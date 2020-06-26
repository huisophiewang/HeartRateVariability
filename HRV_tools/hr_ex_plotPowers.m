%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description:
%   Script to demonstrate the use of hr_powerRatio
%   Plot low frequency power, high frequency power, power ratio in shifted windows for the whole lab session of one subject
% Dependencies:
%   external: hr_power, hr_util_readRR, hr_util_addTaskColorToPlot
%   internal: plot_power, compare_power_plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

% set subject and task
subj = 'LWP2_0019';  

time_format = 'sec';
% read data
[rr_fb, rr_t_fb] = hr_util_readRR(proj_dir, subj, 'firstbeat', 'cleaned', time_format);
%[rr_ms, rr_t_ms] = hr_util_readRR(proj_dir, subj, 'msband', 'cleaned', time_format);
[rr_e4, rr_t_e4] = hr_util_readRR(proj_dir, subj, 'e4', 'raw', time_format);


% set window size and window shift in seconds
window_size = 60;   % lowest freq 0.04 HZ, longest period 1/0.04 = 25 sec, window size should cover longest period
window_shift = 10;

% compute LF and HF power of shifted windows
psd_method = 'LS';
[win_fb, p_fb] = get_window_powers(rr_fb, rr_t_fb, window_size, window_shift, psd_method);
%[win_ms, p_ms] = get_window_powers(rr_ms, rr_t_ms, window_size, window_shift, psd_method);
[win_e4, p_e4] = get_window_powers(rr_e4, rr_t_e4, window_size, window_shift, psd_method);

[start_t, end_t] = hr_util_getTaskTiming(proj_dir, subj, 10, time_format);
indices = find(win_fb>=start_t & win_fb<=end_t);
p_fb(indices,:)=0; 

[start_t, end_t] = hr_util_getTaskTiming(proj_dir, subj, 10, time_format);
indices = find(win_e4>=start_t & win_e4<=end_t);
p_e4(indices,:)=0;

plot_powers(proj_dir, subj, win_fb, p_fb, win_e4, p_e4, time_format);
plot_power_ratios(proj_dir, subj, win_fb, p_fb, win_e4, p_e4, time_format);

% % compute correlation of powers in shifted windows between fb_raw and ms_cleaned
k = min([length(p_fb), length(p_e4)]);
corr_pr_fb_e4 = xcorr(p_fb(1:k,3), p_e4(1:k,3), 0, 'coeff');
corr_lf_fb_e4 = xcorr(p_fb(1:k,1), p_e4(1:k,1), 0, 'coeff');
corr_hf_fb_e4 = xcorr(p_fb(1:k,2), p_e4(1:k,2), 0, 'coeff');

% function plot_psd()
%     figure;
%     plot(freq(2:end), psd(2:end));
%     title('PSD estimated by FFT');
%     xlabel('Frequency (Hz)');
% end

function plot_powers(proj_dir, subj, win_fb, p_fb, win_e4, p_e4, time_format)
    figure;
    subplot(2,1,1);
    p_low = plot(win_fb, p_fb(:,1), 'r.-', 'MarkerSize',8);
    hold on;
    p_high = plot(win_fb, p_fb(:,2), 'b.-', 'MarkerSize',8);
    hr_util_addTaskColorToPlot(proj_dir, subj, [p_low, p_high], {'LF power', 'HF power'}, time_format);
    title(sprintf('%s -- Powers <firstbeat>', subj), 'Interpreter', 'none');
    
    subplot(2,1,2);
    p_low = plot(win_e4, p_e4(:,1), 'r.-', 'MarkerSize',8);
    hold on;
    p_high = plot(win_e4, p_e4(:,2), 'b.-', 'MarkerSize',8);
    hr_util_addTaskColorToPlot(proj_dir, subj, [p_low, p_high], {'LF power', 'HF power'}, time_format);
    title(sprintf('%s -- Powers <E4>', subj), 'Interpreter', 'none');
end

function plot_power_ratios(proj_dir, subj, win_fb, p_fb, win_e4, p_e4, time_format)
    figure;
    subplot(2,1,1);
    plt_fb = plot(win_fb, p_fb(:,3), 'm.-', 'MarkerSize',8);
    hold on;
    hr_util_addTaskColorToPlot(proj_dir, subj, plt_fb, 'power ratio <firstbeat>', time_format);
    title(sprintf('%s -- Power Ratio <firstbeat>', subj), 'Interpreter', 'none');
    
    subplot(2,1,2);
    plt_e4 = plot(win_e4, p_e4(:,3), 'm.-', 'MarkerSize',8);
    hold on;
    hr_util_addTaskColorToPlot(proj_dir, subj, plt_e4, 'power ratio <E4>', time_format);
    title(sprintf('%s -- Power Ratio <E4>', subj), 'Interpreter', 'none');

end


function [window_centers, window_powers] = get_window_powers(rr, rr_t, window_size, window_shift)
    % compute number of shifted windows, (signal_duration - window_size)/window_shift + 1
    if (rr_t(end) - rr_t(1)) <= window_size
        num_window = 1;
    else
        num_window = floor(((rr_t(end) - rr_t(1)) - window_size)/ window_shift) + 1;
    end
    
    window_centers = zeros(num_window, 1);
    window_powers = zeros(num_window, 3);
    
    % create shifted windows and compute power for each window
    for i=1:num_window
        left_bound = (i-1)* window_shift ;
        right_bound = (i-1)* window_shift + window_size;
        window_centers(i,1) = (left_bound + right_bound) / 2;
        indices = find(rr_t >= left_bound & rr_t <= right_bound);
        if ~isempty(indices)
            [LF_power, HF_power] = hr_power(rr(indices), rr_t(indices));
            window_powers(i,1) = LF_power;
            window_powers(i,2) = HF_power;
            if LF_power ~=0 && HF_power ~=0
                window_powers(i,3) = LF_power/(LF_power + HF_power);
            end
        end
    end
        
end

