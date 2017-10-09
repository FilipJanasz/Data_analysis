function [frontArrivalMiddle,frontArrivalDevMax,frontArrivalStart,frontArrivalEnd,frontData]=mixingFrontDynamics(y_dat,x_dat,av_window,currSens,pathPrint,file_list)
 
%     %calc cutoff - process only nonrestricted positions
%     x_dat(x_dat<position_lim)=[];
%     y_dat=y_dat(end-numel(x_dat)+1:end);
    
    %convert av_window in % of the available positions to data points
    av_window=ceil(av_window/100*numel(x_dat));
    
    calc_dat=y_dat;
    calc_dat_norm=calc_dat./median(calc_dat);
  
    %preallocate
    st_dev_local=zeros(1,numel(calc_dat)-1);
    
    %calculate standart deviation for every point, based on neighbourhood
    %described by av_window
    
    for i=2:numel(calc_dat)
        set_st=floor(i-av_window/2);
        set_end=floor(i+av_window/2);

        %if there's not enough points on left or right of the point
        if set_st<1
            set_st=1;
        end
        if set_end>numel(calc_dat_norm)
            set_end=length(calc_dat_norm);
        end

        %define the interval based on start and end conditions
        sub_var=calc_dat_norm(set_st:set_end);
        
        %calculate st_dev for this interval and store it
        st_dev_local(i-1)=std(sub_var);
    end
    
    
    y_dat_norm=(y_dat-min(y_dat))/max(y_dat-min(y_dat)); %normalize to 0:1 values 
    high=find(y_dat_norm>0.96);
    low=find(y_dat_norm<0.1 );
    layer_start=high(end);
    tempLow=low(low>layer_start);
    layer_end=tempLow(1);
    
    frontArrivalStart=layer_start;
    frontArrivalEnd=layer_end;
    
    frontData=y_dat(frontArrivalStart:frontArrivalEnd);
    frontDataNorm=y_dat_norm(frontArrivalStart:frontArrivalEnd);
    
    y_MOD=abs(y_dat_norm-0.5);
    frontArrivalMiddle=find(y_MOD==min(y_MOD));
    if numel(frontArrivalMiddle)>1
       frontArrivalMiddle=frontArrivalMiddle(1);
    end

    st_devFront=st_dev_local(frontArrivalStart:frontArrivalEnd);
    frontArrivalDevMax=find(st_devFront==max(st_devFront))+frontArrivalStart;
    
    fx=figure('visible','off');
    plot(st_dev_local)
    hold on
    yyaxis right
    plot(x_dat,y_dat_norm)
    plot([frontArrivalMiddle frontArrivalMiddle], ylim,'.-r')
    plot([frontArrivalDevMax frontArrivalDevMax], ylim,'.-g')
    plot([frontArrivalStart frontArrivalStart], ylim,'--k')
    plot([frontArrivalEnd frontArrivalEnd], ylim,'--b')
    pathPrintName=[pathPrint,'\',file_list,'_',currSens];
    saveas(fx,pathPrintName,'png')
    close(fx)
    
%     
%     %find highest st dev, which coincides with the middle of mixing front
%     frontArrivalDevMax=find(st_dev_local==max(st_dev_local));
%     
%     %find middle of mixing point
%     y_dat_norm=(y_dat-min(y_dat))/max(y_dat-min(y_dat)); %normalize to 0:1 values   
%     y_MOD=abs(y_dat_norm-0.5); %we want to look for 0.5, so substract, abs() and look for minimum
%     frontArrivalMiddle=find(y_MOD==min(y_MOD));
%     figure
%     plot(y_MOD)
%     if numel(frontArrivalMiddle)>1
%         devDist=abs(frontArrivalMiddle-frontArrivalDevMax);
%         frontArrivalMiddle=min(devDist==min(devDist));
%     end
% 
% 
%     %normalize st dev for easy of analysis
%     st_dev_local_norm=(st_dev_local-min(st_dev_local))/max(st_dev_local-min(st_dev_local));
%     
%     %find where st dev norm rises to 0.1 or more, LEFT side of the front middle
%     stDevLeft=st_dev_local_norm(1:frontArrivalDevMax)-0.1;  % substractdesired value (0.1) and find all negative values, and then negative value closest to the mixing front center
%     frontArrivalStart=find(stDevLeft<0);
%     if isempty(frontArrivalStart)
%         frontArrivalStart=find(stDevLeft==min(stDevLeft));
%     end
%     frontArrivalStart=frontArrivalStart(end);  %take last value, as it's closest to front center
% 
%        
%     
%     %find where st dev norm rises to 0.1 or more, RIGHT side of the front middle
%     stDevRight=st_dev_local_norm(frontArrivalDevMax:end)-0.1; % substractdesired value (0.1) and find all negative values, and then negative value closest to the mixing front center
%     frontArrivalEnd=find(stDevRight<0);
%      if isempty(frontArrivalEnd)
%         frontArrivalEnd=find(stDevRight==min(stDevRight));
%     end
%     frontArrivalEnd=frontArrivalEnd(1)+frontArrivalDevMax-1; %take first value, as it's closest to fronte center, add the left distance that was removed by dividing data in two vectors
%     
%     
%     %get only front shape
%     frontData=y_dat(frontArrivalStart:frontArrivalEnd);    
    
%     figure
%     plot(st_dev_local_norm)
%     hold on
%     yyaxis right
%     plot(x_dat,y_dat_norm)
%     plot([frontArrivalMiddle frontArrivalMiddle], ylim,'.-r')
%     plot([frontArrivalStart frontArrivalStart], ylim,'--k')
%     plot([frontArrivalEnd frontArrivalEnd], ylim,'--b')
    

    
end
