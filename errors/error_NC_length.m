function NC_length_error_abs=error_NC_length(NC_length,moles_total,temp,press,moles_total_error_abs,temp_error_abs,press_error_abs)
    %error propagation see http://www.rit.edu/cos/uphysics/uncertainties/Uncertaintiespart2.html
    radius=0.01;
    radius_error=0.000565;      %tube norm ASTM A269-10, OD +/- 0.13 mm, WT +/- 10% check table on first page http://www.dklokusa.com/wp-content/themes/dk/library/downloads/Stainless-Steel-Instrumentation.pdf
    [~,cross_section_error_rel]=error_cross_section(radius, radius_error);
    NC_length_error_rel=sqrt((moles_total_error_abs/moles_total)^2+(temp_error_abs/temp)^2+(press_error_abs/press)^2+cross_section_error_rel^2);
    NC_length_error_abs=NC_length_error_rel*NC_length;
    
    %L=n*R*T/(P*A)
    %L/R=n*T/(P*A)
    %X=L/R
    %dX/X=sqrt((dn/n)^2+(dT/T)^2+(dP/P)^2+(dA/A)^2)
    %dX=sqrt((dn/n)^2+(dT/T)^2+(dP/P)^2+(dA/A)^2)*X
    %dX=sqrt((dn/n)^2+(dT/T)^2+(dP/P)^2+(dA/A)^2)*(L/R)
    %L=X*R
    %dL=dX*R   check link - multiplication by constant
    %dL=sqrt((dn/n)^2+(dT/T)^2+(dP/P)^2+(dA/A)^2)*(L/R) * R
    %dL=sqrt((dn/n)^2+(dT/T)^2+(dP/P)^2+(dA/A)^2)*L
    %so gas constant is irrelevant?
    
end