clc

clear toPlot plotPos
addpath 'D:\Data_analysis\export_figure'
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

% Defaults for this blog post
width = 6;     % Width in inches
height = 3;    % Height in inches
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
toPlot={'NC-MFR-ABS-N2-6_1_5_2'}; 
% toPlot={'NC-MFR-ABS-2_5_4'}; %use with GHFS3
% toPlot={'NC-MFR-ABS-He-4_4'}; %use with GHFS4
% toPlot={'NC-CMP-3_v1'}; %use with GHFS3


for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end

% plotPos=[3,5,9,13,19];
% plotPos=[19];
xSt=420;
xEn=430;
for n=1:numel(plotPos)
    h=figure;
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
    subplot(2,1,1)
    hold on
    grid on
%     xDat=distributions(plotPos(n)).MP_forward_temp.position_x;
    filtR=1;
    freq=100;
    smTh=0.1;
    yDat1=GHFS(plotPos(n)).GHFS1_offset_raw.var;
% yDat1=steam(plotPos(n)).TF9610.var;

%     xDat=0.001:0.001:numel(yDat)/1000;
%     f1=plot(xDat,yDat,'-');
%     lowpassF=0.1;
%     Fnorm=lowpassF/(1000/2);
%     [num,den]=butter(4,Fnorm);
%     yDat=filtfilt(num,den,yDat);
%     yDat=medfilt1(yDat,filtR,'truncate' );
%     yDat=yDat(50000:end-500000);
    yDat1=(yDat1-min(yDat1))./max(yDat1-min(yDat1));
    yDat1=detrend(yDat1);
    xDat=1/freq:1/freq:numel(yDat1)/freq;
%     yStd=MP(plotPos(n)).MP4.std;
%     yMin=yDat-yStd;
%     yMax=yDat+yStd;
    yDat1filt=smooth(yDat1,smTh*freq);
    f1=plot(xDat,yDat1,'-');
    f2=plot(xDat,yDat1filt,'-');
    f1.LineWidth=1;
    f2.LineWidth=2.5;
    f2.Color=colorstring{1};
    f2.Color=f2.Color./1.5;

%     ylabel(['Heat flux [W/m^2]'],'FontWeight','bold')
    box on
    xlim([xSt xEn])
    %%
    subplot(2,1,2)
    hold on
    grid on
    freq2=100;
%     yDat=GHFS(plotPos(n)).wall_dT_GHFS1.var;
%     yDat=GHFS(plotPos(n)).wall_heatflux_GHFS3.var;
%     yDat=GHFS(plotPos(n)).GHFS3_temp.var;
    yDat2=GHFS(plotPos(n)).GHFS2_offset_raw.var;
    
%     yDat2=steam(plotPos(n)).TF9611.var;
%     yDat=filtfilt(num,den,yDat);
%     yDat=medfilt1(yDat,1,'truncate' );
%     yDat=yDat(50000:end-500000);
    
    yDat2=(yDat2-min(yDat2))./max(yDat2-min(yDat2));
    yDat2=detrend(yDat2);
    yDat2filt=smooth(yDat2,smTh*freq2);
    xDat=1/freq2:1/freq2:numel(yDat2)/freq2;
%     yStd=MP(plotPos(n)).MP2.std;
%     yMin=smooth(yDat-yStd,smth);
%     yMax=smooth(yDat+yStd,smth);
    f3=plot(xDat,yDat2,'-');
    f4=plot(xDat,yDat2filt,'-');
    f3.LineWidth=1;
    f3.MarkerSize=15;
    f3.Color=colorstring{2};
    f4.LineWidth=2.5;
    f4.Color=colorstring{2};
    f4.Color=f4.Color./1.5;
    

%     ylabel(['Temperature [C]'],'FontWeight','bold')
%     x2=[xDat', fliplr(xDat')];
%     inBetween=[yMin',fliplr(yMax')];
%     fl=fill(x2,inBetween,'g');
%     fl.FaceAlpha=0.4;
%     fl.FaceColor=colorstring{2};
%     fl.EdgeAlpha=0.3;
%     fl.EdgeColor=colorstring{2};

    grid on
    box on
    xlim([xSt xEn])
%     xlim([-10,0])
    xlabel('Time [s]','FontWeight','bold') 
    legend([f1,f3],{'GHFS','Double thermcouple'})

end
% calcXCorr(yDat1filt,yDat2filt,100,freq)
%% save
print('D:\Data_analysis\HF_dTvsGHFS','-dmeta')

disp('Fertig')