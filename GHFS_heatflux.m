function [hf,ghfs_raw_offset]=GHFS_heatflux(ghfs_raw,ghfs_area,ghfs_temp,ghfs_amplification,GHFS_offset,GHFS_sensitivity)
    ghfs_area=ghfs_area/1000000; %convert mm^2 to m^2
%     hf=ghfs_raw.var./(ghfs_area*0.00025*ghfs_amplification);
    ghfs_raw_offset=ghfs_raw.var-GHFS_offset;
%     hf=abs(ghfs_raw_offset)./(ghfs_area*GHFS_sensitivity*ghfs_amplification);
    hf=abs(ghfs_raw_offset)./GHFS_sensitivity;
end