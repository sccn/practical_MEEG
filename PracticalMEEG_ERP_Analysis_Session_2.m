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

% Path to data belo. Using relative paths so no need to update.
RootFolder = '/System/Volumes/Data/data/practicalMEEG'; 
if ~exist(RootFolder)
    RootFolder = fileparts(pwd); % Getting root folder
end
path2data = fullfile(RootFolder,'Data', 'sub-01') % Path to data 
filename = 'wh_S01_run_01_preprocessing_data_session_1_out.set';

% Start EEGLAB
[ALLEEG, EEG, CURRENTSET] = eeglab; 

% restart EEGLAB
[ALLEEG, EEG, CURRENTSET] = eeglab; 

% Loading data
EEG = pop_loadset('filename', filename,'filepath',path2data)

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1); 
%% ERP analysis

%% Extract event-locked trials using events listed in 'eventlist'
ALLEEG(2) = pop_epoch( ALLEEG(1), {'Famous'}, [-1  2], 'newname', 'Famous Epoched', 'epochinfo', 'yes');
ALLEEG(3) = pop_epoch( ALLEEG(1), {'Unfamiliar'}, [-1  2], 'newname', 'Unfamiliar Epoched', 'epochinfo', 'yes');
ALLEEG(4) = pop_epoch( ALLEEG(1), {'Scrambled'}, [-1  2], 'newname', 'Scrambled Epoched', 'epochinfo', 'yes');

%% Perform baseline correction
ALLEEG(2) = pop_rmbase(ALLEEG(2), [-1000 0]);
ALLEEG(3) = pop_rmbase(ALLEEG(3), [-1000 0]);
ALLEEG(4) = pop_rmbase(ALLEEG(4), [-1000 0]);

%% Clean data by rejecting epochs.
[ALLEEG(2), rejindx] = pop_eegthresh(ALLEEG(2), 1, 1:ALLEEG(2).nbchan, -400, 400, ALLEEG(2).xmin, ALLEEG(2).xmax, 0, 1);
[ALLEEG(3), rejindx] = pop_eegthresh(ALLEEG(3), 1, 1:ALLEEG(3).nbchan, -400, 400, ALLEEG(3).xmin, ALLEEG(3).xmax, 0, 1);
[ALLEEG(4), rejindx] = pop_eegthresh(ALLEEG(4), 1, 1:ALLEEG(4).nbchan, -400, 400, ALLEEG(4).xmin, ALLEEG(4).xmax, 0, 1);
return

%% plot ERP scalp distribution 
figure; pop_timtopo(ALLEEG(2), [-100  600], [NaN], 'ERP data and scalp maps of Famous Epoched');
figure; pop_timtopo(ALLEEG(3), [-100  600], [NaN], 'ERP data and scalp maps of Unfamiliar Epoched');
figure; pop_timtopo(ALLEEG(4), [-100  600], [NaN], 'ERP data and scalp maps of Scrambled Epoched');

%% plot Component 5 contributions to ERP scalp envelope with channel projection 
pop_envtopo(ALLEEG(2), [-100  600] ,'limcontrib',[0 400],'compsplot',[7],'compnums',[5],'title', 'Famous','electrodes','off', 'plotproj', 1);

%% plot Component contributions to ERP scalp envelope 
pop_envtopo(ALLEEG(2), [-100  600] ,'limcontrib',[0 400],'compsplot',[7],'title', 'Largest ERP components of Famous Epoched','electrodes','off');
pop_envtopo(ALLEEG(3), [-100  600] ,'limcontrib',[0 400],'compsplot',[7],'title', 'Largest ERP components of Unfamiliar Epoched','electrodes','off');
pop_envtopo(ALLEEG(4), [-100  600] ,'limcontrib',[0 400],'compsplot',[7],'title', 'Largest ERP components of Scrambled Epoched','electrodes','off');

