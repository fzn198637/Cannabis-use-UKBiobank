%% Step1 create preprocessed fMRI list
clear
clc

main_fold = '/data/qneuromark/Data/UKBiobank/Data_BIDS/Preprocess_Data/';

sub_fold = dir(fullfile(main_fold, '*/*/*/Sm*.nii'));
subjlist = cell(length(sub_fold),3);
nonexist_idx = zeros(length(sub_fold),1);

for s_sub = 1:length(sub_fold)

    tmp_hd = dir(fullfile(sub_fold(s_sub,1).folder, 'headmotion.txt'));
    if isempty(tmp_hd)
        nonexist_idx(s_sub,1) = 1;
    end

    subjlist{s_sub,1} = sub_fold(s_sub,1).folder;
    subjlist{s_sub,2} = sub_fold(s_sub,1).name;
    subjlist{s_sub,3} = tmp_hd.name;

end

save('Step1_subjlist.mat', 'subjlist', 'main_fold')