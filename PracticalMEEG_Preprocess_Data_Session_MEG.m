% import data
eeglab;
EEG = pop_fileio('/Users/arno/Downloads/derivatives_meg_derivatives_sub-01_ses-meg_meg_sub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg.fif', 'dataformat','auto');

% remove non-MEG channels and reorient them
EEG = pop_select( EEG, 'nochannel',{'EEG001','EEG002','EEG003','EEG004','EEG005','EEG006','EEG007','EEG008','EEG009','EEG010','EEG011','EEG012','EEG013','EEG014','EEG015','EEG016','EEG017','EEG018','EEG019','EEG020','EEG021','EEG022','EEG023','EEG024','EEG025','EEG026','EEG027','EEG028','EEG029','EEG030','EEG031','EEG032','EEG033','EEG034','EEG035','EEG036','EEG037','EEG038','EEG039','EEG040','EEG041','EEG042','EEG043','EEG044','EEG045','EEG046','EEG047','EEG048','EEG049','EEG050','EEG051','EEG052','EEG053','EEG054','EEG055','EEG056','EEG057','EEG058','EEG059','EEG060','EEG061','EEG062','EEG063','EEG064','EEG065','EEG066','EEG067','EEG068','EEG069','EEG070','EEG071','EEG072','EEG073','EEG074','STI101','STI201','STI301','MISC201','MISC202','MISC203','MISC204','MISC205','MISC206','MISC301','MISC302','MISC303','MISC304','MISC305','MISC306','CHPI001','CHPI002','CHPI003','CHPI004','CHPI005','CHPI006','CHPI007','CHPI008','CHPI009'});
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
figure; topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);

% resample data
EEG = pop_resample( EEG, 125);

% clean data 
EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.6,'LineNoiseCriterion',5,'Highpass',[0.25 0.75] ,'BurstCriterion',40,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );

% define fiducials
% LPA = [-71, 0, 0]/10;
% RPA = [77.56,0,0]/10;
% Nz = [0, 106.36, 0]/10;
n = length(EEG.chanlocs)+1;
EEG=pop_chanedit(EEG, 'changefield',{n+0,'labels','LPA'},'changefield',{n+0,'X','-7.1'},'changefield',{n+0,'Y','0'},'changefield',{n+0,'Z','0'},...
                      'changefield',{n+1,'labels','RPA'},'changefield',{n+1,'X','7.756'},'changefield',{n+1,'Y','0'},'changefield',{n+1,'Z','0'},...
                      'changefield',{n+2,'labels','Nz'} ,'changefield',{n+2,'Y','10.636'},'changefield',{n+2,'X','0'},'changefield',{n+2,'Z','0'});
EEG = pop_chanedit(EEG,'nosedir','+Y');
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw

% Run ICA
EEG = pop_runica(EEG, 'icatype', 'picard', 'maxiter',500,'pca',20);

% DIPFIT settings
dipfitpath       = fileparts(which('pop_multifit'));
electemplatepath = fullfile(dipfitpath,'standard_BEM/elec/standard_1005.elc');
[~,coord_transform] = coregister(EEG.chaninfo.nodatchans, electemplatepath, 'warp', 'auto', 'manual', 'off');

% Not necessarily a good model for MEG (3 shells not necessary)
EEG = pop_dipfit_settings( EEG, 'hdmfile','/System/Volumes/Data/data/matlab/eeglab/plugins/dipfit/standard_BEM/standard_seg_mri_meg.mat',...
    'coordformat','MNI','mrifile','/System/Volumes/Data/data/matlab/eeglab/plugins/dipfit/standard_BEM/standard_mri.mat',...
    'chanfile','/System/Volumes/Data/data/matlab/eeglab/plugins/dipfit/standard_BEM/elec/standard_1005.elc','chansel',1:EEG.nbchan );

% localize components
EEG = pop_multifit(EEG, [1:20] ,'threshold',100,'dipplot','on','plotopt',{'normlen','on'});

% plot component 12
figure; pop_topoplot(EEG, 0, 12,' resampled',[1 1] ,1,'electrodes','off');

