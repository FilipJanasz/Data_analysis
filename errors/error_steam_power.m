function power_error_abs=error_steam_power(voltage,current,power)
% based on values for JUMO TYA 201 poower controller, see documentation at: 
% http://www.jumo.de/attachments/JUMO/attachmentdownload?id=10328&filename=t70.9061en.pdf,
% pg4: +/- 1% for current and voltage
volt_err=0.01;
current_err=0.01;
power_error_abs=sqrt((volt_err/voltage)^2+(current_err/current)^2)*power;
end