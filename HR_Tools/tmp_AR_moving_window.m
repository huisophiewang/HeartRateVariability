clear all
dir = pwd();
fp = fullfile(dir, 'HeartRate', 'HR_Data', 'tmp_LWP2_0019_HRVAS', 'LWP2_0019_FirstBeat_RR_Task14_MentalMath.ibi');
fileID = fopen(fp, 'r');
r = fscanf(fileID, '%f');
n = length(r);
k = 9;
window_size = 60;
window_shift = 30;

% error: Nonseasonal autoregressive polynomial is unstable.
% window1, k<=15
% window2, k<=12
% window3, k<=11

for i=0:floor(n/window_shift)-1
    disp(i)
j=i*window_shift;
r_windowed = r(j+1:j+window_size);
mdl = arima(k, 0, 0);
est_mdl = estimate(mdl, r_windowed); 
end

