% Script to simulate the heart rate variability using integrate and fire
% relaxation oscillator controlled by the sympathetic SNS and parasympatthetic PNS nervous
% systems
% Simulation parameters from
% Rose, W., & Knight, C. A. (2011). Spectral analysis of point processes:
% motor unit activity and heart rate analysis. Medicine and Science in
% Sports and Exercise, 43(2), 239-248
% First, we created a steady input to the IPFM model, which gave evenly
% spaced events at 1.2 Hz, a typical HR. Then, we added sinusoidal
% modulation at 0.24 Hz to the input. Noise was not added. This should be
% roughly similar to paced breathing at 0.24 Hz

% Generate cotrolling HR function  V(t)
clear variables
plotflag = 1;
% addpath('C:\Users\pavelm\Documents\Matlab_local\tools_local')
% addpath('C:\Users\pavelm\Documents\A_Projects\Affect\HRV\HRV_tools')
addpath('C:\Users\Sophie\Documents\MATLAB\HR\HR_Tools')
D = 200;     % [sec] Duration of the segment in sec
% Estimate the heart rate HR function 
fs = 4;     % Hz  Sampling frequency for the HR = V
% Set resonance frequency for poles
Fl = 0.08;  % Hz
Fh = 0.25;  % Hz
% Since f = alpha*fs/(2*pi), where alpha is the angle on z circle
alpha_l = Fl*2*pi/fs;
alpha_h = Fh*2*pi/fs;
Rl = 0.90;
Rh = 0.95;

% HF part
a1(1) = 1;
a1(2) = -2*Rh*cos(alpha_h);
a1(3) = Rh^2;
figure; freqz(1,a1,100,fs)

% LF part
a2(1) = 1;
a2(2) = -2*Rl*cos(alpha_l);
a2(3) = Rl^2;
figure; freqz(1,a2,100,fs)

a = conv(a1,a2); % Combine the two IIR filters
rts = roots(a);  % Get poles of the filter
[h fo] = freqz(1,a,100,fs);
nm =  1:round(length(h)/2);
figure; plot((fs/2)*fo(nm),abs(h(nm))); xlabel('Frequency [Hz]'); ylabel('Amplitude');
title('HR Function Spectrum')


% generate random signal
n = fs*D;
t = (0:n-1)'/fs;
Vdrive = randn(n,1);
figure; plot(t, Vdrive); xlabel('Time [sec]'); ylabel('HR Driving Function');



% filter random signal through a
Vslow = filter(1,a,Vdrive);
% scale and shift in amplitude?
Vslow = Vslow/std(Vslow)/10 + 1;
figure; plot(t,Vslow); xlabel('Time [sec]'); ylabel('HR Driving Function');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Estimate raw R-R intervals
frs = 360;           % Raw signal sampling rate to match physionet DB 
deltr = 1/frs;
T = 0:deltr:D;  % upsampling
% Interpolate the Vdriving HR function
% Vr = Vs + Vp; % with separate parasympathetic and sympathetic 
Vr = interp1(t,Vslow,T');
figure; plot(T,Vr); xlabel('Time [sec]'); ylabel('HR Driving Function');

% Parameters of the integrate and fire model
Th = 0.95; % Threshold 
RR0 = 1;  % Nominal RR interval [sec]
Tau = -RR0/(log(1-Th));  % Test V = 1-exp(-T/Tau);
alpha = deltr/Tau;

V(1) = 0;
tt = 1;     % index of integration
ir = 0;     % R event indeces
for t = T(1:(end-1))  % t=T(1)
    tt = tt+1;
    V(tt) = (1 - alpha)*V(tt-1) + alpha*Vr(tt);
    if (V(tt) >= (Th +normrnd(0,0.2) ))
        V(tt) = 0;
        ir = ir+1;
        R(ir) = t;
    end
end
figure, plot(T,V)


RR = diff(R);
figure, histogram(RR)
figure, plot(cumsum(RR),RR)
[sd1, sd2] = hr_poincare(RR,plotflag);


% 103 looks like good ECG
clear all
clc
close all
filename = 'aami3a.dat';
filename = '103.dat';
% [filename, pathname] = uigetfile('*.dat', 'Open file .dat');% only image Bitmap
% if isequal(filename, 0) || isequal(pathname, 0)   
%     disp('File input canceled.');  
%    ECG_Data = [];  
% else
fid=fopen(filename,'r');
% end;
Duration = 10;      % Pick only Duration seconds to read
f=fread(fid,2*frs*Duration,'ubit12');
Orig_Sig1=f(1:2:length(f));     % First channel
Orig_Sig2=f(2:2:length(f));     % Second channel
ntotal = length(f)

t = 0:deltr:10-deltr;
subplot(2,1,1)
plot(t, Orig_Sig1)
subplot(2,1,2)
plot(t,Orig_Sig2)
[pksval,imax,pwidth,prom] = findpeaks(Orig_Sig1,frs);
findpeaks(Orig_Sig1,frs, 'MinPeakProminence',400); % R-peaks
[pksval,imax,pwidth,prom] = findpeaks(Orig_Sig1,frs, 'MinPeakProminence',400);
[pksval,imax,pwidth,prom] = findpeaks(Orig_Sig1,frs, 'MinPeakProminence',75);
Rt = imax(find(prom > 400));
Tt = imax((prom < 400 & prom > 75));
%Select one pulse sequence
RR = diff(Rt);
t1 = Rt(3) - RR(3)/2;
t2 = Rt(4) - RR(4)/2;
ix1 = floor(t1/deltr : t2/deltr);
