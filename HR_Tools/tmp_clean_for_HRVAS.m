clear all
dir = pwd();
addpath(fullfile(dir, 'HeartRate', 'HR_Tools'));
addpath(fullfile(dir, 'HeartRate', 'HR_Data'));


%fp_in = 'lwp_0019_firstbeat_rr_analysis_raw_data.xlsx';
f_in = 'lwp_0019_msband_rr_analysis_raw_data.xlsx';

% task = 'task 2 relaxing pic 1';
% %task = 'Task 2 Relax Pic 1';
% clean(fp_in, task);


[~, sheet_names] = xlsfinfo(f_in);
num_task = length(sheet_names);
for i = 1:num_task
    task_name = sheet_names(i);
    if strcmp(task_name, 'task 1 relaxing music')
        continue
    end
    disp(task_name);
    clean(f_in, char(task_name));
end
    

   
function clean(file_name, task_name)
    % read rr and rr_t of a task 
    d = xlsread(file_name, task_name);
    RR = d(:,1);
    RR_t = d(:,2);
    
    % poincare plot before cleaning
    plotflag = 1;
    [sd1, sd2] = hr_poincare(RR, plotflag);
    title(sprintf('Subj 19 - Raw data - %s', task_name));
    
    % clean and smoothing
    win = 25; 
    plotflag = 0;
    [RR_t_clean, RR_clean] = hr_clean(RR_t, RR, win, plotflag);

    % poincare plot after cleaning
    plotflag = 1;
    [sd1, sd2] = hr_poincare(RR_clean, plotflag);
     title(sprintf('Subj 19 - Clean data - %s', task_name));

    % write to ibi file
    dir = pwd();
    f_out = fullfile(dir, 'HeartRate', 'HR_Data', sprintf('lwp0019_MSBand_RR_%s.ibi', strrep(task_name, ' ', '')));
    ibi_file = fopen(f_out, 'w');
    fprintf(ibi_file,'%.3f\n', RR_clean./1000);
    fclose(ibi_file);
end


    




