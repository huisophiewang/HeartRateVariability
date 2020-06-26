clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

subj = 'LWP2_0019';
nsigma = 2;

% read data
[rr_fb, rr_t_fb, rr_ms, rr_t_ms, rr_e4, rr_t_e4] = get_lab_data(proj_dir, subj);
% rr = rr_fb;
% rr_t = rr_t_fb;

rr = rr_ms;
rr_t = rr_t_ms;

% compute Laplacian of RR
laplacian = [1 -2 1];
y = conv(rr, laplacian);

% remove boundary points, 
% make sure the length of RR and Laplacian match
y = y(2:end-1);
y(1) = 0;
y(end) = 0;

% Plot pdf of Laplacian
figure;
[N, edges] = histcounts(y, 200, 'Normalization', 'pdf');
histogram('BinEdges',edges,'BinCounts',N);
hold on;
[var, mu, ~] = robustcov(y);
sigma = sqrt(var);
y_normal = normpdf(edges, mu, sigma);
plot(edges, y_normal);
xticks(linspace(-2,2,41));
title(sprintf('%s -- pdf of laplacian', subj), 'Interpreter', 'none');

% positive y 
idx_y_pos = find(y>0);
y_pos = y(idx_y_pos);

% histogram, pdf
figure;
[N, edges] = histcounts(y_pos, 100, 'Normalization', 'pdf');
histogram('BinEdges',edges,'BinCounts',N);
hold on;
pd = fitdist(y_pos, 'Exponential');
y_pos_pdf = pdf(pd, edges);
%plot(edges, y_pos_pdf);
%title('positive laplacian');


% boxcox transform
[y_pos_trans, lambda_pos] = boxcox(y_pos);
figure;
[N, edges] = histcounts(y_pos_trans, 100, 'Normalization', 'pdf');
%histogram('BinEdges',edges,'BinCounts',N);
%title('box-cox transform on positive laplacian');

% 3 sigma as outliers
[y_pos_var, y_pos_mu, ~] = robustcov(y_pos_trans);
y_pos_sigma = sqrt(y_pos_var);
idx = find(y_pos_trans > y_pos_mu + nsigma*y_pos_sigma);
i_short_outliers = idx_y_pos(idx);

% negative y
idx_y_neg = find(y<0);
y_neg = y(idx_y_neg);

% histogram, pdf
figure;
[N, edges] = histcounts(abs(y_neg), 100, 'Normalization', 'pdf');
histogram('BinEdges',edges,'BinCounts',N);
hold on;
pd = fitdist(abs(y_neg), 'Exponential');
y_neg_pdf = pdf(pd, edges);
%plot(edges, y_neg_pdf);
%title('negative laplacian');

% box cox transform
[y_neg_trans, lambda_neg] = boxcox(abs(y_neg));
figure;
[N, edges] = histcounts(y_neg_trans, 100, 'Normalization', 'pdf');
%histogram('BinEdges',edges,'BinCounts',N);
%title('box-cox transform on negative laplacian');

% 3 sigma as outliers
[y_neg_var, y_neg_mu, ~] = robustcov(y_neg_trans);
y_neg_sigma = sqrt(y_neg_var);
idx = find(y_neg_trans > y_neg_mu + nsigma*y_neg_sigma);
i_long_outliers = idx_y_neg(idx);



%fit Gaussian Mixture Model to RR
% gmm = fitgmdist(rr,2);
% mu1 = gmm.mu(1);
% mu2 = gmm.mu(2);
% sigma1 = sqrt(gmm.Sigma(1));
% sigma2 = sqrt(gmm.Sigma(2));
% p1 = gmm.ComponentProportion(1);
% p2 = gmm.ComponentProportion(2);
% 
% figure;
% [N, edges] = histcounts(rr, 100, 'Normalization', 'pdf');
% histogram('BinEdges',edges,'BinCounts',N);
% hold on;
% 
% gaussian1 = p1*normpdf(edges, mu1, sigma1);
% plot(edges, gaussian1);
% gaussian2 = p2*normpdf(edges, mu2, sigma2);
% plot(edges, gaussian2);



% plot RR and Laplacian, 
% mark outliers
figure;
ax1 = subplot(2,1,1);
plot(rr_t, rr, 'b.-', 'MarkerSize',8); 
datetick('x');
hold on;
plot(rr_t(i_short_outliers), rr(i_short_outliers),'*m');
plot(rr_t(i_long_outliers), rr(i_long_outliers),'*r');
title(sprintf('%s -- RR', subj), 'Interpreter', 'none');

ax2 = subplot(2,1,2);
plot(rr_t, y, 'b.-', 'MarkerSize',8);
datetick('x');
hold on;
plot(rr_t(i_short_outliers), y(i_short_outliers),'*m');
plot(rr_t(i_long_outliers), y(i_long_outliers),'*r');
title(sprintf('%s -- Laplacian of RR', subj), 'Interpreter', 'none');

linkaxes([ax1,ax2],'x');

function [rr_firstbeat, rr_t_firstbeat, rr_msband, rr_t_msband, rr_e4, rr_t_e4] = get_lab_data(proj_dir, subj)
    subj_data_dir = fullfile(proj_dir, 'HRV', 'HRV_data', subj);
    addpath(subj_data_dir);
    f_in_data = sprintf('%s_lab_data.mat', subj);
    load(f_in_data);
    
    rr_firstbeat = firstbeat_rr;
    rr_t_firstbeat = firstbeat_rr_t;
    
    fp_in_timing = fullfile(subj_data_dir, sprintf('%s_lab_timing.xlsx', subj));
    [ndata, tdata, ~] = xlsread(fp_in_timing);
    dominant_hand = tdata(11,12);
    if strcmp(dominant_hand, 'LEFT')
        rr_msband = msband_right_rr;
        rr_t_msband = msband_right_rr_t;
        rr_e4 = e4_right_rr;
        rr_t_e4 = e4_right_rr_t;
    elseif strcmp(dominant_hand, 'RIGHT')
        rr_msband = msband_left_rr;
        rr_t_msband = msband_left_rr_t;  
        rr_e4 = e4_left_rr;
        rr_t_e4 = e4_left_rr_t;
    end
    
end