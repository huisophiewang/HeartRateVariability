%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
%   based on https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html
% Description:
%   test power spectral density estimation with different methods
%   including FFT, periodogram, Welch's, LombScargle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

% set subject and task
subj = 'LWP2_0019';  
task = 'Task14_MentalMath';

% read data
f_firstbeat_raw = sprintf('%s_lab_firstbeat_rr_raw_%s.ibi', subj, task);
m_firstbeat_raw = dlmread(fullfile(proj_dir, 'HRV', 'HRV_data', subj, f_firstbeat_raw));
rr_t = m_firstbeat_raw(:,1);
rr = m_firstbeat_raw(:,2);

% resample at 4 Hz
fs = 4;
rr_t_resampled = rr_t(1):1/fs:rr_t(end);
rr_resampled = interp1(rr_t, rr, rr_t_resampled, 'spline');

% estimate PSD with FFT
N = length(rr_resampled);
dft = fft(rr_resampled);
psd_fft = 1/(fs*N)*abs(dft).^2;
psd_fft = psd_fft(1:floor(N/2)+1); 
psd_fft(2:end-1) = 2*psd_fft(2:end-1);
f_fft = 0:fs/N:fs/2;
figure;
subplot(2,1,1);
plot(f_fft(2:end), psd_fft(2:end));
title('FFT PSD');
subplot(2,1,2);
plot(f_fft(2:end), 10*log(psd_fft(2:end)));
title('FFT 10*logPSD');

% estimate PSD with periodgram
[psd_pdg, f_pdg] = periodogram(rr_resampled, rectwin(N), N, fs);   
figure;
subplot(2,1,1);
plot(f_pdg(2:end), psd_pdg(2:end));
title('Periodogram PSD');
subplot(2,1,2);
plot(f_pdg(2:end), 10*log(psd_pdg(2:end)));
title('Periodogram 10*logPSD');

% estimate PSD with Welch's 
[psd_welch, f_welch] = pwelch(rr_resampled,rectwin(N), '', N, fs);   
figure;
subplot(2,1,1);
plot(f_welch(2:end), psd_welch(2:end));
title('Welch PSD');
subplot(2,1,2);
plot(f_welch(2:end), 10*log(psd_welch(2:end)));
title('Welch 10*logPSD');

% estimate PSD with Lomb-Scargle 
[psd_ls, f_ls] = plomb(rr, rr_t);
figure;
subplot(2,1,1);
plot(f_ls(2:end), psd_ls(2:end));
title('Lomb-Scargle PSD');
subplot(2,1,2);
plot(f_ls(2:end), 10*log(psd_ls(2:end)));
title('Lomb-Scargle 10*logPSD');


