clear all
dir = pwd();
addpath(fullfile(dir, 'HeartRate', 'HR_Tools'));
addpath(fullfile(dir, 'HeartRate', 'HR_Data'));

fp_in_data = 'LWP2_0019_Data.mat';
fp_in_timing = 'LWP2_0019_lab_timing.xlsx';
[ndata, tdata, ~] = xlsread(fp_in_timing);

task_names = {
    'Task1 Relaxing Music1',
    'Task2 Relaxing Pic1',
    'Task3 EMA1',
    'Task4 IAPS',
    'Task5 StressPic1',
    'Task6 EMA2',
    'Task7 Relaxing Music2',
    'Task8 Relaxing Pic2',
    'Task9 EMA3',
    'Task10 Biking',
    'Task11 Relaxing Music3',
    'Task12 NeutralPic',
    'Task13 EMA4',
    'Task14 MentalMath',
    'Task15 Stroop',
    'Task16 StressPic2',
    'Task17 EMA5',
    'Task18 March'
    };
%time = ndate(4:23,1);


date = datenum(tdata(5,2));
start_time = date + ndata(5,1);
end_time = date + ndata(6,1);

load(fp_in_data); 
f_out = 'tmp_lwp_0019_firstbeat_rr_analysis_raw_data.xlsx';
write_segment(FB_Time_RR, FB_RR, start_time, end_time, f_out);


% A = [12.7 5.02 -98 63.9 0 -.2 56];
% xlswrite(fp_out, A);



function write_segment(RR_t, RR, start_time, end_time, f_out)
    % get segment data
    idx = find((RR_t >= start_time) & (RR_t <= end_time));
    seg_RR = RR(idx);             
    seg_RR_t = RR_t(idx);
    d = cat(2, seg_RR, seg_RR_t);
    % write to xlsx file
    dir = pwd();
    fp_out = fullfile(dir, 'HeartRate', 'HR_Data', f_out);
    xlswrite(fp_out, d, 'tmp_sheet');
end


