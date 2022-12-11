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

% Comment one of the two lines below to process EEG or MEG data
%chantype = { 'megmag' }; % process MEG megmag channels
%chantype = { 'megplanar' }; % process MEG megplanar channels
chantype = { 'eeg' }; % process EEG

% Paths below must be updated to the files on your enviroment.
RootFolder = fileparts(pwd); % Getting root folder
path2data = fullfile(RootFolder,'Data', 'sub-01'); % Path to data 
filename = 'sub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg.fif';

[ALLEEG, EEG, CURRENTSET] = eeglab; % start EEGLAB

%% IMPORTING THE DATA

% Step 1: Importing data with FileIO
EEG = pop_fileio(fullfile(path2data, filename));

% Adjust some fields
EEG.filename = 'sub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg.fif';
EEG.setname = 'sub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg';
EEG.subject = 'sub-01';

% Step 2: Adding fiducials and rotating montage. Note:The channel location from this points were extracted from the sub-01_ses-meg_coordsystem.json
% files (see below) and written down here. The reason is that File-IO does not import these coordinates.
n = length(EEG.chanlocs)+1;
EEG=pop_chanedit(EEG, 'changefield',{n+0,'labels','LPA'},'changefield',{n+0,'X','-7.1'},  'changefield',{n+0,'Y','0'},'changefield',{n+0,'Z','0'},...
                      'changefield',{n+1,'labels','RPA'},'changefield',{n+1,'X','7.756'}, 'changefield',{n+1,'Y','0'},'changefield',{n+1,'Z','0'},...
                      'changefield',{n+2,'labels','Nz'} ,'changefield',{n+2,'Y','10.636'},'changefield',{n+2,'X','0'},'changefield',{n+2,'Z','0'});
EEG = pop_chanedit(EEG,'nosedir','+Y');
EEG = eeg_checkset(EEG);

% Changing Channel types and removing channel locations for channels 61-64 (Raw data types are incorrect)
EEG = pop_chanedit(EEG,'changefield',{367  'type' 'HEOG'  'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
EEG = pop_chanedit(EEG,'changefield',{368  'type' 'VEOG'  'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
EEG = pop_chanedit(EEG,'changefield',{369  'type' 'EKG'   'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
EEG = pop_chanedit(EEG,'changefield',{370  'type' 'EKG'   'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});

% Step 3: Re-import events from STI101 channel (the original ones are incorect)
edgelenval = 1;
EEG = pop_chanevent(EEG, 381,'edge','leading','edgelen',edgelenval,'delevent','on','delchan','off','oper','double(bitand(int32(X),31))'); % first 5 bits

% Step 4: Selecting EEG or MEG data 
EEG = pop_select(EEG, 'chantype', chantype);

% Step 5: Recomputing head center (for display only) Optional
EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[])');
figure; topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);

% Step 6: Cleaning artefactual events (keep only valid event codes) (
% NOT BE NECCESARY FOR US
EEG = pop_selectevent( EEG, 'type',[5 6 7 13 14 15 17 18 19] ,'deleteevents','on');

% Step 7: Fix button press info
EEG.event(74).type = 256; % Artifact; Overlapping of 256 and 4096

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

% Step 10: Correcting event latencies (events have a shift of 34 ms as per the authors)
EEG = pop_adjustevents(EEG,'addms',34);

% Step 11: Creating folder to save data if does not exist yet
EEG = pop_saveset( EEG,'filename',['wh_S01'  '_run_01' '.set'],'filepath',path2data);
eeg_eventtypes(EEG)
