% Practical MEEG 2022
% Wakeman & Henson Data analysis: Group Analysis
%
% Note on data: In this script, we use the OpenNeuro dataset ID: ds002718. 
% This dataset is the EEGLAB imported version of the Wakeman-Henson dataset ID: ds000117.
% Previous to being used in this demo the data was already preprocessed in the script
% PracticalMEEG_ERP_Analysis_GroupAnalysis_support.m

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

% Paths to data. Using relative paths so no need to update.
RootFolder = fileparts(pwd); % Getting root folder
path2data = fullfile(RootFolder,'Data', 'ds002718') % Path to precomputed files from ds002718

% Start EEGLAB
[ALLEEG, EEG, CURRENTSET] = eeglab; 


%% STUDY defs
studyname       = 'henson_study'; % name of the STUDY
studyfolderpath = path2data;      % Path to save the STUDY. Here the same as where the files are located

% Creating entry 'commands'
% Note: this is a programmatic way to generate the STUDY from the command
% line. Basically, we are telling EEGLAB to load the sets
% fullfile(path2data,datInfo(i).name, [datInfo(i).name '_proc.set']),
% assign to it a number (counter), a shortname (['subj00' num2str(i)] ), a group and
% session ( here the same for all subjects) as well as defining that only
% dipoles located inside the brain and with residual variance lower than
% 0.15 must be selected for further proccesing.

commands = {}; counter = 1;
for i = 2:19
    
    if i < 10
        subj = 'sub-00';
    else
        subj = 'sub-0';
    end
    
    filename = fullfile(path2data,[subj  num2str(i)], 'eeg', [subj num2str(i) '_task-FaceRecognition_eeg_proc.set']) ;
    
    commands{counter}   = {'index' counter...
                            'load' filename ...
                            'subject' [subj num2str(i)]...
                            'group' '1'...
                            'session' 1 ...
                            'inbrain' 'on'...
                            'dipselect' 0.15};
    counter = counter + 1;
end

%% Creating the STUDY
% Here we ctreate the STUDY, notice that here we pass the 'commands'
% previously generated.
[STUDY ALLEEG] = std_editset([], [], 'name','henson_study',...
                                             'task','ScrambledVsNormalFace',...
                                             'commands',commands,...
                                             'updatedat','off',...
                                             'savedat','on',...
                                             'rmclust','on' );
                                         
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG); % Checkking all is fine in the STUDY
CURRENTSTUDY   = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];

%% Saving the STUDY
[STUDY EEG] = pop_savestudy( STUDY, EEG, 'filename',[studyname '.study'],...
                                         'filepath',studyfolderpath);
                                     
%%                                     
% Generate design 1
% Here the statistical design is implemented. In this case, the three type
% of presentations for each typ of stimulus were concantenated, so we can
% deal with the marginalized version of the stimulus: Familiar(famous),
% unfamiliar and scrambled faces. 
STUDY       = std_makedesign(STUDY, ALLEEG, 1, 'name','STUDY.design 1',...
                                               'delfiles','off',...
                                               'defaultdesign','off',...
                                               'variable1','type',...
                                               'values1',{{'famous_new' 'famous_second_early' 'famous_second_late'}...
                                                          {'scrambled_new' 'scrambled_second_early' 'scrambled_second_late'}...
                                                          {'unfamiliar_new' 'unfamiliar_second_early' 'unfamiliar_second_late'}},...
                                               'vartype1','categorical');
                                            
[STUDY EEG] = pop_savestudy( STUDY, ALLEEG, 'savemode','resave'); % Saving the STUDY

%% Plot grand average at 170 ms
[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','erp','on');
STUDY = pop_erpparams(STUDY, 'plotconditions','together');
chanList = eeg_mergelocs(ALLEEG.chanlocs);
STUDY = std_erpplot(STUDY,ALLEEG,'channels', {chanList.labels}, 'design', 1);
STUDY = pop_erpparams(STUDY, 'topotime',170 );
STUDY = std_erpplot(STUDY,ALLEEG,'channels',{chanList.labels}, 'design', 1);

%% Generating measures for clusters
[STUDY ALLEEG]  = std_precomp(STUDY, ALLEEG, 'components','savetrials','on','recompute','on','erp','on','scalp','on','erpparams',{'rmbase' [-100 0]});
[STUDY ALLEEG]  = std_preclust(STUDY, ALLEEG, 1,{'erp' 'npca' 10 'weight' 1 'timewindow' [100 800]  'erpfilter' '25'},...
    {'scalp' 'npca' 10 'weight' 1 'abso' 1},...
    {'dipoles' 'weight' 10});

%% Clustering
nclusters = 15;
[STUDY]         = pop_clust(STUDY, ALLEEG, 'algorithm','kmeans','clus_num',  nclusters , 'outliers',  2.8 );
[STUDY EEG]     = pop_savestudy( STUDY, ALLEEG, 'savemode','resave');

%% Figures STUDY
% All clusters ERPs
STUDY = pop_erpparams(STUDY, 'filter',15,'timerange',[-100 400] );
STUDY = std_erpplot(STUDY,ALLEEG,'clusters',[2:nclusters+2], 'design', 1);

% All clusters topos
STUDY = std_topoplot(STUDY,ALLEEG,'clusters',[2:nclusters+2], 'design', 1);

% All clusters dipoles
STUDY = std_dipplot(STUDY,ALLEEG,'clusters',[2:nclusters+2], 'design', 1);

%% One cluster figure
ClusterOfInterest = 15;
STUDY = pop_erpparams(STUDY, 'plotconditions','together');
STUDY = std_erpplot(STUDY,ALLEEG,'clusters',ClusterOfInterest, 'design', 1);
STUDY = std_dipplot(STUDY,ALLEEG,'clusters',ClusterOfInterest, 'design', 1);
STUDY = std_topoplot(STUDY,ALLEEG,'clusters',ClusterOfInterest, 'design', 1, 'plotsubjects', 'on' );
