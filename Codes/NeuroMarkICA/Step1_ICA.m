%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Group ICA main function with prior group-level maps as guidance 
%%%% Written by Zening Fu 
%%%% The Mind Research Network
%%%% Date: 3/01/2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Important notes
%%%% Need to revise according to your data: this means that you need to adjust according to your data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enter the values for the variables required for the ICA analysis.
% Variables are on the left and the values are on the right.
% Characters must be enterd in single quotes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%v%%%%%%%%%%%%%%%%
%% Modality. Options are fMRI and EEG
modalityType = 'fMRI';

%% Enter directory to put results of analysis
outputDir = '/data/qneuromark/Results/ICA/UKBiobank';

%% Enter Name (Prefix) Of Output Files
prefix = 'NeuroMark1';

%% There are four ways to enter the subject data
% options are 1, 2, 3 or 4
dataSelectionMethod = 4;

%%%%%%%%%%%%%%%%%%%%%%%%% Start for Method 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input data file pattern for data-sets must be in a cell array. The no. of rows of cell array correspond to no. of subjects
% and columns correspond to sessions. In the below example, there are 3
% subjects and 1 session. If you have multiple sessions, please see
% Input_data_subjects_2.m file.


%% input data
% select subjects
load('/data/qneuromark/Results/Subject_selection/UKBiobank/UKB_sub_info.mat', 'subjlist_finished', 'main_fold')

Sub = size(subjlist_finished,1); % number of subjects
input_data_subfold_patterns = cell(Sub,1);
input_data_file_patterns = cell(Sub,1);
input_data_hd_patterns   = cell(Sub,1);
TR = zeros(Sub,1);
em_idx = zeros(Sub,1);
for s_sub = 1:Sub

    %% input sub folder
    temp_subfold = subjlist_finished{s_sub,1};
    sub_fold_name = temp_subfold(length(main_fold)+1:end);

    input_data_subfold_patterns(s_sub,1) = {sub_fold_name};

    %% input nii
    tmp_filename = dir(fullfile(subjlist_finished{s_sub,1},'Sm*.nii'));
    if isempty(tmp_filename)
        em_idx(s_sub,1) = 1;
    end
    temp_file = fullfile(subjlist_finished{s_sub,1}, tmp_filename.name); % functional image folder
    input_data_file_patterns(s_sub,1) = {temp_file};
   
    %% head motion
    tmp_filename = dir(fullfile(subjlist_finished{s_sub,1},'headmotion*.txt'));
    temp_hd   = fullfile(subjlist_finished{s_sub,1}, tmp_filename.name); % functional image folder
    input_data_hd_patterns(s_sub,1) = {temp_hd};

    %% TR
%     rest_json_info = jsondecode(fileread(fullfile(subjlist_finished{s_sub,1}, 'rest.json')));
    TR(s_sub,1) = 0.735;
end
    
dummy_scans = 0;
%%%%%%%%%%%%%%%%%%%%%%%%% End for Method 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Group ica type
% Options are spatial or temporal for fMRI modality. By default, spatial
% ica is run if not specified.
group_ica_type = 'spatial';

%% Parallel info
% enter mode serial or parallel. If parallel, enter number of
% sessions/workers to do job in parallel
% parallel_info.mode = 'serial';
% parallel_info.num_workers = 4;
% parallel_info.mode = 'parallel';
% parallel_info.num_workers = 2;

%% 'Which ICA Algorithm Do You Want To Use';
% see icatb_icaAlgorithm for details or type icatb_icaAlgorithm at the
% command prompt.
% Note: Use only one subject and one session for Semi-blind ICA. Also specify atmost two reference function names
% 1 - Infomax?
% 2 - FastICA?
% 3 - ERICA?
% 4 - SIMBEC?
% 5 - EVD?
% 6 - JADE OPAC?
% 7 - AMUSE?
% 8 - SDD ICA?
% 9 - Semi-blind ICA?
% 10 - Constrained ICA (Spatial)?
% 11 - Radical ICA?
% 12 - Combi?
% 13 - ICA-EBM?
% 14 - ERBM?
% 15 - IVA-GL?
% 16 - MOO-ICAR?
% if you only need to use group map to reconstruct subject map, input
% should be set as 'gig-ica'.
algoType = 'MOO-ICAR';

%% Data Pre-processing options
% 1 - Remove mean per time point
% 2 - Remove mean per voxel
% 3 - Intensity normalization
% 4 - Variance normalization
preproc_type = 4;

%% Enter location (full file path) of the image file to use as mask
% or use Default mask which is []
%maskFile = [];
maskFile = '/data/qneuromark/Results/Subject_selection/UKBiobank/UKB_mask.nii';

%% Scale the Results. Options are 0, 1, 2
% 0 - No scaling
% 1 - Scale components to percent signal change
% 2 - Z-scores
% 3 - Scaling in timecourses
% 4 - Scaling in maps and timecourses
scaleType = 2;

%% RUN ICA    Group PCA performance settings. Best setting for each option will be selected based on variable MAX_AVAILABLE_RAM in icatb_defaults.m. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you have selected option 3 (user specified settings) you need to manually set the PCA options. 
% Options are:
% 1 - Maximize Performance
% 2 - Less Memory Usage
% 3 - User Specified Settings
perfType = 3;

%% Specify spatial reference files for constrained ICA (spatial) or gig-ica
%for the high model order
refFiles = {'/data/qneuromark/Network_templates/NeuroMark1/Neuromark_fMRI_1.0.nii'};
