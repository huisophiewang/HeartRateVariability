clear all
dir = pwd();
addpath(fullfile(dir, 'HeartRate', 'HR_Tools'));
addpath(fullfile(dir, 'HeartRate', 'HR_Data'));
addpath(fullfile(dir, 'HeartRate', 'HRVAS'));

subj = '0019';
device = 'FirstBeat';
%sdevice = 'MSBand';

% specifiy input output files and folder
f_in = sprintf('tmp_LWP2_%s_%s_RR_raw_data_by_task.xlsx', subj, device);
[~, sheet_names] = xlsfinfo(f_in);
sheet_names = sheet_names(2:end); % start from the 2nd sheet, 1st sheet is empty
dir_out = fullfile(dir, 'HeartRate', 'HR_Data', sprintf('tmp_LWP2_%s_HRVAS', subj));
mkdir(dir_out);
    
IGNORED_TASKS = {'Task4_IAPS'};
for i = 1:length(sheet_names)
    task_name = sheet_names(i);
%     if any(strcmp(task_name, IGNORED_TASKS))
%         continue
%     end
    clean(f_in, dir_out, subj, device, char(task_name));
    disp(task_name);
end
    

   
function clean(f_in, dir_out, subj, device, task_name)
    % read rr and rr_t of a task 
    d = xlsread(f_in, task_name);
    RR = d(:,1);
    RR_t = d(:,2);
    
    % poincare plot before cleaning
    plotflag = 1;
    [sd1, sd2] = hr_poincare(RR, plotflag);
    if plotflag
        title(sprintf('LWP2_%s, %s, %s, Raw Data', subj, device, task_name));
    end
    
    % clean and smoothing
    win = 25; 
    plotflag = 0;
    [RR_t_clean, RR_clean] = hr_clean(RR_t, RR, win, plotflag);

    % poincare plot after cleaning
    plotflag = 0;
    [sd1, sd2] = hr_poincare(RR_clean, plotflag);
    if plotflag
        title(sprintf('LWP2_%s, %s, %s, Clean Data', subj, device, task_name));
    end

    % write to ibi file
    f_out = sprintf('LWP2_%s_%s_RR_%s.ibi', subj, device, strrep(task_name, ' ', ''));
    fp_out = fullfile(dir_out, f_out);
    ibi_file = fopen(fp_out, 'w');
    fprintf(ibi_file,'%.3f\n', RR_clean./1000);
    fclose(ibi_file);
end


    




