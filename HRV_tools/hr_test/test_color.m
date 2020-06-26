clear all;

x = linspace(0,10*pi);
% y1 = 1;
% y2 = -1;
% figure;
% plot(x, y1)
% hold on
% plot(x, y2)

figure;
%fill([0, 35, 35, 0], [0, 0, 1, 1], [0 0.85 0.25])
%alpha 0.5

% neutral: grey 0.7 0.7 0.7
% relax: light blue 0.5 0.7 1.0
% mental stress: pink 1 0.5 0.5
% physical stress: light orange 1.0 0.7 0.4
patch([0, 35, 35, 0], [0, 0, 1, 1], [0.5 0.7 1.0], 'FaceAlpha', 0.3, 'LineStyle', '--');

%patch([x fliplr(x)], [y1 fliplr(y2)], [1 .8 .8])


%fill([ts, ts(end) ts(1)], [pdriver,0,0],[.4 .6 .8])

