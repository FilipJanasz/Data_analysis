clc

h=figure;
% h.Position0;
h.Position=[600 300 500 500];
sensorPos=[220,320,420,520,670,820,920,1020,1120];
% xDat=steam.TF9606.var
y1Dat=steam(2).contInj.vel;
y2Dat=steam(2).contInj.restTme;
y3Dat=steam(2).contInj.mixL;

y4Dat=steam(4).contInj.vel;
y5Dat=steam(4).contInj.restTme;
y6Dat=steam(4).contInj.mixL;

y7Dat=steam(6).contInj.vel;
y8Dat=steam(6).contInj.restTme;
y9Dat=steam(6).contInj.mixL;



s1=subplot(3,1,1);
hold on

l1=plot(sensorPos,y1Dat,'-o');
l2=plot(sensorPos,y4Dat,'-^');
l3=plot(sensorPos,y7Dat,'-d');
l1.LineWidth=1.5;
l2.LineWidth=1.5;
l3.LineWidth=1.5;
l1.MarkerFaceColor=l1.Color;
l2.MarkerFaceColor=l2.Color;
l3.MarkerFaceColor=l3.Color;
l1.MarkerSize=4;
l2.MarkerSize=4;
l3.MarkerSize=4;

% ylim([125,147])
% xlim([0,900])
% xlabel('Sensor Position [mm]')
ylabel('Velocity [mm/s]')
% title('Mixing zone passage')
grid on
legend('He','MIX','N2','Location','northoutside','Orientation','Horizontal')
s1.YLabel.FontWeight='bold';


s2=subplot(3,1,2);
hold on

% period=0.01;
l4=plot(sensorPos,y2Dat,'-o');
l5=plot(sensorPos,y5Dat,'-^');
l6=plot(sensorPos,y8Dat,'-d');
l4.MarkerFaceColor=l4.Color;
l5.MarkerFaceColor=l5.Color;
l6.MarkerFaceColor=l6.Color;
l4.MarkerSize=4;
l5.MarkerSize=4;
l6.MarkerSize=4;
l4.LineWidth=1.5;
l5.LineWidth=1.5;
l6.LineWidth=1.5;
% ylim([0,20000])
% xlim([0,900])
% xlabel('Time [s]')
ylabel('Residence time [s]')
% title('Mixing zone passage')
grid on
s2.YLabel.FontWeight='bold';

% legend('He','MIX','N2')

s3=subplot(3,1,3);
hold on

l7=plot(sensorPos,y3Dat,'-o');
l8=plot(sensorPos,y6Dat,'-^');
l9=plot(sensorPos,y9Dat,'-d');
l7.MarkerFaceColor=l7.Color;
l8.MarkerFaceColor=l8.Color;
l9.MarkerFaceColor=l9.Color;
l7.MarkerSize=4;
l8.MarkerSize=4;
l9.MarkerSize=4;
l7.LineWidth=1.5;
l8.LineWidth=1.5;
l9.LineWidth=1.5;
% ylim([125,147])
% xlim([0,225])
% xlabel('Recalculated length [mm]')
xlabel('Sensor position [mm]')
ylabel('Zone length [mm]')
% title('Mixing zone passage')
grid on
s3.XLabel.FontWeight='bold';
s3.YLabel.FontWeight='bold';

% legend('He','MIX','N2')

%% save

print(h,'dupa2','-dmeta')
disp('Fertig')