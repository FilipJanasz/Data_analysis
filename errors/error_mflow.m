%% mass flow error calculation, for volumetric flow instruments
function [mass_flow_error_abs]=error_mflow(rho_error_abs,volflow_error_abs,rho,volflow,massflow)
    %error propagation during multiplication
    %see http://www.rit.edu/cos/uphysics/uncertainties/Uncertaintiespart2.html
    mass_flow_error_abs=sqrt((rho_error_abs/rho)^2+(volflow_error_abs/volflow)^2)*massflow;
end