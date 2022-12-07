% Practical MEEG 2022
% Wakeman & Henson Data analysis: Dipiole localization

% Authors: Ramon Martinez-Cancino, Brain Products, 2022
%          Arnaud Delorme, SCCN, 2022
%          Johanna Wagner, Zander Labs, 2022
%
% Copyright (C) 2022  Ramon Martinez-Cancino 
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%%
% Clearing all is recommended to avoid variable not being erased between calls 
clear;                                      
clear globals;

% Path to data below. Using relative paths so no need to update.
RootFolder = fileparts(pwd); % Getting root folder
path2data = fullfile(RootFolder,'Data', 'sub-01'); % Path to data 
filename = 'wh_S01_run_01_preprocessing_data_session_1_out.set';

% Start EEGLAB
[ALLEEG, EEG, CURRENTSET] = eeglab; 

%% Loading data
EEG = pop_loadset('filename', filename,'filepath',path2data);


%% Extract event-locked trials using events
EEG = pop_epoch( EEG, {'Famous', 'Unfamiliar', 'Scrambled'}, [-1  2], 'newname', 'WH_Epoched', 'epochinfo', 'yes');

% Perform baseline correction
EEG = pop_rmbase(EEG, [-1000 0]);

%%  Clean data by rejecting epochs.
EEG = pop_eegthresh(EEG, 1, 1:EEG.nbchan, -400, 400, EEG.xmin, EEG.xmax, 0, 1);

[M,I] = max(EEG.etc.ic_classification.ICLabel.classifications,[],2);                       % Use max prob for classification
Brain_comps = find(I == find(strcmp(EEG.etc.ic_classification.ICLabel.classes, 'Brain')));


%% Subtract artefactual components from the EEG
EEG = pop_subcomp( EEG, Brain_comps, 0, 1);


%% Estimate single equivalent current dipoles
dipfitpath       = fileparts(which('pop_multifit'));
electemplatepath = fullfile(dipfitpath,'standard_BEM/elec/standard_1005.elc');

[~,coord_transform] = coregister(EEG.chaninfo.nodatchans, electemplatepath, 'warp', 'auto', 'manual', 'off');

EEG = pop_dipfit_settings( EEG, 'hdmfile', fullfile(dipfitpath,'standard_BEM/standard_vol.mat'),...
    'coordformat', 'MNI', 'chanfile', electemplatepath,'coord_transform', coord_transform,...
    'mrifile', fullfile(dipfitpath,'standard_BEM/standard_mri.mat'));

EEG = pop_multifit(EEG, 1:EEG.nbchan,'threshold', 100, 'dipplot','off','plotopt',{'normlen' 'on'});

% Fitting dual dipole (for you may not be IC 4, check and asses)
FusiformIC = 4;

EEG = pop_multifit(EEG, FusiformIC, 'threshold', 100, 'dipoles', 2, 'plotopt', {'normlen' 'on'});


%% Plot of all dipoles
pop_dipplot( EEG, [1:length(Brain_comps)] ,'mri',fullfile(dipfitpath,'/standard_BEM/standard_mri.mat'),'normlen','on');


%% ERP Image Dipole on Fusiform Area
figure; 
% Changing dipolarity
EEG.icaweights(FusiformIC,:) = -EEG.icaweights(FusiformIC,:);
EEG.icawinv(:,FusiformIC) = -EEG.icawinv(:,FusiformIC);
EEG.icaact(FusiformIC,:) = -EEG.icaact(FusiformIC,:);

pop_erpimage(EEG,0, FusiformIC,[[]],'Comp. 4',10,1,{},[],'' ,'yerplabel','','erp','on','cbar','on','topo', { mean(EEG.icawinv(:,[4]),2) EEG.chanlocs EEG.chaninfo } );

%% Saving data
EEG = pop_saveset( EEG,'filename', 'wh_S01_run_01_Source_Reconstruction_Session_4_out.set','filepath', path2data);
