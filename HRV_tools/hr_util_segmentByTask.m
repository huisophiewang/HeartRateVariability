function hr_util_segmentByTask(proj_dir, subj, device)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description: 
%   Segment raw data read from the database by task according to lab_timing file
%   Save segmented data in a xlsx file, each task in a seperate sheet
% Inputs:
%   subj       - subject id (e.g. 'LWP2_0019')
%   device     - firstbeat or msband (e.g. 'msband')
%   proj_dir   - full path of local repository 'Data-Analysis'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % input  files
    subj_data_dir = fullfile(proj_dir, 'HRV','data','LWP2', subj);
    mkdir(subj_data_dir);
    fp_in_timing = fullfile(subj_data_dir, sprintf('%s_lab_timing.xlsx', subj));
    fp_in_data = fullfile(subj_data_dir, sprintf('%s_lab_data.mat', subj));

    % all task names
    task_names = {
        'Task1_RelaxingMusic1', ...
        'Task2_RelaxingPic1', ...
        'Task3_EMA1', ...
        'Task4_IAPS', ...
        'Task5_StressPic1', ...
        'Task6_EMA2', ...
        'Task7_RelaxingMusic2', ...
        'Task8_RelaxingPic2', ...
        'Task9_EMA3', ...
        'Task10_Biking', ...
        'Task11_RelaxingMusic3', ...
        'Task12_NeutralPic', ...
        'Task13_EMA4', ...
        'Task14_MentalMath', ...
        'Task15_Stroop', ...
        'Task16_StressPic2', ...
        'Task17_EMA5', ...
        'Task18_March'
        };

    % read data file
    load(fp_in_data); 
    
    % read lab timing file
    [ndata, tdata, ~] = xlsread(fp_in_timing);
    dominant_hand = tdata(11,12);
    computer_os = computer('arch');

    % get date, xlsread date field depends on os
    if startsWith(computer_os, 'mac')
        date = datenum(ndata(3,1)+693960);
    elseif startsWith(computer_os, 'win')
        date = datenum(tdata(5,2));
    end

    % segment data file based on lab timing
    for i=1:length(task_names)
        start_time = date + ndata(4+i,1); % start with ndata(5,1) 
        end_time = date + ndata(5+i,1);

        task_name = task_names{i};
        fprintf('--------------------------------\n');
        fprintf('%s\n', task_name)  

        if strcmp(device, 'firstbeat')
            rr = firstbeat_rr;
            rr_t = firstbeat_rr_t;
            acc = firstbeat_acc;
            acc_t = firstbeat_acc_t;
        elseif strcmp(device, 'msband')
            % nondominant hand has less movement, is more accurate
            if strcmp(dominant_hand, 'LEFT')
                rr = msband_right_rr;
                rr_t = msband_right_rr_t;
                acc = msband_right_acc;
                acc_t = msband_right_acc_t;
            elseif strcmp(dominant_hand, 'RIGHT')
                rr = msband_left_rr;
                rr_t = msband_left_rr_t;  
                acc = msband_left_acc;
                acc_t = msband_left_acc_t;
            end
        elseif strcmp(device, 'e4')
            if strcmp(dominant_hand, 'LEFT')
                rr = e4_right_rr;
                rr_t = e4_right_rr_t;
                acc = e4_right_acc;
                acc_t = e4_right_acc_t;
                sc = e4_right_sc;
                sc_t = e4_right_sc_t;
            elseif strcmp(dominant_hand, 'RIGHT')
                rr = e4_left_rr;
                rr_t = e4_left_rr_t;
                acc = e4_left_acc;
                acc_t = e4_left_acc_t;
                sc = e4_left_sc;
                sc_t = e4_left_sc_t;
            end
        end    
        
        
        warning('off','MATLAB:xlswrite:AddSheet');
        write_task_to_xlsx(subj_data_dir, subj, device, task_name, start_time, end_time, rr, rr_t, acc, acc_t, sc, sc_t);
        %write_task_to_ibi(subj_data_dir, subj, device, task_name, start_time, end_time, rr, rr_t, acc, acc_t)
    end
end

% save data to xlsx file, each task in a seperate sheet 
function write_task_to_xlsx(subj_data_dir, subj, device, task_name, start_time, end_time, rr, rr_t, acc, acc_t, sc, sc_t)
    fp_out_rr = fullfile(subj_data_dir, sprintf('%s_lab_%s_rr_raw_by_task.xlsx', subj, device));
    fp_out_acc = fullfile(subj_data_dir, sprintf('%s_lab_%s_acc_by_task.xlsx', subj, device));
    fp_out_sc = fullfile(subj_data_dir, sprintf('%s_lab_%s_sc_by_task.xlsx', subj, device));
    if (~isnan(start_time)) && (~isnan(end_time)) && (start_time < end_time) 
        % write rr data to xlsx
        idx_rr = find((rr_t >= start_time) & (rr_t <= end_time));
        if ~isempty(idx_rr)
            seg_rr = rr(idx_rr);             
            seg_rr_t = rr_t(idx_rr);   
            d_rr = horzcat(seg_rr_t, seg_rr);
            xlswrite(fp_out_rr, d_rr, task_name); 
        else
            disp("No rr data found within the range between the given start_time and end_time");
        end
          
        
        % write acc data to xlsx
        idx_acc = find((acc_t >= start_time) & (acc_t <= end_time));
        if ~isempty(idx_acc)
            seg_acc = acc(idx_acc);             
            seg_acc_t = acc_t(idx_acc);   
            d_acc = horzcat(seg_acc_t, seg_acc);
            xlswrite(fp_out_acc, d_acc, task_name);
        else
            disp("No accelerometer data found within the range between the given start_time and end_time");
        end
        
        
        % write sc data to xlsx
        idx_sc = find((sc_t >= start_time) & (sc_t <= end_time));
        if ~isempty(idx_sc)
            seg_sc = sc(idx_sc);             
            seg_sc_t = sc_t(idx_sc);    
            d_sc = horzcat(seg_sc_t, seg_sc);
            xlswrite(fp_out_sc, d_sc, task_name);
        else
            disp("No skin conductance data found within the range between the given start_time and end_time");
        end
        
        
    else
        disp("Invalid start_time or end_time");
    end
end

