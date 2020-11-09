clc

h=figure;
% h.Position0;
h.Position=[437         133        1016         701];
% xDat=steam.TF9606.var
y1st=600;
y1end=1050;
y1Dat=steam(2).TF9608.var(y1st:y1end);
y2st=1130;
y2end=1580;
y2Dat=steam(4).TF9608.var(y2st:y2end);
y3st=2190;
y3end=2640;
y3Dat=steam(6).TF9608.var(y3st:y3end);
y4Dat=GHFS(2).GHFS3.var(y1st*100:y1end*100);
y5Dat=GHFS(4).GHFS3.var(y2st*100:y2end*100);
y6Dat=GHFS(6).GHFS3.var(y3st*100:y3end*100);
y7Dat=steam(2).mixFront_TF9608.var;
y8Dat=steam(4).mixFront_TF9608.var;
y9Dat=steam(6).mixFront_TF9608.var;

colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

% s1=subplot(3,1,1);
% hold on
% box on
% 
% l3=plot(y3Dat,'');
% l2=plot(y2Dat,'');
% l1=plot(y1Dat,'');
% 
% l1.LineWidth=1.5;
% l2.LineWidth=1.5;
% l3.LineWidth=1.5;
% 
% l1.Color=colorstring{1};
% l2.Color=colorstring{2};
% l3.Color=colorstring{3};
% ylim([125,147])
% % xlim([0,900])
% % xlabel('Time [s]')
% ylabel(['Temperature',char(176),'C'])
% % title('Mixing zone passage')
% grid on
% legend('N2','MIX','He')
% s1.YLabel.FontWeight='bold';

% s2=subplot(3,1,2);
hold on
box on

period=0.01;
% period=1;
nTh=1500;
x4Dat=period:period:numel(y4Dat)*period;
x5Dat=period:period:numel(y5Dat)*period;
x6Dat=period:period:numel(y6Dat)*period;

s1=subplot (3,1,1);
grid on
hold on
box on
l6=plot(x6Dat,y6Dat,'-d','MarkerIndices',1:nTh:numel(x6Dat));
l6.Color=colorstring{3};
l6.MarkerFaceColor=colorstring{3};
l6.MarkerFaceColor=l6.MarkerFaceColor./1.5;
l6.MarkerEdgeColor=l6.MarkerFaceColor;
l6.LineWidth=1.5;
ylim([0 10000])
xlim([0 450])
legend('N_2')
ylabel('Heat flux [W/m^2]')

s2=subplot (3,1,2);
grid on
hold on
box on
l5=plot(x5Dat,y5Dat,'-s','MarkerIndices',1:nTh:numel(x5Dat));
l5.Color=colorstring{2};
l5.MarkerFaceColor=colorstring{2};
l5.MarkerFaceColor=l5.MarkerFaceColor./1.5;
l5.MarkerEdgeColor=l5.MarkerFaceColor;
l5.LineWidth=1.5;
legend('N_2 & He')
ylabel('Heat flux [W/m^2]')
ylim([0 10000])
xlim([0 450])

s3=subplot (3,1,3);
grid on
hold on
box on
l4=plot(x4Dat,y4Dat,'-o','MarkerIndices',1:nTh:numel(x4Dat));
l4.Color=colorstring{1};
l4.MarkerFaceColor=colorstring{1};
l4.MarkerFaceColor=l4.MarkerFaceColor./1.5;
l4.MarkerEdgeColor=l4.MarkerFaceColor;
l4.LineWidth=1.5;
ylim([0 10000])
xlim([0 450])



% ylim([0,20000])
% xlim([0,900])
xlabel('Time [s]')
ylabel('Heat flux [W/m^2]')
% title('Mixing zone passage')

legend('He')
s1.YLabel.FontWeight='bold';
s1.XLabel.FontWeight='bold';
s2.YLabel.FontWeight='bold';
s2.XLabel.FontWeight='bold';
s3.YLabel.FontWeight='bold';
s3.XLabel.FontWeight='bold';

% 
% 
% s3=subplot(3,1,3);
% hold on
% box on
% 
% l9=plot(y9Dat,'');
% l8=plot(y8Dat,'');
% l7=plot(y7Dat,'');
% 
% l7.LineWidth=1.5;
% l8.LineWidth=1.5;
% l9.LineWidth=1.5;
% l7.Color=colorstring{1};
% l8.Color=colorstring{2};
% l9.Color=colorstring{3};
% % ylim([125,147])
% % xlim([0,225])
% xlabel('Recalculated length [mm]')
% ylabel(['Temperature',char(176),'C'])
% % title('Mixing zone passage')
% grid on
% legend('N2','MIX','He')
% s3.YLabel.FontWeight='bold';
% s3.XLabel.FontWeight='bold';

%% save

print(h,'Zone passage in heat flux only','-dmeta')
disp('Fertig')