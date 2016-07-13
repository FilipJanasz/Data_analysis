function vel_error=error_velocity(vel,vflow,area,vflow_error,area_error)
    vel_error=sqrt((vflow_error/vflow)^2+(area_error/area)^2)*vel;
end