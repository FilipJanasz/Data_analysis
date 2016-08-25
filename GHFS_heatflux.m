function hf=GHFS_heatflux(ghfs_raw,ghfs_area,ghfs_temp,ghfs_amplification)
    ghfs_area=ghfs_area/1000000; %convert mm^2 to m^2
%     hf=ghfs_raw.var./(ghfs_area*0.00025*ghfs_amplification);
    hf=ghfs_raw.var./(ghfs_area*0.00002*ghfs_amplification);
end