clc

clear toPlot plotPos
addpath 'D:\Data_analysis\export_figure'
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

% Defaults for this blog post
width = 6;     % Width in inches
height = 1;    % Height in inches
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
% toPlot={'NC-MFR-ABS-2_4_1','NC-MFR-ABS-He-4_1'}; %use with GHFS3  MIX ZONE
% toPlot={'NC-MFR-ABS-1_4-HF','NC-MFR-ABS-He-4_0_2'}; %use with GHFS1 COND ZONE
toPlot={'NC-MFR-ABS-6_4','NC-MFR-ABS-He-4_5'}; %use with GHFS3 GAS PLUG
% toPlot={'NC-MFR-ABS-N2-6_2_5v2','NC-CMP-2_v1','NC-MFR-ABS-He-4_2_2'}; %use with GHFS2
% toPlot={'NC-MFR-ABS-2_5_4','NC-CMP-3_v1','NC-MFR-ABS-He-4_4'}; 
% toPlot={'NC-MFR-ABS-2_5_4'}; %use with GHFS3
% toPlot={'NC-MFR-ABS-He-4_4'}; %use with GHFS4
% toPlot={'NC-CMP-3_v1'}; %use with GHFS3


for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end

% plotPos=[3,5,9,13,19];
% plotPos=[19];
xSt=200;
xEnd=300;
h=figure;
legText={'N_2, peak-to-peak ','He, peak-to-peak '};
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
    s1=subplot(1,2,n);
    hold on
    grid on
%     xDat=distributions(plotPos(n)).MP_forward_temp.position_x;
    filtR=1;
    period=timing(plotPos(n)).fast;
    freq=1/period;
    yDat{n}=GHFS(plotPos(n)).GHFS3.var;
%     xDat=0.001:0.001:numel(yDat{n})/1000;
%     f1=plot(xDat,yDat{n},'-');
%     lowpassF=0.1;
%     Fnorm=lowpassF/(1000/2);
%     [num,den]=butter(4,Fnorm);
%     yDat{n}=filtfilt(num,den,yDat{n});
%     yDat{n}=medfilt1(yDat{n},filtR,'truncate' );
%     yDat{n}=yDat{n}(50000:end-500000);
% yDat{n}=(yDat{n}-min(yDat{n}))./max(yDat{n}-min(yDat{n}));
    xDat=period:period:numel(yDat{n})*period;
%     yStd=MP(plotPos(n)).MP4.std;
%     yMin=yDat{n}-yStd;
%     yMax=yDat{n}+yStd;
    
    f1=plot(xDat,yDat{n},'-');
    f2=plot(xDat,smooth(yDat{n},freq),'-');
    f1.LineWidth=1;
    f2.LineWidth=2;
    f1.Color=colorstring{n};
    f2.Color=colorstring{n};
    f2.Color=f2.Color./1.15;

    ylabel(['Heat flux [W/m^2]'],'FontWeight','bold')
    box on
    grid on
    xlim([xSt xEnd])
%     ylim([1000 8000])
    ylim([0 1000])
   
    %%
%     s2=subplot(2,1,2);
%     hold on
%     grid on
% %     yDat{n}=GHFS(plotPos(n)).wall_dT_GHFS1.var;
%     yDat{n}=GHFS(plotPos(n)).wall_heatflux_GHFS3.var;
% %     yDat{n}=GHFS(plotPos(n)).GHFS1_temp.var;
% %     yDat{n}=filtfilt(num,den,yDat{n});
% %     yDat{n}=medfilt1(yDat{n},1,'truncate' );
% %     yDat{n}=yDat{n}(50000:end-500000);
% 
% %     yDat{n}=(yDat{n}-min(yDat{n}))./max(yDat{n}-min(yDat{n}));
%     xDat=1:1:numel(yDat{n});
% %     yStd=MP(plotPos(n)).MP2.std;
% %     yMin=smooth(yDat{n}-yStd,smth);
% %     yMax=smooth(yDat{n}+yStd,smth);
%     f3=plot(xDat,yDat{n},'-');
%     f4=plot(xDat,smooth(yDat{n},5),'-');
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
    xlabel('Time [s]','FontWeight','bold') 
%     legend([f1,f3],{'GHFS','Double thermcouple'})
leg=legend([legText{n},num2str(round(max(yDat{n})-min(yDat{n})))]);
leg.Location='northeast';
leg.FontWeight='bold';
end

%% save
print('D:\Data_analysis\HFvsNCgas_PLUG','-dmeta')

disp('Fertig')