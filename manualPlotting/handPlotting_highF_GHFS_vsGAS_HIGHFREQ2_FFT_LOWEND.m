clc

clear toPlot plotPos ghfsList P1 P2 fres1 fres2 yDat1
addpath 'D:\Data_analysis\export_figure'
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

% Defaults for this blog post
width = 6;     % Width in inches
height = 0.5;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(file)
    allFiles{fCntr}=file(fCntr).name;
end

% toPlot={'NC-MFR-ABS-1','NC-MFR-ABS-2','NC-MFR-ABS-3'};
% toPlot={'NC-MFR-ABS-2','NC-MFR-ABS-1'};
toPlot={'NC-MFR-ABS-1','NC-MFR-ABS-2','NC-MFR-ABS-4'};
% toPlot={'NC-CMP-3','NC-CMP-2','NC-CMP-4'};
ghfsList={'GHFS1_raw','GHFS2_raw'};
titleList={'GHFS1','GHFS2'};

for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end

h=figure;
h.Position=([500 200 500+width*100, 200+height*100]);
% Set the defaults for saving/printing to a file
set(h,'defaultFigureInvertHardcopy','on'); % This is the default anyway
set(h,'defaultFigurePaperUnits','inches'); % This is the default anyway
defsize = get(gcf, 'PaperSize');
left = (defsize(1)- width)/2;
bottom = (defsize(2)- height)/2;
defsize = [left, bottom, width, height];
set(h, 'defaultFigurePaperPosition', defsize);

 legF=[];
 ctr=0;
 ctr2=0;
for n=1:numel(ghfsList)
    
    legF=[];
    % Set the default Size for display
    
    s(2*n-1)=subplot(1,numel(ghfsList),n);
%     t=title(titleList{n});
%     t.Position=[0.5 0.901 0.5]
    
%%
%     s1=subplot(numel(plotPos),1,n);
    hold on
    grid on
    box on
    period=timing(plotPos(n)).fast;
    freq=1/period;
    
    for m=1:numel(plotPos)
        ctr=ctr+1;

        yDat1{ctr}=GHFS(plotPos(m)).(ghfsList{n}).var;

        [P1{ctr},fres1]=pspectrum(yDat1{ctr},10000,'FrequencyResolution',0.05);
        

%         P1=(P1-min(P1))./max(P1-min(P1));
        lwrFactor=10;
%         P1=P1./(lwrFactor^(m-1)); %bring down  
        f1(ctr)=plot(fres1,pow2db(abs(P1{ctr})),'-');
%         f1(ctr)=plot(fres,P1,'-');
        f1(ctr).LineWidth=1;
        f1(ctr).Color=colorstring{m};
        legF=[legF,f1(ctr)];
        
%         [pks{ctr}, locs{ctr}] = findpeaks(P1,fres,'MinPeakDistance',30,'MinPeakHeight',0.000015/lwrFactor^(m-1),'MinPeakProminence',0.00001/lwrFactor^(m-1));    
%         f2=plot(locs{ctr},pks{ctr},'.');
%         f2.Color=colorstring{m};
%         f2.Color=f2.Color./1.15;
%         f2.MarkerSize=12;
%         s(n).YScale='log';
        ylabel('Power spectrum [dB]','FontWeight','bold')
        ylim([-110 0])

    end
    
    xlim([0,20])
    if n==2
        leg=legend(legF,{'Condensation','Mixing','NC gas plug'},'FontWeight','bold');
        title('GHFS2 420 mm')
    else
        leg=legend(legF,{'Condensation','Condensation','NC gas plug'},'FontWeight','bold');
        title('GHFS1 220 mm')
    end
    xlabel('Frequency [Hz]','FontWeight','bold')
   
    
end

leg.Location='northeast';
% leg.Orientation='horizontal';
s(1).Position=[0.16 0.1581 0.3347 0.7559];
% s(1).Position=[0.0800    0.6    0.5347    0.3412];
% s(2).Position=[0.6703    0.6    0.2347    0.3412];
% s(3).Position=[0.0800    0.19    0.5347    0.3412];
% s(4).Position=[0.6703    0.19    0.2347    0.3412];
% s(3).XLabel.String='f [Hz]';
% s(3).XLabel.FontWeight='bold';
% s(4).XLabel.String='f [Hz]';
% s(4).XLabel.FontWeight='bold';

%% save

print('D:\Data_analysis\HFvsNCgasHIGH_FREQ2_LOWEND','-dmeta')
% [pks,frqs] = findpeaks(abs(P1),fres);
disp('Fertig')

