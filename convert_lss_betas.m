%% Convert the output from LSS from hdr/img to nii
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Javier Ortiz-Tudela ortiztudela@psych.uni-frankfurt.de
% Modified by Iryna Schommartz schommartz@psych.uni-frankfurt.de
% LISCO Lab - Goethe Universitat
%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Handle paths
% This is going to be useful when running from different computers or
% users.

% Main folder
if strcmpi(getenv('USER'),'x') % Javier's office
    root_folder= '/.../x/.../...';
elseif strcmpi(getenv('USER'),'y') % Javier's session in Pepe
    root_folder = '/.../.../...';
end
main_folder = sprintf('%s/...', root_folder);

% set FSL environment
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be

% Which participants?

use_subject=[];
%%
%% Loop through subjects
for c_sub=use_subject

    % Get folder structure
    [dirs,sub_code]=memokid_getdir(main_folder, c_sub);

    % State
    fprintf('Starting subject: %s\n', num2str(c_sub));

    % Get filenames
    filelist = dir([dirs.rsa_s2, 'lss/betas/*hdr']);

    % Loop through files
    for c_file = 1:length(filelist)
        % Convert
        cmd = sprintf('/usr/local/fsl/bin/fslchfiletype NIFTI %s/%s', ...
            filelist(c_file).folder, filelist(c_file).name);
        system(cmd);

        % Print status to the terminal
        sprintf('File %d out of %d completed', c_file, length(filelist  ))
    end
end