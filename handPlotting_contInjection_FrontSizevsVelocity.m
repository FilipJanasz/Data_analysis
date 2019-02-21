clc

h=figure;
% h.Position0;
% h.Position=[600 300 500 500];

% xDat=steam.TF9606.var
y1=steam(2).contInj.mixL;
y2=steam(4).contInj.mixL;
y3=steam(6).contInj.mixL;

arr1=steam(2).contInj.frontArriv;
arr2=steam(4).contInj.frontArriv;
arr3=steam(6).contInj.frontArriv;

velSm1=smooth(steam(2).velocity.var,10);
velSm2=smooth(steam(4).velocity.var,10);
velSm3=smooth(steam(6).velocity.var,10);

x1=velSm1(arr1);
x2=velSm2(arr2);
x3=velSm3(arr3);

fitType='poly1';
% some fitting
[fitRes1, gof1] = curveFit(x1',y1,fitType);
[fitRes2, gof2] = curveFit(x2',y2,fitType);
[fitRes3, gof3] = curveFit(x3',y3,fitType);
% y4Dat=steam(4).contInj.vel;
% y5Dat=steam(4).contInj.restTme;
% y6Dat=steam(4).contInj.mixL;
% 
% y7Dat=steam(6).contInj.vel;
% y8Dat=steam(6).contInj.restTme;
% y9Dat=steam(6).contInj.mixL;



% s1=subplot(2,1,1);
hold on

l1=plot(x1,y1,'o');
l2=plot(x2,y2,'^');
l3=plot(x3,y3,'d');
l11=plot( fitRes1, '--');
l22=plot( fitRes2, '--');
l33=plot( fitRes3, '--');
l1.LineWidth=2;
l2.LineWidth=2;
l3.LineWidth=2;
l1.MarkerFaceColor=l1.Color;
l2.MarkerFaceColor=l2.Color;
l3.MarkerFaceColor=l3.Color;
l1.MarkerSize=4;
l2.MarkerSize=4;
l3.MarkerSize=4;
l11.Color=l1.Color;
l22.Color=l2.Color;
l33.Color=l3.Color;

% ylim([125,147])
xlim([0.7 1.2])
% xlabel('Sensor Position [mm]')
a=ylabel('Mixing zone length [mm]');
b=xlabel('Steam velocity [mm]');
% title('Mixing zone passage')
grid on
legend('He','MIX','N2','Location','northoutside','Orientation','Horizontal')
a.FontWeight='bold';
b.FontWeight='bold';

% % 
% s2=subplot(2,1,2);
% hold on
% 
% n=10;
% smN=100;
% % period=0.01;
% l4=plot(y4Dat(n:end-5),'-');
% l5=plot(y5Dat(n:end-5),'-');
% l6=plot(y6Dat(n:end-5),'-');
% l7=plot(smooth(y4Dat(n:end-5),smN),'-.');
% l8=plot(smooth(y5Dat(n:end-5),smN),'-.');
% l9=plot(smooth(y6Dat(n:end-5),smN),'-.');
% % l4.LineWidth=1.5;
% % l5.LineWidth=1.5;
% % l6.LineWidth=1.5;
% l7.LineWidth=2.5;
% l8.LineWidth=2.5;
% l9.LineWidth=2.5;
% l7.Color=l4.Color./1.3;
% l8.Color=l5.Color./1.3;
% l9.Color=l6.Color./1.3;
% % ylim([0,20000])
% % xlim([0,900])
% % xlabel('Time [s]')
% ylabel('NC feed rate [mol/s]')
% xlabel('Time [s]')
% % title('Mixing zone passage')
% grid on
% s2.YLabel.FontWeight='bold';
% s2.XLabel.FontWeight='bold';
% 
% % legend('He','MIX','N2')
% 
% s3=subplot(3,1,3);
% hold on
% 
% l7=plot(sensorPos,y3Dat,'-o');
% l8=plot(sensorPos,y6Dat,'-^');
% l9=plot(sensorPos,y9Dat,'-d');
% l7.MarkerFaceColor=l7.Color;
% l8.MarkerFaceColor=l8.Color;
% l9.MarkerFaceColor=l9.Color;
% l7.MarkerSize=4;
% l8.MarkerSize=4;
% l9.MarkerSize=4;
% l7.LineWidth=1.5;
% l8.LineWidth=1.5;
% l9.LineWidth=1.5;
% % ylim([125,147])
% % xlim([0,225])
% % xlabel('Recalculated length [mm]')
% xlabel('Sensor position [mm]')
% ylabel('Zone length [mm]')
% % title('Mixing zone passage')
% grid on
% s3.XLabel.FontWeight='bold';
% s3.YLabel.FontWeight='bold';

% legend('He','MIX','N2')

%% save

print(h,'dupa2','-dmeta')
disp('Fertig')