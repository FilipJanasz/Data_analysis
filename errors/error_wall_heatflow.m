function q=error_wall_heatflow(wall_heatflow,wall_heatflux,error_wall_heatflux)
    q=sqrt(error_wall_heatflux/wall_heatflux)^2*wall_heatflow;
end