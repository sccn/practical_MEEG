% Practical MEEG 2022
% Wakeman & Henson Data analysis: Preprocessing for group analysis

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

% Clearing all is recommended to avoid variable not being erased between calls 
clear;                                      
clear globals;

% Paths to data. Using relative paths so no need to update.
RootFolder = fileparts(pwd); % Getting root folder
path2data = fullfile(RootFolder,'Data', 'ds002718_5_Subjects') % Path to  the original unzipped data files

% Start EEGLAB
[ALLEEG, EEG, CURRENTSET] = eeglab; 


for isubj = 2:6
    
    current_path2data = fullfile(path2data,['sub-00', num2str(isubj)],'eeg');
    current_filename = ['sub-00' num2str(isubj) '_task-FaceRecognition_eeg.set'];
    current_savefilename = ['sub-00' num2str(isubj) '_task-FaceRecognition_eeg_proc.set'];
    
    %% Load data previously imported
    EEG = pop_loadset('filename', current_filename , 'filepath', current_path2data);
    
    %% Remove unwanted channels (61-64)
    EEG = pop_select(EEG, 'nochannel', [61:64]) ;
    
    %% Recomputing head center
    EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[])');
    
    %% Re-Reference
    % Apply Common Average Reference
    EEG = pop_reref(EEG,[]);
    
    %% Resampling
    % Downsampling to 250 Hz
    EEG = pop_resample(EEG, 100);
    
    %% Filter
    % Filter the data Highpass at 1 Hz Lowpass at 90Hz (to avoid line noise at 100Hz)
    EEG = pop_eegfiltnew(EEG, 1, 0);   % High pass at 1Hz
    EEG = pop_eegfiltnew(EEG, 0, 40);  % Low pass below 40
    
    %% Automatic rejection of bad channels
    % Apply clean_artifacts() to reject bad channels
    EEG = clean_artifacts(EEG, 'Highpass', 'off',...
        'ChannelCriterion', 0.9,...
        'ChannelCriterionMaxBadTime', 0.4,...
        'LineNoiseCriterion', 4,...
        'BurstCriterion', 'off',...
        'WindowCriterion','off' );
    
    %% Re-Reference
    EEG = pop_reref(EEG,[]);
    
    % %% Repair bursts and reject bad portions of data
    EEG = clean_artifacts( EEG, 'Highpass', 'off',...
        'ChannelCriterion', 'off',...
        'LineNoiseCriterion', 'off',...
        'BurstCriterion', 30,...
        'WindowCriterion',0.3);
        
    %% run ICA
    EEG = pop_runica(EEG, 'icatype', 'picard', 'maxiter',10,'mode','standard','pca', EEG.nbchan-1);
    % EEG = pop_runica( EEG , 'runica', 'extended',1, 'pca', EEG.nbchan-1);
    %% automatically classify Independent Components using IC Label
    EEG  = iclabel(EEG);
    
    %% Identify Brain ICs using IC Label classification results
    [M,I] = max(EEG.etc.ic_classification.ICLabel.classifications,[],2);                       % Use max prob for classification
    Brain_comps = find(I == find(strcmp(EEG.etc.ic_classification.ICLabel.classes, 'Brain')));

    %% Removing components
    EEG = pop_subcomp(EEG, Brain_comps,0,1);  
    
    %% Extract event-locked trials using events listed in 'eventlist'
    EEG = pop_epoch( EEG,  {'famous_new' 'famous_second_early' 'famous_second_late'...
                            'scrambled_new' 'scrambled_second_early' 'scrambled_second_late',...
                            'unfamiliar_new' 'unfamiliar_second_early' 'unfamiliar_second_late'},...
                            [-1  2], 'newname', 'wh_S01_allruns_preproc', 'epochinfo', 'yes');
    
    %% Perform baseline correction
    EEG = pop_rmbase(EEG, [-1000 0]);

    %% Clean data by rejecting epochs.
    [EEG, rejindx] = pop_eegthresh(EEG, 1, 1:EEG.nbchan, -400, 400, EEG.xmin, EEG.xmax, 0, 1);
    
    %% Estimate single equivalent current dipoles
    dipfitpath       = fileparts(which('pop_multifit'));
    electemplatepath = fullfile(dipfitpath,'standard_BEM/elec/standard_1005.elc');
    [~,coord_transform] = coregister(EEG.chaninfo.nodatchans, electemplatepath, 'warp', 'auto', 'manual', 'off');
    EEG = pop_dipfit_settings( EEG, 'hdmfile', fullfile(dipfitpath,'standard_BEM/standard_vol.mat'),...
                                    'coordformat', 'MNI', 'chanfile', electemplatepath,'coord_transform', coord_transform,...
                                    'mrifile', fullfile(dipfitpath,'standard_BEM/standard_mri.mat')); 
    
    EEG = pop_multifit(EEG, 1:EEG.nbchan,'threshold', 100, 'dipplot','off','plotopt',{'normlen' 'on'});

    %% Save dataset
    EEG = pop_saveset( EEG,'filename', current_savefilename,'filepath', current_path2data);
end