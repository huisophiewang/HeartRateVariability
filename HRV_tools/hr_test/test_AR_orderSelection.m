%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description:
%   Decide the order of AR to use
%   based on Matlab exmple: AR order selection with partial autocorrelation
%   https://www.mathworks.com/help/signal/ug/ar-order-selection-with-partial-autocorrelation-sequence.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')
fp = fullfile(proj_dir, 'HRV', 'HRV_data', 'LWP2_0019', 'LWP2_0019_lab_firstbeat_rr_raw_Task14_MentalMath.ibi');
m = dlmread(fp);
x = m(:,2);

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

%auto_corr_plot(x, 7);

function auto_corr_plot(x, p)
    x0 = x(1:end-p);
    xp = x(1+p:end);
    figure;
    plot(x0,xp,'*');
end