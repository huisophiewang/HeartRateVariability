clear all
dir = pwd();
addpath(fullfile(dir, 'HeartRate', 'HR_Tools'));
addpath(fullfile(dir, 'HeartRate', 'HR_Data'));

task_names = {
    'Task1_RelaxingMusic1', ...
    'Task2_RelaxingPic1', ...
    'Task3_EMA1', ...
    'Task4_IAPS', ...
    'Task5_StressPic1', ...
    'Task6_EMA2', ...
    'Task7_RelaxingMusic2', ...
    'Task8_RelaxingPic2', ...
    'Task9_EMA3', ...
    'Task10_Biking', ...
    'Task11_RelaxingMusic3', ...
    'Task12_NeutralPic', ...
    'Task13_EMA4', ...
    'Task14_MentalMath', ...
    'Task15_Stroop', ...
    'Task16_StressPic2', ...
    'Task17_EMA5', ...
    'Task18_March'
    };


subj = '0003';
device = 'FirstBeat';
%device = 'MSBand';

% input and output files
fp_in_data = sprintf('tmp_LWP2_%s_Data.mat', subj);
fp_in_timing = sprintf('LWP2_%s_lab_timing.xlsx', subj);
f_out = sprintf('tmp_LWP2_%s_%s_RR_raw_data_by_task.xlsx', subj, device);

% read input files
load(fp_in_data); 
[ndata, tdata, ~] = xlsread(fp_in_timing);
dominant_hand = tdata(11,10);
computer_os = computer('arch');

% get date, xlsread date field depends on os
if startsWith(computer_os, 'mac')
    date = datenum(ndata(3,1)+693960);
elseif startsWith(computer_os, 'win')
    date = datenum(tdata(5,2));
end

% segment Data.mat based on timing.xlsx
for i=1:length(task_names)
    start_time = date + ndata(4+i,1); % start with ndata(5,1) 
    end_time = date + ndata(5+i,1);
    
    task_name = task_names{i};
    fprintf('--------------------------------\n');
    fprintf('%s\n', task_name)  
    
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
    
    warning('off','MATLAB:xlswrite:AddSheet');
    write_segment(f_out, task_name, RR, RR_t, start_time, end_time);
end


function write_segment(f_out, sheet_name, RR, RR_t, start_time, end_time)
    % get segment data
    if (~isnan(start_time)) && (~isnan(end_time)) && (start_time < end_time)  
        idx = find((RR_t >= start_time) & (RR_t <= end_time));
        if ~isempty(idx)
            seg_RR = RR(idx);             
            seg_RR_t = RR_t(idx);
            d = cat(2, seg_RR, seg_RR_t);
            % write to xlsx 
            dir = pwd();
            fp_out = fullfile(dir, 'HeartRate', 'HR_Data' ,f_out);
            xlswrite(fp_out, d, sheet_name);
        else
            disp("No data found within the range between the given start_time and end_time");
        end
    else
        disp("Invalid start_time or end_time");
    end
end


