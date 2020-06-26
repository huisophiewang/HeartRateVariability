% valence range (1 ~ 5)
% arounsal range (1 ~ 5)
function valence_arousal = sc_util_getImgValenceArousal(proj_dir, subj)    
    subj_dir = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj);
    fp_in_timing = fullfile(subj_dir, sprintf('%s_lab_timing.xlsx', subj));
    [ndata, tdata, ~] = xlsread(fp_in_timing);
    ratings = tdata(3:end,7);
    num = length(ratings);
    valence_arousal = zeros(num, 2);
    for i=1:num
        items = split(ratings(i), ',');
        valence = str2num(char(items(1))) - 3;
        valence_arousal(i, 1) = valence;
        arousal = strtrim(items(2));
        arousal = str2num(char(arousal));
        valence_arousal(i, 2) = arousal;
    end
end
