% Practical MEEG 2022
% Wakeman & Henson Data analysis: Extract EEG data and handle events.

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

% This script use the plug-in extension File-IO.

% Clearing all is recommended to avoid variable not being erased between calls 
clear;                                      
clear globals;

% Paths to data. Using relative paths so no need to update.
RootFolder = fileparts(pwd); % Getting root folder
path2data = fullfile(RootFolder,'Data', 'sub-01') % Path to  the original unzipped data files
path2save = path2data;                            % Path to save EEGLAB files
filename = 'sub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg.fif'; % Fif file original name

% Start EEGLAB
[ALLEEG, EEG, CURRENTSET] = eeglab; 

%% Step 1: Importing data with FileIO
EEG = pop_fileio(fullfile(path2data, filename));

% Adjust some fields
EEG.filename = 'sub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg.fif';
EEG.setname = 'sub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg';
EEG.subject = 'sub-01';

% Labels for EEG channels 
%In newer EEGLAB versions, labels with prefix "EEG" are not allowed, therefore using non capitalized option)
ListOfChannels =  {'eeg001' 'eeg002' 'eeg003' 'eeg004' 'eeg005' 'eeg006' 'eeg007' 'eeg008' 'eeg009' 'eeg010' 'eeg011' 'eeg012' 'eeg013' 'eeg014' 'eeg015'...
                   'eeg016' 'eeg017' 'eeg018' 'eeg019' 'eeg020' 'eeg021' 'eeg022' 'eeg023' 'eeg024' 'eeg025' 'eeg026' 'eeg027' 'eeg028' 'eeg029' 'eeg030'...
                   'eeg031' 'eeg032' 'eeg033' 'eeg034' 'eeg035' 'eeg036' 'eeg037' 'eeg038' 'eeg039' 'eeg040' 'eeg041' 'eeg042' 'eeg043' 'eeg044' 'eeg045'...
                   'eeg046' 'eeg047' 'eeg048' 'eeg049' 'eeg050' 'eeg051' 'eeg052' 'eeg053' 'eeg054' 'eeg055' 'eeg056' 'eeg057' 'eeg058' 'eeg059' 'eeg060'...
                   'eeg061' 'eeg062' 'eeg063' 'eeg064' 'eeg065' 'eeg066' 'eeg067' 'eeg068' 'eeg069' 'eeg070' 'eeg071' 'eeg072' 'eeg073' 'eeg074' 'STI101'};

%% Step 2: Selecting EEG data and event (STI101) channels
% EEG channels 1-60 are EEG, as are 65-70, but channels 61-64 are actually HEOG, VEOG and two floating channel (EKG).
EEG = pop_select(EEG, 'channel', [307:381]);
[EEG.chanlocs.labels] = ListOfChannels{:}; % Update labels to the ones in ListOfChannels

%% Step 3: Adding fiducials and rotating montage. Note:The channel location from this points were extracted from the sub-01_ses-meg_coordsystem.json
% files (see below) and written down here. The reason is that File-IO does not import these coordinates.
n = length(EEG.chanlocs)+1;
EEG=pop_chanedit(EEG, 'changefield',{n+0,'labels','LPA'},'changefield',{n+0,'X','-7.1'},'changefield',{n+0,'Y','0'},'changefield',{n+0,'Z','0'},...
                      'changefield',{n+1,'labels','RPA'},'changefield',{n+1,'X','7.756'},'changefield',{n+1,'Y','0'},'changefield',{n+1,'Z','0'},...
                      'changefield',{n+2,'labels','Nz'} ,'changefield',{n+2,'Y','10.636'},'changefield',{n+2,'X','0'},'changefield',{n+2,'Z','0'});
EEG = pop_chanedit(EEG,'nosedir','+Y');

% Changing Channel types and removing channel locations for channels 61-64 (Raw data types are incorrect)
EEG = pop_chanedit(EEG,'changefield',{61  'type' 'HEOG'  'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
EEG = pop_chanedit(EEG,'changefield',{62  'type' 'VEOG'  'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
EEG = pop_chanedit(EEG,'changefield',{63  'type' 'EKG'   'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});
EEG = pop_chanedit(EEG,'changefield',{64  'type' 'EKG'   'X'  []  'Y'  []  'Z'  []  'theta'  []  'radius'  []  'sph_theta'  []  'sph_phi'  []  'sph_radius'  []});

%% Step 4: Recomputing head center
 EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[])');

%% Step 5: Re-import events from STI101 channel (the original ones are incorect)
edgelenval = 1;
EEG = pop_chanevent(EEG, 75,'edge','leading','edgelen',edgelenval,'delevent','on','delchan','off','oper','double(bitand(int32(X),31))'); % first 5 bits

%% Step 6: Cleaning artefactual events (keep only valid event codes) (
% NOT BE NECCESARY FOR US
EEG = pop_selectevent( EEG, 'type',[5 6 7 13 14 15 17 18 19] ,'deleteevents','on');

%% Step 7: Importing  button press info
EEG = pop_chanevent(EEG, 75,'edge','leading','edgelen', edgelenval, 'delevent','off','oper','double(bitand(int32(X),8160))'); % bits 5 to 13
EEG.event(74).type = 256; % Overlapping of 256 and 4096

%% Step 8: Renaming button press events
EEG = pop_selectevent( EEG, 'type',256, 'renametype', 'left_nonsym','deleteevents','off');  % Event type : 'left_nonsym'
EEG = pop_selectevent( EEG, 'type',4096,'renametype', 'right_sym','deleteevents','off');    % Event type : 'right_sym'

%% Step 9: Rename face presentation events (information provided by authors)
EEG = pop_selectevent( EEG, 'type',5,'renametype','Famous','deleteevents','off');           % famous_new
EEG = pop_selectevent( EEG, 'type',6,'renametype','Famous','deleteevents','off');           % famous_second_early
EEG = pop_selectevent( EEG, 'type',7,'renametype','Famous','deleteevents','off');           % famous_second_late

EEG = pop_selectevent( EEG, 'type',13,'renametype','Unfamiliar','deleteevents','off');      % unfamiliar_new
EEG = pop_selectevent( EEG, 'type',14,'renametype','Unfamiliar','deleteevents','off');      % unfamiliar_second_early
EEG = pop_selectevent( EEG, 'type',15,'renametype','Unfamiliar','deleteevents','off');      % unfamiliar_second_late

EEG = pop_selectevent( EEG, 'type',17,'renametype','Scrambled','deleteevents','off');       % scrambled_new
EEG = pop_selectevent( EEG, 'type',18,'renametype','Scrambled','deleteevents','off');       % scrambled_second_early
EEG = pop_selectevent( EEG, 'type',19,'renametype','Scrambled','deleteevents','off');       % scrambled_second_late

%% Step 9: Correcting event latencies (events have a shift of 34 ms as per the authors)
EEG = pop_adjustevents(EEG,'addms',34);

%% Step 10: Replacing original imported channels
% Note: This is a very unusual step that should not be done lightly. The reason here is because
%       of the original channels were wrongly labeled at the time of the experiment
EEG = pop_chanedit(EEG, 'rplurchanloc',1);

%% Step 11: Creating folder to save data if does not exist yet
if ~exist(path2save, 'dir'), mkdir(path2save); end
EEG = pop_saveset( EEG,'filename','wh_S01_run_01.set','filepath', path2save);