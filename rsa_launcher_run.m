%% RSA analyses with TDT
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Javier Ortiz-Tudela ortiztudela@psych.uni-frankfurt.com
% modified by Iryna Schommartz
% LISCO Lab - Goethe Universitat
%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Handle paths
% This is going to be useful when running from different computers or
% users.

% Main folder
if strcmpi(getenv('USER'),'x') 
    root_folder= '/.../x/.../...';
elseif strcmpi(getenv('USER'),'y') 
    root_folder = '/.../y/.../...';
end
main_folder = sprintf('%s/...', root_folder);

% All available ROIs
roi_labels={'...'};

% Which rois?
use_rois=[1];

% Add necesary folders
addpath([root_folder, '/_common_software/decoding_toolbox_v3.997'])
addpath([root_folder, '/_common_software/spm12'])

%% Specify what to run
% Which participants?

sub_list = [];
  
%% Loop through subjects
for c_sub=sub_list
    
    % Get folder structure
    [dirs,sub_code]=memokid_getdir(main_folder, c_sub);
    
    % State
    fprintf('Starting subject: %s\n', num2str(c_sub));
    
    for c_ses=2
        
        for c_roi = use_rois
            
            % Get ROI label
            mask_name = roi_labels{c_roi};
            
            % Run RSA
            rdm_by_run = rsa_manual(dirs, sub_code, c_ses, mask_name);
            
        end
    end
end

%% Aggregate across subjects
% Subject list
sub_list = [];
   
% Loop through sessions
for c_ses = 2
    
    % Loop through rois
    for c_roi = use_rois
        
        % Get ROI label
        mask_name = roi_labels{c_roi};
        
        sprintf(['*****************************************\n',...
            'Aggregating %s...'],mask_name)
        
        % Aggregate
        rsa_aggregate_manual(main_folder, sub_list, c_ses, mask_name)
    end
end
