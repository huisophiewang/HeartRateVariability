function [rr_out, rr_t_out, i_imputed] = hr_imputeLong2(rr, rr_t, i_outliers, AR_order, AR_window_size)  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description: 
%   Imputing long rr using autoregression (AR)
%   for each long rr (outlier), first estimate the number of missing R events,
%   then fit AR model using data points around the outlier (set a window),
%   estimate the missing R events using AR coefficients,
%   and multiply by a weight to make sure the sum of imputed values is equal to the outlier.
% Inputs:
%   rr                 - a sequence of rr intervals
%   rr_t               - timestamps associated with each R event
%   i_outliers         - indices of large outliers
%   AR_order           - order of AR model
%   AR_window_size     - number of local data points used to fit the AR model
% Outputs:
%   rr_out             - rr intervals after imputation
%   rr_t_out           - timestamps after imputation
%   i_imputed          - indices of the imputed values
% Dependencies:
%   Matlab: arima
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    i_imputed = [];
    for j=1:length(i_outliers)
        i_start = i_outliers(j);    % index of the outlier
        if i_start <= AR_order
            continue
        end
        rr_long = rr(i_start);   % value of the outlier
        % estimate the number of points to impute based on the previous data point
        num_points = round(rr_long/rr(i_start-1));
        % set AR window, centered at the outlier
        left_bound = i_start - AR_window_size/2;
        right_bound = i_start + AR_window_size/2;
        if left_bound < 1
            left_bound = 1;
            right_bound = 1 + AR_window_size;
        end
        if right_bound > length(rr)
            right_bound = length(rr);
            left_bound = right_bound - AR_window_size;
            if left_bound < 1
                left_bound = 1;
            end
        end
        rr_windowed = rr(left_bound:right_bound);
        % fit AR model 
        [mdl, ~] = estimate(arima(AR_order, 0, 0), rr_windowed); 
        % get AR coefficients
        A = cell2mat(mdl.AR);
        c = mdl.Constant;
        % impute
        rr_imputed_values = []; % imputed values
        for k=1:num_points
            i = i_start+k-1;
            % use both original values of the signal and imputed values
            rr_prev = [rr(i-AR_order : i_start-1).', rr_imputed_values];
            rr_prev = fliplr(rr_prev);
            rr_i = A*rr_prev.' + c;
            rr_imputed_values = [rr_imputed_values, rr_i];
            i_imputed = [i_imputed, i];
            disp(rr_imputed_values);
        end 
        weight = rr_long / sum(rr_imputed_values); 
        % make sure the sum of imputed values is equal to the outlier
        rr_imputed_values = weight * rr_imputed_values;
        % remove the outlier and insert the imputed values
        rr = vertcat(rr(1:i_start-1), rr_imputed_values.', rr(i_start+1:end));
        % outlier indices changed after inserting imputed values
        i_outliers(j+1:end) = i_outliers(j+1:end) + num_points-1;
    end    
    rr_out = rr;
    
    % for E4, t(2)-t(1) = rr(1)
    % rr_t_out = rr_t(1) + [0; cumsum(rr_out(1:end-1))/(24*3600)];
    
    % for firstbeat and msband t(2)-t(1)= rr(2)
    rr_t_out = rr_t(1) + [0; cumsum(rr_out(2:end))/(24*3600)];
    
end