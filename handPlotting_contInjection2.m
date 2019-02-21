clc

h=figure;
% h.Position0;
h.Position=[600 300 700 500];
% xDat=steam.TF9606.var
y1Dat=steam(5).TF9606.var(3700:4550);
y2Dat=steam(3).TF9606.var(4500:4800);
% y3Dat=GHFS(6).GHFS2.var(240000:300000);
% y4Dat=GHFS(3).GHFS2.var(477000:500000);
y3Dat=GHFS(5).wall_heatflux_GHFS3.var(3200:4050);
y4Dat=GHFS(3).wall_heatflux_GHFS3.var(4230:4530);
y5Dat=steam(5).mixFront_TF9606.var;
y6Dat=steam(3).mixFront_TF9606.var;


s1=subplot(2,1,1);
hold on

l1=plot(y1Dat,'');
l2=plot(smooth(y1Dat,50),':','Color',[0.5660, 0.7740, 0.2880]);
l1.LineWidth=1.5;
l2.LineWidth=1.5;
ylim([125,147])
xlim([0,900])
xlabel('Time [s]')
ylabel(['Temperature ',char(176),'C'])
% title('Mixing zone passage')
grid on
s1.YLabel.FontWeight='bold';
s1.XLabel.FontWeight='bold';
% legend('N2','He')

s2=subplot(2,1,2);
hold on

l5=plot(y5Dat,'','Color',[0.8500, 0.3250, 0.0980]);
l6=plot(smooth(y5Dat,20),':','Color',[0.5660, 0.7740, 0.2880]);
l5.LineWidth=1.5;
l6.LineWidth=1.5;
ylim([125,147])
xlim([0,225])
xlabel('Recalculated length [mm]')
ylabel(['Temperature ',char(176),'C'])
% title('Mixing zone passage')
grid on
s2.YLabel.FontWeight='bold';
s2.XLabel.FontWeight='bold';
% legend('N2','He')

%% save

print(h,'dupa','-dmeta')
disp('Fertig')