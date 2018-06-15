function [r_clean, t_clean] = hr_clean2(r_in, t_in, nsigma, AR_order, AR_window, ssa_window, plotflag)

% plot input raw signal
if plotflag
    figure, plot(t_in, r_in, 'b.-', 'MarkerSize',8); 
    datetick('x', 'HH:MM:SS'); 
    ylabel('RR (msec)');
    title('original RR signal');
end

% Pass 1: identify extreme outliers using robust variance estimation
[r_var,r_mean, ~] = robustcov(r_in);
r_std = sqrt(r_var);

% mark small r
if plotflag
    i_outliers = find((r_in - r_mean) < -nsigma*r_std); 
    figure, plot(t_in, r_in, 'b.-', 'MarkerSize',8);
    hold on;
    plot(t_in(i_outliers),r_in(i_outliers),'*r')
    datetick('x', 'HH:MM:SS'); 
    ylabel('RR (msec)');
    title('mark small outliers');
end

% remove small r
[r_tmp1, t_tmp1] = hr_remove_shortRR(r_in, t_in, i_outliers);

% mark big r
if plotflag
    i_outliers = find((r_tmp1 - r_mean) > nsigma*r_std);
    figure, plot(t_tmp1, r_tmp1, 'b.-', 'MarkerSize',8);
    hold on;
    plot(t_tmp1(i_outliers), r_tmp1(i_outliers),'*r')
    datetick('x', 'HH:MM:SS'); 
    ylabel('RR (msec)');
    title('mark big outliers');
end

% remove big r
[r_tmp2, t_tmp2, i_imputed] = hr_impute_long_AR(r_tmp1, t_tmp1, i_outliers, AR_order, AR_window);

% plot after pass 1
if plotflag
    figure, plot(t_tmp2, r_tmp2, 'b.-', 'MarkerSize',8); 
    hold on;
    plot(t_tmp2(i_imputed), r_tmp2(i_imputed), 'r.', 'MarkerSize',8);
    datetick('x', 'HH:MM:SS'); 
    ylabel('RR (msec)');
    title('RR signal after removing outliers');
end

t_clean = t_tmp2;
r_clean = r_tmp2;

% Pass 2: identify extreme outliers using SSA smoothing
grp = [1 2 3 4]; % Top eigenfunctions to use in reconstruct_ing smooth version
plotflag = 0;
[r_clean, t_clean, ~]=hr_ssa(r_clean, t_clean, ssa_window, grp, plotflag);   

% plot after pass 2
plotflag = 1;
if plotflag
    figure, plot(t_clean, r_clean, 'b.-', 'MarkerSize',8); 
    datetick('x', 'HH:MM:SS'); 
    ylabel('RR (msec)');
    title('RR signal after SSA smoothing');
end

% TODO?
% For small deviations, use the original values
% but replace large deviations with the xsmooth values
end