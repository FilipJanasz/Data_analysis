%% dT error between two PT100
function [dt_pt100_error_abs]=error_dT(PT100_error_total_abs)
dt_pt100_error_abs=sqrt(2*PT100_error_total_abs^2);
% dt_pt100_error_relative=dt_pt100_error_abs/T_increase;
end