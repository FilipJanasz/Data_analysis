clear
%Solution for continuous NC injection
%Input data
%Molar mass [g/mol]
    mol_m_air=28.966;
    mol_m_N2=28.0134;
    mol_m_He=4;
    rho_He=0.1664;
    mol_m_h2o=18.02;
%Gas constant [Nm/molK]
    R=8.3144621;    
%Pressures [bar]
    p_heaterTank=4.0;
    p_NCtank=8.0;
%Temperatures [K]
    T_heaterTank=IAPWS_IF97('Tsat_p',p_heaterTank/10);
    T_NCtank=273.15+23;
%Volumes [m3]
    vol_heaterTank=0.0040675;
    vol_NCtank=0.00501;
%Geometry
    A_valve=0.00002826; % Swagelok SS-6P4T-MM-BK Di=6 mm
    C_v=1.6; % flow coefficient
    K_v=0.865*C_v; % flow factor
    pos_valv=1.0;
%Time step control 
    dt=1; 
    time=0;
    t_final=1200;
    Nsteps=round(t_final/dt); 
  
%ODE solution
    for i=1:Nsteps
        if p_NCtank <= p_heaterTank+0.03; %+0.03 bar for check valve dp
            break
        elseif p_NCtank > p_heaterTank; %calculates until p-equilibrium is reached
            p_NCtank=p_NCtank*exp(-(pos_valv*A_valve*sqrt(2/rho_He*(p_NCtank-p_heaterTank))/vol_NCtank*dt));
            %p_NCtank=p_NCtank*exp(-(K_v*sqrt(p_NCtank-p_heaterTank))/vol_NCtank*dt);
            time=time+dt;
            v=sqrt(2/rho_He*(p_NCtank-p_heaterTank)); % from Bernoulli
            %v=K_v*sqrt(p_NCtank-p_heaterTank)/A_valve;
            m=v*0.00002826*rho_He; % He mass flow
            figure(1);
            yyaxis left
            y1=p_NCtank;
            plot(time,y1,'*');
            xlabel('Time [s]');
            ylabel('Pressure NC tank [bar]');
            hold on;
            yyaxis right
            y2=v;
            plot(time,y2,'*');
            xlabel('Time [s]');
            ylabel('Volumetric flow [m3/s]');
            hold on;
            figure(2);
            plot(time,m,'*');
            xlabel('Time [s]');
            ylabel('He mass flow [kg/s]');
            hold on;
        end
        
    end
