function htc=htc_gnielinski(reynolds,thermcond,prandtl,hydraulic_diam)
    % check on wiki
    % https://en.wikipedia.org/wiki/Nusselt_number
    darcy_friction_factor=(0.79*log(reynolds)-1.64)^(-2);
    htc=(((darcy_friction_factor/8)*(reynolds-1000)*prandtl)/(1+12.7*(darcy_friction_factor/8)^0.5*(prandtl^(2/3)-1)))*thermcond/hydraulic_diam;
end