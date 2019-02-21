function ft=MP1filmthick(MPvolt)
    % used data from : D:\Movable Probe\Probe Calibration_Guillaume\05.11.2015 bis\increase
%     fitCoef=[-1.3408, 2.9090, -1.8833, 0.4766, 0.6014];
if MPvolt>1
     fitCoef=[-12.1559,  81.0235, -199.4046,  215.8455,  -86.1974];
else
    fitCoef=[-12.1559,   36.7760,  -38.6083,   17.5744,  -2.1839];
end
    ft=fitCoef(1).*MPvolt.^4+fitCoef(2).*MPvolt.^3+fitCoef(3).*MPvolt.^2+fitCoef(4).*MPvolt+fitCoef(5);

end