clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

subj = 'LWP2_0019';
task = 'Task14_MentalMath';
%task = 'Task1_RelaxingMusic1';
%task = 'Task10_Biking';

fp_rr = fullfile(proj_dir, 'HRV', 'HRV_data', subj, sprintf('%s_lab_e4_rr_raw_by_task.xlsx', subj));
data_rr= xlsread(fp_rr, task);
rr_t = data_rr(:,1);
rr = data_rr(:,2);

fp_acc = fullfile(proj_dir, 'HRV', 'HRV_data', subj, sprintf('%s_lab_e4_acc_by_task.xlsx', subj));
data_acc = xlsread(fp_acc, task);
acc_t = data_acc(:,1);
acc = data_acc(:,2);

win_start = -10;
win_end = 0;
plot_acc_and_rr(subj, task, rr, rr_t, acc, acc_t, win_start, win_end);
    
function plot_acc_and_rr(subj, task, rr, rr_t, acc, acc_t, win_start, win_end)
    min_t = min([min(rr_t), min(acc_t)]);
    max_t = max([max(rr_t), max(acc_t)]);
    
    figure;
    subplot(3,1,1);
    rr_t_diff = [rr(1); diff(rr_t)*24*3600];
    plot(rr_t, rr_t_diff, 'b.-', 'MarkerSize',8); 
    datetick('x'); 
    xlim([min_t, max_t]);
    ylabel('diff(RR_t) (sec)', 'Interpreter', 'None');
    title(sprintf('%s <%s> ----- diff(RR_t)', subj, task), 'Interpreter', 'None');
    
    subplot(3,1,2);
    plot(acc_t, acc, 'b.-', 'MarkerSize',8); 
    datetick('x'); 
    xlim([min_t, max_t]);
    ylabel('RMSA');
    title(sprintf('%s <%s> ----- RMSA', subj, task), 'Interpreter', 'None');
    
    
    rr_t_diff = [rr(1); diff(rr_t)*24*3600];
    avg_vals = zeros(length(rr_t), 1);
    for i=1:length(rr_t)
        %rr_curr = rr(i);
        t_curr = rr_t(i);
        t_start = t_curr + win_start/(24*3600);
        if t_start > rr_t(1)
            t_end = t_curr + win_end/(24*3600);
            i_range = find(acc_t >= t_start & acc_t <= t_end);
            avg_val = var(acc(i_range));
            avg_vals(i, 1) = avg_val;
        else
            avg_vals(i, 1) = 0;
        end
    end
    indices = find(avg_vals>0);
    
    subplot(3,1,3);
    plot(rr_t(indices), avg_vals(indices), 'b.-', 'MarkerSize',8); 
    datetick('x'); 
    xlim([min_t, max_t]);
    win = win_end - win_start;
    ylabel('variance', 'Interpreter', 'None');
    title(sprintf('%s <%s> ----- variance of RMSA in past %d sec', subj, task, win), 'Interpreter', 'None');
    
   
%     figure;
%     scatter(rr_t_diff(indices), avg_vals(indices));
%     xlabel('diff(RR_t)','Interpreter', 'None');
%     ylabel(sprintf('variance of RMSA in past %d sec', win),'Interpreter', 'None');
end
