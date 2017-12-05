function writeCFD(steamFlow,steamTemp,clntFlow,clntTemp,clntPress,clntVel,initPress,initN2,initHe,fileName)

    % read template into cell
    fid=fopen('D:\Data\Data_analysis\fluent\2DMacroTemplate','r');
    i = 1;
    tline = fgetl(fid);
    A{i} = tline;
    while ischar(tline)
        i = i+1;
        tline = fgetl(fid);
        A{i} = tline;
    end
    fclose(fid); 
    
    %for every file
    for n=1:numel(steamFlow)
        temp=A;
        
        %prepare variables
        stTemp=num2str(steamTemp(n)+273.15);
        stFlow=num2str(steamFlow(n)/(2*pi));
        ctTemp=num2str(clntTemp(n)+273.15);
        ctFlow=num2str(clntFlow(n)/(2*pi*3600));
        ctPress=num2str((clntPress(n)-initPress(n))*10000);
        ctVel=num2str(clntVel(n));
        inPress=num2str(initPress(n)*10000);
        inN2=num2str(1-initN2(n));
        
        %write steam parameters
        temp{4}=['/define/boundary-conditions/mass-flow-inlet steam_inlet y y n ',stFlow,' n ',stTemp,' n 0 y n 1 n 0 n n y 5 10 n n 1 y'];  %divide by 2pi because axisymmetric
        temp{13}=['/solve/patch steam () species-0 ',inN2];
        temp{14}=['/define/operating-conditions/operating-pressure ',inPress];
        %write coolant paramteres
        temp{5}=['/define/boundary-conditions/mass-flow-inlet coolant_inlet y y n ',ctFlow,' n ',ctTemp,' n 0 y n 1 n 0 n n y 5 10 y'];
        temp{15}=['/solve/patch coolant () pressure ',ctPress];
        temp{16}=['/solve/patch coolant () x-velocity n ',ctVel];   
        
        %define monitors
        temp{8}=['/solve/monitors/surface/set-monitor udm4 \"Integral\" udm-4 steam_tube () n n yes \"/home/janasz_f/',fileName{n},'/udm4.out\" 1 n flow-time'];
        temp{9}=['/solve/monitors/volume/set-monitor press \"Volume-Average\" absolute-pressure coolant () n n yes \"/home/janasz_f/',fileName{n},'/press.out\" 1 n flow-time'];
        
        %define storage and autosave
        temp{17}=['/file/write-case \"/home/janasz_f/',fileName{n},'/',fileName{n},'.cas\" ok'];
        temp{18}=['/file/auto-save/root-name \"',fileName{n},'\"'];
        
        %store in Fluent settings file
        fid=fopen(['D:\Data\CFD\Inputs\',fileName{n},'_macro'],'w');
        for i = 1:numel(temp)
            if temp{i+1} == -1
                fprintf(fid,'%s', temp{i});
                break
            else
                fprintf(fid,'%s\n', temp{i});
            end
        end
        fclose(fid);
        
    end
    
end
