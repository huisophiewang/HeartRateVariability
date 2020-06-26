clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

% set subject
subj = 'LWP2_0019';  
time_format = 'sec';

[rr_fb_raw, rr_t_fb_raw] = hr_util_readRR(proj_dir, subj, 'firstbeat', 'raw', time_format);
[rr_mb_raw, rr_t_mb_raw] = hr_util_readRR(proj_dir, subj, 'msband', 'raw', time_format);

[rr_fb_cln, rr_t_fb_cln] = hr_util_readRR(proj_dir, subj, 'firstbeat', 'cleaned', time_format);
[rr_mb_cln, rr_t_mb_cln] = hr_util_readRR(proj_dir, subj, 'msband', 'cleaned_local_win20_shift1', time_format);

win_size = 240;   
win_shift = 15;
[win_fb_raw, val_fb_raw] = compute_features(rr_fb_raw, rr_t_fb_raw, win_size, win_shift);
[win_mb_raw, val_mb_raw] = compute_features(rr_mb_raw, rr_t_mb_raw, win_size, win_shift);
[win_mb_cln, val_mb_cln] = compute_features(rr_mb_cln, rr_t_mb_cln, win_size, win_shift);

% feature id: 1 - sdnn, 2 - RMSSD, 3 - pNN50
f = 1;

k = min([length(val_fb_raw), length(val_mb_raw), length(val_mb_cln)]);
c1 = xcorr(val_fb_raw(1:k,f)-mean(val_fb_raw(1:k,f)), val_mb_raw(1:k,f)-mean(val_mb_raw(1:k,f)), 'coeff');
c1_max = max(c1);

c2 = xcorr(val_fb_raw(1:k,f)-mean(val_fb_raw(1:k,f)), val_mb_cln(1:k,f)-mean(val_mb_cln(1:k,f)), 'coeff');
c2_max = max(c2);

plot_HRV(proj_dir, subj, win_fb_raw, val_fb_raw, win_mb_raw, val_mb_raw, win_mb_cln, val_mb_cln, f);

function plot_HRV(proj_dir, subj, win_fb, val_fb, win_mb1, val_mb1, win_mb2, val_mb2, f)
    figure;
    subplot(2,1,1);
    p_fb = plot(win_fb, val_fb(:,f), 'b.-', 'MarkerSize',8);
    hold on;
    p_mb1 = plot(win_mb1, val_mb1(:,f), 'r.-', 'MarkerSize',8);
    hr_util_addTaskColorToPlot(proj_dir, subj, [p_fb, p_mb1], {'<Firstbeat>', '<MSBand>'}, 'sec');
    title('firstbeat vs raw msband');
    
    subplot(2,1,2);
    p_fb = plot(win_fb, val_fb(:,f), 'b.-', 'MarkerSize',8);
    hold on;
    p_mb2 = plot(win_mb2, val_mb2(:,f), 'r.-', 'MarkerSize',8);
    hr_util_addTaskColorToPlot(proj_dir, subj, [p_fb, p_mb2], {'<Firstbeat>', '<MSBand>'}, 'sec');
    title('firstbeat vs cleaned msband');
end

function [window_centers, feature_values] = compute_features(rr, rr_t, window_size, window_shift)
    num_window = floor(((rr_t(end) - rr_t(1)) - window_size)/ window_shift) + 1;
    window_centers = zeros(num_window, 1);
    feature_values = zeros(num_window, 3);
    for i=1:num_window
        left_bound = rr_t(1) + (i-1)* window_shift ;
        right_bound = rr_t(1) + (i-1)* window_shift + window_size;
        window_centers(i,1) = (left_bound + right_bound) / 2;
        i_range = find(rr_t >= left_bound & rr_t <= right_bound);
        
        feature_values(i, 1) = get_sdnn(rr(i_range));
        feature_values(i, 2) = get_rmssd(rr(i_range));
        feature_values(i, 3) = get_pNN50(rr(i_range));
    end
end

function sdnn = get_sdnn(rr)
    sdnn = std(rr);
end

function rmssd = get_rmssd(rr)
    rmssd = sqrt(mean(diff(rr).^2));
end

function pNN50 = get_pNN50(rr)
    indices = find(abs(diff(rr))>0.05);
    pNN50 = length(indices)/length(rr);
end