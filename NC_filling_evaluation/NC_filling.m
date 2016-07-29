function [h2o_mole_frac, N2_mole_frac,He_mole_frac,h2o_mole_frac_error,N2_mole_frac_error,He_mole_frac_error,N2_mole_frac_init,He_mole_frac_init,P_init]=NC_filling(p,T,p_error,T_error,file)
    extensive_error_flag=0;
    % get initial conditions from file
    dir=file.directory;
    try
        init_cond=xlsread([dir,'\IC.xlsx'],'B1:B12');
%         name_init_cond=xlsread([dir,'\IC.xlsx'],'A1:A12');
    catch
         init_cond=xlsread([dir,'\',file.name,'_IC.xlsx'],'B1:B12');
%          name_init_cond=xlsread([dir,'\',file.name,'_IC.xlsx'],'A1:A12');
    end

%     % by mistake, first component filled is actually He, but the script
%     % thinks it's N2, so to fix this, in case we have He in the system,
%     % recalculate correct partial pressure of N2 and substitute
%     if strcmp(name_init_cond(7),'P_NCtank_He')
%         init_cond(7)=init_cond(9)-init_cond(7);
%     end
    
    arg=[p T init_cond'];
    P_init=init_cond(11);
    %calulate values of mole fractions for measured p and T and also for p
    %and T offset by p and T errors (arg_mod)
    disp_flag=1;
    [h2o_mole_frac, N2_mole_frac, He_mole_frac,N2_mole_frac_init,He_mole_frac_init]=NCfilling_evaluation_fun(arg,disp_flag);
    
    if ~extensive_error_flag     
         %calculate maximal possible deviation from p and T, due to p and T
        arg_mod_p=arg;
        arg_mod_T=arg;
        
        for err_cntr=1:numel(arg)/2
            arg_mod_p(err_cntr*2-1)=arg_mod_p(err_cntr*2-1)+p_error;
            arg_mod_T(err_cntr*2)=arg_mod_T(err_cntr*2)+T_error;
        end
        disp_flag=0;
        [h2o_mole_frac_T, N2_mole_frac_T, He_mole_frac_T]=NCfilling_evaluation_fun(arg_mod_p,disp_flag);
        [h2o_mole_frac_P, N2_mole_frac_P, He_mole_frac_P]=NCfilling_evaluation_fun(arg_mod_T,disp_flag);

        %calculate "derivatives" of mole fractions wrt p and T, as finite
        %differences for each species
        dh2o_mole_frac_dT=(h2o_mole_frac-h2o_mole_frac_T)/T_error;
        dh2o_mole_frac_dP=(h2o_mole_frac-h2o_mole_frac_P)/p_error;
        dN2_mole_frac_dT=(N2_mole_frac-N2_mole_frac_T)/T_error;
        dN2_mole_frac_dP=(N2_mole_frac-N2_mole_frac_P)/p_error;
        dHe_mole_frac_dT=(He_mole_frac-He_mole_frac_T)/T_error;
        dHe_mole_frac_dP=(He_mole_frac-He_mole_frac_P)/p_error;


        %sum the errors coming from p and T measurements
        %see section (f) from http://www.rit.edu/cos/uphysics/uncertainties/Uncertaintiespart2.html
        mfrac_p_error=dh2o_mole_frac_dP.*p_error;
        mfrac_T_error=dh2o_mole_frac_dT.*T_error;
        h2o_mole_frac_error=sqrt(mfrac_p_error.^2+mfrac_T_error.^2);
        

        mfracN2_p_error=dN2_mole_frac_dP.*p_error;
        mfracN2_T_error=dN2_mole_frac_dT.*T_error;
        N2_mole_frac_error=sqrt(mfracN2_p_error.^2+mfracN2_T_error.^2);

        mfracHe_p_error=dHe_mole_frac_dP.*p_error;
        mfracHe_T_error=dHe_mole_frac_dT.*T_error;
        He_mole_frac_error=sqrt(mfracHe_p_error.^2+mfracHe_T_error.^2);
    else
        %in extensive error mode, calculate the influence of the initial
        %conditions measurements error additionally to test conditions
        %measurement error
        
        %loop through all the paramaters and calc mole fraction for each
        %combination in a way that on parameter is modified by
        %corresponding error value and the others are kept constant
        for i=1:length(arg)
            arg_mod=arg;
            if mod(i,2) == 0
                arg_mod(i)=arg_mod(i)+T_error;
                dx=T_error;
            else
                %recalculate p_error, according to pressure to which it is
                %applied
                p_error=error_press(arg_mod(i));
                arg_mod(i)=arg_mod(i)+p_error;
                dx=p_error;
            end
            
            % get values of mole fractions for each modified arg array
            [h2o_mole_frac_mod_array(i), N2_mole_frac_mod_array(i), He_mole_frac_mod_array(i)]=NCfilling_evaluation_fun(arg_mod);
            
            %calc "derivatives" for each modified parameter
            dh2o_mole_frac_dx(i)=(h2o_mole_frac-h2o_mole_frac_mod_array(i))/dx;
            dN2_mole_frac_dx(i)=(N2_mole_frac-N2_mole_frac_mod_array(i))/dx;
            dHe_mole_frac_dx(i)=(He_mole_frac-He_mole_frac_mod_array(i))/dx;
            
            %calc error due to each parameter (error of x * dparam/dx)
            mfrac_h2o_err(i)=dh2o_mole_frac_dx(i)*dx;
            mfrac_N2_err(i)=dN2_mole_frac_dx(i)*dx;
            mfrac_He_err(i)=dHe_mole_frac_dx(i)*dx;
        end
        
        %sum the errors coming from every parameter measurement
        %see section (f) from http://www.rit.edu/cos/uphysics/uncertainties/Uncertaintiespart2.html
%         mfrac_h2o_err(3:end)=[];
%         mfrac_N2_err(3:end)=[];
%         mfrac_He_err(3:end)=[];
        h2o_mole_frac_error=sqrt(sumsqr(mfrac_h2o_err));
        N2_mole_frac_error=sqrt(sumsqr(mfrac_N2_err));
        He_mole_frac_error=sqrt(sumsqr(mfrac_He_err));
    end
end
