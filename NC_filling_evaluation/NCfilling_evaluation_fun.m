function [h2o_mole_frac, N2_mole_frac, He_mole_frac,moles_N2_htank,moles_He_htank,N2_mole_frac_init,He_mole_frac_init]=NCfilling_evaluation_fun(arg,disp_flag,eos)


    %% PURPOSE OF THIS CODE
    % Enter measured values for pressure and temperature at following stages of
    % facility filling:
    % 1. vacuum in heater tank and in NC tank
    % 2. water filling in heater tank
    % 3. 1st NC component filling to NC tank
    % 4. 2nd NC component filling to NC tank
    % 5. Filling NC mixture to heater tank
    % From this, estimate the exact mass / molar fractions of H2O, N2 and He for a given test

    %% GAS PROPERTIES
        %molar mass
%         mol_m_air=28.966;
%         mol_m_N2=28.0134;
%         mol_m_He=4;
%         mol_m_h2o=18.02;
% 
%         mol_m(1)=mol_m_N2;
%         mol_m(2)=mol_m_He;  %put molar masses into one var for Equation Of State
%         mol_m(3)=mol_m_h2o;

        %critical pressure in Bar http://en.wikipedia.org/wiki/Critical_point_%28thermodynamics%29
        pc_N2=33.9;
        pc_He=2.27;
        pc_h2o=220.58;

        pc(1)=pc_N2;
        pc(2)=pc_He;    %put pc's into one var for Equation Of State
        pc(3)=pc_h2o;

        %critical temperature in K http://en.wikipedia.org/wiki/Critical_point_%28thermodynamics%29
        Tc_N2=126.2;
        Tc_He=5.19;
        Tc_h2o=647.096;

        Tc(1)=Tc_N2;
        Tc(2)=Tc_He;    %put Tc's into one var for Equation Of State
        Tc(3)=Tc_h2o;

        %gas constant
        R=8.3144621;

    %% GEOMTERY
        vol.heaterTank=0.00419;
        vol.NCtank=0.005;
        vol.waterTank=0.003;

    %% EOS choice
        % eos=1 - ideal gas
        % eos=2 - Redlich Kwong

    %% GET CONDITIONS 
    
        %remove negative pressures
        for arg_ctr=1:numel(arg)
            if arg(arg_ctr)<0
                arg(arg_ctr)=0.00001;
            end
        end
        
        %test conditions
        P_Htank_test=arg(1);
        T_Htank_test=arg(2)+273.15;
        
        % 1. Vacuum in heater tank
        P_Htank_vac=arg(3);
        T_Htank_vac=arg(4)+273.15;

        % 2. Vacuum in NC tank
        P_NCtank_vac=arg(5);
        T_NCtank_vac=arg(6)+273.15;

        % 3. Water filled to heater tank
        P_Htank_h2o=arg(7);
        T_Htank_h2o=arg(8)+273.15;
        
        % 4. First NC component (He) filled in NC tank
        P_NCtank_He=arg(9);
        T_NCtank_He=arg(10)+273.15;
        
        % 5. Second NC component (N2) filled in NC tank
        P_NCtank_full=arg(11);
        T_NCtank_full=arg(12)+273.15;

        % 6. Heater tank filled with NC
        P_htank_full=arg(13);
        T_htank_full=arg(14)+273.15;
      
        
    %% Calculaion 1 - Vacuum in heater tank

    % assume there's only nitrogen in air mixture
    % define equation of state for pure nitrogen
        if eos==1
            %in case of ideal gas equation, equation of state always looks the
            %same
%             [~,Vm_fun_N2,~]=ideal_gas(R);
            Vm_fun_N2=@(P,T) R*T/P;  %simplify maths
%             [press_fun_N2,Vm_fun_N2,T_fun_N2]=ideal_gas(R);
        elseif eos==2
            reset(symengine) %clears symbolic variables
            [~,Vm_fun_N2,~]=Redlich_Kwong(R,Tc_N2,pc_N2,1);
