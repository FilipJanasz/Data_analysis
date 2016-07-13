function [drho_dT,drho_dP]=h2o_dens_derivatives(T,p)

    %   v       - specific volume
    %   alfaV   - isobaric cubic expansion coefficient
    %   Kt      - isothermal compressibility
    %   PI      - reduced pressure
    %   tau     - reduced temperature

    R=461.526;      % specific gas constant of water vapor [J/(kg*K)]
    p_star=16.53;   % [MPa]
    t_star=1386;    % [K]

    %% EQUATIONS FROM GIBBS

    %   define coefficients for Gibbs equation

        ireg1=[0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,3,3,3,4,4,4,5,8,8,21,23,29,30,31,32];
        jreg1=[-2,-1,0,1,2,3,4,5,-9,-7,-1,0,1,3,-3,0,1,3,17,-4,0,6,-5,-2,10,-8,-11,-6,-29,-31,-38,-39,-40,-41];    
        nreg1=[0.14632971213167,-0.84548187169114,-3.756360367204,3.3855169168385,-0.95791963387872,0.15772038513228,-0.016616417199501,8.1214629983568E-04,2.8319080123804E-04,...
        -6.0706301565874E-04,-0.018990068218419,-0.032529748770505,-0.021841717175414,-5.283835796993E-05,-4.7184321073267E-04,-3.0001780793026E-04,...
        4.7661393906987E-05,-4.4141845330846E-06,-7.2694996297594E-16,-3.1679644845054E-05,-2.8270797985312E-06,-8.5205128120103E-10,-2.2425281908E-06,...
        -6.5171222895601E-07,-1.4341729937924E-13,-4.0516996860117E-07,-1.2734301741641E-09,-1.7424871230634E-10,-6.8762131295531E-19,1.4478307828521E-20,...
        2.6335781662795E-23,-1.1947622640071E-23,1.8228094581404E-24,-9.3537087292458E-26];

    %ADVISORY NOTE 3 pg 7, bottom
    % v=R*T/p*PI*gamma_pi;
    % Kt=-1/p/PI*gamma_pi_pi/gamma_pi
    % alfaV=1/T*(1-tau*gamma_pi_tau/gamma_pi)

    % gamma_pi - first derivative of gamma with respect to PI
    % gamma_pi_pi - second derivative of gamma with respect to PI
    % gamma_pi_tau - second derivative of gamma with respect to PI and tau

    PI=p/p_star;
    tau=t_star/T;
    gamma_pi=0;
    gamma_pi_pi=0;
    gamma_pi_tau=0;
    gamma_tau_tau=0;

    %TABLE 2.4, pg 27 INTERNATIONAL STEAM TABLES

    for i=1:34
        gamma_pi=gamma_pi-nreg1(i)*ireg1(i)*(7.1-PI)^(ireg1(i)-1)*(tau-1.222)^jreg1(i);
        gamma_pi_pi=gamma_pi_pi+nreg1(i)*ireg1(i)*(ireg1(i)-1)*(7.1-PI)^(ireg1(i)-2)*(tau-1.222)^jreg1(i);
        gamma_pi_tau=gamma_pi_tau-nreg1(i)*ireg1(i)*(7.1-PI)^(ireg1(i)-1)*jreg1(i)*(tau-1.222)^(jreg1(i)-1);
        gamma_tau_tau=gamma_tau_tau+nreg1(i)*(7.1-PI)^ireg1(i)*jreg1(i)*(jreg1(i)-1)*(tau-1.222)^(jreg1(i)-2);
    end

    v=R*T/(p*100000)*PI*gamma_pi;           %100000 factor due to bar to Pa conversion
    Kt=-1/(p*100000)/PI*gamma_pi_pi/gamma_pi;
    alfaV=1/T*(1-tau*gamma_pi_tau/gamma_pi);


    %% SPECIFIC VOLUME / DENISTY DERIVATIVE WITH RESPECT TO PRESSURE UNDER CONSTANT TEMPERATURE

    dvdP=-v*Kt;
    % DUE TO RECIPROCAL RULE
    % as rho=1/v  (http://en.wikipedia.org/wiki/Reciprocal_rule)
    % d(1/f(x))dx=-f'(x)/f(x)^2

    drho_dP=-dvdP/v^2;

    %% SPECIFIC VOLUME / DENISTY DERIVATIVE WITH RESPECT TO TEMPERATURE UNDER CONSTANT PRESSURE

    dvdT=v*alfaV;
    % DUE TO RECIPROCAL RULE
    % as rho=1/v  (http://en.wikipedia.org/wiki/Reciprocal_rule)
    % d(1/f(x))dx=-f'(x)/f(x)^2

    drho_dT=-dvdT/v^2;

end