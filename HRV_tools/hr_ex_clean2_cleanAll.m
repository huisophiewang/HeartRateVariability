%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description:
%   Script to demonstrate the use of hr_clean2
%   first, load msband and firstbeat data of all tasks of a given subject
%   plot raw msband rr and raw firstbeat rr
%   clean msband rr using hr_clean2.m
%   plot cleaned msband rr and raw firstbeat rr
%   write cleaned msband rr to .ibi file
% Dependencies:
%   external: hr_clean2, hr_write_rr_to_csv
%   internal: get_lab_data, compare_msband_with_firstbeat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

% specify subject id
subj = 'LWP2_0019';
time_format = 'sec';

% read data
[rr_fb, rr_t_fb] = hr_util_readRR(proj_dir, subj, 'firstbeat', 'raw', time_format);
[rr_mb, rr_t_mb] = hr_util_readRR(proj_dir, subj, 'msband', 'raw', time_format);


%compare_with_firstbeat(rr_fb, rr_t_fb, rr_mb, rr_t_mb, 'msband raw');



%time_format = 'datenum';
%data_type = 'raw';
%hr_util_writeRR(proj_dir, subj, rr_firstbeat, rr_t_firstbeat, 'firstbeat', data_type, time_format);
%hr_util_writeRR(proj_dir, subj, rr_msband, rr_t_msband, 'msband', data_type, time_format);
%hr_util_writeRR(proj_dir, subj, rr_e4, rr_t_e4, 'e4', data_type, time_format);

% set hr_clean2 parameters
AR_order = 10;          % AR order for impute long outlier
AR_window = 300;        % AR window size for impute long outlier
ssa_window = 25;        % SSA window size
plotflag = 1;

% clean firstbeat rr
% [rr_firstbeat_cleaned, rr_t_firstbeat_cleaned] = hr_clean2(rr_firstbeat, rr_t_firstbeat, AR_order, AR_window, ssa_window, plotflag);
% hr_util_writeRR(proj_dir, subj, rr_firstbeat_cleaned, rr_t_firstbeat_cleaned, 'firstbeat', 'cleaned', 'datenum');
% hr_util_writeRR(proj_dir, subj, rr_firstbeat_cleaned, rr_t_firstbeat_cleaned, 'firstbeat', 'cleaned', 'sec');
% 
% clean msband rr
[rr_mb_cleaned, rr_t_mb_cleaned] = hr_clean2(rr_mb, rr_t_mb, AR_order, AR_window, ssa_window, plotflag);
hr_util_writeRR(proj_dir, subj, rr_mb_cleaned, rr_t_mb_cleaned, 'msband', 'cleaned_local_win90_shift1', 'sec');










