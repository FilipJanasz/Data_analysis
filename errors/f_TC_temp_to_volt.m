function [T_voltage]=f_TC_temp_to_volt(T)

% syms K1 K2 K3 K4 K5 K6 K7 K8 K9 T

K1=-1.8533063273E1;
K2= 3.8918344612E1;
K3= 1.6645154356E-2;
K4=-7.8702374448E-5;
K5= 2.2835785557E-7;
K6=-3.5700231258E-10;
K7= 2.9932909136E-13;
K8=-1.2849848798E-16;
K9= 2.2239974336E-20;

% E=subs(E) % substitutes all symbolic with values from workspace

T_voltage=K1+K2.*T+K3.*T.^2+K4.*T.^3+K5.*T.^4+K6.*T.^5+K7.*T.^6+K8.*T.^7+K9.*T.^8+125.*exp((-0.5).*(T-127).^2/65);
end
