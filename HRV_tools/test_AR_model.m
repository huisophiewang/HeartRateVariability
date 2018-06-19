clear all;

% read data file
dir = pwd();
fp = fullfile(dir, 'HeartRate', 'HR_Data', 'tmp_LWP2_0019_HRVAS', 'LWP2_0019_FirstBeat_RR_Task14_MentalMath.ibi');
fileID = fopen(fp, 'r');
r = fscanf(fileID, '%f');
n = length(r);

% set parameter (AR order)
k = 10;

% fit AR model
mdl = estimate(arima(k, 0, 0), r);   
A = cell2mat(mdl.AR);
c = mdl.Constant;
% test_mu = c/(1.0-sum(A));

% plot AR frequency response
b = [1.0];
a = [1.0, -A];
[h,w] = freqz(b, a); % default n=512
figure, plot(w/pi,abs(h));
ylim([0 15]);
title(sprintf('AR(%d) Frequency Response', k));
xlabel('Normalized Frequency (\times\pi rad/sample)');
ylabel('Magnitude');


% plot AR poles
H = tf(b, a);
figure, pzmap(H);
title(sprintf('AR(%d) Poles', k));
grid on;
[zeros, poles, ~] = tf2zp(b, a);


% prediction (rhat) using fitted AR model 
for i=k+1:n
    ri = r(i-k:i-1);
    ri = flipud(ri); % flip column vector upside down
    rhat(i) = A*ri + c;
end
rhat=rhat';

% estimated signal and original signal scatter plot
figure, scatter(rhat(k+1:end), r(k+1:end))
xlabel('predicted signal - rhat');
ylabel('orignal signal - r');

% overlay estimated signal on original signal in time domain
r_cut = r(k+1:end);
rhat_cut = rhat(k+1:end);
figure, plot(r_cut,'.-b', 'MarkerEdgeColor', 'b', 'MarkerSize', 8);
hold on;
plot(rhat_cut,'.-r', 'MarkerEdgeColor', 'r', 'MarkerSize', 8);
legend('original signal', 'predicted signal');

% check residual
res = r_cut - rhat_cut;
stres = res/sqrt(var(res));
figure, subplot(1,2,1);
qqplot(stres);
x = -4:.05:4;
[f,xi] = ksdensity(stres);
subplot(1,2,2);
plot(xi,f,'k','LineWidth',2);
hold on;
plot(x,normpdf(x),'r--','LineWidth',2);
legend('Standardized Residuals', 'Standard Normal');






