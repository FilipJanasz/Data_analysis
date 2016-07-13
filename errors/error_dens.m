function dens_error_abs=error_dens(T,p,error_T_abs,error_P_abs)
    %get derivatives of density with respect to T and p
    [drho_dT,drho_dP]=h2o_dens_derivatives(T+273.15,p/10); %convert C to K and bar to MPa
    
    %error of a property which is a function of another parameter 
    %error = drho_dx*errorX
    error_drho_dP=error_P_abs*drho_dP;
    error_drho_dT=error_T_abs*drho_dT;

    %sum errors due to temp and press measurements
    dens_error_abs=sqrt(abs(error_drho_dP)^2+abs(error_drho_dT)^2);
end