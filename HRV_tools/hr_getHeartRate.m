function hr = hr_getHeartRate(rr, rr_t)    
% interpolate and resample to 4Hz
    fs = 4;
    rr_t_resample = rr_t(1):1/fs:rr_t(end);
    rr_resample = interp1(rr_t, rr, rr_t_resample, 'cubic');
    
    hr = 60./rr_resample;
    hr = hr.';
    
    hr = hr - mean(hr);
    
%     figure;
%     subplot(3,1,1);
%     plot(rr_t, rr, 'b.-', 'MarkerSize',8); 
%     ylabel('RR (sec)');
%     title('Raw RR');
% 
%     subplot(3,1,2);
%     plot(rr_t_resample, rr_resample, 'b.-', 'MarkerSize',8); 
%     ylabel('RR (sec)');
%     title('Resampled RR');
%     
%     subplot(3,1,3);
%     plot(rr_t_resample, hr, 'b.-', 'MarkerSize',8); 
%     ylabel('Heart Rate (bpm)');
%     title('Heart Rate');
    
    
end