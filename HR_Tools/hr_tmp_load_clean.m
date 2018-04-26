clear all
dir = pwd();
addpath(fullfile(dir, 'HeartRate', 'HR_Tools'));
addpath(fullfile(dir, 'HeartRate', 'HR_Data'));


fp_in = 'lwp_0019_firstbeat_rr_analysis_raw_data.xlsx';
task = 'Task 1 Relax Music';
clean(dir, fp_in, task);


% [~, sheet_names] = xlsfinfo(fp_in);
% num_task = length(sheet_names);
% for i = 1:num_task
%     task_name = sheet_names(i);
%     clean(fp_in, task_name);
    

   
function clean(dir, file_name, task_name)
    % read rr and rr_t of a task 
    d = xlsread(file_name, task_name);
    RR = d(:,1);
    RR_t = d(:,2);
    
    % poincare plot before cleaning
    plotflag = 1;
    [sd1, sd2] = hr_poincare(RR, plotflag);
    title('Subj 19 - Raw data', 'Interpreter', 'none');
    
    % clean and smoothing
    win = 25; 
    plotflag = 0;
    [RR_t_clean, RR_clean] = hr_clean(RR_t, RR, win, plotflag);

    % poincare plot after cleaning
    plotflag = 1;
    [sd1, sd2] = hr_poincare(RR_clean, plotflag);
    title('Subj 19 - Clean Data', 'Interpreter', 'none');

    % write to ibi file
    
    fp_out = fullfile(dir, 'HeartRate', 'HR_Data', sprintf('lwp0019_FirstBeat_RR_%s.ibi', strrep(task_name, ' ', '')));
    ibi_file = fopen(fp_out, 'w');
    fprintf(ibi_file,'%.3f\n', RR_clean./1000);
    fclose(ibi_file);
end


    




