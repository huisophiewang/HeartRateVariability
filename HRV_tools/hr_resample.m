function [y, to] = hr_resample(x,ti,fs)
% First, converts Matlab time to seconds 
% Then it converts irregularly sampled rate to regularly sampled at 500 Hz 
% Then downsamples by rfactor 
% ti  -  Input time (irregular) is assumed to be in Matlab time format
% x   -  Input values 
% fs  -  Desired uniform sampling frequency
% Signal processing toolbox
% M. Pavel 02-14-17
if ~exist('fs','var')    fs = 20;    end    % Decimated Sampling frequency
% Sampling  of the data segment ti(end) - ti(1) converted to seconds 

tm2sec = 24*3600;                % Convert matlab time to seconds
ti = (ti - ti(1))*tm2sec;
fsh = 500;                      % Default upsampling 500 Hz    
rfactor = round(fsh/fs);        % Decimating factor after upsampling

to = (ti(1):1/fsh:ti(end))';     % Output periodic sample points in time
yh=interp1(ti,x,to,'spline');   % Cubic spline interpolation
y = decimate(yh,rfactor);
fs = round(fsh/rfactor);
to = (ti(1):1/fs:ti(end))';  
end   %