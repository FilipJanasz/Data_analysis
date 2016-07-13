function [press_NC_tank, press_NC_tank_He]=NCfilling_estimation_fun(mole_fr_h2o,mole_fr_N2,T_room,test_press,eos)
reset(symengine)
    %% PURPOSE OF THIS CODE
    % Define desired test conditions in PRECISE facility - 
    % total pressure and mass fractions of H2O, N2 and He
    % from those, back calculate required amounts
    % of Helium and Nitrogen to be inserted in NC gas tank


    %% GAS PROPERTIES
        %molar mass
%         mol_m_air=28.966;
        mol_m_N2=28.0134;
        mol_m_He=4;
        mol_m_h2o=18.02;

        mol_m(1)=mol_m_N2;
        mol_m(2)=mol_m_He;  %put molar masses into one var for Equation Of State
        mol_m(3)=mol_m_h2o;

        %critical pressure in Bar http://en.wikipedia.org/wiki/Critical_point_%28thermodynamics%29
        pc_N2=33.9;
        pc_He=2.27;
        pc_h2o=220.6;

        pc(1)=pc_N2;
        pc(2)=pc_He;    %put critical pressure values (pc's) into one var for Equation Of State
        pc(3)=pc_h2o;

        %critical temperature in K http://en.wikipedia.org/wiki/Critical_point_%28thermodynamics%29
        Tc_N2=123.21;
        Tc_He=5.19;
        Tc_h2o=647.096;

        Tc(1)=Tc_N2;
        Tc(2)=Tc_He;    %put Tc's into one var for Equation Of State
        Tc(3)=Tc_h2o;

    %gas constant
    R=8.3144621;

    %% GEOMTERY
    vol_heaterTank=0.0040675;
    vol_NCtank=0.00501;
    vol_waterTank=0.0025;

    vol(1)=vol_heaterTank;
    vol(2)=vol_NCtank;
    vol(3)=vol_waterTank;

    %% TEST CONDITIONS
    % mass_fr_h2o=0.8;            %*************************************************
    % mass_fr_He=1;             % mass fraction of helium in NC mixture %**********************************************
    % mass_fr_N2=1-mass_fr_He;
    % 
    % mass_fr(1)=mass_fr_N2*(1-mass_fr_h2o);
    % mass_fr(2)=mass_fr_He*(1-mass_fr_h2o);  %put mass fractions into one var for Equation Of State
    % mass_fr(3)=mass_fr_h2o;

    % mole_fr_h2o=0.8;
    mole_fr_He=1-mole_fr_N2;
    % mole_fr_N2=1-mole_fr_He;

    mole_fr(1)=mole_fr_N2*(1-mole_fr_h2o);
    mole_fr(2)=mole_fr_He*(1-mole_fr_h2o);
    mole_fr(3)=mole_fr_h2o;
    % mixture_components=length(mass_fr);
    mixture_components=length(mole_fr);
    %get mole fractions
    % mole_fr=mass_2_mole_fraction(mol_m,mass_fr);

    % T_room=20; %[degrees celsius]

    % press_total=5;  % [Bar] *******************************************************
    press_part_h2o=test_press*mole_fr(3);
    Tsat=IAPWS_IF97('Tsat_p',press_part_h2o/10);


    

    %% check applicability condition (for all mixture components p/pc > T/2*Tc) for Redlich Kwong

    RK_app=zeros(1,mixture_components);
    for i=1:mixture_components
        RK_app(i)=test_press/pc(i)/(Tsat/2/Tc(i));
        if RK_app(i)>1
             error('Redlich-Kwong equation not applicable - for a mixture component p/pc > T/2*Tc')
        end
    end
    %% Define Redlich-Kwong equation (for three species in heater tank) or ideal gas
    if eos==1
        [press_fun,Vm_fun,T_fun]=ideal_gas(R);
    elseif eos==2
        [press_fun,Vm_fun,T_fun]=Redlich_Kwong(R,Tc,pc,mole_fr);
    end

    %% Calculate facility filling steps
    % Start from the end:
    % 1. Test conditions
    % 2. Cooled down to conditions after filling NC
    % 3. Estimate conditions in NC tank at time of 2
    % 4. Estimate conditions in NC tank before time 2 (before valve is opened
    % and NC gases enter heater tank

    %% From 1. to 2.
    molar_Vol=Vm_fun(test_press*100000,Tsat);
    molar_Vol=real(molar_Vol(1));
    % density=molar_vol_factor/molar_Vol/1000;
    moles_amount=(vol(1)-vol(3))/molar_Vol;
    moles(3)=moles_amount*mole_fr(3);   %amount of h2o moles
    moles(2)=moles_amount*mole_fr(2);   %amount of He moles
    moles(1)=moles_amount*mole_fr(1);   %amount of N2 moles

    % at this point we know how much gas mixture molecules are at test
    % conditions - then let's calculate pressure before heating (e.g. at T=20C,
    % amount of moles changes by evaporated water mass will be estimated as well)
    %start with assupmtion moles_amount=constant (molar_Vol=const as well)
    T_temp=273.15+T_room;
    press_temp=press_fun(T_temp,molar_Vol)/100000;

    %based on new pressure calculate boiling point
    T_sat_temp=IAPWS_IF97('Tsat_p',press_temp/10*mole_fr(3));
    %if higher than T_temp, means some steam must condense to further reduce
    %pressure to reach equilibrium

    %define fraction by which steam is condensing at each iteration (start with 0.5)
    cond_frac=0.5;
    residual=0.0001;
    counter=0;
    while T_sat_temp-T_temp>residual
        counter=counter+1;
        %step 1 condense cond_frac portion of steam and update relevant temp
        %values
        moles_amount_temp=moles_amount-cond_frac*moles(3);
        moles_h2o_temp=(1-cond_frac)*moles(3);
        mole_fr_h2o_temp=moles_h2o_temp/moles_amount_temp;

        %step 2 calculate resulting molar_vol, pressure and temperature
        molar_Vol=(vol(1)-vol(3))/moles_amount_temp;
        press_temp=press_fun(T_temp,molar_Vol)/100000;
        T_sat_temp=IAPWS_IF97('Tsat_p',press_temp/10*mole_fr_h2o_temp);
        Temp_plot(counter)=T_sat_temp;
        Press_plot(counter)=press_temp;
        %step 3a if T_sat_temp is still larger than desired T_temp, then save
        %temp values as right values with which the next iteration of the loop
        %will start
        if T_sat_temp>=T_temp
            moles_amount=moles_amount_temp;
            moles(3)=moles_h2o_temp;
            mole_fr(3)=mole_fr_h2o_temp;
        %step 3b in case our temperature fallen too low, go a step back - reduce cond_frac
        %by half and recalculate T_sat_temp with values from previous step,
        %thus the loop will repeat current iteration with lower cond_frac
        elseif T_sat_temp<T_temp 
            cond_frac=0.5*cond_frac;
            molar_Vol=(vol(1)-vol(3))/moles_amount;
            press_temp=press_fun(T_temp,molar_Vol)/100000;
            T_sat_temp=IAPWS_IF97('Tsat_p',press_temp/10*mole_fr(3));        
        end

    end
    % counter
    % T_temp
    %plot(Temp_plot,'.')
    %plot(Press_plot,'.')
    %update all mole fractions to new values
        for i=1:mixture_components
            mole_fr(i)=moles(i)/moles_amount;
        end
    clear moles_amount_temp moles_h2o_temp  mole_fr_h2o_temp
    %% From 2. to 3.

    % % after opening the valve, both tanks are in equilibrium (equal T and P)
    % % NC tank is only filled with NC mixture (thanks to check valve)
    % mass_fr_NC_tank(1)=mass_fr_N2;
    % mass_fr_NC_tank(2)=mass_fr_He;
    % %since we have only two species, take a subset of previously used vector
    % %storing molar mass of species
    % mol_m_NC_tank=mol_m(1:2);
    % %recalculate mass to molar fractions
    % mole_fr_NC_tank=mass_2_mole_fraction(mol_m_NC_tank,mass_fr_NC_tank);

    %since now user defines mole fr instead of mass fr, read directly:
    mole_fr_NC_tank(1)=mole_fr_N2;  %XXXXXXXXXXXXXXXXXXXXXXX
    mole_fr_NC_tank(2)=mole_fr_He;  %XXXXXXXXXXXXXXXXXXXXXXX
    press_NC_tank=press_temp;
    T_NC_tank=T_sat_temp;

    % Define Redlich-Kwong equation (for two species in NC tank - parameters a and b change slightly)
    Tc_NC_tank=Tc(1:2);
    pc_NC_tank=pc(1:2);
    if eos==1
        press_fun_NC=press_fun;
        Vm_fun_NC=Vm_fun;
        T_fun_NC=T_fun;
    elseif eos==2
        [press_fun_NC,Vm_fun_NC,T_fun_NC]=Redlich_Kwong(R,Tc_NC_tank,pc_NC_tank,mole_fr_NC_tank);
    end

    %with known pressure and temperature, calculate molar volume
    molar_Vol_NC_tank=Vm_fun_NC(press_NC_tank*100000,T_NC_tank);
    molar_Vol_NC_tank=real(molar_Vol_NC_tank(1));
    %and based on molar volume estimate total and species mole amount in NC tank
    moles_amount_NC_tank=vol(2)/molar_Vol_NC_tank;

    moles_NC_tank=zeros(1,mixture_components-1);
    for i=1:mixture_components-1
    moles_NC_tank(i)=moles_amount_NC_tank*mole_fr_NC_tank(i);
    end

    %% From 3. to 4.
    %before the valve is opened, all moles of NC mixture that reside in heater
    %tank later on, are "squeezed" into NC tank, thus:

    for i=1:mixture_components-1
    moles_NC_tank(i)=moles_NC_tank(i)+moles(i);
    end
    moles_amount_NC_tank=sum(moles_NC_tank);
    molar_Vol_NC_tank=vol(2)/moles_amount_NC_tank;
    molar_Vol_NC_tank_He=vol(2)/moles_NC_tank(2);
    %if all the extra moles of NC gas are squezzed back to NC tank, assuming T
    %const, we can calculate the pressure in the tank
    press_NC_tank=press_fun_NC(T_NC_tank,molar_Vol_NC_tank)/100000;
    press_NC_tank_He=press_fun_NC(T_NC_tank,molar_Vol_NC_tank_He)/100000;
end