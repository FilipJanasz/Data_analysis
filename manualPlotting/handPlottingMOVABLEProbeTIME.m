clc

addpath 'D:\Data_analysis\export_figure'
% Defaults for this blog post
width = 3;     % Width in inches
height = 4;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(file)
    allFiles{fCntr}=file(fCntr).name;
end

%files to plot
toPlot={'NC-MFR-ABS-1_4-LF'};
% toPlot={'NC-MFR-ABS-N2-6_1_5'};
% toPlot={'NC-MFR-ABS-1_4-LF','NC-MFR-ABS-1_5_4-LF2','NC-MFR-ABS-2_5_4_2'};
% toPlot=allFiles;

for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end


for n=1:numel(toPlot)
    
    % Set the default Size for display
    % defpos = get(0,'defaultFigurePosition');
    currFile=plotPos(n);
    xlimMax=6000;
    h=figure;
    h.Name=toPlot{n};
    h.Position=([500 200 500+width*100, 200+height*100]);

    % Set the defaults for saving/printing to a file
    set(h,'defaultFigureInvertHardcopy','on'); % This is the default anyway
    set(h,'defaultFigurePaperUnits','inches'); % This is the default anyway
    defsize = get(gcf, 'PaperSize');
    left = (defsize(1)- width)/2;
    bottom = (defsize(2)- height)/2;
    defsize = [left, bottom, width, height];
    set(h, 'defaultFigurePaperPosition', defsize);

    
    % plot POSITION
    subplot(3,1,1)
    f1=plot(MP(currFile).Pos.var,'-');
    f1.LineWidth=2.5;
    grid on
    ylabel(['Position [mm]'])
    xlim([0 xlimMax])
    
    % plot TEMP
    s1=subplot(3,1,2);
    s1.Position=[0.1300    0.4450    0.7750    0.2157];
    y=smooth(MP(currFile).Temp.var,50);
    f1=plot(y,'-');
    f1.LineWidth=2.5;
    f1.Color=[0.4660, 0.6740, 0.1880];
    grid on
    ylabel(['Temperature [\circC]'])
    xlim([0 xlimMax])
    
    % plot VOLTAGE
    s1=subplot(3,1,3);
    s1.Position=[0.1300 0.0700 0.7750 0.3257];
%     x=0.01:0.01:numel(MP(currFile).Temp.var)/100;

    x = MP(currFile).Pos.var;
    y = MP(currFile).MP4.var;
    p=round(numel(x)/10);
    q=round(numel(y)/10);
    y = resample(y,p,q);
    if numel(x)<numel(y)
        y=y(1:numel(x));
    elseif numel(x)>numel(y)
        x=x(1:numel(y));
    end
    ySmooth=smooth(y,100);

%     y=smooth(MP(currFile).MP4.var,3000);
    y(1)=mean(y);
    y(end)=mean(y);
    f1=plot(smooth(y,1),'-');
    f1.Color=[0.8500, 0.3250, 0.0980];
    f1.LineWidth=1.5;
    hold on
    f1=plot(ySmooth,'-');
    f1.Color=[0.9290, 0.6940, 0.1250];
    f1.LineWidth=2.5;
    
    grid on
    ylabel(['Voltage [V]'])
    xlabel('Time [s]')
    xlim([0 xlimMax])
    ylim([-0.011 0.01])
%     f1.LineWidth=1.5;
%     f1.MarkerSize=15;
    
%     x = MP(plotPos).Pos.var;
%     y = MP(plotPos).MP4.var;
%     p=round(numel(x)/10);
%     q=round(numel(y)/10);
%     y = resample(y,p,q);
%     y=y(1:numel(x));
%     
%     yyaxis right
%     f1=plot(x,y,'.');
%     f1.LineWidth=1.5;
%     f1.MarkerSize=15;
    
%      f1=plot(distributions(plotPos(n)).MP_backward_temp.position_x,distributions(plotPos(n)).MP_backward_temp.var,'.-');
%     f1.LineWidth=1.5;
%     f1.MarkerSize=15;
    

end
% f1.MarkerFaceColor='blue';

% xlim([-10,0])
% ylim([0.4,1.1])
% A=ylim;
% hold on
% plot([520 520],[A(1),A(2)],'k--','LineWidth',1)
% plot([920 920],[A(1),A(2)],'k--','LineWidth',1)


%% save
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','epsc')
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','png')
% print('D:\Data_analysis\figureOutputs\temp','-dpng')
% print('D:\Data_analysis\figureOutputs\temp','-deps')
% print('D:\Data_analysis\figureOutputs\temp','-dtiff')
print('D:\Data_analysis\figureOutputs\MPTempTIMEl','-dmeta')

disp('Fertig')