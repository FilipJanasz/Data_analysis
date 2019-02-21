clc
h=figure;
hold on

addpath 'D:\Data_analysis\export_figure'
% Defaults for this blog post
width = 0;     % Width in inches
height = 1;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(file)
    allFiles{fCntr}=file(fCntr).name;
end

%files to plot
% toPlot={'NC-MFR-ABS-1_4-LF','NC-MFR-ABS-1_4-HF'};
toPlot={'NC-MFR-ABS-1_4-LF'};

for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end


% Set the default Size for display
% defpos = get(0,'defaultFigurePosition');
h.Position=([500 200 500+width*100, 200+height*100]);

% Set the defaults for saving/printing to a file
set(h,'defaultFigureInvertHardcopy','on'); % This is the default anyway
set(h,'defaultFigurePaperUnits','inches'); % This is the default anyway
defsize = get(gcf, 'PaperSize');
left = (defsize(1)- width)/2;
bottom = (defsize(2)- height)/2;
defsize = [left, bottom, width, height];
set(h, 'defaultFigurePaperPosition', defsize);

hold on
for n=1:numel(toPlot)
    
    f1=plot(distributions(plotPos(n)).MP_forward_temp.position_x,distributions(plotPos(n)).MP_forward_temp.var,'.-');
    f1.LineWidth=1.5;
    f1.MarkerSize=15;
    
%      f1=plot(distributions(plotPos(n)).MP_backward_temp.position_x,distributions(plotPos(n)).MP_backward_temp.var,'.-');
%     f1.LineWidth=1.5;
%     f1.MarkerSize=15;
    

end
% f1.MarkerFaceColor='blue';
grid on
ylabel(['Temperature [\circC]'])
xlabel('Horizontal position [mm]')
xlim([-10,0])
% ylim([0.4,1.1])
A=ylim;
hold on
% plot([520 520],[A(1),A(2)],'k--','LineWidth',1)
% plot([920 920],[A(1),A(2)],'k--','LineWidth',1)


%% save
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','epsc')
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','png')
% print('D:\Data_analysis\figureOutputs\temp','-dpng')
% print('D:\Data_analysis\figureOutputs\temp','-deps')
% print('D:\Data_analysis\figureOutputs\temp','-dtiff')
print('D:\Data_analysis\figureOutputs\MPTempHorizontal','-dmeta')

display('Fertig')