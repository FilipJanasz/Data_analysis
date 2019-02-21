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


plotPos=[6,4,2];  %use it with C-INT files (He 4_5 MIX 4_5 N2 4_5)
yst=[2460,1360,850];

h=figure;
 legF=[];
 ctr=0;
for n=1:numel(plotPos)
    
    % Set the default Size for display
    s(1)=subplot(1,2,1);
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
%     s1=subplot(numel(plotPos),1,n);
    hold on
    grid on
    box on
    filtR=1;
    period=timing(plotPos(n)).fast;
    freq=1/period;

    frontArr=yst(n);
    yDat1=GHFS(plotPos(n)).GHFS2.var(frontArr*freq:(frontArr+300)*freq);
    yDat1=detrend(yDat1,'constant');
%     [fres,P1]=calcFFT(yDat1,freq);
    [P1,fres]=pspectrum(yDat1,100,'FrequencyResolution',0.1);
    f1=plot(fres,pow2db(abs(P1)),'-');
    f1.LineWidth=1.5;
    f1.Color=colorstring{n};

    ylabel('Power spectrum [dB]','FontWeight','bold')
    xlabel('frequency [Hz]','FontWeight','bold') 
%     ylim([10^-2,5000])
    xlim([10^-2,50])
    legF=[legF,f1];
%     h.Children.XScale='log';
%     h.Children.YScale='log';

%%
    s(2)=subplot(1,2,2);
    hold on
    grid on
    box on
    ctr=ctr+1;
    [P2{ctr},fres2{ctr}]=pspectrum(yDat1,100,'FrequencyResolution',0.02);
    f2=plot(fres2{ctr},pow2db(abs(P2{ctr})),'-');
    f2.LineWidth=1.5;
    f2.Color=colorstring{n};
    xlim([0 5])
    xlabel('f [Hz]','FontWeight','bold') 
end
s(1)=subplot(1,2,1);
leg=legend(legF,{'N_2','Mix','He'});

leg.Location='north';
leg.Orientation='horizontal';
% leg=legend(legF,{'He','Mix','N_2'},'FontWeight','bold');
% leg=legend(legF,{'He','Mix','N_2'},'FontWeight','bold');
s(1).Position=[0.1300    0.1600    0.6    0.8000];
s(2).Position=[0.7703    0.1600    0.1347    0.8000];

%% save
print('D:\Data_analysis\HFvsNCgasCONTINJ_FFT','-dmeta')

disp('Fertig')