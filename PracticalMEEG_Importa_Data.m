% Wakeman & Henson Data analysis: Extract EEG data and import events and channel location

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

% script folder, this must be updated to the files on your enviroment.
clear;                                      % clearing all is recommended to avoid variable not being erased between calls 
clear globals;

% Paths below must be updated to the files on your enviroment.
path2data = '/Users/amon-ra/Desktop/Data_PracticalMEEG/Data/sub-01';  % Define path to  the original unzipped data files
path2save = '/Users/amon-ra/Desktop/Data_PracticalMEEG/Data/Imported_subj-01';   % Define to save EEGLAB files
filename = 'sub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg.fif';

[ALLEEG, EEG, CURRENTSET] = eeglab; % start EEGLAB


%% IMPORTING THE DATA

% Step 1: Importing data with FileIO
EEG = pop_fileio(fullfile(path2data, filename));

% Adjust some fields
EEG.filename = 'ub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg.fif';
EEG.setname = 'sub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg';
EEG.subject = 'sub-01';

% List of EEG channels of interest
ListOfChannels =  {'EEG001' 'EEG002' 'EEG003' 'EEG004' 'EEG005' 'EEG006' 'EEG007' 'EEG008' 'EEG009' 'EEG010' 'EEG011' 'EEG012' 'EEG013' 'EEG014' 'EEG015'...
                   'EEG016' 'EEG017' 'EEG018' 'EEG019' 'EEG020' 'EEG021' 'EEG022' 'EEG023' 'EEG024' 'EEG025' 'EEG026' 'EEG027' 'EEG028' 'EEG029' 'EEG030'...
                   'EEG031' 'EEG032' 'EEG033' 'EEG034' 'EEG035' 'EEG036' 'EEG037' 'EEG038' 'EEG039' 'EEG040' 'EEG041' 'EEG042' 'EEG043' 'EEG044' 'EEG045'...
                   'EEG046' 'EEG047' 'EEG048' 'EEG049' 'EEG050' 'EEG051' 'EEG052' 'EEG053' 'EEG054' 'EEG055' 'EEG056' 'EEG057' 'EEG058' 'EEG059' 'EEG060'...
                   'EEG061' 'EEG062' 'EEG063' 'EEG064' 'EEG065' 'EEG066' 'EEG067' 'EEG068' 'EEG069' 'EEG070' 'EEG071' 'EEG072' 'EEG073' 'EEG074' 'STI101'};

% Update Channel Labels
[EEG.chanlocs.labels] = EEG.urchanlocs.labels;


% Step 2: Selecting EEG data and event (STI101) channels
% EEG channels 1-60 are EEG, as are 65-70, but channels 61-64 are actually HEOG, VEOG and two floating channels (EKG).
EEG = pop_select(EEG, 'channel', ListOfChannels) ;


% Step 3: Adding fiducials and rotating montage. Note:The channel location from this points were extracted from the sub-01_ses-meg_coordsystem.json
% files (see below) and written down here. The reason is that File-IO does not import these coordinates.

LPA = [-71, 0, 0]/10;
RPA = [77.56,0,0]/10;
Nz = [0, 106.36, 0]/10;

EEG = pop_chanedit(EEG,'append',{length(EEG.chanlocs) 'LPA'  [] [] LPA(1)   LPA(2) LPA(3)    [] [] [] 'FID' '' [] 0 [] []});
EEG = pop_chanedit(EEG,'append',{length(EEG.chanlocs) 'RPA'  [] [] RPA(1)   RPA(2) RPA(3)    [] [] [] 'FID' '' [] 0 [] []});
EEG = pop_chanedit(EEG,'append',{length(EEG.chanlocs) 'Nz'   [] [] Nz(1)    Nz(2)  Nz(3)     [] [] [] 'FID' '' [] 0 [] []});
EEG = pop_chanedit(EEG,'nosedir','+Y');


