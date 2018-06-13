clear all;

% read r
dir = pwd();
fp = fullfile(dir, 'HeartRate', 'HR_Data', 'tmp_LWP2_0019_HRVAS', 'LWP2_0019_FirstBeat_RR_Task14_MentalMath.ibi');
fileID = fopen(fp, 'r');
r_original = fscanf(fileID, '%f');

% set parameters
AR_order = 10;  
AR_window_size = 280; % 2~3 min
num_runs = 16;  % number of times to remove data points
max_points = 1;  % maximum number of consecutive points removed each run
num_sigma = 4;  % limit for outlier detection
err_metric = 'MAE';
repeat = 1;   % repeat times to get the distribution of error

errs = zeros(1, length(repeat));
for n=1:repeat
    fprintf('---------------- repeat=%d ----------------\n', n);
    % simulate missing value
    r_miss = generate_miss_value_signal(r_original, AR_order, num_runs, max_points);
    % find outliers that are outside the range of num_sigma 
    i_outliers = find_outliers(r_miss, num_sigma);    
    % imputation
    [r_imputed, i_imputed] = impute(r_miss, i_outliers, AR_order, AR_window_size);
    % check imputed signal length
    if length(r_imputed) ~= length(r_original)
        error('imputed signal length (%d) differs from original signal length (%d) \n', length(r_imputed), length(r_original));
    end
    % plot original signal and imputed signal together
    plot_prediction(i_imputed, r_imputed, r_original);
    % imputation error
    err = get_prediction_error(r_original(i_imputed), r_imputed(i_imputed), err_metric);
    errs(n) = err;
end
% plot imputation error computed for repeated samples
figure, histogram(errs);
title(sprintf('%s, %d repeats', err_metric, repeat));


% estimate missing data using AR  
function [r, i_imputed] = impute(r, i_outliers, AR_order, AR_window_size)
    i_imputed = [];
    for j=1:length(i_outliers)
        fprintf('---------------- j=%d ----------------\n', j);
        i_start = i_outliers(j);    % index of the outlier
        ri_long = r(i_start);   % value of the outlier
        % estimate the number of points to impute based on the previous data point
        num_points = round(ri_long/r(i_start-1)) 
        if num_points ~= 2
            fprintf('num_points=%d, i_start=%d, ri_long=%f, r(i_start-1)=%f \n', num_points, i_start, ri_long, r(i_start-1));
        end
        % set AR window
        left_bound = i_start - AR_window_size/2;
        right_bound = i_start + AR_window_size/2;
        if left_bound < 1
            left_bound = 1;
            right_bound = 1 + AR_window_size;
        end
        if right_bound > length(r)
            right_bound = length(r);
            left_bound = right_bound - AR_window_size;
        end
        r_windowed = r(left_bound:right_bound);
        % fit AR model 
        [mdl, ~] = estimate(arima(AR_order, 0, 0), r_windowed); 
        % get AR coefficients
        A = cell2mat(mdl.AR);
        c = mdl.Constant;
        % impute
        r_imputed_values = []; % imputed values
        for k=1:num_points
            i = i_start+k-1;
            % use both original values of the signal and imputed values
            r_prev = [r(i-AR_order : i_start-1).', r_imputed_values];
            r_prev = fliplr(r_prev);
            ri = A*r_prev.' + c;
            r_imputed_values = [r_imputed_values, ri];
            i_imputed = [i_imputed, i];
            fprintf('sum of imputed ri  = %f \n', sum(r_imputed_values));
        end 
        weight = ri_long / sum(r_imputed_values); 
        % make sure the sum of imputed values is equal to the outlier
        r_imputed_values = weight * r_imputed_values;
        % remove the outlier and insert the imputed values
        r = vertcat(r(1:i_start-1), r_imputed_values.', r(i_start+1:end));
        % outlier indices changed after inserting imputed values
        i_outliers(j+1:end) = i_outliers(j+1:end) + num_points-1;
    end    
end


% generate long intervals by removing at most max_points consecutive data points
function r = generate_miss_value_signal(r, AR_order, num_runs, max_points)
    for j=1:num_runs
        fprintf('--------------------------------\n');
        fprintf('num_runs = %d\n', j);
        % remove num_point consecutive data points
        num_points = randsample(max_points, 1);
        fprintf('remove %d consecutive data points\n', num_points);
        % the starting idx to remove data points
        i_start = randi([AR_order+1, length(r)-num_points])
        % the idx that becomes the outlier
        i_long = i_start + num_points;
        i_remove = zeros(1, num_points);
        for i=1:num_points
            disp(r(i_start + i-1));
            r(i_long) = r(i_long) + r(i_start + i-1);
            i_remove(i) = i_start + i-1;
        end
        disp(i_remove);
        fprintf('r(i_long) = %f \n', r(i_long));
        % remove elements from r
        r(i_remove) = []; 
    end
end


function i_outliers = find_outliers(r, num_sigma)
    [r_var,r_mu,~] = robustcov(r);
    r_std = sqrt(r_var);
    i_outliers = find((r - r_mu) > num_sigma*r_std);
end


function plot_prediction(i_imputed, r_imputed, r)
    figure, plot(r, 'b.-', 'MarkerSize',8);
    hold on;
    p1 = plot(i_imputed, r(i_imputed), 'b.', 'MarkerSize',8);
    p2 = plot(i_imputed, r_imputed(i_imputed), 'r.', 'MarkerSize',8);
    
    for i=1:length(i_imputed)
        idx = i_imputed(i);
        % draw line between points (idx, r(idx)) and (idx, r_imputed(idx))
        plot([idx idx], [r(idx) r_imputed(idx)], 'r:');
    end
    legend([p1, p2], {'actual value', 'imputed value'});
end

function err = get_prediction_error(r_actual, r_estimate, metric)
    err = 0;
    k = length(r_estimate);
    for i=1:k
        if strcmp(metric, 'MSE') || strcmp(metric, 'RMSE')
            err = err + (r_actual(i)-r_estimate(i))^2;
        elseif strcmp(metric, 'MAE')
            err = err + abs(r_actual(i)-r_estimate(i));
        end
    end
    err = err/k;
    if strcmp(metric, 'RMSE')
        err = sqrt(err);
    end
end