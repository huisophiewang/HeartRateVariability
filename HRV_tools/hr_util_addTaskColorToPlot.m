function hr_util_addTaskColorToPlot(proj_dir, subj, main_plot_objs, main_legend_names, time_format, with_baseline)    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description: 
%   Segment raw data read from the database by task according to lab_timing file
%   Save segmented data in a xlsx file, each task in a seperate sheet
% Inputs:
%   proj_dir            - full path of local repository 'Data-Analysis'
%   subj                - subject id (e.g. 'LWP2_0019')
%   main_plot_objs      - plot object(s) from matlab plot function (e.g. plt_obj = plot()), use vector for multiple plot objects (e.g. [obj1, obj2])
%   main_legend_names   - lengend(s) correspond to the main plot object(s), (e.g. 'power'), use cell array for multiple legends (e.g. {'LF power', 'HF power'})
%   time_format         - options are: datenum (matlab datenum format), sec (seconds, start from 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % read lab timing file
    fp_in_timing = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj, sprintf('%s_lab_timing.xlsx', subj));
    [ndata, tdata, ~] = xlsread(fp_in_timing);
    timings = ndata(4:end,1);
    computer_os = computer('arch');
    if startsWith(computer_os, 'mac')
        date = datenum(ndata(3,1)+693960);
    elseif startsWith(computer_os, 'win')
        date = datenum(tdata(5,2));
    end
    
    y_range = get(gca,'YLim');
    min_h = y_range(1);
    max_h = y_range(2);
    
    % read stress level from EMA sessions
    levels = zeros(1,5);
    pattern = 'stress level (\d+)';
    stress_rows = [9, 12, 15, 19, 23];
    for i=1:5
        levels(1,i) = max_h;
%         str = char(tdata(stress_rows(i), 5));
%         [mat,tok] = regexp(str, pattern, 'match', 'tokens');
%         if ~isempty(mat)
%             levels(1,i) = str2num(char(tok{1}));
%             levels(1,i) = max_h;
%             %levels(1,i) = (max_h-min_h)*levels(1,i)/5;
%         else
%             levels(1,i) = min_h;
%         end
    end

    % assign color to each type of task
    grey = [0.7 0.7 0.7];   % neutral
    blue = [0.5 0.7 1.0];   % relaxation
    pink = [1 0.5 0.5];     % mental stress
    orange = [1.0 0.7 0.4]; % physical stress

    % fill each type of task with a specified color, with height of stress level
    p1 = fill_task_with_color(date, timings, 1, min_h, levels(1,1), blue, time_format, with_baseline);    % relaxing music 1
    p2 = fill_task_with_color(date, timings, 2, min_h, levels(1,1), blue, time_format, with_baseline);    % describe relaxing pic 1
    p3 = fill_task_with_color(date, timings, 3, min_h, levels(1,1), grey, time_format, with_baseline);    % EMA 1
    
    EMA2_stress = (max_h-min_h)*levels(1,2)/5;
    p4 = fill_task_with_color(date, timings, 4, min_h, levels(1,2), pink, time_format, with_baseline);    % IAPS
    p5 = fill_task_with_color(date, timings, 5, min_h, levels(1,2), pink, time_format, with_baseline);    % describe stressful pic 1
    p6 = fill_task_with_color(date, timings, 6, min_h, levels(1,2), grey, time_format, with_baseline);    % EMA 2
    
    EMA3_stress = (max_h-min_h)*levels(1,3)/5;
    p7 = fill_task_with_color(date, timings, 7, min_h, levels(1,3), blue, time_format, with_baseline);    % relaxing music 2
    p8 = fill_task_with_color(date, timings, 8, min_h, levels(1,3), blue, time_format, with_baseline);    % dexcribe relaxing pic 2
    p9 = fill_task_with_color(date, timings, 9, min_h, levels(1,3), grey, time_format, with_baseline);    % EMA 3
    
    EMA4_stress = (max_h-min_h)*levels(1,4)/5;
    p10 = fill_task_with_color(date, timings, 10, min_h, min_h, orange, time_format, with_baseline);    % biking
    p11 = fill_task_with_color(date, timings, 11, min_h, levels(1,4), blue, time_format, with_baseline);    % relaxing music 3
    p12 = fill_task_with_color(date, timings, 12, min_h, levels(1,4), grey, time_format, with_baseline);    % describe neutral    
    p13 = fill_task_with_color(date, timings, 13, min_h, levels(1,4), grey, time_format, with_baseline);    % EMA 4
    
    EMA5_stress = (max_h-min_h)*levels(1,5)/5;
    p14 = fill_task_with_color(date, timings, 14, min_h, levels(1,5), pink, time_format, with_baseline);    % mental math
    p15 = fill_task_with_color(date, timings, 15, min_h, levels(1,5), pink, time_format, with_baseline);    % stroop test
    p16 = fill_task_with_color(date, timings, 16, min_h, levels(1,5), pink, time_format, with_baseline);    % describe stressful pic
    p17 = fill_task_with_color(date, timings, 17, min_h, levels(1,5), grey, time_format, with_baseline);    % EMA 5
    
    p18 = fill_task_with_color(date, timings, 18, min_h, min_h, orange, time_format, with_baseline);  % March

    plot_objs = [main_plot_objs, [p17, p1, p16]];
    legend_names = [main_legend_names, {'Neutral', 'Relaxation', 'Mental Stress'}];
    legend(plot_objs, legend_names);
    set(gca,'TickLength',[0.001, 0.001])
    %title(sprintf('%s', subj), 'Interpreter', 'none');
    
end

function p = fill_task_with_color(date, timings, task_id, min_h, max_h, color, time_format, with_baseline)
    if strcmp(time_format, 'sec')
        if isempty(with_baseline)
            start_t = (timings(1+task_id,1) - timings(1,1)) * 24 * 3600;
            end_t = (timings(2+task_id,1) - timings(1,1)) * 24 * 3600;
        else
            disp(task_id);
            start_t = (timings(1+task_id,1) - timings(23,1)) * 24 * 3600;
            start_t
            end_t = (timings(2+task_id,1) - timings(23,1)) * 24 * 3600;
        end
    elseif strcmp(time_format, 'datenum')
        start_t = date + timings(1+task_id,1); 
        end_t = date + timings(2+task_id,1);
    end
    p = fill([start_t, end_t, end_t, start_t], [min_h, min_h, max_h, max_h], color, 'FaceAlpha', 0.2, 'LineStyle', ':');
end