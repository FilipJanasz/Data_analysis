for n=1:5
   sensitivity(n)=GHFS(n).GHFS1_raw.value/(GHFS(n).wall_heatflux_GHFS1.value*GHFS(n).GHFS1.area/1000000*GHFS(n).GHFS1.amplification)
end