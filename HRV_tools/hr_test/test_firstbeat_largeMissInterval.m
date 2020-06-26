clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

subj = 'LWP2_0009';  
device = 'firstbeat';
data_type = 'raw';
time_format = 'datenum';
% read data
[rr, rr_t] = hr_util_readRR(proj_dir, subj, device, data_type, time_format);

idx = find(rr<1.5);
rr = rr(idx);
rr_t = rr_t(idx);

figure;
p = plot(rr_t, rr, 'b.-', 'MarkerSize',8); 
datetick('x', 13, 'keepticks');
hold on;
hr_util_addTaskColorToPlot(proj_dir, subj, p, 'firstbeat', time_format);