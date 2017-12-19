clc

h=figure;
% h.Position0;

% xDat=steam.TF9606.var
% y1Dat=steam(5).TF9606.var(3700:4550);
% y2Dat=steam(3).TF9606.var(4500:4800);
% y3Dat=steam(5).mixFront_TF9606.var;
% y4Dat=steam(3).mixFront_TF9606.var;

list={'03','04','05','06','08','10','11','12','13'};
clear dat_N2 dat_He ratio
for n=1:6
    dat_N2{n}=steam(5).(['mixFront_TF96',list{n}]).var;
    dat_He{n}=steam(3).(['mixFront_TF96',list{n}]).var;
    ratio(n)=numel(dat_N2{n})/numel(dat_He{n});
end
% subplot(2,1,1)
hold on

l1=plot(ratio);
% l2=plot(y2Dat);
l1.LineWidth=1.5;
% l2.LineWidth=1.5;
% ylim([125,147])
% xlim([0,900])
xlabel('Thermocouple]')
ylabel(['Temperature',char(176),'C'])
title('Mixing zone passage')
grid on
legend('N2','He')

% subplot(2,1,2)
% hold on
% 
% l3=plot(y3Dat);
% l4=plot(y4Dat);
% l3.LineWidth=1.5;
% l4.LineWidth=1.5;
% ylim([125,147])
% xlim([0,225])
% xlabel('Recalculated length [mm]')
% ylabel(['Temperature',char(176),'C'])
% % title('Mixing zone passage')
% grid on
% legend('N2','He')

%% save

print(h,'dupa','-dmeta')
disp('Fertig')