clc

h=figure;
% h.Position0;
h.Position=[600 300 500 500];
% xDat=steam.TF9606.var
y1Dat=steam(5).TF9606.var(3700:4550);
y2Dat=steam(3).TF9606.var(4500:4800);
% y3Dat=GHFS(6).GHFS2.var(240000:300000);
% y4Dat=GHFS(3).GHFS2.var(477000:500000);
y3Dat=GHFS(5).wall_heatflux_GHFS3.var(3200:4050);
y4Dat=GHFS(3).wall_heatflux_GHFS3.var(4230:4530);
y5Dat=steam(5).mixFront_TF9606.var;
y6Dat=steam(3).mixFront_TF9606.var;


subplot(3,1,1)
hold on

l1=plot(y1Dat);
l2=plot(y2Dat);
l1.LineWidth=1.5;
l2.LineWidth=1.5;
ylim([125,147])
xlim([0,900])
xlabel('Time [s]')
ylabel(['Temperature',char(176),'C'])
title('Mixing zone passage')
grid on
legend('N2','He')

subplot(3,1,2)
hold on

% period=0.01;
period=1;
x3Dat=period:period:numel(y3Dat)*period;
x4Dat=period:period:numel(y4Dat)*period;
l3=plot(x3Dat,y3Dat);
l4=plot(x4Dat,y4Dat);
l3.LineWidth=1.5;
l4.LineWidth=1.5;
ylim([0,20000])
xlim([0,900])
xlabel('Time [s]')
ylabel(['Heat flux [W/m^2]'])
% title('Mixing zone passage')
grid on
legend('N2','He')

subplot(3,1,3)
hold on

l5=plot(y5Dat);
l6=plot(y6Dat);
l5.LineWidth=1.5;
l6.LineWidth=1.5;
ylim([125,147])
xlim([0,225])
xlabel('Recalculated length [mm]')
ylabel(['Temperature',char(176),'C'])
% title('Mixing zone passage')
grid on
legend('N2','He')

%% save

print(h,'dupa','-dmeta')
disp('Fertig')