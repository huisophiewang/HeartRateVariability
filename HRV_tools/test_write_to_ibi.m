% write files
dir_out = fullfile(dir, 'HeartRate', 'HR_Data', sprintf('tmp_LWP2_%s_HRVAS', subj));
mkdir(dir_out);
write_to_ibi(RR_clean, dir_out, subj, device, char(task_name));


function write_to_ibi(RR_clean, dir_out, subj, device, task_name)
    f_out = sprintf('LWP2_%s_%s_RR_%s.ibi', subj, device, strrep(task_name, ' ', ''));
    fp_out = fullfile(dir_out, f_out);
    ibi_file = fopen(fp_out, 'w');
    fprintf(ibi_file,'%.3f\n', RR_clean./1000);
    fclose(ibi_file);
end