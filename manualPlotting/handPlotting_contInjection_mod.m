clc

h=figure;
% h.Position0;
h.Position=[600 300 500 500];
% xDat=steam.TF9606.var
y1st=700;
y1end=800;
y1Dat=steam(2).TF9608.var(y1st:y1end);
y2st=1230;
y2end=1480;
y2Dat=steam(4).TF9608.var(y2st:y2end);
y3st=2250;
y3end=2590;
y3Dat=steam(6).TF9608.var(y3st:y3end);
y4Dat=GHFS(2).GHFS3.var(y1st*100:y1end*100);
y5Dat=GHFS(4).GHFS3.var(y2st*100:y2end*100);
y6Dat=GHFS(6).GHFS3.var(y3st*100:y3end*100);
y7Dat=steam(2).mixFront_TF9608.var;
y8Dat=steam(4).mixFront_TF9608.var;
y9Dat=steam(6).mixFront_TF9608.var;

colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

s1=subplot(3,1,1);
hold on
box on

l3=plot(y3Dat,'');
l2=plot(y2Dat,'');
l1=plot(y1Dat,'');

l1.LineWidth=1.5;
l2.LineWidth=1.5;
l3.LineWidth=1.5;

l1.Color=colorstring{1};
l2.Color=colorstring{2};
l3.Color=colorstring{3};
ylim([125,147])
% xlim([0,900])
% xlabel('Time [s]')
ylabel(['Temperature',char(176),'C'])
% title('Mixing zone passage')
grid on
legend('N2','MIX','He')
s1.YLabel.FontWeight='bold';

s2=subplot(3,1,2);
hold on
box on

period=0.01;
% period=1;
x4Dat=period:period:numel(y4Dat)*period;
x5Dat=period:period:numel(y5Dat)*period;
x6Dat=period:period:numel(y6Dat)*period;
l6=plot(x6Dat,y6Dat,'');
l5=plot(x5Dat,y5Dat,'');
l4=plot(x4Dat,y4Dat,'');
l4.Color=colorstring{1};
l5.Color=colorstring{2};
l6.Color=colorstring{3};
l4.LineWidth=1.5;
l5.LineWidth=1.5;
l6.LineWidth=1.5;
% ylim([0,20000])
% xlim([0,900])
xlabel('Time [s]')
ylabel('Heat flux [W/m^2]')
% title('Mixing zone passage')
grid on
legend('N2','MIX','He')
s2.YLabel.FontWeight='bold';
s2.XLabel.FontWeight='bold';



s3=subplot(3,1,3);
hold on
box on

l9=plot(y9Dat,'');
l8=plot(y8Dat,'');
l7=plot(y7Dat,'');

l7.LineWidth=1.5;
l8.LineWidth=1.5;
l9.LineWidth=1.5;
l7.Color=colorstring{1};
l8.Color=colorstring{2};
l9.Color=colorstring{3};
% ylim([125,147])
% xlim([0,225])
xlabel('Recalculated length [mm]')
ylabel(['Temperature',char(176),'C'])
% title('Mixing zone passage')
grid on
legend('N2','MIX','He')
s3.YLabel.FontWeight='bold';
s3.XLabel.FontWeight='bold';

%% save

print(h,'Zone passage in temp flux and rec length','-dmeta')
disp('Fertig')