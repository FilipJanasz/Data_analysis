clc

clear toPlot plotPos pks locs
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
% toPlot={'NC-MFR-ABS-2','NC-MFR-ABS-1'};
% toPlot={'NC-MFR-ABS-3','NC-MFR-ABS-2','NC-MFR-ABS-1'};
toPlot={'NC-MFR-ABS-1_4-LF'};
% ghfsList={'GHFS1_raw','GHFS2_raw'};
ghfsList={'MP4','MP2'};


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

    
  
%%
%     s(n)=subplot(numel(plotPos),1,n);
   
    
    
    for m=1:numel(ghfsList)
        s(m)=subplot(numel(ghfsList),1,m);
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
            yDat1=MP(plotPos(n)).(ghfsList{m}).var;
        else
            yDat1=GHFS(plotPos(n)).(ghfsList{m}).var;
        end
        
        yDat1=detrend(yDat1,'constant');
        [fres,P1]=calcFFT(yDat1,freq);
        lwrFactor=10;
        P1=P1./(lwrFactor^(m-1)); %bring down  
        f1=plot(fres,P1,'-');
        f1.LineWidth=1.5;
        f1.Color=colorstring{m};
        legF=[legF,f1];
        
        try
            [pks{ctr}, locs{ctr}] = findpeaks(P1,fres,'MinPeakDistance',freq/33,'MinPeakHeight',0.00008/lwrFactor^(m-1),'MinPeakProminence',0.00001/lwrFactor^(m-1));    
            pks{ctr}(locs{ctr}>50)=[];
            locs{ctr}(locs{ctr}>50)=[];
            f2=plot(locs{ctr},pks{ctr},'.');
            f2.Color='k';
            f2.Color=f2.Color./1.25;
            f2.MarkerSize=16;
        catch
        end
        s(m).YScale='log';
        s(m).XScale='log';
        ylabel('P1(f)','FontWeight','bold')
        xlim([10^-3,50])
        temp=ylim;
        ylim([temp(1)*100 temp(2)*2]);
        if m==2
            text(locs{m}./6,pks{m}.*3,['Freq. ',num2str(round(locs{m},5)),' [Hz]'],'FontWeight','bold')
            text(locs{m}./6,pks{m}.*1.5,['Period. ',num2str(round(1./locs{m})),' [s]'],'FontWeight','bold')
        else
            text(locs{m}./6,pks{m}.*1.5,['Freq. ',num2str(round(locs{m},5)),' [Hz]'],'FontWeight','bold')
            text(locs{m}./6,pks{m},['Period. ',num2str(round(1./locs{m})),' [s]'],'FontWeight','bold')
        end
    end
    
%     xlim([10^-2,1])
    
    if n==1
        temp=s(n).Position;
        leg=legend(legF,{'Traversing electrode','Fixed electrode'},'FontWeight','bold');
        
    end
end
xlabel('f [Hz]','FontWeight','bold') 
% leg=legend(legF,{'Traversing electrode','Fixed electrode'},'FontWeight','bold');
% leg=legend(legF,{'He','Mix','N_2'},'FontWeight','bold');
% leg=legend('N_2','Mix','He');
leg.Location='northoutside';
s(1).Position=temp;
leg.Orientation='horizontal';
%% save

print('D:\Data_analysis\MP_Probe_FFT','-dmeta')
% [pks,frqs] = findpeaks(abs(P1),fres);
disp('Fertig')

