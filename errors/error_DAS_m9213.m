%% Thermocouple - module 9213, pg 21 and 25, http://www.ni.com/pdf/manuals/372499b.pdf
function [DAS_TC_err_abs]=error_DAS_m9213(T)
% T_voltage=f_TC_temp_to_volt(T)         % convert T into voltage, according to type K TC properties
% seebeck_K=39;                           % micro volts per celsius
% TC_gain_err_rel=0.0003;                 % in high-resolution mode
% TC_offset_err_abs=6;                    % micro volts, in high-resolution mode
% % TC_offset_err_sImpedance_abs=0.05;    % micro volts, per ohm greater than 50
% % TC_cJuntcionComp_abs=1.7;             % degrees celsius, 1.7 - maximum, 0.8 typical
% 
% DAS_TC_err_abs_uvolts=T_voltage*TC_gain_err_rel+TC_offset_err_abs % error in micro volts
% DAS_TC_err_abs=DAS_TC_err_abs_uvolts/seebeck_K                    % error in Kelvins
% % DAS_TC_err_relative=DAS_TC_err_abs_uvolts/T_voltage;
% % DAS_TC_err_abs=T*DAS_TC_err_relative;

DAS_TC_err_abs=1;                  % degrees celsius - figure, pg 25, high res, room temp. (module)
end