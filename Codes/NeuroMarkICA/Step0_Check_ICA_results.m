%% check ICA process
clear
clc

ICA_fold = '/data/qneuromark/Results/ICA/UKBiobank';

load /data/qneuromark/Results/Subject_selection/UKBiobank/UKB_sub_info.mat
Sub = size(subjlist_finished,1); % number of subjects


%%
exist_idx = [];
ICA_fold_out = cell(Sub,5);

for s_sub = 1:Sub
    temp_fold1 = subjlist_finished{s_sub,1};
    ICA_fold_out{s_sub, 1} = temp_fold1;

    sub_fold_name = temp_fold1(length(main_fold)+1:end);

    temp_fold_out = fullfile(ICA_fold, sub_fold_name);
    % check exist or not
    func_temp = dir(fullfile(temp_fold_out, '*_sub01_timecourses_ica_s1_.nii'));
    fnc_temp  = dir(fullfile(temp_fold_out, '*_postprocess_results', '*_post_process_sub_001.mat'));
    
    if ~isempty(func_temp) && ~isempty(fnc_temp)
        
        exist_idx = [exist_idx;s_sub];
        ICA_fold_out{s_sub, 2} = temp_fold_out;

        if ismember(s_sub,headmotion_info.hd_idx)
            ICA_fold_out{s_sub, 3} = 1;
        else
            ICA_fold_out{s_sub, 3} = 0;
        end

        if ismember(s_sub,headmotion_info.fd_idx)
            ICA_fold_out{s_sub, 4} = 1;
        else
            ICA_fold_out{s_sub, 4} = 0;
        end
        
        if ismember(s_sub,mask_info.mask_idx)
            ICA_fold_out{s_sub, 5} = 1;
        else
            ICA_fold_out{s_sub, 5} = 0;
        end
    end

    s_sub
end

non_exist_idx = setdiff([1:Sub]', exist_idx);

save('non_exist.mat', 'non_exist_idx', 'exist_idx', 'ICA_fold_out')