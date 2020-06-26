function sc_draw_phasic_driver(sc_t, phasic_driver, peak_time, peak_amp, img_timings, task_timings)
    % draw phasic driver 
    figure;
    plot(sc_t, phasic_driver);
    hold on;

    % draw impulse
    y_range = get(gca,'YLim');
    y_min = y_range(1);
    y_max = y_range(2);
    
    max_peak_amp = max(peak_amp);
    peak_amp = peak_amp./max_peak_amp;
    for i=1:length(peak_time)
        p1 = line([peak_time(i), peak_time(i)], [y_min, y_max*peak_amp(i)], 'Color',[0.9,0.2,0.5], 'LineStyle', ':');
    end
    
    % draw task timing
    if ~isempty(task_timings)
        num_task = length(task_timings);
        for j=1:num_task
            p = line([task_timings(j), task_timings(j)], [y_min, y_max], 'Color',[0,0,1.0]);
        end
    end
    
    % draw image timing
    num_img = length(img_timings);
    for i=1:num_img
        p = line([img_timings(i), img_timings(i)], [y_min, y_max], 'Color',[0,1.0,0.5]);
    end
    
    if isempty(task_timings)
        xticks(img_timings);
        xticklabels({1:num_img});
        title('Phasic Driver of IAPS image viewing session');
        xlabel('Image ID');
        ylabel('Phasic Driver Amplitude [microSiemens]');
    end
end
