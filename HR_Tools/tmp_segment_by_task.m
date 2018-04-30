clear all
dir = pwd();
addpath(fullfile(dir, 'HeartRate', 'HR_Tools'));
addpath(fullfile(dir, 'HeartRate', 'HR_Data'));

task_names = {
    'Task1 Relaxing Music1', ...
    'Task2 Relaxing Pic1', ...
    'Task3 EMA1', ...
    'Task4 IAPS', ...
    'Task5 StressPic1', ...
    'Task6 EMA2', ...
    'Task7 Relaxing Music2', ...
    'Task8 Relaxing Pic2', ...
    'Task9 EMA3', ...
    'Task10 Biking', ...
    'Task11 Relaxing Music3', ...
    'Task12 NeutralPic', ...
    'Task13 EMA4', ...
    'Task14 MentalMath', ...
    'Task15 Stroop', ...
    'Task16 StressPic2', ...
    'Task17 EMA5', ...
    'Task18 March'
    };


subj = '0011';
device = 'FirstBeat';
%device = 'MSBand';


% input and output files
fp_in_data = sprintf('LWP2_%s_Data.mat', subj);
fp_in_timing = sprintf('LWP2_%s_lab_timing.xlsx', subj);
f_out = sprintf('LWP2_%s_%s_RR_raw_data_by_task.xlsx', subj, device);


% read input files
load(fp_in_data); 
[ndata, tdata, ~] = xlsread(fp_in_timing);
date = datenum(tdata(5,2));
dominant_hand = tdata(11,10);


for i=1:length(task_names)
    start_time = date + ndata(4+i,1); % start with ndata(5,1) 
    end_time = date + ndata(5+i,1);
    task_name = task_names{i};
    sprintf('%s', task_name)    
    if strcmp(device, 'FirstBeat')
        RR = FB_RR;
        RR_t = FB_Time_RR;
    elseif strcmp(device, 'MSBand')
        if strcmp(dominant_hand, 'RIGHT')
            RR = BandRR_L;
            RR_t = BandTimeRR_L;
        elseif strcmp(dominant_hand, 'LEFT')
            RR = BandRR_R;
            RR_t = BandTimeRR_R;  
        end
    end    
    write_segment(f_out, task_name, RR, RR_t, start_time, end_time);
end


function write_segment(f_out, sheet_name, RR, RR_t, start_time, end_time)
    % get segment data
    idx = find((RR_t >= start_time) & (RR_t <= end_time));
    seg_RR = RR(idx);             
    seg_RR_t = RR_t(idx);
    d = cat(2, seg_RR, seg_RR_t);
    
    % write to xlsx 
    dir = pwd();
    fp_out = fullfile(dir, 'HeartRate', 'HR_Data', f_out);
    xlswrite(fp_out, d, sheet_name);
end


