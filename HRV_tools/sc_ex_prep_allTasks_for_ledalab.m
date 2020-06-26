clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

subj = 'LWP2_0019';

subj_dir = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj);

subj_leda_data = fullfile(subj_dir, 'ledalab_data');
if exist(subj_leda_data,'dir')~=7
    mkdir(subj_leda_data);
end
fp_out = fullfile(subj_leda_data, sprintf('%s_sc_all.txt', subj));

% read sc data
fp_in_data = fullfile(subj_dir, sprintf('%s_lab_data.mat', subj));
load(fp_in_data); 
sc = e4_left_sc;
sc_t = e4_left_sc_t;


% read task timing
fp_in_timing = fullfile(subj_dir, sprintf('%s_lab_timing.xlsx', subj));
[ndata, tdata, ~] = xlsread(fp_in_timing);
computer_os = computer('arch');
if startsWith(computer_os, 'mac')
    date = datenum(ndata(3,1)+693960);
elseif startsWith(computer_os, 'win')
    date = datenum(tdata(5,2));
end

e4_start_time = date + ndata(26,1);
task_timings = date + ndata(4:23,1);
task_timings = (task_timings - e4_start_time)*24*3600;
image_timings = date + ndata(:,7); 
image_timings = (image_timings - e4_start_time)*24*3600;
sc_t = sc_t.*(24*3600) - e4_start_time*24*3600;

events = zeros(length(sc), 1);
for i=1:length(sc)
    if find(abs(task_timings-sc_t(i))<0.01)
        events(i,1) = 1;
    elseif find(abs(image_timings-sc_t(i))<0.01)
        events(i,1) = 2;
    end
end

m = horzcat(sc_t, sc, events);
f_id = fopen(fp_out,'w');
format = '%.2f %f %d\n';
fprintf(f_id, format, m.');
fclose(f_id);



