%% step 3 sumary demo and FNC
clear
clc

addpath('/data/users2/zfu/Matlab/GSU/Toolbox')
load('/data/qneuromark/Scripts/ICA/UKBiobank/non_exist.mat', 'ICA_fold_out')
result_fold = '/data/users2/zfu/Matlab/GSU/UKB/Cannabis/Results/Matching';

%% read match index
match_all_idx = zeros(size(ICA_fold_out,1), 1);
for s_sub = 1:size(ICA_fold_out,1)

    tmp_data = fullfile(result_fold, sprintf('ICA%05d.mat', s_sub));

    load(tmp_data, 'match_idx')

    match_all_idx(s_sub, 1) = match_idx;

    clear match_idx
      
    s_sub
end

%% save demo
M = readtable('/data/users2/zfu/Matlab/GSU/Temp/Vince/Temp_UKB/Array/Kent/Download/field_int.csv');
demo_ana1 = M([match_all_idx(match_all_idx~=0)],:);
clear M

M = readtable('/data/users2/zfu/Matlab/GSU/Temp/Vince/Temp_UKB/Array/Kent/Download/field_int_add.csv');
demo_ana2 = M([match_all_idx(match_all_idx~=0)],:);
clear M

M = readtable('/data/users2/zfu/Matlab/GSU/Temp/Vince/Temp_UKB/Array/Kent/Download/field_int_add2.csv');
demo_ana3 = M([match_all_idx(match_all_idx~=0)],:);

%% save FNC
ICA_fold_out_use = ICA_fold_out(match_all_idx~=0,:);
sFNC = zeros(size(ICA_fold_out_use,1), 1378);
for s_sub = 1:size(ICA_fold_out_use,1)
    tmp_data = load(fullfile(ICA_fold_out_use{s_sub,2}, 'NeuroMark1_postprocess_results', 'NeuroMark1_post_process_sub_001.mat'));
    sFNC(s_sub, :) = mat2vec(squeeze(tmp_data.fnc_corrs(1,:,:)));

    s_sub
end

%% save mean FD
load('/data/qneuromark/Results/Subject_selection/UKBiobank/UKB_sub_info.mat', 'headmotion_info');
meanFD = headmotion_info.meanFD(match_all_idx~=0,1);

%% save mat
save('Step3_demo_FNC.mat', 'demo_ana1', 'demo_ana2', 'demo_ana3', 'match_all_idx', 'ICA_fold_out_use', 'sFNC', 'meanFD', '-v7.3')