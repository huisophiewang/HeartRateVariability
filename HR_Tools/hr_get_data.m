function hr_get_data(SubjID)
%% Function hr_get_data(Subj) fetches data from DeepHealth and stores in a 
% file SubjID_Data.mat in the current working directory in the Matlab
% format, e.g. LWP2_0011_Data.mat
% Input Subj is a string, e.g., 'LWP2_0011' as the ID of the subject
% Band = MS band wrist wearable device 
% FB is FirstBeat - the most accurate EKG device in the current experiment
% E4 is the Empatica product
% 
addpath('C:\Users\pavelm\Documents\Matlab_local\tools_local');
if ~exist('SubjID','var') SubjID = 'LWP2_0011'; end
usrID = ['"' SubjID '"']; 
% end
fnameSave = sprintf('tmp_%s_Data.mat',SubjID);    % Mat file to store the data
% if exists(fnameSave,'file')
%     fprintf('%s exists in current directory\n', fnameSave)
%     return
% end
% Connect to database
plotflag = false; %true;
conn2 = database('deephealth2', 'deepresearcher', 'UJqTPYqKF84YMVNJ',...
        'Vendor', 'MySQL', 'Server', 'deephealthlab.org');
fprintf('Connecting to DeepHealth Database \n')
%end
device_L = ' and device_location="Left"';
device_R = ' and device_location="Right"';
order_by_time = ' order by unix_timestamp ASC';
outlier = ' and unix_timestamp > 0';  % To remove outliers from E4_RR database

%% Band EDA
% Extract EDA data for MS band
selectEDA = 'SELECT unix_timestamp,mb_resistance FROM viewl_msband_gsr where user=';
fprintf('Fetching Left MS Band EDA\n')
Tx = fetch( conn2,[selectEDA, usrID, device_L, order_by_time]);
% Fetch Band EDA Left to a temp table Tx
BandEDA_L = cell2mat(Tx(:,2));
BandEDA_L = 1000./BandEDA_L;          % Convert from kOhms to microSiemens
BandTimeEDA_L = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
                         
