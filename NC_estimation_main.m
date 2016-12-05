clc
clear all
close all

% %test parameters
% % mole fraction of steam
% mole_fr_h2o=[0,0.1,0.2,0.3,0.5,0.7,0.9];
% 
% % desired test pressure
% Test_press=[5,5,5,5,5,5,5];
% 
% %mole fraction of N2 in NC mixture (mfr N2 + mfr He = 1)
% N2_NC_mole_fr[1 1 1 1 1 1 1];
[ndata, text, c]=xlsread('test_matrix_matlab.xlsx');
text=text(2:end,1);
mole_fr_NC=ndata(:,1);
N2_NC_mole_fr=ndata(:,2);
test_press=ndata(:,3);
wall_dT=ndata(:,4);
clnt_mflow=ndata(:,5);

T_room=20; %degress Celsius 
test_amount=size(ndata);

 %% Equation of state choice for NCfilling_estimation_fun
    % 1 - ideal gas
    % 2 - Redlich Kwong
    eos=1;

for n=1:test_amount(1)
    if mole_fr_NC(n)==0
        press_NC_tank_both=0;
        press_NC_tank_He=0;
    else
        [press_NC_tank_both, press_NC_tank_He]=NCfilling_estimation_fun((1-mole_fr_NC(n)),N2_NC_mole_fr(n),T_room,test_press(n),eos);
    end
    initial_cond{n,1}=text{n};
    initial_cond{n,2}=press_NC_tank_both;
    initial_cond{n,3}=press_NC_tank_He;
    initial_cond{n,4}=mole_fr_NC(n);
    initial_cond{n,5}=N2_NC_mole_fr(n);
    initial_cond{n,6}=test_press(n);
    initial_cond{n,7}=IAPWS_IF97('Tsat_p',test_press(n)*(1-mole_fr_NC(n))/10)-273.15;
    initial_cond{n,8}=initial_cond{n,7}-wall_dT(n);
    initial_cond{n,9}=clnt_mflow(n);
    initial_cond{n,10}=wall_dT(n);
end

%sort rows by NC gas mole fraction, so later it's easier to indentify same
%initial conditions
initial_cond=sortrows(initial_cond,[2,3,6,9,10]);

% "push back" the values in array to makes space for header
initial_cond(2:end+1,:)=initial_cond;

%add header
initial_cond{1,1}='File name';
initial_cond{1,2}='NC_tank_press_total_INIT';
initial_cond{1,3}='NC_tank_pres_He_INIT';
initial_cond{1,4}='Mole_fr_NC';
initial_cond{1,5}='N2 fraction in NC mix';
initial_cond{1,6}='Test pressure';
initial_cond{1,7}='Steam boiling point';
initial_cond{1,8}='Coolant temp';
initial_cond{1,9}='Coolant mass flow';
initial_cond{1,10}='wall dT';

xlswrite('D:\Data\Data_analysis\NC_filling_estimation\initial_conditions.xlsx',initial_cond)