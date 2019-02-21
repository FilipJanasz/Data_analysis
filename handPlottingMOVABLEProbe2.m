clc
h=figure;
hold on
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

addpath 'D:\Data_analysis\export_figure'
% Defaults for this blog post
width = 4;     % Width in inches
height = 1;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(file)
    allFiles{fCntr}=file(fCntr).name;
end

%files to plot
% toPlot={'NC-MFR-ABS-1_4-LF','NC-MFR-ABS-1_4-HF'};
toPlot={'NC-MFR-ABS-N2-6_2_2','NC-MFR-ABS-N2-6_2_5v2','NC-MFR-ABS-N2-6_4'};
% toPlot={'NC-MFR-ABS-2_4_1','NC-MFR-ABS-2_5_4','NC-MFR-ABS-He-4_1','NC-MFR-ABS-He-4_1_2'};

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
Forleg=[];
for n=1:numel(toPlot)
    box on
    xDat=distributions(plotPos(n)).MP_forward_temp.position_x;
    yDat=distributions(plotPos(n)).MP_forward_temp.var;
    yStd=distributions(plotPos(n)).MP_forward_temp.std;
    yMin=yDat-yStd;
    yMax=yDat+yStd;
    if n==3
        offs=13;
        yDat=yDat+offs;
        yMin=yMin+offs;
        yMax=yMax+offs;
    end
    
    %fill region
    x2=[xDat', fliplr(xDat')];
    inBetween=[yMin',fliplr(yMax')];
    fl=fill(x2,inBetween,'g');
    fl.FaceAlpha=0.4;
    fl.FaceColor=colorstring{n};
    fl.EdgeAlpha=0.3;
%     fl.LineStyle='none';
    fl.EdgeColor=colorstring{n};
    %plot data
    f=plot(xDat,yDat,'-');
    f.LineWidth=1.5;
    f.MarkerSize=15;
    f.Color=colorstring{n};
    
%     f2=plot(xDat,yMin,'-');
%     f2.Color=colorstring{n};
%     f3=plot(xDat,yMax,'-');
%     f3.Color=colorstring{n};
    
    grid on

    xlim([-10,0])
%     if n==1
%         temp=ylim;
%         ylim([floor(temp(1)) ceil(temp(2))]);
%         range=temp(2)-temp(1);
%     else
%         temp2=ylim;
%         ylim([ceil(temp2(2))-range ceil(temp2(2))]);
%     end
% s.YLabel.FontWeight='bold';
% s.XLabel.FontWeight='bold';
Forleg=[Forleg,f];
end
xlabel('Horizontal position [mm]','FontWeight','bold')
ylabel('Temp. [\circC]','FontWeight','bold')
% ylim([0.4,1.1])
A=ylim;
hold on
l=legend(Forleg,toPlot,'Interpreter','none');
l.Location='northoutside';
l.Orientation='horizontal';
l.FontWeight='bold';

% plot([520 520],[A(1),A(2)],'k--','LineWidth',1)
% plot([920 920],[A(1),A(2)],'k--','LineWidth',1)


%% save
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','epsc')
%  saveas(gcf,'D:\Data_analysis\figureOutputs\temp','png')
% print('D:\Data_analysis\figureOutputs\temp','-dpng')
% print('D:\Data_analysis\figureOutputs\temp','-deps')
% print('D:\Data_analysis\figureOutputs\temp','-dtiff')
print('D:\Data_analysis\MPTempHorizontal','-dmeta')

disp('Fertig')