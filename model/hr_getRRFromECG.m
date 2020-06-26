clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('code')
proj_dir = fullfile(code_dir, '..'); % ('WESAD')


subj = 'S6';
fp_in = fullfile(proj_dir, 'data', subj, sprintf('%s_ECG.csv', subj));
fp_out = fullfile(proj_dir, 'data', subj, sprintf('%s_RR.csv', subj));

%% read raw ECG signal, sampling rate 700 Hz

d_in = dlmread(fp_in);
t = d_in(:,1);
ecg = d_in(:,2);
fs_ecg = 700;

% [rr,fs_rr]=ECG_to_RRI(ecg, fs_ecg, 'AAR', 'Y');

%% get RR interval from ECG signal, using Pan & Tompkins algorithm
[rr,qrs_i_raw,delay] = tool_pan_tompkin(ecg, fs_ecg, 1);
% delay is always 52.5, what to do with it?

%% write RR and RR_t 
rr_t = cumsum(rr);
rr_t = [0, rr_t(1:length(rr_t)-1)];
figure;
plot(rr_t, rr);
d_out = vertcat(rr_t, rr);
f_id = fopen(fp_out,'w');
fprintf(f_id, '%.3f,%.3f\n', d_out);
fclose(f_id);
