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
path2data = fullfile(RootFolder,'Data', 'sub-01') % Path to  the original unzipped data files
path2save = path2data;                            % Path to save EEGLAB files
filename = 'sub-01_ses-meg_task-facerecognition_run-01_proc-sss_meg.fif'; % Fif file original name