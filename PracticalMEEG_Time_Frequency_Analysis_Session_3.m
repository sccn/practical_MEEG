% Practical MEEG 2022
% Wakeman & Henson Data analysis: Spectral and Time-Frequency Analsyis

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
filename_epoched_famous     = 'wh_S01_run_01_ERP_Analysis_Session_2_famous_out.set';
filename_epoched_unfamiliar = 'wh_S01_run_01_ERP_Analysis_Session_2_unfamiliar_out.set';
filename_epoched_scrambled  = 'wh_S01_run_01_ERP_Analysis_Session_2_scrambled_out.set';

% Start EEGLAB
[ALLEEG, EEG, CURRENTSET] = eeglab; 

%% Loading data
EEG = pop_loadset('filename', filename,'filepath',path2data);

%% Identifying Artifacts Using ICLabel and removing them (EEG only)
if ~contains(EEG.chanlocs(1).type, 'meg')
    [M,I] = max(EEG.etc.ic_classification.ICLabel.classifications,[],2);                       % Use max prob for classification
    Brain_comps = find(I == find(strcmp(EEG.etc.ic_classification.ICLabel.classes, 'Brain')));
    EEG = pop_subcomp( EEG, Brain_comps, 0, 1);
end

%%-------------------------------------------------------------------------
%% Plot spectrum using Welch’s method

% Default vaues. winsize = Sampling Rate; overlap = 0
figure('name', 'spectopo_defaults'); 
pop_spectopo(EEG, 1, [0 EEG.xmax*1000], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 40],'electrodes','off');
% saveas(gcf,'spectopo_defaults.jpg') 

% winsize = 200; overlap = 0
figure('name', 'winsize = 200; overlap = 0'); 
pop_spectopo(EEG, 1, [0 EEG.xmax*1000], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 40],'electrodes','off', 'winsize', 200);

% winsize = 300; overlap = 0
figure('name', 'winsize = 300; overlap = 0');
pop_spectopo(EEG, 1, [0 EEG.xmax*1000], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 40],'electrodes','off', 'winsize', 300);
saveas(gcf,'spectopo_winsize_300.jpg')

% winsize = 300; overlap = 5
figure('name', 'winsize = 300; overlap = 50');
pop_spectopo(EEG, 1, [0 EEG.xmax*1000], 'EEG' , 'freq', [6 10 22], 'freqrange',[2 40],'electrodes','off', 'winsize', 300, 'overlap', 50);

%% Plot spectrum for channel eeg065

figure('name', 'Spectrum Channel EEG065'); 
spectopo( EEG.data(55,:), EEG.pnts, EEG.srate,'winsize', 300, 'overlap', 50);
title('Spectrum Channel EEG065')

%% Time-frequency
%% ERS Vs ERP

% Load Epoched data here
EEG_famous = pop_loadset('filename', filename_epoched_famous,'filepath',path2data);
EEG_unfamiliar = pop_loadset('filename', filename_epoched_unfamiliar,'filepath',path2data);
EEG_scrambled = pop_loadset('filename', filename_epoched_scrambled,'filepath',path2data);


figure; 
pop_newtimef( EEG_famous, 1, 52, [-1000  1990], [3 0.8] , 'topovec', 52,...
                                                   'elocs', EEG_famous.chanlocs,...
                                                   'chaninfo', EEG_famous.chaninfo,...
                                                   'caption', 'ERS: Famous eeg065',...
                                                   'baseline', [NaN],...
                                                   'plotitc' , 'off',...
                                                   'plotphase', 'off',...
                                                   'padratio', 1,...
                                                   'winsize', 100);

figure; 
pop_newtimef( EEG_famous, 1, 52, [-1000  1990], [3 0.8] , 'topovec', 52,...
                                                   'elocs', EEG_famous.chanlocs,...
                                                   'chaninfo', EEG_famous.chaninfo,...
                                                   'caption', 'ERSP: Famous eeg065',...
                                                   'baseline', 1,...
                                                   'plotitc' , 'off',...
                                                   'plotphase', 'off',...
                                                   'padratio', 1,...
                                                   'winsize', 100);

%% ERSP all conditions with same scale                                           

% ERSP for famous faces
figure; 
pop_newtimef( EEG_famous, 1, 52, [-1000  1990], [3 0.8] , 'topovec', 52,...
                                                   'elocs', EEG_famous.chanlocs,...
                                                   'chaninfo', EEG_famous.chaninfo,...
                                                   'caption', 'ERS: Famous eeg065',...
                                                   'baseline', 1,...
                                                   'plotitc' , 'off',...
                                                   'plotphase', 'off',...
                                                   'padratio', 1,...
                                                   'winsize', 100,...
                                                   'erspmax', 3);

                                               
% ERSP for undfamiliar faces
figure; 
pop_newtimef( EEG_unfamiliar, 1, 52, [-1000  1990], [3 0.8] , 'topovec', 52,...
                                                   'elocs', EEG_unfamiliar.chanlocs,...
                                                   'chaninfo', EEG_unfamiliar.chaninfo,...
                                                   'caption', 'ERSP: Unfamiliar eeg065',...
                                                   'baseline', 1,...
                                                   'plotitc' , 'off',...
                                                   'plotphase', 'off',...
                                                   'padratio', 1,...
                                                   'winsize', 100,...
                                                   'erspmax', 3);


                                               
% ERSP for scrambled faces
figure; 
pop_newtimef( EEG_scrambled, 1, 52, [-1000  1990], [3 0.8] , 'topovec', 52,...
                                                   'elocs', EEG_scrambled.chanlocs,...
                                                   'chaninfo', EEG_scrambled.chaninfo,...
                                                   'caption', 'ERSP: Scrambled eeg065',...
                                                   'baseline', 1,...
                                                   'plotitc' , 'off',...
                                                   'plotphase', 'off',...
                                                   'padratio', 1,...
                                                   'winsize', 100,...
                                                   'erspmax', 3);             
                                               
% For significance testing, add option: 'alpha',0.01                                               