clear all
    
subj = 'LWP2_0015';
conn2 = database('deephealth2', 'deepresearcher', 'UJqTPYqKF84YMVNJ', 'Vendor', 'MySQL', 'Server', 'deephealthlab.org');


fname = sprintf('tmp_%s_Data_MSBand.mat',subj);    % mat file to store the data

% Band RR Left 
Tx = fetch( conn2, 'SELECT * FROM deephealth2.view_msband_rr where user="lwp2_0015" and device_id="58:82:A8:CF:B9:59" order by unix_timestamp ASC');
% Convert to matlab time
BandTimeRR_L = datenum(datetime(cell2mat(Tx(:,1))/1000,'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
rr = cell2mat(Tx(:,2));        % Raw data in seconds
rrtime = cumsum(rr);

% ???
X = [ones(length(rr),1), rrtime];
bcoef = regress(BandTimeRR_L,X);

BandRR_L = rr;               
BandTimeRR_L = rrtime/(24*3600) + bcoef(1);


save(fname, 'BandRR_L', 'BandTimeRR_L');