%             [press_fun_N2,Vm_fun_N2,T_fun_N2]=Redlich_Kwong(R,Tc_N2,pc_N2,1);
        end

        molar_vol_Htank_vac=Vm_fun_N2(P_Htank_vac*10^5,T_Htank_vac);   % times 10^5 to convert bar to Pa
        moles_N2_Htank_vac=vol.heaterTank/real(molar_vol_Htank_vac(1));

    %% Calculation 2 Vacuum in NC tank

    % assume there's only nitrogen in the remaining air mixture, reuse function from step 1
    % (same composition)
    if ~P_NCtank_full==0
        molar_vol_NCtank_N2=Vm_fun_N2(P_NCtank_vac*100000,T_NCtank_vac);
        moles_N2_NCtank_vac=vol.NCtank/real(molar_vol_NCtank_N2(1));
    end

    %% Calculation 3 Water filled to heater tank

    % make an initial guess about mole fraction of steam in gas mixture
        moles_h2o_Htank_filling=P_Htank_h2o*100000*vol.heaterTank/R/T_Htank_h2o-moles_N2_Htank_vac;
        mole_fr_h2o_Htank=moles_h2o_Htank_filling/(moles_h2o_Htank_filling+moles_N2_Htank_vac);


     % check what equation of state was chosen and act accordingly   
        if eos==1
            %initial guess is final guess in this case

        elseif eos==2
            flag=0;
            % this checks if first guess of mole fraction was good and if does
            % not meet "condition" (currently set to 0.0001, repeat estimation
            % of Redlich Kwong parameters with updated mole fraction, compare
            % again and so on

            while flag==0
                mole_fr_array=[1-mole_fr_h2o_Htank,mole_fr_h2o_Htank];  % first term is NC mole fraction
                [~,Vm_fun,~]=Redlich_Kwong(R,Tc([1,3]),pc([1,3]),mole_fr_array);
%                 [press_fun,Vm_fun,T_fun]=Redlich_Kwong(R,Tc([1,3]),pc([1,3]),mole_fr_array);
                molar_vol_Htank_filling=Vm_fun(P_Htank_h2o*100000,T_Htank_h2o);
                moles_h2o_Htank_filling_temp=vol.heaterTank/real(molar_vol_Htank_filling(1))-moles_N2_Htank_vac;
                mole_fr_h2o_Htank=moles_h2o_Htank_filling_temp/(moles_h2o_Htank_filling_temp+moles_N2_Htank_vac);
                condition=abs(moles_h2o_Htank_filling_temp-moles_h2o_Htank_filling)/moles_h2o_Htank_filling_temp;
                moles_h2o_Htank_filling=moles_h2o_Htank_filling_temp;
                if condition<0.0001
                    flag=1;
                end
            end
        end

        %CHECK measured and calculated temp values
        T_Htank_h2o_IAPWS_sat=IAPWS_IF97('Tsat_p',P_Htank_h2o*mole_fr_h2o_Htank/10);  %divide by 10 to convert bar to MPa
%         if disp_flag==1
%             T_Htank_h2o_IAPWS_sat_nodajdustment=IAPWS_IF97('Tsat_p',P_Htank_h2o/10)
%             T_Htank_h2o
%             T_Htank_h2o_IAPWS_sat
%         end
        if abs(T_Htank_h2o-T_Htank_h2o_IAPWS_sat)>0.1
            if disp_flag==1
                disp('Step 3 error - measured T larger than T sat from tables. Adjusting T')
                disp('No calculations involved - just steam tables, so check initial conditions file but leave code alone')
                disp('calculated Tsat:')
                disp(T_Htank_h2o_IAPWS_sat)
                disp('Measured T: ')
                disp(T_Htank_h2o)
            end
            T_Htank_h2o=T_Htank_h2o_IAPWS_sat;
            moles_h2o_Htank_filling=P_Htank_h2o*100000*vol.heaterTank/R/T_Htank_h2o-moles_N2_Htank_vac;
            mole_fr_h2o_Htank=moles_h2o_Htank_filling/(moles_h2o_Htank_filling+moles_N2_Htank_vac);
        end
        %after the heater tank is separated from water tank, parts of the
        %moles of water and gas are left in the latter, thus while fraction
        %remains the same, absolute amount changes
        %  (vol.heaterTank-vol.waterTank)/vol.heaterTank - water from vol.waterTank is stransferred to vol.heaterTank
        volume_ratio=(vol.heaterTank-vol.waterTank)/vol.heaterTank;    
        moles_h2o_Htank_filling=moles_h2o_Htank_filling*volume_ratio;
        moles_N2_Htank_filling=moles_N2_Htank_vac*volume_ratio;

   
    %do steps 4 and 5 only if it is not a pure steam test
    if ~P_NCtank_full==0
    %% Calculation 4 First NC component (He) filled in NC tank
        % pure helium + initial nitrogen, reuse EOS from Calculation 1

%         molar_vol_NCtank=Vm_fun_N2(P_NCtank_He*100000,T_NCtank_He);
%         moles_He_NCtank=vol.NCtank/real(molar_vol_NCtank(1))-moles_N2_NCtank_vac;
        molar_vol_NCtank_step_4=Vm_fun_N2(P_NCtank_He*100000,T_NCtank_He);
        moles_He_NCtank=vol.NCtank/real(molar_vol_NCtank_step_4(1))-moles_N2_NCtank_vac;
        


    % Caculation 5 Second NC component (N2) filled in NC tank

    % make an initial guess about mole fraction of N2 in NC gas mixture
        molar_vol_NCtank_step_5=Vm_fun_N2(P_NCtank_full*100000,T_NCtank_full);
        moles_N2_NCtank=vol.NCtank/real(molar_vol_NCtank_step_5(1))-moles_He_NCtank;
%         mole_fr_N2_NCtank=moles_N2_NCtank/(moles_He_NCtank+moles_N2_NCtank); % apparently unused, keep in the code though

    % get the gas ratio
        mole_fr_He_NCtank=moles_He_NCtank/(moles_He_NCtank+moles_N2_NCtank);

        % check what equation of state was chosen and act accordingly
        if eos==1

                    %initial guess is final guess in this case
        elseif eos==2
            flag=0;
            % this checks if first guess of mole fraction was good and if does
            % not meet "condition" (currently set to 0.0001, repeat estimation
            % of Redlich Kwong parameters with updated mole fraction, compare
            % again and so on

            while flag==0
                mole_fr_array=[1-mole_fr_He_NCtank,mole_fr_He_NCtank];
                [~,Vm_fun,~]=Redlich_Kwong(R,Tc([1,2]),pc([1,2]),mole_fr_array);
%                     [press_fun,Vm_fun,T_fun]=Redlich_Kwong(R,Tc([1,2]),pc([1,2]),mole_fr_array);
                molar_vol_NC_tank=Vm_fun(P_NCtank_full*100000,T_NCtank_full);
                moles_He_NCtank_temp=vol.NCtank/real(molar_vol_NC_tank(1))-moles_N2_NCtank;
                %make sure there actually is any He filled into the tank
                if moles_He_NCtank ~= 0
                    mole_fr_He_NCtank=moles_He_NCtank_temp/(moles_He_NCtank_temp+moles_N2_NCtank);
                    condition=abs(moles_He_NCtank_temp-moles_He_NCtank)/moles_He_NCtank_temp;
                    moles_He_NCtank=moles_He_NCtank_temp;
                else %and if not, break the loop - otherwise it goes on forever
                    mole_fr_He_NCtank=0;
                    condition=0;
                end
                if condition<0.0001 
                    flag=1;
                end
            end
        end

            %At this point, composition of NC gas mixture is set finally
    end
    %% Calculation 6 Heater tank filled with NC

    % At this point we know total amount of moles of each species in the system.
    % After the valve between NC tank and heater tank is opened, pressure will
    % equalize (rise in htank and fall in NC tank), thus some of steam will
    % condense back - that's the only unknown at this point

    %initial guess (ideal gas eq)
    %if we have 0 NC filled from NC tank, skip this step
    
        moles_h2o_htank=moles_h2o_Htank_filling;
        moles_total=P_htank_full*100000*(vol.heaterTank-vol.waterTank)/R/T_htank_full;
    
    %perform NC filling calculation only if this is not a PURE STEAM test
    %that's what the below if clause does
    if P_NCtank_full==0
        moles_N2_htank=moles_N2_Htank_filling;
        moles_He_htank=0;
        % those two below are to pass values outside back to main program
        N2_mole_frac_init=0;
        He_mole_frac_init=0;
    else
        flag=0;

        while flag==0
%             
            moles_NC=moles_total-moles_h2o_htank-moles_N2_Htank_filling;   %these are moles that entered heater tank from NC tank, hence substract the original leftovers
            moles_N2_htank=moles_N2_Htank_filling+moles_NC*(1-mole_fr_He_NCtank);
            moles_He_htank=moles_NC*mole_fr_He_NCtank;
            mole_fr_h2o_htank_full=moles_h2o_htank/moles_total;
            part_press_h2o=P_htank_full*mole_fr_h2o_htank_full;
            Tsat_h2o=IAPWS_IF97('Tsat_p',part_press_h2o/10);

            %check if initial guess is OK - if the while loop below would
            %start with Tsat_h2o smaller than T_htank_full, it breaks
            if Tsat_h2o<T_htank_full  
                if disp_flag==1
                    disp('Step 6 error - measured T larger than T sat. Adjusting T')
%                     disp(['Step 6 iteration number: ',step6_counter])
                    disp('calculated Tsat_full:')
                    disp(Tsat_h2o)
                    disp('Measured T_full: ')
                    disp(T_htank_full)
                end
                T_htank_full=Tsat_h2o;
            end


            %define fraction by which steam is condensing at each iteration (start with 0.5)
            cond_frac=0.1;
            %the while loop condenses surplus of steam to reach
            %thermodynamic balance
            while abs(Tsat_h2o-T_htank_full)>0.1
                moles_total_temp=moles_total-moles_h2o_htank*cond_frac;
                moles_h2o_htank_temp=moles_h2o_htank*(1-cond_frac);
                mole_fr_h2o_htank_full_temp=moles_h2o_htank_temp/moles_total_temp;
                part_press_h2o_temp=P_htank_full*mole_fr_h2o_htank_full_temp;
                Tsat_h2o_temp=IAPWS_IF97('Tsat_p',part_press_h2o_temp/10);
                
                if Tsat_h2o_temp>=T_htank_full
%                     disp('bigger')
                    moles_total=moles_total_temp;
                    moles_h2o_htank=moles_h2o_htank_temp;
                    mole_fr_h2o_htank_full=mole_fr_h2o_htank_full_temp;
                    Tsat_h2o=Tsat_h2o_temp;
                %in case our temperature fallen too low, go a step back - reduce cond_frac
                %by half and recalculate T_sat_temp with values from previous step,
                %thus the loop will repeat current iteration with lower cond_frac
                elseif Tsat_h2o_temp<T_htank_full
%                     disp('smaller')
                    cond_frac=0.5*cond_frac;
            %         molar_Vol=(vol.heaterTank-vol.waterTank)/moles_amount;
            %         press_temp=press_fun(T_temp,molar_Vol)/100000;
            %         T_sat_temp=IAPWS_IF97('Tsat_p',press_temp/10*mole_fr(3));        
                end
            end


            if eos==1
                flag=1;
            elseif eos==2
                %with a good estimate of h2o molar fraction we can now check
                %total mole estimation with Redlich Kwong equation
                mole_fr_N2_htank_full=moles_N2_htank/moles_total;
                mole_fr_He_htank_full=moles_He_htank/moles_total;
                %redlich kwong needs to be redefined each time to account
                %for appropriate mixture of gases
                mole_fr_array=[mole_fr_N2_htank_full,mole_fr_He_htank_full,mole_fr_h2o_htank_full];
                [~,Vm_fun,~]=Redlich_Kwong(R,Tc,pc,mole_fr_array);
%                 [press_fun,Vm_fun,T_fun]=Redlich_Kwong(R,Tc,pc,mole_fr_array);
                molar_vol_htank=Vm_fun(P_htank_full*100000,T_htank_full);
                %here, we check if Redlich Kwong and inital guess give the same
                %result, if not, we go back to the beginning of the while loop
                %with updated molar values
                moles_total_temp=(vol.heaterTank-vol.waterTank)/real(molar_vol_htank(1));
                condition=abs(moles_total_temp-moles_total)/moles_total_temp;
                if condition>0.001
                    moles_total=moles_total_temp;
                else
                    flag=1;
                end
            end
        end
        
        % those two below are to pass values outside back to main program
        mole_fr_N2_htank_full=moles_N2_htank/moles_total;
        mole_fr_He_htank_full=moles_He_htank/moles_total;
        
        N2_mole_frac_init=mole_fr_N2_htank_full;
        He_mole_frac_init=mole_fr_He_htank_full;
    end
    %% Calculation 7 Test conditions

    %initial guess with ideal gas
%     moles_total
    moles_evaporated=P_Htank_test*100000*(vol.heaterTank-vol.waterTank)/R/T_Htank_test-moles_total;
    moles_h2o_test=moles_evaporated+moles_h2o_htank;
    h2o_mole_frac=moles_h2o_test/(moles_h2o_test+moles_total);
    N2_mole_frac=moles_N2_htank/(moles_h2o_test+moles_total);
    He_mole_frac=moles_He_htank/(moles_h2o_test+moles_total);
%     test_sum=h2o_mole_frac+N2_mole_frac+He_mole_frac;

%     flag=0;
%     while flag==0;
%         flag=1;
%     end
%     % Redklich Kwong to raz
%     % dwa, korekta przez zmiane obietosci
end