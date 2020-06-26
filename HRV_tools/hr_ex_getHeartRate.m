clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

% set subject
subj = 'LWP2_0019';  
time_format = 'sec';

% read data
[rr_fb, rr_t_fb] = hr_util_readRR(proj_dir, subj, 'firstbeat', 'raw', time_format);
[rr_mb, rr_t_mb] = hr_util_readRR(proj_dir, subj, 'msband', 'raw', time_format);

hr_fb = hr_getHeartRate(rr_fb, rr_t_fb);
hr_mb = hr_getHeartRate(rr_mb, rr_t_mb);


hr_fb = hr_fb - mean(hr_fb);
hr_mb = hr_mb - mean(hr_mb);

a = corr(hr_fb, hr_mb);
b = xcorr(hr_fb, hr_mb, 0, 'coeff');
%c = xcorr(hr_fb, hr_mb, 5, 'coeff');
[c, lag] = xcorr(hr_fb, hr_mb, 'coeff');
figure;
plot(lag, c);
[m, i] = max(c);




% % read data
% [rr_fb, rr_t_fb, rr_mb, rr_t_mb, ~] = hr_util_readTaskRR(proj_dir, subj, task);
% rr_t_mb = hr_util_datenumToSec(rr_t_mb);
% hr_mb = hr_getHeartRate(rr_mb, rr_t_mb);
