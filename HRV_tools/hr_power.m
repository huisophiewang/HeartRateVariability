function [LF_power, HF_power] = hr_power(rr, rr_t, method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description: 
%   Compute LF and HF power of input rr signal
% Inputs:
%   rr              - a sequence of rr intervals (in seconds)
%   rr_t            - timestamps associated with each R event (in seconds)
%   method          - the method used to compute PSD, options are 'FFT', 'PDG' or 'LS'
% Outputs:
%   LF_power        - low freq power (0.04 ~ 0.15 Hz)
%   HF_power        - high freq power (0.15 ~ 0.4 Hz)
% Dependencies:
%   internal: compute_power_fft, compute_power_periodogram, compute_power_LombScargle
% Note:
%   All the time format used here has to be in seconds, 
%   computing power by fft, LombScargle doesn't work with matlab datenum format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmp(method,'FFT')
        [LF_power, HF_power] = compute_power_fft(rr, rr_t);
    elseif strcmp(method, 'PDG')
        [LF_power, HF_power] = compute_power_periodogram(rr, rr_t);
    elseif strcmp(method, 'LS')
        [LF_power, HF_power] = compute_power_LombScargle(rr, rr_t);
    else
        disp("Invalid method.");
    end
    
end

function [LF_power, HF_power] = compute_power_fft(rr, rr_t)
% estimate PSD by FFT, result is the same as periodogram

    % interpolate and resample to 4Hz
    fs = 4;
    rr_t_resample = rr_t(1):1/fs:rr_t(end);
    rr_resample = interp1(rr_t, rr, rr_t_resample, 'spline');

    % PSD estimation with FFT
    N = length(rr_resample);
    dft_rr = fft(rr_resample);
    psd = 1/(fs*N)*(abs(dft_rr)).^2 ;  % P(f) = delta_t/N * |X(f)|^2
    psd = psd(1:floor(N/2)+1);  % reduce to half length
    psd(2:end-1) = 2*psd(2:end-1);  % nonzero freq power multiply by 2
    freq = 0:fs/N:fs/2;   
    
    % integration/summation                                      
    % LF: 0.04 Hz ~ 0.15 Hz
    % HF: 0.15 Hz ~ 0.4 Hz
    LF_indices = find(freq>=0.04 & freq<=0.15);
    LF_power = sum(psd(LF_indices));
    
    HF_indices = find(freq>=0.15 & freq<=0.4);
    HF_power = sum(psd(HF_indices));

end 


function [LF_power, HF_power] = compute_power_periodogram(rr, rr_t)
% estimate PSD by periodogram, result is the same as FFT

    % interpolate and resample to 4Hz
    fs = 4;
    rr_t_resample = rr_t(1):1/fs:rr_t(end);
    rr_resample = interp1(rr_t, rr, rr_t_resample, 'spline');
    
    N = length(rr_resample);
    [psd, freq] = periodogram(rr_resample, rectwin(N), N, fs);   
    
    % integration/summation                                      
    % LF: 0.04 Hz ~ 0.15 Hz
    % HF: 0.15 Hz ~ 0.4 Hz
    LF_indices = find(freq>=0.04 & freq<=0.15);
    LF_power = sum(psd(LF_indices));
    
    HF_indices = find(freq>=0.15 & freq<=0.4);
    HF_power = sum(psd(HF_indices));
end


function [LF_power, HF_power] = compute_power_LombScargle(rr, rr_t)
% estimate PSD by LombScargle, no need to resample, 
% result is different from FFT and periodogram, 
% result is larger because of more points (smaller interval) in f domain

    [psd, freq] = plomb(rr, rr_t);
    
    % integration/summation                                      
    % LF: 0.04 Hz ~ 0.15 Hz
    % HF: 0.15 Hz ~ 0.4 Hz
    LF_indices = find(freq>=0.04 & freq<=0.15);
    LF_power = sum(psd(LF_indices));
    
    HF_indices = find(freq>=0.15 & freq<=0.4);
    HF_power = sum(psd(HF_indices));
end
