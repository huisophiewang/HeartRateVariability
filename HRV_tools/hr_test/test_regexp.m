clear all;

str = 'H1, stress level 5, yes';
str2 = 'random text';
pattern = 'stress level (\d+)';

[mat,tok] = regexp(str2, pattern, 'match', 'tokens');
if isempty(mat)
    disp('no match found');
else
    stress = str2num(char(tok{1}));
end
%val = str2num(tok{1,1});
%test = val{1};