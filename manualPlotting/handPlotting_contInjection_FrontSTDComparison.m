clc

h=figure;
% h.Position0;
h.Position=[1200 300 500 500];
clear frontStd1 frontStd2 frontStd3
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
frontStd1{frontCntr}=highpass(fr1{frontCntr},nn);
 end
 
 for frontCntr=1:numel(fr2)
    %get stds of front
%     frontStd2(frontCntr)=mean(movstd(fr2{frontCntr},round(numel(fr2{frontCntr})/avgWin)));%/mean(frontDataTime{frontCntr}));
%     frontStd2(frontCntr)=std(fr2{frontCntr})/(max(fr2{frontCntr})-min(fr2{frontCntr}));
% frontStd2(frontCntr)=pentropy(fr2{frontCntr},1,'Instantaneous',false);
%     frontStd2(frontCntr)=std(fr2{frontCntr}-smooth(fr2{frontCntr},50));
    frontStd2{frontCntr}=highpass(fr2{frontCntr},nn);

 end
 
 for frontCntr=1:numel(fr3)
    %get stds of front
%     frontStd3(frontCntr)=mean(movstd(fr3{frontCntr},round(numel(fr3{frontCntr})/avgWin)));%/mean(frontDataTime{frontCntr}));
%     frontStd3(frontCntr)=std(fr3{frontCntr})/(max(fr3{frontCntr})-min(fr3{frontCntr}));
% frontStd3(frontCntr)=pentropy(fr3{frontCntr},1,'Instantaneous',false);
% frontStd3(frontCntr)=std(fr3{frontCntr}-smooth(fr3{frontCntr},50));
frontStd3{frontCntr}=highpass(fr3{frontCntr},nn);

 end

 n=3;
y1=frontStd1{n};
y2=frontStd2{n};
y3=frontStd3{n};

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

% fitType='poly1';
% some fitting
% [fitRes1, gof1] = curveFit(x1',y1,fitType);
% [fitRes2, gof2] = curveFit(x2',y2,fitType);
% [fitRes3, gof3] = curveFit(x3',y3,fitType);
% y4Dat=steam(4).contInj.vel;
% y5Dat=steam(4).contInj.restTme;
% y6Dat=steam(4).contInj.mixL;
% 
% y7Dat=steam(6).contInj.vel;
% y8Dat=steam(6).contInj.restTme;
% y9Dat=steam(6).contInj.mixL;

    colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};


% s1=subplot(2,1,1);

limMin=-4.5;
limMax=3;

subplot(3,1,1)
hold on
l1=plot(y1,'-');
ylim([limMin limMax])
grid on
xx=xlim;
plot([xx(1) xx(2)],[min(y1) min(y1)],'--','Color',colorstring{5},'LineWidth',1)
plot([xx(1) xx(2)],[max(y1) max(y1)],'--','Color',colorstring{5},'LineWidth',1)
% a1=ylabel('High freq oscillations');

subplot(3,1,2)
hold on
l2=plot(y2,'-');
ylim([limMin limMax])
grid on
xx=xlim;
plot([xx(1) xx(2)],[min(y2) min(y2)],'--','Color',colorstring{5},'LineWidth',1)
plot([xx(1) xx(2)],[max(y2) max(y2)],'--','Color',colorstring{5},'LineWidth',1)
a2=ylabel('Temp. high frequency oscillations');

subplot(3,1,3)
hold on
l3=plot(y3,'-');
ylim([limMin limMax])
grid on
xx=xlim;
plot([xx(1) xx(2)],[min(y3) min(y3)],'--','Color',colorstring{5},'LineWidth',1)
plot([xx(1) xx(2)],[max(y3) max(y3)],'--','Color',colorstring{5},'LineWidth',1)
% a3=ylabel('High freq oscillations');

% l11=plot( fitRes1, '--');
% l22=plot( fitRes2, '--');
% l33=plot( fitRes3, '--');
% plot(x1,y4,'x')
% plot(x2,y5,'o')
% plot(x3,y6,'+')
l1.LineWidth=2;
l2.LineWidth=2;
l3.LineWidth=2;
l1.Color=colorstring{1};
l2.Color=colorstring{2};
l3.Color=colorstring{3};
l1.MarkerSize=4;
l2.MarkerSize=4;
l3.MarkerSize=4;
% l11.Color=l1.Color;
% l22.Color=l2.Color;
% l33.Color=l3.Color;

% ylim([125,147])
% xlim([0.7 1.2])
% xlabel('Sensor Position [mm]')
b=xlabel('Time [s]');
% title('Mixing zone passage')
grid on
% legend('He','MIX','N2','Location','northoutside','Orientation','Horizontal')
% a1.FontWeight='bold';
a2.FontWeight='bold';

% a3.FontWeight='bold';

b.FontWeight='bold';



%% save

print(h,'dupa2','-dmeta')
disp('Fertig')