%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors:
%   Sophie Wang (huiwang@ccs.neu.edu)
% Description:
%   Script to demonstrate the use of hr_getData2
% Dependencies:
%   external: hr_getData2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
[code_dir, ~] =fileparts(mfilename('fullpath')); % get the folder of current file ('HRV_tools')
proj_dir = fullfile(code_dir, '..', '..'); % get project directory (two levels up, 'Data-Analysis')

% set input parameters


subjs = {'LWP2_0019'};
for i=1:length(subjs)
    disp(i);
    s = char(subjs(i));
    disp(s);
    hr_getData2(proj_dir, s);
end
