function [rr_clean, rr_t_clean] = hr_clean2(rr_in, rr_t_in, AR_order, AR_window, ssa_window, plotflag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
%   modified based on hr_clean.m by Misha Pavel (m.pavel@northeastern.edu)
% Description: 
%   Data cleaning in the RR space
%   Compute robust standard deviation and
%   remove  too short samples rr - mu <  -nsigma*stdx, adjust remaining
%   Impute too long rr samples using autoregression (AR)
%   Use a SSA based smoothing
% Inputs:
%   rr_in          - a sequence of rr intervals (in seconds)
%   rr_t_in          - timestamps associated with each R event (in matlab time)
%   AR_order      - order of AR for imputing large rr (e.g. AR_order=10)
%   AR_window     - window size of AR for imputing large rr (e.g. AR_window=250)
%   ssa_window    - window size for ssa smoothing and interpolation (e.g. ssa_window=25)
%   plotflag      - logical 1 if plots are desired
% Outputs:
%   rr_clean       - cleaned rr intervals
%   rr_t_clean       - cleaned timestamps associated with each R event 
% Depenndencies: 
%   Matlab: robustcov()
%   external:    hr_findOutliers, hr_removeShortRR2, hr_imputeLong2, hr_ssa     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot input raw signal
if plotflag
    figure, plot(rr_t_in, rr_in, 'b.-', 'MarkerSize',8); 
    datetick('x', 'HH:MM:SS'); 
    ylabel('RR (sec)');
    title('original RR signal');
end

% find short rr
i_short_outliers = hr_findShortOutliers(rr_in, rr_t_in, plotflag);

% remove short rr
[rr_tmp1, rr_t_tmp1] = hr_removeShortRR(rr_in, rr_t_in, i_short_outliers);



% after removing short outliers
if plotflag
    figure, plot(rr_t_tmp1, rr_tmp1, 'b.-', 'MarkerSize',8);
    hold on;
    datetick('x', 'HH:MM:SS'); 
    ylabel('RR (sec)');
    title('after removing small outliers');
end

% find long rr
i_long_outliers = hr_findLongOutliers2(rr_tmp1, rr_t_tmp1, plotflag);

% remove big rr
[rr_tmp2, rr_t_tmp2, i_imputed] = hr_imputeLong2(rr_tmp1, rr_t_tmp1, i_long_outliers, AR_order, AR_window);

% plot after pass 1
if plotflag
    figure, plot(rr_t_tmp2, rr_tmp2, 'b.-', 'MarkerSize',8); 
    hold on;
    plot(rr_t_tmp2(i_imputed), rr_tmp2(i_imputed), 'r.', 'MarkerSize',8);
    datetick('x', 'HH:MM:SS'); 
    ylabel('RR (sec)');
    title('RR signal after removing outliers');
end

rr_t_clean = rr_t_tmp2;
rr_clean = rr_tmp2;
% 
% % Pass 2: identify extreme outliers using SSA smoothing
% grp = [1 2 3 4]; % Top eigenfunctions to use in reconstrucrr_t_ing smooth version
% [rr_clean, rr_t_clean, ~]=hr_ssa(rr_clean, rr_t_clean, ssa_window, grp, plotflag);   
% 
% % plot after pass 2
% if plotflag
%     figure, plot(rr_t_clean, rr_clean, 'b.-', 'MarkerSize',8); 
%     datetick('x', 'HH:MM:SS'); 
%     ylabel('RR (sec)');
%     title('RR signal after SSA smoothing');
% end

% TODO:
% For small deviations, use the original values
% but replace large deviations with the xsmooth values

% when acc is small, use raw rr,
% when acc is big, use cleaned rr
% refer to Misha's slides, acc threshold 0.06~0.07
end