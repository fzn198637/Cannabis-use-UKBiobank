function Step2_ICA(slurm_array_id)

% clear
% clc
% slurm_array_id = 1;

addpath(genpath('/trdapps/linux-x86_64/matlab/toolboxes/GroupICAT'));
addpath('/data/users2/zfu/Matlab/GSU/Toolbox/GroupICATv4.0_array/gift_functions')

load('/data/qneuromark/Scripts/ICA/UKBiobank/non_exist.mat', 'non_exist_idx');
run_idx = non_exist_idx(slurm_array_id);

icatb_batch_file_run('/data/qneuromark/Scripts/ICA/UKBiobank/Step1_ICA.m', run_idx);
