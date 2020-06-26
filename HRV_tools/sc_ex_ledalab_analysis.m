clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

subj = 'LWP2_0019';

% read sc
subj_dir = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj);
subj_leda_data = fullfile(subj_dir, 'ledalab_data');
sc_file = fullfile(subj_leda_data, sprintf('%s_sc_all.txt', subj));
m = dlmread(sc_file);
sc_t = m(:,1);
sc_t = sc_t - sc_t(1);
sc = m(:,2);
events = m(:,3);


% read task timing & image timing
fp_in_timing = fullfile(subj_dir, sprintf('%s_lab_timing.xlsx', subj));
[ndata, tdata, ~] = xlsread(fp_in_timing);
computer_os = computer('arch');
if startsWith(computer_os, 'mac')
    date = datenum(ndata(3,1)+693960);
elseif startsWith(computer_os, 'win')
    date = datenum(tdata(5,2));
end

e4_start_time = date + ndata(26,1);
task_timings = date + ndata(4:23,1);
task_timings = (task_timings - e4_start_time)*24*3600;
image_timings = date + ndata(:,7); 
image_timings = (image_timings - e4_start_time)*24*3600;

% % run ledalaab
% Ledalab_path = fullfile(proj_dir, 'HRV', 'ledalab-349');
% addpath(Ledalab_path);
% computer_os = computer('arch');
% if startsWith(computer_os, 'mac')
%     subj_leda_data = strcat(subj_leda_data, '\');
% elseif startsWith(computer_os, 'win')
%     subj_leda_data = strcat(subj_leda_data, '/');
% end
% Ledalab(subj_leda_data, 'open', 'text', 'analyze', 'CDA', 'optimize',6);
% 
% % load variable from ledalab
% global leda2
% phasic_driver = leda2.analysis.driver;
% peak_time = leda2.analysis.impulsePeakTime;
% peak_onset = leda2.analysis.impulseOnset;
% peak_amp = leda2.analysis.impulseAmp;

% read saved processed file
processed_leda_file = fullfile(subj_leda_data, sprintf('%s_sc_all.mat', subj));
load(processed_leda_file);
phasic_driver = analysis.driver;
peak_time = analysis.impulsePeakTime;
peak_onset = analysis.impulseOnset;
peak_amp = analysis.impulseAmp;

%sc_draw_phasic_driver(sc_t, phasic_driver, peak_time, peak_amp, image_timings, task_timings);
%sc_draw_phasic_driver_single_img(sc_t, phasic_driver, peak_time, peak_amp, img_timings, 20);

% bin_width = 10;
% num_bin = ceil(length(sc)/bin_width);
% for i=1:num_bin
%     bin_start = (i-1)*bin_width;
%     bin_end = i*bin_width;
%     idx = find(peak_time >= bin_start & peak_time <= bin_end);
%     count = length(idx);
% end

bin_width = 1;
edges = 0:bin_width:ceil(sc_t(end));
figure;
h = histogram(peak_time, edges);
hold on;
hr_util_addTaskColorToPlot(proj_dir, subj, h, 'phasic peak', 'sec', 1);
    
t = [10, 250, 900, 1300, 1600, 2405, 2900];
r = sc_psth(t,10,1000,3,1000);

function features = get_phasic_driver_features(peak_time, peak_amp, img_timings, num_img)
    % calculate num of impulses in each images
    % each images was shown to the individual for 7 or 8 seconds, then they rate it.
    % SCR typically occurs 1-3s or 1-5s after the stimulus
    % combined, we choose window size 13 seconds
    time_window = 13; 
    features = zeros(num_img, 2);
    for i = 1:1
        img_start_t = img_timings(i);
        img_end_t = img_start_t + time_window;
        indices = find(peak_time > img_start_t & peak_time < img_end_t);

        features(i,1) = length(indices); % number of impulses
        features(i,2) = sum(peak_amp(indices)); % sum of impulse peaks
    end
end


function draw_valence_arousal(features, num_img)
    % get subject's rating of arousal valence
    vals = sc_util_getImgValenceArousal(proj_dir, subj);

    % plot sc impulse features, and arousal valence
    x = 1:num_img;
    figure;
    p1 = subplot(4,1,1);
    plot(x, features(:,1), '--ro');
    xticks(1:num_img);
    xticklabels({1:num_img});
    title('number of impulses');

    p2 = subplot(4,1,2);
    plot(x, features(:,2), '--ro');
    xticks(1:num_img);
    xticklabels({1:num_img});
    title('sum of amplitude of impulses');

    p3 = subplot(4,1,3);
    plot(x, vals(:,1), '--bo');
    ylim([-2 2])
    xticks(1:num_img);
    xticklabels({1:num_img});
    title('Valence');

    p4 = subplot(4,1,4);
    plot(x, vals(:,2), '--bo');
    ylim([1 5])
    xticks(1:num_img);
    xticklabels({1:num_img});
    title('Arousal');
    linkaxes([p1,p2,p3,p4],'x');
    % 
    corrcoef(features(:,1), vals(:,2))
    corrcoef(features(:,2), vals(:,2))
end



