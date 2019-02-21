clc


addpath 'D:\Data_analysis\export_figure'
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

% Defaults for this blog post
width = 4;     % Width in inches
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
toPlot=allFiles;
toPlot={'NC-MFR-ABS-1_4-HF'};
% toPlot={'NC-MFR-ABS-2_5_4_2'};
% toPlot={'NC-MFR-ABS-He-4_1_5'};


for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end

% plotPos=[3,5,9,13,19];
% plotPos=[19];

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

    subplot(2,1,1)
    hold on
    grid on
    xDat=distributions(plotPos(n)).MP_forward_temp.position_x;
    yDat=distributions(plotPos(n)).MP_forward_temp.var;
    yStd=distributions(plotPos(n)).MP_forward_temp.std;
    yMin=yDat-yStd;
    yMax=yDat+yStd;
    
    f1=plot(xDat,yDat,'-');
    f1.LineWidth=1.5;
    f1.MarkerSize=15;
    


    ylabel(['Temperature [\circC]'],'FontWeight','bold')
    x2=[xDat', fliplr(xDat')];
    inBetween=[yMin',fliplr(yMax')];
    fl=fill(x2,inBetween,'g');
    fl.FaceAlpha=0.4;
    fl.FaceColor=colorstring{1};
    fl.EdgeAlpha=0.3;
    fl.EdgeColor=colorstring{1};
    bLay=-MP(plotPos(n)).T_boundlayer_forward.value;
    plot([bLay bLay], ylim,'k--')
    xlim([-10,0])
    box on
    
    subplot(2,1,2)
    hold on
    grid on
    xDat=distributions(plotPos(n)).MP_forward_temp.position_x;
    smth=1;
    yDat=smooth(distributions(plotPos(n)).MP_forward_MP4.var,smth)-min(smooth(distributions(plotPos(n)).MP_forward_MP4.var,smth));
    yStd=distributions(plotPos(n)).MP_forward_MP4.std;
    yMin=smooth(yDat-yStd,smth);
    yMax=smooth(yDat+yStd,smth);
    f1=plot(xDat,yDat,'-');
    f1.LineWidth=1.5;
    f1.MarkerSize=15;
    f1.Color=colorstring{2};
    

    ylabel(['Traversing electrode [V]'],'FontWeight','bold')
    x2=[xDat', fliplr(xDat')];
    inBetween=[yMin',fliplr(yMax')];
    fl=fill(x2,inBetween,'g');
    fl.FaceAlpha=0.4;
    fl.FaceColor=colorstring{2};
    fl.EdgeAlpha=0.3;
    fl.EdgeColor=colorstring{2};
    plot([bLay bLay], ylim,'k--')
    grid on
    box on
    xlim([-10,0])
    xlabel('Horizontal position [mm]','FontWeight','bold') 
    

end

%% save
print('D:\Data_analysis\MPELECTRHorizontal','-dmeta')

disp('Fertig')