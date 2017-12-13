function writeCFDHe(steamFlow,steamTemp,clntFlow,clntTemp,clntPress,clntVel,initPress,initN2,initHe,fileName)

    % read template into cell
    fid=fopen('./fluent/2DMacroTemplateHe','r');
    i = 1;
    tline = fgetl(fid);
    A{i} = tline;
    while ischar(tline)
        i = i+1;
        tline = fgetl(fid);
        A{i} = tline;
    end
    fclose(fid); 
    
    % open file for master macro and write header
    fidM=fopen(['./fluent/inputs/master_macro'],'w');
    fprintf(fidM,'(cx-macro-define\n');
    fprintf(fidM,'''( (master . "\n');
    
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
        inH2O=num2str(1-initN2(n)-initHe(n));
        inN2=num2str(initN2(n));
        
        %write steam parameters
        temp{4}=['/define/boundary-conditions/mass-flow-inlet steam_inlet y y n ',stFlow,' n ',stTemp,' n 0 y n 1 n 0 n n y 5 10 n n 1 n 0 y '];  %divide by 2pi because axisymmetric
        temp{16}=['/solve/patch steam () species-0 ',inH2O];
        temp{17}=['/solve/patch steam () species-1 ',inN2];
        temp{18}=['/define/operating-conditions/operating-pressure ',inPress];
        %write coolant paramteres
        temp{5}=['/define/boundary-conditions/mass-flow-inlet coolant_inlet y y n ',ctFlow,' n ',ctTemp,' n 0 y n 1 n 0 n n y 5 10 y'];
        temp{19}=['/solve/patch coolant () pressure ',ctPress];
        temp{20}=['/solve/patch coolant () x-velocity n ',ctVel];   
        
        %define input parameters for UDF
        temp{11}=['(rp-var-define ''cttemp ',ctTemp,' ''real #f)'];
        temp{12}=['(rp-var-define ''steamtemp ',stTemp,' ''real #f)'];
        
        %define monitors
        temp{8}=['/solve/monitors/surface/set-monitor udm4 \"Integral\" udm-4 steam_tube () n n yes \"/home/janasz_f/',fileName{n},'/udm4.out\" 1 n flow-time'];
        temp{9}=['/solve/monitors/volume/set-monitor press \"Volume-Average\" absolute-pressure steam () n n yes \"/home/janasz_f/',fileName{n},'/press.out\" 1 n flow-time'];
        temp{10}=['/solve/monitors/volume/set-monitor h2o \"Volume-Average\" h2o steam () n n yes \"/home/janasz_f/',fileName{n},'/h2o.out\" 1 n flow-time'];
        
        %define storage and autosave
        temp{21}=['/file/write-case \"/home/janasz_f/',fileName{n},'/',fileName{n},'.cas\" ok'];
        temp{22}=['/file/auto-save/root-name \"/home/janasz_f/',fileName{n},'/',fileName{n},'.cas\"'];
               
        %define plotting of data
        temp{26}=['/plot/plot n \"/home/janasz_f/',fileName{n},'/h2o_centerline.txt\" yes n n h2o y 1 0 symmetry ()']; 
        temp{27}=['/plot/plot n \"/home/janasz_f/',fileName{n},'/temp_centerline.txt\" yes n n temperature y 1 0 symmetry ()'];
        temp{28}=['/plot/plot n \"/home/janasz_f/',fileName{n},'/temp_wall.txt\" yes n n temperature y 1 0 steam_tube ()']; 
        temp{29}=['/plot/plot n \"/home/janasz_f/',fileName{n},'/h2o_wall.txt\" y n n h2o y 1 0 steam_tube ()']; 
        temp{30}=['/plot/plot n \"/home/janasz_f/',fileName{n},'/udm4_wall.txt\" y n n udm-4 y 1 0 steam_tube ()'];
        temp{31}=['/plot/plot n \"/home/janasz_f/',fileName{n},'/N2_wall.txt\" y n n n2 y 1 0 steam_tube ()'];
        temp{32}=['/plot/plot n \"/home/janasz_f/',fileName{n},'/N2_centerline.txt\" y n n n2 y 1 0 symmetry ()'];
        
        %store in Fluent settings file
        fid=fopen(['./fluent/inputs/',fileName{n},'_macro'],'w');
        for i = 1:numel(temp)
            if temp{i+1} == -1
                fprintf(fid,'%s', temp{i});
                break
            else
                fprintf(fid,'%s\n', temp{i});
            end
        end
        fclose(fid);
        
        %update master macro
        fprintf(fidM,'/file/read-macro \\"/home/janasz_f/macros/%s\\"\n',[fileName{n},'_macro']);
        fprintf(fidM,'/file/execute-macro runmacr\n');
    end
    
    %finish and close master macro
    fprintf(fidM,'")\n');
    fprintf(fidM,'))');
    fclose(fidM);
    
end
