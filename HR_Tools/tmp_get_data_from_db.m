clear all
all_subjs = {'LWP2_0017', 'LWP2_0015', 'LWP2_0013', ...
        'LWP2_0009', 'LWP2_0007', 'LWP2_0005', 'LWP2_0003'};
    
one_subj = 'LWP2_0011';
for i=1:length(all_subjs)
    subj = all_subjs(i);
    disp(subj); 
    hr_get_data(char(subj));
end