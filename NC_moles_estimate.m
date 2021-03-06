function NC_moles_per_height=NC_moles_estimate(T,test_press,NC_mole_fraction,N2_moles,He_moles,NC_moles_total,eos)
    
    %calculate amount of NC moles per height based on recorded temperatures in the tube
    
    %T in Kelvin
    %P in bar
    
    %ideal gas vs redlich kwong equation
    % eos=1 - ideal gas
    % eos=2 - Redlich Kwong
    
    %critical pressure in Bar http://en.wikipedia.org/wiki/Critical_point_%28thermodynamics%29
    pc_N2=33.94;
    pc_He=2.27;
    pc_h2o=220.6;

    pc(1)=pc_N2;
    pc(2)=pc_He;    %put critical pressure values (pc's) into one var for Equation Of State
    pc(3)=pc_h2o;

    %critical temperature in K http://en.wikipedia.org/wiki/Critical_point_%28thermodynamics%29
    Tc_N2=126.2;
    Tc_He=5.19;
    Tc_h2o=647.096;

    Tc(1)=Tc_N2;
    Tc(2)=Tc_He;    %put Tc's into one var for Equation Of State
    Tc(3)=Tc_h2o;
    
    %gas contant
    R=8.31;
    
    % moles and fractions  - this part assumes no strartification of N2 and He in NC mixture
    mole_fr(1)=NC_mole_fraction*N2_moles/NC_moles_total;  %N2
    mole_fr(2)=NC_mole_fraction*He_moles/NC_moles_total;  %He
    mole_fr(3)=1-NC_mole_fraction;                        %H2O
    
    % mixture_components=length(mass_fr);
    mixture_components=length(mole_fr);
    
    %% check applicability condition (for all mixture components p/pc > T/2*Tc) for Redlich Kwong
    if eos==2;
        reset(symengine)
        RK_app=zeros(1,mixture_components);
        for i=1:mixture_components
            RK_app(i)=test_press/pc(i)/(T/2/Tc(i));
            if RK_app(i)>1
                 warning('Redlich-Kwong equation not applicable - for a mixture component the condition is not met (p/pc > T/2*Tc), forcing ideal gas equation')
                 eos=1;
            end
        end
    end
    %% Define state equation - Redlich-Kwong equation (for three species in heater tank) or ideal gas
    if eos==1
        %[~,Vm_fun,~]=ideal_gas(R);
        Vm_fun=@(P,T) R*T/P;  %simplify maths
    elseif eos==2
        [~,Vm_fun,~]=Redlich_Kwong(R,Tc,pc,mole_fr);
    end
    
    %from equation of state get molar volume (i.e. m3/mol)
    molar_Vol=Vm_fun(test_press*100000,T);
    molar_Vol=real(molar_Vol(1));
    
    %estimate the moles per height 
    NC_moles_per_height=1/molar_Vol*(pi*0.01^2)*NC_mole_fraction;  % mol / m
    
end