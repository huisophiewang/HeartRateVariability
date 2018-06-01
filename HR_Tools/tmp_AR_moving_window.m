clear all
dir = pwd();
fp = fullfile(dir, 'HeartRate', 'HR_Data', 'tmp_LWP2_0019_HRVAS', 'LWP2_0019_FirstBeat_RR_Task14_MentalMath.ibi');
fileID = fopen(fp, 'r');
r = fscanf(fileID, '%f');
n = length(r);
k = 16;
window_size = 140;
window_shift = window_size/2;

% error: Nonseasonal autoregressive polynomial is unstable.
% window1, k<=15
% window2, k<=12
% window3, k<=11

for i=1:floor((n-window_size)/window_shift)
disp(i);
j=i*window_shift;
left_bound = j-window_size/2+1;
right_bound = j+window_size/2;
fprintf('range: %d, %d\n', left_bound, right_bound);
r_windowed = r(left_bound:right_bound);
mdl = arima(k, 0, 0);
est_mdl = estimate(mdl, r_windowed); 
end

