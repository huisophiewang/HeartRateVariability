function hr_util_writeRR(proj_dir, subj, rr, rr_t, device, data_type, time_format)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description: 
%   write rr_t and rr to csv file
%   csv file name is created by (subj)_lab_(device)_rr_(data_type)_(time_format).csv (e.g. LWP2_0019_lab_msband_rr_cleaned_datenum.csv"
%   csv file is saved under folder "Data-Analysis\HRV\data\(subj)"
% Inputs:
%   proj_dir    - full path of local repository 'Data-Analysis'
%   subj        - subject id (e.g. 'LWP2_0019')
%   rr          - a sequence of rr intervals (in seconds)
%   rr_t        - timestamps associated with each R event (in matlab datenum format or in seconds starting from 0)
%   device      - options are: firstbeat, msband, e4
%   data_type   - options are: raw, cleaned, smoothed  
%   time_format - options are: datenum (matlab datenum format), sec (seconds, start from 0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    f_out = sprintf('%s_lab_%s_rr_%s_in_%s.csv', subj, device, data_type, time_format);
    subj_data_dir = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj);
    addpath(subj_data_dir);
    fp_out = fullfile(subj_data_dir, f_out);
    
    if strcmp(time_format, 'sec')
        rr_t = rr_t.*(24*3600);
        rr_t = rr_t - rr_t(1);
        format = '%.3f,%.3f\n';
    elseif strcmp(time_format, 'datenum')
        format = '%.6f,%.3f\n';
    end
    
    m = horzcat(rr_t, rr);
    f_id = fopen(fp_out,'w');
    fprintf(f_id, format, m.');
    fclose(f_id);
    
end