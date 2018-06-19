clear all
% root folder, need to be specified 
dir = pwd();
% relative path to the root folder
addpath(fullfile(dir, 'HRV', 'HRV_tools'));
addpath(fullfile(dir, 'HRV', 'HRV_data'));

% read data
subj = '0019';
task_name = 'Task14_MentalMath';
data_msband = xlsread(sprintf('tmp_LWP2_%s_MSBand_RR_raw_data_by_task.xlsx', subj), task_name);
r_msband = data_msband(:,1);
t_msband = data_msband(:,2);
data_firstbeat = xlsread(sprintf('tmp_LWP2_%s_FirstBeat_RR_raw_data_by_task.xlsx', subj), task_name);
r_firstbeat = data_firstbeat(:,1);
t_firstbeat = data_firstbeat(:,2);


% set parameters
nsigma = 2;   %outlier range
AR_order = 10;      % AR order for impute long outlier
AR_window = 250;        % AR window size for impute long outlier
ssa_window = 25;        % SSA window size
plotflag = 1;

compare_msband_with_firstbeat(r_msband, t_msband, r_firstbeat, t_firstbeat, 'Original MSband RR Signal');
[r_msband_cleaned, t_msband_cleaned] = hr_clean2(r_msband, t_msband, nsigma, AR_order, AR_window, ssa_window, plotflag);
compare_msband_with_firstbeat(r_msband_cleaned, t_msband_cleaned, r_firstbeat, t_firstbeat, 'Cleaned MSband RR Signal');




function compare_msband_with_firstbeat(r_msband, t_msband, r_firstbeat, t_firstbeat, title_msband)
    figure;
    subplot(2,1,1);
    plot(t_msband, r_msband, 'b.-', 'MarkerSize',8); 
    datetick('x', 'HH:MM:SS'); 
    ylabel('RR (msec)');
    title(title_msband);
    
    subplot(2,1,2);
    plot(t_firstbeat, r_firstbeat, 'b.-', 'MarkerSize',8); 
    datetick('x', 'HH:MM:SS'); 
    ylabel('RR (msec)');
    title('Original FirstBeat RR Signal');
end


