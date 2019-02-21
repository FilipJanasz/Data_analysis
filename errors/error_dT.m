%% dT error between two PT100
function [dt_error_abs]=error_dT(tempError)
dt_error_abs=2*tempError;
% dt_pt100_error_relative=dt_pt100_error_abs/T_increase;
end