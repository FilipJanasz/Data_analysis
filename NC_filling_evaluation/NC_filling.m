function [N2_inNC_mfrac,N2_inNC_mfracErr,h2o_mole_frac, N2_mole_frac,He_mole_frac,h2o_mole_frac_error,N2_mole_frac_error,He_mole_frac_error,N2_mole_frac_init,He_mole_frac_init,P_init,T_init,moles_h2o_test,moles_N2_htank,moles_He_htank,moleN2_error,moleHe_error]=NC_filling(p,T,p_error,T_error,file,eos_flag)
    extensive_error_flag=0;
    % get initial conditions from file
    directory=file.directory;
    try
        init_cond=xlsread([directory,'\IC.xlsx'],'B1:B12');
%         name_init_cond=xlsread([dir,'\IC.xlsx'],'A1:A12');
    catch
        try
            init_cond=xlsread([directory,'\',file.name,'_IC.xlsx'],'B1:B12');
        catch
            init_cond=xlsread([directory,'\',file.name,'-IC.xlsx'],'B1:B12');
        end
%          name_init_cond=xlsread([dir,'\',file.name,'_IC.xlsx'],'A1:A12');
    end
    
    arg=[p T init_cond'];
    P_init=init_cond(11);
    T_init=init_cond(12);
    
    if init_cond(1)<0
        init_cond(1)=0;
    end
    
    %estimate NC mixture composition, assume adiabatic
    %init_cond(1)  - residual air after vacuuming, assume pure N2
    %init_cond(7)  - pressure after filling He
    %init_cond(9)  - pressure after filling N2
    
    if init_cond(3)<0
        init_cond(3)=0;
    end
    
    HePress=init_cond(7)-init_cond(3);
    if HePress<0
        HePress=0;
    end
    N2_inNC_mfrac=1-HePress/init_cond(9);
    
    %and it's error, as it's based here purely on pressure measurements
    [Perr1,~]=error_press(init_cond(3));
    [Perr2,~]=error_press(init_cond(7));
    [~,Perr3]=error_press(init_cond(9));
    %first calc error propagation helium pressure (simple addition - sqrt
    %of sum of absolute errors
    HePressErr=sqrt(Perr1^2+Perr2^2);
    %error of N2 fraction - division, sqrt of sum of relative errors *
    %value
    if HePress==0
        N2_inNC_mfracErr=0;
    else
        N2_inNC_mfracErr=sqrt((HePressErr/HePress)^2+Perr3^2)*1;
        if N2_inNC_mfracErr>0.0704
            N2_inNC_mfracErr=0.0704;
        end
    end
    %calulate values of mole fractions for measured p and T and also for p
    %and T offset by p and T errors (arg_mod)
    disp_flag=1;
    [h2o_mole_frac, N2_mole_frac, He_mole_frac,moles_h2o_test,moles_N2_htank,moles_He_htank,N2_mole_frac_init,He_mole_frac_init]=NCfilling_evaluation_fun(arg,disp_flag,eos_flag);
    
    %% estimate errors
    if ~extensive_error_flag     
        %calculate maximal possible deviation from p and T, due to p and T
        %errors
        arg_mod_p=arg;
        arg_mod_T=arg;
        
        %create modified input string based on p and T errors (odd
        %positions are pressures, even positions are temperatures
        for err_cntr=1:numel(arg)/2
            arg_mod_p(err_cntr*2-1)=arg_mod_p(err_cntr*2-1)+p_error;
            arg_mod_T(err_cntr*2)=arg_mod_T(err_cntr*2)+T_error;
        end
        disp_flag=0;
        [h2o_mole_frac_T, N2_mole_frac_T, He_mole_frac_T,moles_N2_htank_T,moles_He_htank_T]=NCfilling_evaluation_fun(arg_mod_p,disp_flag,eos_flag);
        [h2o_mole_frac_P, N2_mole_frac_P, He_mole_frac_P,moles_N2_htank_P,moles_He_htank_P]=NCfilling_evaluation_fun(arg_mod_T,disp_flag,eos_flag);

        %calculate "derivatives" of mole fractions wrt p and T, as finite
        %differences for each species
        dh2o_mole_frac_dT=(h2o_mole_frac-h2o_mole_frac_T)/T_error;
        dh2o_mole_frac_dP=(h2o_mole_frac-h2o_mole_frac_P)/p_error;
        dN2_mole_frac_dT=(N2_mole_frac-N2_mole_frac_T)/T_error;
        dN2_mole_frac_dP=(N2_mole_frac-N2_mole_frac_P)/p_error;
        dHe_mole_frac_dT=(He_mole_frac-He_mole_frac_T)/T_error;
        dHe_mole_frac_dP=(He_mole_frac-He_mole_frac_P)/p_error;
        dmoles_N2_htank_dT=(moles_N2_htank-moles_N2_htank_T)/T_error;
        dmoles_N2_htank_dP=(moles_N2_htank-moles_N2_htank_P)/p_error;
        dmoles_He_htank_dT=(moles_He_htank-moles_He_htank_T)/T_error;
        dmoles_He_htank_dP=(moles_He_htank-moles_He_htank_P)/p_error;


        %sum the errors coming from p and T measurements
        %see section (f) from http://www.rit.edu/cos/uphysics/uncertainties/Uncertaintiespart2.html
        mfrac_p_error=dh2o_mole_frac_dP*p_error;
        mfrac_T_error=dh2o_mole_frac_dT*T_error;
        h2o_mole_frac_error=sqrt(mfrac_p_error^2+mfrac_T_error^2);
        

        mfracN2_p_error=dN2_mole_frac_dP*p_error;
        mfracN2_T_error=dN2_mole_frac_dT*T_error;
        N2_mole_frac_error=sqrt(mfracN2_p_error^2+mfracN2_T_error^2);

        mfracHe_p_error=dHe_mole_frac_dP*p_error;
        mfracHe_T_error=dHe_mole_frac_dT*T_error;
        He_mole_frac_error=sqrt(mfracHe_p_error^2+mfracHe_T_error^2);
        
        moleN2_p_error=dmoles_N2_htank_dP*p_error;
        moleN2_T_error=dmoles_N2_htank_dT*T_error;
        moleN2_error=sqrt(moleN2_p_error^2+moleN2_T_error^2);
        
        moleHe_p_error=dmoles_He_htank_dP*p_error;
        moleHe_T_error=dmoles_He_htank_dT*T_error;
        moleHe_error=sqrt(moleHe_p_error^2+moleHe_T_error^2);
        %last two missing in extensive mode
    else
        %in extensive error mode, calculate the influence of the initial
        %conditions measurements error additionally to test conditions
        %measurement error
        
        %loop through all the paramaters and calc mole fraction for each
        %combination in a way that on parameter is modified by
        %corresponding error value and the others are kept constant
        %preallocate
        arg_lng=length(arg);
        h2o_mole_frac_mod_array=zeros(1,arg_lng);
        N2_mole_frac_mod_array=zeros(1,arg_lng);
        He_mole_frac_mod_array=zeros(1,arg_lng);
        moleN2_mod_array=zeros(1,arg_lng);
        moleHe_mod_array=zeros(1,arg_lng);
        
        dh2o_mole_frac_dx=zeros(1,arg_lng);
        dN2_mole_frac_dx=zeros(1,arg_lng);
        dHe_mole_frac_dx=zeros(1,arg_lng);
        dmoles_N2_htank_dx=zeros(1,arg_lng);
        dmoles_He_htank_dx=zeros(1,arg_lng);
        
        mfrac_h2o_err=zeros(1,arg_lng);
        mfrac_N2_err=zeros(1,arg_lng);
        mfrac_He_err=zeros(1,arg_lng);
        moles_N2_err=zeros(1,arg_lng);
        moles_He_err=zeros(1,arg_lng);
        
        for i=1:arg_lng
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
            [h2o_mole_frac_mod_array(i), N2_mole_frac_mod_array(i), He_mole_frac_mod_array(i),moleN2_mod_array(i),moleHe_mod_array(i)]=NCfilling_evaluation_fun(arg_mod,disp_flag);
            
            %calc "derivatives" for each modified parameter
            dh2o_mole_frac_dx(i)=(h2o_mole_frac-h2o_mole_frac_mod_array(i))/dx;
            dN2_mole_frac_dx(i)=(N2_mole_frac-N2_mole_frac_mod_array(i))/dx;
            dHe_mole_frac_dx(i)=(He_mole_frac-He_mole_frac_mod_array(i))/dx;
            dmoles_N2_htank_dx(i)=(moles_N2_htank-moleN2_mod_array(i))/dx;
            dmoles_He_htank_dx(i)=(moles_He_htank-moleHe_mod_array(i))/dx;
            
            %calc error due to each parameter (error of x * dparam/dx)
            mfrac_h2o_err(i)=dh2o_mole_frac_dx(i)*dx;
            mfrac_N2_err(i)=dN2_mole_frac_dx(i)*dx;
            mfrac_He_err(i)=dHe_mole_frac_dx(i)*dx;
            moles_N2_err(i)=dmoles_N2_htank_dx(i)*dx;
            moles_He_err(i)=dmoles_He_htank_dx(i)*dx;
        end
        
        %sum the errors coming from every parameter measurement
        %see section (f) from http://www.rit.edu/cos/uphysics/uncertainties/Uncertaintiespart2.html
%         mfrac_h2o_err(3:end)=[];
%         mfrac_N2_err(3:end)=[];
%         mfrac_He_err(3:end)=[];
        h2o_mole_frac_error=sqrt(sumsqr(mfrac_h2o_err));
        N2_mole_frac_error=sqrt(sumsqr(mfrac_N2_err));
        He_mole_frac_error=sqrt(sumsqr(mfrac_He_err));
        moleN2_error=sqrt(sumsqr(moles_N2_err));
        moleHe_error=sqrt(sumsqr(moles_He_err));
    end
end