% Changing Channel types and removing channel locations for channels 61-64 (Raw data types are incorrect)
EEG = pop_chanedit(EEG,'changefield',{61  'type' 'HEOG'  'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
EEG = pop_chanedit(EEG,'changefield',{62  'type' 'VEOG'  'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
EEG = pop_chanedit(EEG,'changefield',{63  'type' 'EKG'   'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
EEG = pop_chanedit(EEG,'changefield',{64  'type' 'EKG'   'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});

% Step 4: Recomputing head center
% EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[])');

% Step 5: Re-import events from STI101 channel (the original ones are incorect)
edgelenval = 1;
EEG = pop_chanevent(EEG, 75,'edge','leading','edgelen',edgelenval,'delevent','on','delchan','off','oper','double(bitand(int32(X),31))'); % first 5 bits

% Step 6: Cleaning artefactual events (keep only valid event codes) (
% NOT BE NECCESARY FOR US
EEG = pop_selectevent( EEG, 'type',[5 6 7 13 14 15 17 18 19] ,'deleteevents','on');

% Step 7: Importing  button press info
EEG = pop_chanevent(EEG, 75,'edge','leading','edgelen', edgelenval, 'delevent','off','oper','double(bitand(int32(X),8160))'); % bits 5 to 13

EEG.event(74).type = 256; % Overlapping of 256 and 4096

% Step 8: Renaming button press events
EEG = pop_selectevent( EEG, 'type',256, 'renametype', 'left_nonsym','deleteevents','off');  % Event type : 'left_nonsym'
EEG = pop_selectevent( EEG, 'type',4096,'renametype', 'right_sym','deleteevents','off');    % Event type : 'right_sym'

% Step 9: Rename face presentation events (information provided by authors)
EEG = pop_selectevent( EEG, 'type',5,'renametype','Famous','deleteevents','off');           % famous_new
EEG = pop_selectevent( EEG, 'type',6,'renametype','Famous','deleteevents','off');           % famous_second_early
EEG = pop_selectevent( EEG, 'type',7,'renametype','Famous','deleteevents','off');           % famous_second_late

EEG = pop_selectevent( EEG, 'type',13,'renametype','Unfamiliar','deleteevents','off');      % unfamiliar_new
EEG = pop_selectevent( EEG, 'type',14,'renametype','Unfamiliar','deleteevents','off');      % unfamiliar_second_early
EEG = pop_selectevent( EEG, 'type',15,'renametype','Unfamiliar','deleteevents','off');      % unfamiliar_second_late

EEG = pop_selectevent( EEG, 'type',17,'renametype','Scrambled','deleteevents','off');       % scrambled_new
EEG = pop_selectevent( EEG, 'type',18,'renametype','Scrambled','deleteevents','off');       % scrambled_second_early
EEG = pop_selectevent( EEG, 'type',19,'renametype','Scrambled','deleteevents','off');       % scrambled_second_late

% Step 9: Correcting event latencies (events have a shift of 34 ms as per the authors)
EEG = pop_adjustevents(EEG,'addms',34);

% Step 10: Replacing original imported channels
% Note: This is a very unusual step that should not be done lightly. The reason here is because
%       of the original channels were wrongly labeled at the time of the experiment
EEG = pop_chanedit(EEG, 'rplurchanloc',1);

% Step 11: Creating folder to save data if does not exist yet
if ~exist(path2save, 'dir'), mkdir(path2save); end
EEG = pop_saveset( EEG,'filename',['wh_S01'  '_run_01' '.set'],'filepath',path2save);


%% PREPROCESSING

% Step 12: rereference data  Apply Common Average Reference
EEG = pop_reref(EEG,[],'interpchan',[], 'exclude', [61:64]);

% Step 13: Downsampling to 250 Hz
EEG = pop_resample(EEG, 250);

% Step 14: Filter the data Highpass at 1 Hz Lowpass at 90Hz (to avoid line noise at 100Hz)
EEG = pop_eegfiltnew(EEG, 1,   0);  % High pass at 1Hz
EEG = pop_eegfiltnew(EEG, 0,   90);
EEG = pop_eegfiltnew(EEG, 48,  52);  % Line noise suppression ~50Hz

% Step 15: Remove unwanted channels
EEG = pop_select(EEG, 'nochannel', [61:64]) ;

% Step 16: Apply clean_rawdata() to reject bad channels: No Artifact Subspace Reconstruction (ASR)
EEG = clean_artifacts(EEG, 'Highpass', 'off', 'ChannelCriterion', 0.8, 'ChannelCriterionMaxBadTime', 0.4, 'LineNoiseCriterion', 'off', 'BurstCriterion', 'off','WindowCriterion','off' );

% Step 17: Apply Common Average Reference
EEG = pop_reref(EEG,[],'interpchan',[]);

% Step 18: Repair bursts and reject bad portions of data
EEG = clean_artifacts( ALLEEG(al), 'Highpass', 'off', 'ChannelCriterion', 'off', 'LineNoiseCriterion', 'off', 'BurstCriterion', 20,'WindowCriterion',0.25);

% Step 19: Save dataset
EEG = pop_saveset( EEG,'filename',['wh_S01'  '_run_01' '_preproc.set'],'filepath',path2save);
% Step 20 run amica
EEG = pop_runamica(EEG,'numprocs',8, 'do_reject', 1, 'numrej', 10, 'rejint', 4,'rejsig', 3,'rejstart', 1, 'pcakeep',EEG.nbchan-1); % Computing ICA with AMICA

 EEG  = iclabel(MERGE);
 Brain_comps = find(EEG.etc.ic_classification.ICLabel.classifications(:,find(strcmp(EEG.etc.ic_classification.ICLabel.classes, 'Brain'))) > 0.6);
 %...& [EEG.dipfit.model.rv]' < 0.15);






%% ERP analysis

%Step 21 Extract event-locked trials using events listed in 'eventlist'
EEG_famous = pop_epoch( EEG, {'famous'}, [-1  2], 'newname', 'famous Epoched', 'epochinfo', 'yes');
EEG_unfamiliar = pop_epoch( EEG, {'unfamiliar'}, [-1  2], 'newname', 'unfamiliar Epoched', 'epochinfo', 'yes');
EEG_scrambled = pop_epoch( EEG, {'scrambled'}, [-1  2], 'newname', 'familiar Epoched', 'epochinfo', 'yes');

% Step 22: Perform baseline correction
EEG_famous = pop_rmbase(EEG_famous, [-1000 0]);
EEG_unfamiliar = pop_rmbase(EEG_unfamiliar, [-1000 0]);
EEG_scrambled = pop_rmbase(EEG_scrambled, [-1000 0]);

% Step 23: Clean data by rejecting epochs.
[EEG_famous, rejindx] = pop_eegthresh(EEG_famous, 1, 1:EEG_famous.nbchan, -400, 400, EEG_famous.xmin, EEG_famous.xmax, 0, 1);
[EEG_unfamiliar, rejindx] = pop_eegthresh(EEG_unfamiliar, 1, 1:EEG_unfamiliar.nbchan, -400, 400, EEG_unfamiliar.xmin, EEG_unfamiliar.xmax, 0, 1);
[EEG_scrambled, rejindx] = pop_eegthresh(EEG_scrambled, 1, 1:EEG_scrambled.nbchan, -400, 400, EEG_scrambled.xmin, EEG_scrambled.xmax, 0, 1);

% Step XX run amica
EEG = pop_runamica(EEG,'numprocs',8, 'do_reject', 1, 'numrej', 10, 'rejint', 4,'rejsig', 3,'rejstart', 1, 'pcakeep',EEG.nbchan-1); % Computing ICA with AMICA

% outdir = [path2save filesep 'wh_S01_run_01_amicaouttmp' filesep];
% num_chans = EEG.nbchan;
% num_models = 1;
% max_iter = 2000;
% do_reject = 1;
% numrej = 15;
% rejsig = 3;
% doPCA = 1;
% pcakeep = size(EEG.data,1)-1;
% 
% [w, s, mods] = runamica15(EEG.data(:,:),'outdir',outdir,...
%     'num_models', num_models,...
%     'max_iter', max_iter,...
%     'do_reject',do_reject,...
%     'numrej', numrej,...
%     'rejsig', rejsig,...
%     'pcakeep',pcakeep,...
%     'write_nd',1,...
%     'do_history',0,...
%     'histstep',2,...
%     'min_dll',0.000000001,...
%     'min_grad_norm',0.0000005);




