clc

clear allFiles x
addpath 'D:\Data_analysis\export_figure'
% Defaults for this blog post

% all files

% use data from here : D:\Movable Probe\Probe Calibration_Guillaume\05.11.2015 bis\increase
for fCntr=1:numel(GHFS_file)
    allFiles{fCntr}=GHFS_file(fCntr).name;
end

%files to plot
% toPlot={'NC-MFR-ABS-1_4-LF','NC-MFR-ABS-1_4-HF'};
toPlot=allFiles;

for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end
% 
% 

for n=1:numel(toPlot)
    
    currFile=plotPos(n);
    fDat(n)=GHFS_data(currFile).F.value;
    lDat(n)=GHFS_data(currFile).L.value;
    mDat(n)=GHFS_data(currFile).M.value;
    
    x(n)=GHFS_data(currFile).filmThick.value;

end


fDatNorm=(fDat-min(fDat))./(max(fDat)-min(fDat));
lDatNorm=(lDat-min(lDat))./(max(lDat)-min(lDat));
mDatNorm=(mDat-min(mDat))./(max(mDat)-min(mDat));

x=x./10; %convert to mm

% h=figure;
% hold on
width = 2;     % Width in inches
height = 4;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize

% % Set the default Size for display
% % defpos = get(0,'defaultFigurePosition');
% h.Position=([500 200 500+width*100, 200+height*100]);
% 
% % Set the defaults for saving/printing to a file
% set(h,'defaultFigureInvertHardcopy','on'); % This is the default anyway
% set(h,'defaultFigurePaperUnits','inches'); % This is the default anyway
% defsize = get(gcf, 'PaperSize');
% side = (defsize(1)- width)/2;
% bottom = (defsize(2)- height)/2;
% defsize = [side, bottom, width, height];
% set(h, 'defaultFigurePaperPosition', defsize);
% 


% subplot(2,1,1)
% hold on
% f1=plot(x,fDat,'.-');
% f1.LineWidth=1.5;
% f1.MarkerSize=15;
% 
% f1=plot(x,lDat,'.-');
% f1.LineWidth=1.5;
% f1.MarkerSize=15;
% 
% f1=plot(x,mDat,'.-');
% f1.LineWidth=1.5;
% f1.MarkerSize=15;
% 
% grid on
% ylabel(['Voltage [V]'])
% 
% % normalized
% subplot(2,1,2)
% hold on
% f1=plot(x,fDatNorm,'.-');
% f1.LineWidth=1.5;
% f1.MarkerSize=15;
% 
% f1=plot(x,lDatNorm,'.-');
% f1.LineWidth=1.5;
% f1.MarkerSize=15;
% 
% f1=plot(x,mDatNorm,'.-');
% f1.LineWidth=1.5;
% f1.MarkerSize=15;
%     
%     
% grid on
% ylabel(['Normalized signal [-]'])
% xlabel('Film thickness [mm]')
% % xlim([-10,0])
% % ylim([0.4,1.1])
% A=ylim;
% legend({'Top electrode','Side electrode','Center electrode'},'Location','southoutside','Orientation','horizontal')
% 
% % plot([520 520],[A(1),A(2)],'k--','LineWidth',1)
% % plot([920 920],[A(1),A(2)],'k--','LineWidth',1)
% %% save
% %  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','epsc')
% %  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','png')
% % print('D:\Data_analysis\figureOutputs\temp','-dpng')
% % print('D:\Data_analysis\figureOutputs\temp','-deps')
% % print('D:\Data_analysis\figureOutputs\temp','-dtiff')
% print('D:\Data_analysis\figureOutputs\MPCalibration','-dmeta')
% 
% disp('Fertig')

%% polyfit
pos=find(x>1);
xMax=pos(1);

xFit=x(1:xMax);

totalDat={fDat,lDat,mDat};
h=figure;

% Set the default Size for display
% defpos = get(0,'defaultFigurePosition');
h.Position=([500 200 500+width*100, 200+height*100]);

% Set the defaults for saving/printing to a file
set(h,'defaultFigureInvertHardcopy','on'); % This is the default anyway
set(h,'defaultFigurePaperUnits','inches'); % This is the default anyway
defsize = get(gcf, 'PaperSize');
side = (defsize(1)- width)/2;
bottom = (defsize(2)- height)/2;
defsize = [side, bottom, width, height];
set(h, 'defaultFigurePaperPosition', defsize);

electrNames={'Top electrode','Side electrode','Center electrode'};

for n=1:3
%     yFit=xFit;
%     xFit=totalDat{n}(1:xMax)-0.9;
        yFit=totalDat{n}(1:xMax);
%     temp=xFit;
%     xFit=yFit;
    
    fitCoef=polyfit(xFit,yFit,4);

    fitDat=fitCoef(1).*xFit.^4+fitCoef(2).*xFit.^3+fitCoef(3).*xFit.^2+fitCoef(4).*xFit+fitCoef(5);
    % fitDat=zeros(1,numel(xFit));
    % for n=1:numel(fitCoef)
    %     fitDat=fitCoef(n).*xFit.^(n-1)+fitDat;
    % end

    s1=subplot(3,1,n);
    box on
    switch n
        case 1
            s1.Position=[0.1300 0.7593 0.7750 0.2157];
        case 2
            s1.Position=[0.1300    0.4596    0.7750    0.2157];
        case 3
            s1.Position=[0.1300    0.1600    0.7750    0.2157];
    end
    hold on
    grid on
    ylabel(electrNames{n},'FontWeight','bold')
    f1=plot(xFit,yFit,'.-');
    f1.LineWidth=1.5;
    f1.Marker='o';
    f1.MarkerSize=6;
    f1.MarkerFaceColor=f1.Color;
    
    %plot second
    f1=plot(xFit,fitDat,'.-');
    f1.LineWidth=1.5;
    f1.Marker='^';
    f1.MarkerSize=4;
    f1.MarkerFaceColor=f1.Color;
    
    %calculate slop
    slope{n}=diff(yFit)./diff(xFit);
end

xlabel('Film thickness [mm]','FontWeight','bold')
l1=legend({'Data','4th order poly fit'},'Location','southoutside','Orientation','horizontal');
l1.Position=[0.3829 0.0850 0.2700 0.0283];
s1.Position=[0.1300    0.2000    0.7750    0.2157];


%% clear up voltage related error
err(1)=0.001456;
err(2)=0.003456;

for m=1:3
    for n=1:2
        thickErr(m,n)=err(n)*max(slope{m});
    end
end
%% save
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','epsc')
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','png')
% print('D:\Data_analysis\figureOutputs\temp','-dpng')
% print('D:\Data_analysis\figureOutputs\temp','-deps')
% print('D:\Data_analysis\figureOutputs\temp','-dtiff')
print('D:\Data_analysis\figureOutputs\MPCalibrationFIT','-dmeta')

disp('Fertig')