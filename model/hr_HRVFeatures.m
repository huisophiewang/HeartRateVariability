clear all;
[cur_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('model')
proj_dir = fullfile(cur_dir, '..', '..'); % ('HRV')


% set subject and task
subj = 'S17'; 
fname = sprintf('%s_RR.csv', subj);
fp = fullfile(proj_dir, 'data', 'WESAD', subj, fname);

m = dlmread(fp);
rr_t = m(:,1);
rr = m(:,2);

window_size = 60;   % lowest freq 0.04 HZ, longest period 1/0.04 = 25 sec, window size should cover longest period
window_shift = 10;

psd_method = 'LS';
[win_f, f_features] = get_freq_features(rr, rr_t, window_size, window_shift, psd_method);
[win_t, t_features] = get_time_features(rr, rr_t, window_size, window_shift);

f_time = fullfile(proj_dir, 'data', 'WESAD', subj, sprintf('%s_timing.csv', subj));
timing = readtable(f_time);
plot_features(subj, timing, rr_t, rr, win_f, f_features, win_t, t_features);



function [window_centers, window_powers] = get_freq_features(rr, rr_t, window_size, window_shift, psd_method)
    % compute number of shifted windows, (signal_duration - window_size)/window_shift + 1
    if (rr_t(end) - rr_t(1)) <= window_size
        num_window = 1;
    else
        num_window = floor(((rr_t(end) - rr_t(1)) - window_size)/ window_shift) + 1;
    end
    
    window_centers = zeros(num_window, 1);
    window_powers = zeros(num_window, 3);
    
    % create shifted windows and compute power for each window
    for i=1:num_window
        left_bound = (i-1)* window_shift ;
        right_bound = (i-1)* window_shift + window_size;
        window_centers(i,1) = (left_bound + right_bound) / 2;
        i_range = find(rr_t >= left_bound & rr_t <= right_bound);
        if ~isempty(i_range)
            [LF_power, HF_power] = hr_power(rr(i_range), rr_t(i_range), psd_method);
            window_powers(i,1) = LF_power;
            window_powers(i,2) = HF_power;
            if LF_power ~=0 && HF_power ~=0
                window_powers(i,3) = LF_power/(LF_power + HF_power);
            end
        end
    end
        
end

function [window_centers, feature_values] = get_time_features(rr, rr_t, window_size, window_shift)
    num_window = floor(((rr_t(end) - rr_t(1)) - window_size)/ window_shift) + 1;
    window_centers = zeros(num_window, 1);
    feature_values = zeros(num_window, 3);
    for i=1:num_window
        left_bound = rr_t(1) + (i-1)* window_shift ;
        right_bound = rr_t(1) + (i-1)* window_shift + window_size;
        window_centers(i,1) = (left_bound + right_bound) / 2;
        i_range = find(rr_t >= left_bound & rr_t <= right_bound);
        
        feature_values(i, 1) = get_sdnn(rr(i_range));
        feature_values(i, 2) = get_rmssd(rr(i_range));
        feature_values(i, 3) = get_pNN50(rr(i_range));
    end
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


function plot_features(subj, timing, rr_t, rr, win_f, f_features, win_t, t_features)
    figure;
    ax1 = subplot(5,1,1);
    p_rr = plot(rr_t, rr);
    add_task_color(timing, p_rr, 'RR');
    ylabel('RR (sec)');
    xlabel('t (sec)');
    title(sprintf('Subj %s ', subj), 'Interpreter', 'none');
    
    ax2 = subplot(5,1,2);
    p_low = plot(win_f, f_features(:,1), 'r.-', 'MarkerSize',8);
    hold on;
    p_high = plot(win_f, f_features(:,2), 'b.-', 'MarkerSize',8);
    add_task_color(timing, [p_low, p_high], {'LF power', 'HF power'});
    ylabel('LF & HF power');
    xlabel('t (sec)');
    
    ax3 = subplot(5,1,3);
    p_power_ratio = plot(win_f, f_features(:,3), 'm.-', 'MarkerSize',8);
    add_task_color(timing, p_power_ratio, 'LF/(LF+HF)');
    ylabel('Power Ratio');
    xlabel('t (sec)');
    
    ax4 = subplot(5,1,4);
    p_sdnn = plot(win_t, t_features(:,1), 'b.-', 'MarkerSize',8);
    add_task_color(timing, p_sdnn, 'SDNN');
    ylabel('SDNN');
    xlabel('t (sec)');
    
    ax5 = subplot(5,1,5);
    p_rmssd = plot(win_t, t_features(:,2), 'b.-', 'MarkerSize',8);
    add_task_color(timing, p_rmssd, 'RMSSD');
    ylabel('RMSSD');
    xlabel('t (sec)');
    
    linkaxes([ax1, ax2, ax3, ax4, ax5],'x')
    
end

function add_task_color(t, main_plot_objs, main_legend_names)
    hold on;
    
    grey = [0.7 0.7 0.7];   % neutral
    blue = [0.5 0.7 1.0];   % meditation
    pink = [1 0.5 0.5];     % stress
    yellow = [1 1 0.5];     % fun
    
    y_range = get(gca,'YLim');
    min_h = y_range(1);
    max_h = y_range(2);
    
    p_base = fill_task_with_color(t.Base(1), t.Base(2), min_h, max_h, grey);
    p_stress = fill_task_with_color(t.TSST(1), t.TSST(2), min_h, max_h, pink);
    p_fun = fill_task_with_color(t.Fun(1), t.Fun(2), min_h, max_h, yellow);
    p_medi1 = fill_task_with_color(t.Medi1(1), t.Medi1(2), min_h, max_h, blue);
    p_medi2 = fill_task_with_color(t.Medi2(1), t.Medi2(2), min_h, max_h, blue);
    
    plot_objs = [main_plot_objs, [p_base, p_fun, p_medi1, p_stress]];
    legend_names = [main_legend_names, {'Baseline', 'Amusement', 'Meditation', 'TSST stress'}];
    legend(plot_objs, legend_names);
end

function p = fill_task_with_color(start_t, end_t, min_h, max_h, color)
    p = fill([start_t, end_t, end_t, start_t], [min_h, min_h, max_h, max_h], color, 'FaceAlpha', 0.2, 'LineStyle', ':');
end

