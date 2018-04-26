clear all
dir_current = pwd();
addpath(fullfile(dir_current, 'HeartRate', 'HR_Tools'));
addpath(fullfile(dir_current, 'HeartRate', 'HR_Data'));


% read xlsx file
d = xlsread('lwp_0019_firstbeat_rr_analysis_raw_data.xlsx', 'Task 1 Relax Music');
RR = d(:,1);
RR_t = d(:,2);

% poincare plot before cleaning
plotflag = 1;
[sd1, sd2] = hr_poincare(RR, plotflag);
title('Subj 19 - Raw data', 'Interpreter', 'none');

% clean and smoothing
win = 25; 
plotflag = 0;
[RR_t_clean, RR_clean] = hr_clean(RR_t, RR, win, plotflag);

% poincare plot after cleaning
plotflag = 1;
[sd1, sd2] = hr_poincare(RR_clean, plotflag);
title('Subj 19 - Clean Data', 'Interpreter', 'none');

% write to ibi file
fp_out = fullfile(dir_current, 'HeartRate', 'HR_Data', 'sophie_test.ibi');
ibi_file = fopen(fp_out, 'w');
fprintf(ibi_file,'%.3f\n', RR_clean./1000);
fclose(ibi_file);