%% plot Component contributions to ERP scalp envelope - removing artefact ICs
pop_envtopo(ALLEEG(2), [-100  600] ,'limcontrib',[0 400],'compsplot',[7],'subcomps',[1 6],'title', 'Largest ERP components of Famous Epoched','electrodes','off');
pop_envtopo(ALLEEG(3), [-100  600] ,'limcontrib',[0 400],'compsplot',[7],'subcomps',[1 6],'title', 'Largest ERP components of Unfamiliar Epoched','electrodes','off');
pop_envtopo(ALLEEG(4), [-100  600] ,'limcontrib',[0 400],'compsplot',[7],'subcomps',[1 6],'title', 'Largest ERP components of Scrambled Epoched','electrodes','off');

%% plot Component contributions to ERP scalp envelope - removing artefact ICs - plot differences between conditions
pop_envtopo(([ALLEEG(2)  ALLEEG(4)]), [-100  600] ,'limcontrib',[0 400],'compsplot',[7],'subcomps',[1 6],'title', 'Famous - Scrambled','electrodes','off');
pop_envtopo(([ALLEEG(2)  ALLEEG(3)]), [-100  600] ,'limcontrib',[0 400],'compsplot',[7],'subcomps',[1 6],'title', 'Famous - Unfamiliar','electrodes','off');
pop_envtopo(([ALLEEG(3)  ALLEEG(4)]), [-100  600] ,'limcontrib',[0 400],'compsplot',[7],'subcomps',[1 6],'title', 'Unfamiliar - Scrambled','electrodes','off');

%% Identify Brain ICs using IC Label classification results
[M,I] = max(ALLEEG(1).etc.ic_classification.ICLabel.classifications,[],2);                       % Use max prob for classification
Brain_comps = find(I == find(strcmp(ALLEEG(1).etc.ic_classification.ICLabel.classes, 'Brain')));

%% Subtract artefactual components from the EEG
ALLEEG(2) = pop_subcomp( ALLEEG(2), Brain_comps, 0, 1);
ALLEEG(3) = pop_subcomp( ALLEEG(3), Brain_comps, 0, 1);
ALLEEG(4) = pop_subcomp( ALLEEG(4), Brain_comps, 0, 1);

%% Rename datasets
ALLEEG(2) = pop_editset(ALLEEG(2), 'setname', 'Famous', 'run', []);
ALLEEG(3) = pop_editset(ALLEEG(3), 'setname', 'Unfamiliar', 'run', []);
ALLEEG(4) = pop_editset(ALLEEG(4), 'setname', 'Scrambled', 'run', []);

%% plot ERP scalp distribution 
figure; pop_timtopo(ALLEEG(2), [-100  600], [NaN], 'Famous');
figure; pop_timtopo(ALLEEG(3), [-100  600], [NaN], 'Unfamiliar');
figure; pop_timtopo(ALLEEG(4), [-100  600], [NaN], 'Scrambled');

%% plot ERP scalp distribution at each ERP peak
figure; pop_timtopo(ALLEEG(2), [-100  600], [120  170  250], 'Famous');
figure; pop_timtopo(ALLEEG(3), [-100  600], [120  170  250], 'Unfamiliar');
figure; pop_timtopo(ALLEEG(4), [-100  600], [120  170  250], 'Scrambled');

%% plot 3 largest contributing ICs to ERP
pop_envtopo(ALLEEG(2), [-100  600] ,'limcontrib',[0 400],'compsplot',[3],'title', 'Famous','electrodes','off');
pop_envtopo(ALLEEG(3), [-100  600] ,'limcontrib',[0 400],'compsplot',[3],'title', 'Unfamiliar','electrodes','off');
pop_envtopo(ALLEEG(4), [-100  600] ,'limcontrib',[0 400],'compsplot',[3],'title', 'Scrambled','electrodes','off');

