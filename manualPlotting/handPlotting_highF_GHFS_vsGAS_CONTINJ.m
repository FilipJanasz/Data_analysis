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
%

plotPos=[2,4,6];
% yst=[850,1360,2460]; %for GHFS2
yst=[600,1130,2200]; %for GHFS3
range=400;

h=figure;
legF=[];
markerList={'-v','-s','-o'};
markerListTemp={'-^','-d','-*'};
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

    filtR=1;
    period=timing(plotPos(n)).fast;
    freq=1/period;
    frontArr=yst(n);
    yDat1{n}=GHFS(plotPos(n)).GHFS3.var(frontArr*freq:(frontArr+range)*freq);


    yDat2{n}=steam(plotPos(n)).TF9608.var(frontArr:(frontArr+range)); % GHFS 3


    xDat=period:period:numel(yDat1{n})*period;

    
    f1=plot(xDat,yDat1{n},markerList{n},'MarkerIndices',1:8000:length(yDat1{n}));
    f1.LineWidth=1.5;
    f1.Color=colorstring{n};
    f1.MarkerFaceColor=f1.Color./1.3;
    f1.MarkerEdgeColor=f1.MarkerFaceColor;
    

     ylabel('Heat flux [W/m^2]','FontWeight','bold')
     ylim([0 10000])
 %%
    yyaxis right
    f3=plot(yDat2{n},markerListTemp{n},'MarkerIndices',1:80:length(yDat2{n}));
    f3.Color=colorstring{n};
    f3.Color=f3.Color./1.3;
    f3.MarkerFaceColor=f3.Color./1.3;
    f3.MarkerEdgeColor=f3.MarkerFaceColor;
    ylim([115 147])
    ylabel(['Temperature [',char(176),'C]'],'FontWeight','bold')   
   
    box on
    grid on
    s1.YColor=[0.1500    0.1500    0.1500];
    xlabel('Time [s]','FontWeight','bold') 
    xlim([0,range])
    legF=[legF,f1,f3];
end
% leg=legend(legF,{'He','Mix','N_2'},'FontWeight','bold');
leg=legend(legF,{'He','He temp.','Mix','Mix temp.','N_2','N_2 temp.'},'FontWeight','bold');

leg.Location='northoutside';
leg.Orientation='horizontal';
leg.FontSize;
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
    