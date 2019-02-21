function writeCFD(steamFlow,steamTemp,clntFlow,clntTemp,clntPress,clntVel,initPress,initTemp,initN2,initHe,fileName)

%     % read template into cell
%     fid=fopen('./fluent/2DMacroTemplateHe','r');
%     i = 1;
%     tline = fgetl(fid);
%     A{i} = tline;
%     while ischar(tline)
%         i = i+1;
%         tline = fgetl(fid);
%         A{i} = tline;
%     end
%     fclose(fid); 
    
    % open file for master macro and write header
    fidM=fopen('./fluent/inputs/master_journal','w');
%     fprintf(fidM,'sync-chdir D:\\CFD2018 \n');
%     fprintf(fidM,'\n');
%     fprintf(fidM,'(cx-macro-define\n');
%     fprintf(fidM,'''( (master . "\n');
    
    %for every file
    for n=1:numel(steamFlow)
%         temp=A;
        temp=[];
        
        %prepare variables
        stTemp=num2str(steamTemp(n)+273.15);
        stFlow=num2str(steamFlow(n)/(pi*0.01^2));
        ctTemp=num2str(clntTemp(n)+273.15);
        ctFlow=num2str(clntFlow(n)/(0.00432189686));
        ctPress=num2str((clntPress(n)-initPress(n))*100000);
        ctVel=num2str(clntVel(n));
        inPress=num2str(initPress(n)*100000);
        inTemp=num2str(initTemp(n)+273.15);
        inH2O=num2str(1-initN2(n)-initHe(n));
        inN2=num2str(initN2(n));
        inHe=num2str(initHe(n));
        
        
        %header
        temp{1}='(cx-macro-define';
        temp{end+1}=' ''( (runmacr . " ';
        if initHe(n)==0
            temp{end+1}='/file/read-case \"D:\CFD2018\caseTemplates/template30k.cas\" ';
        else
            temp{end+1}='/file/read-case \"D:\CFD2018\caseTemplates/template30kHe.cas\" ';
        end
        
        %efine boundary conditions
        if initHe(n)==0
            temp{end+1}=['/define/boundary-conditions/mass-flow-inlet steam_inlet yes no yes no ',stFlow,' yes yes \"udf\" \"inlet_temp::libudf_2D\" no 0 yes no 1 no 0 no no yes 5 10 no no 1 yes '];  %divide by 2pi because axisymmetric
%         temp{4}=['/define/boundary-conditions/mass-flow-inlet steam_inlet y y n ',stFlow,' n ',inTemp,' n 0 y n 1 n 0 n n y 5 10 n n 1 n 0 y '];  %divide by 2pi because axisymmetric
        else
            temp{end+1}=['/define/boundary-conditions/mass-flow-inlet steam_inlet yes no yes no ',stFlow,' yes yes \"udf\" \"inlet_temp::libudf_2D\" no 0 yes no 1 no 0 no no yes 5 10 no no 1 no 0 yes ']; 
        end
        temp{end+1}=['/define/boundary-conditions/mass-flow-inlet coolant_inlet y n y n ',ctFlow,' n ',ctTemp,' n 0 y n 1 n 0 n n y 5 10 y'];

        %clear any preexisting monitors
        temp{end+1}='/solve/monitors/surface/clear-monitors';
        temp{end+1}='/solve/monitors/volume/clear-monitors';
        
        %define monitors
        temp{end+1}=['/solve/monitors/surface/set-monitor udm4 \"Integral\" udm-4 steam_tube () n n yes \"D:\CFD2018/results\',fileName{n},'/udm4.out\" 1 y flow-time'];
        temp{end+1}=['/solve/monitors/surface/set-monitor inletTemp \"Area-Weighted Average\" temperature steam_inlet () n n yes \"D:\CFD2018/results\',fileName{n},'/inletTemp.out\" 1 y flow-time'];
        temp{end+1}=['/solve/monitors/surface/set-monitor inletMFlow \"Mass Flow Rate\" steam_inlet () n n yes \"D:\CFD2018/results\',fileName{n},'/inletMFlow.out\" 1 y flow-time'];
        temp{end+1}=['/solve/monitors/volume/set-monitor press \"Volume-Average\" absolute-pressure steam () n n yes \"D:\CFD2018/results\',fileName{n},'/press.out\" 1 y flow-time'];
        temp{end+1}=['/solve/monitors/volume/set-monitor h2o \"Volume-Average\" h2o steam () n n yes \"D:\CFD2018/results\',fileName{n},'/h2o.out\" 1 y flow-time'];
        temp{end+1}=['/solve/monitors/volume/set-monitor h2omass \"Mass Integral\" h2o steam () n n yes \"D:\CFD2018/results\',fileName{n},'/h2omass.out\" 1 y flow-time'];
        temp{end+1}=['/solve/monitors/volume/set-monitor n2mass \"Mass Integral\" n2 steam () n n yes \"D:\CFD2018/results\',fileName{n},'/n2mass.out\" 1 y flow-time'];
        if ~initHe(n)==0
            temp{end+1}=['/solve/monitors/volume/set-monitor heMass \"Mass Integral\" he steam () n n yes \"D:\CFD2018/results\',fileName{n},'/heMass.out\" 1 y flow-time'];
        end
        %define input parameters for UDF
        temp{end+1}=['(rp-var-define ''cttemp ',ctTemp,' ''real #f)'];
        temp{end+1}=['(rp-var-define ''steamtemp ',stTemp,' ''real #f)'];
        temp{end+1}='(rp-var-define ''wallcond/underrelax 0.2 ''real #f)';
        temp{end+1}='(rp-var-define ''wallcond/wall_mf_ur 0.2 ''real #f)';
        
        %initialize solution
        temp{end+1}='/solve/initialize/initialize-flow';
        temp{end+1}='/solve/initialize/compute-defaults/mass-flow-inlet steam_inlet';
        temp{end+1}='/solve/initialize/initialize-flow ok';
        
        %patch domain after initialization
        %steam
        temp{end+1}=['/solve/patch steam () species-0 ',inH2O];
        if ~initHe(n)==0
            temp{end+1}=['/solve/patch steam () species-1 ',inN2];
        end
        temp{end+1}='/solve/patch steam () x-velocity n 0';
        temp{end+1}=['/solve/patch steam tube insulation_cone coolant () temperature ', inTemp];
        temp{end+1}=['/define/operating-conditions/operating-pressure ',inPress];
        %coolant
        temp{end+1}=['/solve/patch coolant () pressure ',ctPress];
        temp{end+1}=['/solve/patch coolant () x-velocity n ',ctVel];         
        
        %define storage and autosave
        temp{end+1}=['/file/write-case \"D:\CFD2018/results\',fileName{n},'/',fileName{n},'.cas\" ok'];
        temp{end+1}=['/file/auto-save/root-name \"D:\CFD2018/results\',fileName{n},'/',fileName{n},'.cas\"'];
        
        %solve
        temp{end+1}='/solve/set/p-v-coupling 22';
        temp{end+1}='/solve/set/time-step 0.001';
        temp{end+1}='/solve/dual-time-iterate 100 40 n yes ';
        temp{end+1}='/solve/set/time-step 0.01';
        temp{end+1}='/solve/dual-time-iterate 10000 40 y y';
%         temp{end+1}='/solve/set/time-step 0.1';
%         temp{end+1}='/solve/dual-time-iterate 10000 30 y y';
%         
        %save final datafile
        temp{end+1}=['/file/write-data \"D:\CFD2018/results\',fileName{n},'/',fileName{n},'_FINAL.dat\" '];
        
        %finish macro
        temp{end+1}='")';
        temp{end+1}='))';
        
        
        
        %define plotting of data
        temp{end+1}='(cx-macro-define';
        temp{end+1}=' ''( (plotmacr . " ';
        
        temp{end+1}=['/plot/plot n \"D:\CFD2018/results\',fileName{n},'/h2o_centerline.txt\" y y 1 0 n n h2o symmetry ()']; 
        temp{end+1}=['/plot/plot n \"D:\CFD2018/results\',fileName{n},'/temp_centerline.txt\" y y 1 0 n n temperature symmetry ()'];
        temp{end+1}=['/plot/plot n \"D:\CFD2018/results\',fileName{n},'/temp_wall.txt\" y y 1 0 n n temperature steam_tube ()']; 
        temp{end+1}=['/plot/plot n \"D:\CFD2018/results\',fileName{n},'/h2o_wall.txt\" y y 1 0 n n h2o steam_tube ()']; 
        temp{end+1}=['/plot/plot n \"D:\CFD2018/results\',fileName{n},'/udm4_wall.txt\" y y 1 0 n n udm-4 steam_tube ()'];
        temp{end+1}=['/plot/plot n \"D:\CFD2018/results\',fileName{n},'/N2_wall.txt\" y y 1 0 n n n2 steam_tube ()'];
        temp{end+1}=['/plot/plot n \"D:\CFD2018/results\',fileName{n},'/N2_centerline.txt\" y y 1 0 n n n2 symmetry ()'];
        if ~initHe(n)==0
            temp{end+1}=['/plot/plot n \"D:\CFD2018/results\',fileName{n},'/He_wall.txt\" y y 1 0 n n he steam_tube ()'];
            temp{end+1}=['/plot/plot n \"D:\CFD2018/results\',fileName{n},'/He_centerline.txt\" y y 1 0 n n he symmetry ()'];
        end
        
        %finish macro
        temp{end+1}='")';
        temp{end+1}='))';
        
        %store in Fluent macro file
        fid=fopen(['./fluent/inputs/',fileName{n},'_macro'],'w');
        for i = 1:numel(temp)
%             if temp{i+1} == -1
%                 fprintf(fid,'%s', temp{i});
%                 break
%             else
                fprintf(fid,'%s\n', temp{i});
%             end
        end
        fclose(fid);
        
        %update master macro
        fprintf(fidM,'/file/read-macro D:/CFD2018/inputs/%s\n',[fileName{n},'_macro']);
        fprintf(fidM,'/file/execute-macro runmacr\n');
        fprintf(fidM,'/file/execute-macro plotmacr\n');
    end
    
    %finish and close master journal
%     fprintf(fidM,'")\n');
%     fprintf(fidM,'))');
    fclose(fidM);
    
end
