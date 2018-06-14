function [r_clean, t_clean] = tmp_hr_clean(r_in, t_in, win, plotflag)

figure, plot(t_in, r_in, 'b.-', 'MarkerSize',8); 
datetick('x', 'HH:MM:SS'); 
ylabel('RR (msec)');
title('original RR signal');

% Pass 1: identify extreme outliers using robust variance estimation
[r_var,r_mean, ~] = robustcov(r_in);
r_std = sqrt(r_var);
nsigma = 2; 

% mark small r
i_outliers = find((r_in - r_mean) < -nsigma*r_std); 
figure, plot(t_in, r_in, 'b.-', 'MarkerSize',8);
hold on;
plot(t_in(i_outliers),r_in(i_outliers),'*r')
datetick('x', 'HH:MM:SS'); 
ylabel('RR (msec)');
title('mark small outliers');

% remove small r
[r_tmp1, t_tmp1] = hr_remove_shortRR(r_in, t_in, i_outliers);

% mark big r
i_outliers = find((r_tmp1 - r_mean) > nsigma*r_std);
figure, plot(t_tmp1, r_tmp1, 'b.-', 'MarkerSize',8);
hold on;
plot(t_tmp1(i_outliers), r_tmp1(i_outliers),'*r')
datetick('x', 'HH:MM:SS'); 
ylabel('RR (msec)');
title('mark big outliers');

% remove big r
AR_order = 10;
AR_window = 250;
[r_tmp2, t_tmp2] = tmp_hr_impute_long(r_tmp1, t_tmp1, i_outliers, AR_order, AR_window);

% after Pass 1
figure, plot(t_tmp2, r_tmp2, 'b.-', 'MarkerSize',8); 
datetick('x', 'HH:MM:SS'); 
ylabel('RR (msec)');
title('RR signal after removing outliers');


% % Pass 2: identify extreme outliers using SSA smoothing
% grp = [1 2, 3, 4]; % [1 2 3 4];Top eigenfunctions to use in reconstruct_ing smooth version
% [RRclean,err,vr,eigf]=hr_ssa(RRclean,win,grp, plotflag);   %  figure; plot(xhat)
% % For small deviations, use the original values
% % but replace large deviations with the xsmooth values

t_clean = t_tmp2;
r_clean = r_tmp2;

end