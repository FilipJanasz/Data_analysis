function [press_fun,Vm_fun,T_fun]=ideal_gas(R)



% equation will be solved either for volume, pressure or temperature
syms P Vm T
%define equation
f(P,Vm)=P*Vm-R*T;
%get expression for pressure as a function of Vm and T
press_eq=solve(f,P);
%get expression of Vm as a function of P and T
Vm_eq=solve(f,Vm);
%get expression of T as a function of P and Vm (Vm = V/n)
T_eq=solve(f,T);

%convert to expressions matlabfunctions, which can be later called for
press_fun=matlabFunction(press_eq);
Vm_fun=matlabFunction(Vm_eq); %Vm gives as a result three values in complex domain - then Vm=real(Vm(1))
T_fun=matlabFunction(T_eq);

end