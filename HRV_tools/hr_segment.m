function [iseg, valid, ivalid] = hr_segment(tin, xin, threshRR, maxgap, plotflag)
% Output segments of the raw input (tin, xin)  to valid segments xin <  threhRR
% Inputs
% tin       Sample times in Matlab format 
% xin       RR intervals [msec]
% threshRR  Maximal possible RR interval (might be 
%               removed later as an outlier [msec] [default 2000 msec]
% maxgap    Maximum gap that can still be imputed [sec]   [default 5 sec] 
% plotflag  0 no plot, 1 reduced plot, 2 full verbose
% ivalid    index to valid data points in the raw input xin
% 
% Outputs
% iseg(1:n_segments,1:2) First and last sample of each segment
% valid =  segments 0 are not valid, 1 valid, 2 not valid but may be imputed
%
% using run-length encoding
% Invalid intervals to be removed are (1) those longer than maxgap that can
% be interpolated surrounded by good data and (2)good intervals that are
% shorter than 60 seconds surrounded by bad data
%
% For debugging Test data FB SubjID = 'LWP2_0011'  
% ti1 = 166000; ti2 = 167200; xin = xin(ti1:ti2); tin = tin(ti1:ti2);  clear ti1 ti2
% figure; plot(tin,xin); datetick;
minsegment = 15;        % 
if ~exist('maxgap','var')    maxgap = 5;    end    % Max gap for interpolationin seconds
if ~exist('threshi','var')   threshRR = 2000; end    % Max RR in mseconds
if ~exist('plotflag','var')  plotflag = 0;   end    % Max RR in mseconds

xin = xin(:)'; tin = tin(:)';       % Convert to row vectors
% Identify RR < threshold and the complement is missing data 
% Use run-length coding to estimate the time intervals with RR within range
% Terminate with an opposite validity sample adding the last RR interval
%tin = [tin (tin(end)+ xin(end)/(24*3600*1000))]; % add the last point in unix time (xin is in secs)
% xin = [xin xin(end)];
% The starting point is the time before the first RR interval in sec
t2sec = 24*3600;
tsec = (tin - (tin(1)))*t2sec - xin(1)/1000;
% figure; plot(tin,1000*xi); datetick; ylim([0,1.2]);

%delt = [0 diff(tsec)];
xi = (xin < threshRR);   % Compute logical indicator for acceptable RR
len = diff([ 0 find(xi(1:end-1) ~= xi(2:end)) length(xi) ]);
val = xi([ find(xi(1:end-1) ~= xi(2:end)) length(xi) ]);  % [val' len']
% len(i) is the number of points in the run with the last point of the
% current interval starting at len(i-1) + 1
% Find valid time intervals  corresponding to [len' val']
valid = double(val);

% Segment to valid and invalid segments
ti1=[]; ti2=[]; dtin=[]; iseg=[];
%ti1(1) = -xin(1);% The first interval starts RR(1) before the first beat is detected
j = len(1);
iseg(1,1) = 1; iseg(1,2) = j;
ti2(1) = tsec(j);   % End if the first segment
ti1(1) = tsec(1) ;   % Begining if the first segment
dtin(1) =  ti2(1);
for ii=2:(length(len)) 
    % starting point j, last point is  j + len(i);
    % duration  delt(ii) = tin(jend)-tin(j)
    ti1(ii) = ti2(ii-1);    iseg(ii,1) = j+1;
     j = j + len(ii);       iseg(ii,2) = j;
    ti2(ii) =  tsec(j);
    dtin(ii) =  ti2(ii) - ti2(ii-1);
    % figure;plot(xin(iseg(ii,1):iseg(ii,2)))
end
% [[1:ii]' val(1:ii)' ti1' ti2' dtin'] 
% [[1:ii]' val(1:ii)' iseg] 
% [len(1:(end-1))' val(1:(end-1))' ti1' ti2' dtin'] 
if plotflag
    figure; plot(tsec,xin); ylim([0 3000]);  hold on; %datetick;
    xlabel('Time [sec]'); ylabel('RR [msec]')
    %plot(tsec,1000*xi);
        if val(1)
            plot([tsec(1) ti2(1)],[2000 2000],'-g','Linewidth',3);
        end
    for j=2:length(ti2)
        if val(j)
            plot([ti1(j) ti2(j)],[2000 2000],'-g','Linewidth',3);
        end
        %pause
    end
    legend('Data','Valid');
end
%% Assess the validity of segments
% Eliminate short segments with long RR and determine gaps that could
% potentially be imputed Eliminate all short segments surrounded by long
% invalid segments
for isg = 1:length(dtin)
    if valid(isg) == 0  &&  dtin(isg) < maxgap
        valid(isg) = 2;
    end
end

for isg = 2:length(dtin)
    if valid(isg) == 1  &  valid(isg - 1) == 0 &  dtin(isg) < minsegment
        valid(isg) = 0;
    elseif valid(isg) == 2  &  valid(isg - 1) == 0 
        valid(isg) = 0;
    end
end
%valid(find(valid == 2)) = 0;   % Temporary hack - should be revisited

%% PLot valid segments
if plotflag == 2
    iv = find(valid(1:end)== 1);
    ixval = [];
    figure
    for i = 1:length(iv)
        ixval = [ixval iseg(iv(i),1): iseg(iv(i),2)];
        plot(xin(iseg(iv(i),1): iseg(iv(i),2)));
        title(sprintf('iseg = %d',i));
        fprintf('Segment = %d  Press any key to continue:\n', i);
        pause
    end
end
% Output the entire signal in with valid flag
ivalid = zeros(length(xin),1);
for i = 1:length(dtin)
    ixs = [iseg(i,1):iseg(i,2)];
    ivalid(ixs) = valid(i);
end
        
        
        
    