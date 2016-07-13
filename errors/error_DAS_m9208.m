%% Fast DAQ - module 9208, pg 14, http://www.ni.com/pdf/manuals/375170a.pdf
function [DAS_signal_err_rel,DAS_signal_err_abs]=error_DAS_m9208(signal,range)
DAS_gain_err_rel=0.0076;
DAS_offset_err_rel=0.0004*range*1.1;  % [mA], range is 22mA
DAS_signal_err_abs=signal*DAS_gain_err_rel+DAS_offset_err_rel;
DAS_signal_err_rel=DAS_signal_err_abs/signal;
end