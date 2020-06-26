function [i_long_outliers] = hr_findLongOutliers(rr, rr_t, plotflag)

laplacian = [1 -2 1];
y = conv(rr, laplacian);

% make sure the length of RR and Laplacian match
% set boundary points to 0
y = y(2:end-1);
y(1) = 0;
y(end) = 0;


% negative y
idx_y_neg = find(y<0);
y_neg = y(idx_y_neg);


% box cox transform
[y_neg_trans, lambda_neg] = boxcox(abs(y_neg));


% 3 sigma as outliers
[y_neg_var, y_neg_mu, ~] = robustcov(y_neg_trans);
y_neg_sigma = sqrt(y_neg_var);
idx = find(y_neg_trans > y_neg_mu + 3*y_neg_sigma);
i_long_outliers = idx_y_neg(idx);


% plot outliers in RR and Laplacian
if plotflag
    figure;
    ax1 = subplot(2,1,1);
    plot(rr_t, rr, 'b.-', 'MarkerSize',8); 
    datetick('x');
    hold on;
    plot(rr_t(i_long_outliers), rr(i_long_outliers),'*r');

    ax2 = subplot(2,1,2);
    plot(rr_t, y, 'b.-', 'MarkerSize',8);
    datetick('x');
    hold on;
    plot(rr_t(i_long_outliers), y(i_long_outliers),'*r');

    linkaxes([ax1,ax2],'x');
end

end