function [cross_section_error_abs,cross_section_error_rel]=error_cross_section(radius, radius_error)
    %error propagation see http://www.rit.edu/cos/uphysics/uncertainties/Uncertaintiespart2.html
    cross_section=pi*radius^2;
    cross_section_error_rel=sqrt(2*(radius_error/radius)^2);
    cross_section_error_abs=cross_section_error_rel*cross_section;
    %similarly to file upper, PI seems not to matter - check derivation of
    %error formula with gas constant (R) removed
end