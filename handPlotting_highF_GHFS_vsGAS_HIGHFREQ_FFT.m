clc

clear toPlot plotPos
addpath 'D:\Data_analysis\export_figure'
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

% Defaults for this blog post
width = 6;     % Width in inches
height = 6;    % Height in inches
alw = 1;    % AxesLineWidth
fsz = 11;      % Fontsize
% all files
for fCntr=1:numel(file)
    allFiles{fCntr}=file(fCntr).name;
end

% toPlot={'NC-MFR-ABS-1','NC-MFR-ABS-2','NC-MFR-ABS-3'};
% toPlot={'NC-MFR-ABS-2','NC-MFR-ABS-1'};
toPlot={'NC-MFR-ABS-3','NC-MFR-ABS-2','NC-MFR-ABS-1'};
ghfsList={'GHFS1_raw','GHFS2_raw'};

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
for n=1:numel(plotPos)
    
    
    % Set the default Size for display

    s(n)=subplot(numel(plotPos),1,n);
  
%%
%     s1=subplot(numel(plotPos),1,n);
    hold on
    grid on
    box on
    period=timing(plotPos(n)).fast;
    freq=1/period;
    
    for m=1:numel(ghfsList)
        ctr=ctr+1;
%         if m==2
%             yyaxis right
%             ylim([5*10^-6./lwrFactor*(m-1),0.0005])
%             s(n).YColor=[0.8500 0.3250 0.0980];
%         else
%             yyaxis left
%             ylim([5*10^-7,0.005])
%         end
        yDat1=GHFS(plotPos(n)).(ghfsList{m}).var;
        yDat1=detrend(yDat1,'constant');
        [fres,P1]=calcFFT(yDat1,freq);
        lwrFactor=10;
        P1=P1./(lwrFactor^(m-1)); %bring down  
        f1=plot(fres,P1,'-');
        f1.LineWidth=1;
        f1.Color=colorstring{m};
        legF=[legF,f1];
        
        [pks{ctr}, locs{ctr}] = findpeaks(P1,fres,'MinPeakDistance',30,'MinPeakHeight',0.000015/lwrFactor^(m-1),'MinPeakProminence',0.00001/lwrFactor^(m-1));    
        f2=plot(locs{ctr},pks{ctr},'.');
        f2.Color=colorstring{m};
        f2.Color=f2.Color./1.25;
        f2.MarkerSize=12;
        s(n).YScale='log';
        ylabel('P1(f)','FontWeight','bold')
        ylim([5*10^-7,0.005])
    end
    
    xlim([10^-2,5000])
    if n==1
        temp=s(n).Position;
        leg=legend(legF,{'GHFS1   420mm','GHFS2   620mm'},'FontWeight','bold');
        
    end
end
xlabel('f [Hz]','FontWeight','bold') 
% leg=legend(legF,{'He','Mix','N_2'},'FontWeight','bold');
% leg=legend(legF,{'He','Mix','N_2'},'FontWeight','bold');
% leg=legend('N_2','Mix','He');
leg.Location='northoutside';
s(1).Position=temp;
leg.Orientation='horizontal';
%% save

print('D:\Data_analysis\HFvsNCgasHIGH_FREQ1','-dmeta')
% [pks,frqs] = findpeaks(abs(P1),fres);
disp('Fertig')

