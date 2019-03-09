clc
clear varSteam varCl varFacility errSt errCl errFc  minMaxSt minMaxCl minMaxFc
files=numel(steam);

varSteam=fields(steam);
varCl=fields(coolant);
varFacility=fields(facility);
precision=4;

for n=1:numel(varSteam)
    if ~strcmp(varSteam{n},'powerOffset')
        clear temp tempRel
        for m=1:files
            temp(m)=steam(m).(varSteam{n}).error;
            tempVal(m)=steam(m).(varSteam{n}).value;
            tempRel(m)=abs(temp(m)/tempVal(m))*100;
        end
        %filter infinities
        temp(isinf(temp))=[];
        tempRel(isinf(tempRel))=[];
        
        valSt.(varSteam{n})=tempVal;
        errSt.(varSteam{n})=temp;
        errStRel.(varSteam{n})=tempRel;
        minMaxSt{n,1} = (varSteam{n});
        minMaxSt{n,2} = [num2str(min(temp),precision),' - ',num2str(max(temp),precision)];
        minMaxSt{n,3} = [num2str(min(tempRel),precision),' - ',num2str(max(tempRel),precision),'%'];
%         minMaxSt{n,3} = mean(temp);
%         minMaxSt{n,4} = max(temp);
    end
end

for n=1:numel(varCl)
    clear temp tempRel
    for m=1:files
        temp(m)=coolant(m).(varCl{n}).error;
        tempVal(m)=coolant(m).(varCl{n}).value;
        tempRel(m)=abs(temp(m)/tempVal(m))*100;
    end
    %filter infinities
    temp(isinf(temp))=[];
    tempRel(isinf(tempRel))=[];
    
    %filter unrealistic low power
    if strcmp(varCl{n},'power_Offset')
        rem=find(tempVal<200);
        temp(rem)=[];
        tempVal(rem)=[];
        tempRel(rem)=[];
    end   
    valCl.(varCl{n})=tempVal;
    errCl.(varCl{n})=temp;
    errClRel.(varCl{n})=tempRel;
    minMaxCl{n,1} = (varCl{n});
    minMaxCl{n,2} = [num2str(min(temp),precision),' - ',num2str(max(temp),precision)];
    minMaxCl{n,3} = [num2str(min(tempRel),precision),' - ',num2str(max(tempRel),precision),'%'];
%     minMaxCl{n,3} = mean(temp);
%     minMaxCl{n,4} = max(temp);
end

for n=1:numel(varFacility)
    clear temp tempRel
    for m=1:files
        temp(m)=facility(m).(varFacility{n}).error;
        tempVal(m)=facility(m).(varFacility{n}).value;
        tempRel(m)=abs(temp(m)/tempVal(m))*100;
    end
    %filter infinities
    temp(isinf(temp))=[];
    tempRel(isinf(tempRel))=[];
        
    valFc.(varFacility{n})=tempVal;
    errFc.(varFacility{n})=temp;
    errFcRel.(varFacility{n})=tempRel;
    minMaxFc{n,1} = (varFacility{n});
    minMaxFc{n,2} = [num2str(min(temp),precision),' - ',num2str(max(temp),precision)];
    minMaxFc{n,3} = [num2str(min(tempRel),precision),' - ',num2str(max(tempRel),precision),'%'];
%     minMaxFc{n,3} = mean(temp);
%     minMaxFc{n,4} = max(temp);
end