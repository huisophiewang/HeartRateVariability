clear all;

% read data file
dir = pwd();
fp = fullfile(dir, 'HeartRate', 'HR_Data', 'tmp_LWP2_0019_HRVAS', 'LWP2_0019_FirstBeat_RR_Task14_MentalMath.ibi');
fileID = fopen(fp, 'r');
r = fscanf(fileID, '%f');
n = length(r);

miss_percent = 0.05;
miss_num = round(miss_percent*length(r));


AR_model = [0.0523    1.0043   -0.0452   -0.1302    0.0540   -0.0672   -0.1204    0.0322    0.0645    0.0183    0.1107];
% figure, plot(r, 'b');
% hold on;
% plot(indices, r(indices), 'b*');
% plot(indices, rhat, 'r*');

% mse = 0;
% for i=1:length(indices)
%     idx = indices(i);
%     mse = mse + (r(idx)-rhat(i))^2;
%     % plot([idx idx], [0.5 r(idx)], 'b:');
% end
% mse

function [indices, rhat] = impute(r, A, c, miss_num)
    % rng(0);
    indices = sort(randsample(length(r), miss_num));
    rhat = zeros(1, miss_num);
    for i=1:length(indices)
        idx = indices(i);
        if idx>k
            r_prev = r(idx-k:idx-1);
            r_prev = fliplr(r_prev);
            rhat(i) = A*r_prev + c;
        else
            rhat(i) = 0;
        end
    end
end
