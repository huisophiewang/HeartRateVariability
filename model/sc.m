clear all;
[cur_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('model')
proj_dir = fullfile(cur_dir, '..', '..'); % ('HRV')

% set subject and task
subj = 'S15'; 
fname = sprintf('%s_EDA.csv', subj);
fp = fullfile(proj_dir, 'data', 'WESAD', subj, fname);

m = dlmread(fp);
t = m(:,1);
eda = m(:,2);

figure;
p_eda = plot(t, eda);
title(sprintf('Subj %s ', subj));
xlabel('t (sec)');
ylabel('skin conductance (uS)');

f_time = fullfile(proj_dir, 'data', 'WESAD', subj, sprintf('%s_timing.csv', subj));
timing = readtable(f_time);
add_task_color(timing, p_eda, 'EDA');

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