clear all;

% read r
dir = pwd();
fp = fullfile(dir, 'HeartRate', 'HR_Data', 'tmp_LWP2_0019_HRVAS', 'LWP2_0019_FirstBeat_RR_Task14_MentalMath.ibi');
fileID = fopen(fp, 'r');
r = fscanf(fileID, '%f');

% given AR(10) model [constant, a1, ..., a10]
AR_coef = [0.0523    1.0043   -0.0452   -0.1302    0.0540   -0.0672   -0.1204    0.0322    0.0645    0.0183    0.1107];
% set parameters
miss_percent = 0.05;
num_runs = round(miss_percent*length(r));
num_runs = 16;
num_sigma = 4;  % limit for outlier detection
err_metric = 'RMSE';
repeat = 1;

% prediction/imputation error computed for repeated samples
errs = zeros(1, length(repeat));
for n=1:repeat
    % simulate missing value
    r_miss = generate_miss_value_signal(r, length(AR_coef)-1, num_runs);
    % find outliers
    i_outliers = find_outliers(r_miss, num_sigma);    
    [r_imputed, i_imputed] = impute(r_miss, i_outliers, AR_coef);
    [r_imputed, i_imputed] = check_imputation(r_imputed, i_imputed, length(r));
    plot_prediction(i_imputed, r_imputed, r);
    err = get_prediction_error(r(i_imputed), r_imputed(i_imputed), err_metric);
    errs(n) = err;
end
figure, histogram(errs);
title(sprintf('%s, %d runs, %d percent missing data', err_metric, repeat, miss_percent*100));


function [r_imputed, i_imputed] = check_imputation(r_imputed, i_imputed, original_length)
    if length(r_imputed) < original_length
        % if imputed signal is shorter, fill in avg values 
        r_avg = mean(r_imputed);
        r_fill = zeros(1, original_length - length(r_imputed));
        for i=1:length(r_fill)
            r_fill(i)=r_avg;
        end
        r_imputed = vertcat(r_imputed, r_fill.');
    elseif length(r_imputed) > original_length
        % if imputed signal is longer, cut the extra tail
        i_cut = length(i_imputed);
        for i=1:length(i_imputed)
            idx = i_imputed(i);
            if idx > original_length
                i_cut = i-1;
                break
            end
        end
        i_imputed = i_imputed(1:i_cut);
        r_imputed = r_imputed(1:original_length);
    end
end

% recursively impute the first outlier, so that later outliers can
% use previously imputed values if the indices are close
function [r_new, i_imputed] = impute(r, i_outliers, AR_coef)
    AR_order = length(AR_coef)-1; 
    i_imputed = [];
    for j=1:length(i_outliers)
        fprintf('--------------------------------\n');
        % remove the first outlier in i_outliers (smallest index)
        j
        i_start = i_outliers(j)
        ri_long = r(i_start);
        if i_start == length(r)
            local_avg = r(i_start-1);
        else
            local_avg = (r(i_start-1) + r(i_start+1))/2;
        end
        num_points = round(r(i_start)/local_avg)
        ri_values = zeros(1, num_points);
        for k=1:num_points
            i = i_start+k-1;
            r_original = r(i-AR_order : i_start-1).';
            if k==1
                % use only original values to estimate the first point
                r_prev = r_original;
            else
                % use newly estimated values for later points
                r_prev = [r_original, ri_values(1:k-1)];
            end
            r_prev = fliplr(r_prev);
            ri_values(k) = AR_coef(2:end)*r_prev.' + AR_coef(1);
            % maintain the sum of total values
            if k == num_points
                ri_values(k) = ri_long - sum(ri_values(1:k-1));
            end
        end 
        ri_values
        % remove the outlier, and insert the imputed values
        r_new = vertcat(r(1:i_start-1), ri_values.', r(i_start+1:end));
        % for next iteration
        r = r_new;
        test = find_outliers(r, 4);   
        % outlier indices changed after inserting imputed values
        i_outliers(j+1:end) = i_outliers(j+1:end) + num_points-1;
        % save the indices of imputed values
        i_imputed = [i_imputed, (i_start:i_start+num_points-1)];
    end
        
end

function i_outliers = find_outliers(r, num_sigma)
    [r_var,r_mu,~] = robustcov(r);
    r_std = sqrt(r_var);
    i_outliers = find((r - r_mu) > num_sigma*r_std);
end

% generate long intervals by removing 1, 2, or 3 consecutive data points
function r_new = generate_miss_value_signal(r, AR_order, num_runs)
    for j=1:num_runs
        fprintf('--------------------------------\n');
        fprintf('num_runs = %d\n', j);
        % remove num_point consecutive data points, could be 1, 2, or 3 points
        num_points = randsample(3, 1);
        fprintf('remove %d consecutive data points\n', num_points);
        % the starting idx to remove data points, (the last point of r can't be removed
        i_start = randi([AR_order+1, length(r)-num_points])
        % the idx that adds the values of previous num_points and becomes the long r
        i_long = i_start + num_points;
        i_remove = zeros(1, num_points);
        fprintf('before r(i_long) = %f \n', r(i_long));
        for i=1:num_points
            disp(r(i_start + i-1));
            r(i_long) = r(i_long) + r(i_start + i-1);
            i_remove(i) = i_start + i-1;
        end
        disp(i_remove);
        fprintf('after r(i_long) = %f \n', r(i_long));
        % remove elements from r
        r_new = r;
        r_new(i_remove) = []; 
        % for next iteration
        r = r_new;
    end
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