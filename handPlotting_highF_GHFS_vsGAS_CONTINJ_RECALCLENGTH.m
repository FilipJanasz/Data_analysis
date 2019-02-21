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
% yst=[850,1360,2460]; %for GHFS2
yst=[650,1200,2220]; %for GHFS3
yst=[550,1100,2120]; %for GHFS3
range=640;
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

    filtR=1;
    period=timing(plotPos(n)).fast;
    freq=1/period;
%     frontArr=steam(plotPos(n)).contInj.frontArriv(2);
    frontArr=yst(n);
%     yDat1{n}=steam(plotPos(n)).mixFront_GHFS3.var;
    yDat1{n}=GHFS(plotPos(n)).GHFS3.var(frontArr*freq:(frontArr+range)*freq);
    xDat=period:period:numel(yDat1{n})*period;


%     front{n}=GHFS(plotPos(n)).GHFS3_var(steam.
    f1=plot(xDat,yDat1{n},'-');
    f2=plot(xDat,smooth(yDat1{n},10),'-');
    f1.LineWidth=1.5;
    f2.LineWidth=2;
    f1.Color=colorstring{n};
    f2.Color=f1.Color./1.25;

 ylabel('Heat flux [W/m^2]','FontWeight','bold')

    box on
    grid on

    xlabel('Time [s]','FontWeight','bold') 
    xlim([0,range])
%     legend([f1,f3],{'GHFS','Double thermcouple'})
    legF=[legF,f1,f2];
end
% leg=legend(legF,{'He','Mix','N_2'},'FontWeight','bold');
leg=legend(legF,{'He','He temp.','Mix','Mix temp.','N_2','N_2 temp.'},'FontWeight','bold');

leg.Location='northoutside';
leg.Orientation='horizontal';
%% save
print('D:\Data_analysis\HFvsNCgasCONTINJ','-dmeta')

disp('Fertig')
h=figure;
h.Position=[315         437        1118         284];
for n=1:numel(yDat1)
    s(n)=subplot(1,numel(yDat1),n);
    spectrogram(yDat1{n},kaiser(64,18),32,128,1E2,'xaxis');
%     s(n)
%     s(n).Colorbar.Visible='off'
%     pspectrum(yDat1{n},100,'spectrogram');
%     h.Children(2).YScale='log';
%     pspectrum(yDat2{n},'power')
end
colormap jet
a=colorbar
a.Position=[0.9293 0.1197 0.0127 0.8063]
    