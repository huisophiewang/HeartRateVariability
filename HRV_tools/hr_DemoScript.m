% Script to demonstrate the process of loading and cleaning the HR data
% Default data directory
%  dir_data = 'C:\Users\pavelm\Documents\A_Projects\Affect\HRV\Experiment01\Data';
clear all
addpath('C:\Users\Sophie\Documents\MATLAB\HeartRate\HR_Tools')
dir_data = 'C:\Users\Sophie\Documents\MATLAB\HeartRate\HR_Data'
dir_current = pwd();
%
% First get all the data for a subject loaded; 
if ~exist('SubjID','var') SubjID = 'LWP2_0011'; end
%
hr_loadData
%
%
%
% Determine valid segments for FB using run-length encoding
% threslo = 0;
% threshi = 2000;
% maxgap = 15;  % sec
% tin = FB_Time_RR;
% xin = FB_RR;
% plotfalg = 2;
% % ti1 = 166000; ti2 = 167200; xin = xin(ti1:ti2); tin = tin(ti1:ti2);  clear ti1 ti2
% [iseg, valid] = hr_segment(tin, xin, threshi, maxgap, plotfalg);

% figure; plot(BandTimeRR_L,BandRR_L); datetick; hold on
% plot(BandTimeQ_L,BandQ_L); 

win = 25;
plotflag = 1;
[Tclean, RRclean] = hr_clean(BandTimeRR_L, BandRR_L, win, plotflag);

%%
% 
% <html>
% <table border=1><tr><td>one</td><td>two</td></tr></table>
% </html>
% 
[sd1, sd2] = hr_poincare(RRclean,plotflag);

%rr2 = [0; diff(BandTimeRR_L)]*24*3600*1000;   % Sampling intervals in msec
%figure; scatter(BandRR_L,rr2); xlabel('RR Intervals [msec]'); ylabel('\Delta t  [msec]');
%save('FB_RR_Data.mat', 'FB_RR', 'FB_Time_RR')
% figure; plot(FB_Time_RR, FB_RR);  datetick; title('Raw FB
% Data');ylim([0, 2500])
% figure; plot(BandTimeRR_L, BandRR_L);  datetick; title('Raw Left Band Data');
% figure; plot(BandTimeRR_R, BandRR_R);  datetick; title('Raw Right Band Data');
% figure; plot(FB_RR); ylim([0,5000]);
threslo = 0;
threshRR = 2000;
maxgap = 5;  % sec
plotflag = 1;
t2sec = 24*3600;
win = 25;   % Window for stationary HRV


% If the data are from FB we need to eliminate long segments
[iseg, valid, ivalid] = hr_segment(FB_Time_RR, FB_RR, threshRR, maxgap, plotflag);
title('FirstBeat');
FB_RR_Seg = [FB_Time_RR, FB_RR, ivalid];
[sd1, sd2] = hr_poincare(FB_RR,plotflag);
title( sprintf('FirstBeat   Subj %s, Raw Data', sid),'Interpreter', 'none');
[FB_Time_RR_clean, FB_RR_clean] = hr_clean(FB_Time_RR, FB_RR, win);
[sd1, sd2] = hr_poincare(FB_RR_clean,plotflag);
title( sprintf('FirstBeat   Subj %s, Clean Data', sid),'Interpreter', 'none');
xax = xlim;
yax = ylim;

[iseg, valid, ivalid] = hr_segment(BandTimeRR_L, BandRR_L, threshRR, maxgap, plotflag);
title( sprintf('MSBand Left   Subj %s', sid),'Interpreter', 'none');
BandRR_L_Seg = [BandTimeRR_L, BandRR_L, ivalid];

[sd1, sd2] = hr_poincare( BandRR_L,plotflag);
title( sprintf('MSBand Left   Subj %s, Raw Data', sid),'Interpreter', 'none');

[MB_Time_RR_clean, MB_RR_L_clean] = hr_clean(BandTimeRR_L, BandRR_L, win);
[sd1, sd2] = hr_poincare( MB_RR_L_clean,plotflag);
title( sprintf('MSBand Left   Subj %s, Clean Data', sid),'Interpreter', 'none');
xlim([400,1300]);
ylim([400,1300]);

xin = FB_RR;  tin =  FB_Time_RR;
xin =  BandRR_L;  tin = BandTimeRR_L;
xin = E4_RR_L;  tin =  E4_Time_RR_L;
% figure; plot(tin,xin); ylim([0,4000]); datetick
% figure; plot(BandTimeACC_L, Band_ACC_L)
% figure; plot(FB_Time_GYR, FB_ACC)
% 
% xin = Band_ACC_L-1; tin =  BandTimeACC_L;
% tsec = (tin - tin(1))*t2sec;
% figure; plot(tsec,xin);   hold on             %ylim([0 3000]);
% title('MS Band');
% ylabel('Acceleration [g]');
% xlabel('Time [sec]');
% xhat = movstd(xin,20);
% plot(tsec,xhat);
%  
% xin = BandQ_L; tin = BandTimeQ_L;
% tsec = (tin - tin(1))*t2sec;
% plot(tsec,0.5*xin);
% acfb = FB_AC;




