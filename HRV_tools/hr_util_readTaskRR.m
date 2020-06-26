function [rr_fb, rr_t_fb, rr_mb, rr_t_mb, rr_e4, rr_t_e4] = hr_util_readTaskRR(proj_dir, subj, task)
% get msband and firstbeat data, given subject id and task name
    subj_data_dir = fullfile(proj_dir, 'HRV', 'HRV_data', subj);
    addpath(subj_data_dir);
    
    rr_data_fb = xlsread(sprintf('%s_lab_firstbeat_rr_raw_by_task.xlsx', subj), task);
    rr_t_fb = rr_data_fb(:,1);
    rr_fb = rr_data_fb(:,2);
    
    rr_data_mb = xlsread(sprintf('%s_lab_msband_rr_raw_by_task.xlsx', subj), task);
    rr_t_mb = rr_data_mb(:,1);
    rr_mb = rr_data_mb(:,2);
    
    rr_data_e4= xlsread(sprintf('%s_lab_e4_rr_raw_by_task.xlsx', subj), task);
    rr_t_e4 = rr_data_e4(:,1);
    rr_e4 = rr_data_e4(:,2);
end