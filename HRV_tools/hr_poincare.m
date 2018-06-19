function [sd1, sd2] = hr_poincare(rr,plotflag)
% Plots rr_i vs rr_i-1
% Estimates the prinicpal axes of the Poincare plot for sequence r(t)
% plotflag = true will plot the data
if ~exist('plotflag','var') || isempty(plotflag), plotflag = false; end
if nargout < 1, plotflag = true; end

rr = rr(:);
y = rr(2:end);
x = rr(1:(end-1));
xy = [x y];
avgxy = mean(xy);   % Compute Grand mean
[coeff,score,latent,tsquared,explained,mu] = pca(xy);
% to reconstruct the original data 
% xhat = score*coeff'   where score is [xs,ys]

maxxy = max(score);
minxy = min(score);
p1 = [minxy(1),0;maxxy(1), 0]*coeff';
p2 = [0, minxy(2);0, maxxy(2)]*coeff';

if plotflag
    figure; plot(x,y,'o','MarkerFaceColor','b');  hold on
    plot(p1(:,1)+mu(1),p1(:,2)+mu(2),'r','Linewidth', 3 );
    plot(p2(:,1)+mu(1),p2(:,2)+mu(2),'r','Linewidth', 3 );
    axis equal
    xlabel('RR(i) Interval [msec]','FontSize',14)
    ylabel('RR(i-1) Interval [msec]','FontSize',14)
end

sd1 = sqrt(latent(1));
sd2 = sqrt(latent(2));






