function [dirs, sub_code] = memokid_getdir(main_folder, which_sub)
%% Get folder structure for this participant
% This script merely creates a handle for project paths. This is specially
% useful for subject specific hierarchical paths (as in BIDS-compatible
% structures). The handle is a structure with the format: 
% written by Javier Ortiz
%  modified by Iryna Schommartz
% dirs.<folder_label>
%
% where <folder_label> is a short label given to a given folder (which can
% have longer name. Labels are defined relative to the root folder of the
% project. You can think about this structure as a shortcut or pointer to 
% specific (more involved) locations. 
%
% At the end of the script, the folders specified here but which do not
% exist previously, will be created.
%
% As an extra output, this script also generates a (BIDS compatible) 
% subject code that can be re-used outside this script.

%% Folder labels and true folder names
% d.BIDS = '/BIDS/';
dirs.rsa = '/../';
dirs.masks = '/Masks/';
% d.beh = '/task_outputs/';
% d.brain = '/preproc_data_hlr/fmriprep/';
% d.mask = '/masks/';

%% Build subject code
sub_code = sprintf('sub-%02d', which_sub);

%% Create subject-specific folders names
% d.BIDS=[main_folder,d.BIDS, sub_code,'/'];
dirs.rsa_s1 = [main_folder, dirs.rsa, sub_code, '/ses-01/'];
dirs.rsa_s2 = [main_folder, dirs.rsa, sub_code, '/ses-02/'];
dirs.masks = [main_folder,dirs.masks, sub_code, '/'];
dirs.lss_s1 = [dirs.rsa_s1, '/lss/betas/'];
dirs.lss_s2 = [dirs.rsa_s2, '/lss/betas/'];

% d.beh=[main_folder,d.beh, sub_code,'/'];
% d.brain=[main_folder,d.brain, sub_code,'/'];
%% Create folders if they don't already exist
if ~exist(dirs.rsa_s1);mkdir(dirs.rsa_s1);end
if ~exist(dirs.rsa_s2);mkdir(dirs.rsa_s2);end
% if ~exist(d.beh);mkdir(d.beh);end
% if ~exist(d.brain);mkdir(d.brain);end
% if ~exist(d.mask);mkdir(d.mask);end
% if ~exist(d.retMap);mkdir(d.retMap);end
% if ~exist(d.spm);mkdir(d.spm);end



end
