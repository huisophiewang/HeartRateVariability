
% Modeling heart rate before cleaning using raw R samples as if they were
% periodically sampled

nfft = 128;
t = FB_Time_RR(1:nfft);
y = FB_RR(1:nfft);

% Estimate the dynamics of RR distribution with overlaping moving window
Ntotal = length(FB_RR);
prc = [10, 25, 50, 75, 90];     % Percentiles to compute
n1 = 1;                         % Start and end of the moving window
n2 = nfft;
delw = nfft/8;                  % Shift of the moving window between frames
i = 0;
rp = [];
ri = linspace(0.2,1.0);         % Points of RR to evaluate the distribution
while (n2 <=Ntotal)
    i = i + 1;
    y = FB_RR(n1:n2);
    ta(i) = FB_Time_RR(n1 + delw/2);
    rp = [rp ; prctile(y,prc)];
    [ft rrt] = ksdensity(FB_RR(n1:n2),ri);
    f2d(:,i) = ft';
    rrmin(i) = rrt(1);
    rrmax(i) = rrt(end);
    % ksdensity(FB_RR(n1:n2)); hold on
    
    n1 = n1 + delw;
    n2 = n1 + nfft - 1;
end

figure; mesh(ta,ri,f2d)
xlabel('Time','FontSize',14);
ylabel('RR Interval [sec]','FontSize',14);
zlabel('Probability Density','FontSize',14);
title(sprintf('RRFirstBeat RR , Subj:%s, ',usrID))
datetick
figure; pcolor(ta,ri,f2d); colorbar;
xlabel('Time','FontSize',14); datetick
ylabel('RR Interval [sec]','FontSize',14);
title(sprintf('RRFirstBeat RR , Subj:%s, ',usrID))
    
figure; plot(ta,rp)
ylabel('Percentiles','FontSize',14);
xlabel('Time','FontSize',14); datetick
legend({'10', '25', '50', '75', '90'},'Location','southwest')
title(sprintf('RRFirstBeat RR Percentiles , Subj:%s, ',usrID))

% Plot the difference between 10 and 90 percentile
figure; plot(ta,rp(:,5)-rp(:,1))
datetick

% Plot autocorrelation (ACF) and partial autocorrelation (PACF) of RR
% PACF is correlation with all intermediated dependcies removed
% PACF(3) removes the correlation that predicts 2 from 1 and therefore 3 from 2
figure
subplot(2,1,1)
autocorr(y)
subplot(2,1,2)
parcorr(y)

%Difference data
dY = diff(y);

figure
plot(dY)
h2 = gca;
h2.XLim = [0,T];
h2.XTick = 1:10:T;
h2.XTickLabel = datestr(dates(2:10:T),17);
title('Differenced Raw RR Data')

figure
subplot(2,1,1)
autocorr(dY)
title(sprintf('FB RR Autocorrelation, Subj:%s, ',usrID))
subplot(2,1,2)
parcorr(dY)
% ARIMA model ARIMA(p,D,q)   p  - Moving Avg,  q AR coefficients and
% D is the number of differences taken (integrating noise over samples) 

Mdl = arima(4,1,2);         % Setup model
EstMdl = estimate(Mdl,y);   % Estimate model parameters
res = infer(EstMdl,y);      % Compute residuals
figure
subplot(2,2,1)
plot(res./sqrt(EstMdl.Variance))
title('Standardized Residuals')
subplot(2,2,2)
qqplot(res)         % Are the residuals normally distributed
subplot(2,2,3)
autocorr(res)       % Residual ACF
subplot(2,2,4)
parcorr(res)