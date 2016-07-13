%test test test change test change for git
% function plotting(data)
% wall=data.wall;
% steam=data.steam;
% coolant=data.coolant;
% figure
% subplot(2,2,1)
% hold on
% title('Pressure vs mflow')
% plot([steam.press_mean], [steam.mflow],'o','linewidth',1)
% polyplot([steam.press_mean], [steam.mflow],2,'r','error','k--','linewidth',.3)
% hold off
% subplot(2,2,2)
% hold on
% title('Pressure vs coolant dT')
% plot([steam.press_mean],[coolant.dT_mean],'o')
% polyplot([steam.press_mean], [coolant.dT_mean],1,'r','error','k--','linewidth',.3)
% hold off
% subplot(2,2,3)
% hold on
% title('Steam mflow vs coolant dT')
% plot([steam.mflow],[coolant.dT_mean],'o')
% polyplot([steam.mflow], [coolant.dT_mean],1,'r','error','k--','linewidth',.3)
% hold off
% subplot(2,2,4);
% hold on
% title('Power comparison')
% plot([steam.power_mean],[coolant.power_mean],'o')
% hr=refline(1,0);
% set(hr,'Color','r')
% hold off

    figure
    subplot(2,2,1)
    hold on
    title('wall dT vs mflow')
    plot([wall.dT], [steam.mflow],'o','linewidth',1)
    polyplot([wall.dT], [steam.mflow],1,'r','error','k--','linewidth',.3)
    hold off
    subplot(2,2,2)
    hold on
    title('wall dT vs coolant dT')
    plot([wall.dT],[coolant.dT_mean],'o')
    polyplot([wall.dT], [coolant.dT_mean],1,'r','error','k--','linewidth',.3)
    hold off
    subplot(2,2,3)
    hold on
    title('steam mflow vs coolant dT')
    plot([steam.mflow],[coolant.dT_mean],'o')
    polyplot([steam.mflow], [coolant.dT_mean],1,'r','error','k--','linewidth',.3)
    hold off
    subplot(2,2,4);
    hold on
    title('Power comparison')
    plot([steam.power_mean],[coolant.power_mean],'o')
    hr=refline(1,0);
    set(hr,'Color','r')
    hold off
% end