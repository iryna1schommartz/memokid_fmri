%% Convert the output from LSS from hdr/img to nii
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Javier Ortiz-Tudela ortiztudela@psych.uni-frankfurt.com
% Iryna Schommartz
% LISCO Lab - Goethe Universitat
%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Handle paths
% This is going to be useful when running from different computers or
% users.

% Main folder
if strcmpi(getenv('USER'),'x') % 
    root_folder= '/.../x/.../...';
elseif strcmpi(getenv('USER'),'y') % 
    root_folder = '/.../.../...';
end
main_folder = sprintf('%s/MemoKid', root_folder);

% set FSL environment
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be

% Which participants?

    use_subject=[];
%% Loop through subjects
for c_sub=use_subject

    % Get folder structure
    [dirs,sub_code]=memokid_getdir_stick(main_folder, c_sub);

    % State
    fprintf('Starting subject: %s\n', num2str(c_sub));

    % Get filenames
    filelist = dir([dirs.rsa_s1, 'lss/betas/*nii.gz']);

    % Loop through files
    for c_file = 1:length(filelist)
            
        % Gunzip
        gunzip([filelist(c_file).folder, '/', filelist(c_file).name])

        % Print status to the terminal
        sprintf('File %d out of %d completed', c_file, length(filelist  ))
    end
end