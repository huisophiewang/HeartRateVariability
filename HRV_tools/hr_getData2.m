function hr_getData2(proj_dir, subj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
%   modified based on hr_get_data.m by Misha Pavel (m.pavel@northeastern.edu)
% Description: 
%   Read heart rate data during the lab session of a given subject from deephealth database
%   Write the data to .mat file (e.g. 'LWP2_0019_lab_data.mat')
% Inputs:
%   subj       - subject id (e.g. 'LWP2_0019')
%   proj_dir   - full path of local repository 'Data-Analysis'
% Dependencies:
%   internal: get_msband_rr_data, get_msband_acc_data, get_firstbeat_rr_data, get_firstbeat_acc_data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % database connection
    conn2 = database('deephealth2', 'deepresearcher', 'UJqTPYqKF84YMVNJ', 'Vendor', 'MySQL', 'Server', 'deephealthlab.org');
    subj_data_dir = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj);
    mkdir(subj_data_dir);
    fp_in_timing = fullfile(subj_data_dir, sprintf('%s_lab_timing.xlsx', subj));
    fp_out_data = fullfile(subj_data_dir, sprintf('%s_lab_data.mat',subj));
    
    % get lab timing and device id
    [ndata, tdata, ~] = xlsread(fp_in_timing);
    computer_os = computer('arch');   % xlsread date field depends on os
    if startsWith(computer_os, 'win')
        date = datenum(tdata(5,2));
    elseif startsWith(computer_os, 'mac') 
        date = datenum(ndata(3,1) + 693960);   % mac use 1900 date system
    end
    lab_start_time = date + ndata(4,1);     % lab session start time
    e4_start_time = date + ndata(26,1);
    lab_start_time = e4_start_time;
    fprintf('lab start time:\n');
    datetime(lab_start_time,'ConvertFrom','datenum')
    lab_end_time = date + ndata(23,1);      % lab session end time
    fprintf('lab end time:\n');
    datetime(lab_end_time,'ConvertFrom','datenum')
    msband_left_id = char(tdata(3,2));      % msband device id left
    msband_right_id = char(tdata(4,2));     % msband device id right
    
    % get e4 rr data left and right
    [e4_left_rr, e4_left_rr_t] = get_e4_rr_data(conn2, subj, '1', lab_start_time, lab_end_time);
    [e4_right_rr, e4_right_rr_t] = get_e4_rr_data(conn2, subj, '2', lab_start_time, lab_end_time);
    % get e4 skin conductance data left and right
    [e4_left_sc, e4_left_sc_t] = get_e4_sc_data(conn2, subj, '1', lab_start_time, lab_end_time);
    [e4_right_sc, e4_right_sc_t] = get_e4_sc_data(conn2, subj, '2', lab_start_time, lab_end_time);
    % get e4 accelerometer data left and right
    [e4_left_acc, e4_left_acc_t] = get_e4_acc_data(conn2, subj, '1', lab_start_time, lab_end_time);
    [e4_right_acc, e4_right_acc_t] = get_e4_acc_data(conn2, subj, '2', lab_start_time, lab_end_time);
    
    % get msband rr data left and right
    [msband_left_rr, msband_left_rr_t] = get_msband_rr_data(conn2, subj, msband_left_id, lab_start_time, lab_end_time);
    [msband_right_rr, msband_right_rr_t] = get_msband_rr_data(conn2, subj, msband_right_id, lab_start_time, lab_end_time);
    % get msband accelerometer data left and right
    [msband_left_acc, msband_left_acc_t] = get_msband_acc_data(conn2, subj, msband_left_id, lab_start_time, lab_end_time);
    [msband_right_acc, msband_right_acc_t] = get_msband_acc_data(conn2, subj, msband_right_id, lab_start_time, lab_end_time);

    % get firstbeat rr data
    [firstbeat_rr, firstbeat_rr_t] = get_firstbeat_rr_data(conn2, subj, lab_start_time, lab_end_time);
    % get firstbeat accelerometer data
    [firstbeat_acc, firstbeat_acc_t] = get_firstbeat_acc_data(conn2, subj, lab_start_time, lab_end_time);

    % save to .mat file
    save(fp_out_data, ...
        'e4_left_rr', 'e4_left_rr_t', 'e4_right_rr', 'e4_right_rr_t',...
        'e4_left_sc', 'e4_left_sc_t', 'e4_right_sc', 'e4_right_sc_t',...
        'e4_left_acc', 'e4_left_acc_t', 'e4_right_acc', 'e4_right_acc_t',...
        'msband_left_rr', 'msband_left_rr_t', 'msband_right_rr', 'msband_right_rr_t',...
        'msband_left_acc', 'msband_left_acc_t', 'msband_right_acc', 'msband_right_acc_t',...
        'firstbeat_rr','firstbeat_rr_t',...
        'firstbeat_acc','firstbeat_acc_t');
    
    
end

function [rr, rr_t] = get_e4_rr_data(conn2, subj, device_id, start_time, end_time)
    % left hand
    rr = [];
    rr_t = [];
    cmd = ['SELECT unix_timestamp, e4_rr FROM deephealth2.view_e4_rr where user=', ['"' subj '"'], ...
        ' and device_id=', ['"' device_id '"'], ' order by unix_timestamp ASC'];
    data = fetch(conn2, cmd);
    data = cell2mat(data);
    if isempty(data)
        fprintf('no rr data found for device %s\n', device_id);
    else
        timestamp = datenum(datetime(data(:,1)/1000,'ConvertFrom', 'posixtime', 'TimeZone', 'America/New_York')); 
        % get entries of the lab session
        indices = find(timestamp >= start_time & timestamp <= end_time); 
        timestamp = timestamp(indices,1);
        rr = data(indices,2);    % get rr (in sec)   
        rr_t = timestamp;
    end
