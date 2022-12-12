% Practical MEEG 2022
% Wakeman & Henson Data analysis: Preprocessing for group analysis using
% EEGLAB BIDS Tools

% Authors: Arnaud Delorme, SCCN, 2022
%          Ramon Martinez-Cancino, Brain Products, 2022
%          Johanna Wagner, Zander Labs, 2022
%
% Copyright (C) 2022  Arnaud Delorme
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

%% Download the data at https://nemar.org/dataexplorer/detail?dataset_id=ds000117
%% This tutorial only process run 1, but you can change the call to pop_importbids to process all the runs

%%
% Clearing all is recommended to avoid variable not being erased between calls 
clear;                                      
clear globals;

% Comment one of the two lines below to process EEG or MEG data
chantype = { 'megmag' }; % process MEG megmag channels
%chantype = { 'megplanar' }; % process MEG megplanar channels
%chantype = { 'eeg' }; % process EEG

% Paths below must be updated to the files on your enviroment.
RootFolder = fileparts(pwd); % Getting root folder
path2data = fullfile(RootFolder,'Data', 'ds000117_run1'); % Path to data 
path2save = fullfile(RootFolder,'Data', 'ds000117_run1', 'derivative', 'eeglab'); % Path to data 
[ALLEEG, EEG, CURRENTSET] = eeglab; % start EEGLAB

%% IMPORTING THE DATA
[STUDY, ALLEEG] = pop_importbids(path2data, 'bidsevent', 'on', 'bidsevent', 'on', 'bidschanloc', 'off', 'eventtype', 'stim_type', 'outputdir', path2save, 'subjects', [1:3], 'runs', 1);
CURRENTSET = 1:length(ALLEEG); EEG = ALLEEG; CURRENTSTUDY = 1;
eeglab redraw

% Preprocess data
EEG = pop_select(EEG, 'chantype', chantype);
EEG = pop_resample(EEG, 100);
EEG = pop_eegfiltnew(EEG, 1, 0);   % High pass at 1Hz
EEG = pop_eegfiltnew(EEG, 0, 40);  % Low pass below 40

%% Automatic rejection of bad channels
% Apply clean_artifacts() to reject bad channels
if contains(EEG(1).chanlocs(1).type, 'meg')
    minChanCorr = 0.4;
else
    minChanCorr = 0.9;
end
EEG = pop_clean_rawdata(EEG, 'Highpass', 'off',...
    'ChannelCriterion', minChanCorr,...
    'ChannelCriterionMaxBadTime', 0.4,...
    'LineNoiseCriterion', 4,...
    'BurstCriterion', 'off',...
    'WindowCriterion','off' );

%% Re-Reference
EEG = pop_reref(EEG,[]);

% %% Repair bursts and reject bad portions of data
EEG = pop_clean_rawdata( EEG, 'Highpass', 'off',...
    'ChannelCriterion', 'off',...
    'LineNoiseCriterion', 'off',...
    'BurstCriterion', 30,...
    'WindowCriterion',0.3);

%% run ICA
if exist('picard') % faster
    EEG = pop_runica( EEG , 'picard', 'maxiter', 500, 'pca', -1);
else
    EEG = pop_runica( EEG , 'runica', 'extended',1, 'pca', -1);
end

%% automatically classify Independent Components using IC Label
if ~contains(EEG(1).chanlocs(1).type, 'meg')
    EEG = pop_iclabel(EEG, 'default'); % IC label with MEG is technically possible but
                                       % IC label would need to be retrained with MEG components
    EEG = pop_icflag(EEG,  [0 0;0.9 1; 0.9 1; 0 0; 0 0; 0 0; 0 0]);
end

%% Extract event-locked trials using events listed in 'eventlist'
EEG = pop_epoch( EEG,  {'Famous' 'Unfamiliar' 'Scrambled' }, [-1  2], 'epochinfo', 'yes');

%% Perform baseline correction
EEG = pop_rmbase(EEG, [-1000 0]);

%% Clean data by rejecting epochs.
[EEG, rejindx] = pop_eegthresh(EEG, 1, [], -400, 400, EEG(1).xmin, EEG(1).xmax, 0, 1);

%% Settings for dipole localization
EEG = pop_dipfit_settings( EEG, 'model', 'standardBEM', 'coord_transform', 'warpfiducials');
EEG = pop_multifit(EEG, [1:10],'threshold', 100, 'dipplot','off');

%% Create STUDY design
ALLEEG = EEG;
STUDY = std_maketrialinfo(STUDY, ALLEEG);
STUDY = std_makedesign(STUDY, ALLEEG, 1, 'name','STUDY.design 1','delfiles','off', ...
    'defaultdesign','off','variable1','type','values1',{'Famous' 'Unfamiliar' 'Scrambled' },'vartype1','categorical'); 

%% Precompute measures
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','rmicacomps','on','interp','on','recompute','on','erp','on');

%% Plot at 170 ms
chanList = eeg_mergelocs(ALLEEG.chanlocs);
STUDY = pop_erpparams(STUDY, 'plotconditions','together', 'topotime',[] );
STUDY = std_erpplot(STUDY,ALLEEG,'channels', {chanList.labels}, 'design', 1);
STUDY = pop_erpparams(STUDY, 'topotime',170 );
STUDY = std_erpplot(STUDY,ALLEEG,'channels',{chanList.labels}, 'design', 1);

%% Clustering
warning off; % for meg channel location
STUDY = std_checkset(STUDY,ALLEEG);
[STUDY ALLEEG]  = std_precomp(STUDY, ALLEEG, 'components','savetrials','on','recompute','on','erp','on','scalp','on','erpparams',{'rmbase' [-100 0]});
[STUDY ALLEEG]  = std_preclust(STUDY, ALLEEG, 1,{'erp' 'npca' 10 'weight' 1 'timewindow' [100 800]  'erpfilter' '25'},{'scalp' 'npca' 10 'weight' 1 'abso' 1},{'dipoles' 'weight' 10});
nclusters = 15;
[STUDY]         = pop_clust(STUDY, ALLEEG, 'algorithm','kmeans','clus_num',  nclusters , 'outliers',  2.8 );

%% Figures STUDY
% All clusters ERPs
STUDY = pop_erpparams(STUDY, 'filter',15,'timerange',[-100 400] );
STUDY = std_erpplot(STUDY,ALLEEG,'clusters',[2:nclusters+1], 'design', 1);

% All clusters topos
STUDY = std_topoplot(STUDY,ALLEEG,'clusters',[2:nclusters+1], 'design', 1);

% All clusters dipoles
STUDY = std_dipplot(STUDY,ALLEEG,'clusters',[2:nclusters+1], 'design', 1, 'spheres', 'off');
