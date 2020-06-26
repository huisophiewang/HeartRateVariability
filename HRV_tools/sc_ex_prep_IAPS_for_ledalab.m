clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

subj = 'LWP2_0019';

task = 'Task4_IAPS';
subj_dir = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj);
subj_leda_data = fullfile(subj_dir, 'ledalab_data');
if exist(subj_leda_data,'dir')~=7
    mkdir(subj_leda_data);
end
fp_out = fullfile(subj_leda_data, sprintf('%s_sc_IAPS.txt', subj));



image_timings = sc_util_getImageTiming(proj_dir, subj);
[task_start_time, task_end_time] = hr_util_getTaskTiming(proj_dir, subj, 4, 'datenum');

sc_data = xlsread(fullfile(subj_dir, sprintf('%s_lab_e4_sc_by_task.xlsx', subj)), task);
sc = sc_data(:,2);
sc_t = sc_data(:,1);
sc_t = sc_t.*(24*3600) - task_start_time*24*3600;


events = zeros(length(sc), 1);
n = 28;
for i=1:n
    disp('--------------------');
    disp(i);
    idx = find(abs(sc_t - image_timings(i))<0.01);
%     if isempty(idx)
%         disp(i);
%     end
    disp(idx);
    events(idx) = 1;
end



m = horzcat(sc_t, sc, events);
f_id = fopen(fp_out,'w');
format = '%.2f %f %d\n';
fprintf(f_id, format, m.');
fclose(f_id);

