clear all
addpath('C:\Users\Sophie\Documents\MATLAB\HR\HR_Tools')

% load 
hr_loadData;

% set parameters
win = 25;    % Q: why 25? How to choose window size?
plotflag = 1;


% poincare plot before cleaning
[sd1, sd2] = hr_poincare(FB_RR,plotflag);
title( sprintf('FirstBeat   Subj %s, Raw Data', sid),'Interpreter', 'none');

% clean 
% 1) compute mean and variance of RR intervals 
% 2) remove short RR, 4 sigma below
% 3) remove long RR, 4 sigma above
% 4) 
[FB_Time_RR_clean, FB_RR_clean] = hr_clean(FB_Time_RR, FB_RR, win, plotflag);

% poincare plot after cleaning
[sd1, sd2] = hr_poincare(FB_RR_clean, plotflag);
title( sprintf('FirstBeat   Subj %s, Clean Data', sid),'Interpreter', 'none');


% same process for MS band
[sd1, sd2] = hr_poincare( BandRR_L,plotflag);
title( sprintf('MSBand Left   Subj %s, Raw Data', sid),'Interpreter', 'none');
[MB_Time_RR_clean, MB_RR_L_clean] = hr_clean(BandTimeRR_L, BandRR_L, win, plotflag);
[sd1, sd2] = hr_poincare(MB_RR_L_clean, plotflag);
title( sprintf('MSBand Left   Subj %s, Clean Data', sid),'Interpreter', 'none');