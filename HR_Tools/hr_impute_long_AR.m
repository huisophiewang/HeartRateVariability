% estimate missing data using AR
function [r_out, t_out, i_imputed] = hr_impute_long_AR(r, t, i_outliers, AR_order, AR_window_size)  
    i_imputed = [];
    for j=1:length(i_outliers)
        i_start = i_outliers(j);    % index of the outlier
        if i_start <= AR_order
            continue
        end
        ri_long = r(i_start);   % value of the outlier
        % estimate the number of points to impute based on the previous data point
        num_points = round(ri_long/r(i_start-1));
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
            if left_bound < 1
                left_bound = 1;
            end
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
            disp(r_imputed_values);
        end 
        weight = ri_long / sum(r_imputed_values); 
        % make sure the sum of imputed values is equal to the outlier
        r_imputed_values = weight * r_imputed_values;
        % remove the outlier and insert the imputed values
        r = vertcat(r(1:i_start-1), r_imputed_values.', r(i_start+1:end));
        % outlier indices changed after inserting imputed values
        i_outliers(j+1:end) = i_outliers(j+1:end) + num_points-1;
    end    
    r_out = r;
    t_out = t(1) + cumsum(r_out)/(1000*24*3600);
    
end