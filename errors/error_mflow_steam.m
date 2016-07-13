function mflow_error_abs=error_mflow_steam(power,evapheat,mflow,power_error,evapheat_error)
%error propagation during multiplication
%see http://www.rit.edu/cos/uphysics/uncertainties/Uncertaintiespart2.html
mflow_error_abs=sqrt((power_error/power)^2+(evapheat_error/evapheat)^2)*mflow;
end