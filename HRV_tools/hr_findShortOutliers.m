function [i_short_outliers] = hr_findShortOutliers(rr, rr_t, plotflag)



win_size = 90;
win_shift = 1;
nsigma = 3;
i_short_outliers = [];

num_window = floor(((rr_t(end) - rr_t(1)) - win_size)/ win_shift) + 1;
window_centers = zeros(num_window, 1);
for i=1:num_window
    left_bound = rr_t(1) + (i-1)* win_shift ;
    right_bound = rr_t(1) + (i-1)* win_shift + win_size;
    window_centers(i,1) = (left_bound + right_bound) / 2;
    i_range = find(rr_t >= left_bound & rr_t <= right_bound);
    rr_local = rr(i_range);
    [var_local, mean_local, ~] = robustcov(rr_local);
    std_local = sqrt(var_local);
    i_out = find((rr_local - mean_local) < -nsigma*std_local);
    i_out = i_out + i_range(1) - 1;
    i_short_outliers = union(i_short_outliers, i_out);
end

i_impossible = find(rr < 0.3);
i_short_outliers = union(i_short_outliers, i_impossible);

if plotflag
    figure;
    plot(rr_t, rr, 'b.-', 'MarkerSize',8); 
    datetick('x');
    hold on;
    plot(rr_t(i_short_outliers), rr(i_short_outliers),'*r');
end

end


