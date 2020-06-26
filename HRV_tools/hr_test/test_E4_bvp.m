clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

% specify subject id
subj = 'LWP2_0019';
task = 'Task15_Stroop';

subj_data_dir = fullfile(proj_dir, 'HRV', 'HRV_data', subj);
addpath(subj_data_dir);



% read bvp data
f_bvp = sprintf('%s_lab_e4_bvp.mat', subj);
load(f_bvp);
bvp = lwp19E4BvpLab1(:,1);
bvp_t = datenum(datetime(lwp19E4BvpLab1(:,2)/1000,'ConvertFrom', 'posixtime', 'TimeZone', 'America/New_York')); 

% read rr data
f_in_data = sprintf('%s_lab_data.mat', subj);
load(f_in_data);
rr = e4_left_rr;
rr_t = e4_left_rr_t;

%plot_all(bvp, bvp_t, rr, rr_t);


% get task segment
[t_start, t_end] = get_task_time(proj_dir, subj, task);
datetime(t_start,'ConvertFrom','datenum')
datetime(t_end,'ConvertFrom','datenum')
 
[task_bvp, task_bvp_t] = segment(bvp, bvp_t, t_start, t_end);
[task_rr, task_rr_t] = segment(rr, rr_t, t_start, t_end);
plot_bvp_rr(subj, task, task_bvp, task_bvp_t, task_rr, task_rr_t, t_start, t_end);

function [t_start, t_end] = get_task_time(proj_dir, subj, task_name)
    task_id = strsplit(task_name, '_');
    task_id = char(task_id(1));
    task_id = str2num(task_id(5:end));
    
    % read lab timing file
    fp_in_timing = fullfile(proj_dir, 'lab_timing', sprintf('%s_lab_timing.xlsx', subj));
    [ndata, tdata, ~] = xlsread(fp_in_timing);
    timings = ndata(4:end,1);
    
    computer_os = computer('arch');

    % get date, xlsread date field depends on os
    if startsWith(computer_os, 'mac')
        date = datenum(ndata(3,1)+693960);
    elseif startsWith(computer_os, 'win')
        date = datenum(tdata(5,2));
    end

    t_start = date + timings(1+task_id,1);
    t_end = date + timings(2+task_id,1);
end

function [x_out, x_t_out] = segment(x, x_t, t_start, t_end)
    indices = find(x_t >= t_start & x_t <= t_end);
    x_out = x(indices);
    x_t_out = x_t(indices);
end

function plot_bvp_rr(subj, task, bvp, bvp_t, rr, rr_t, t_start, t_end)
    figure;
    ax1 = subplot(3,1,1);
    plot(bvp_t, bvp, 'b.-', 'MarkerSize',8); 
    xlim([t_start, t_end]);
    datetick('x'); 
    hold on;
    for i=1:length(rr_t)
        line([rr_t(i), rr_t(i)], get(ax1, 'YLim'), 'Color','red','LineStyle',':');
    end
    title(sprintf('%s <%s> ----- bvp', subj, task), 'Interpreter', 'None');
    
    ax2 = subplot(3,1,2);
    plot(rr_t, rr, 'b.-', 'MarkerSize',8); 
    xlim([t_start, t_end]);
    datetick('x'); 
    hold on;
    for i=1:length(rr_t)
        line([rr_t(i), rr_t(i)], get(ax2, 'YLim'),'Color','red','LineStyle',':');
    end
    title(sprintf('%s <%s> ----- rr', subj, task), 'Interpreter', 'None');
    
    ax3 = subplot(3,1,3);
    rr_t_diff = [rr(1); diff(rr_t)*24*3600];
    plot(rr_t, rr_t_diff, 'b.-', 'MarkerSize',8); 
    xlim([t_start, t_end]);
    datetick('x'); 
    hold on;
    for i=1:length(rr_t)
        line([rr_t(i), rr_t(i)], get(ax3, 'YLim'),'Color','red','LineStyle',':');
    end
    title(sprintf('%s <%s> ----- diff(rr_t)', subj, task), 'Interpreter', 'None');
    
    linkaxes([ax1,ax2, ax3],'x');
end

function plot_all(bvp, bvp_t, rr, rr_t)
    t_min = min([min(bvp_t), min(rr_t)]);
    t_max = max([max(bvp_t), max(rr_t)]);
    datetime(t_min,'ConvertFrom','datenum')
    datetime(t_max,'ConvertFrom','datenum')

    figure;
    ax1 = subplot(2,1,1);
    plot(bvp_t, bvp, 'b.-', 'MarkerSize',8); 
    xlim([t_min, t_max]);
    datetick('x'); 

    ax2 = subplot(2,1,2);
    plot(rr_t, rr, 'b.-', 'MarkerSize',8); 
    xlim([t_min, t_max]);
    datetick('x'); 
    
    linkaxes([ax1,ax2],'x');

end