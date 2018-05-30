clear all;
dir = pwd();
fp = fullfile(dir, 'HeartRate', 'HR_Data', 'tmp_LWP2_0019_HRVAS', 'LWP2_0019_FirstBeat_RR_Task14_MentalMath.ibi');
% fp = fullfile(dir, 'HeartRate', 'HR_Data', 'tmp_LWP2_0019_HRVAS', 'LWP2_0019_FirstBeat_RR_Task15_Stroop.ibi');
fileID = fopen(fp, 'r');
x = fscanf(fileID, '%f');

% auto_corr_plot(x, 7);

[xc,lags] = xcorr(x,50,'coeff');
figure
stem(lags(51:end),xc(51:end),'filled')
xlabel('Lag')
ylabel('ACF')
title('Sample Autocorrelation Sequence')
grid

p = 25;
[arcoefs,E,K] = aryule(x,p);
pacf = -K;

stem(pacf,'filled')
xlabel('Lag')
ylabel('Partial ACF')
title('Partial Autocorrelation Sequence')
xlim([0 p])
uconf = 1.96/sqrt(1000);
lconf = -uconf;
hold on
plot([0 p],[1 1]'*[lconf uconf],'r')
grid

function auto_corr_plot(x, p)
    x0 = x(1:end-p);
    xp = x(1+p:end);
    plot(x0,xp,'*');
end