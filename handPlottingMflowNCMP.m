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

% %files to plot
% toPlot={'NC-MFR-ABS-1_5_4-HF1','NC-MFR-ABS-He-4_1_5_2'};
% 
% for fCntr2=1:numel(toPlot)
%     plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
% end
 plotPos=[2,4,7,8,9,11,13];

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

for datCntr=1:numel(plotPos)
    xData(datCntr)=NC(plotPos(datCntr)).N2_molefraction.value/NC(plotPos(datCntr)).NC_molefraction.value;
    yData(datCntr)=steam(plotPos(datCntr)).mflow.value;
end
yData=yData.*1000;
% fit
% fitOrder='poly1';
% ft = fittype( fitOrder );
% [fitResult, gof] = fit( xData', yData', ft );

% f1=plot(fitResult,xData,yData);
f1=plot(xData,yData,'.');
hold on
% f1.LineWidth=1.5;
f1.MarkerSize=15;
% f1.MarkerFaceColor='blue';
grid on
a=legend('data','fit');
delete(a)
title('Steam condensation')
xlabel('N2 fraction in NC mixture')
ylabel('Steam condensation flux [g/s]')






%% save
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','epsc')
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','png')
% print('D:\Data_analysis\figureOutputs\temp','-dpng')
% print('D:\Data_analysis\figureOutputs\temp','-deps')
% print('D:\Data_analysis\figureOutputs\temp','-dtiff')
print('D:\Data_analysis\figureOutputs\mflowN2_CMP','-dmeta')

display('Fertig')