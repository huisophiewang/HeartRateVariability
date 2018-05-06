clear all
all_subjs = {'LWP2_0019'};
    
% one_subj = 'LWP2_0015';
% hr_get_data(one_subj);

for i=1:length(all_subjs)
    subj = all_subjs(i);

    disp(subj); 
    hr_get_data(char(subj));
end