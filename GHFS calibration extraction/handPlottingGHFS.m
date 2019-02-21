clc
% get data


paramToGet={'GHFS_TC','hfx_Joule_power','hfx_dT','hfx_gradT','hfx_rad','hfx_rad2'};  %'hfx_dT2','hfx_gradT','hfx_gradT2'
% paramToGet={'GHFS_TC','GHFS_sensitivity_Joule_power','GHFS_sensitivity_dT','GHFS_sensitivity_rad'};
for m=1:numel(paramToGet)
    currParam=paramToGet{m};
    for n=1:numel(GHFS_file)
        plotDat.(currParam)(n)=GHFS_data(n).(currParam).value;
    end
end


%plot
figure
hold on
grid on
for m=2:numel(paramToGet)
    currParam=paramToGet{m};
    plot(plotDat.GHFS_TC,plotDat.(currParam),'.')
    if m==2
        plot(plotDat.GHFS_TC,plotDat.(currParam),'o')
    end
end
titleString=GHFS_file(1).directory(end-5:end-1);
title([titleString,' HEATFLUXES'])
legend(paramToGet(1:end),'Location','eastoutside','Interpreter','none')