clc

h=figure;
box on
% h.Position0;
% h.Position=[1200 300 500 500];

% xDat=steam.TF9606.var
fr1=steam(2).contInj.frontData;
fr2=steam(4).contInj.frontData;
fr3=steam(6).contInj.frontData;

avgWin=20;
nn=0.1;
 for frontCntr=1:numel(fr1)
    %get stds of front
%     frontStd1(frontCntr)=mean(movstd(fr1{frontCntr},round(numel(fr1{frontCntr})/avgWin)));%/mean(frontDataTime{frontCntr}));
%     frontStd1(frontCntr)=std(fr1{frontCntr})/(max(fr1{frontCntr})-min(fr1{frontCntr}));
%     frontStd1(frontCntr)=pentropy(fr1{frontCntr},1,'Instantaneous',false);
% frontStd1(frontCntr)=std(fr1{frontCntr}-smooth(fr1{frontCntr},50));
frontStd1(frontCntr)=std(highpass(fr1{frontCntr},nn));
 end
 
 for frontCntr=1:numel(fr2)
    %get stds of front
%     frontStd2(frontCntr)=mean(movstd(fr2{frontCntr},round(numel(fr2{frontCntr})/avgWin)));%/mean(frontDataTime{frontCntr}));
%     frontStd2(frontCntr)=std(fr2{frontCntr})/(max(fr2{frontCntr})-min(fr2{frontCntr}));
% frontStd2(frontCntr)=pentropy(fr2{frontCntr},1,'Instantaneous',false);
%     frontStd2(frontCntr)=std(fr2{frontCntr}-smooth(fr2{frontCntr},50));
    frontStd2(frontCntr)=std(highpass(fr2{frontCntr},nn));

 end
 
 for frontCntr=1:numel(fr3)
    %get stds of front
%     frontStd3(frontCntr)=mean(movstd(fr3{frontCntr},round(numel(fr3{frontCntr})/avgWin)));%/mean(frontDataTime{frontCntr}));
%     frontStd3(frontCntr)=std(fr3{frontCntr})/(max(fr3{frontCntr})-min(fr3{frontCntr}));
% frontStd3(frontCntr)=pentropy(fr3{frontCntr},1,'Instantaneous',false);
% frontStd3(frontCntr)=std(fr3{frontCntr}-smooth(fr3{frontCntr},50));
frontStd3(frontCntr)=std(highpass(fr3{frontCntr},nn));

 end

y1=frontStd1;
y2=frontStd2;
y3=frontStd3;

y4=steam(2).contInj.frontSTD;
y5=steam(4).contInj.frontSTD;
y6=steam(6).contInj.frontSTD;
 
arr1=steam(2).contInj.frontArriv;
arr2=steam(4).contInj.frontArriv;
arr3=steam(6).contInj.frontArriv;

smN=30;
velSm1=smooth(steam(2).velocity.var,smN);
velSm2=smooth(steam(4).velocity.var,smN);
velSm3=smooth(steam(6).velocity.var,smN);

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
% plot(x1,y4,'x')
% plot(x2,y5,'o')
% plot(x3,y6,'+')
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
a=ylabel('Temperature STD');
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

print(h,'Temp std vs steam velocity','-dmeta')
disp('Fertig')