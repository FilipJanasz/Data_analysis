function [press_error_totalAbs,press_error_totalRel]=error_press(press)
% due to pressure transducer
    press_error_relative=0.005;    % relative Keller Series 35 X HTC http://www.keller-druck.com/picts/pdf/engl/35xhtc_e.pdf
    press_error_abs=press*press_error_relative;
    % due to module 9208
    [DAS_P_err_rel,DAS_P_err_abs]=error_DAS_m9208(press,10);
    % total
    press_error_totalAbs=sqrt(press_error_abs.^2+DAS_P_err_abs.^2);
    press_error_totalRel=sqrt(press_error_relative.^2+DAS_P_err_rel.^2);
end