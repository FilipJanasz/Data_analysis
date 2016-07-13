%% Fast DAQ - module 9203, pg 12, http://www.ni.com/pdf/manuals/374070c.pdf
function [DAS_signal_err_rel,DAS_signal_err_abs]=error_DAS_m9203(signal,range)
DAS_gain_err_rel=0.004;
DAS_offset_err_rel=0.0002*range;         % [mA], calibrated at 23degress operating temp
DAS_signal_err_abs=signal*DAS_gain_err_rel+DAS_offset_err_rel;
DAS_signal_err_rel=DAS_signal_err_abs/signal;
end