function [file,data]=MP_processing_fun(file_list,directory)
    file_msg=['Processing file: ',file_list];
    disp(file_msg)
    
                     
%% Data loading
    %file data of possible mat file that was already processed
    fileName=[directory,'\',file_list,'.tdms'];
    matFileName=[directory,'\',file_list,'.mat'];
    processed_data_file_name=[directory,'\','processed_data_',file_list];
    
    disp('1. Loading data')
    try 
        load([processed_data_file_name,'.mat']);
        disp('Processed data found, loading without recalculation')
    catch
        
        disp('Proccessed data not available, recalculating')
        %if the file was already converted before, load .mat file rather than waste
        %time on another conversion
        if exist(matFileName,'file')
            disp('File already converted from .tdms, loading .mat file')
            load(matFileName)
        else
            ignoreGroupNames=1;
            simpleConvertTDMS(fileName,ignoreGroupNames);
            load(matFileName)
        end
        %find out what variables are stored in the file and create a
        %list for further processing
        temp_slow_vars_list=whos ('-file',matFileName);
        vars_list={temp_slow_vars_list.name};

        %remove redundant fields
        vars_list=unique(vars_list);

        %remove non-data positions from the list
        removal_list={'Process_Data','Root','Untitled','XX','fileFolder','fileName','Time','Timestamp'};
        removal_amount=numel(removal_list);
        for removal_cnt=1:removal_amount
            I = ismember(vars_list, removal_list{removal_cnt});
            vars_list(I) = [];
        end

        %% Organize data
      
        channel_amount=length(vars_list);
        temp.(vars_list{1})(1)=0; %initialize data variable for the sake of warning messages
        for i=1:channel_amount
            command=strcat('temp.',vars_list{i},'=',vars_list{i},'.Data;');
            eval(command)
%                 data.(list{i})=(list{i}).Data;  
        end      
        
        %% Data processing - time varying values
        disp('2. Calculating process variables from raw data')
        
        % file parameters
        file.name=file_list;
        file.directory=directory;
        
        %transfer data to final struct
        for variable=vars_list
            curr_var=variable{1};
            data.(curr_var).var=temp.(curr_var);
        end
        
        %% calibration data for thermocouples
        try
            
             %get TC calibration
            if ~exist([file.directory,'\TCcalib.mat'])
                [num,den]=xlsread([file.directory,'\TCcalib.xlsx']);
                for n=1:numel(den)
                    calibData.(den{n})=num(:,n);
                end
                save([file.directory,'\TCcalib.mat'],'calibData')
                disp('New calibration data .m created')
            else
                load([file.directory,'\TCcalib.mat'],'calibData');
            end

       % apply calibration
        
            allFields=fields(calibData);
            for calibN=2:numel(allFields)  %2 because 1st is the reference temperature
                currParam=allFields{calibN};
                currMean=mean(data.(currParam).var); %temps are mostly constant, so work on averages
                currOffset=interp1(calibData.Temp,calibData.(currParam),currMean);  %calc offset based on table in folder
                %apply offset
                data.(currParam).var=data.(currParam).var+currOffset;
            end
        catch
            disp('No calibraton table in folder')    
        end
       
        
        %% calculate fluxes XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        tubeInArea=pi*0.021*0.11;
        
        %MP zero offset and properties
        selector=str2double(directory(end-1));
        MP_elOffset=[-7.48,-1.68,-16.59,-39.2].*10^-8;
        data.MP_raw.var=data.MP.var;
        data.MP.var=data.MP.var-(MP_elOffset(selector));
        data.MP.var=-data.MP.var;
        MParea=[84.78,85.54,82.34,84.31]./1000000; % m^2
        currArea=MParea(selector);
        
        
        %% from power        
        try
            data.Joule_power2.var=data.Current.var.*data.Voltage.var;      % W
            data.Resistance.var=0.0004*75*(data.TH.var-20)+75;  %  0.0004 is TCR 75 is resistance at 20 deg  http://www.resistorguide.com/temperature-coefficient-of-resistance/ 
            data.Joule_power.var=data.Voltage.var.^2./data.Resistance.var;
            data.hfx_Joule_power.var=round(data.Joule_power.var./tubeInArea);     % W/m2
            data.MP_sensitivity_Joule_power.var=data.MP.var./(currArea.*data.hfx_Joule_power.var); %  V/W  (84/1000000 sensor area in m^2)
        catch
            disp('No current/voltage data available')
        end
        
        
        %% from dT
        currTc=steel_316L_thermcond(data.MP_TC.var);      % W/mK
%         wall_htc=2*currTc/(0.021*log(0.03/0.021));          % W/m2K
        
        %based on every tube
        tipDist=[1.2075,0.9399,1.0669,0.8628]./1000;  %values measured by Lucas under a microscope
        termDist=[2.2874,2.5142,2.4587,2.5646]./1000;
        T2Wpos=0.021+2*tipDist(selector);
        T3Wpos=0.021+2*(tipDist(selector)+termDist(selector));
        wall_htc=2*currTc/(T2Wpos*log(T3Wpos/T2Wpos));
        
        % calculate with heat transfer coefficient
        data.wall_dT.var=abs(data.T3W.var-data.T2W.var);    % K
        data.hfx_dT.var=data.wall_dT.var.*wall_htc;         % K*W/m2K = W/m2
        data.MP_sensitivity_dT.var=data.MP.var./(currArea.*data.hfx_dT.var);  % V/W
        
        % calculate with thermal conductivity
        data.wall_gradT.var=data.wall_dT.var./(termDist(selector));    % K/m
        data.hfx_gradT.var=data.wall_gradT.var.*currTc;     % K/m * W/mK = W/m2
        data.MP_sensitivity_gradT.var=data.MP.var./(currArea.*data.hfx_gradT.var);  % V/W
        
        
        %% radiation
        e_st=0.85;  %emissivity steel
        e_cu=0.78;  %emissivity cooper
        stefBoltz=5.670367*10^(-8);
        radArea=pi*0.014*0.11;  % pi d h
        
%         data.rad_power.var=emissivity*stefan_boltzman_constant.*((data.T1F.var+273.15).^4-(data.MP_TC.var+273.15).^4).*radiating_area; % W
        T1=data.T1F.var+273.15;
        T2=data.T2W.var+273.15;
        
%         T1=data.TH.var+273.15;
%         T2=data.OiltempPT100.var+273.15;

        data.rad_power1.var=radArea.*stefBoltz.*(T1.^4-T2.^4) ./ (1/e_cu+(radArea/tubeInArea)*(1/e_st-1)); % W       
%         data.rad_power2.var=radArea.*stefBoltz.*(T1.^4-T2.^4) ./ (1/e_cu+1/e_st-1); % W
        data.rad_power2.var=radArea.*stefBoltz.*(T1.^4-T2.^4); % W
%         reqDT=data.hfx_dT.var.*tubeInArea./(radArea.*stefBoltz./ (1/e_cu+(radArea/tubeInArea)*(1/e_st-1)))+T2.^4
        data.hfx_rad.var=data.rad_power1.var./tubeInArea;       % W/m2
        data.hfx_rad2.var=data.rad_power2.var./tubeInArea;     % W/m2
        
        data.MP_sensitivity_rad.var=data.MP.var./(currArea.*data.hfx_rad.var);  % V/W
        data.MP_sensitivity_rad2.var=data.MP.var./(currArea.*data.hfx_rad2.var);  % V/W
        
 
        %% calculate averages
        processed_vars_list=fields(data);
        processed_vars_list=processed_vars_list';
        
        for proc_variable=processed_vars_list
            curr_var=proc_variable{1};
            data.(curr_var).value=mean(data.(curr_var).var);            % add mean values to each struct
            data.(curr_var).error=0.005.*data.(curr_var).value;         % temporary - add error
            data.(curr_var).unit='dupa';                                % temporary - add unit
        end
        
    
        %% Sort variables and save
        disp('3. Sorting and storing data in .mat files')
        
        %sorting
        data=orderfields(data);
        file=orderfields(file);

        %saving
        save(processed_data_file_name,'file','data');

    end
disp('Processing finished, ready for a new file')
disp('*****************************************')

end