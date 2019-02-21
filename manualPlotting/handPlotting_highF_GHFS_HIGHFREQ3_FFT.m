clc

clear toPlot plotPos yDat1 s P1 P2 fres1 fres2
addpath 'D:\Data_analysis\export_figure'
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

% Defaults for this blog post
width = 6;     % Width in inches
height = 4;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(file)
    allFiles{fCntr}=file(fCntr).name;
end

% toPlot={'NC-MFR-ABS-1','NC-MFR-ABS-2','NC-MFR-ABS-3'};
% toPlot={'NC-MFR-ABS-2'};
toPlot={'NC-MFR-ABS-1','NC-MFR-ABS-2','NC-MFR-ABS-4'};
% toPlot={'NC-MFR-ABS-1_4-LF'};
ghfsList={'GHFS1_raw','GHFS2_raw'};
% ghfsList={'GHFS1_raw'};


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
for n=1:numel(plotPos)
    
    
    % Set the default Size for display

    
  
%%
%     s(n)=subplot(numel(plotPos),1,n);
   
    
    s(2*n-1)=subplot(numel(plotPos),2,2*n-1);
    for m=1:numel(ghfsList)
        
         hold on
        grid on
        box on
        if ~(contains(ghfsList{m},'Temp') || contains(ghfsList{m},'Pos'))
            period=timing(plotPos(n)).fast;
        else
            period=timing(plotPos(n)).slow;
        end
        freq=1/period;
        ctr=ctr+1;
%         if m==2
%             yyaxis right
%             ylim([5*10^-6./lwrFactor*(m-1),0.0005])
%             s(n).YColor=[0.8500 0.3250 0.0980];
%         else
%             yyaxis left
%             ylim([5*10^-7,0.005])
%         end

        if contains(ghfsList{m},'MP') || contains(ghfsList{m},'Temp') || contains(ghfsList{m},'Pos')
            yDat1{ctr}=MP(plotPos(n)).(ghfsList{m}).var;
        else
            yDat1{ctr}=GHFS(plotPos(n)).(ghfsList{m}).var;
        end

        yDat1{ctr}=detrend(yDat1{ctr},'constant');

        [P1{ctr},fres1{ctr}]=pspectrum(yDat1{ctr},10000,'FrequencyResolution',10);
        [P2{ctr},fres2{ctr}]=pspectrum(yDat1{ctr},10000,'FrequencyResolution',1);
        f1(ctr)=plot(fres1{ctr},pow2db(abs(P1{ctr})),'-');
        f1(ctr).LineWidth=1;
        f1(ctr).Color=colorstring{m};
        legF=[legF,f1(ctr)];

    end

    ylabel('Power spectrum [dB]','FontWeight','bold')
    xlim([0,5000])
    ylim([-85 -40])
    
    if n==1
        leg=legend(legF,{'GHFS1   420 mm','GHFS2   620 mm'},'FontWeight','bold');
        
    end
    
    s(2*n)=subplot(numel(plotPos),2,2*n);
    hold on
    grid on
    box on
    
    for m=1:numel(ghfsList)
        ctr2=ctr2+1;
        f2(ctr2)=plot(fres2{ctr2},pow2db(abs(P2{ctr2})),'-');
        f2(ctr2).LineWidth=1;
        f2(ctr2).Color=colorstring{m};

        xlim([0 500]);
        ylim([-90 -40])
    end

end
leg.Location='northoutside';
leg.Orientation='horizontal';

s(1).Position=[0.0800    0.7093    0.5347    0.2157];
s(2).Position=[0.6703    0.7093    0.2347    0.2157];
s(3).Position=[0.0800    0.4    0.5347    0.2157];
s(4).Position=[0.6703    0.4     0.2347    0.2157];
s(5).Position=[0.0800    0.1    0.5347    0.2157];
s(6).Position=[0.6703    0.1    0.2347    0.2157];
s(5).XLabel.String='f [Hz]';
s(5).XLabel.FontWeight='bold';
s(6).XLabel.String='f [Hz]';
s(6).XLabel.FontWeight='bold';
R=corrcoef(P1{1},P1{2})
R=corrcoef(P1{3},P1{4})
R=corrcoef(P1{5},P1{6})
print('D:\Data_analysis\HFvsNCgasHIGH_FREQ3','-dmeta')
% [pks,frqs] = findpeaks(abs(P1{ctr}),fres);
disp('Fertig')

% h=figure;
% % h.Position=[315         437        1118         284];
% for n=1:numel(yDat1)
%     h=figure;
% 
% %     s(n)=subplot(1,numel(yDat1{ctr}),n);
% %     spectrogram(yDat1{ctr},kaiser(128,18),120,256,1E4,'xaxis');
% %     s(n)
% %     s(n).Colorbar.Visible='off'
%     pspectrum(yDat1{n},10000);
% %     h.Children(2).YScale='log';
% %     pspectrum(yDat2{n},'power')
% end
% colormap jet
% a=colorbar
% a.Position=[0.9293 0.1197 0.0127 0.8063]
