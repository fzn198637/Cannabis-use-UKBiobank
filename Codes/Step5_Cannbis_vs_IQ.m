%% Step 4: statistic on FNC
clear
clc

%% load data
load Step3_demo_FNC.mat

%% prepare demo info
% age and QC measures
QC_measure = zeros(size(ICA_fold_out_use,1),3)-999; % C1 is hd, C2 is mean FD, C3 is mask
for s_sub = 1:size(ICA_fold_out_use,1)
    tmp_path = ICA_fold_out_use{s_sub, 2};
    sy_idx = find(tmp_path == '/');
    tmp_sess = tmp_path(sy_idx(end-1)+1:sy_idx(end)-1);

    if strcmp(tmp_sess, 'ses_01')
        input_age(s_sub,1) = table2array(demo_ana3(s_sub,4));
        input_IQ(s_sub,1) = table2array(demo_ana1(s_sub,2472));

    elseif strcmp(tmp_sess, 'ses_02')
        input_age(s_sub,1) = table2array(demo_ana3(s_sub,5));
        input_IQ(s_sub,1) = table2array(demo_ana1(s_sub,2473));

    end

    QC_measure(s_sub,1) = ICA_fold_out_use{s_sub, 3};
    QC_measure(s_sub,2) = ICA_fold_out_use{s_sub, 4};
    QC_measure(s_sub,3) = ICA_fold_out_use{s_sub, 5};
end

% ID
input_ID = categorical(table2array(demo_ana1(:,1)));

% gender
input_gender = categorical(table2array(demo_ana2(:,2)));

% cannabis use
input_can1 = (table2array(demo_ana1(:,2492))); % 20453, Ever taken cannabis,0~4
input_can2 = (table2array(demo_ana1(:,2493))); % 20454, Maximum frequency of taking cannabis, 1~4
input_can3 = (table2array(demo_ana1(:,2494))); % 20455, Age when last took cannabis

% head motion cov
input_meanFD = meanFD;

%% Select samples
% Image QC or not
% 0~not QC;1~spatial only;2~spatial+temporal (hd);3~spatial+temporal (mean
% FD);4~full QC
use_idx = 1:length(input_age);
opt_QC = 4;
if opt_QC == 0
    use_idx = use_idx;
elseif opt_QC == 1
    use_idx = intersect(use_idx, find(QC_measure(:,3)==0));
elseif opt_QC == 2
    use_idx = intersect(use_idx, find(QC_measure(:,3)==0));
    use_idx = intersect(use_idx, find(QC_measure(:,1)==0));
elseif opt_QC == 3
    use_idx = intersect(use_idx, find(QC_measure(:,3)==0));
    use_idx = intersect(use_idx, find(QC_measure(:,2)==0));
elseif opt_QC == 4
    use_idx = intersect(use_idx, find(QC_measure(:,3)==0));
    use_idx = intersect(use_idx, find(QC_measure(:,1)==0));
    use_idx = intersect(use_idx, find(QC_measure(:,2)==0));
end

% age >= 65
use_idx_age = find(input_age>=45);
% use_idx_age = intersect(find(input_age>=56), find(input_age<=65));
use_idx = intersect(use_idx, use_idx_age);
% unique ID
[u_ID, use_idx_ID] = unique(input_ID(use_idx));
use_idx = use_idx(use_idx_ID);
% healthy and cannabis users
hc_idx = find(input_can1(use_idx)==0);
pa_idx = intersect(find(input_can1(use_idx)>=1),find(input_can1(use_idx)<=4));
input_can1((use_idx(pa_idx))) = 99;

% balance sample
opt_balance = 0;
if opt_balance == 1
    tmp_idx = randperm(length(hc_idx));
    hc_idx_b = hc_idx(tmp_idx(1:length(pa_idx)));
    use_idx = union(use_idx(hc_idx_b), use_idx(pa_idx));

else
    use_idx = union(use_idx(hc_idx), use_idx(pa_idx));

end

% target score is not NAN
nonan_idx = find(input_IQ>=-9999);
use_idx = intersect(use_idx, nonan_idx);

%% LMM

tbl = table(input_can1(use_idx), input_IQ(use_idx), input_age(use_idx), input_gender(use_idx), input_ID(use_idx), input_meanFD(use_idx), 'VariableNames',{'Score', 'IQ', 'Age', 'Gender', 'ID', 'MFD'});
lme = fitlme(tbl,'IQ~Score+Age+Gender+MFD');

score_tval = lme.Coefficients(2,4).tStat;
score_df   = lme.Coefficients(2,5).DF;
asso_IQ.pval = lme.Coefficients(2,6).pValue;
asso_IQ.dval = 2*score_tval/(sqrt(score_df));
asso_IQ.rval = sqrt(score_tval^2/(score_tval^2+score_df)) .* sign(2*score_tval/(sqrt(score_df)));
asso_IQ.tval = score_tval;


%%
% save('Step4_FNC_vs_IQ_QC4.mat', 'asso_FNC', 'use_idx')