clc
clear htcDehbi htcUchida htcTagami
T1=200;
T2=203;
P=5;
W=0.05:0.05:0.45;

% calc from correlations
for n=1:numel(W)

htcDehbi(n)=0.02^0.05*((3.7+28.7*P)-(2438+458.3*P)*log(W(n)))/(T2-T1);
htcUchida(n)=379*(W(n)/(1-W(n)))^-0.707;
htcTagami(n)=11.4+284*((1-W(n))/W(n));


end

m=2;
facilityPress=steam(m).press.var;
%% calc from expsensor 1
% ghfsFlux1=GHFS(m).GHFS1.var;
% ghfsTemp1=GHFS(m).GHFS1_temp.var;
% centerlineTemp1=steam(m).TF9603.var;
% ghfsWalldT1=GHFS(m).wall_dT_GHFS1.var;
% 
% tempAmount1=numel(ghfsTemp1);
% 
% ghfsFlux1=resample(ghfsFlux1,1,100);
% ghfsFlux1(tempAmount1+1:end)=[];
% 
% htcExp1=smooth(ghfsFlux1,10)./smooth(ghfsWalldT1,10);
% 
% partpress_h2o1=IAPWS_IF97('psat_T',(centerlineTemp1+273.15))*10;  % * 10 to convert MPa to bar            
% molefr_h2o1=partpress_h2o1./facilityPress;
%                 
% wExp1=1-molefr_h2o1;
% wExp1(wExp1<=0.01)=0.01;

%% calc from exp sensor 3
switch m
    case 2
        stVal=680; %exp 2
        endVal=850; %exp 2
    case 6
        stVal=2100; %exp 6
        endVal=2700; %exp 6
    case 4
        stVal=1200; %exp 4
        endVal=1500; %exp 4 
    case 5
        stVal=3300; %exp 6
        endVal=4300; %exp 6
end

ghfsFlux3=GHFS(m).GHFS3.var(stVal*100:endVal*100);
ghfsTemp3=GHFS(m).GHFS3_temp.var(stVal:endVal);
centerlineTemp3=steam(m).TF9608.var(stVal:endVal);
ghfsWalldT3=GHFS(m).wall_dT_GHFS3.var(stVal:endVal);
ghfsdT3=centerlineTemp3-ghfsTemp3;
facilityPress=steam(m).press.var(stVal:endVal);
tempAmount3=numel(ghfsTemp3);

ghfsFlux3=resample(ghfsFlux3,1,100);
ghfsFlux3(tempAmount3+1:end)=[];
ghfsFlux3(1)=ghfsFlux3(2); %to fix resampling error

smT=5;
htcExp3=smooth(ghfsFlux3,smT)./smooth(ghfsWalldT3,smT);

partpress_h2o3=IAPWS_IF97('psat_T',(centerlineTemp3+273.15))*10;  % * 10 to convert MPa to bar            
molefr_h2o3=partpress_h2o3./facilityPress;
                
wExp3=1-molefr_h2o3;
wExp3=wExp3-min(wExp3);

colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};
nTh=20;
figure
subplot(4,1,1)
c1=plot(ghfsFlux3,'o-','MarkerIndices',1:nTh:numel(ghfsFlux3));
ylabel('Heat flux [W/m^2]')

subplot (4,1,2)
c2=plot(ghfsWalldT3,'s-','MarkerIndices',1:nTh:numel(ghfsFlux3));
ylabel('Wall dT [K]')

subplot(4,1,3)
c3=plot(1-wExp3,'d-','MarkerIndices',1:nTh:numel(ghfsFlux3));
ylabel('H_2O mole fraction [1]')

subplot(4,1,4)
c4=plot(htcExp3,'^-','MarkerIndices',1:nTh:numel(ghfsFlux3));
ylabel('h_t_c [W/m^2*K]')
ylim([0 3000]);
xlabel('Time [s]')
c1.LineWidth=1.5;
c2.LineWidth=1.5;
c3.LineWidth=1.5;
c4.LineWidth=1.5;
c1.Color=colorstring{1};
c2.Color=colorstring{2};
c3.Color=colorstring{3};
c4.Color=colorstring{4};
c1.MarkerFaceColor=colorstring{1};
c2.MarkerFaceColor=colorstring{2};
c3.MarkerFaceColor=colorstring{3};
c4.MarkerFaceColor=colorstring{4};
print('D:\Data_analysis\Htc comparison in time','-dmeta')
% figure;plot(wExp)
figure
g1=plot(W,htcDehbi,'o-');
hold on
g2=plot(W,htcUchida,'s-');
g3=plot(W,htcTagami,'d-');
% plot(wExp1,htcExp1,'.');
g4=plot(wExp3,htcExp3,'-^');
g1.MarkerFaceColor=g1.Color;
g2.MarkerFaceColor=g2.Color;
g3.MarkerFaceColor=g3.Color;
g4.MarkerFaceColor=g4.Color;

legend({'h_t_c Uchida','h_t_c Tagami','h_t_c Dehbi','h_t_c GHFS3'})
ylim([0        6000]);
xlim([0 0.5])
ylabel('Heat transfer coefficient [W/m^2*K]');
xlabel('Local NC gas mole fraction');

%% save
print('D:\Data_analysis\Htc comparison correlations','-dmeta')

disp('Fertig')