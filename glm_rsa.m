% univariate_02_glm(project_folder, which_sub, task_name, compress,varargin)
% This function reads in the condition files in SPM format (see
% univariate_00_create_condFile.m), confund files in .txt format (see
% univariate_01_create_confounds_files.m), applies spatial smoothing,
% creates a model with task and nuisance regressors, saves it in a SPM.mat,
% and computes the GLM. In SPM's terms: it specifies the model and estimates it.

%
% Please be aware that this script uses a GM binary mask to only compute 
% the GLM on GM voxels. If you do not want that, you can set to blank the
% content of line 112 (matlabbatch{1}.spm.stats.fmri_spec.mask).%
%
% The script will assume that all your files follow BIDS convention. To
% include changes in the way paths are hanldled, see getdirs.m.
%
% Usage:
%    - project_folder: path to root folder of the project
%    - which_sub: subject id
%    - task_name: task label for which condition files will get generated.
%    NOTE that this label *must* be identical to the one used for naming
%    the files.
%    - compress: should it compress .nii filde at the end? 1 = yes, 0 = no.
%    - varargin: optional arguments.
%           - string: If provided, the first argument will be used as session label
%           to navigate BIDS folders.
%           - cell array: If provided, the second argument will be used to select
%           specific conditions from the event files.
%
% This script has been created at the Goethe University.
%
% Author: Ortiz-Tudela (Goethe University)
% Created: 09.01.2021
% Last update: 12.01.2021
% Modified: Iryna Schommartz (1.03.2022)
function glm_rsa(project_folder, which_sub, ses_nbr, n_runs)
project_folder='/.../.../.../.../';
which_sub=[];
ses_nbr=[];
n_runs=[];
% Echo

addpath('/.../.../.../_common_software/spm12/')

sub_code = sprintf('sub-%d', which_sub);
fprintf('Starting participant %d',sub_code)
%%
% Create output folder to keep things nice and clean
out_folder=[project_folder, 'rsa/', sub_code, '/ses-0', num2str(ses_nbr), '/betas/'];
if ~exist(out_folder);mkdir(out_folder);end

% Get filenames
'Looking for functional files'

func_folder = [project_folder, '.../fmriprep/', sub_code, '/' 'ses-0',num2str(ses_nbr), '/' 'func' '/'];


temp=dir([func_folder '/', '*task-memokid*space-T1w_desc-preproc_bold.nii.gz']);
for c_file=1:length(temp)
    func_files{c_file}=[func_folder '/',temp(c_file).name];
end

% Events info folder
%func_files_cell=struct2cell(func_files);
events_folder = [project_folder, '.../ses-0', num2str(ses_nbr), '/', 'sub_', num2str(which_sub), '/'];

%% Fun beggins
matlabbatch{1}.spm.stats.fmri_spec.dir = {out_folder}; % Output folder
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.8; % TR
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 72; % n slices
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 36; % reference slice for slicetime correction

%for c_run=1:n_runs
% Loop through runs

for c_run=1:n_runs
    
    % First, unzip the .nii.gz files
    gunzipped_file = func_files{c_run};
    gunzip(gunzipped_file);
    unzipped_file = func_files{c_run}(1:end-3);
    
  
    % These are all the fields that SPM needs for a given run. Nothing
    % needs to be changed here.
    filter = ['^', sub_code,  '.*memokid.*_run-', num2str(c_run), '.*_bold.nii$'] ;
    matlabbatch{1}.spm.stats.fmri_spec.sess(c_run).scans = cellstr(spm_select('FPList',func_folder,filter));
    matlabbatch{1}.spm.stats.fmri_spec.sess(c_run).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(c_run).multi = {[events_folder,  sub_code, '_run-', num2str(c_run), '_events.mat']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(c_run).regress = struct('name', {}, 'val', {});
%    matlabbatch{1}.spm.stats.fmri_spec.sess(c_run).multi_reg = {''}; % If no confound, {['']}
     matlabbatch{1}.spm.stats.fmri_spec.sess(c_run).multi_reg = {[events_folder,  sub_code, '_run-', num2str(c_run), '_confounds.txt']}; % If no confound, {['']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(c_run).hpf = 128;
   

  
end

%%  Model specification
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''}; % If no GM mask, {['']};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

% Model estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% And run!
spm_jobman('run', matlabbatch);
clear matlabbatch;

end