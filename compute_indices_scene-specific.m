%% Computing dissimilarity indices for Memokid
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Javier Ortiz-Tudela ortiztudela@psych.uni-frankfurt.com
% adjusted and modified by Iryna Schommartz
% LISCO Lab - Goethe Universitat
%%%%%%%%%%%%%%%%%%%%%%%%%%

% This script computes dissimilarity indices from already computed RDMs.
% I will start with recent vs remote and move on from there.
clear; close all
clc
format short g
% Main folder
if strcmpi(getenv('USER'),'x') 
    root_folder= '/.../x/.../...';
elseif strcmpi(getenv('USER'),'y') 
    root_folder = '/.../.../...';
end

% Add project name
main_folder = sprintf('%s/...', root_folder);

% Add toolbox to create nice figures
addpath(sprintf('%s/_common_software/notBoxPlot', root_folder));

% Get ROI labels from rsa_launcher.m
% All available ROIs

roi_labels={''};

% Let's create a handle to select only a subset of all the available rois
use_rois = 1;

%
% Plots info
subPlot_rows=numel(use_rois);
subPlot_cols=1;

% Subject list

use_subject = [];

ses_nbr = 2;
n_subs =  numel(use_subject);
%
% Loop through ROIs
%for
c_roi = use_rois
mask = roi_labels{c_roi};

% Get ROI label
mask_name = roi_labels{c_roi};
for c_sub = 1:n_subs
    % Get rdms file name
    % Get folder structure
    [dirs,sub_code]=memokid_getdir(main_folder, use_subject(c_sub));
    % Get rdms file name
    rdms_file = sprintf('%s/.../%s/ses-%02d/rdms/%s/rdms_by_runs.mat', main_folder, sub_code, ses_nbr, mask);
    
    % Load aggregated results
    'loading data...'
    load(rdms_file)
    %%
    % Loop through subjects
    d = 1;
    
    n_runs = size(rdm_out,3);

    % Load trial info. Right now I'm loading one subject as an example.
    % It will probably make sense to sort the RDMs already at the
    % aggregating stage (if no counterbalancing across subject is
    % done). If RDMs are sorted equally for all subject it would make
    % this script much simpler.
    if ses_nbr == 1
        info_file = sprintf('%s/%s_beta_info.mat', dirs.lss_s1, sub_code);
        load(info_file);
    elseif ses_nbr == 2
        info_file = sprintf('%s/%s_beta_info.mat', dirs.lss_s2, sub_code);
        load(info_file);
    end


    for c_run = 1:size(rdm_out,3) %(rdms_all,3)

        trial_info_file =  sprintf('%s/.../.../ses-%02d/%s/%s_ses-%d_run-%d_events.mat', main_folder, ses_nbr, sub_code, sub_code, ses_nbr, c_run);
        load(trial_info_file)
        % Rename trial info
        trial_info_run = Tablenew; clear Tablenew

        % We need to sort the event info to match the betas. We could sort 
        % the betas to match the  trial sequence, but since SPM's sorting 
        % already clusters by condition the betas (and hence the RDM), 
        % computing the indices later on is easier.
        % Sort and retain indices
        [~, ind] = sort(trial_info_run.memoryage);
        trial_info_run = trial_info_run(ind,:);

        sprintf('%s accuracy for run %d = %d', sub_code, c_run, mean(trial_info_run.accuracy))
        %% Get values
        % Will start with object recent vs object remote. These are betas
        % from 1-10 and 31-40

        % Get current subjects' data
        % rdm_sub = rdms_all(:,:,:,c_sub);
        rdm_sub = rdm_out;
        % Since the RDMs are not trial X trial (20x20) but rather they include
        % three events per trial (60x60), we need to expand these indices
        incorr_ind_rdm = ones(60,1);
        for c_incorr = 1:height(trial_info_run)
            if c_incorr < 11
                if trial_info_run.accuracy(c_incorr) == 0
                    incorr_ind_rdm(c_incorr) = 0;
                    incorr_ind_rdm(c_incorr+10) = 0;
                    incorr_ind_rdm(c_incorr+20) = 0;
                end
            elseif c_incorr > 10
                if trial_info_run.accuracy(c_incorr) == 0
                    incorr_ind_rdm(c_incorr+20) = 0;
                    incorr_ind_rdm(c_incorr+30) = 0;
                    incorr_ind_rdm(c_incorr+40) = 0;
                end
            end
        end
        %subplot(2,3,3+c_run), imagesc(incorr_ind_rdm)
        % for c_run=1:n_runs % END

        rdm_run = rdm_sub(:,:,c_run);
        rdm_run_clean(:,:,c_run)=rdm_run;
        rdm_run_clean(incorr_ind_rdm==0,:,c_run) = NaN;
        rdm_run_clean(:, incorr_ind_rdm==0,c_run) = NaN;

        trial_ind = [1:10];
        n_trials=length(trial_ind);

        %%
        for c_trial=1:n_trials

            this_trial=trial_ind(c_trial);
            % for recent 10 and 20, for remote 40 and 50  for fix and scene
            pred_per_trial(c_trial) = rdm_run_clean(10+this_trial, 20+this_trial,c_run);
            pred_per_set = rdm_run_clean(10+this_trial, 20:30,c_run);
            pred_per_set(this_trial) = [];
            pred_per_trial_set(c_trial) = nanmean(atanh(pred_per_set));
         
            itemset(c_trial) =pred_per_trial_set(c_trial)-atanh(pred_per_trial(c_trial));
           
        end
        av_pred_run(c_run) = nanmean(atanh(pred_per_trial)); % mean across trials in each run separately
        av_pred_run_set(c_run) = nanmean(pred_per_trial_set); % mean across trials in this run
        av_pred_run_itemset(c_run)=nanmean(itemset(c_trial));

    end
   % keyboard
    av_pred(c_sub)=nanmean(av_pred_run); % mean across runs
    av_pred_set(c_sub)=nanmean(av_pred_run_set); 
    av_pred_itemset(c_sub)=nanmean(av_pred_run_itemset);
    av_pred_itemset_subjectlevel(c_sub)=av_pred_set(c_sub)-av_pred(c_sub);

   
end

%
mkdir('...')
output_name = sprintf('%s/.../%s_ses-%02d_fixscene_rec_item.mat', main_folder, mask, ses_nbr);
save(output_name, 'av_pred')

output_name1 = sprintf('%s/.../%s_ses-%02d_fixscene_rec_set.mat', main_folder, mask, ses_nbr);
save(output_name1, 'av_pred_set');

output_name2 = sprintf('%s/.../%s_ses-%02d_fixscene_rec_setitem.mat', main_folder, mask, ses_nbr);
save(output_name2, 'av_pred_itemset');




