% Practical MEEG 2022
% Wakeman & Henson Data analysis: Ereprocess Data Session #1 

% Authors: Ramon Martinez-Cancino, Brain Products, 2022
%          Arnaud Delorme, SCCN, 2022
%          Johanna Wagner, Zander Labs, 2022
%
% Copyright (C) 2022  Johanna Wagner
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

% Clearing all is recommended to avoid variable not being erased between calls 
clear;                                      
clear globals;

% Path to data below. Using relative paths so no need to update.
RootFolder = fileparts(pwd); % Getting root folder
path2data = fullfile(RootFolder,'Data', 'sub-01'); % Path to data 
filename = 'wh_S01_run_01.set';

% Start EEGLAB
[ALLEEG, EEG, CURRENTSET] = eeglab; 

%% Loading data
EEG = pop_loadset('filename', filename,'filepath',path2data);

%% Remove unwanted channels (61-64)
EEG = pop_select(EEG, 'nochannel', [61:64]) ;

%% Re-Reference
% Apply Common Average Reference
EEG = pop_reref(EEG,[]);

%% Resampling
% Downsampling to 100 Hz for speed (for real analysis prefer 250 or 500 Hz)
EEG = pop_resample(EEG, 100);

%% Filter
% Filter the data Highpass at 1 Hz Lowpass at 90Hz (to avoid line noise at 100Hz)
EEG = pop_eegfiltnew(EEG, 1, 0);   % High pass at 1Hz
EEG = pop_eegfiltnew(EEG, 0, 40);  % Low pass below 40

%% Automatic rejection of bad channels
% Apply clean_artifacts() to reject bad channels
if contains(EEG.chanlocs(1).type, 'meg')
    minChanCorr = 0.4;
else
    minChanCorr = 0.9;
end
EEG = clean_artifacts(EEG, 'Highpass', 'off',...
                           'ChannelCriterion', minChanCorr,...
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
% Use second line for speed (but you must install the Picard plugin)
% The -1 for the number of channel is to account for matrix rank 
% decrease due to average reference
if exist('picard') % faster
    EEG = pop_runica( EEG , 'picard', 'pca', EEG.nbchan-1);
else
    EEG = pop_runica( EEG , 'runica', 'extended',1, 'pca', EEG.nbchan-1);
end

%% automatically classify Independent Components using IC Label
% EEG only, MEG would be possible if ICLabel is retrained with MEG
% components instead of EEG components
if ~contains(EEG.chanlocs(1).type, 'meg')
    EEG  = iclabel(EEG);
end

%% Save dataset
EEG = pop_saveset( EEG,'filename', 'wh_S01_run_01_preprocessing_data_session_1_out.set','filepath',path2data);
