function [rho,rho_error_abs,rho_error_relative,cv,cv_error_relative]=error_IAPWS_97_tables(T,p,temp_am,p_am,press_error_total,absTemp_error_total_abs)

%~~~~~~~~~~~~~~density error calculation
    
    % calculate density and partial derivatives of density
    
    v=zeros(temp_am,p_am);
    cv=zeros(temp_am,p_am);
    drho_dT=zeros(temp_am,p_am);
    drho_dP=zeros(temp_am,p_am);
    

    %get values of properites for given T and p
    for i=1:temp_am
        for j=1:p_am
            [v(i,j), cv(i,j),drho_dT(i,j),drho_dP(i,j)]=f_h2o_properties(T(i),p(j));
        end
    end

    rho=1./v;
 
    % use obtained derivatives to calculate error
    error_drho_dP=zeros(temp_am,p_am);

    for n=1:p_am
        error_drho_dP(:,n)=press_error_total(n)*drho_dP(:,n);
    end
 
    rho_error_abs=sqrt(abs(error_drho_dP).^2+abs(absTemp_error_total_abs*drho_dT).^2);  % error = drho_dx*errorX
    rho_error_relative=sqrt((rho_error_abs./rho).^2+0.0005^2);
    
%~~~~~~~~~~~~~~heat capacity error
    %get "companion values" - used for derivative calc of Cv
    T_companion=T-0.00000000001;
    p_companion=p-0.000000000001;
    
    a=zeros(temp_am,p_am);
    b=zeros(temp_am,p_am);
    c=zeros(temp_am,p_am);
    cv_companion=zeros(temp_am,p_am);
    
    for i=1:temp_am
        for j=1:p_am
            [a(i,j), cv_companion(i,j),b(i,j),c(i,j)]=f_h2o_properties(T_companion(i),p_companion(j));
        end
    end
    
    %calculate derivatives (primitive delta_y/delta_x)
    dcv_dp=zeros(temp_am,p_am);
    for i=1:temp_am
        for j=1:p_am
            dcv_dp(i,j)=abs(cv(i,j)-cv_companion(i,j))/(p(j)-p_companion(j));
        end
    end
        
    dcv_dT=zeros(temp_am,p_am);   
    for j=1:p_am
        for i=1:temp_am
            dcv_dT(i,j)=abs(cv(i,j)-cv_companion(i,j))/(T(i)-T_companion(i));
        end
    end

    % for multiple T and P, convert P errors to matrix (error is
    % independent of T bud depends on P)
    press_error_total_matrix=zeros(temp_am,p_am);
    for n=1:temp_am
    press_error_total_matrix(n,:)=press_error_total;
    end
    
    %get cv error
    cv_error_abs=sqrt((dcv_dp.*press_error_total_matrix).^2+(dcv_dT.*absTemp_error_total_abs).^2);
    cv_error_relative=sqrt(0.0005^2.+(cv_error_abs./cv).^2);
    end