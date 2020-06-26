function sc_draw_phasic_driver_single_img(sc_t, phasic_driver, peak_time, peak_amp, img_timings, img_id) 
    y_min = min(phasic_driver);
    y_max = max(phasic_driver);
    % draw phasic driver and impuluse for only one image
    figure;
    start_t = img_timings(img_id);
    end_t = img_timings(img_id+1);
    sc_t_indices = find(sc_t > start_t & sc_t < end_t);
    plot(sc_t(sc_t_indices), phasic_driver(sc_t_indices));
    hold on;
    peak_indices = find(peak_time > start_t & peak_time < end_t);
    for i=1:length(peak_indices)
        index = peak_indices(i);
        time = peak_time(index);
        p = line([time, time], [y_min, peak_amp(index)], 'Color',[0.9,0.2,0.5], 'LineStyle', ':');
    end
    p = line([start_t, start_t], [y_min, y_max], 'Color',[0,1.0,0.5]);
    p = line([end_t, end_t], [y_min, y_max], 'Color',[0,1.0,0.5]);
    title(sprintf('Image %d', img_id));
    
    % draw poisson distribution
    delta_t = 0.1;
    counts = zeros(10,1);
    for t = start_t:delta_t:end_t
        interval_start_t = t;
        interval_end_t = t+delta_t;
        peak_indices = find(peak_time >= interval_start_t & peak_time < interval_end_t);
        if isempty(peak_indices)
            counts(1) = counts(1) + 1;
        else
            num = length(peak_indices);
            counts(num+1) = counts(num+1) + 1;           
        end
    end

    figure;
    counts = counts./sum(counts);
    plot(0:9, counts, 'r');
    hold on;
    peak_num = length(find(peak_time >= start_t & peak_time < end_t));
    lambda = peak_num/((end_t - start_t)/delta_t);
    
    
    x = 0:9;
    y = poisspdf(x,lambda);
    plot(x,y, 'b');
    legend('Actual PDF','Poisson PDF');
end