end

function [sc, sc_t] = get_e4_sc_data(conn2, subj, device_id, start_time, end_time)
    % left hand
    sc = [];
    sc_t = [];
    cmd = ['SELECT unix_timestamp, e4_gsr FROM deephealth2.view_e4_gsr where user=', ['"' subj '"'], ...
        ' and device_id=', ['"' device_id '"'], ' order by unix_timestamp ASC'];
    data = fetch(conn2, cmd);
    data = cell2mat(data);
    if isempty(data)
        fprintf('no gsr data found for device %s\n', device_id);
    else
        timestamp = datenum(datetime(data(:,1)/1000,'ConvertFrom', 'posixtime', 'TimeZone', 'America/New_York')); 
        % get entries of the lab session
        indices = find(timestamp >= start_time & timestamp <= end_time); 
        timestamp = timestamp(indices,1);
        sc = data(indices,2);    % get rr (in sec)   
        sc_t = timestamp;
    end
end

function [acc, acc_t] = get_e4_acc_data(conn2, subj, device_id, start_time, end_time)
    acc = [];
    acc_t = [];
    cmd = ['SELECT unix_timestamp, e4_x, e4_y, e4_z FROM deephealth2.view_e4_accelerometer where user=',...
        ['"' subj '"'], ' and device_id=', ['"' device_id '"'], ' order by unix_timestamp ASC'];   
    data = fetch(conn2,cmd);  
    data = cell2mat(data);
    if isempty(data)
        fprintf('no accelerometer data found for device %s\n', device_id);
    else
        timestamp = datenum(datetime(data(:,1)/1000,'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
        indices = find(timestamp >= start_time & timestamp <= end_time); % get entries of the lab session
        acc = data(indices,2:4);
        acc = sqrt(sum(acc.*acc, 2));   % RMS Accelerometer data
        acc_t = timestamp(indices,1);
    end
end

function [rr, rr_t] = get_msband_rr_data(conn2, subj, device_id, start_time, end_time)
    rr = [];
    rr_t = [];
    cmd = ['SELECT unix_timestamp,mb_rr FROM deephealth2.view_msband_rr where user=', ['"' subj '"'], ...
        ' and device_id=', ['"' device_id '"'], ' order by unix_timestamp ASC'];
    data = fetch(conn2, cmd);
    data = cell2mat(data);
    if isempty(data)
        fprintf('no rr data found for device %s\n', device_id);
    else
        % convert to matlab time
        timestamp = datenum(datetime(data(:,1)/1000,'ConvertFrom', 'posixtime', 'TimeZone', 'America/New_York')); 
        % get entries of the lab session
        indices = find(timestamp >= start_time & timestamp <= end_time); 
        timestamp = timestamp(indices,1);
        rr = data(indices,2);    % get rr (in sec)   
        rr_t = timestamp;
    end

end


function [acc, acc_t] = get_msband_acc_data(conn2, subj, device_id, start_time, end_time)
    acc = [];
    acc_t = [];
    cmd = ['SELECT unix_timestamp,mb_x,mb_y,mb_z FROM deephealth2.view_msband_gyroscope where user=',...
        ['"' subj '"'], ' and device_id=', ['"' device_id '"'], ' order by unix_timestamp ASC'];   
    data = fetch(conn2,cmd);  
    data = cell2mat(data);
    if isempty(data)
        fprintf('no accelerometer data found for device %s\n', device_id);
    else
        timestamp = datenum(datetime(data(:,1)/1000,'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
        indices = find(timestamp >= start_time & timestamp <= end_time); % get entries of the lab session

        acc = data(indices,2:4);
        acc = sqrt(sum(acc.*acc, 2));   % RMS Accelerometer data
        acc_t = timestamp(indices,1);
    end
end

function [rr, rr_t] = get_firstbeat_rr_data(conn2, subj, start_time, end_time)
    rr = [];
    rr_t = [];
    cmd = ['SELECT unix_timestamp,fb_rr FROM deephealth2.view_firstbeat_rr where user=', ['"' subj '"'], ...
           ' order by unix_timestamp ASC'];
    data = fetch(conn2, cmd);
    data = cell2mat(data);
    if isempty(data)
        fprintf('no rr data found for firstbeat\n');
    else
        % convert to matlab time
        timestamp = datenum(datetime(data(:,1)/1000,'ConvertFrom', 'posixtime', 'TimeZone', 'America/New_York')); 
        % get entries of the lab session
        indices = find(timestamp >= start_time & timestamp <= end_time); 
        timestamp = timestamp(indices,1);
        rr = data(indices,2)/1000;    % get rr (raw data in msec) 
        rr_t = timestamp;
    end     
end

function [acc, acc_t] = get_firstbeat_acc_data(conn2, subj, start_time, end_time)
    acc = [];
    acc_t = [];
    cmd = ['SELECT unix_timestamp,fb_x,fb_y,fb_z FROM deephealth2.view_firstbeat_accelerometer where user=',...
        ['"' subj '"'], ' order by unix_timestamp ASC'];   
    data = fetch(conn2,cmd);  
    data = cell2mat(data);
    if isempty(data)
        fprintf('no accelerometer data found for firstbeat\n');
    else
        timestamp = datenum(datetime(data(:,1)/1000,'ConvertFrom','posixtime', 'TimeZone', 'America/New_York'));
        indices = find(timestamp >= start_time & timestamp <= end_time); % get entries of the lab session
        acc = data(indices,2:4);
        acc = sqrt(sum(acc.*acc, 2));   % RMS Accelerometer data
        acc_t = timestamp(indices,1);
    end
end


