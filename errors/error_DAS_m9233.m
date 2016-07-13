%% Fast DAQ - module 9233, pg 21, http://www.ni.com/pdf/manuals/373784f.pdf
function [DAS_fast_err_abs]=error_DAS_m9233(signal)
DAS_fast_err_rel=0.0715;                 % as given in link, 0.3 dB
DAS_fast_err_abs=signal*DAS_fast_err_rel;
end