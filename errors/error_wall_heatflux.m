function wall_heatflux_error_abs=error_wall_heatflux(wall_heatflux,wall_htc,dT,wall_htc_error,dT_error)
    wall_heatflux_error_abs=sqrt((wall_htc_error/wall_htc)^2+(dT_error/dT)^2)*wall_heatflux;
end