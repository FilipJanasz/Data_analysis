function wall_heatflux_error_abs=error_wall_heatflux_GHFS(wall_heatflux,wall_htc,dT,wall_htc_error,dT_error)
    dS_err_REL=0.05;
    wall_heatflux_error_abs=sqrt((wall_htc_error/wall_htc)^2+(dT_error/dT)^2+dS_err_REL^2)*wall_heatflux;
end