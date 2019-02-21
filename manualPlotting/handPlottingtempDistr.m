clc
h=figure;

addpath 'D:\Data_analysis\export_figure'
% Defaults for this blog post
width = 0;     % Width in inches
height = 1;    % Height in inches
alw = 0.75;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(file)
    allFiles{fCntr}=file(fCntr).name;
end

%files to plot
toPlot={'NC-MFR-ABS-1_5_4-HF1','NC-MFR-ABS-He-4_1_5_2'};

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

subplot(2,1,1)
hold on

f1=plot(distributions(plotPos(1)).centerline_temp.position_y,distributions(plotPos(1)).centerline_temp.value.cal,'.-');
f1.LineWidth=1.5;
f1.MarkerSize=15;
% f1.MarkerFaceColor='blue';
grid on
title('Vertical temperature distribution')

f2=plot(distributions(plotPos(2)).centerline_temp.position_y,distributions(plotPos(2)).centerline_temp.value.cal,'rd-.');
f2.LineWidth=1.5;
f2.MarkerSize=5;
% f2.MarkerFaceColor='k';
grid on
ylabel(['Temp. [',char(176),'C]'])
xlabel('Vertical position [mm]')
xlim([600, 1300])
ylim([120, 150])

legend('N_2','He')
%%
subplot(2,1,2)
hold on

f1=plot(distributions(plotPos(1)).centerline_temp.position_y,distributions(plotPos(1)).centerline_temp.std,'.-');
f1.LineWidth=1.5;
f1.MarkerSize=15;
% f1.MarkerFaceColor='blue';
grid on
title('Vertical temperature oscillations')


f2=plot(distributions(plotPos(2)).centerline_temp.position_y,distributions(plotPos(2)).centerline_temp.std,'rd-.');
f2.LineWidth=1.5;
f2.MarkerSize=5;
% f2.MarkerFaceColor='k';
grid on
ylabel(['St. d. [',char(176),'C]'])
xlabel('Vertical position [mm]')
xlim([600, 1300])
ylim([0, 2])

legend('N_2','He')

%% save
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','epsc')
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','png')
% print('D:\Data_analysis\figureOutputs\temp','-dpng')
% print('D:\Data_analysis\figureOutputs\temp','-deps')
% print('D:\Data_analysis\figureOutputs\temp','-dtiff')
print('D:\Data_analysis\figureOutputs\tempSTDDistr','-dmeta')

display('Fertig')