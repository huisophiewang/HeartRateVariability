function image_timings = sc_util_getImageTiming(proj_dir, subj)
    subj_dir = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj);
    fp_in_timing = fullfile(subj_dir, sprintf('%s_lab_timing.xlsx', subj));

    [ndata, tdata, ~] = xlsread(fp_in_timing);
    task_timings = ndata(4:end,1);
    computer_os = computer('arch');
    if startsWith(computer_os, 'mac')
        date = datenum(ndata(3,1)+693960);
    elseif startsWith(computer_os, 'win')
        date = datenum(tdata(5,2));
    end
    task_start_time = (date + task_timings(5,1))*24*3600;

    image_timings = date + ndata(:,7); 
    image_timings = image_timings.*24*3600 - task_start_time;
end
