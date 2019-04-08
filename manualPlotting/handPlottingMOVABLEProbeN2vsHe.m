clc
h=figure;
hold on
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

addpath 'D:\Data_analysis\export_figure'
% Defaults for this blog post
width = 4;     % Width in inches
height = 6;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(file)
    allFiles{fCntr}=file(fCntr).name;
end

%files to plot
% toPlot={'NC-MFR-ABS-1_4-LF','NC-MFR-ABS-1_4-HF'};
% toPlot={'NC-MFR-ABS-N2-6_2_2','NC-MFR-ABS-N2-6_2_5v2','NC-MFR-ABS-N2-6_4'};
% toPlot={'NC-MFR-ABS-2_4_1','NC-MFR-ABS-2_5_4','NC-MFR-ABS-He-4_1','NC-MFR-ABS-He-4_1_2'};
toPlot={'NC-MFR-ABS-2_4_1','NC-MFR-ABS-He-4_1_2','NC-CMP-5_v1real','NC-MFR-ABS-N2-6_2_5v2','NC-MFR-ABS-He-4_2_2','NC-CMP-4_v1','NC-MFR-ABS-4_4','NC-MFR-ABS-He-4_3_2','NC-CMP-1_v3'};
breakPos=3;
breakPos2=6;

for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end


% Set the default Size for display
% defpos = get(0,'defaultFigurePosition');
h.Position=([1010 200 500+width*100, 100+height*100]);

% Set the defaults for saving/printing to a file
set(h,'defaultFigureInvertHardcopy','on'); % This is the default anyway
set(h,'defaultFigurePaperUnits','inches'); % This is the default anyway
defsize = get(gcf, 'PaperSize');
left = (defsize(1)- width)/2;
bottom = (defsize(2)- height)/2;
defsize = [left, bottom, width, height];
set(h, 'defaultFigurePaperPosition', defsize);

xCut=-10;

Forleg1=[];
Forleg2=[];
Forleg3=[];
%%
markerList={'-o','-^','-d'};

subplot(3,1,1)
hold on
for n=1:breakPos
    box on
    
    xDat=distributions(plotPos(n)).MP_forward_temp.position_x;
    yDat=distributions(plotPos(n)).MP_forward_temp.var;
    yStd=distributions(plotPos(n)).MP_forward_temp.std;
    yMin=yDat-yStd;
    yMax=yDat+yStd;

    %fill region
    x2=[xDat', fliplr(xDat')];
    inBetween=[yMin',fliplr(yMax')];
    fl=fill(x2,inBetween,'g');
    fl.FaceAlpha=0.15;
    fl.FaceColor=colorstring{n};
    fl.EdgeAlpha=0.15;

    fl.EdgeColor=colorstring{n};
    %plot data
    f=plot(xDat,yDat,markerList{n},'MarkerIndices',1:10:length(yDat));
    f.LineWidth=1.5;
    f.MarkerSize=6;
    f.Color=colorstring{n};
    f.MarkerFaceColor=colorstring{n};
    Forleg1=[Forleg1,f];
    grid on

end
xlim([xCut,0])
ylabel('Temp. [\circC]','FontWeight','bold')
l=legend(Forleg1,{'N_2','He','1:1 molar mixture of N_2 and He'});
l.Location='northoutside';
l.Orientation='horizontal';
l.FontWeight='bold';

%%
subplot(3,1,2)
hold on
for n=breakPos+1:breakPos2
    box on
    xDat=distributions(plotPos(n)).MP_backward_temp.position_x;
    yDat=distributions(plotPos(n)).MP_backward_temp.var;
    yStd=distributions(plotPos(n)).MP_backward_temp.std;
    yMin=yDat-yStd;
    yMax=yDat+yStd;
    if strcmp(toPlot{n},'NC-MFR-ABS-N2-6_2_5v2')
        offs=12;
        yDat=yDat-offs;
        yMin=yMin-offs;
        yMax=yMax-offs;
    elseif strcmp(toPlot{n},'NC-CMP-4_v1')
        offs=-12;
        yDat=yDat-offs;
        yMin=yMin-offs;
        yMax=yMax-offs;
    end
    %fill region
    x2=[xDat', fliplr(xDat')];
    inBetween=[yMin',fliplr(yMax')];
    fl=fill(x2,inBetween,'g');
    fl.FaceAlpha=0.1;
    fl.FaceColor=colorstring{n-breakPos};
    fl.EdgeAlpha=0.1;

    fl.EdgeColor=colorstring{n-breakPos};
%    plot data
    f=plot(xDat,yDat,markerList{n-breakPos},'MarkerIndices',1:10:length(yDat));
    f.LineWidth=1.5;
    f.MarkerSize=6;
    f.Color=colorstring{n-breakPos};
    f.MarkerFaceColor=colorstring{n-breakPos};
    Forleg3=[Forleg3,f];
    grid on

end
xlim([xCut,0])
ylabel('Temp. [\circC]','FontWeight','bold')
% l=legend(Forleg1,{'N_2','He','1:1 MIX'});
% l.Location='northoutside';
% l.Orientation='horizontal';
% l.FontWeight='bold';
%%
subplot(3,1,3)
hold on
for n=breakPos2+1:numel(toPlot)
    box on
    xDat=distributions(plotPos(n)).MP_forward_temp.position_x;
    yDat=distributions(plotPos(n)).MP_forward_temp.var;
    yStd=distributions(plotPos(n)).MP_forward_temp.std;
    yMin=yDat-yStd;
    yMax=yDat+yStd;

    if strcmp(toPlot{n},'NC-CMP-1_v3')
        xDat=xDat-19;
        yDat=yDat-2.5;
        yMin=yMin-2.5;
        yMax=yMax-2.5;
    end
    %fill region
    x2=[xDat', fliplr(xDat')];
    inBetween=[yMin',fliplr(yMax')];
    fl=fill(x2,inBetween,'g');
    fl.FaceAlpha=0.1;
    fl.FaceColor=colorstring{n-breakPos2};
    fl.EdgeAlpha=0.1;

    fl.EdgeColor=colorstring{n-breakPos2};
    %plot data
    f=plot(xDat,yDat,markerList{n-breakPos2},'MarkerIndices',1:10:length(yDat));
    f.LineWidth=1.5;
    f.MarkerSize=6;
    f.Color=colorstring{n-breakPos2};
    f.MarkerFaceColor=colorstring{n-breakPos2};
    Forleg3=[Forleg3,f];
    grid on

end
ylim([118 119.5])
xlim([xCut,0])

xlabel('Horizontal position [mm], wall at 0 mm, tube center at -10 mm','FontWeight','bold')
ylabel('Temp. [\circC]','FontWeight','bold')
% ylim([0.4,1.1])
A=ylim;
hold on


% plot([520 520],[A(1),A(2)],'k--','LineWidth',1)
% plot([920 920],[A(1),A(2)],'k--','LineWidth',1)


%% save
print('D:\Data_analysis\MPTempHorizontal_variousZones','-dmeta')

disp('Fertig')