%  hr_loadData - Script to load the data from the lab Exp 1
% First use hr_get_data(Subj) to create the local dataset for subject Subj
% Then load the dataset
%
clear variables
if ~exist('SubjID','var') SubjID = 'LWP2_0011'; end
fprintf('\n>>>>  Loading data for subject: %s\n', SubjID);
usrID = ['"' SubjID '"']; 
%dir_data = 'C:\Users\pavelm\Documents\A_Projects\Affect\HRV\Experiment01\Data';
dir_data = 'C:\Users\Sophie\Documents\MATLAB\HR\HR_Data'
dir_current = pwd();

% Activity segments of Laboratory Data Collection
cd(dir_data);
[ndata, tdata, ~] = xlsread('ActivityData.xlsx','Data');
SubjIDs = tdata(1,2:end);
Dates =  tdata(2,2:end);
DatesLab = datenum(Dates);
Segments = tdata(3:end,1);      % Segments of activities

% For each SubjID  e.g., SubjID = 'LWP2_0019';

%for sn = 1:length(SubjID)               %findstrcell(SubjID, word)  if needed
sn = 9; %5 %8
sid = SubjIDs{sn};
% Get the times
%
tsegments = ndata(:,sn) + datenum(Dates{sn});
fnameSave = sprintf('%s_Data.mat',sid);    % Mat file to store the data
if exist(fnameSave,'file')
    load(fnameSave)     % Mat file to store the data e.g., LWP2_0011_Data.mat;
else
    hr_get_data(sid)    % Mat file to store the data e.g., LWP2_0011_Data.mat;
end
cd(dir_current)

%% Extract indeces to the laboratory period identified by the segments
iFB = find((FB_Time_RR    >= tsegments(1)) & (FB_Time_RR   <= tsegments(end)));
iFBA = find((FB_Time_GYR  >= tsegments(1)) & (FB_Time_GYR  <= tsegments(end)));
iE4L = find((E4_Time_RR_L >= tsegments(1)) & (E4_Time_RR_L <= tsegments(end)));
iE4R = find((E4_Time_RR_R >= tsegments(1)) & (E4_Time_RR_R <= tsegments(end)));
iMBL = find((BandTimeRR_L >= tsegments(1)) & (BandTimeRR_L <= tsegments(end)));
iMBR = find((BandTimeRR_R >= tsegments(1)) & (BandTimeRR_R <= tsegments(end)));
iMBQL = find((BandTimeQ_L >= tsegments(1)) & (BandTimeQ_L <= tsegments(end)));
iMBQR = find((BandTimeQ_R >= tsegments(1)) & (BandTimeQ_R <= tsegments(end)));
iMBACCL = find((BandTimeACC_L >= tsegments(1)) & (BandTimeACC_L <= tsegments(end)));
iMBACCR = find((BandTimeACC_R >= tsegments(1)) & (BandTimeACC_R <= tsegments(end)));

% Eliminate the data beyond the laboratory period
FB_RR = FB_RR(iFB);             FB_Time_RR = FB_Time_RR(iFB);
FB_ACC = FB_ACC(iFBA);          FB_Time_GYR = FB_Time_GYR(iFBA);
E4_RR_L = E4_RR_L(iE4L);        E4_Time_RR_L = E4_Time_RR_L(iE4L);
E4_RR_R = E4_RR_R(iE4R);        E4_Time_RR_R = E4_Time_RR_R(iE4R);
BandRR_L = BandRR_L(iMBL);      BandTimeRR_L = BandTimeRR_L(iMBL);
BandRR_R = BandRR_R(iMBR);      BandTimeRR_R = BandTimeRR_R(iMBR);
BandQ_L = BandQ_L(iMBQL);       BandTimeQ_L = BandTimeQ_L(iMBQL);
BandQ_R = BandQ_R(iMBQR);       BandTimeQ_R = BandTimeQ_R(iMBQR);
Band_ACC_L = Band_ACC_L(iMBACCL);         BandTimeACC_L = BandTimeACC_L(iMBACCL);
Band_ACC_R = Band_ACC_R(iMBACCR);         BandTimeACC_R = BandTimeACC_R(iMBACCR);


