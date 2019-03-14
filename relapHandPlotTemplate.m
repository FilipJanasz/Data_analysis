clc
expNo=5;
clear tempY tempX yRelap xRelap yExp xExp varYRelap varXexp yLab xLab

colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

%% var input
%mflow vs press
n=1;
varXRelap{n}='RELAP_ext(relCnt).steamMflowEvap';
varYRelap{n}='RELAP_ext(relCnt).p_avg';

varXexp{n}='steam(n).mflow';
varYexp{n}='steam(n).press';
    
xLab{n}='Condensation mass flow [kg/s]';
yLab{n}='Pressure [bar]';

%mflow vs walldT
n=2;
% varXRelap{n}='RELAP_ext(relCnt).wall_dT';
varXRelap{n}='RELAP_secondary(relCnt).tempf';
varYRelap{n}='RELAP_ext(relCnt).steamMflowEvap';
% varYRelap{n}='RELAP_ext(relCnt).evapHeat' ;%p_avg';

% varXexp{n}='facility(n).wall_dT';
varXexp{n}='coolant(n).temp';
varYexp{n}='steam(n).mflow';
% varYexp{n}='steam(n).power';
  
% xLab{n}='Wall dT [^{\circ}C]';
xLab{n}='Coolant temperature [^{\circ}C]';
yLab{n}='Condensation mass flow [kg/s]';

%coolnat vel vs mflow
n=3;
varXRelap{n}='RELAP_secondary(relCnt).velf';
varYRelap{n}='RELAP_ext(relCnt).steamMflowEvap';

varXexp{n}='coolant(n).velocity';
varYexp{n}='steam(n).mflow';
    
xLab{n}='Coolant velocity [m/s]';
yLab{n}='Condensation mass flow [kg/s]';
    
%% plotting loop below 
for plotCtr=1:numel(varYRelap)
    
    clear tempY tempX varYRelapCurr varXRelapCurr varXexpCurr varYexpCurr yLabCurr xLabCurr

    
  
    %% var processing
    %mod vars
    varXRelapCurr=[varXRelap{plotCtr},'.value'];
    varYRelapCurr=[varYRelap{plotCtr},'.value'];
    varXexpCurr=[varXexp{plotCtr},'.value'];
    varYexpCurr=[varYexp{plotCtr},'.value'];
    
    xLabCurr=xLab{plotCtr};
    yLabCurr=yLab{plotCtr};

    %% get Relap data
    relAmnt=numel(RELAP_ext)/expNo;
    for n=1:relAmnt

        for m=1:expNo
            relCnt=(m-1)*relAmnt+n;
            tempX(m)=eval(varXRelapCurr);
            tempY(m)=eval(varYRelapCurr);
            if contains(varXRelapCurr,'temp') || contains(varXRelapCurr,'htvat')
                tempX(m)=tempX(m)-273.15;
%             elseif contains(varXRelapCurr,'.p')
%                 tempX(m)=tempX(m)/10000; %pa to bar
            end
            if contains(varYRelapCurr,'temp') || contains(varYRelapCurr,'htvat')
                tempY(m)=tempY(m)-273.15;
%             elseif contains(varYRelapCurr,'.p')
%                 tempY(m)=tempY(m)/10000; %pa to bar
            end
        end
        xRelap(n,:)=tempX;    
        yRelap(n,:)=tempY; 

    end

    %% get experimental data
    for n=1:expNo
        xExp(n)=eval(varXexpCurr);
        yExp(n)=eval(varYexpCurr);
    end


    %% plotting
    % Defaults for this blog post
    width = 4;     % Width in inches
    height = 3;    % Height in inches

    f=figure;
    f.Position=([500 50 500+width*100, height*100]);
    hold on
    markerList={'o','d','^','<','>'};
%     currVarName=file(expSwitch).name;
    legendString=[];
    for n=1:relAmnt+1
        if n<relAmnt+1
            [xRelapSorted,sortKey]=sort(xRelap(n,:));
            yRelapSorted=yRelap(n,:);
            yRelapSorted=yRelapSorted(sortKey); %sorts the same way as X'es
            h(n)=plot(xRelapSorted,yRelapSorted); 
            legendString{n}=RELAP_primary(n).file;
            findDash=strfind(legendString{n},'_');
            legendString{n}=legendString{n}(findDash(end)+1:end);
            switch legendString{n}
                case 'ST'
                    legendString{n}='Nodalization 1';
                case 'STNONC'
                    legendString{n}='Nodalization 1, no NC';
                case 'an'
                    legendString{n}='Nodalization 2';
                case 'anNONC'
                    legendString{n}='Nodalization 2, no NC';
            end
        else
            [xExpSorted,sortKey]=sort(xExp);
            yExpSorted=yExp;
            yExpSorted=yExpSorted(sortKey); %sorts the same way as X'es
            h(n)=plot(xExpSorted,yExpSorted);
            legendString{n}='Experiment';
        end
        h(n).Marker=markerList{n};
        h(n).Color=colorstring{n};
    %     h(n).LineWidth=1.5;
    %     h(n).LineStyle='none';
        h(n).MarkerFaceColor=colorstring{n};
    end


    xlabel(xLabCurr);
    ylabel(yLabCurr);
    f.Children.XLabel.FontWeight='bold';
    f.Children.YLabel.FontWeight='bold';
    legH=legend(legendString);
    legH.Interpreter='none';
    legH.Location='eastoutside';
%     titH=title(currExpName);

    %% save

    currVarSimpX=varXRelapCurr;
    dotPos=strfind(currVarSimpX,'.');
    currVarSimpX=currVarSimpX(dotPos(1)+1:dotPos(2)-1);
    currVarSimpY=varYRelapCurr;
    dotPos=strfind(currVarSimpY,'.');
    currVarSimpY=currVarSimpY(dotPos(1)+1:dotPos(2)-1);
    
    fileName=['D:\Relap5\tempPlots\',file(2).name(1:end-2),'_',currVarSimpX,'_vs_',currVarSimpY];
    print(f,fileName,'-dmeta')
    disp('Fertig')
end