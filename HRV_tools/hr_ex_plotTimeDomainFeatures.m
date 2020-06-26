%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description:
%   Plot time domain features in shifted windows for the whole lab session of one subject
% Dependencies:
%   external: hr_powerRatio, hr_util_readRR, hr_util_addTaskColorToPlot
%   internal: plot_features, compare_features, get_sdnn, get_rmssd, get_pNN50
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

% set subject
subj = 'LWP2_0019';  
time_format = 'datenum';

% read data
[rr_fb, rr_t_fb] = hr_util_readRR(proj_dir, subj, 'firstbeat', 'cleaned', time_format);
[rr_mb, rr_t_mb] = hr_util_readRR(proj_dir, subj, 'msband', 'raw', time_format);
[rr_e4, rr_t_e4] = hr_util_readRR(proj_dir, subj, 'e4', 'raw', time_format);

%c_raw_fb_mb = xcorr(rr_fb, rr_mb, 'coeff');
%c_raw_fb_e4 = xcorr(rr_fb, rr_e4, 'coeff');

% compute windowed feature
win_size = 60/(24*3600);   
win_shift = 15/(24*3600);
[win_fb, val_fb] = compute_features(rr_fb, rr_t_fb, win_size, win_shift);
[win_mb, val_mb] = compute_features(rr_mb, rr_t_mb, win_size, win_shift);
[win_e4, val_e4] = compute_features(rr_e4, rr_t_e4, win_size, win_shift);


val_e4(isnan(val_e4)) = 0;
val_e4(isnan(val_e4)) = 0;

% set biking task to 0
[start_t, end_t] = hr_util_getTaskTiming(proj_dir, subj, 10, time_format);
indices = find(win_fb>=start_t & win_fb<=end_t);
val_fb(indices,:)=0; 
[start_t, end_t] = hr_util_getTaskTiming(proj_dir, subj, 10, time_format);
indices = find(win_mb>=start_t & win_mb<=end_t);
val_mb(indices,:)=0;
[start_t, end_t] = hr_util_getTaskTiming(proj_dir, subj, 10, time_format);
indices = find(win_e4>=start_t & win_e4<=end_t);
val_e4(indices,:)=0;

%plot_features(proj_dir, subj, win_fb, val_fb, win_e4, val_e4, time_format);
plot_features(proj_dir, subj, win_fb, val_fb, win_mb, val_mb, time_format);

k = min([length(val_fb), length(val_mb),length(val_e4)]);
c1 = xcorr(val_fb(1:k,1)-mean(val_fb(1:k,1)), val_mb(1:k,1)-mean(val_mb(1:k,1)), 'coeff');
[c1, i1] = max(c1);

c2 = xcorr(val_fb(1:k,1)-mean(val_fb(1:k,1)), val_mb(1:k,1)-mean(val_mb(1:k,1)), 0, 'coeff');
c3 = xcorr(val_fb(1:k,1), val_e4(1:k,1), 0, 'coeff');
c4 = corr(val_fb(1:k,1), val_mb(1:k,1));





function plot_features(proj_dir, subj, win_fb, val_fb, win_e4, val_e4, time_format)
    figure;
    subplot(3,1,1);
    p_fb = plot(win_fb, val_fb(:,1), 'b.-', 'MarkerSize',8);
    hold on;
    p_e4 = plot(win_e4, val_e4(:,1), 'r.-', 'MarkerSize',8);
    hr_util_addTaskColorToPlot(proj_dir, subj, [p_fb, p_e4], {'SDNN <Firstbeat>', 'SDNN <E4>'}, time_format);
    datetick('x');
    xlabel('Time'); 
    title(sprintf('%s -- SDNN', subj), 'Interpreter', 'none');
                                                                
    subplot(3,1,2);
    p_fb = plot(win_fb, val_fb(:,2), 'b.-', 'MarkerSize',8);
    hold on;     
    p_e4 = plot(win_e4, val_e4(:,2), 'r.-', 'MarkerSize',8);
    hr_util_addTaskColorToPlot(proj_dir, subj, [p_fb, p_e4], {'RMSSD <Firstbeat>', 'RMSSD <E4>'}, time_format);
    datetick('x');
    xlabel('Time');
    title(sprintf('%s -- RMSSD', subj), 'Interpreter', 'none');
    
    subplot(3,1,3);
    p_fb = plot(win_fb, val_fb(:,3), 'b.-', 'MarkerSize',8);
    hold on;
    p_e4 = plot(win_e4, val_e4(:,3), 'r.-', 'MarkerSize',8);
    hr_util_addTaskColorToPlot(proj_dir, subj, [p_fb, p_e4], {'pNN50 <Firstbeat>', 'pNN50 <E4>'}, time_format);
    datetick('x');
    xlabel('Time');
    title(sprintf('%s -- pNN50', subj), 'Interpreter', 'none');
        
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

