function [start_t, end_t] = hr_util_getTaskTiming(proj_dir, subj, task_id, time_format)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description: 
%   Segment raw data read from the database by task according to lab_timing file
%   Save segmented data in a xlsx file, each task in a seperate sheet
% Inputs:
%   proj_dir            - full path of local repository 'Data-Analysis'
%   subj                - subject id (e.g. 'LWP2_0019')
%   task_id             - refer to 'Data-Analysis\lab_timing\(subj)' for task_id (e.g. 'Task10_Biking')
%   time_format         - options are: datenum (matlab datenum format), sec (seconds, start from 0)
% Outputs:
%   start_t             - start time of the task in the specified time format
%   end_t               - end time of the task in the specified time format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fp_in_timing = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj, sprintf('%s_lab_timing.xlsx', subj));
    [ndata, tdata, ~] = xlsread(fp_in_timing);
    timings = ndata(4:end,1);
    computer_os = computer('arch');
    if startsWith(computer_os, 'mac')
        date = datenum(ndata(3,1)+693960);
    elseif startsWith(computer_os, 'win')
        date = datenum(tdata(5,2));
    end
    
    % there is bug in 'sec' part, 
    % here t=0 is the lab start time, but sensor data may start later than lab start time,    
    if strcmp(time_format, 'sec')
        start_t = (timings(1+task_id,1) - timings(1,1)) * 24 * 3600;
        end_t = (timings(2+task_id,1) - timings(1,1)) * 24 * 3600;
    elseif strcmp(time_format, 'datenum')
        start_t = date + timings(1+task_id,1); 
        end_t = date + timings(2+task_id,1);
    end
end