function [press_fun,Vm_fun,T_fun]=Redlich_Kwong(R,Tc,pc,mole_fr)
    reset(symengine)

    mixture_components=length(Tc);
    %get parameters for R-K EOS
    a=zeros(1,mixture_components);
    b=zeros(1,mixture_components);
    for i=1:mixture_components
        a(i)=RK_a(R,Tc(i),pc(i));
        b(i)=RK_b(R,Tc(i),pc(i));
    end

    %get all attractive constants for cross species interactions http://en.wikipedia.org/wiki/Redlich%E2%80%93Kwong_equation_of_state
    %attractive forces between species 1 and 2 and so on
    %all combinations! 
    mole_fr_a=mole_fr.^2;

    counter=1;
    start=1;
    for i=1:mixture_components
        start=start+1;
        for j=start:mixture_components
            a(mixture_components+counter)=sqrt(a(i)*a(j));
            mole_fr_a(mixture_components+counter)=mole_fr(i)*mole_fr(j);
            counter=counter+1;
        end
    end


    %define weighting factor for density calculation http://en.wikipedia.org/wiki/Molar_volume
    % molar_vol_factor=sum(mole_fr.*mol_m);

    % for i=1:mixture_components
    %     a(mixture_components+i)=a(i)*a(i+1)
    % end
    b_weighted=sum(b.*mole_fr);
    a_weighted=sum(a.*mole_fr_a);

    % Redlich-Kwong will be solved either for volume, pressure or temperature
    syms P Vm T
    %define equation
    f = 0==R*T/(Vm-b_weighted)-a_weighted/(sqrt(T)*Vm*(Vm+b_weighted))-P;
%     f = 0==R*T^2/(Vm-b_weighted)-a_weighted/(T*Vm*(Vm+b_weighted))-P;
    %get expression for pressure as a function of Vm and T
    press_eq=solve(f,P);
    %get expression of T as a function of P and Vm
%     T_eq=solve(f,T);
%     T_eq=vpa(T_eq);
    T_eq=1; %at the momemnt, matlab cannot solve this for T, unless one substitutes T^(1/2) with another var
    %as equation for T is not required now, just forget it and fix later
    %get expression of Vm as a function of P and T
    Vm_eq=solve(f,Vm);
    Vm_eq=vpa(Vm_eq);   % important to convert symbolic to numeric and get rid of "root" http://uk.mathworks.com/help/symbolic/root.html?searchHighlight=root
    

    %convert to expressions matlabfunctions, which can be later called for
    press_fun=matlabFunction(press_eq);
    Vm_fun=matlabFunction(Vm_eq); %Vm gives as a result three values in complex domain - then Vm=real(Vm(1))
%     T_fun=matlabFunction(T_eq);
    T_fun=1; %see above about T:eq
end