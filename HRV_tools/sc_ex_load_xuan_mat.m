clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

subj = 'LWP2_0019';

subj_dir = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj);

fp_xuan = fullfile(subj_dir, 'LWP_0019_E4GsrLeft_Lab_AllEvents_LedalabImport.mat');
load(fp_xuan);