function power_err_abs=error_coolantpower(mflow,specheat,dT,power,mflow_err_abs,specheat_err_abs,dT_err_abs)
    %error propagation during multiplication
    %see http://www.rit.edu/cos/uphysics/uncertainties/Uncertaintiespart2.html
    power_err_abs=sqrt((mflow_err_abs/mflow)^2+(specheat_err_abs/specheat)^2+(dT_err_abs/dT)^2)*power;
end