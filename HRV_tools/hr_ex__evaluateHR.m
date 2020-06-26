clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

% set subject
subj = 'LWP2_0019';  
time_format = 'sec';

[rr_fb_raw, rr_t_fb_raw] = hr_util_readRR(proj_dir, subj, 'firstbeat', 'raw', time_format);
[rr_mb_raw, rr_t_mb_raw] = hr_util_readRR(proj_dir, subj, 'msband', 'raw', time_format);

[rr_fb_cln, rr_t_fb_cln] = hr_util_readRR(proj_dir, subj, 'firstbeat', 'cleaned', time_format);
[rr_mb_cln, rr_t_mb_cln] = hr_util_readRR(proj_dir, subj, 'msband', 'cleaned_local_win30_shift1', time_format);


hr_fb_raw = hr_getHeartRate(rr_fb_raw, rr_t_fb_raw);
hr_mb_raw = hr_getHeartRate(rr_mb_raw, rr_t_mb_raw);
c_fb_mb_raw = xcorr(hr_fb_raw, hr_mb_raw, 'coeff');
c_fb_mb_raw_max = max(c_fb_mb_raw);

hr_mb_cln = hr_getHeartRate(rr_mb_cln, rr_t_mb_cln);
k = min([length(hr_fb_raw), length(hr_mb_cln)]);
c_fb_mb_cln = xcorr(hr_fb_raw(1:k), hr_mb_cln(1:k), 'coeff');
c_fb_mb_cln_max = max(c_fb_mb_cln);



%compare_RR(rr_fb_raw, rr_t_fb_raw, rr_mb_cln, rr_t_mb_cln, 'msband cleaned');
compare_HR(hr_fb_raw, hr_mb_raw);
compare_HR(hr_fb_raw, hr_mb_cln);

function compare_RR(rr_fb, rr_t_fb, rr, rr_t, title_str)
    figure;
    ax1 = subplot(2,1,1);
    
    plot(rr_t, rr, 'r', 'MarkerSize',8); h
    hold on;
    plot(rr_t_fb, rr_fb, 'b', 'MarkerSize',8); 
    ylabel('RR (sec)');
    title('FirstBeat Raw RR');
    
    ax2 = subplot(2,1,2);
    plot(rr_t, rr, 'r', 'MarkerSize',8); 
    ylabel('RR (sec)');
    title(title_str, 'Interpreter', 'None');
    
    linkaxes([ax1,ax2],'xy');
end

function compare_HR(hr_fb, hr)
    len = min([length(hr_fb), length(hr)]);
    f = 4;
    t = [0:(len-1)];
    figure;
    ax1 = subplot(2,1,1);
    plot(hr_fb, 'b');
    
    ax2 = subplot(2,1,2);
    plot(hr, 'r')
    linkaxes([ax1,ax2],'xy')
end

