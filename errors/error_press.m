function press_error_total=error_press(press)
% due to pressure transducer
    press_error_relative=0.005;    % relative Keller Series 35 X HTC http://www.keller-druck.com/picts/pdf/engl/35xhtc_e.pdf
    press_error_abs=press*press_error_relative;
    % due to module 9208
    [DAS_P_err_rel,DAS_P_err_abs]=error_DAS_m9208(press,10);
    % total
    press_error_total=sqrt(press_error_abs.^2+DAS_P_err_abs.^2);
end