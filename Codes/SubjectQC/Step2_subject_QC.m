%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Subject selection: 1. Head motion; 2. Compare mask
%%%% common mask
%%%% Zening
%%%% 2021.05.10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
clc
parpool(30) % only work in the cluster, not on hemera
addpath('/data/users2/zfu/Matlab/GSU//Toolbox/spm12');
addpath('/data/users2/zfu/Matlab/GSU//Toolbox');

%% Step 1: match file name to info
load('/data/qneuromark/Scripts/Subject_selection/UKBiobank/Step1_subjlist.mat', 'subjlist', 'main_fold')
subjlist_finished = subjlist;

%% QC1-temporal: subject head motions
headmotion_info.fd_thres     = 0.35;
headmotion_info.hd_thres     = 3;

num_Sub = size(subjlist_finished,1);
headmotion_info.meanFD = zeros(num_Sub, 1);

headmotion_info.fd_idx = [];
headmotion_info.hd_idx = [];
for s_sub = 1:num_Sub

    temp_file = fullfile(subjlist_finished{s_sub,1}, subjlist_finished{s_sub,3});
    temp_hd   = load(temp_file);

    %%%% calculate mean FD
    clear FD
    for i = 1:(size(temp_hd,1)-1)
        FD(i) = sum(abs(temp_hd(i,4:6) - temp_hd(i+1,4:6))) + 50*sum(abs(temp_hd(i,1:3) - temp_hd(i+1,1:3)));
    end            
    headmotion_info.meanFD(s_sub, 1) = mean(FD);

    %%%% transfer to degree
    temp_hd(:,1:3) = temp_hd(:,1:3).*(180/pi);
    temp_hd = abs(temp_hd);
   
    %% subj select
    if mean(FD) > headmotion_info.fd_thres
        headmotion_info.fd_idx = [headmotion_info.fd_idx; s_sub];
    end
    
    bad_idx = find(temp_hd(:) > headmotion_info.hd_thres);
    if size(bad_idx) ~= 0
        headmotion_info.hd_idx = [headmotion_info.hd_idx; s_sub];
    end
    s_sub
end
headmotion_info.use_idx = setdiff([1:num_Sub]', union(headmotion_info.hd_idx, headmotion_info.fd_idx));

%% QC2-spatial: comparing mask
% Input paramters
slice_which = 1;      % number of time frame used, usually use the first time frame

multiplier = 0.9;     % for individual mask, > multiplier x mean is set to 1, otherwise set to 0
perc_thres = 0.9;     % for group mask, > perc_thres of subjects with 1 then set to 1, otherwise set to 0

top_slice = [43:52];  % examine the top x slice
but_slice = [6:15];   % examine the buttom x slice

mini_corr_all = 0.8;  % if the individual mask with smaller correlation < mini_corr_all with the compared mask, discard this subject
mini_corr_top = 0.75;  % if the individual mask with smaller correlation < mini_corr_top with the compared mask, discard this subject
mini_corr_but = 0.55;  % if the individual mask with smaller correlation < mini_corr_but with the compared mask, discard this subject

sub_ID_mask = subjlist_finished;
num_Sub = size(sub_ID_mask,1);

hdr_hc  = spm_vol('/data/qneuromark/Network_templates/NeuroMark1/Functional/For_QC/NetworkTemplate_High_VarNor.nii,1');
mask_hc = spm_read_vols( hdr_hc );
mask_indi = zeros(num_Sub,size(mask_hc,1)*size(mask_hc,2)*size(mask_hc,3));
parfor s_sub = 1:num_Sub
    
    temp_file = sprintf('%s/%s,%d', sub_ID_mask{s_sub,1}, sub_ID_mask{s_sub,2}, slice_which);
    temp_hdr = spm_vol( temp_file );
    temp_img = spm_read_vols( temp_hdr );
    temp_img = temp_img(:);
    % choose img with values
    value_idx = find(temp_img >= -9999999);
    
    % larger than mean.*perc_thres
    temp_thres = mean(temp_img(value_idx)) .* multiplier;
    sub_mask = (temp_img(:) >= temp_thres);
    
    mask_indi(s_sub,:) = sub_mask;
end

% calculate common mask
mask_comm_temp = zeros(size(mask_hc,1)*size(mask_hc,2)*size(mask_hc,3),1);
for i = 1:size(mask_indi,2)
    if (sum(mask_indi(:,i))/num_Sub) >= perc_thres
        mask_comm_temp(i) = 1;
    end
end

mask_comm_temp = reshape(mask_comm_temp, size(mask_hc,1), size(mask_hc,2), size(mask_hc,3));
[corr_mask_all] = corr_with_mask(mask_comm_temp, reshape(mask_indi, num_Sub, size(mask_hc,1), size(mask_hc,2), size(mask_hc,3)), [1:size(mask_hc,3)]);
[corr_mask_but] = corr_with_mask(mask_comm_temp, reshape(mask_indi, num_Sub, size(mask_hc,1), size(mask_hc,2), size(mask_hc,3)), but_slice);
[corr_mask_top] = corr_with_mask(mask_comm_temp, reshape(mask_indi, num_Sub, size(mask_hc,1), size(mask_hc,2), size(mask_hc,3)), top_slice);

% choose subject larger than thres
use_all_idx     = find(corr_mask_all >= mini_corr_all);
use_top_idx     = find(corr_mask_top >= mini_corr_top);
use_but_idx     = find(corr_mask_but >= mini_corr_but);

% overlap idx
use_final_idx     = intersect(use_top_idx, use_but_idx);
use_final_idx     = intersect(use_final_idx, use_all_idx);

% calculate final mask
mask_comm_final = zeros(size(mask_hc,1)*size(mask_hc,2)*size(mask_hc,3),1);
for i = 1:size(mask_indi,2)
    if (sum(mask_indi(use_final_idx,i))/(length(use_final_idx))) >= perc_thres
        mask_comm_final(i) = 1;
    end
end

mask_final       = reshape(mask_comm_final, size(mask_hc,1), size(mask_hc,2), size(mask_hc,3));
mask_info.use_idx     = use_final_idx;
mask_info.mask_idx = setdiff(1:size(sub_ID_mask,1), mask_info.use_idx)';

mask_info.discard_subjlist_mask      = subjlist_finished(mask_info.mask_idx,1);

for i = 1:length(mask_info.mask_idx)
    mask_info.discard_subjlist_mask{i,2} = corr_mask_all(mask_info.mask_idx(i),1);
    mask_info.discard_subjlist_mask{i,3} = corr_mask_top(mask_info.mask_idx(i),1);
    mask_info.discard_subjlist_mask{i,4} = corr_mask_but(mask_info.mask_idx(i),1);
end

mask_info.corr_mask_all = corr_mask_all;
mask_info.corr_mask_top = corr_mask_top;
mask_info.corr_mask_but = corr_mask_but;

%% save mask and idx
hdr_final = hdr_hc;
hdr_final.fname = sprintf( '/data/qneuromark/Results/Subject_selection/UKBiobank/UKB_mask.nii');
spm_write_vol(hdr_final, mask_final);

%% save info
Savefolder  = sprintf( '/data/qneuromark/Results/Subject_selection/UKBiobank/UKB_sub_info.mat');
save(Savefolder, 'subjlist_finished', 'headmotion_info', 'mask_info', 'main_fold', '-v6');