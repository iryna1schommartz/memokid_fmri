%% Wrapper script for GLM
%  Written by Iryna Schommartz (1.03.2022)
% Add SPM to MATLAB's path
addpath('/.../.../.../_common_software/spm12/')

% Project info
project_folder = '/.../.../.../.../';
sub_list = [];
sess_list = [];
run_list(1,:) = [];
run_list(2,:) = [];

% Get n of subs
n_subs = length(sub_list);

for c_sub = 1:n_subs
    
    % Select one subject
    which_sub = sub_list(c_sub);
    
    % Select nbr of session
    nbr_sess = sess_list;
    
    % Loop through sessions
    for c_sess = 1:nbr_sess
        
        % Select nbr of session
        nbr_runs = run_list;
        %c_sess, c_sub)
        % Loop through runs
        for c_runs = 1:nbr_runs
            
            glm_rsa(project_folder, which_sub, c_sess, c_runs)
            
        end
    end
end