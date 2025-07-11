%% examine finishe
clear
clc

load('/data/qneuromark/Scripts/ICA/UKBiobank/non_exist.mat', 'ICA_fold_out')
result_fold = '/data/users2/zfu/Matlab/GSU/UKB/Cannabis/Results/Matching';

whole_idx = zeros(size(ICA_fold_out,1), 1);

for s_sub = 1:size(ICA_fold_out,1)

    tmp_data = fullfile(result_fold, sprintf('ICA%05d.mat', s_sub));

    if ~isempty(dir(tmp_data))
        whole_idx(s_sub, 1) = 1;
    end
    
    s_sub
end

finish_idx    = find(whole_idx == 1);
nonfinish_idx = find(whole_idx == 0);

save('Step1_index.mat', 'finish_idx', 'nonfinish_idx')