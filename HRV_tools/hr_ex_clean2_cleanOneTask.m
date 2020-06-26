%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description:
%   Script to demonstrate the use of hr_clean2
%   first, load msband and firstbeat data of a given subject and a task,
%   plot raw msband rr and raw firstbeat rr
%   clean msband rr using hr_clean2.m
%   plot cleaned msband rr and raw firstbeat rr
%   write cleaned msband rr to .ibi file
% Dependencies:
%   external: hr_clean2, hr_write_rr_to_csv
%   internal: get_lab_data_by_task, compare_msband_with_firstbeat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')


% specify subject id and task name
subj = 'LWP2_0019';
task = 'Task14_MentalMath';
task = 'Task7_RelaxingMusic2';

% read data
[rr_firstbeat, rr_t_firstbeat, rr_msband, rr_t_msband, rr_e4, rr_t_e4] = get_lab_data_by_task(proj_dir, subj, task);

%compare_rr(rr_firstbeat, rr_t_firstbeat, 'firstbeat', rr_msband, rr_t_msband, 'msband raw', rr_e4, rr_t_e4, 'e4 raw');

plot_moving_avg(rr_msband, rr_t_msband);

% set hr_clean2 parameters
AR_order = 10;          % AR order for impute long outlier
AR_window = 250;        % AR window size for impute long outlier
ssa_window = 25;        % SSA window size
plotflag = 1;

% clean firstbeat
%nsigma = 3.5;
%[rr_firstbeat_cleaned, rr_t_firstbeat_cleaned] = hr_clean2(rr_firstbeat, rr_t_firstbeat, nsigma, AR_order, AR_window, ssa_window, plotflag);

% clean msband rr
%nsigma = 1.7;
%[rr_msband_cleaned1, rr_t_msband_cleaned1] = hr_clean2(rr_msband, rr_t_msband, nsigma, AR_order, AR_window, ssa_window, plotflag);

% clean msband diff(rr_t)
%rr_t_msband_diff = [rr_msband(1); diff(rr_t_msband)*24*3600];
%[rr_msband_cleaned2, rr_t_msband_cleaned2] = hr_clean2(rr_t_msband_diff, rr_t_msband, nsigma, AR_order, AR_window, ssa_window, plotflag);

% compare clean results


% disp('firstbeat cleaned:');
% datetime(rr_t_firstbeat_cleaned(end), 'ConvertFrom', 'datenum') 
% 
% disp('msband cleaned 1:');
% datetime(rr_t_msband_cleaned1(end), 'ConvertFrom', 'datenum') 
% 
% disp('msband cleaned 2:');
% datetime(rr_t_msband_cleaned2(end), 'ConvertFrom', 'datenum') 


% write cleaned msband to .ibi file
%hr_write_rr_to_csv(proj_dir, subj, rr_msband_cleaned2, rr_t_msband_cleaned2, 'msband', sprintf('cleaned_%s', task));  


function [rr_firstbeat, rr_t_firstbeat, rr_msband, rr_t_msband, rr_e4, rr_t_e4] = get_lab_data_by_task(proj_dir, subj, task)
% get msband and firstbeat data, given subject id and task name
    subj_data_dir = fullfile(proj_dir, 'HRV', 'HRV_data', subj);
    addpath(subj_data_dir);
    
    rr_data_firstbeat = xlsread(sprintf('%s_lab_firstbeat_rr_raw_by_task.xlsx', subj), task);
    rr_t_firstbeat = rr_data_firstbeat(:,1);
    rr_firstbeat = rr_data_firstbeat(:,2);
    
    rr_data_msband = xlsread(sprintf('%s_lab_msband_rr_raw_by_task.xlsx', subj), task);
    rr_t_msband = rr_data_msband(:,1);
    rr_msband = rr_data_msband(:,2);
    
    rr_data_e4= xlsread(sprintf('%s_lab_e4_rr_raw_by_task.xlsx', subj), task);
    rr_t_e4 = rr_data_e4(:,1);
    rr_e4 = rr_data_e4(:,2);
end

function compare_rr(rr1, rr_t1, title1, rr2, rr_t2, title2, rr3, rr_t3, title3)
    figure;
    ax1 = subplot(3,1,1);
    plot(rr_t1, rr1, 'b.-', 'MarkerSize',8);
    datetick('x'); 
    title(title1, 'Interpreter', 'None');
    
    ax2 = subplot(3,1,2);
    plot(rr_t2, rr2, 'b.-', 'MarkerSize',8); 
    datetick('x'); 
    title(title2, 'Interpreter', 'None');
    
    ax3 = subplot(3,1,3);
    plot(rr_t3, rr3, 'b.-', 'MarkerSize',8); 
    datetick('x'); 
    title(title3, 'Interpreter', 'None');
    
    linkaxes([ax1,ax2,ax3],'xy');
end

function plot_moving_avg(rr, rr_t)
    figure;
    plot(rr_t, rr, 'b');
    datetick('x'); 
    hold on;
    k_nb = 3;
    avg = movmean(rr, k_nb);
    plot(rr_t, avg, 'r');


end

