clc

clear toPlot plotPos yDat1 yDat2
addpath 'D:\Data_analysis\export_figure'
colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

% Defaults for this blog post
width = 6;     % Width in inches
height = 9;    % Height in inches
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
% toPlot={'NC-MFR-ABS-N2-6_1'}; 
% toPlot={'NC-MFR-ABS-2_5_4'}; %use with GHFS3
% toPlot={'NC-MFR-ABS-He-4_4'}; %use with GHFS4
% toPlot={'NC-CMP-3_v1'}; %use with GHFS3
% 'NC-CMP-3_v1'
toPlot={'NC-CMP-5_v2real','NC-MFR-ABS-2_5_4','NC-MFR-ABS-He-4_4'};
sensors={'GHFS2','GHFS3','GHFS3'};
for fCntr2=1:numel(toPlot)
    plotPos(fCntr2)=find(strcmp(allFiles,toPlot{fCntr2}));
end
xSt=500;
xEnd=700;
% plotPos=[3,5,9,13,19];
% plotPos=[19];
h=figure;
for n=1:numel(plotPos)
    
    % Set the default Size for display
    % defpos = get(0,'defaultFigurePosition');
    h.Position=([500 50 500+width*100, height*100]);

    % Set the defaults for saving/printing to a file
    set(h,'defaultFigureInvertHardcopy','on'); % This is the default anyway
    set(h,'defaultFigurePaperUnits','inches'); % This is the default anyway
    defsize = get(gcf, 'PaperSize');
    left = (defsize(1)- width)/2;
    bottom = (defsize(2)- height)/2;
    defsize = [left, bottom, width, height];
    set(h, 'defaultFigurePaperPosition', defsize);
%%
    subplot(numel(plotPos),1,n)
    hold on
    grid on
%     xDat=distributions(plotPos(n)).MP_forward_temp.position_x;
    filtR=1;
    period(n)=timing(plotPos(n)).fast;
    freq(n)=1/period(n);
    yDat1{n}=GHFS(plotPos(n)).(sensors{n}).var(1 : end-1*freq(n));
    yErr1(n)=mean(GHFS(plotPos(n)).(sensors{n}).error);
%     xDat=0.001:0.001:numel(yDat)/1000;
%     f1=plot(xDat,yDat,'-');
    lowpassF=0.1;
    Fnorm=lowpassF/(1000/2);
    [num,den]=butter(4,Fnorm);
%     yDat=filtfilt(num,den,yDat);
%     yDat=medfilt1(yDat,filtR,'truncate' );
%     yDat=yDat(50000:end-500000);
% yDat=(yDat-min(yDat))./max(yDat-min(yDat));
    xDat=1/freq(n):1/freq(n):numel(yDat1{n})/freq(n);
%     yStd=MP(plotPos(n)).MP4.std;
%     yMin=yDat-yStd;
%     yMax=yDat+yStd;
    
    f1=plot(xDat,yDat1{n},'-');
    f2=plot(xDat,smooth(yDat1{n},500),'-');
    f1.LineWidth=1;
    f2.LineWidth=2.5;
    f2.Color=colorstring{1};
    f2.Color=f2.Color./1.5;

    ylabel(['Heat flux [W/m^2]'],'FontWeight','bold')
    box on
    %%
%     subplot(2,1,2)
    hold on
    grid on
%     yDat=GHFS(plotPos(n)).wall_dT_GHFS1.var;
    currVar=['wall_heatflux_',sensors{n}];
    yDat2{n}=GHFS(plotPos(n)).(currVar).var(1 :end-1);
    yErr2(n)=mean(GHFS(plotPos(n)).(currVar).error);
%     yDat=GHFS(plotPos(n)).GHFS1_temp.var;
%     yDat=filtfilt(num,den,yDat);
%     yDat=medfilt1(yDat,1,'truncate' );
%     yDat=yDat(50000:end-500000);

%     yDat=(yDat-min(yDat))./max(yDat-min(yDat));
    xDat=1:1:numel(yDat2{n});
%     yStd=MP(plotPos(n)).MP2.std;
%     yMin=smooth(yDat-yStd,smth);
%     yMax=smooth(yDat+yStd,smth);
    f3=plot(xDat,yDat2{n},'-');
    f4=plot(xDat,smooth(yDat2{n},5),'-');
    f3.LineWidth=1;
    f3.MarkerSize=15;
    f3.Color=colorstring{2};
    f4.LineWidth=2.5;
    f4.Color=colorstring{2};
    f4.Color=f4.Color./1.5;
    

%     ylabel(['Temperature [C]'],'FontWeight','bold')
%     x2=[xDat', fliplr(xDat')];
%     inBetween=[yMin',fliplr(yMax')];
%     fl=fill(x2,inBetween,'g');
%     fl.FaceAlpha=0.4;
%     fl.FaceColor=colorstring{2};
%     fl.EdgeAlpha=0.3;
%     fl.EdgeColor=colorstring{2};

    grid on
    box on
    if n==1 || n==2
         ylim([1.0e+04    2.1*1.0e+04])
    else
%         ylim([-1000    10000])
    end
    xlim([xSt xEnd])
%     xlim([-10,0])
    p2pGHFS=round(max(yDat1{n})-min(yDat1{n}));
    p2pdT=round(max(yDat2{n})-min(yDat2{n}));
    leg=legend([f1,f3],{['GHFS, peak-to-peak: ',num2str(p2pGHFS)],['dT, peak-to-peak: ',num2str(p2pdT)]});
    leg.Location='northoutside';
    leg.FontWeight='bold';
    leg.Orientation='horizontal';
    

end
xlabel('Time [s]','FontWeight','bold') 
% legend([f1,f3],{'GHFS','Double thermcouple'})
%% save
print('D:\Data_analysis\HF_dTvsGHFS','-dmeta')

disp('Fertig')
%%
for m=1:numel(yErr1)
    errRelGHFS(m)=yErr1(m)/mean(yDat1{m});
    errReldT(m)=yErr2(m)/mean(yDat2{m});
end

%% xcorr
smth=5;
exp=2;
range=200;
xSt=500;
xEnd=xSt+range;
%get
y1=yDat1{exp}(xSt*freq(exp):xEnd*freq(exp));
%smooth
% y1=smooth(y1,smth*freq(exp));
%normalize
% y1=detrend(y1,'constant');
y1=(y1-min(y1))./max(y1-min(y1));
y2=yDat2{exp}(xSt:xEnd);
% y2=smooth(y2,smth);
% y2=detrend(y2,'constant');
y2=(y2-min(y2))./max(y2-min(y2));

xDat1=period(exp):period(exp):numel(y1)*period(exp);
xDat2=1:1:numel(y2);
        
%         y = resample(x,p,q) 
%         resamples the input sequence, x, at p/q times the original sample rate. 
%         If x is a matrix, then resample treats each column of x as an independent 
%         channel. resample applies an antialiasing FIR lowpass filter to x 
%         and compensates for the delay introduced by the filter.
    y=resample(y1,numel(xDat2),numel(xDat1));
    y(1)=[];
    y(end+1)=y(end);
    y(1)=[];
    y(end+1)=y(end);

        finddelay(y,y2)
        
h=calcXCorr(y,y2,1,1)

