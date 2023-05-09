function rsa_aggregate_manual(main_folder, which_subs, ses_nbr, mask)
%% Aggregate RDMs across participants
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Javier Ortiz-Tudela ortiztudela@psych.uni-frankfurt.com
% modified by Iryna Schommartz
% LISCO Lab - Goethe Universitat
%%%%%%%%%%%%%%%%%%%%%%%%%%

% This script aggregates per run and per subject RDMs

if ses_nbr == 1
    ses_list = [];
elseif ses_nbr == 2
    ses_list = [];
end

%% Loop through participants
% Create a counter to store participants along the third dimension
c = 1;
for c_sub = which_subs
    
    % Get folder structure
    [dirs,sub_code]=memokid_getdir(main_folder, c_sub);
    
    % Check if current subject has current session
    if ismember(c_sub, ses_list)
        missing = 0;
    else
        missing = 1;
    end
    
    % Concatenate subject or pad with NANs
    if missing == 0
        % What is the name of the folder with the results of the RSA?
        if ses_nbr == 1
            rdms_folder = dirs.rsa_s1;
        elseif ses_nbr == 2
            rdms_folder = dirs.rsa_s2;
        end
        
        % What is the name of the file with the RDMs?
        rdm_file = sprintf('%s/rdms/%s/rdms_by_runs.mat', rdms_folder, mask);
        
        % Load results
        load(rdm_file)
        
        % Loop through runs
        for c_run = 1:size(rdm_out,3)
            
            % Get distance
            out(:,:,c_run) = rdm_out(:,:,c_run);
            
        end
        
    elseif missing == 1
        out = nan(60,60,3);
    end
    
    % Store in a trialsXtrialsXrunsXsubjects matrix
    rdms_all(:,:,:,c) = out;
    c = c + 1;
    
end

%% Save output
output_name = sprintf('%s/.../.../%s_ses-%02d_rdms_by_run.mat', main_folder, mask, ses_nbr);
save(output_name, 'rdms_all')
