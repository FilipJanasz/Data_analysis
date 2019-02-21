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
% toPlot={'NC-MFR-ABS-N2-6_2'}; %use with GHFS3
% toPlot={'NC-MFR-ABS-2_5_4'};
% toPlot={'NC-MFR-ABS-He-4_4'}; %use with GHFS4
% toPlot={'NC-CMP-3_v1'}; %use with GHFS3
% toPlot={'NC-MFR-ABS-2_5_4','NC-CMP-3_v1','NC-MFR-ABS-6_4'};
toPlot={'NC-MFR-ABS-2_5_4','NC-CMP-5_v2real','NC-MFR-ABS-He-4_4'};
sensors={'GHFS3','GHFS2','GHFS3'};


for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end

% plotPos=[3,5,9,13,19];
% plotPos=[19];
h=figure;
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
    s1=subplot(2,1,1);
    periodFast=timing(plotPos(n)).fast;
    hold on
    grid on
%     xDat=distributions(plotPos(n)).MP_forward_temp.position_x;
    filtR=1;
    Fs1=1/periodFast;
    
    yDat=GHFS(plotPos(n)).(sensors{n}).var;
    yDat=detrend(yDat,'constant');
    [freq1, P1]=calcFFT(yDat,Fs1);
    P1(1)=1;
    f1=plot(freq1,P1,'-');
%     f2=plot(xDat,smooth(yDat,500),'-');
%     f1.LineWidth=1;
%     f2.LineWidth=2.5;
    f1.Color=colorstring{n};
%     f2.Color=f2.Color./1.5;

    ylabel('|P1(f)|','FontWeight','bold')
    box on
    
    
%     s1.YScale='log';
    s1.XScale='log';
    xlim([10^-2 50]);
    ylim([0 300]);
    %%
    s2=subplot(2,1,2);
    periodSlow=timing(plotPos(n)).slow;
    hold on
    grid on
    Fs2=1/periodSlow;
    currVar=['wall_heatflux_',sensors{n}];
    yDat=GHFS(plotPos(n)).(currVar).var;
    yDat=detrend(yDat,'constant');
    [freq2, P2]=calcFFT(yDat,Fs2);
    
    f3=plot(freq2,P2,'-');

% 
%     f3.LineWidth=1;
%     f3.MarkerSize=15;
    f3.Color=colorstring{n};
    box on
%     s2.YScale='log';
    s2.XScale='log';
    ylim([0 400]);
    xlim([10^-2 50]);
    lab=ylabel('|P1(f)|','FontWeight','bold');
%     xlim([500 700])
%     xlim([-10,0])
    xlabel('Frequency [Hz]','FontWeight','bold') 
    lab=legend('Mixing zone','Condensation zone','NC gas plug');
    lab.Location='northoutside';
    lab.Orientation='horizontal';
    lab.FontWeight='bold';
%     legend([f1,f3],{'GHFS','Double thermcouple'})
    

end

%% save
print('D:\Data_analysis\HF_FFT','-dmeta')

disp('Fertig')