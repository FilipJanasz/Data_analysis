clc
clear all
close all

%% ~~~~~~~~~~~USER INPUT~~~~~~~~~~~~~~~~~~~~~~

    % DEFINE flow parameters
        T_1=310:30:450;         % [K]
        p_1=1:3:10;             % [Bar]
        
        T_2=310:40:450;         % [K]
        p_2=1:3:10;             % [Bar]
        volflow=5/3600;         % [m3/s]
        mflow=1.3744;           % [kg/s]
        T_increase=2;           % [K] allowed increase in coolant water     
        HFS=1;                  % [uV]
        
          
%% ~~~~~~~~~~~BASED ON INFO ABOVE, CALCULATE ERROR~~~~~~~~~~~
 	% tech
        temp_am_coolant=length(T_2);
        p_am_coolant=length(p_2);
        
% ~~~~~~~~~~~~MEASUREMENT + DAS ERROR~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
    %SECONDARY FLOW
    
    % mass flow error
        % due to coriolis flowmeter
        coriolis_mflow_error_relative=0.0005;   % relative coriolis https://portal.endress.com/wa001/dla/5000275/1921/000/01/TI101DEN_0210.pdf
        % due to module 9203                    pg 18 http://www.ni.com/pdf/manuals/375101c.pdf
        [DAS_mflow_err_relative,DAS_mflow_err_abs]=error_DAS_m9203(mflow,1.3744);
        % total
        coriolis_mflow_error_total_relative=sqrt(coriolis_mflow_error_relative^2+DAS_mflow_err_relative^2);
        
    % volflow error
        % due to flow meter
        volflow_error_relative=0.016;   % relative http://www.yokogawa.com/us/products/field-instruments/flowmeters/variable-area-flow-meter-rotameters/ramc.htm?t=1
        % due to module 9203            pg 18 http://www.ni.com/pdf/manuals/375101c.pdf
        [DAS_volflow_err_relative, DAS_volflow_err_abs]=error_DAS_m9203(volflow,5/3600);
        % total
        volflow_error_total_relative=sqrt(volflow_error_relative^2+DAS_volflow_err_relative^2);
        
    % T coolant error 
        % due to PT100
        PT100_error_abs=0.03;               % [K] absolute http://www.priggen.com/index.php?page=shop.product_details&flypage=flypage-ask.tpl&product_id=48&category_id=10&manufacturer_id=11&option=com_virtuemart&Itemid=44&lang=en
        % due to Omega PT-104A (PT100)
        DAS_PT100_err_abs=error_DAS_omega_PT104A;  %[K]
        %total PT100
        PT100_error_total_abs=sqrt(PT100_error_abs^2+DAS_PT100_err_abs^2);    %[K]
        
%         % due to TC
%         TC_error_abs=1.5;               % [K] http://digital.ni.com/public.nsf/allkb/776AB03E065228408625727B00034E20
%         % due to module 9213 (TC)
%         DAS_TC_err_abs=error_DAS_m9213(T_2);
%         % total TC
%         TC_error_total_abs=sqrt(TC_error_abs^2+DAS_TC_err_abs^2);
        
    % pressure coolant error
        % due to pressure transducer
        press_error_relative_2=0.005;    % relative Keller Series 35 X HTC http://www.keller-druck.com/picts/pdf/engl/35xhtc_e.pdf
        press_error_abs_2=p_2*press_error_relative_2;
        % due to module 9208
        [DAS_P_err_rel_2,DAS_P_err_abs_2]=error_DAS_m9208(p_2,10);
        % total
        press_error_total_2=sqrt(press_error_abs_2.^2+DAS_P_err_abs_2.^2);
        
    %PRIMARY FLOW**********************************************************
    
    % heat flux error - HFS error
        % sensor accuracy
        %##########################
        % aplifier/filter induced error
        %##########################
        % error due to module 9233
        DAS_HFS_err_abs=error_DAS_m9233(HFS);
        
    % heat flux error - TC triplet error
        %##########################
        
    % Movable probe - film thickness error
        % stationary part
        % error due to sensor
        %##########################
        % error due to DAS
        %##########################
        
        % movable part
        % error due to encoder
        %##########################
        % error due to DAS (peak recording)
        %##########################
        
    % Movable probe - temperature profile error
        %##########################
        
    % pressure - steam error
        % due to pressure transducer
        press_error_relative_1=0.005;    % relative Keller Series 35 X HTC http://www.keller-druck.com/picts/pdf/engl/35xhtc_e.pdf
        press_error_abs_1=p_1*press_error_relative_1;
        % due to module 9208
        DAS_P_err_abs_1=error_DAS_m9208(p_1,10);
        % total
        press_error_total_1=press_error_abs_1+DAS_P_err_abs_1;
        
           
% ~~~~~~~~~~CALCULATION ERROR~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    % calculated dt coolant error 
        [dt_pt100_error_abs,dt_pt100_error_relative]=error_dT(PT100_error_total_abs,T_increase,temp_am_coolant,p_am_coolant);    % call function that calculates delta T error between two PT100 elements
       
    % steam tables error calculation    
        [rho,rho_error_abs,rho_error_relative,cv,cv_error_relative]=error_IAPWS_97_tables(T_2,p_2,temp_am_coolant,p_am_coolant,press_error_total_2,PT100_error_total_abs);          % call script that calculates errors due use of steam tables

    % mass flow error calculation, from volumetric flow
        [mass_flow_error_relative,mass_flow_error_absolute]=error_mass_flow(rho,volflow,rho_error_relative,volflow_error_total_relative); % call script that calculates errors due to volumetric flow instrument

    % heat flow error calculation
%         rho_error_relative
%         cv_error_relative
%         mass_flow_error_relative
%         coriolis_mflow_error_total_relative
%         dt_pt100_error_relative
        
        Q_error_relative_rotameter=sqrt(mass_flow_error_relative.^2+cv_error_relative.^2+dt_pt100_error_relative.^2);  
        Q_error_relative_coriolis=sqrt(coriolis_mflow_error_total_relative.^2+cv_error_relative.^2+dt_pt100_error_relative.^2);    
        Error_difference=Q_error_relative_rotameter-Q_error_relative_coriolis