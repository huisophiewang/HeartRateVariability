function [Tclean, RRclean] = hr_clean(tin, xin, win, plotflag)
% Data cleaning in the RR space
% Compute robust standard deviation and and
% remove  too short samples rr - mu <  -nsigma*stdx), adjust remaining
% Impute too long rr samples
% Use a SSA based smooting
% Inputs:
% tin    - times associated with each R event
% xin    - A sequence of rr intervals
% win    - length of the smoothing window for ssa smoothing and  interpolation
% plotflag = logical 1 if plots are desired
% Depenndencies: 
% Matlab:  robustcov(), 
% CTPC:    hr_remove_shortRR(), hr_imputeLong(), hr_ssa()
if ~exist('plotflag','var') || isempty(plotflag), plotflag = true; end
if ~exist('win','var')      || isempty(win), win = 15;  end    % window size
% Constants
%alpha = 0.01;               % Probability for outlier detection
%nsigma = norminv(1-alpha);  % Limit in SD for outlier detection
nsigma = 4;                 % Limit in SD for outlier detection

% figure; plot(tin, xin); hold on;  datetick; title('Raw Left Band Data');

% Pass 1: identify extreme outliers using robust variance estimation
[sig2,mu,distxmah,outliers] = robustcov(xin);
stdx = sqrt(sig2);
%iout = find(outliers);                 % From robust variance estimate

% remove small RR
iout = find((xin - mu) < -nsigma*stdx); % with our criterion for outliers
if plotflag
    figure, plot(tin,xin), hold on, plot(tin(iout),xin(iout),'*r')
    xlabel('Time [hrs]', 'FontSize', 14);
    ylabel('RR Intervals [msec]', 'FontSize', 14);
    datetick
end
[xtmp, ttmp] = hr_remove_shortRR(xin, tin, iout);

% impute long RR
iout = find((xtmp - mu) > nsigma*stdx);
dmax = 2*stdx + mu;
[RRclean, Tclean] = hr_imputeLong(xtmp,ttmp,iout,dmax);
% figure, plot(RRclean), hold on, plot(iout, RRclean(iout),'*r')
if plotflag
    figure, plot(Tclean, RRclean), hold on, plot(Tclean(iout), xtmp(iout),'*r')
    tt = (Tclean - Tclean(1))*24*3600*1000;
    figure; plot(tt,cumsum(RRclean));xlabel('Clean Time');ylabel('Cumulative Time')
    figure; plot(tt,tt-cumsum(RRclean)); ylabel('Deviation in time')
end
% Handling too large RR requires spreading the extra time over a small
% neighborhood
% Find the nighborhood of i-th point that satisfies the average conditions
% itest = 790:840;
% iout = ioutl(find(iout>=790 & iout <= 840 )) - itest(1)+1;
% x = xtmp(itest);
% t = ttmp(itest);

% Pass 2: identify extreme outliers using SSA smoothing
grp = [1 2, 3, 4]; % [1 2 3 4];Top eigenfunctions to use in reconstructing smooth version
[RRclean,err,vr,eigf]=hr_ssa(RRclean,win,grp, plotflag);   %  figure; plot(xhat)
% For small deviations, use the original values
% but replace large deviations with the xsmooth values





