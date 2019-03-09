%% Thermocouple - module 9215, 0.02% http://www.ni.com/pdf/manuals/373779f.pdf page 22
function [DAS_fast_err_abs,DAS_fast_err_rel]=error_DAS_m9215(signal)
    DAS_fast_err_rel=0.0002;                 % as given in link, 0.02%
    DAS_fast_err_abs=signal*DAS_fast_err_rel+0.001456 ;
%     DAS_fast_err_rel=signal/DAS_fast_err_abs;
end
