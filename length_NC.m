function nc_length=length_NC(test_T,test_press,N2_moles,He_moles,NC_moles_total)
    
    %T in Kelvin
    %P in bar
    
    reset(symengine)
    
    %ideal gas vs redlich kwong equation
    eos=2;
    
    %critical pressure in Bar http://en.wikipedia.org/wiki/Critical_point_%28thermodynamics%29
    pc_N2=33.9;
    pc_He=2.27;
%     pc_h2o=220.6;

    pc(1)=pc_N2;
    pc(2)=pc_He;    %put critical pressure values (pc's) into one var for Equation Of State
%     pc(3)=pc_h2o;

    %critical temperature in K http://en.wikipedia.org/wiki/Critical_point_%28thermodynamics%29
    Tc_N2=123.21;
    Tc_He=5.19;
%     Tc_h2o=647.096;

    Tc(1)=Tc_N2;
    Tc(2)=Tc_He;    %put Tc's into one var for Equation Of State
%     Tc(3)=Tc_h2o;
    
    %gas contant
    R=8.31;
    
    % moles and fractions
    mole_fr(1)=N2_moles/NC_moles_total;
    mole_fr(2)=He_moles/NC_moles_total;
%     mole_fr(3)=0; %assuming no steam in NC mixture
    
    % mixture_components=length(mass_fr);
    mixture_components=length(mole_fr);
    
    %% check applicability condition (for all mixture components p/pc > T/2*Tc) for Redlich Kwong

    RK_app=zeros(1,mixture_components);
    for i=1:mixture_components
        RK_app(i)=test_press/pc(i)/(test_T/2/Tc(i));
        if RK_app(i)>1 && eos==2;
             warning('Redlich-Kwong equation not applicable - for a mixture component the condition is not met (p/pc > T/2*Tc), forcing ideal gas equation')
             eos=1;
        end
    end
    %% Define state equation - Redlich-Kwong equation (for three species in heater tank) or ideal gas
    if eos==1
        [~,Vm_fun,~]=ideal_gas(R);
    elseif eos==2
        [~,Vm_fun,~]=Redlich_Kwong(R,Tc,pc,mole_fr);
    end
    
    %from equation of state get molar volume (i.e. m3/mol)
    molar_Vol=Vm_fun(test_press*100000,test_T);
    molar_Vol=real(molar_Vol(1));
    
    %get volume
    volume=NC_moles_total*molar_Vol;
    
    %from volume, get length of tube (divide by tube crossection)
    nc_length=volume/(pi*0.01^2);
       
    
end