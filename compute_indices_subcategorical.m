%% Computing categorical dissimilarity indices for Memokid
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Javier Ortiz-Tudela ortiztudela@psych.uni-frankfurt.com
% adjusted and modified by Iryna Schommartz
% LISCO Lab - Goethe Universitat
%%%%%%%%%%%%%%%%%%%%%%%%%%

% This script computes categorical dissimilarity indices from already
% computed RDMs.
clear; close all

%% Handle paths
% This is going to be useful when running from different computers or
% users.

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

% Add custom functions
addpath(sprintf('%s/.../.../_functions', main_folder));


%% Get ROI labels from rsa_launcher.m
% All available ROIs

roi_labels={''};

%% Participants ids
% Subject list
use_subject = [];

%% Specify what to run
% Let's create a handle to select only a subset of all the available rois
use_rois = 1;
nROIs=numel(use_rois);

% Another handle for selecting a subset of subjects
n_subs = numel(use_subject);

%% Session id
% in the future will probably loop through sessions but right now I don't
% see it clearly. Will keep it as it is for now
ses_nbr = 2;

%% Loop through ROIs
for c_roi = 1:use_rois

    % Get ROI label
    mask_name = roi_labels{c_roi};

    % Loop through subjects
    d = 1;
    for c_sub = 1:n_subs

        % Get folder structure
        [dirs,sub_code]=memokid_getdir(main_folder, use_subject(c_sub));

        % Get rdms file name
        rdms_file = sprintf('%s/rsa/%s/ses-%02d/rdms/%s/rdms_by_runs.mat', main_folder, sub_code, ses_nbr, mask_name);

        % Load RDM
        'loading data...'
        load(rdms_file)

        % Load beta info. Right now I'm loading one subject as an example.
        % It will probably make sense to sort the RDMs already at the
        % aggregating stage (if no counterbalancing across subject is
        % done). If RDMs are sorted equally for all subject it would make
        % this script much simpler.
        if ses_nbr==1
        beta_info_file = sprintf('%s/%s_beta_info.mat', dirs.lss_s1, sub_code);
        else
         beta_info_file = sprintf('%s/%s_beta_info.mat', dirs.lss_s2, sub_code);
        end
        load(beta_info_file);

        % Rename trial info from the betas to avoid confusion
        beta_info = cell2table(trialinfo(2:end,:), "VariableNames", trialinfo(1,:)); clear trialinfo

        %% Loop through runs
        for c_run = 1:size(rdm_out,3)

            % Get current run beta info
            beta_info_run = beta_info(beta_info.run_number==c_run,:);

            % Get current run RDM
            rdm_run = rdm_out(:,:,c_run);

            if  ~ isnan(nanmean(nanmean(rdm_run)))
                %nanmean(nanmean(rdm_run)) ~= NaN

           
            % Load trial info
          trial_info_file =  sprintf('%s/.../.../ses-%02d/%s/%s_ses-%d_run-%d_events.mat', main_folder, ses_nbr, sub_code, sub_code, ses_nbr, c_run);
            load(trial_info_file)

            % Rename trial info
            trial_info_run = Tablenew; clear Tablenew

            % We need to sort the event info to match the betas. Sort and retain indices
            [~, ind] = sort(trial_info_run.memoryage);
            trial_info_run = trial_info_run(ind,:);

            %% Select relevant cells
            % Create a selector 20x20 matrix of cells with:
            % - 3s  where the categories are equal and recent,
            % - 2s where the categories are equal and remote,
            % - 1s where the categories are NOT equal and recent,
            % - and 0s, where the categories are NOT equal and remote.
            selector = zeros(20,20);
            for i = 1:length(trial_info_run.subtopic)
                for j = 1:length(trial_info_run.subtopic)
                    if trial_info_run.subtopic(i) == trial_info_run.subtopic(j)
                        selector(i,j) = 2;
                    end
                end
            end
            selector(1:10,:)=selector(1:10,:)+1;

            % Remove incorrect trials. Error code = 9999
            for i =  1:length(trial_info_run.subtopic)
                if trial_info_run.accuracy(i) == 0
                    selector(i,:) = 9999;
                    selector(:,i) = 9999;
                end
            end

            % Turn diagonal into NaN
            selector(eye(size(selector,1)) == 1) = NaN;

            %% Categorical info at the scene stage
            % First, I will check whether, at the scene stage, it is
            % posssible to cluster scene categories when they are actually
            % seing the scenes.
            % Get the indices for the fixation window

            
            fix_ind = startsWith(beta_info_run.betaname, 'fix');

            % Slice the RDM
            rdm = rdm_run(fix_ind,fix_ind);

            % Compute averages across categories. I will store it into a
            % structure with all scene_stage values
            fix.subcat.run(c_run,1) = mean(atanh(mean(rdm(selector==3))));
            fix.subcat.run(c_run,2) = mean(atanh(mean(rdm(selector==1))));
            fix.subcat.run(c_run,3) = mean(atanh(mean(rdm(selector==2))));
            fix.subcat.run(c_run,4) = mean(atanh(mean(rdm(selector==0))));

            end
        end

        %% Compute an index for pre-activation 
        % This is computed as between - within. Non-zero values reflect
        % pre-activation as distance would be higher for pairs of trials
        % with different categories than the same category. I will compute
        % it in every run and then average.

        fix.subcat.within_rec(c_sub) = mean(fix.subcat.run(:,1));
        fix.subcat.between_rec(c_sub) = mean(fix.subcat.run(:,2));
        fix.subcat.within_rem(c_sub) = mean(fix.subcat.run(:,3));
        fix.subcat.between_rem(c_sub) = mean(fix.subcat.run(:,4));
        fix.subcat.preact_rec(c_sub) = mean(fix.subcat.run(:,2) - fix.subcat.run(:,1));
        fix.subcat.preact_rem(c_sub) = mean(fix.subcat.run(:,4) - fix.subcat.run(:,3));


    end

