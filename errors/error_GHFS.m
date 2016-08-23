function err_GHFS_abs=error_GHFS(ghfs,ghfs_raw) 
    
    [~,NI9215_err_rel]=error_DAS_m9215(ghfs_raw);
    pixel_size=0.0005/55.16;
    length_err_rel=2*pixel_size/0.00953295;
    Area_err_rel=2*length_err_rel;

    % based on values for JUMO TYA 201 power controller, see documentation at: 
    % http://www.jumo.de/attachments/JUMO/attachmentdownload?id=10328&filename=t70.9061en.pdf,
    % pg4: +/- 1% for current and voltage

    volt_err_rel=0.01;
    current_err_rel=0.01;

    receiving_area_err_rel=0.0001/(pi*0.021*0.12);
    s0_err_rel=NI9215_err_rel+Area_err_rel+volt_err_rel+current_err_rel+receiving_area_err_rel;

    err_GHFS_rel=s0_err_rel+NI9215_err_rel+Area_err_rel;
    err_GHFS_abs=err_GHFS_rel*ghfs_raw;
end