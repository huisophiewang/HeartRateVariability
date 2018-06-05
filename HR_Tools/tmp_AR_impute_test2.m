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
num_long_r = round(miss_percent*length(r));
num_long_r = 2;
% simulate_signal_with_miss_values(r, length(AR_coef)-1, num_long_r);

new_r = generate_long_r(r, length(AR_coef)-1, num_long_r);



% generate long intervals by removing 1, 2, or 3 consecutive data points, 
function new_r = generate_long_r(r, AR_order, num_runs)
    while num_runs > 0
        fprintf('--------------------------------\n');
        fprintf('num_runs = %d\n', num_runs);

        % rng(0);
        % remove num_point consecutive data points, could be 1, 2, or 3 points
        num_points = randsample(3, 1)
        fprintf('remove %d consecutive data points\n', num_points);
        % the starting idx to remove data points
        start_idx = randi([AR_order+1, length(r)-(num_points-1)]);
        % the idx that adds the values of previous num_points and becomes the long r
        long_r_idx = start_idx + num_points;
        remove_indices = [];
        for i=1:num_points
            r(long_r_idx) = r(long_r_idx) + r(start_idx + i-1);
            remove_indices = [remove_indices, start_idx + i-1];
        end
        disp(remove_indices);
        
        new_r = r;
        new_r(remove_indices) = []; % remove elements from r
        
        r = new_r;
        num_runs = num_runs - 1;
    end
end