%%

fixsubcatwithin_rec=fix.subcat.within_rec;
fixsubcatbetween_rec=fix.subcat.between_rec;
fixsubcatwithin_rem=fix.subcat.within_rem;
fixsubcatbetween_rem=fix.subcat.between_rem;
fixsubcatpreact_rec=fix.subcat.preact_rec;
fixsubcatpreact_rem=fix.subcat.preact_rem;

%
subNo=use_subject';
if ses_nbr==1
session=ones(length(subNo),1);
else
  session=2.*ones(length(subNo),1);  
end
category_rem=ones(length(subNo),1);
category_rec=zeros(length(subNo),1);
ROI=c_roi.*ones(length(subNo),1);
group=5.*ones(length(subNo),1); % 1 kids, 5 adults


fixsubcatwithin_rec=real(fixsubcatwithin_rec');
fixsubcatbetween_rec=real(fixsubcatbetween_rec');
fixsubcatwithin_rem=real(fixsubcatwithin_rem');
fixsubcatbetween_rem=real(fixsubcatbetween_rem');
fixsubcatpreact_rec=real(fixsubcatpreact_rec');
fixsubcatpreact_rem=real(fixsubcatpreact_rem');


%
Tablesummary_rec=table(subNo,session,group,category_rec,ROI,...
   fixsubcatwithin_rec,fixsubcatbetween_rec,fixsubcatpreact_rec);
Tablesummary_rec=renamevars(Tablesummary_rec, ["category_rec",...
    "fixsubcatwithin_rec","fixsubcatbetween_rec","fixsubcatpreact_rec"],...
    ["category","fixsubcatwithin","fixsubcatbetween","fixsubcatpreact"]);

Tablesummary_rem=table(subNo,session,group,category_rem,ROI,...
   fixsubcatwithin_rem,fixsubcatbetween_rem,fixsubcatpreact_rem);
Tablesummary_rem=renamevars(Tablesummary_rem, ["category_rem",...
    "fixsubcatwithin_rem","fixsubcatbetween_rem","fixsubcatpreact_rem"],...
    ["category","fixsubcatwithin","fixsubcatbetween","fixsubcatpreact"]);
% combine tables
%
Tablesummary=[Tablesummary_rec;Tablesummary_rem];
%

mkdir('...')
output_name = sprintf('%s/.../.../.../.../%s_ses-%02d.mat', main_folder, mask_name, ses_nbr);
save(output_name, 'Tablesummary')
end