% Fetch Band EDA Right to a temp table Tx                     
fprintf('Fetching Right MS Band EDA\n')
Tx = fetch( conn2,[selectEDA, usrID, device_R, order_by_time]);
BandEDA_R = cell2mat(Tx(:,2));
BandEDA_R = 1000./BandEDA_R;          % Convert from kOhms to microSiemens
BandTimeEDA_R = datenum(datetime(cell2mat(Tx(:,1))/1000,'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
if plotflag
    figure
    T0 = min(BandTimeEDA_L(1),BandTimeEDA_R(1));
    subplot(2,1,1)
    plot(BandTimeEDA_L - T0,BandEDA_L);
    ylabel('Conductance [\mu S]','FontSize', 14);
    xlabel('Time','FontSize', 14)
    title(sprintf('Left Band EDA, Subj:%s, ',usrID))
    subplot(2,1,2)
    plot(BandTimeEDA_R - T0,BandEDA_R,'r');
    xlabel('Time [sec]','FontSize', 14);
    ylabel('Conductance [\mu S]','FontSize', 14);
    title(sprintf('Right Band EDA, Subj:%s, ',usrID))
    datetick('x')
end

%% Band RR 
% Fetch RR data for MS band
selectRR = 'SELECT unix_timestamp, mb_rr FROM viewl_msband_rr where user=';
fprintf('Fetching Left MS Band RR\n')
% Band RR Left
Tx = fetch( conn2,[selectRR, usrID, device_L, order_by_time]);
BandTimeRR_L = datenum(datetime(cell2mat(Tx(:,1))/1000,...  % Convert to matlab time
     'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
rr = cell2mat(Tx(:,2));        % Raw data in seconds
rrtime = cumsum(rr);
X = [ones(length(rr),1), rrtime];
bcoef = regress(BandTimeRR_L,X);
BandTimeRR_L = rrtime/(24*3600) + bcoef(1);
BandRR_L = 1000*rr;               % Convert to msec
%
selectQ = 'SELECT unix_timestamp, mb_heart_rate_quality  FROM viewl_msband_heartrate where user=';
Tx = fetch( conn2,[selectQ, usrID, device_L, order_by_time]);
[num_rows, num_cols] = size(Tx);
BandQ_L  = zeros(num_rows,1);
%ix = findstrcell(table2array(Tx(:,2)),'LOCKED');
% couldn't find function findstrcell
ix = find(strcmp(Tx(:,2),'LOCKED'));
BandQ_L(ix) = 1;
BandTimeQ_L = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
%
% Band RR Right
fprintf('Fetching Right MS Band RR\n')
Tx = fetch( conn2,[selectRR, usrID, device_R, order_by_time]);
BandTimeRR_R = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
rr = 1000*cell2mat(Tx(:,2));       % Convert to msec
rrtime = cumsum(rr);
X = [ones(length(rr),1), rrtime];
bcoef = regress(BandTimeRR_R,X);
BandTimeRR_R = rrtime/(24*3600) + bcoef(1);
BandRR_R = 1000*rr;               % Convert to msec
%
Tx = fetch( conn2,[selectQ, usrID, device_R, order_by_time]);
[num_rows, num_cols] = size(Tx);
BandQ_R  = zeros(num_rows,1); 
% ix = findstrcell(table2array(Tx(:,2)),'LOCKED');
% couldn't find function findstrcell
ix = find(strcmp(Tx(:,2),'LOCKED'));
BandQ_R(ix) = 1;
BandTimeQ_R = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
if plotflag
    figure
    plot(BandTimeRR_L,BandRR_L); hold on;
    plot(BandTimeRR_R,BandRR_R); hold off
    xlabel('Time [sec]','FontSize', 14);
    ylabel('RR Interval [msec]','FontSize', 14);
end

%% Band Accelerometry
% Get accelerometer data from Gyro since the acc data were corrupted
selectGyro = ['SELECT unix_timestamp,mb_ang_x,mb_ang_y,mb_ang_z,mb_x,',...
    'mb_y,mb_z FROM viewl_msband_gyroscope where user='];

% Band Accelerometer Left
fprintf('Fetching Left MS Band Gyroscope\n')
Tx = fetch( conn2,[selectGyro, usrID, device_L, order_by_time]);  
BandTimeACC_L = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
acc = cell2mat(Tx(:,5:7));
tacc = BandTimeACC_L;
%figure; plot(tacc,acc); datetick
Band_ACC_L = sqrt(sum(acc.*acc, 2));   % RMS Accelerometer data

% Band Gyro and Accelerometer Right
fprintf('Fetching Right MS Band Gyroscope\n')  
Tx = fetch( conn2,[selectGyro, usrID, device_R, order_by_time]);    
BandTimeACC_R = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
acc = cell2mat(Tx(:,5:7));
Band_ACC_R = sqrt(sum(acc.*acc, 2));   % RMS Accelerometer data
if plotflag
    figure
    plot(BandTimeACC_L,Band_ACC_L);  hold on
    plot(BandTimeACC_R,Band_ACC_R); hold off
    legend('Left', 'Right')
    xlabel('Time [sec]','FontSize', 14);
    ylabel('RMS Accelerometer [g]','FontSize', 14);
    title(sprintf('Subj:%s, RMS Accelerometer',usrID))
end

%--------------------------------------------------------------------------

%% FirstBeat RR All
selectFBRR = ...
    'SELECT unix_timestamp, fb_rr FROM viewl_firstbeat_rr where user=';
fprintf('Fetching FirstBeat RR\n')
Tx = fetch( conn2,[selectFBRR, usrID, order_by_time]);  
FB_Time_RR = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
FB_RR = cell2mat(Tx(:,2));

selectFBACC = ...
    'SELECT unix_timestamp, fb_x, fb_y, fb_z FROM viewl_firstbeat_accelerometer where user=';
fprintf('Fetching FirstBeat Accelerometer\n')
Tx = fetch( conn2,[selectFBACC, usrID, order_by_time]);  
FB_Time_GYR = datenum(datetime(cell2mat(Tx(:,1))/1000,'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
acc = cell2mat(Tx(:,2:4));
FB_ACC = sqrt(sum(acc.*acc, 2));   % RMS Accelerometer data
if plotflag
    figure
    plot(FB_Time_RR,FB_RR);  hold on
    xlabel('Time [sec]','FontSize', 14);
    ylabel('RR Interval [msec]','FontSize', 14);
    title(sprintf('Subj:%s, FirstBeat',usrID))
    %title(sprintf('Subj:%s, RMS Accelerometer',usrID))
    figure
    plot(FB_Time_GYR,FB_ACC); hold off
    xlabel('Time [sec]','FontSize', 14);
    datetick('x',21) % 13 = 15:45:17   'HH:MM:SS',  21 =  'mmm.dd,yyyy HH:MM:SS' Mar.01,2000 15:45:17
    ylabel('RMS Accelerometer [g]','FontSize', 14);    
    title(sprintf('Subj:%s, RMS Accelerometer',usrID))
end

%--------------------------------------------------------------------------

% E4 Data
% E4 EDA  ******************************************************
% Fetch E4 EDA Left and right hand to a temp table Tx
selectEDA = 'SELECT unix_timestamp, e4_gsr FROM viewl_e4_gsr where user=';
fprintf('Fetching Left E4 EDA\n')
Tx = fetch( conn2,[selectEDA, usrID, device_L, order_by_time]);
E4_Time_EDA_L = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
E4_EDA_L = cell2mat(Tx(:,2));

fprintf('Fetching Right E4 EDA\n')
Tx = fetch( conn2,[selectEDA, usrID, device_R, order_by_time]);
E4_Time_EDA_R = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
E4_EDA_R = cell2mat(Tx(:,2));
if plotflag
    figure
    plot(E4_Time_EDA_L,E4_EDA_L); hold on
    plot(E4_Time_EDA_R,E4_EDA_R); hold off
    datetick('x',13) % 13 = 15:45:17   'HH:MM:SS',  21 =  'mmm.dd,yyyy HH:MM:SS' Mar.01,2000 15:45:17
end

%  E4  RR INTERVALS ******************************************************
selectRR =  'SELECT unix_timestamp, e4_rr FROM viewl_e4_rr where user=';
fprintf('Fetching Left E4 RR\n')
Tx = fetch( conn2,[selectRR, usrID, device_L, order_by_time]); 
E4_Time_RR_L = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
E4_RR_L = cell2mat(Tx(:,2));

fprintf('Fetching Right E4 RR\n')
Tx = fetch( conn2,[selectRR, usrID, device_R, order_by_time]);
E4_Time_RR_R = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
E4_RR_R = cell2mat(Tx(:,2));

%  E4 ACCELEROMETER  ******************************************************
selectACC = 'SELECT unix_timestamp, e4_x, e4_y, e4_z FROM viewl_e4_accelerometer where user=';
fprintf('Fetching Left E4 Accelerometer\n')
Tx = fetch( conn2,[selectACC, usrID, device_L, order_by_time]); 
E4_Time_ACC_L = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
acc = cell2mat(Tx(:,2:4));
E4_ACC_L = sqrt(sum(acc.*acc, 2));   % RMS Accelerometer data;

fprintf('Fetching Right E4 Accelerometer\n')
Tx = fetch( conn2,[selectACC, usrID, device_R, order_by_time]);
E4_Time_ACC_R = datenum(datetime(cell2mat(Tx(:,1))/1000,...
    'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
acc = cell2mat(Tx(:,2:4));
E4_ACC_R = sqrt(sum(acc.*acc, 2));   % RMS Accelerometer data;

%% Save subject's data
clear acc Tx T0 plotflag selectACC selectEDA selectRR selectFBACC conn2
clear selectFBRR selectGyro selectACC selectEDA outlier order_by_time
clear device_L device_R 
clear ix tacc rr rrtime X

fprintf('Saving data to %s\n',fnameSave)
save(fnameSave)

% %%--------------------------------------------------------------------------
% % i330 data imported manually from dropbox:
% % https://www.dropbox.com/sh/eypfrcbioo19ydb/AADPPY4vW-LMFL_M4iBESmDoa?dl=0
% 
% % i330 session 1 with timings (off by 1 second from manual labeling!) 
% i330serdarlab1_t = table2array(i330serdarlab1(:,12));
% i330serdarlab1_t = i330serdarlab1_t/1000; 
% i330serdarlab1_time = datetime(i330serdarlab1_t,'ConvertFrom','posixtime', 'TimeZone', 'America/New_York', 'Format', 'MMMM d, yyyy HH:mm:ss Z');
% % Left Hand
% plot(i330serdarlab1_time, i330serdarlab1{:,5});
% % Right Hand
% plot(i330serdarlab1_time, i330serdarlab1{:,7});
% 
% % i330 session 2 with timings (no offset) 
% i330serdarlab2_t = table2array(i330serdarlab2(:,10));
% i330serdarlab2_t = i330serdarlab2_t/1000; 
% i330serdarlab2_time = datetime(i330serdarlab2_t,'ConvertFrom','posixtime', 'TimeZone', 'America/New_York', 'Format', 'MMMM d, yyyy HH:mm:ss Z');
% % Left Hand
% plot(i330serdarlab2_time, i330serdarlab2{:,5});
% %plot(i330serdarlab2_time(1:20), i330serdarlab2{(1:20),5});
% % Right Hand
% plot(i330serdarlab2_time, i330serdarlab2{:,7});
% 
% %--------------------------------------------------------------------------


