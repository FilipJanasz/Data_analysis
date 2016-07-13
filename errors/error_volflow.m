function volflow_error_total_absolute=error_volflow(volflow)
 % due to flow meter
        volflow_error_relative=0.016;   % relative http://www.yokogawa.com/us/products/field-instruments/flowmeters/variable-area-flow-meter-rotameters/ramc.htm?t=1
        % due to module 9203            pg 18 http://www.ni.com/pdf/manuals/375101c.pdf
        [DAS_volflow_err_relative, DAS_volflow_err_abs]=error_DAS_m9203(volflow,5/3600);
        % total
        volflow_error_total_relative=sqrt(volflow_error_relative^2+DAS_volflow_err_relative^2);
        volflow_error_total_absolute=volflow_error_total_relative*volflow;
end