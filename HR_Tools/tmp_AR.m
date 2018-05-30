clear all
dir = pwd();
fp = fullfile(dir, 'HeartRate', 'HR_Data', 'tmp_LWP2_0019_HRVAS', 'LWP2_0019_FirstBeat_RR_Task14_MentalMath.ibi');
% fp = fullfile(dir, 'HeartRate', 'HR_Data', 'tmp_LWP2_0019_HRVAS', 'LWP2_0019_FirstBeat_RR_Task15_Stroop.ibi');
fileID = fopen(fp, 'r');
r = fscanf(fileID, '%f');
n = length(r);
k = 16;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using function ar

% mdl = ar(r, k);
% A = mdl.A;
% 
% for i=k+1:n
%     ri = r(i-k:i-1);
%     mu = mean(ri);
%     ri = fliplr(ri);
%     e(i) = A(1)*mu + A(2:end)*ri;
%     rhat(i) = mu - e(i);
% end
% 
% scatter(r(k+1:end)',rhat(k+1:end))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using function arima

mdl = estimate(arima(k, 0, 0), r);   

A = cell2mat(mdl.AR);
c = mdl.Constant;

% test 0 constant AR model
% mdl2 = arima('Constant',0,'ARLags',[1:k]);
% est_mdl2 = estimate(mdl2, r);

for i=k+1:n
    ri = r(i-k:i-1);
    ri = fliplr(ri);
    rhat(i) = A*ri + c;
end
rhat=rhat';
%figure, scatter(r(k+1:end),rhat(k+1:end))


% overlay estimated signal on original signal
r_cut = r(k+1:end);
rhat_cut = rhat(k+1:end);
figure, plot(r_cut,'.-b', 'MarkerEdgeColor', 'b', 'MarkerSize', 8)
hold on
plot(rhat_cut,'.-r', 'MarkerEdgeColor', 'r', 'MarkerSize', 8)


% check residual
res = r_cut - rhat_cut;
stres = res/sqrt(var(res));

figure
subplot(1,2,1)
qqplot(stres)
x = -4:.05:4;
[f,xi] = ksdensity(stres);
subplot(1,2,2)
plot(xi,f,'k','LineWidth',2);
hold on
plot(x,normpdf(x),'r--','LineWidth',2)
legend('Standardized Residuals','Standard Normal')
hold off



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 


