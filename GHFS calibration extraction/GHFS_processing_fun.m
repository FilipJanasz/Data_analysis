function [file,data]=GHFS_processing_fun(file_list,directory)
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
        
        %calculate fluxes
        %from power
        tube_inner_area=pi*0.021/2*0.12;
        
        try
            data.Joule_power.var=data.Current.var.*data.Voltage.var;      % W
            data.hfx_Joule_power.var=round(data.Joule_power.var./tube_inner_area);     % W/m2
            data.GHFS_sensitivity_Joule_power.var=data.GHFS.var./((84/1000000).*data.hfx_Joule_power.var); %  V/W  (84/1000000 sensor area in m^2)
        catch
            disp('No current/voltage data available')
        end
        
        %radiation
        emissivity=0.78;
        stefan_boltzman_constant=5.6703*10^(-8);
        radiating_area=0.00527788;
        
        data.rad_power.var=emissivity*stefan_boltzman_constant.*((data.T1F.var+273.15).^4-(data.T2W.var+273.15).^4).*radiating_area; % W
        data.hfx_rad.var=data.rad_power.var./tube_inner_area;       % W/m2
        data.GHFS_sensitivity_rad.var=data.GHFS.var./((84/1000000).*data.hfx_rad.var);  % V/W
        
        
        %from dT
        wall_htc=2*15/(0.021*log(0.03/0.021));
        
        data.wall_dT.var=abs(data.T3W.var-data.T2W.var);         % W
        data.hfx_dT.var=data.wall_dT.var.*wall_htc;         % W/m2
        data.GHFS_sensitivity_dT.var=data.GHFS.var./((84/1000000).*data.hfx_dT.var);  % V/W
        
        
        %calculate means
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