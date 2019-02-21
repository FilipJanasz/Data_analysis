clc

clear toPlot plotPos
addpath 'D:\Data_analysis\export_figure'
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

% Defaults for this blog post
width = 6;     % Width in inches
height = 5;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(file)
    allFiles{fCntr}=file(fCntr).name;
end

%files to plot
% toPlot={'NC-MFR-ABS-1_4-LF','NC-MFR-ABS-1_4-HF'};
% toPlot={'NC-MFR-ABS-1_4-HF'};
% toPlot=allFiles;
% toPlot={'NC-MFR-ABS-2_4_1'};
% toPlot={'NC-MFR-ABS-2_4_1','NC-MFR-ABS-He-4_1'}; %use with GHFS3
% toPlot={'NC-MFR-ABS-N2-6_2_5v2','NC-CMP-2_v1','NC-MFR-ABS-He-4_2_2'}; %use with GHFS2
% toPlot={'NC-MFR-ABS-2_5_4','NC-CMP-3_v1','NC-MFR-ABS-He-4_4'}; 
% toPlot={'NC-MFR-ABS-2_5_4'}; %use with GHFS3
% toPlot={'NC-MFR-ABS-He-4_4'}; %use with GHFS4
% toPlot={'NC-CMP-3_v1'}; %use with GHFS3


% for fCntr2=1:numel(toPlot)
% %     plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
% end

plotPos=[2,4,6];
yst=[850,1360,2460];

% plotPos=[19];
% xSt=200;
% xEnd=300;
h=figure;
 legF=[];
for n=1:numel(plotPos)
    
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
%%
    s1=subplot(numel(plotPos),1,n);
    hold on
    grid on
%     xSt=steam(plotPos(n)).contInj.frontArriv(7);
%     xEnd=xSt+500;
%     xDat=distributions(plotPos(n)).MP_forward_temp.position_x;
    filtR=1;
    period=timing(plotPos(n)).fast;
    freq=1/period;
%     frontArr=steam(plotPos(n)).contInj.frontArriv(2);
    frontArr=yst(n);
    yDat1{n}=GHFS(plotPos(n)).GHFS2.var(frontArr*freq:(frontArr+300)*freq);
    yDat3{n}=smooth(yDat1{n},8000);
    yDat2{n}=steam(plotPos(n)).TF9605.var(frontArr:(frontArr+300));

%     xDat=0.001:0.001:numel(yDat)/1000;
%     f1=plot(xDat,yDat,'-');
%     lowpassF=0.1;
%     Fnorm=lowpassF/(1000/2);
%     [num,den]=butter(4,Fnorm);
%     yDat=filtfilt(num,den,yDat);
%     yDat=medfilt1(yDat,filtR,'truncate' );
%     yDat=yDat(50000:end-500000);
% yDat=(yDat-min(yDat))./max(yDat-min(yDat));
    xDat=period:period:numel(yDat1{n})*period;
%     yStd=MP(plotPos(n)).MP4.std;
%     yMin=yDat-yStd;
%     yMax=yDat+yStd;
    
    f1=plot(xDat,yDat1{n},'-');
%     f2=plot(xDat,yDat3{n},'-');
    f1.LineWidth=1.5;
%     f2.LineWidth=2;
    f1.Color=colorstring{n};
%     f2.Color=colorstring{n};
%     f2.LineWidth=1.5;
%     f2.Color=colorstring{n};
%     f2.Color=f2.Color./1.15;
 ylabel('Heat flux [W/m^2]','FontWeight','bold')
%  xlim=([1 300]);
 %%
    yyaxis right
    f3=plot(yDat2{n},'-');
    f3.Color=colorstring{n};
    f3.Color=f3.Color./1.3;
  ylabel(['Temperature [',char(176),'C]'],'FontWeight','bold')   
   
    box on
    grid on
%     xlim([xSt xEnd])
    %%
%     s2=subplot(2,1,2);
%     hold on
%     grid on
% %     yDat=GHFS(plotPos(n)).wall_dT_GHFS1.var;
%     yDat=GHFS(plotPos(n)).wall_heatflux_GHFS3.var;
% %     yDat=GHFS(plotPos(n)).GHFS1_temp.var;
% %     yDat=filtfilt(num,den,yDat);
% %     yDat=medfilt1(yDat,1,'truncate' );
% %     yDat=yDat(50000:end-500000);
% 
% %     yDat=(yDat-min(yDat))./max(yDat-min(yDat));
%     xDat=1:1:numel(yDat);
% %     yStd=MP(plotPos(n)).MP2.std;
% %     yMin=smooth(yDat-yStd,smth);
% %     yMax=smooth(yDat+yStd,smth);
%     f3=plot(xDat,yDat,'-');
%     f4=plot(xDat,smooth(yDat,5),'-');
%     f3.LineWidth=1;
%     f3.MarkerSize=15;
%     f3.Color=colorstring{n};
%     f4.LineWidth=2;
%     f4.Color=colorstring{n};
%     f4.Color=f4.Color./1.15;
% 
% 
%     grid on
%     box on
%     xlim([xSt xEnd])
%     xlim([-10,0])
s1.YColor=[0.1500    0.1500    0.1500];
    xlabel('Time [s]','FontWeight','bold') 
    xlim([0,300])
%     legend([f1,f3],{'GHFS','Double thermcouple'})
    legF=[legF,f1,f3];
end
% leg=legend(legF,{'He','Mix','N_2'},'FontWeight','bold');
leg=legend(legF,{'He','He temp.','Mix','Mix temp.','N_2','N_2 temp.'},'FontWeight','bold');

leg.Location='northoutside';
leg.Orientation='horizontal';
%% save
print('D:\Data_analysis\HFvsNCgasCONTINJ','-dmeta')
% 
% disp('Fertig')
% 
% for n=1:numel(yDat1)
%     figure
% hold on
%     pspectrum(yDat1{n},100,'power')
% %     pspectrum(yDat2{n},'power')
% end
    