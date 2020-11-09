clc

% expNo=5;
expNo=numel(file);
for expSwitch=1:expNo
    
    colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};
    clear tempY tempX yRelap xRelap yExp xExp varYRelap varXexp yLab xLab
    %% var input
    varYRelap{1}='RELAP_secondary(relCnt).tempf';
    varYRelap{2}='RELAP_primary(relCnt).tempg';
    varYRelap{3}='RELAP_primary(relCnt).htvat';
    varYRelap{4}='RELAP_primary(relCnt).quala';
    unitLength=80; %height of single Relap5 volume
    
    offset(1)=500;%-620 for primary +500 for secondary
    offset(2)=-620;
    offset(3)=-620;
    offset(4)=-620;

    varXexp{1}='distributions(n).coolant_temp_0deg';
    varXexp{2}='distributions(n).centerline_temp';
    varXexp{3}='distributions(n).wall_inner';
    varXexp{4}='distributions(n).centerline_molefr_NC';

    yLab{1}='Coolant temperature [^{\circ}C]';
    yLab{2}='Centerline temperature [^{\circ}C]';
    yLab{3}='Wall temperature [^{\circ}C]';
    yLab{4}='NC mole fraction [1]';
    xLab='Tube elevation [mm]';

    %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    %% var processing
    for plotCtr=1:numel(varYRelap)
        %mod vars
        varYRelapCurr=[varYRelap{plotCtr},'.var'];
        %get position for Relap

        % var2=[var2,'.value'];
        varXexpCurr=[varXexp{plotCtr},'.position_y'];
        varYexpCurr=[varXexp{plotCtr},'.value.cal'];

        offsetCurr=offset(plotCtr);

        xLabCurr=xLab;
        yLabCurr=yLab{plotCtr};
        %% get Relap data
        relAmnt=floor(numel(RELAP_ext)/expNo);
        for n=1:relAmnt

            for m=1:expNo
                relCnt=(m-1)*relAmnt+n;
                tempY{m}=eval(varYRelapCurr);
                %fix units
                if contains(varYRelapCurr,'temp') || contains(varYRelapCurr,'htvat')
                    tempY{m}=tempY{m}-273.15;
                end
                tempX{m}=(unitLength:unitLength:numel(tempY{m})*unitLength)+offsetCurr;
            end
        %     xRelap(n,:)=tempX;    
            yRelap(n,:)=tempY; 

            xRelap(n,:)=tempX;
        end

        %% get experimental data
        for n=1:expNo
            xExp{n}=eval(varXexpCurr);
            yExp{n}=eval(varYexpCurr);
        end


        %% plotting
        % Defaults for this blog post
        width = 3;     % Width in inches
        height = 3;    % Height in inches

        f=figure;
        grid on
        box on
        f.Position=([500 50 500+width*100, height*100]);
        hold on
        markerList={'o','d','^','<','>'};
        legendString=[];
        currExpName=file(expSwitch).name;

        for n=1:relAmnt+1
            if n<relAmnt+1
                h(n)=plot(xRelap{n,expSwitch},yRelap{n,expSwitch}); 
                legendString{n}=RELAP_primary(n).file;
                dashLoc=strfind(legendString{n},'_');
%                 legendString{n}=strrep(legendString{n},currExpName,'');
%                 legendString{n}(1)=[];
                legendString{n}=legendString{n}(dashLoc+1:end);
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
                h(n)=plot(xExp{expSwitch},yExp{expSwitch});
                legendString{n}='Experiment';
            end  

            h(n).Marker=markerList{n};
            h(n).Color=colorstring{n};
%             h(n).LineWidth=1.5;
%             h(n).LineStyle='none';
            h(n).MarkerFaceColor=colorstring{n};

        end
        
        limX=xlim;
        xlim([0 limX(2)]);
        xlabel(xLabCurr);
        ylabel(yLabCurr);
        f.Children.XLabel.FontWeight='bold';
        f.Children.YLabel.FontWeight='bold';
        legH=legend(legendString);
        legH.Interpreter='none';
        legH.Location='eastoutside';
        titH=title(currExpName,'Interpreter','none');
        %% save
        currVarSimpl=strrep(varYRelapCurr,'RELAP_primary(relCnt).','');
        dotPos=strfind(currVarSimpl,'.');
        currVarSimpl(dotPos:end)=[];
        fileName=['D:\Relap5\tempPlots\',currExpName,'_',currVarSimpl];
        print(f,fileName,'-dmeta')
        disp('Fertig')
        close(f)
    end
end