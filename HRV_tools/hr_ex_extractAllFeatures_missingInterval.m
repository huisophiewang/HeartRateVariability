% this script is only for subj09 and subj13, 
% there are large intervals of missing data in their firstbeat

clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

subj = 'LWP2_0013';  
device = 'firstbeat';
data_type = 'raw';
time_format = 'datenum';
% read data
[rr, rr_t] = hr_util_readRR(proj_dir, subj, device, data_type, time_format);

if strcmp(subj,'LWP2_0009')
    idx = find(rr>1.5);
    rr(idx)=1.5;
elseif strcmp(subj,'LWP2_0013')
    idx = find(rr>2);
    rr(idx)=2;
end

figure;
p = plot(rr_t, rr, 'b.-', 'MarkerSize',8); 
datetick('x', 13, 'keepticks');
hold on;
hr_util_addTaskColorToPlot(proj_dir, subj, p, 'firstbeat', time_format);
% hold on;
% t_start_subj09_task04 = datenum([2016,10,21,15,28,30]);
% t_end_subj09_task04 = datenum([2016,10,21,15,36,30]);
% t_start_subj09_task11 = datenum([2016,10,21,15,64,30]);
% line([t_start_subj09_task04 t_start_subj09_task04], [0 1.3]);

win_size = 60/(24*3600);   
win_shift = 15/(24*3600);

t_windows = get_shifted_windows(rr_t(1), rr_t(end), win_size, win_shift);

[t_relax_tasks, t_stress_tasks] = get_selected_tasks_timing(proj_dir, subj, time_format);

data = get_features_and_label(rr, rr_t, t_windows, t_relax_tasks, t_stress_tasks);

data = normalize_features(data);

write_features_and_labels(proj_dir, subj, device, data);

function t_windows = get_shifted_windows(t_start, t_end, window_size, window_shift)
    num_window = floor(((t_end - t_start) - window_size)/ window_shift) + 1;
    t_windows = zeros(num_window, 2);
    for i=1:num_window
        left_bound = t_start + (i-1)* window_shift ;
        right_bound = t_start + (i-1)* window_shift + window_size;
        t_windows(i,1) = left_bound;
        t_windows(i,2) = right_bound;
    end
end

function [t_relax_tasks, t_stress_tasks] = get_selected_tasks_timing(proj_dir, subj, time_format)
    if strcmp(subj,'LWP2_0009')
        relax_tasks = [1,2,11];
    elseif strcmp(subj,'LWP2_0013')
        relax_tasks = [1,2,7,8,11];
    end
    t_relax_tasks = zeros(length(relax_tasks),2);
    for i=1:length(relax_tasks)
        [start_t, end_t] = hr_util_getTaskTiming(proj_dir, subj, relax_tasks(i), time_format);
        t_relax_tasks(i,1) = start_t;
        t_relax_tasks(i,2) = end_t;
    end
    if strcmp(subj,'LWP2_0009')
        t_relax_tasks(3,1) = datenum([2016,10,21,15,64,30]);
    end
    
    if strcmp(subj,'LWP2_0009')
        stress_tasks = [4,14,15,16];
    elseif strcmp(subj,'LWP2_0013')
        stress_tasks = [4,5];        
    end
    t_stress_tasks = zeros(length(stress_tasks),2);
    for i=1:length(stress_tasks)
        [start_t, end_t] = hr_util_getTaskTiming(proj_dir, subj, stress_tasks(i), time_format);
        t_stress_tasks(i,1) = start_t;
        t_stress_tasks(i,2) = end_t;
    end
    if strcmp(subj,'LWP2_0009')
        t_stress_tasks(1,1) = datenum([2016,10,21,15,28,30]);
        t_stress_tasks(1,2) = datenum([2016,10,21,15,36,30]);
    end
end


function mat_data = get_features_and_label(rr, rr_t, t_windows, t_relax_tasks, t_stress_tasks)
    mat_data = [];
    for j=1:length(t_windows)
        t_window = t_windows(j,:);
        t_win_start = t_window(1);
        t_win_end = t_window(2);
        stress = get_stress_label(t_win_start, t_win_end, t_relax_tasks, t_stress_tasks);
        if stress~=-1  
            i_range = find(rr_t >= t_win_start & rr_t <= t_win_end);
            rr_win = rr(i_range);
            rr_t_win = rr_t(i_range);
            
            f = zeros(1,10);
            % time domain
            f(1,1) = get_sdnn(rr_win);
            f(1,2) = get_rmssd(rr_win);
            f(1,3) = get_pNN50(rr_win);
            
            % freq domain
            rr_t_win = rr_t_win.*(24*3600);
            rr_t_win = rr_t_win - rr_t_win(1);
            [lf, hf] = hr_power(rr_win, rr_t_win, 'LS');
            f(1,4) = lf;
            f(1,5) = hf;
            if lf ~=0 && hf ~=0
                f(1,6) = lf/(lf+hf);
            else 
                f(1,6) = 0;
            end
            
            % non-linear 
            [sd1, sd2] = hr_poincare(rr_win, 0);
            f(1,7) = sd1;
            f(1,8) = sd2;
            
            % mean, variance
            f(1,9) = mean(rr_win);
            f(1,10) = var(rr_win);
            
            row = [f, stress];
            mat_data = vertcat(mat_data, row);
        end
    end
end

function stress = get_stress_label(t_win_start, t_win_end, t_relax_tasks, t_stress_tasks)
    stress = -1;
    t_win_center = (t_win_start + t_win_end)/2;
    % check if the window is within relaxation tasks
    for i=1:length(t_relax_tasks)
        t_task = t_relax_tasks(i,:);
        t_task_start = t_task(1);
        t_task_end = t_task(2);
        if (t_win_center>= t_task_start && t_win_center<= t_task_end)
            stress = 0;
            break
        end
    end
    % check if the window is within stress tasks
    for i=1:length(t_stress_tasks)
        t_task = t_stress_tasks(i,:);
        t_task_start = t_task(1);
        t_task_end = t_task(2);
        if (t_win_center>= t_task_start && t_win_center<= t_task_end)
            stress = 1;
            break
        end
    end
end

function data = normalize_features(data)
    num_features = size(data,2)-1;
    for i=1:num_features
        x = data(:,i);
        %figure;
        %histogram(x);
        x_mean = mean(x);
        x_std = std(x);
        z = (x-x_mean)/x_std;
        data(:,i) = z;
    end
end


function write_features_and_labels(proj_dir, subj, device, data)
    f_out = sprintf('%s_lab_%s_stress_features.csv', subj, device);
    subj_data_dir = fullfile(proj_dir, 'HRV', 'HRV_data', subj);
    fp_out = fullfile(subj_data_dir, f_out);
    csvwrite(fp_out, data);
end
    

function sdnn = get_sdnn(rr)
    sdnn = std(rr);
end

function rmssd = get_rmssd(rr)
    rmssd = sqrt(mean(diff(rr).^2));
end

function pNN50 = get_pNN50(rr)
    indices = find(abs(diff(rr))>0.05);
    pNN50 = length(indices)/length(rr);
end