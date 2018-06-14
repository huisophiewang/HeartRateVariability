clear all
dir = pwd();
addpath(fullfile(dir, 'HeartRate', 'HR_Tools'));
addpath(fullfile(dir, 'HeartRate', 'HR_Data'));
addpath(fullfile(dir, 'HeartRate', 'HRVAS'));

subj = '0019';
%device = 'FirstBeat';
device = 'MSBand';

% specifiy input output files and folder
f_in = sprintf('tmp_LWP2_%s_%s_RR_raw_data_by_task.xlsx', subj, device);
[~, sheet_names] = xlsfinfo(f_in);
sheet_names = sheet_names(2:end); % start from the 2nd sheet, 1st sheet is empty
dir_out = fullfile(dir, 'HeartRate', 'HR_Data', sprintf('tmp_LWP2_%s_HRVAS', subj));
mkdir(dir_out);


%     'Task1_RelaxingMusic1'
%     'Task2_RelaxingPic1'
%     'Task3_EMA1'
%     'Task4_IAPS'
%     'Task5_StressPic1'
%     'Task6_EMA2'
%     'Task7_RelaxingMusic2'
%     'Task8_RelaxingPic2'
%     'Task9_EMA3'
%     'Task10_Biking'
%     'Task11_RelaxingMusic3'
%     'Task12_NeutralPic'
%     'Task13_EMA4'
%     'Task14_MentalMath'
%     'Task15_Stroop'
%     'Task16_StressPic2'
%     'Task17_EMA5'
%     'Task18_March'


%IGNORED_TASKS = {'Task1_RelaxingMusic1', 'Task2_RelaxingPic1', 'Task3_EMA1', 'Task4_IAPS'};
TEST_TASKS = {'Task14_MentalMath'};
for i = 1:length(sheet_names)
    task_name = sheet_names(i);
    fprintf('--------------------------------\n');
    fprintf('%s started\n', char(task_name));
%     if any(strcmp(task_name, IGNORED_TASKS))
%         continue
%     end
    if any(strcmp(task_name, TEST_TASKS))
        clean(f_in, dir_out, subj, device, char(task_name));
    end
    fprintf('%s finished\n', char(task_name));
end
    
 
function clean(f_in, dir_out, subj, device, task_name)
    % read rr and rr_t of a task 
    d = xlsread(f_in, task_name);
    RR = d(:,1);
    RR_t = d(:,2);
    
    % poincare plot before cleaning
    plotflag = 0;
    [sd1, sd2] = hr_poincare(RR, plotflag);
    if plotflag
        title(sprintf('LWP2_%s, %s, %s, Raw Data', subj, device, task_name));
    end
    
    % clean and smoothing
    win = 25; 
    plotflag = 1;
    [RR_clean, RR_t_clean] = tmp_hr_clean(RR, RR_t, win, plotflag);

    % poincare plot after cleaning
%     plotflag = 0;
%     [sd1, sd2] = hr_poincare(RR_clean, plotflag);
%     if plotflag
%         title(sprintf('LWP2_%s, %s, %s, Clean Data', subj, device, task_name));
%     end

%     % write to ibi file
%     f_out = sprintf('LWP2_%s_%s_RR_%s.ibi', subj, device, strrep(task_name, ' ', ''));
%     fp_out = fullfile(dir_out, f_out);
%     ibi_file = fopen(fp_out, 'w');
%     fprintf(ibi_file,'%.3f\n', RR_clean./1000);
%     fclose(ibi_file);
end


    




