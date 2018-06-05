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
repeat = 1;
err_metric = 'MAE';

% prediction/imputation error computed for repeated samples
errs = zeros(1, length(repeat));
for j=1:repeat
    miss_num = round(miss_percent*length(r));
    miss_indices = random_miss(length(r), length(AR_coef)-1, miss_num);
    r_hat = impute(r, miss_indices, AR_coef);
    % plot_prediction(miss_indices, r_hat, r);
    err = get_prediction_error(r(miss_indices), r_hat, err_metric);
    errs(j) = err;
end
figure, histogram(errs);
title(sprintf('%s, %d runs, %d percent missing data', err_metric, repeat, miss_percent*100));


function err = get_prediction_error(r_actual, r_hat, metric)
    err = 0;
    k = length(r_hat);
    for i=1:k
        if strcmp(metric, 'MSE') || strcmp(metric, 'RMSE')
            err = err + (r_actual(i)-r_hat(i))^2;
        elseif strcmp(metric, 'MAE')
            err = err + abs(r_actual(i)-r_hat(i));
        end
    end
    err = err/k;
    if strcmp(metric, 'RMSE')
        err = sqrt(err);
    end
end


function r_hat = impute(r, miss_indices, AR_coef)
    % rng(0);
    r_hat = zeros(1, length(miss_indices));
    for i=1:length(miss_indices)
        idx = miss_indices(i);
        AR_order = length(AR_coef)-1;
        if idx > AR_order
            r_prev = r(idx-AR_order:idx-1);
            r_prev = fliplr(r_prev);
            r_hat(i) = AR_coef(2:end)*r_prev + AR_coef(1);
        else
            r_hat(i) = 0;
        end
    end
end

function miss_indices = random_miss(signal_length, AR_order, miss_num)
    % sample from indices larger than AR_order
    miss_indices = randi([AR_order+1, signal_length], [1, miss_num]);
    miss_indices = sort(miss_indices);
end

function plot_prediction(miss_indices, r_hat, r)
    figure, plot(r, 'b');
    hold on;
    p1 = plot(miss_indices, r(miss_indices), 'b*');
    p2 = plot(miss_indices, r_hat, 'r*');
    
    for i=1:length(miss_indices)
        idx = miss_indices(i);
        % draw line between points (idx, 0.5) and (idx, r(idx))
        % chose 0.5 as the lower range of r 
        % plot([idx idx], [0.5 r(idx)], 'b:');
        % plot([idx idx], [0.5 r_hat(i)], 'r:');
        plot([idx idx], [r(idx) r_hat(i)], 'r:');
    end
    legend([p1, p2], {'actual value', 'imputed value'});
end