%% Visualize channel ERPs in 2D
pop_topoplot(ALLEEG(2), 1, [25:25:300] ,'Famous',[3 4] ,0,'electrodes','on');
pop_topoplot(ALLEEG(3), 1, [25:25:300] ,'Unfamiliar',[3 4] ,0,'electrodes','on');
pop_topoplot(ALLEEG(4), 1, [25:25:300] ,'Scrambled',[3 4] ,0,'electrodes','on');

%% Plot channel ERPs in topographic array
figure; pop_plottopo(ALLEEG(2), [1:64] , 'Famous', 0, 'ydir',1);
figure; pop_plottopo(ALLEEG(3), [1:64] , 'Unfamiliar', 0, 'ydir',1);
figure; pop_plottopo(ALLEEG(4), [1:64] , 'Scrambled', 0, 'ydir',1);


%% plot average ERPs for each condition with standard deviation

% find channel index of eeg065
Chanind = find(strcmp({ALLEEG(2).chanlocs.labels},'eeg065'));

% create timevector for plotting 
[val, indL] = min(abs(ALLEEG(2).times+200)); %get timepoints for -200 and 800 Latencies
[val, indU] = min(abs(ALLEEG(2).times-800));
timevec = ALLEEG(2).times(indL:indU); % create timevector

% clear aa
% clear bb
% [bb,aa] = butter (4, [10] ./ (ALLEEG(2).srate / 2), 'low' );
% freqz(bb,aa,ALLEEG(2).srate, 100)
%Famous_filt = filter(bb, aa, mean(ALLEEG(2).data(Chanind,:,:),3));

% Famous_filt = filter(bb, aa, ALLEEG(2).data(Chanind,:,:), [], 2);
% Unfamiliar_filt = filter(bb, aa, ALLEEG(3).data(Chanind,:,:), [], 2);
% Scrambled_filt = filter(bb, aa, ALLEEG(4).data(Chanind,:,:), [], 2);

% create datavectors for plotting
av_datavecF = mean(ALLEEG(2).data(Chanind,indL:indU,:),3); % average
std_datavecF = std(ALLEEG(2).data(Chanind,indL:indU,:),1,3); % standard deviation

figure;
X2 = [[timevec],fliplr([timevec])];                %#create continuous x value array for plotting
Y2 = [av_datavecF-std_datavecF,fliplr(av_datavecF+std_datavecF)];              %#create y values for out and then back
fill(X2,Y2,[153/255 204/255 255/255]);
hold on
plot(timevec,av_datavecF, 'b', 'LineWidth',2)
xline(0, 'LineWidth',2)
yline(0, 'LineWidth',2)
xlabel('Latency ms')
ylabel('mu Volt')
title('famous')
set(gca, 'FontSize', 15)

av_datavecU = mean(ALLEEG(3).data(Chanind,indL:indU,:),3); % average
std_datavecU = std(ALLEEG(3).data(Chanind,indL:indU,:),1,3); % standard deviation

figure;
X2 = [[timevec],fliplr([timevec])];                %#create continuous x value array for plotting
Y2 = [av_datavecU-std_datavecU,fliplr(av_datavecU+std_datavecU)];              %#create y values for out and then back
fill(X2,Y2,[153/255 204/255 255/255]);
hold on
plot(timevec,av_datavecU, 'b', 'LineWidth',2)
xline(0, 'LineWidth',2)
yline(0, 'LineWidth',2)
xlabel('Latency ms')
ylabel('mu Volt')
title('unfamiliar')
set(gca, 'FontSize', 15)

av_datavecS = mean(ALLEEG(4).data(Chanind,indL:indU,:),3); % average
std_datavecS = std(ALLEEG(4).data(Chanind,indL:indU,:),1,3); % standard deviation

