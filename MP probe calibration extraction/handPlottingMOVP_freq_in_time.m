clc

addpath 'D:\Data_analysis\export_figure'
% Defaults for this blog post
width = 3;     % Width in inches
height = 4;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(GHFS_file)
    allFiles{fCntr}=GHFS_file(fCntr).name;
end

%files to plot
% toPlot={'NC-MFR-ABS-1_4-LF'};
% toPlot={'NC-MFR-ABS-1_4-LF','NC-MFR-ABS-1_5_4-LF2','NC-MFR-ABS-2_5_4_2'};
toPlot=allFiles;

for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end
 everySecond=1:2:numel(plotPos);
 plotPos=plotPos(everySecond);

%    h=figure;
%     h.Name=toPlot{n};
%     h.Position=([500 200 500+width*100, 200+height*100]);
% 
%     % Set the defaults for saving/printing to a file
%     set(h,'defaultFigureInvertHardcopy','on'); % This is the default anyway
%     set(h,'defaultFigurePaperUnits','inches'); % This is the default anyway
%     defsize = get(gcf, 'PaperSize');
%     left = (defsize(1)- width)/2;
%     bottom = (defsize(2)- height)/2;
%     defsize = [left, bottom, width, height];
%     set(h, 'defaultFigurePaperPosition', defsize);
    
for n=1:numel(plotPos)
    
    % Set the default Size for display
    % defpos = get(0,'defaultFigurePosition');
    currFile=plotPos(n);
    xlimMax=1;
    
    % timming
    period=9.92359E-5;
    acqRate=1/period;
    
    
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
%     subplot(3,1,1)
    currFile=plotPos(n);
    y=GHFS_data(currFile).M.var;
    x=period:period:numel(y)/acqRate;
    f1=plot(x,y,'-');
    f1.LineWidth=2.5;
    grid on
    ylabel(['Position [mm]'])
    xlim([0 xlimMax])
%     title(GHFS_file(currFile).name)
        
    
%     % fft
%     Fs = acqRate;           % Sampling frequency
% 
% %     L = numel(y_dat)+10000;       % Length of signal
%     L=numel(y);
%     % t = x;              % Time vector
%     
% 
%     Y=fft(y);           % calculates fft
%     P2 = abs(Y/L);
%     P1 = P2(1:round(L/2)+1);
%     P1(2:end-1) = 2*P1(2:end-1);
%     f1 = Fs*(0:(round(L/2)))/L;
% 
%     % remove spike at 0
%     P1(1)=0;
% %     grid on
% %     ylabel(['Voltage [V]'])
% %     xlabel('Time [s]')
% %     xlim([0 xlimMax])
% %     ylim([-0.011 0.01])
% %     
%     plot(f1,P1)
%     ylabel('|P1(f)|')
%     xlim([7.5 25])
%     RPM=(str2double(toPlot{currFile}(end-1:end)))/100*220;
%     actualFreq=6*(RPM/60);
% %     title(num2str(actualFreq));
%     
%     A=ylim;
%     hold on
%     plot([actualFreq actualFreq],[A(1),A(2)],'k--','LineWidth',0.5)
%     xlabel('Frequency [Hz]')
    

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
print('D:\Data_analysis\figureOutputs\MPTempFREQ_inTime','-dmeta')

disp('Fertig')