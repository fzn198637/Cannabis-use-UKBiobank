function Step2_UKB_match_index(slurm_array_id)
% clear
% clc
% slurm_array_id = 1;

% load ICA folder
load('/data/qneuromark/Scripts/ICA/UKBiobank/non_exist.mat', 'ICA_fold_out')
% load demo ID
load('/data/qneuromark/Data/UKBiobank/Data_info/Basket/B4033904/Cannabis/f20453.mat', 'field20453')
% load unmatched index; Run step 1 first
load('/data/users2/zfu/Matlab/GSU/UKB/Cannabis/Codes/Step1_index.mat', 'nonfinish_idx')
% output matching folder
result_fold = '/data/users2/zfu/Matlab/GSU/UKB/Cannabis/Results/Matching';

%% start matching
s_sub = nonfinish_idx(slurm_array_id);
seach_num = size(field20453,1);

tmp_path = ICA_fold_out{s_sub, 2};
sy_idx = find(tmp_path == '/');
tmp_ID = tmp_path(sy_idx(6)+1:sy_idx(7)-1);

match_idx = 0;
for i = 1:seach_num
    tmp_ID2 = num2str(table2array(field20453(i,1)));

    if strcmp(tmp_ID, tmp_ID2)
        match_idx = i;
        break
    end

end


%% save index
save(fullfile(result_fold, sprintf('ICA%05d.mat', s_sub)), 'match_idx', 'tmp_ID', 'tmp_ID2')