figure;
X2 = [[timevec],fliplr([timevec])];                %#create continuous x value array for plotting
Y2 = [av_datavecS-std_datavecS,fliplr(av_datavecS+std_datavecS)];              %#create y values for out and then back
fill(X2,Y2,[153/255 204/255 255/255]);
hold on
plot(timevec,av_datavecS, 'b', 'LineWidth',2)
xline(0, 'LineWidth',2)
yline(0, 'LineWidth',2)
xlabel('Latency ms')
ylabel('mu Volt')
title('scrambled')
set(gca, 'FontSize', 15)

%% plot superimposed ERPs

figure;plot(timevec,av_datavecF, 'LineWidth',2, 'color', 'r'); hold on
plot(timevec,av_datavecU, 'LineWidth',2, 'color', 'b')
plot(timevec,av_datavecS, 'LineWidth',2, 'color', 'g')
fillcurves(timevec,av_datavecF-std_datavecF,av_datavecF+std_datavecF, 'r', 0.2);
fillcurves(timevec,av_datavecU-std_datavecU,av_datavecU+std_datavecU, 'b', 0.2);
fillcurves(timevec,av_datavecS-std_datavecS,av_datavecS+std_datavecS, 'g', 0.2);
xline(0, 'LineWidth',2)
yline(0, 'LineWidth',2)
xlabel('Latency ms')
ylabel('mu Volt')
legend('famous', 'unfamiliar', 'scrambled')
set(gca, 'FontSize', 15)

%% ERPimage
figure; pop_erpimage(ALLEEG(2),1, [55],[[]],'eeg065',3,1,{},[],'' ,'yerplabel','\muV','erp','on','limits',[-100 1200 NaN NaN NaN NaN NaN NaN] ,'cbar','on','topo', { [55] EEG.chanlocs EEG.chaninfo } );
figure; pop_erpimage(ALLEEG(3),1, [55],[[]],'eeg065',3,1,{},[],'' ,'yerplabel','\muV','erp','on','limits',[-100 1200 NaN NaN NaN NaN NaN NaN] ,'cbar','on','topo', { [55] EEG.chanlocs EEG.chaninfo } );
figure; pop_erpimage(ALLEEG(4),1, [55],[[]],'eeg065',3,1,{},[],'' ,'yerplabel','\muV','erp','on','limits',[-100 1200 NaN NaN NaN NaN NaN NaN] ,'cbar','on','topo', { [55] EEG.chanlocs EEG.chaninfo } );

% sort by event latency
figure; pop_erpimage(ALLEEG(2),1, [55],[[]],'eeg065',3,1,{ 'left_nonsym' 'right_sym'},[],'latency' ,'yerplabel','\muV','erp','on','limits',[-100 1200 NaN NaN NaN NaN NaN NaN] ,'cbar','on','topo', { [55] EEG.chanlocs EEG.chaninfo } );
figure; pop_erpimage(ALLEEG(3),1, [55],[[]],'eeg065',3,1,{ 'left_nonsym' 'right_sym'},[],'latency' ,'yerplabel','\muV','erp','on','limits',[-100 1200 NaN NaN NaN NaN NaN NaN] ,'cbar','on','topo', { [55] EEG.chanlocs EEG.chaninfo } );
figure; pop_erpimage(ALLEEG(4),1, [55],[[]],'eeg065',3,1,{ 'left_nonsym' 'right_sym'},[],'latency' ,'yerplabel','\muV','erp','on','limits',[-100 1200 NaN NaN NaN NaN NaN NaN] ,'cbar','on','topo', { [55] EEG.chanlocs EEG.chaninfo } );

%% Save dataset
EEG_famous = pop_saveset( ALLEEG(2),'filename', 'wh_S01_run_01_ERP_Analysis_Session_2_famous_out.set','filepath',path2data);
EEG_unfamiliar = pop_saveset( ALLEEG(3),'filename', 'wh_S01_run_01_ERP_Analysis_Session_2_unfamiliar_out.set','filepath',path2data);
EEG_scrambled = pop_saveset( ALLEEG(4),'filename', 'wh_S01_run_01_ERP_Analysis_Session_2_scrambled_out.set','filepath',path2data);
