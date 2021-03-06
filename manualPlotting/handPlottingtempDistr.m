clc
h=figure;

addpath 'D:\Data_analysis\export_figure'
% Defaults for this blog post
width = 6;     % Width in inches
height = 0;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(file)
    allFiles{fCntr}=file(fCntr).name;
end
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

%files to plot
toPlot={'VEL-DT-PURE-4','VEL-CLNT-NC-1'};

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

subplot(1,2,1)
hold on

f1=plot(distributions(plotPos(1)).centerline_temp.position_y,distributions(plotPos(1)).centerline_temp.value.cal,'o-');
f1.LineWidth=1.5;
f1.MarkerSize=5;
f1.Color=colorstring{1};
f1.MarkerFaceColor=colorstring{1};
% f1.MarkerFaceColor='blue';
grid on
title('Pure steam')

f2=plot(distributions(plotPos(2)).wall_inner.position_y,distributions(plotPos(1)).wall_inner.value.cal,'rd-');
f2.LineWidth=1.5;
f2.MarkerSize=5;
f2.Color=colorstring{2};
f2.MarkerFaceColor=colorstring{2};
% f2.MarkerFaceColor='k';

f3=plot(distributions(plotPos(1)).coolant_temp_0deg.position_y,distributions(plotPos(1)).coolant_temp_0deg.value.cal,'ys-');
f3.LineWidth=1.5;
f3.MarkerSize=7;
f3.Color=colorstring{3};
f3.MarkerFaceColor=colorstring{3};
ylim([104, 125])
grid on
box on
ylabel(['Temperature [',char(176),'C]'])
xlabel('Vertical position [mm]')
% legend('Centerline', 'Tube wall','Coolant')

%%
subplot(1,2,2)
hold on

f4=plot(distributions(plotPos(2)).centerline_temp.position_y,distributions(plotPos(2)).centerline_temp.value.cal,'o-');
f4.LineWidth=1.5;
f4.Color=colorstring{1};
f4.MarkerSize=5;
f4.MarkerFaceColor=colorstring{1};
% f1.MarkerFaceColor='blue';
grid on
% title('Vertical temperature oscillations')


f5=plot(distributions(plotPos(2)).coolant_temp_0deg.position_y,distributions(plotPos(2)).coolant_temp_0deg.value.cal,'d-');
f5.LineWidth=1.5;
f5.Color=colorstring{2};
f5.MarkerFaceColor=colorstring{2};
f5.MarkerSize=5;
% f2.MarkerFaceColor='k';

f6=plot(distributions(plotPos(2)).wall_inner.position_y,distributions(plotPos(2)).wall_inner.value.cal,'s-');
f6.LineWidth=1.5;
f6.Color=colorstring{3};
f6.MarkerFaceColor=colorstring{3};
f6.MarkerSize=7;


grid on
box on
ylabel(['Temperature [',char(176),'C]'])
xlabel('Vertical position [mm]')
% xlim([600, 1300])
% ylim([0, 2])
ylim([104, 125])
legend('Centerline', 'Tube wall','Coolant')
title('With NC gas')

%% save
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','epsc')
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','png')
% print('D:\Data_analysis\figureOutputs\temp','-dpng')
% print('D:\Data_analysis\figureOutputs\temp','-deps')
% print('D:\Data_analysis\figureOutputs\temp','-dtiff')
print('D:\Data_analysis\figureOutputs\Temp distr with and without NC','-dmeta')

disp('Fertig')