function sc_util_writeSC(proj_dir, subj, sc, sc_t, time_format)
    f_out = sprintf('%s_lab_e4_sc_%s.txt', subj, time_format);
    subj_data_dir = fullfile(proj_dir, 'HRV', 'data', 'LWP2', subj);
    addpath(subj_data_dir);
    fp_out = fullfile(subj_data_dir, f_out);
    
    if strcmp(time_format, 'sec')
        sc_t = sc_t.*(24*3600);
        sc_t = sc_t - sc_t(1);
        format = '%.2f %f\n';
    elseif strcmp(time_format, 'datenum')
        format = '%.6f,%.3f\n';
    end
    
    m = horzcat(sc_t, sc);
    f_id = fopen(fp_out,'w');
    fprintf(f_id, format, m.');
    fclose(f_id);