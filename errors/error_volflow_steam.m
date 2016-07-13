function vflow_error_abs=error_volflow_steam(vflow,mflow,rho,mflow_error,rho_error)
    %error propagation during multiplication
    %see http://www.rit.edu/cos/uphysics/uncertainties/Uncertaintiespart2.html
    vflow_error_abs=sqrt((rho_error/rho)^2+(mflow_error/mflow)^2)*vflow;
end