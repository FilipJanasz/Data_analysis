clc
% get data


% paramToGet={'GHFS_TC','hfx_Joule_power','hfx_dT','hfx_dT2','hfx_gradT','hfx_gradT2','hfx_rad','hfx_rad2'};
% paramToGet={'GHFS_TC','GHFS_sensitivity_Joule_power','GHFS_sensitivity_dT','GHFS_sensitivity_gradT','GHFS_sensitivity_rad','GHFS_sensitivity_rad2'};
paramToGet={'GHFS_TC','GHFS_sensitivity_dT','GHFS_sensitivity_Joule_power'}; %,'GHFS_sensitivity_gradT','GHFS_sensitivity_rad','GHFS_sensitivity_rad2'};

for m=1:numel(paramToGet)
    currParam=paramToGet{m};
    for n=1:numel(GHFS_file)
        plotDat.(currParam)(n)=GHFS_data(n).(currParam).value;
    end
end

figure
hold on
grid on
for m=2:numel(paramToGet)
    currParam=paramToGet{m};
    
    %do some fitting
    x=plotDat.GHFS_TC;
    % y=plotDat.GHFS_sensitivity_Joule_power;
    y=plotDat.(currParam);

    %remove nans
    y(isnan(x))=[];
    x(isnan(x))=[];
    x(isnan(y))=[];
    y(isnan(y))=[];
    y(x<40)=[];
    x(x<40)=[];

    %sort according to temp
    temp=[x',y'];
    temp=sortrows(temp,1);
    x=temp(:,1);
    y=temp(:,2);

% plot confidence 
    if strcmp(currParam,'GHFS_sensitivity_dT')
        %first order
        p1=polyfit(x,y,1);
        fitDat1=p1(1).*x +p1(2);
        %second order
        p2=polyfit(x,y,2);
        fitDat2=p2(1).*x.^2+p2(2).*x+p2(3);
        %third order
        p3=polyfit(x,y,3);
        fitDat3=p3(1).*x.^3+p3(2).*x.^2+p3(3).*x+p3(4);
         %third order
        p4=polyfit(x,y,4);
        fitDat4=p4(1).*x.^4+p4(2).*x.^3+p4(3).*x.^2+p4(4).*x+p4(5);
        
      
        
        y2=fitDat2;
        % confidence band
        e=0.1.*y2;
        lo = y2 - e;
        hi = y2 + e;

        hp = patch([x; x(end:-1:1); x(1)], [lo; hi(end:-1:1); lo(1)],'r');
        hold on;
        
        set(hp, 'facecolor', [ 0.5843    0.8157    0.9882], 'edgecolor', 'none');
        alpha(0.5)
        f2=plot(x,y2,'.--');
        f2.LineWidth=1.5;
        f2.MarkerSize=15;
        
        
    end
    f1=plot(x,y,'.-');
    f1.LineWidth=1.5;
    f1.MarkerSize=15;
end
titleString=GHFS_file(1).directory(end-5:end-1);
% title([titleString,' SENSITIVITES'])
ylabel('Sensitivity [mV/W]')
xlabel(sprintf('Temperature [%cC]', char(176)))
% legend(paramToGet(2:end),'Location','northwest','Interpreter','none')
l1=legend({'10% interval','2^{nd} order polynomial','based on \DeltaT','based on heating power'},'Location','northwest');
%  set(ll, 'interpreter', 'tex')
print('D:\Data_analysis\figureOutputs\senitivityGHFS','-dmeta')

% %do some fitting
% x=plotDat.GHFS_TC;
% % y=plotDat.GHFS_sensitivity_Joule_power;
% y=plotDat.GHFS_sensitivity_dT;
% 
% %remove nans
% y(isnan(x))=[];
% x(isnan(x))=[];
% y(x<40)=[];
% x(x<40)=[];
% 
% %sort according to temp
% temp=[x',y'];
% temp=sortrows(temp,1);
% x=temp(:,1);
% y=temp(:,2);

% %first order
% p1=polyfit(x,y,1);
% fitDat1=p1(1).*x +p1(2);
% %second order
% p2=polyfit(x,y,2);
% fitDat2=p2(1).*x.^2+p2(2).*x+p2(3);
% %third order
% p3=polyfit(x,y,3);
% fitDat3=p3(1).*x.^3+p3(2).*x.^2+p3(3).*x+p3(4);

% figure
% hold on
% plot(x,y,'x')
% plot(x,fitDat1)
% plot(x,fitDat2)
% plot(x,fitDat3)
% 
% legend({'data','poly 1','poly 2','poly 3'},'Location','eastoutside');

%plot
% figure
% hold on
% grid on
% for m=2:numel(paramToGet)
%     currParam=paramToGet{m};
%     plot(plotDat.GHFS_TC,plotDat.(currParam),'.')
%     if m==2
%         plot(plotDat.GHFS_TC,plotDat.(currParam),'o')
%     end
% end
% titleString=GHFS_file(1).directory(end-5:end-1);
% title(titleString)
% legend(paramToGet(1:end),'Location','eastoutside','Interpreter','none')