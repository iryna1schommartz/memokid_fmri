function rdm_out = rsa_manual(dirs, sub_code, ses_nbr, mask)
% Homebrewed script to compute dissimilarity matrices.
% This script is intended for the Memokid project.
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Javier Ortiz-Tudela ortiztudela@psych.uni-frankfurt.com
% modified by Iryna Schommartz
% LISCO Lab - Goethe Universitat
%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = decoding_defaults;

%% Define parameters of the analysis
% Set the output directory where data will be saved
if ses_nbr == 1
    cfg.results.dir = [dirs.rsa_s1, 'rdms/', mask];
elseif ses_nbr == 2
    cfg.results.dir = [dirs.rsa_s2, 'rdms/', mask];
end

% Set the filepath where your SPM.mat and all related betas are
if ses_nbr == 1
    beta_loc = [dirs.rsa_s1 'betas/'];
elseif ses_nbr == 2
    beta_loc = [dirs.rsa_s2 'betas/'];
end

% RSA folder. Not sure what this is for. LSS betas' names are
% "RUN<run_nbr>_<condition_label>_<repetition_number>
if ses_nbr == 1
    rsa_folder = dirs.rsa_s1;
elseif ses_nbr == 2
    rsa_folder = dirs.rsa_s2;
end

% Set the dissimilarity metric
method = 'pearson'; % this is Pearson correlation

%% Where?
% Set the filename of your brain mask (or your ROI masks as cell matrix)
mask_name=fullfile([dirs.masks, 'ses-0', num2str(ses_nbr), '/',sub_code, '_space-native_roi-', mask, '_mask.nii.gz']);

% Unzip it
if ~exist(mask_name(1:end-3))
    ['gunzipping ', mask_name]
    gunzip(mask_name)
end
cfg.files.mask = mask_name(1:end-3);
%% What?
% Set the label names to the regressor names which you want to use for
% decoding. Don't remember the names? -> run display_regressor_names(beta_loc)
labelnames = {'objrec'; 'fix1rec'; 'scenerec'; 'objrem'; 'fix1rem'; 'scenerem'};

%% Nothing needs to be changed below for standard dissimilarity estimates using all data

cfg=update_cfg_lss_escop(sub_code, cfg, labelnames, rsa_folder);

% Extract beta values for the selected mask
data = get_data_from_tdt(cfg, []);

% I need to split the data by runs here but in the future this is better to
% have in the previous script
n_runs = length(unique(cfg.files.chunk));
for c_run = 1:n_runs
    data_by_run{c_run} = data(cfg.files.chunk == c_run,:);
end

%% Compute dissimilarities

for c_run = 1:n_runs
    missing = 0;
    
    % Omit misssing runs for some subjects
    if c_run == 2
        if ses_nbr == 1
            
            if strcmpi(sub_code, '...' ) ||  strcmpi(sub_code, '...')
                missing = 1;
            end
        elseif ses_nbr == 2
            
            if strcmpi(sub_code, '...' ) ||  strcmpi(sub_code, '...') ||  strcmpi(sub_code, '...')
                missing = 1;
            end
        end
    end
    
    % Compute RDM
    if missing == 0
        for i = 1:60
            for j = 1:60
                RDM(i,j, c_run) = 1 - corr2(data_by_run{c_run}(i,:),...
                    data_by_run{c_run}(j,:));
            end
        end
    elseif missing == 1
        
        RDM(:,:, c_run) = nan(60);
    end
    
    
end

%% Prepare output and write to disk
rdm_out = RDM;
out_filename = [cfg.results.dir, '/rdms_by_runs.mat'];
save(out_filename, 'rdm_out');

