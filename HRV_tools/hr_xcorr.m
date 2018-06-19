function [Rmax,Tshift, tmax] = hr_xcorr(x, y, pwinshift, win, fs, plotflag, Subj)
% Compute short-term correlation between x,y within a moving window win
% shifted by theamount pshift*win
% x, y Input arrays
% win = array: 1:end
% 0 < pwinshift <= 1
delt = round(pwinshift*length(win));  % proportion of window to shift
if plotflag figure; end
j = 0;
tmax = [];
for tshift = 0:delt:(min([length(x),length(y)]) - length(win))
    j = j + 1;
    shift(j) = tshift;
    [R, lag] = xcov(x(win+tshift),y(win+tshift),'coeff');
    %[R, lag] = xcorr(x(win+tshift),y(win+tshift),'coeff');
    %stem(lags/fs, R)
    [Rmax(j),imax] = max(R);
    Tshift(j) = (tshift + length(win)/2)/fs;    % Center of the window corresponding to Rmax
    tmax(j) = lag(imax)/fs;
    if plotflag
        plot(lag/fs,R);
        ylim([0,1]);
        title(sprintf('Subj:%s,Dm=%4.0f,Shift=%5.0f', Subj, tmax(j),tshift/fs));
        xlabel('Lag [secs]', 'FontSize',14)
        ylabel('Correlation', 'FontSize',14)
        %datetick('x',13)
        disp('Paused')
        pause
    end
end