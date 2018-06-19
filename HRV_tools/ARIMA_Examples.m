
% Modeling heart rate before cleaning using ARIMA withraw R samples as if 
% they were % periodically sampled

nfft = 128;
t = FB_Time_RR(1:nfft);
y = FB_RR(1:nfft);

% Evolution of RR distribution
Ntotal = length(FB_RR);
prc = [10, 25, 50, 75, 90];
n1 = 1;
n2 = nfft;
delw = nfft/8;
i = 0;
rp = [];
ri = linspace(0.2,1.0);
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
datetick
figure; pcolor(ta,ri,f2d); colorbar;
xlabel('Time','FontSize',14)
ylabel('RR Interval [sec]','FontSize',14);


    
figure; plot(ta,rp)
ylabel('Percintiles');
legend({'10', '25', '50', '75', '90'},'Location','southwest')
datetick

figure; plot(ta,rp(:,5)-rp(:,1))
datetick

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
subplot(2,1,2)
parcorr(dY)

Mdl = arima(4,1,2);
EstMdl = estimate(Mdl,y);
res = infer(EstMdl,y);      % Compute residuals
figure
subplot(2,2,1)
plot(res./sqrt(EstMdl.Variance))
title('Standardized Residuals')
subplot(2,2,2)
qqplot(res)
subplot(2,2,3)
autocorr(res)
subplot(2,2,4)
parcorr(res)