function writeCFD(steamFlow,steamTemp,clntFlow,clntTemp,clntPress,initPress,initN2,initHe)

    % read template into cell
    fid=fopen('D:\Data_analysis\fluent\2DAxiSimTemplate','r');
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
        %write press to patch in coolant zone\
        temp{83}=['(pressure/patch ',num2str((clntPress-initPress)*10000),')'];
        %write init pressure steam
        temp{117}=['(initial-operating-pressure ',num2str(initPress*10000),'.)'];
        %write steam parameters
        temp{324}=['(mass-flow (constant . ',num2str(steamFlow(n)/(2*pi)),') (profile "" ""))'];  %divide by 2pi because axisymmetric
        temp{329}=['(t0 (constant . ',num2str(steamTemp(n)+273.15),') (profile "" ""))'];
        %write coolant paramteres
        temp{367}=['(mass-flow (constant . ',num2str(clntFlow(n)/(2*pi)),') (profile "" ""))'];
        temp{372}=['(t0 (constant . ',num2str(clntTemp(n)+273.15),') (profile "" ""))'];
        
        %store in Fluent settings file
        fid=fopen(['D:\CFD\dupa',num2str(n)],'w');
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
