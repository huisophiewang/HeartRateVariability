function [rr, rr_t] = hr_util_readRR(proj_dir, subj, device, data_type, time_format)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description: 
%   read rr and rr_t from csv in folder "(proj_dir)\HRV\HRV_data\subj"
%   csv file is named by (subj)_lab_(device)_rr_(data_type)_(time_format).csv (e.g. LWP2_0019_lab_msband_rr_cleaned_datenum.csv"
% Inputs:
%   proj_dir    - full path of local repository 'Data-Analysis'
%   subj        - subject id (e.g. 'LWP2_0019')
%   device      - options are: firstbeat, msband, e4
%   data_type   - options are: raw, cleaned, smoothed  
%   time_format - options are: datenum (matlab datenum format), sec (seconds, start from 0)
% Outputs:
%   rr          - a sequence of rr intervals (in seconds)
%   rr_t        - timestamps associated with each R event (in matlab datenum format or in seconds starting from 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    f_name = sprintf('%s_lab_%s_rr_%s_in_%s.csv', subj, device, data_type, time_format);
    fp = fullfile(proj_dir, 'HRV', 'HRV_data', subj, f_name);
    m = dlmread(fp);
    rr_t = m(:,1);
    rr = m(:,2);
end