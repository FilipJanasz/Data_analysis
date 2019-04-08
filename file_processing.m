function [steam, coolant, facility, NC, distributions, file, BC, GHFS, MP,timing]=file_processing(interactive_flag,file_list,directory,st_state_flag,frontDynamics_flag,options)
    file_msg=['Loading file: ',file_list];
    disp(file_msg)
    
    if interactive_flag
        disp('_________________________________________________________________________')
        disp('INTERACTIVE MODE ENGADED')
        disp('_________________________________________________________________________')
    end
        
%% get preffered user otions for file processing
    %options for boundary layer calculation in MP datga
    avg_window=options(1);
    limiting_factor=options(2);
    x_limit=options(3);
    
    %smoothing parameters
    frame_size=options(4);
    smoothing_type=options(5);
    sgolay_order=options(6);
    
    %option for equation of state
    eos_type=options(7);
%% Data loading
    %file data of possible mat file that was already processed
    fileName=[directory,'\',file_list,'.tdms'];
    matFileName=[directory,'\',file_list,'.mat'];
    steady_data_file_name=[directory,'\','steady_data_',file_list];
    UNsteady_data_file_name=[directory,'\','UNsteady_data_',file_list];
    processed_data_file_name=[directory,'\','processed_steady_data_',file_list];
    
    %file data for GHFS data file
    splitdir=strsplit(directory,'DATA');
    directoryFAST=[splitdir{1},'FAST\'];
    fileNameFAST=[directoryFAST,file_list,'-FAST.tdms'];
    matFileNameFAST=[directoryFAST,file_list,'-FAST.mat'];   
    
    %file data for MP temperature / position
    directoryMP=[splitdir{1},'MP\'];
    fileNameMP=[directoryMP,file_list,'-MP.tdms'];
    matFileNameMP=[directoryMP,file_list,'-MP.mat'];   
    
    % if the file was already recalculated from .tdms and steady state was
    % found and mean values were calculated, save time and load it directly
    
    try 
        load([processed_data_file_name,'.mat']);
        disp('Processed data found, loading without recalculation')
    catch
        %if data was not processed, but already steady state was found, try
        %to load it
        try
            if st_state_flag
                load([steady_data_file_name,'.mat']);
                disp('Proccessed data not found but steady state data found, loading without looking for steady state period and recalculating')
                disp('Check if "steady state" checkbox is in the right state')  
            else
                temp_dat=load([UNsteady_data_file_name,'.mat']);
                %below is so the rest of the code works fine
                experimentalData=temp_dat.UNsteady_data;
                disp('Proccessed data not found but UNsteady state data found, loading without looking for steady state period and recalculating')
                disp('Check if "steady state" checkbox is in the right state')
            end
            
            % verify which types of data are available
            if isfield(experimentalData,'GHFS1')
                fast_flag=1;
            else
                fast_flag=0;
            end

            if isfield(experimentalData,'MP_Pos')
                MP_flag=1;
            else
                MP_flag=0;
            end
                
        catch %ME
            % ME.message
            disp('Proccessed data and steady / UNsteady state data not available, looking for steady state, then recalculating')
            disp('Check if "steady state" checkbox is in the right state')
            %if the file was already converted before, load .mat file rather than waste
            %time on another conversion
            if exist(matFileName,'file')
                disp('Slow sensors file already converted from .tdms, loading .mat file')
                load(matFileName)
            else
                ignoreGroupNames=1;
                simpleConvertTDMS(fileName,ignoreGroupNames);
                load(matFileName)
            end
            %find out what variables are stored in the file and create a
            %list for further processing
            temp_slow_vars_list=whos ('-file',matFileName);
            slow_vars_list={temp_slow_vars_list.name};
            
            %trying to load or convert data from fast sensors
            if exist(matFileNameFAST,'file')
                load(matFileNameFAST)
                disp('FAST sensors file already converted from .tdms, loading .mat file')
                fast_flag=1;
            else
                try
                disp('Trying to convert FAST file')
                ignoreGroupNames=1;
                simpleConvertTDMS(fileNameFAST,ignoreGroupNames);
                load(matFileNameFAST)
                fast_flag=1;  % if fast data is found
                catch
                    disp('Cannot find FAST sensors tdms files - processing only slow sensors')
                    fast_flag=0; % if fast data is NOT found
                end
            end
            %find out what variables are stored in the file and create a
            %list for further processing
            if fast_flag
                temp_FAST_vars_list=whos ('-file',matFileNameFAST);
                FAST_vars_list={temp_FAST_vars_list.name};
            end
            
            %trying to load or convert data from movable probe
            if exist(matFileNameMP,'file')
                load(matFileNameMP)
                disp('Movable probe file already converted from .tdms, loading .mat file')
                MP_flag=1;
            else
                try
                disp('Trying to convert movable probe file')
                ignoreGroupNames=1;
                simpleConvertTDMS(fileNameMP,ignoreGroupNames);
                load(matFileNameMP)
                MP_flag=1;  % if fast data is found
                catch
                    disp('Cannot find movable probe tdms files - processing only slow sensors')
                    MP_flag=0; % if fast data is NOT found
                end
            end
            %find out what variables are stored in the file and create a
            %list for further processing
            if MP_flag
                temp_MP_vars_list=whos ('-file',matFileNameMP);
                MP_vars_list={temp_MP_vars_list.name};
            end
            
            %combine obtained lists
            if fast_flag && MP_flag
                all_vars_list=[slow_vars_list,FAST_vars_list,MP_vars_list];
            elseif fast_flag
                all_vars_list=[slow_vars_list,FAST_vars_list];
            elseif MP_flag
                all_vars_list=[slow_vars_list,MP_vars_list];
            else
                all_vars_list=slow_vars_list;
            end
            
            %remove redundant fields
            all_vars_list=unique(all_vars_list);
            
            %remove non-data positions from the list
            removal_list={'Process_Data','Root','Untitled','XX','fileFolder','fileName','Time','Timestamp','ci','convertVer','Data'};
            removal_amount=numel(removal_list);
            for removal_cnt=1:removal_amount
%                 all_vars_list(strcmp(all_vars_list, removal_list{removal_cnt})) = [];
%                 [I, ~] = find(cellfun(@(s) isequal(s, removal_list{removal_cnt}), all_vars_list));
                I = ismember(all_vars_list, removal_list{removal_cnt});
                all_vars_list(I) = [];
            end

            clear fileNameGHFS matFileNameGHFS fileNameMP matFileNameMP temp_slow_vars_list temp_FAST_vars_list temp_MP_vars_list removal_list
            %clear not needed vars
            clear ChanNames ConvertedData SaveConvertedFile filename filenamemat fileName fileFolder ignoreGroupNames matFileName Process_Data Root fileNameGHFS matFileNameGHFS
   
            %% Organize data

            list=all_vars_list;
            %limit list to only variable data - last channel is TW9603 -
            %this may change and needs adjusting!!!
%             disp('****************************************')
%             disp('last channel for processing marked as TW9603 - verify in data files')

            %find indices of last channel
            
%             if fast_flag==1
%                 last_channel=find(strcmp('Timestamp',list));
%             else
%                 last_channel=find(strcmp('Time',list));
%             end
%             last_channel=find(strcmp('TW9603',list));
%             list=list(1:last_channel)
            channel_amount=length(list);
            data.(list{1})(1)=0; %initialize data variable for the sake of warning messages
            for i=1:channel_amount
                command=strcat('data.',list{i},'=',list{i},'.Data;');
                eval(command)
%                 data.(list{i})=(list{i}).Data;  
            end      
             
%             clearvars -except data channel_amount plot_flag file_list directory steady_data_file_name processed_data_file_name
            channel_list=fieldnames(data);
        %% Data processing - calculate power

%             data.power=joule_heating(data.HE9601_I,data.HE9601_U);
            data.power=joule_heating(data.HE9601_I,230);
            
        %% Data processing - figure out acquisition time for scan engines and FPGA
            %FPGA - fast sensors
            if fast_flag
                period_fast=(Timestamp.Data(2)-Timestamp.Data(1))/40000000;  % timestamp is in processor ticks, FPGA runs at 40MHz
%                 Timestamp_fast=(1:1:numel(Timestamp.Data)).*period_fast;
                timing.fast=period_fast;
            else
                timing.fast=0;
            end
            
            if MP_flag
                try
                    period_MP=MP_Time.Data(2)-MP_Time.Data(1);
                catch
                    period_MP=0.1;
                end
                timing.MP=period_MP;
            end
            
            try
                period_slow=Time.Data(2)-Time.Data(1);
            catch
                period_slow=1;
            end
%             Timestamp_slow=(1:1:numel(Time.Data)).*period_slow;
            
            timing.slow=period_slow;
            
        %% Find steady state in the recorded data
            % big av_window - ignore big oscillations, eliminate areas with global
            % trend
            % small av_window - prefer smaller oscillations, ignore global trend
            % find steady state, but only if appropriate checkbox is
            % checked, otherwise, pretend to do it and save all the data in
            % there
            disp('********************************************** ')
            disp('Data processing engaged')
            
            if st_state_flag
                disp('1. Finding steady state')
                % FIRST PARAMETER FOR STEADY STATE SEARCH
                st_state_data=data.PA9601;
                % time=data.Time-data.Time(1);
                use_mov_av=1;
                %lim_factor - how small, in terms of std_dev multiples, can local
                %oscillations be
                lim_factor_st_state=0.5;  % to allow for local oscillations in data (like temperature) increase this

                av_window_st_state=100;  % to relax steady state requirements

                %preallocating
                st_state_start=zeros(1,2);
                st_state_end=zeros(1,2);

                for process_counter=1:2
                    [st_state_start(process_counter),st_state_end(process_counter)]=steady_state(st_state_data,av_window_st_state,lim_factor_st_state,use_mov_av,interactive_flag,file_list,process_counter,directory);
                    st_state_start_relative=sum(st_state_start);
                    st_state_end_relative=st_state_start_relative-st_state_start(process_counter)+st_state_end(process_counter)-1;
                    % remove all the data beside steady state
                    for i=1:channel_amount
                        curr_channel=channel_list{i};
                        %the if clause below differntiates channels recorded at
                        %different acquistion rates
                        %dividing by period makes sure we get the proper
                        %interval of fast data
                        if ~isempty(strfind(curr_channel,'GHFS')) || (~isempty(strfind(curr_channel,'MP')) && isempty(strfind(curr_channel,'MP_')))
%                             eval(['steady_data.',curr_channel,'=data.',curr_channel,'(st_state_start_relative/period_fast:st_state_end_relative/period_fast);']);
                            fast_start=st_state_start_relative/period_fast;
                            fast_end=st_state_end_relative/period_fast;
                            if fast_end>numel(data.(curr_channel))
                                fast_end=numel(data.(curr_channel));
                            end
                            experimentalData.(curr_channel)=data.(curr_channel)(fast_start:fast_end);
                        elseif ~isempty(strfind(curr_channel,'MP_TF')) || ~isempty(strfind(curr_channel,'MP_Pos')) 
%                             eval(['steady_data.',curr_channel,'=data.',curr_channel,'(st_state_start_relative/period_MP:st_state_end_relative/period_MP);']);                          
                            st_state_start_MP=floor(st_state_start_relative/numel(data.TF9602)*numel(data.(curr_channel)));
                            st_state_end_MP=floor(st_state_end_relative/numel(data.TF9602)*numel(data.(curr_channel)));                            
                            experimentalData.(curr_channel)=data.(curr_channel)(st_state_start_MP:st_state_end_MP);
%                             steady_data.(curr_channel)=data.(curr_channel)(st_state_start_relative/period_MP:st_state_end_relative/period_MP);
                        else
%                             eval(['steady_data.',curr_channel,'=data.',curr_channel,'(st_state_start_relative:st_state_end_relative);']);
                            try
                                experimentalData.(curr_channel)=data.(curr_channel)(st_state_start_relative:st_state_end_relative);
                            catch
                                disp(['Problematic channel: ',curr_channel,' - not extracting steady state from it. Check the data'])
                                experimentalData.(curr_channel)=data.(curr_channel);
                            end
                        end
                    end
    %                 st_state_data=steady_data.PA9601;
                    % SECOND PARAMTER FOR STEADY STATE SEARCH
                    st_state_data=experimentalData.TF9503;
                end
                % append power
                experimentalData.power=joule_heating(experimentalData.HE9601_I,230);
                % append timing
                experimentalData.timing=timing;
                %save
                save(steady_data_file_name,'experimentalData');
            else
                disp('1. Not looking for steady state - check box not ticked')
                for i=1:channel_amount
%                      eval(['UNsteady_data.',channel_list{i},'=data.',channel_list{i},';']);
                    UNsteady_data.(channel_list{i})=data.(channel_list{i});
                end
                % append power
                UNsteady_data.power=joule_heating(UNsteady_data.HE9601_I,230);
                % append timing
                UNsteady_data.timing=timing;
                %save
                save(UNsteady_data_file_name,'UNsteady_data');
                
                %below is so the rest of the code works fine
                experimentalData=UNsteady_data;
            end
         

        end
    
        %% Apply any calibration data previosly obtained to the raw data (especially thermoelements)
        disp('2. Applying any avaialble calibration look up tables')
        interp_data=cal_data_interpolate(experimentalData);
        cal_fields=fields(interp_data);
        calibratedData=experimentalData;
        for cal_cntr=1:numel(cal_fields)
            try
            calibratedData.(cal_fields{cal_cntr})=calibratedData.(cal_fields{cal_cntr})+interp_data.(cal_fields{cal_cntr});
            catch
            end
        end
        % assignin('base','cal_steady_data',cal_steady_data);
        %% Initialize structures
        %fast sensors and MP
        data_holder=struct('var',0,'value',0,'error',0,'unit','na');
        MP=struct('MP1',data_holder,'MP2',data_holder,'MP3',data_holder,'MP4',data_holder,'Pos',data_holder,'Temp',data_holder,'Temp_smooth_sgolay',data_holder);
        GHFS=struct('GHFS1',data_holder,'GHFS1_raw',data_holder,'GHFS1_temp',data_holder,'GHFS2',data_holder,'GHFS2_raw',data_holder,'GHFS2_temp',data_holder,'GHFS3',data_holder,'GHFS3_raw',data_holder,'GHFS3_temp',data_holder,'GHFS4',data_holder,'GHFS4_raw',data_holder,'GHFS4_temp',data_holder,'wall_dT_GHFS1',data_holder,'wall_dT_GHFS2',data_holder,'wall_dT_GHFS3',data_holder,'wall_dT_GHFS4',data_holder,'wall_heatflux_GHFS1',data_holder,'wall_heatflux_GHFS2',data_holder,'wall_heatflux_GHFS3',data_holder,'wall_heatflux_GHFS4',data_holder);

        %distributions - really long struct
        value=struct('cal',[],'non_cal',[]);
        data_holder_2=struct('value',value,'position_y',[],'position_x',[]);
        distributions=struct('NC_length_est',data_holder_2,'NC_length_init',data_holder_2,'GHFS_TC',data_holder_2,'MP_backward_molefr_h2o',data_holder_2,'MP_backward_partpress_h2o',data_holder_2,...
            'MP_backward_temp',data_holder_2,'MP_forward_molefr_h2o',data_holder_2,'MP_forward_partpress_h2o',data_holder_2,...
            'MP_forward_temp',data_holder_2,'MP_backward_temp_smooth',data_holder_2,'MP_forward_temp_smooth',data_holder_2,...
            'centerline_molefr_h2o',data_holder_2,'centerline_partpress_h2o',data_holder_2,'coolant_temp_0deg',data_holder_2,...
            'coolant_temp_180deg',data_holder_2,'outer_wall_temp_0deg',data_holder_2,'outer_wall_temp_180deg',data_holder_2,...
            'wall_dT',data_holder_2,'wall_inner',data_holder_2,'wall_outer',data_holder_2);
        
        %% Data processing - time varying values
        disp('3. Calculating process variables from raw data')
        
        % file parameters
        file.name=file_list;
        file.directory=directory;
        
        % timing - it's necessary in case steady state was already found
        timing=experimentalData.timing;
        
        % coolant side
        coolant.vflow.var=calibratedData.FV3801;  
        coolant.velocity.var=coolant.vflow.var/3600/0.008641587;
%         coolant_water_residence_time=1.5/mean(coolant.velocity.var); % how long does it take coolant water to travel the height of the facility
        % facility height (1.5 m) divide by velocity [m/s]
        coolant.temp.var=(calibratedData.TF9502+calibratedData.TF9501)/2;
        coolant.press.var=calibratedData.PA9501;  
        coolant.temp_inlet.var=calibratedData.TF9501;
        coolant.temp_inlet_TC.var=(calibratedData.TF9503+calibratedData.TF9504)/2;
        coolant.temp_outlet.var=calibratedData.TF9502;
        coolant.temp_outlet_TC.var=(calibratedData.TF9507+calibratedData.TF9508)/2;
        coolant.dT.var=coolant.temp_outlet.var-coolant.temp_inlet.var; 
        
        % GHFS var & MP var
        if  fast_flag==1
                        
            GHFS.GHFS1_raw.var=calibratedData.GHFS1;
            GHFS.GHFS2_raw.var=calibratedData.GHFS2;
            GHFS.GHFS3_raw.var=calibratedData.GHFS3;
            GHFS.GHFS4_raw.var=calibratedData.GHFS4;                    
            
            % thermocouple cal_steady_data.TCH2_2W is broken
            % as a workaround, use average between two thermocouples
            if ~isfield(calibratedData,'TCH2_2W')
                calibratedData.TCH2_2W=(calibratedData.TCH1_2W+calibratedData.TCH3_2W)./2;
            end
            if isnan(calibratedData.TCH2_2W)>0
                calibratedData.TCH2_2W=calibratedData.TCH3_2W;
            end
            
            if isnan(calibratedData.TCH1_2W)>0
                calibratedData.TCH1_2W=calibratedData.TCH1_1F;
            end
            GHFS.GHFS1_temp.var=calibratedData.TCH1_2W;
            GHFS.GHFS2_temp.var=calibratedData.TCH2_2W;
%             GHFS.GHFS2_temp.var=(cal_steady_data.TCH1_2W+cal_steady_data.TCH3_2W)./2;  % one TC is broken, this is a work around that might fail
            GHFS.GHFS3_temp.var=calibratedData.TCH3_2W;
            GHFS.GHFS4_temp.var=calibratedData.TCH4_2W;
               
            GHFS.wall_dT_GHFS1.var=calibratedData.TCH1_2W-calibratedData.TCH1_3W;
            GHFS.wall_dT_GHFS2.var=calibratedData.TCH2_2W-(calibratedData.TCH1_3W+calibratedData.TCH3_3W)./2;
%             GHFS.wall_dT_GHFS2.var=(cal_steady_data.TCH1_2W+cal_steady_data.TCH3_2W)./2-cal_steady_data.TCH2_3W; % one TC is broken, this is a work around that might fail
            GHFS.wall_dT_GHFS3.var=calibratedData.TCH3_2W-calibratedData.TCH3_3W;
            GHFS.wall_dT_GHFS4.var=calibratedData.TCH4_2W-calibratedData.TCH4_3W;
            
            % HEATFLUXES
            % from GHFS
            
            %measured by microscope + image recognition
            GHFS.GHFS1.area=84.78; % mm^2
            GHFS.GHFS2.area=85.54; % mm^2
            GHFS.GHFS3.area=82.34; % mm^2
            GHFS.GHFS4.area=84.31; % mm^2
            
            %sensitivities
%             GHFS.GHFS1.sensitivity=0.7e-5;
%             GHFS.GHFS2.sensitivity=0.7e-5;
%             GHFS.GHFS3.sensitivity=1.25e-5;
%             GHFS.GHFS4.sensitivity=0.25e-5;
            GHFS.GHFS1.sensitivity=GHFSsensitivity(mean(GHFS.GHFS1_temp.var),1);
            GHFS.GHFS2.sensitivity=GHFSsensitivity(mean(GHFS.GHFS2_temp.var),2);
            GHFS.GHFS3.sensitivity=GHFSsensitivity(mean(GHFS.GHFS3_temp.var),3);
            GHFS.GHFS4.sensitivity=GHFSsensitivity(mean(GHFS.GHFS4_temp.var),4);
            
            %based on amplifier tests
            GHFS.GHFS1.amplification=10000; % 
            GHFS.GHFS2.amplification=10000; % 
            GHFS.GHFS3.amplification=10000; % 
            GHFS.GHFS4.amplification=10000; % 
            
            %based on GHFS response with no heatflux applied
            GHFS_offset=[-0.032 0.26 0.4 0.21];  
%             GHFS_offset=[0 0 0 0];  
            
            GHFS_string={'GHFS1','GHFS2','GHFS3','GHFS4'}; %contains names of all sensors in facility
            %call function with appropriate data and recalculate heat flux from meaured voltage
            for ghfs_cntr=1:numel(GHFS_string)
                currS=GHFS_string{ghfs_cntr};
                [GHFS.(currS).var,GHFS.([currS,'_offset_raw']).var]=GHFS_heatflux(GHFS.([currS,'_raw']),GHFS.(currS).area,GHFS.(currS).amplification,GHFS_offset(ghfs_cntr),GHFS.(currS).sensitivity);
            end
            
            % from dT (0.003 is distance between thermocouples in mm)
            currTc=steel_316L_thermcond(mean(GHFS.GHFS1_temp.var));
            GHFS_wall_htc=2*currTc/(0.023*log(0.03/0.023));
            GHFS.wall_heatflux_GHFS1.var=GHFS.wall_dT_GHFS1.var.*GHFS_wall_htc;
            GHFS.wall_heatflux_GHFS2.var=GHFS.wall_dT_GHFS2.var.*GHFS_wall_htc;
            GHFS.wall_heatflux_GHFS3.var=GHFS.wall_dT_GHFS3.var.*GHFS_wall_htc;
            GHFS.wall_heatflux_GHFS4.var=GHFS.wall_dT_GHFS4.var.*GHFS_wall_htc;
            
            
            %store calclulated senstivity
            GHFS.GHFS1sensCALC.value=GHFS.GHFS1.sensitivity;
            GHFS.GHFS2sensCALC.value=GHFS.GHFS2.sensitivity;
            GHFS.GHFS3sensCALC.value=GHFS.GHFS3.sensitivity;
            GHFS.GHFS4sensCALC.value=GHFS.GHFS4.sensitivity;
            
            % actual sensitivity
            GHFS.GHFS1sens.value=mean(GHFS.GHFS1_offset_raw.var)/GHFS.GHFS1.amplification/mean(GHFS.wall_heatflux_GHFS1.var.*GHFS.GHFS1.area/1000000);
            GHFS.GHFS2sens.value=mean(GHFS.GHFS2_offset_raw.var)/GHFS.GHFS2.amplification/mean(GHFS.wall_heatflux_GHFS2.var.*GHFS.GHFS2.area/1000000);
            GHFS.GHFS3sens.value=mean(GHFS.GHFS3_offset_raw.var)/GHFS.GHFS3.amplification/mean(GHFS.wall_heatflux_GHFS3.var.*GHFS.GHFS3.area/1000000);
            GHFS.GHFS4sens.value=mean(GHFS.GHFS4_offset_raw.var)/GHFS.GHFS4.amplification/mean(GHFS.wall_heatflux_GHFS4.var.*GHFS.GHFS4.area/1000000);
           
            
            %movable probe
            MP.MP1.var=calibratedData.MP1;
            MP.MP1_filmthick.var=MP1filmthick(MP.MP1.var);
            MP.MP2.var=calibratedData.MP2;
            MP.MP3.var=calibratedData.MP3;
            MP.MP4.var=calibratedData.MP4;
        end
                
        % steam side thermodynamic codnitions - measured
        steam.press.var=calibratedData.PA9601; % [bar]        
        steam.power.var=calibratedData.power;   
        steam.temp.var=calibratedData.TF9602; % [C]  
        steam.heater_temp.var=calibratedData.TW9602; % [C] 
%         [facility.powerOffset.var,facility.powerOffset_TC.var]=fixHeatLosses(steam.power.var,(coolant.temp_outlet.var-coolant.temp_inlet.var));
        [facility.powerOffset.var,facility.powerOffset_TC.var]=fixHeatLosses(coolant.temp.var);

        steam.powerOffset.var=steam.power.var-facility.powerOffset.var';

        % steam side thermocouples - centerline
        try
            steam.TF9603.var=calibratedData.TF9603;
            steam.TF9604.var=calibratedData.TF9604;
            steam.TF9605.var=calibratedData.TF9605;
            steam.TF9606.var=calibratedData.TF9606;
            steam.TF9607.var=calibratedData.TF9606.*(1/3)+calibratedData.TF9608.*(2/3);
            steam.TF9608.var=calibratedData.TF9608;
            steam.TF9609.var=calibratedData.TF9608.*(2/3)+calibratedData.TF9610.*(1/3);
            steam.TF9610.var=calibratedData.TF9610;
            steam.TF9611.var=calibratedData.TF9611;
            steam.TF9612.var=calibratedData.TF9612;
            steam.TF9613.var=calibratedData.TF9613;
            steam.TF9614.var=calibratedData.TF9614;
        catch
            disp('No data for thermocouples TF9603-TF9614 - old recording probably')
        end
         %distributions.centerline_temp.position_y=[220 320 420 520 620 670 720 820 920 1020 1120 1220];
        % steam - coolant interface - facility
        facility.wall_dT.var=steam.temp.var-coolant.temp.var;   
        
%         facility.voltage.var=cal_steady_data.HE9601_U;
        facility.current.var=calibratedData.HE9601_I;
        facility.NCtank_press.var=calibratedData.PA9701;
        facility.NCtank_temp.var=calibratedData.TF9701;
        
        
        %% mean values
        % coolant thermodynamic conditions - measured               
        coolant.vflow.value=mean(calibratedData.FV3801);        
        coolant.temp.value=mean(coolant.temp.var);
        coolant.press.value=mean(calibratedData.PA9501);  
        coolant.temp_inlet.value=mean(calibratedData.TF9501);
        coolant.temp_outlet.value=mean(calibratedData.TF9502);
        coolant.temp_inlet_TC.value=(mean(calibratedData.TF9503)+mean(calibratedData.TF9504))/2;
        coolant.temp_outlet_TC.value=(mean(calibratedData.TF9507)+mean(calibratedData.TF9508))/2;
        
        % coolant properties - calculated (some with IAPWS_IF97)
        coolant.dT.value=coolant.temp_outlet.value-coolant.temp_inlet.value; 
        coolant.dT_TC.value=coolant.temp_outlet_TC.value-coolant.temp_inlet_TC.value; 
        coolant.dens.value=1/IAPWS_IF97('v_pT',coolant.press.value/10,coolant.temp.value+273.15); %take inversion, cause IAPWS calcualtes specific volume (m3/kg)
        coolant.mflow.value=coolant.vflow.value*coolant.dens.value;
        coolant.enthalpy.value=IAPWS_IF97('h_pT',coolant.press.value/10,coolant.temp.value+273.15);
        coolant.spec_heat.value=IAPWS_IF97('cp_ph',coolant.press.value/10,coolant.enthalpy.value)*1000; %multiply by 1000 so unit is J/kg*K
        coolant.power.value=coolant.mflow.value/3600*coolant.spec_heat.value*coolant.dT.value;
        coolant.power_TC.value=coolant.mflow.value/3600*coolant.spec_heat.value*coolant.dT_TC.value;
        
        coolant.power_Offset.value=coolant.power.value+mean(facility.powerOffset.var);
        coolant.power_TC_Offset.value=coolant.power_TC.value+mean(facility.powerOffset_TC.var);

        coolant.dynvis.value=IAPWS_IF97('mu_pT',coolant.press.value/10,coolant.temp.value+273.15);
        coolant.kinvis.value=coolant.dynvis.value/coolant.dens.value;
        coolant.thermcond.value=IAPWS_IF97('k_pT',coolant.press.value/10,coolant.temp.value+273.15);
        coolant.prandtl.value=coolant.spec_heat.value*coolant.dynvis.value/coolant.thermcond.value;
        coolant.velocity.value=coolant.vflow.value/3600/0.008641587; %flow area = 0.008641587 m2
        coolant.reynolds.value=coolant.velocity.value*coolant.dens.value*0.0791/coolant.dynvis.value;% hydraulic diameter of the annulus = 0.0791 m
        coolant.htc_dittusBoelter.value=0.023*coolant.reynolds.value^0.8*coolant.prandtl.value^0.4*coolant.thermcond.value/0.0791;
        coolant.htc_gnielinski.value=htc_gnielinski(coolant.reynolds.value,coolant.thermcond.value,coolant.prandtl.value,0.0791);
        coolant.htc_laminar.value=7.37*coolant.thermcond.value/0.0791;
        if coolant.reynolds.value>2300
            coolant.htc.value=coolant.htc_gnielinski.value;
        else
            coolant.htc.value=coolant.htc_laminar.value;
        end
        % steam side thermodynamic codnitions - measured
        steam.press.value=mean(calibratedData.PA9601); % [bar]        
        steam.power.value=mean(steam.power.var);   
        steam.powerOffset.value=mean(steam.powerOffset.var);  
        steam.temp.value=mean(calibratedData.TF9602); % [C] 
        steam.heater_temp.value=mean(steam.heater_temp.var); % [C] 
        
        %steam side thermocouples - centerline
        try
            steam.TF9603.value=mean(steam.TF9603.var);
            steam.TF9604.value=mean(steam.TF9604.var);
            steam.TF9605.value=mean(steam.TF9605.var);
            steam.TF9606.value=mean(steam.TF9606.var);
            steam.TF9607.value=mean(steam.TF9607.var);
            steam.TF9608.value=mean(steam.TF9608.var);
            steam.TF9609.value=mean(steam.TF9609.var);
            steam.TF9610.value=mean(steam.TF9610.var);
            steam.TF9611.value=mean(steam.TF9611.var);
            steam.TF9612.value=mean(steam.TF9612.var);
            steam.TF9613.value=mean(steam.TF9613.var);
            steam.TF9614.value=mean(steam.TF9614.var);
        catch
            disp('No data for thermocouples TF9603-TF9614 - old recording probably')
        end
        
        % continous steam properties
        steam.boiling_point.var=IAPWS_IF97('Tsat_p',steam.press.var./10)-273.15; 
        steam.density.var=1./IAPWS_IF97('v_pT',steam.press.var./10,steam.boiling_point.var+273.15+1); 
        steam.enthalpy.var=IAPWS_IF97('hV_p',steam.press.var./10);        
        steam.enthalpy_liquid.var=IAPWS_IF97('hL_p',steam.press.var./10);        
        steam.evap_heat.var=(steam.enthalpy.var-steam.enthalpy_liquid.var).*1000; %again, multiply by 1000 so unit is J/kg
        steam.mflow.var=steam.power.var./steam.evap_heat.var;   
        
        steam.vflow.var=steam.mflow.var./steam.density.var;
        steam.velocity.var=steam.vflow.var./(pi*(0.021/2)^2);  %last term is test tube crossection area
        
        % steam properties - calculated (some with IAPWS_IF97)
        steam.boiling_point.value=IAPWS_IF97('Tsat_p',steam.press.value/10)-273.15; 
        steam.density.value=1/IAPWS_IF97('v_pT',steam.press.value/10,steam.boiling_point.value+273.15+1);    
        steam.enthalpy.value=IAPWS_IF97('hV_p',steam.press.value/10);        
        steam.enthalpy_liquid.value=IAPWS_IF97('hL_p',steam.press.value/10);        
        steam.evap_heat.value=(steam.enthalpy.value-steam.enthalpy_liquid.value)*1000; %again, multiply by 1000 so unit is J/kg
        steam.mflow.value=steam.power.value/steam.evap_heat.value;        
        steam.vflow.value=steam.mflow.value/steam.density.value;
        steam.velocity.value=steam.vflow.value/(pi*(0.021/2)^2);  %last term is test tube crossection area
                
        % steam - coolant interface - facility
        facility.wall_dT.value=steam.temp.value-coolant.temp.value;    
        facility.powerOffset.value=mean(facility.powerOffset.var);
        facility.powerOffset_TC.value=mean(facility.powerOffset_TC.var);
        facility.heat_losses.value=steam.power.value-coolant.power.value;
        facility.heat_losses_TC.value=steam.power.value-coolant.power_TC.value;
        facility.dT_losses.value=(coolant.power.value+facility.heat_losses.value)/(coolant.mflow.value/3600*coolant.spec_heat.value);  % how much more dT should there be in coolant water
        try
            facility.wallThermcond.value=steel_316L_thermcond(mean(GHFS.GHFS1_temp.var));
        catch
            facility.wallThermcond.value=15;
        end
        facility.wall_htc.value=2*facility.wallThermcond.value/(0.02*log(0.03/0.02));
%         facility.wall_htc.value=2*15/(0.02*log(0.03/0.02));
%         facility.wall_heatflux_dT.value=facility.wall_htc.value*facility.wall_dT.value;
        facility.wall_heatflux_dT.value=mean(GHFS.wall_heatflux_GHFS1.var+GHFS.wall_heatflux_GHFS2.var+GHFS.wall_heatflux_GHFS3.var+GHFS.wall_heatflux_GHFS4.var)/4;
        facility.wall_heatflow_dT.value=facility.wall_heatflux_dT.value*2*pi*0.020/2*1;  %last term is inner wall area of the test tube
        
        %         facility.voltage.value=mean(facility.voltage.var);
        facility.current.value=mean(facility.current.var);
        facility.NCtank_press.value=mean(facility.NCtank_press.var);
        facility.NCtank_temp.value=mean(facility.NCtank_press.var);
        %Fast sensors
        if  fast_flag==1
            
            % GHFS  replace with looooop
            GHFS.GHFS1_raw.value=mean(GHFS.GHFS1_raw.var);
            GHFS.GHFS2_raw.value=mean(GHFS.GHFS2_raw.var);
            GHFS.GHFS3_raw.value=mean(GHFS.GHFS3_raw.var);
            GHFS.GHFS4_raw.value=mean(GHFS.GHFS4_raw.var);
            
            GHFS.GHFS1_offset_raw.value=mean(GHFS.GHFS1_offset_raw.var);
            GHFS.GHFS2_offset_raw.value=mean(GHFS.GHFS2_offset_raw.var);
            GHFS.GHFS3_offset_raw.value=mean(GHFS.GHFS3_offset_raw.var);
            GHFS.GHFS4_offset_raw.value=mean(GHFS.GHFS4_offset_raw.var);
            
            GHFS.GHFS1_temp.value=mean(GHFS.GHFS1_temp.var);
            GHFS.GHFS2_temp.value=mean(GHFS.GHFS2_temp.var);
            GHFS.GHFS3_temp.value=mean(GHFS.GHFS3_temp.var);
            GHFS.GHFS4_temp.value=mean(GHFS.GHFS4_temp.var);
            
            GHFS.wall_dT_GHFS1.value=mean(GHFS.wall_dT_GHFS1.var);
            GHFS.wall_dT_GHFS2.value=mean(GHFS.wall_dT_GHFS2.var);
            GHFS.wall_dT_GHFS3.value=mean(GHFS.wall_dT_GHFS3.var);
            GHFS.wall_dT_GHFS4.value=mean(GHFS.wall_dT_GHFS4.var);
            
            GHFS.GHFS1.value=mean(GHFS.GHFS1.var);
            GHFS.GHFS2.value=mean(GHFS.GHFS2.var);
            GHFS.GHFS3.value=mean(GHFS.GHFS3.var);
            GHFS.GHFS4.value=mean(GHFS.GHFS4.var);
            
            GHFS.wall_heatflux_GHFS1.value=mean(GHFS.wall_heatflux_GHFS1.var);
            GHFS.wall_heatflux_GHFS2.value=mean(GHFS.wall_heatflux_GHFS2.var);
            GHFS.wall_heatflux_GHFS3.value=mean(GHFS.wall_heatflux_GHFS3.var);
            GHFS.wall_heatflux_GHFS4.value=mean(GHFS.wall_heatflux_GHFS4.var);       
        
            % Movable probe - electrodes
            MP.MP1.value=mean(MP.MP1.var);
            MP.MP1_filmthick.value=mean(MP.MP1_filmthick.var);
            MP.MP2.value=mean(MP.MP2.var);
            MP.MP3.value=mean(MP.MP3.var);
            MP.MP4.value=mean(MP.MP4.var);

        end
        
        %% MOVABLE PROBE POSITION AND TEMEPRATURE CALCULATION
        if MP_flag %this is not available for all the calculations
            for rounding_counter=1:numel(calibratedData.MP_Pos)
                MP.Pos.var(rounding_counter,1)=round(calibratedData.MP_Pos(rounding_counter)*10);  %rounding to the first digit to the right of the decimal point
                MP.Pos.var(rounding_counter,1)=MP.Pos.var(rounding_counter,1)/10;
            end
%             MP.Pos.var=cal_steady_data.MP_Pos;
            MP.Pos.value=mean(MP.Pos.var); %[mm, wall with fixed probe is 0]
            % MOD THIS ACCORDINGLY TO PROPER CHANNELS
            MP.Temp.var=calibratedData.MP_TF;
            MP.Temp.value=mean(MP.Temp.var); %[deg C]
            
            %make sure that the while loop executes at least once
            frist_loop_flag=1;           

            while interactive_flag || frist_loop_flag
                             

                %based on user choice apply appropriate smoothing algorithm
                switch smoothing_type
                    case 1  
                        MP.Temp_smooth.var=smooth(MP.Temp.var,frame_size,'moving');
                    case 2
                        MP.Temp_smooth.var=smooth(MP.Temp.var,frame_size,'sgolay',sgolay_order);
                    case 3
                        MP.Temp_smooth.var=smooth(MP.Temp.var,frame_size,'lowess');
                    case 4
                        MP.Temp_smooth.var=smooth(MP.Temp.var,frame_size,'loess');
                    case 5
                        MP.Temp_smooth.var=smooth(MP.Temp.var,frame_size,'rlowess');
                    case 6
                        MP.Temp_smooth.var=smooth(MP.Temp.var,frame_size,'rloess');
                end
                
                %is user wants to control paramters of this smoothing
                
                if interactive_flag                                                   
                    %show user the results and ask if he likes them or not
                    [user_decision,new_param,smooth_update_defaults] = gui_smoothing_interactive(MP.Temp.var,MP.Temp_smooth.var,smoothing_type,frame_size,sgolay_order,frist_loop_flag);
                   
                    % if user is happy with the results
                    if user_decision
                        break
                    else
                        %update parameters for the next iteration
                        frame_size=new_param.frame_size;
                        smoothing_type=new_param.smoothing_type;
                        sgolay_order=new_param.sgolay_order;
                    end
                end
                
                %change first loop flag to indicate first iteration is done
                frist_loop_flag=0;                
            end
            
            MP.Temp_smooth.value=mean(MP.Temp_smooth.var);

            %build a matrix with probe position as first column to enable 
            %proper sorting
            %preallocate
            pos_amount=numel(MP.Pos.var);
            MP_direction=zeros(1, pos_amount);
            
            for pos_counter=1:pos_amount
                if pos_counter==pos_amount
                    MP_direction(pos_counter)=MP_direction(pos_counter-1); % for the last point assume the direction is as for the previous one
                elseif MP.Pos.var(pos_counter+1)>MP.Pos.var(pos_counter)
                    MP_direction(pos_counter)=1;
                    %if next position has higher value - you're going forward
                elseif MP.Pos.var(pos_counter+1)<MP.Pos.var(pos_counter)
                    MP_direction(pos_counter)=0;
                    %alternatively, you're going backward
                else
                    %but if the tip halted, just assume it's part of the
                    %previous movement
                    try
                        MP_direction(pos_counter)=MP_direction(pos_counter-1);
                    catch
                        %but if this happened for the first data point, just
                        %assume going forward, will not change much
                        MP_direction(pos_counter)=1;
                    end
                end
            end
            
            %resample voltage signal to match temperature signal
            % the p * q must be lower than 2^31, due to nature of resample,
            % so check first
            amntSlow=numel(MP.Temp.var);
            amntMP(1)=numel(MP.MP1.var);
            amntMP(2)=numel(MP.MP2.var);
            amntMP(3)=numel(MP.MP3.var);
            amntMP(4)=numel(MP.MP4.var);
            MPnostring={'MP1','MP2','MP3','MP4'};
            
            for rCntr=1:numel(amntMP)
                try
                    MPresampl{rCntr}=resample(MP.(MPnostring{rCntr}).var,amntSlow,amntMP(rCntr));            
                    tooMuch=numel(MPresampl{rCntr})-amntSlow; 
                    MPresampl{rCntr}=MPresampl{rCntr}(1:end-tooMuch);
                catch
                    %probably fails because too many data points, try to do
                    %in parts, number of parts depends on ratio to 2^31
                    nParts=ceil(amntSlow*amntMP(rCntr)/2^31);
                    
                    %define span of each part
                    sizeSlow=ceil(amntSlow/nParts);
                    sizeMP=ceil(amntMP(rCntr)/nParts);
                    
                    %define begining records
                    stRec=1;
                    endRec=sizeMP;
                    
                    %define flags and counter
                    empty=0;  %shows when all records were processed
                    lastIter=0; %signidies last iteration
                    pCntr=1;
                    resampBin=[];
%                     for pCntr=1:nParts
                    while ~empty
                        try   
                            resampBin{pCntr}=resample(MP.(MPnostring{rCntr}).var(stRec:endRec),sizeSlow,sizeMP);
                        catch
                            disp('error')
                        end
                        %define new 
                        stRec=endRec+1;
                        endRec=stRec+sizeMP-1;
                        
                        if lastIter
                            empty=1;
                        end
                        
                        if endRec>=amntMP(rCntr)
                            endRec=amntMP(rCntr);
                            lastIter=1;                            
                        end
                        pCntr=pCntr+1;
                    end
                     resamplTemp=[];
                     for cntr=1:numel(resampBin)
                         resamplTemp=[resamplTemp,resampBin{cntr}'];
                     end
                     tooMuch=numel(resamplTemp)-amntSlow; %stupid stupid stupid XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                     resamplTemp=resamplTemp(1:end-tooMuch);                    
                     MPresampl{rCntr}=resamplTemp';
                end
%                 [amntSlow, amntMP(resampCntr)]=varSizeCutter(amntSlow, amntMP(resampCntr));
            end
            
            %combine all into one matrix for further processing
            if strcmp(file_list,'NC-MFR-ABS-He-4_2_2')
                cf=5000;
                MP_matrix=[MP.Pos.var(1:cf) MP.Temp.var(1:cf) MP.Temp_smooth.var(1:cf) MPresampl{1}(1:cf) MPresampl{2}(1:cf) MPresampl{3}(1:cf) MPresampl{4}(1:cf) MP_direction(1:cf)'];
            else
                MP_matrix=[MP.Pos.var MP.Temp.var MP.Temp_smooth.var MPresampl{1} MPresampl{2} MPresampl{3} MPresampl{4} MP_direction'];
            end
            %sort by movement direction and separate in two matrices
            MP_matrix=sortrows(MP_matrix,8);
            direction_forward=find(MP_matrix(:,8)==1);
            direction_backward=find(MP_matrix(:,8)==0);

            %as matrix is sorted by row 8, all forward and backward points
            %are grouped - first backward movement, then forward movement, simple to separate
            if numel(direction_forward)>0
                MP_data.forward=MP_matrix(direction_forward(1):direction_forward(end),1:7);
                forward_flag=1;
            else
                forward_flag=0;
            end

            if numel(direction_backward)>0
                MP_data.backward=MP_matrix(direction_backward(1):direction_backward(end),1:7);
                backward_flag=1;
            else
                backward_flag=0;
            end

            %this is not elegant way here but I have to prepare for
            %cases when we measured only one direction of movement
            %and honestly it's Friday and I could not be less creative
            %Filip 04.03.2016
            if forward_flag && backward_flag
                directions={'forward', 'backward'};
            elseif forward_flag
                directions={'forward'};
            elseif backward_flag
                directions={'backward'};
            end

            %now, process data for forward movement and backward movement
            %separately - average temp for every position point
            for ctr=1:numel(directions)

                %sort by position (first column) - "directions{ctr}" is either "forward" or
                %"backward"
                MP_data.(directions{ctr})=sortrows(MP_data.(directions{ctr}),1);
                %disassemble matrix into sorted vectors
                MP_pos_sorted=MP_data.(directions{ctr})(:,1);
                MP_temp_sorted=MP_data.(directions{ctr})(:,2);
                MP_temp_sorted_filtered=MP_data.(directions{ctr})(:,3);
                MP1resamplSorted=MP_data.(directions{ctr})(:,4);
                MP2resamplSorted=MP_data.(directions{ctr})(:,5);
                MP3resamplSorted=MP_data.(directions{ctr})(:,6);
                MP4resamplSorted=MP_data.(directions{ctr})(:,7);

                %loop below averages temperatures for a given position
                n=1;
                while numel(MP_pos_sorted)>0
                    %take first position from the top and find how many rows
                    %below also are for the same positions (since the matrix
                    %is sorted these would be all rows with the same position)
                    processed_pos=MP_pos_sorted(1);
                    interval=find(MP_pos_sorted==processed_pos);
                    %do the following only if enough points were measured at this
                    %position
                    if numel(interval)>3
                        %average temperatures for given position over all
                        %measurements
                        pos_temp=mean(MP_temp_sorted(1:interval(end)));                        
                        %also for the filtered data
                        pos_temp_smooth=mean(MP_temp_sorted_filtered(1:interval(end)));
                        %calculate standard deviation for a given position
                        pos_std=std(MP_temp_sorted(1:interval(end)));
                        %average voltage signal for all 4 electrodes
                        pos_MP1=mean(MP1resamplSorted(1:interval(end)));
                        pos_MP1_std=std(MP1resamplSorted(1:interval(end)));
                        pos_MP2=mean(MP2resamplSorted(1:interval(end)));
                        pos_MP2_std=std(MP2resamplSorted(1:interval(end)));
                        pos_MP3=mean(MP3resamplSorted(1:interval(end)));
                        pos_MP3_std=std(MP3resamplSorted(1:interval(end)));
                        pos_MP4=mean(MP4resamplSorted(1:interval(end)));
                        pos_MP4_std=std(MP4resamplSorted(1:interval(end)));
                        
                        %store all for the glorious future
                        MP_Temp_averaged.(directions{ctr})(n,:)=[processed_pos pos_temp pos_temp_smooth pos_std pos_MP1 pos_MP2 pos_MP3 pos_MP4 pos_MP1_std pos_MP2_std pos_MP3_std pos_MP4_std];
                        n=n+1;
                    else
                    end
                    %now clear the rows that were just processed, so program
                    %will at some point exit this unholy loop
                    MP_pos_sorted(1:interval(end))=[];
                    MP_temp_sorted(1:interval(end))=[];
                    MP_temp_sorted_filtered(1:interval(end))=[];
                    MP1resamplSorted(1:interval(end))=[];
                    MP2resamplSorted(1:interval(end))=[];
                    MP3resamplSorted(1:interval(end))=[];
                    MP4resamplSorted(1:interval(end))=[];
                end

            end
        else
            disp('Warning, no movable probe position and temperature data available')
        end

        % plotting for testing purposes, comment out
%         if forward_flag
%             figure
%             plot(MP_Temp_averaged.(directions{1})(:,1),MP_Temp_averaged.(directions{1})(:,2),'.')
%             hold on
%             plot(MP_Temp_averaged.(directions{1})(:,1),MP_Temp_averaged.(directions{1})(:,3),'r-')
%             hold off
%         end
%         
%         if backward_flag
%             figure
%             plot(MP_Temp_averaged.(directions{2})(:,1),MP_Temp_averaged.(directions{2})(:,2),'k.')
%             hold on
%             plot(MP_Temp_averaged.(directions{2})(:,1),MP_Temp_averaged.(directions{2})(:,3),'g-')
%             hold off
%         end
        
        %make sure that the while loop executes at least once
        frist_loop_flag=1;
        %------*-***************-*-***************** 
        %boundary layer calculation, based on movable probe temperature and position data       
        
        while interactive_flag || frist_loop_flag   
        
            try
                [MP.T_boundlayer_forward.value,fwd_data_norm,fwd_lower,fwd_upper,x_dat_forward,~]=boundary_layer_calc(MP_Temp_averaged.forward(:,2),MP_Temp_averaged.forward(:,1),avg_window,limiting_factor,x_limit);
                if MP.T_boundlayer_forward.value < -2.4
                    MP.T_boundlayer_forward.value=0;
                end
                MP.T_boundlayer_forward.value=-MP.T_boundlayer_forward.value;
            catch
                disp('no boundlayer forward found')
                MP.T_boundlayer_forward.value=0;
            end
            try
                [MP.T_boundlayer_backward.value,bkwd_data_norm,bkwd_lower,bkwd_upper,x_dat_backward,~]=boundary_layer_calc(MP_Temp_averaged.backward(:,2),MP_Temp_averaged.backward(:,1),avg_window,limiting_factor,x_limit);
                if MP.T_boundlayer_backward.value < -5
                    MP.T_boundlayer_backward.value=0;
                end
                MP.T_boundlayer_backward.value=-MP.T_boundlayer_backward.value;
            catch
                MP.T_boundlayer_backward.value=0;
                disp('no boundlayer backward found')
            end
            
            if interactive_flag        
                
                %package data
                MP_package.forward.pos=x_dat_forward;                       %modified position
                MP_package.forward.norm_temp=fwd_data_norm;                 %normalized temperature data
                MP_package.forward.lower=fwd_lower;                         %lower boundary of acceptable points deviation
                MP_package.forward.upper=fwd_upper;                         %upper boundary of acceptable points deviation
                MP_package.forward.blayer=MP.T_boundlayer_forward.value;    %forward movement boundary layer
                MP_package.backward.pos=x_dat_backward;                     %modified position
                MP_package.backward.norm_temp=bkwd_data_norm;               %normalized temperature data
                MP_package.backward.lower=bkwd_lower;                       %lower boundary of acceptable points deviation
                MP_package.backward.upper=bkwd_upper;                       %upper boundary of acceptable points deviation
                MP_package.backward.blayer=MP.T_boundlayer_backward.value;  %backward movement boundary layer 
                
                %show user the results and ask if he likes them or not
                [user_decision,new_param] = gui_boundary_layer_interactive(MP_package,avg_window,limiting_factor,x_limit,frist_loop_flag);

                % if user is happy with the results
                if user_decision
                    break
                else
                    %update parameters for the next iteration
                    avg_window=new_param.avg_window;
                    limiting_factor=new_param.limiting_factor;
                    x_limit=new_param.x_limit;
                end
            end
               
            %change first loop flag to indicate first iteration is done
            frist_loop_flag=0; 
        end
            
            
        MP.T_boundlayer_mean.value=(MP.T_boundlayer_forward.value+MP.T_boundlayer_backward.value)/2;
        
        
        %% distributions
        
        % thermocouple steady_data.TCH2_2W is broken
        % as a workaround, use average between two thermocouples
        if ~isfield(experimentalData,'TCH2_2W') && isfield(experimentalData,'TCH1_2W')
            experimentalData.TCH2_2W=(experimentalData.TCH1_2W+experimentalData.TCH3_2W)./2;
        end
        
        %time-varying data
        if MP_flag %MP_flag points to new files. which have modified TC layout
            %movable probe distributions
            if forward_flag
                distributions.MP_forward_temp.var=MP_Temp_averaged.forward(:,2);                
                distributions.MP_forward_temp_smooth.var=MP_Temp_averaged.forward(:,3);
                distributions.MP_forward_MP1.var=MP_Temp_averaged.forward(:,5);
                distributions.MP_forward_MP2.var=MP_Temp_averaged.forward(:,6);
                distributions.MP_forward_MP3.var=MP_Temp_averaged.forward(:,7);
                distributions.MP_forward_MP4.var=MP_Temp_averaged.forward(:,8);
            end
            if backward_flag
                distributions.MP_backward_temp.var=MP_Temp_averaged.backward(:,2);               
                distributions.MP_backward_temp_smooth.var=MP_Temp_averaged.backward(:,3);
                distributions.MP_backward_MP1.var=MP_Temp_averaged.backward(:,5);
                distributions.MP_backward_MP2.var=MP_Temp_averaged.backward(:,6);
                distributions.MP_backward_MP3.var=MP_Temp_averaged.backward(:,7);
                distributions.MP_backward_MP4.var=MP_Temp_averaged.backward(:,8);
            end 
        end
        
       
        %centerline - 3 options are for legacy data file structure from
        %runs done in 2014 and 2015
        try
            distributions.centerline_temp.var=[steam.TF9603.var,steam.TF9604.var,steam.TF9605.var,steam.TF9606.var,steam.TF9607.var,steam.TF9608.var,steam.TF9609.var,steam.TF9610.var,steam.TF9611.var,steam.TF9612.var,steam.TF9613.var,steam.TF9614.var];
            centerline_flag=1;
        catch
            try
                distributions.centerline_temp.var=[calibratedData.TCH1_1F,MP.Temp.var,calibratedData.TCH2_1F,calibratedData.TCH3_1F,calibratedData.TCH4_1F];
                centerline_flag=1;
            catch
                try
                    distributions.centerline_temp.var=[calibratedData.TCH1_1F,calibratedData.TCH2_1F,calibratedData.TCH3_1F,calibratedData.TCH4_1F];
                    centerline_flag=1;
                catch
                    distributions.centerline_temp.var=[0,0,0,0];
                    centerline_flag=0;
                end
            end
        end
        
        % the layout of TC's is the same for old and new files, hence no if /try catch structures
        distributions.coolant_temp_0deg.var=[calibratedData.TF9503,calibratedData.TF9505,calibratedData.TF9507];
        distributions.coolant_temp_180deg.var=[calibratedData.TF9504,calibratedData.TF9506,calibratedData.TF9508];
        distributions.outer_wall_temp_0deg.var=[calibratedData.TW9501,calibratedData.TW9503,calibratedData.TW9505,calibratedData.TW9507,calibratedData.TW9509,calibratedData.TW9511];
        distributions.outer_wall_temp_180deg.var=[calibratedData.TW9502,calibratedData.TW9504,calibratedData.TW9506,calibratedData.TW9508,calibratedData.TW9510,calibratedData.TW9512];
        
        %GHFS thermocouples
        try
            distributions.GHFS_TC.var=[calibratedData.HFS1TC,calibratedData.HFS2TC,calibratedData.HFS3TC,calibratedData.HFS4TC];
        catch
            try
            distributions.GHFS_TC.var=[calibratedData.TCH1_2W,(calibratedData.TCH1_2W+calibratedData.TCH3_2W)./2,calibratedData.TCH3_2W,calibratedData.TCH4_2W];
            catch
                distributions.GHFS_TC.var=[0,0,0,0];
            end
        end
        
        %inner wall thermocouples
        try
            distributions.wall_inner.var=distributions.GHFS_TC.var;
            wall_inner_flag=1;
        catch
            wall_inner_flag=0;
        end
        
        %outer wall thermocouples
        try
            distributions.wall_outer.var=[calibratedData.TCH1_3W,calibratedData.TCH2_3W,calibratedData.TCH3_3W,calibratedData.TCH4_3W];
        catch
        end
        
        %wall dT at GHFS positions
        try
            distributions.wall_dT.var=[GHFS.wall_dT_GHFS1.var,GHFS.wall_dT_GHFS2.var,GHFS.wall_dT_GHFS3.var,GHFS.wall_dT_GHFS4.var];
        catch
        end
        
        %==================================================================================================================
        %temperature mean values - calibrated 
        if MP_flag %MP_flag points to new files. which have modified TC layout
            %movable probe distributions
            if forward_flag
                distributions.MP_forward_temp.value.cal=MP_Temp_averaged.forward(:,2);
                distributions.MP_forward_temp.std=MP_Temp_averaged.forward(:,4);               
                distributions.MP_forward_temp_smooth.value.cal=MP_Temp_averaged.forward(:,3);
                distributions.MP_forward_MP1.value.cal=MP_Temp_averaged.forward(:,5);
                distributions.MP_forward_MP2.value.cal=MP_Temp_averaged.forward(:,6);
                distributions.MP_forward_MP3.value.cal=MP_Temp_averaged.forward(:,7);
                distributions.MP_forward_MP4.value.cal=MP_Temp_averaged.forward(:,8);
                distributions.MP_forward_MP1.std=MP_Temp_averaged.forward(:,9);
                distributions.MP_forward_MP2.std=MP_Temp_averaged.forward(:,10);
                distributions.MP_forward_MP3.std=MP_Temp_averaged.forward(:,11);
                distributions.MP_forward_MP4.std=MP_Temp_averaged.forward(:,12);
                
                 %dirty fix
%                 if max(distributions.MP_forward_temp.value.cal)-min(distributions.MP_forward_temp.value.cal)<2.5
%                     MP.T_boundlayer_forward.value=0;
%                 end
            end
            if backward_flag
                distributions.MP_backward_temp.value.cal=MP_Temp_averaged.backward(:,2);               
                distributions.MP_backward_temp.std=MP_Temp_averaged.backward(:,4);
                distributions.MP_backward_temp_smooth.value.cal=MP_Temp_averaged.backward(:,3);
                distributions.MP_backward_MP1.value.cal=MP_Temp_averaged.backward(:,5);
                distributions.MP_backward_MP2.value.cal=MP_Temp_averaged.backward(:,6);
                distributions.MP_backward_MP3.value.cal=MP_Temp_averaged.backward(:,7);
                distributions.MP_backward_MP4.value.cal=MP_Temp_averaged.backward(:,8);
                distributions.MP_backward_MP1.std=MP_Temp_averaged.backward(:,9);
                distributions.MP_backward_MP2.std=MP_Temp_averaged.backward(:,10);
                distributions.MP_backward_MP3.std=MP_Temp_averaged.backward(:,11);
                distributions.MP_backward_MP4.std=MP_Temp_averaged.backward(:,12);
                
                %dirty fix
%                 if max(distributions.MP_backward_temp.value.cal)-min(distributions.MP_backward_temp.value.cal)<2.5
%                     MP.T_boundlayer_backward.value=0;
%                 end
            end 
        end
          
        %centerline - 3 options are for legacy data file structure from
        %runs done in 2014 and 2015
        try
            distributions.centerline_temp.value.cal=[steam.TF9603.value,steam.TF9604.value,steam.TF9605.value,steam.TF9606.value,steam.TF9607.value,steam.TF9608.value,steam.TF9609.value,steam.TF9610.value,steam.TF9611.value,steam.TF9612.value,steam.TF9613.value,steam.TF9614.value];
            centerline_flag=1;
        catch
            try
                distributions.centerline_temp.value.cal=[mean(calibratedData.TCH1_1F),MP.Temp.value,mean(calibratedData.TCH2_1F),mean(calibratedData.TCH3_1F),mean(calibratedData.TCH4_1F)];
                centerline_flag=1;
            catch
                try
                    distributions.centerline_temp.value.cal=[mean(calibratedData.TCH1_1F),mean(calibratedData.TCH2_1F),mean(calibratedData.TCH3_1F),mean(calibratedData.TCH4_1F)];
                    centerline_flag=1;
                catch
                    centerline_flag=0;
                end
            end
        end
        
        % the layout of TC's is the same for old and new files, hence no if /try catch structures
        distributions.coolant_temp_0deg.value.cal=[mean(calibratedData.TF9503),mean(calibratedData.TF9505),mean(calibratedData.TF9507)];
        distributions.coolant_temp_180deg.value.cal=[mean(calibratedData.TF9504),mean(calibratedData.TF9506),mean(calibratedData.TF9508)];
        distributions.outer_wall_temp_0deg.value.cal=[mean(calibratedData.TW9501),mean(calibratedData.TW9503),mean(calibratedData.TW9505),mean(calibratedData.TW9507),mean(calibratedData.TW9509),mean(calibratedData.TW9511)];
        distributions.outer_wall_temp_180deg.value.cal=[mean(calibratedData.TW9502),mean(calibratedData.TW9504),mean(calibratedData.TW9506),mean(calibratedData.TW9508),mean(calibratedData.TW9510),mean(calibratedData.TW9512)];
        
        %GHFS thermocouples
        try
            distributions.GHFS_TC.value.cal=[mean(calibratedData.HFS1TC),mean(calibratedData.HFS2TC),mean(calibratedData.HFS3TC),mean(calibratedData.HFS4TC)];
        catch
            try
                distributions.GHFS_TC.value.cal=[mean(calibratedData.TCH1_2W),mean((calibratedData.TCH1_2W+calibratedData.TCH3_2W)./2),mean(calibratedData.TCH3_2W),mean(calibratedData.TCH4_2W)];
            catch
                distributions.GHFS_TC.value.cal=[0,0,0,0];
            end
        end
        
        %inner wall thermocouples
        try
            distributions.wall_inner.value.cal=distributions.GHFS_TC.value.cal;
            wall_inner_flag=1;
        catch
            wall_inner_flag=0;
        end
        
        %outer wall thermocouples
        try
            distributions.wall_outer.value.cal=[mean(calibratedData.TCH1_3W),mean(calibratedData.TCH2_3W),mean(calibratedData.TCH3_3W),mean(calibratedData.TCH4_3W)];
        catch
        end
        
        %wall dT at GHFS positions
        try
            distributions.wall_dT.value.cal=[GHFS.wall_dT_GHFS1.value,GHFS.wall_dT_GHFS2.value,GHFS.wall_dT_GHFS3.value,GHFS.wall_dT_GHFS4.value];
        catch
        end
        
        %==================================================================================================================
        %temperature mean values- non calibrated
              
        if MP_flag
            %across the tube - forward motion
            for molefr_ctr=1:numel(distributions.MP_forward_temp.value.cal)
                distributions.MP_forward_partpress_h2o.value.cal(molefr_ctr,1)=IAPWS_IF97('psat_T',(distributions.MP_forward_temp.value.cal(molefr_ctr)+273.15))*10;  % * 10 to convert MPa to bar
                distributions.MP_forward_molefr_h2o.value.cal(molefr_ctr,1)=distributions.MP_forward_partpress_h2o.value.cal(molefr_ctr)/steam.press.value;
            end
            %across the tube - backward motion
            for molefr_ctr=1:numel(distributions.MP_backward_temp.value.cal)
                distributions.MP_backward_partpress_h2o.value.cal(molefr_ctr,1)=IAPWS_IF97('psat_T',(distributions.MP_backward_temp.value.cal(molefr_ctr)+273.15))*10;  % * 10 to convert MPa to bar
                distributions.MP_backward_molefr_h2o.value.cal(molefr_ctr,1)=distributions.MP_backward_partpress_h2o.value.cal(molefr_ctr)/steam.press.value;
            end
        end
        if MP_flag
            if forward_flag
                distributions.MP_forward_temp.value.non_cal=MP_Temp_averaged.forward(:,2);
                distributions.MP_forward_temp_smooth.value.non_cal=MP_Temp_averaged.forward(:,3);
            end
            if backward_flag
                distributions.MP_backward_temp.value.non_cal=MP_Temp_averaged.backward(:,2);
                distributions.MP_backward_temp_smooth.value.non_cal=MP_Temp_averaged.backward(:,3); 
            end 
                
        end
        
        %the layout of TC's in the coolant water and outer jacket is the same for old and new files, hence no if /try catch structures
        distributions.coolant_temp_0deg.value.non_cal=[mean(experimentalData.TF9503),mean(experimentalData.TF9505),mean(experimentalData.TF9507)];
        distributions.coolant_temp_180deg.value.non_cal=[mean(experimentalData.TF9504),mean(experimentalData.TF9506),mean(experimentalData.TF9508)];
        distributions.outer_wall_temp_0deg.value.non_cal=[mean(experimentalData.TW9501),mean(experimentalData.TW9503),mean(experimentalData.TW9505),mean(experimentalData.TW9507),mean(experimentalData.TW9509),mean(experimentalData.TW9511)];
        distributions.outer_wall_temp_180deg.value.non_cal=[mean(experimentalData.TW9502),mean(experimentalData.TW9504),mean(experimentalData.TW9506),mean(experimentalData.TW9508),mean(experimentalData.TW9510),mean(calibratedData.TW9512)];
        try
            distributions.centerline_temp.value.non_cal=[mean(experimentalData.TCH1_1F),MP.Temp.value,mean(experimentalData.TCH2_1F),mean(experimentalData.TCH3_1F),mean(experimentalData.TCH4_1F)];     
        catch
           
        end
        
        %GHFS thermocouples - non calibrated  
        try
            distributions.GHFS_TC.value.non_cal=[mean(experimentalData.HFS1TC),mean(experimentalData.HFS2TC),mean(experimentalData.HFS3TC),mean(experimentalData.HFS4TC)];
            %GHFS_TC_flag=1;
        catch
            try
                distributions.GHFS_TC.value.non_cal=[mean(experimentalData.TCH1_2W),mean(experimentalData.TCH2_2W),mean(experimentalData.TCH3_2W),mean(experimentalData.TCH4_2W)];
                %GHFS_TC_flag=0;
            catch
                distributions.GHFS_TC.value.non_cal=[0,0,0,0];
            end
        end
        
        %inner wall thermocouples
        try
            distributions.wall_inner.value.non_cal=[mean(experimentalData.TCH1_2W),mean(experimentalData.TCH2_2W),mean(experimentalData.TCH3_2W),mean(experimentalData.TCH4_2W)];
        catch
        end
        
        %outer wall thermocouples
        try
            distributions.wall_outer.value.non_cal=[mean(experimentalData.TCH1_3W),mean(experimentalData.TCH2_3W),mean(experimentalData.TCH3_3W),mean(experimentalData.TCH4_3W)];
        catch
        end
        
        %wall dT at GHFS positions
        try
            distributions.wall_dT.value.non_cal=[mean(experimentalData.TCH1_2W-experimentalData.TCH1_3W),mean(experimentalData.TCH2_2W-experimentalData.TCH2_3W),mean(experimentalData.TCH3_2W-experimentalData.TCH3_3W),mean(experimentalData.TCH4_2W-experimentalData.TCH4_3W)];
        catch
        end

        %partial pressure of h2o and mole fraction of h2o - based on calibrated temperature
        %along the tube
        if centerline_flag~=0
            for molefr_ctr=1:numel(distributions.centerline_temp.value.cal)
                distributions.centerline_partpress_h2o.value.cal(molefr_ctr)=IAPWS_IF97('psat_T',(distributions.centerline_temp.value.cal(molefr_ctr)+273.15))*10;  % * 10 to convert MPa to bar            
                distributions.centerline_molefr_h2o.value.cal(molefr_ctr)=distributions.centerline_partpress_h2o.value.cal(molefr_ctr)/steam.press.value;
                
                if distributions.centerline_molefr_h2o.value.cal(molefr_ctr)>1  %due to superheat!
                    distributions.centerline_molefr_h2o.value.cal(molefr_ctr)=1;
                end
                distributions.centerline_molefr_NC.value.cal(molefr_ctr)=1-distributions.centerline_molefr_h2o.value.cal(molefr_ctr); 
            end  
            steam.moleFr_660.value=distributions.centerline_molefr_h2o.value.cal(5);
        end
      
        %==================================================================================================================
        %geometry - vertical distribution of sensors
        if MP_flag
            
            if forward_flag
                distributions.MP_forward_temp.position_y=ones(length(distributions.MP_forward_temp.value.cal),1)*(360+27.5);
                distributions.MP_forward_temp_smooth.position_y=ones(length(distributions.MP_forward_temp_smooth.value.cal),1)*(360+27.5);
                distributions.MP_forward_partpress_h2o.position_y=ones(length(distributions.MP_forward_partpress_h2o.value.cal),1)*(360+27.5);  
                distributions.MP_forward_molefr_h2o.position_y=ones(length(distributions.MP_forward_partpress_h2o.value.cal),1)*(360+27.5);    

                distributions.MP_forward_MP1.position_y=ones(length(distributions.MP_forward_MP1.value),1)*(360+27.5); 
                distributions.MP_forward_MP2.position_y=ones(length(distributions.MP_forward_MP2.value),1)*(360+27.5); 
                distributions.MP_forward_MP3.position_y=ones(length(distributions.MP_forward_MP3.value),1)*(360+27.5); 
                distributions.MP_forward_MP4.position_y=ones(length(distributions.MP_forward_MP4.value),1)*(360+27.5); 
            end
            
            if backward_flag
                distributions.MP_backward_temp.position_y=ones(length(distributions.MP_backward_temp.value.cal),1)*(360+27.5);
                distributions.MP_backward_temp_smooth.position_y=ones(length(distributions.MP_backward_temp_smooth.value.cal),1)*(360+27.5);           
                distributions.MP_backward_partpress_h2o.position_y=ones(length(distributions.MP_backward_partpress_h2o.value.cal),1)*(360+27.5);           
                distributions.MP_backward_molefr_h2o.position_y=ones(length(distributions.MP_backward_partpress_h2o.value.cal),1)*(360+27.5);

                distributions.MP_backward_MP1.position_y=ones(length(distributions.MP_backward_MP1.value),1)*(360+27.5); 
                distributions.MP_backward_MP2.position_y=ones(length(distributions.MP_backward_MP2.value),1)*(360+27.5); 
                distributions.MP_backward_MP3.position_y=ones(length(distributions.MP_backward_MP3.value),1)*(360+27.5); 
                distributions.MP_backward_MP4.position_y=ones(length(distributions.MP_backward_MP4.value),1)*(360+27.5); 
            end
                       
        end
        
        if centerline_flag
            if numel(distributions.centerline_temp.value.cal)==12
                %centerline geometry
                distributions.centerline_temp.position_y=[220 320 420 520 620 670 720 820 920 1020 1120 1220];
                distributions.GHFS_TC.position_y=[220 420 670 920];  %position of sensors in mm
            else             
                if numel(distributions.centerline_temp.value.cal)==5 
                    distributions.centerline_temp.position_y=[210+27.5 360+27.5 431+27.5 733+27.5 1035+27.5];
                else
                    distributions.centerline_temp.position_y=[210+27.5 360+27.5 733+27.5 1035+27.5];
                end
                distributions.GHFS_TC.position_y=[210+27.5 431+27.5 733+27.5 1035+27.5];  %position of sensors in mm
            end
            
            distributions.centerline_molefr_h2o.position_y=distributions.centerline_temp.position_y;
            distributions.centerline_partpress_h2o.position_y=distributions.centerline_temp.position_y;
            distributions.centerline_molefr_NC.position_y=distributions.centerline_temp.position_y;    
        end
        
        distributions.coolant_temp_0deg.position_y=[235-53 809+47 1261+35];  %see document in D:\Data\Facility Instrumentation\Thermocouples called  blah blah positions
        distributions.coolant_temp_180deg.position_y=distributions.coolant_temp_0deg.position_y; % for the rest see sensor_positioning.idw
        distributions.outer_wall_temp_0deg.position_y=[-28.5 160 582 884 1186 1380];
        distributions.outer_wall_temp_180deg.position_y=distributions.outer_wall_temp_0deg.position_y;

        % these can be just copied, as they are in the same spots
        % previously described
        distributions.wall_inner.position_y=distributions.GHFS_TC.position_y;
        distributions.wall_outer.position_y=distributions.GHFS_TC.position_y;
        distributions.wall_dT.position_y=distributions.GHFS_TC.position_y;  %positions with reference to the bottom of the test tube everywhere!!!!
        

        %geometry - horizontal distribution of sensors
        if MP_flag
            if forward_flag
                distributions.MP_forward_temp.position_x=MP_Temp_averaged.forward(:,1);
                distributions.MP_forward_temp_smooth.position_x=MP_Temp_averaged.forward(:,1);
                distributions.MP_forward_partpress_h2o.position_x=MP_Temp_averaged.forward(:,1);
                distributions.MP_forward_molefr_h2o.position_x=MP_Temp_averaged.forward(:,1);
                distributions.MP_forward_MP1.position_x=MP_Temp_averaged.forward(:,1);
                distributions.MP_forward_MP2.position_x=MP_Temp_averaged.forward(:,1);
                distributions.MP_forward_MP3.position_x=MP_Temp_averaged.forward(:,1);
                distributions.MP_forward_MP4.position_x=MP_Temp_averaged.forward(:,1);
                
            end
            if backward_flag
                distributions.MP_backward_temp.position_x=MP_Temp_averaged.backward(:,1);
                distributions.MP_backward_temp_smooth.position_x=MP_Temp_averaged.backward(:,1);
                distributions.MP_backward_partpress_h2o.position_x=MP_Temp_averaged.backward(:,1);
                distributions.MP_backward_molefr_h2o.position_x=MP_Temp_averaged.backward(:,1);
                distributions.MP_backward_MP1.position_x=MP_Temp_averaged.backward(:,1);
                distributions.MP_backward_MP2.position_x=MP_Temp_averaged.backward(:,1);
                distributions.MP_backward_MP3.position_x=MP_Temp_averaged.backward(:,1);
                distributions.MP_backward_MP4.position_x=MP_Temp_averaged.backward(:,1);
            end 
        end
        
        distributions.coolant_temp_0deg.position_x=ones(length(distributions.coolant_temp_0deg.value.cal),1)*36.07;           %in the middle of the coolant channel
        distributions.coolant_temp_180deg.position_x=ones(length(distributions.coolant_temp_180deg.value.cal),1)*36.07;         %in the middle of the coolant channel
        distributions.outer_wall_temp_0deg.position_x=ones(length(distributions.outer_wall_temp_0deg.value.cal),1)*114.3/2;      %DN100 tube
        distributions.outer_wall_temp_180deg.position_x=ones(length(distributions.outer_wall_temp_180deg.value.cal),1)*114.3/2;    %DN100 tube
        if centerline_flag~=0
            distributions.centerline_temp.position_x=zeros(length(distributions.centerline_temp.value.cal),1);                %tube center - easy
            distributions.centerline_molefr_h2o.position_x=distributions.centerline_temp.position_x;
            distributions.centerline_partpress_h2o.position_x=distributions.centerline_temp.position_x;
            distributions.centerline_molefr_NC.position_x=distributions.centerline_temp.position_x;
        end
       % if GHFS_TC_flag~=0
            distributions.GHFS_TC.position_x=ones(length(distributions.GHFS_TC.value.non_cal),1)*12.5;                      %inner tube wal diam
       % end
        if wall_inner_flag~=0
            distributions.wall_inner.position_x=ones(length(distributions.wall_inner.value.cal),1)*13.5;                   %estimate
        end
        try
            distributions.wall_outer.position_x=ones(length(distributions.wall_outer.value.cal),1)*15;                     %tube wall is 30mm
        catch
        end
        try
            distributions.wall_dT.position_x=ones(length(distributions.wall_dT.value.cal),1)*(15+12.5)/2;               %middle of the inner tube wall
        catch
        end
        

        %% Temperature distribution derivatives
        if centerline_flag
            mixing_zone=centerline_derivs(distributions.centerline_temp);
            steam.mixing_zone_length.value=mixing_zone.length_max;
            
            steam.mixing_zone_start.value=mixing_zone.start;
            steam.mixing_zone_end.value=mixing_zone.end;
            steam.mixing_zone_length.error=mixing_zone.length_error;
            steam.mixing_zone_start.error=mixing_zone.start_error;
            steam.mixing_zone_end.error=mixing_zone.end_error;
            
            steam.mixing_zone_lengthInt.value=mixing_zone.lengthInt_max;
            steam.mixing_zone_startInt.value=mixing_zone.startInt;
            steam.mixing_zone_endInt.value=mixing_zone.endInt;
            
            steam.mixing_zone_lengthInt.error=mixing_zone.lengthInt_error;
            steam.mixing_zone_startInt.error=mixing_zone.startInt_error;
            steam.mixing_zone_endInt.error=mixing_zone.endInt_error;            
            
            % calculate mflux based on steam power
            steam.mFlux.value=steam.mflow.value/(pi*0.02*(steam.mixing_zone_start.value+steam.mixing_zone_end.value)/2);
            % total heat transmitted through wall based on GHFS and dT
            GHFS.total_HF_dT.value=wall_heatflow([GHFS.wall_heatflux_GHFS1.value,GHFS.wall_heatflux_GHFS2.value,GHFS.wall_heatflux_GHFS3.value,GHFS.wall_heatflux_GHFS4.value],[220 420 670 920],steam.mixing_zone_start.value);
            GHFS.total_HF_GHFS.value=wall_heatflow([GHFS.GHFS1.value,GHFS.GHFS2.value,GHFS.GHFS3.value,GHFS.GHFS4.value],[220 420 670 920],steam.mixing_zone_start.value);
            GHFS.total_mflow_dT.value=GHFS.total_HF_dT.value/steam.evap_heat.value;
            GHFS.total_mflow_GHFS.value=GHFS.total_HF_GHFS.value/steam.evap_heat.value;
        end
        
        %% DEFINE ERRORS ==============================================================================================================
        disp('4. Calculating measurement errors')
        %coolant - measured values
        coolant.vflow.error=error_volflow(coolant.vflow.value);
        coolant.temp.error=error_PT100; %function call
        coolant.temp_inlet.error=error_PT100;
        coolant.temp_outlet.error=error_PT100;
        [coolant.press.error,~]=error_press(coolant.press.value);
        coolant.temp_inlet_TC.error=0.05;
        coolant.temp_outlet_TC.error=0.05;
        %coolant - recalculated values
        coolant.dT.error =error_dT(coolant.temp.error );
        coolant.dT_TC.error=sqrt(coolant.temp_inlet_TC.error^2+coolant.temp_outlet_TC.error^2);
        coolant.dens.error =error_dens(coolant.temp.value,coolant.press.value,coolant.temp.error ,coolant.press.error );
        coolant.mflow.error =error_mflow(coolant.dens.error ,coolant.vflow.error ,coolant.dens.value,coolant.vflow.value,coolant.mflow.value);
        coolant.enthalpy.error = error_IAPWS_custom('h_pT',coolant.press.value/10,coolant.press.error/10,coolant.temp.value+273.15,coolant.temp.error);
        coolant.spec_heat.error = error_IAPWS_custom('cp_ph',coolant.press.value/10,coolant.press.error/10,coolant.enthalpy.value,coolant.enthalpy.error);
        coolant.power.error =error_coolantpower(coolant.mflow.value,coolant.spec_heat.value,coolant.dT.value,coolant.power.value,coolant.mflow.error ,coolant.spec_heat.error ,coolant.dT.error );
        coolant.power_TC.error=error_coolantpower(coolant.mflow.value,coolant.spec_heat.value,coolant.dT_TC.value,coolant.power.value,coolant.mflow.error ,coolant.spec_heat.error ,coolant.dT_TC.error );
        coolant.power_Offset.error=coolant.power.error;
        coolant.power_TC_Offset.error=coolant.power_TC.error;
        coolant.dynvis.error = error_IAPWS_custom('mu_pT',coolant.press.value/10,coolant.press.error/10,coolant.temp.value+273.15,coolant.temp.error);
        coolant.kinvis.error =coolant.kinvis.value*error_custom(coolant.dynvis.value,coolant.dynvis.error,coolant.dens.value,coolant.dens.error);
        coolant.thermcond.error =error_IAPWS_custom('k_pT',coolant.press.value/10,coolant.press.error/10,coolant.temp.value+273.15,coolant.temp.error);
        coolant.prandtl.error =coolant.prandtl.value*error_custom(coolant.spec_heat.value,coolant.spec_heat.error,coolant.dynvis.value,coolant.dynvis.error,coolant.thermcond.value,coolant.thermcond.error);
        coolant.velocity.error =sqrt((coolant.vflow.error/coolant.vflow.value)^2+(0.0001/0.021)^2+(0.0001/0.021)^2)*coolant.velocity.value;
        coolant.reynolds.error =coolant.reynolds.value*0.0791*error_custom(coolant.velocity.value,coolant.velocity.error,coolant.dens.value,coolant.dens.error,coolant.dynvis.value,coolant.dynvis.error);
        coolant.htc_dittusBoelter.error = coolant.htc_dittusBoelter.value*0.0023/0.0791*error_custom(coolant.reynolds.value,coolant.reynolds.error,coolant.prandtl.value,coolant.prandtl.error,coolant.thermcond.value,coolant.thermcond.error);
        coolant.htc_gnielinski.error = error_gnielinski(coolant.reynolds.value,coolant.reynolds.error,coolant.thermcond.value,coolant.thermcond.error,coolant.prandtl.value,coolant.prandtl.error,0.0791,0.002);
        coolant.htc_laminar.error =7.37*coolant.thermcond.error/0.0791;
         if coolant.reynolds.value>2300
            coolant.htc.error=coolant.htc_gnielinski.error;
        else
            coolant.htc.error=coolant.htc_laminar.error;
         end
         
        %steam - measured values
        [steam.press.error,~]=error_press(steam.press.value);
        [steam.pressPartEst.error,~]=error_press(steam.press.value);
        [steam.pressPart.error,~]=error_press(steam.press.value);
        steam.temp.error=error_PT100;
        steam.press_init.error=steam.press.error;
        steam.temp_init.error=steam.temp.error;      
        steam.heater_temp.error=error_PT100;
        
        %steam thermocouple centerline
         %steam side thermocouples - centerline
        TCerror=1.0006;
        steam.TF9603.error=TCerror;
        steam.TF9604.error=TCerror;
        steam.TF9605.error=TCerror;
        steam.TF9606.error=TCerror;
        steam.TF9607.error=TCerror;
        steam.TF9608.error=TCerror;
        steam.TF9609.error=TCerror;
        steam.TF9610.error=TCerror;
        steam.TF9611.error=TCerror;
        steam.TF9612.error=TCerror;
        steam.TF9613.error=TCerror;
        steam.TF9614.error=TCerror;
        
        %steam - recalculated values  
        %%
        steam.boiling_point.error = error_IAPWS_custom('Tsat_p',coolant.press.value/10,coolant.press.error/10);
        steam.enthalpy.error =error_IAPWS_custom('hV_p',coolant.press.value/10,coolant.press.error/10);
        steam.enthalpy_liquid.error =error_IAPWS_custom('hL_p',coolant.press.value/10,coolant.press.error/10);
        steam.evap_heat.error =sqrt(steam.enthalpy.error^2+steam.enthalpy_liquid.error^2)*1000;
        steam.power.error =error_steam_power(mean(230),mean(calibratedData.HE9601_I),steam.power.value);  %XXXXXXXXXXXXXXXXXXX
        steam.powerOffset.error=error_steam_power(mean(230),mean(calibratedData.HE9601_I),steam.powerOffset.value);
        steam.mflow.error =error_mflow_steam(steam.power.value,steam.evap_heat.value,steam.mflow.value,steam.power.error ,steam.evap_heat.error );
        if centerline_flag
            steam.mFlux.error=sqrt((steam.mflow.error/steam.mflow.value)^2+(steam.mixing_zone_start.error/steam.mixing_zone_start.value)^2+(steam.mixing_zone_end.error/steam.mixing_zone_end.value)^2)*steam.mFlux.value;
        end
        steam.density.error =error_dens(steam.temp.value,steam.press.value,steam.temp.error ,steam.press.error );
        steam.vflow.error =error_volflow_steam(steam.vflow.value,steam.mflow.value,steam.density.value,steam.mflow.error ,steam.density.error );
        steam.velocity.error =error_velocity(steam.velocity.value,steam.vflow.value,(pi*(0.021/2)^2),steam.vflow.error,0);
       
        
        %facility - calculated values only
        facility.wall_dT.error=error_dT(TCerror);
        facility.powerOffset.error=1;
        facility.powerOffset_TC.error=1;
        facility.heat_losses.error=sqrt(steam.power.error^2+coolant.power.error^2);
        facility.heat_losses_TC.error=sqrt(steam.power.error^2+coolant.power_TC.error^2);
        facility.dT_losses.error=sqrt((sqrt(facility.heat_losses.error^2+coolant.power.error^2)/(facility.heat_losses.value+coolant.power.value))^2+(coolant.mflow.error/coolant.mflow.value)^2+(coolant.spec_heat.error/coolant.spec_heat.value)^2)*facility.dT_losses.value;
        facility.wallThermcond.error=sqrt(2*TCerror^2)*0.0117;
        facility.wall_htc.error=sqrt(facility.wallThermcond.error^2+3*0.0005^2);
        facility.wall_heatflux_dT.error=error_wall_heatflux(facility.wall_heatflux_dT.value,facility.wall_htc.value,facility.wall_dT.value,facility.wall_htc.error ,facility.wall_dT.error );
        facility.wall_heatflow_dT.error=error_wall_heatflow(facility.wall_heatflow_dT.value,facility.wall_heatflux_dT.value,facility.wall_heatflux_dT.error );
        facility.wall_heatflux_powerbased.error=steam.power.error/(pi*0.02*1.3);
        %         facility.voltage.error=1;
        facility.current.error=1;
        [facility.NCtank_press.error,~]=error_press(facility.NCtank_press.value);
        facility.NCtank_temp.error=error_PT100;
        
         % GHFS - errors
        if  fast_flag==1
            [GHFS.GHFS1_raw.error,~]=error_DAS_m9215(GHFS.GHFS1_raw.value);
            [GHFS.GHFS2_raw.error,~]=error_DAS_m9215(GHFS.GHFS2_raw.value);
            [GHFS.GHFS3_raw.error,~]=error_DAS_m9215(GHFS.GHFS3_raw.value);
            [GHFS.GHFS4_raw.error,~]=error_DAS_m9215(GHFS.GHFS4_raw.value);
            
            GHFS.GHFS1_offset_raw.error=GHFS.GHFS1_raw.error;
            GHFS.GHFS2_offset_raw.error=GHFS.GHFS2_raw.error;
            GHFS.GHFS3_offset_raw.error=GHFS.GHFS3_raw.error;
            GHFS.GHFS4_offset_raw.error=GHFS.GHFS4_raw.error;
            
            GHFS.GHFS1_temp.error=TCerror;
            GHFS.GHFS2_temp.error=TCerror;
            GHFS.GHFS3_temp.error=TCerror;
            GHFS.GHFS4_temp.error=TCerror;
            
            GHFS.wall_dT_GHFS1.error=error_dT(GHFS.GHFS1_temp.error);
            GHFS.wall_dT_GHFS2.error=error_dT(GHFS.GHFS2_temp.error);
            GHFS.wall_dT_GHFS3.error=error_dT(GHFS.GHFS3_temp.error);
            GHFS.wall_dT_GHFS4.error=error_dT(GHFS.GHFS4_temp.error);
            
            GHFS.GHFS1.error=error_GHFS(GHFS.GHFS1.value,GHFS.GHFS1_raw.value);
            GHFS.GHFS2.error=error_GHFS(GHFS.GHFS2.value,GHFS.GHFS2_raw.value);
            GHFS.GHFS3.error=error_GHFS(GHFS.GHFS3.value,GHFS.GHFS3_raw.value);
            GHFS.GHFS4.error=error_GHFS(GHFS.GHFS4.value,GHFS.GHFS4_raw.value);
            
            GHFS.wall_heatflux_GHFS1.error=error_wall_heatflux_GHFS(GHFS.wall_heatflux_GHFS1.value,facility.wall_htc.value,GHFS.wall_dT_GHFS1.value,facility.wall_htc.error ,GHFS.wall_dT_GHFS1.error );
            GHFS.wall_heatflux_GHFS2.error=error_wall_heatflux_GHFS(GHFS.wall_heatflux_GHFS2.value,facility.wall_htc.value,GHFS.wall_dT_GHFS2.value,facility.wall_htc.error ,GHFS.wall_dT_GHFS2.error );
            GHFS.wall_heatflux_GHFS3.error=error_wall_heatflux_GHFS(GHFS.wall_heatflux_GHFS3.value,facility.wall_htc.value,GHFS.wall_dT_GHFS3.value,facility.wall_htc.error ,GHFS.wall_dT_GHFS3.error );
            GHFS.wall_heatflux_GHFS4.error=error_wall_heatflux_GHFS(GHFS.wall_heatflux_GHFS4.value,facility.wall_htc.value,GHFS.wall_dT_GHFS4.value,facility.wall_htc.error ,GHFS.wall_dT_GHFS4.error );
            
            GHFS.total_HF_dT.error=0;  %XXXXXXXXXXXXXXXXXXX 
            GHFS.total_HF_GHFS.error=0;  %XXXXXXXXXXXXXXXXXXX 
            GHFS.total_mflow_dT.error=0;
            GHFS.total_mflow_GHFS.error=0;
            
            GHFS.GHFS1sens.error=0;
            GHFS.GHFS2sens.error=0;
            GHFS.GHFS3sens.error=0;
            GHFS.GHFS4sens.error=0;
            
            GHFS.GHFS1sensCALC.error=0;
            GHFS.GHFS2sensCALC.error=0;
            GHFS.GHFS3sensCALC.error=0;
            GHFS.GHFS4sensCALC.error=0;

            % MP - errors
            MP.MP1.error=0.002*MP.MP1.value;
            MP.MP1_filmthick.error=0.002*MP.MP1_filmthick.value;
            MP.MP2.error=0.002*MP.MP2.value;
            MP.MP3.error=0.002*MP.MP3.value;
            MP.MP4.error=0.002*MP.MP4.value;
        end
        
        if MP_flag
            MP.Pos.error=0.1;  % [mm]
            MP.Temp.error=0.1;
            MP.Temp_smooth.error=0.1;
            MP.T_boundlayer_forward.error=MP.Pos.error;  %0.1
            MP.T_boundlayer_backward.error=MP.Pos.error; %XXXXXXXXXXXXXXXXXXX  
            MP.T_boundlayer_mean.error=MP.Pos.error;
        end
        
        % Distribution errors
        distributions.GHFS_TC.error=0.05;       
        distributions.MP_backward_molefr_h2o.error=1; %XXXXXXXXXXXXXXXXXXX 
        distributions.MP_backward_partpress_h2o.error=1; %XXXXXXXXXXXXXXXXXXX 
        distributions.MP_backward_temp.error=0.05;
        distributions.MP_forward_molefr_h2o.error=1; %XXXXXXXXXXXXXXXXXXX 
        distributions.MP_forward_partpress_h2o.error=1;%XXXXXXXXXXXXXXXXXXX 
        distributions.MP_forward_temp.error=0.05;
        distributions.MP_backward_temp_smooth.error=0.05;
        distributions.MP_forward_temp_smooth.error=0.05;
        distributions.centerline_molefr_h2o.error=1;%XXXXXXXXXXXXXXXXXXX 
        distributions.centerline_molefr_NC.error=1;%XXXXXXXXXXXXXXXXXXX 
        distributions.centerline_NC_moles_per_height.error=1;%XXXXXXXXXXXXXXXXXXX 
        distributions.centerline_partpress_h2o.error=1;%XXXXXXXXXXXXXXXXXXX 
        distributions.centerline_temp.error=0.05;
        distributions.coolant_temp_0deg.error=0.05;
        distributions.coolant_temp_180deg.error=0.05;
        distributions.outer_wall_temp_0deg.error=0.05;
        distributions.outer_wall_temp_180deg.error=0.05;
        distributions.wall_dT.error=0.05;
        distributions.wall_inner.error=0.05;
        distributions.wall_outer.error=0.05;
        distributions.MP_forward_MP1.error=MP.MP1.error;
        distributions.MP_backward_MP1.error=MP.MP1.error;
        distributions.MP_forward_MP2.error=MP.MP2.error;
        distributions.MP_backward_MP2.error=MP.MP2.error;
        distributions.MP_forward_MP3.error=MP.MP3.error;
        distributions.MP_backward_MP3.error=MP.MP3.error;
        distributions.MP_forward_MP4.error=MP.MP4.error;
        distributions.MP_backward_MP4.error=MP.MP4.error;
        
            
                 
        %% NC gases ==============================================================================================================
        %  values and errors
        try
            % values
            [NC.N2_inNC_mfrac.value,NC.N2_inNC_mfrac.error,steam.molefraction.value,NC.N2_molefraction.value,NC.He_molefraction.value,steam.molefraction.error,...
                NC.N2_molefraction.error,NC.He_molefraction.error,NC.N2_molefraction_init.value,NC.He_molefraction_init.value,steam.press_init.value,steam.temp_init.value...
                ,NC.moles_h2o_test.value,NC.moles_N2_test.value,NC.moles_He_test.value,NC.moles_N2_test.error,NC.moles_He_test.error]=...
                NC_filling(steam.press.value,steam.temp.value,steam.press.error,steam.temp.error,file,eos_type);
            steam.moleFr_660.error=steam.molefraction.error;
            NC.NC_molefraction.value=NC.N2_molefraction.value + NC.He_molefraction.value;
            NC.moles_total_init.value=NC.moles_N2_test.value+NC.moles_He_test.value;
            steam.pressPart.value=steam.press.value.*(1-NC.NC_molefraction.value);
            % estimate tube length occupied by NC mixture, based on NC moles estimate calculated with recorded temperature
            %initialize
            NC.moles_total_est.value=0;

            if centerline_flag~=0
                for molefr_ctr=1:numel(distributions.centerline_temp.value.cal)
                    distributions.centerline_NC_moles_per_height.value.cal(molefr_ctr)=NC_moles_estimate(distributions.centerline_temp.value.cal(molefr_ctr)+273.15,steam.press.value,distributions.centerline_molefr_NC.value.cal(molefr_ctr),NC.moles_N2_test.value,NC.moles_He_test.value,NC.moles_total_init.value,eos_type);  
                end

                for mole_ctr=1:numel(distributions.centerline_temp.value.cal)-1
                    distance=(distributions.centerline_temp.position_y(mole_ctr+1)-distributions.centerline_temp.position_y(mole_ctr))/1000;  %divide by 1000 to convert mm to m
                    %trapezoid (a+b)*h/2 a = value at mole_ctr b = value at mole_ctr+1 h = distance
                    NC.moles_total_est.value=NC.moles_total_est.value+(distributions.centerline_NC_moles_per_height.value.cal(mole_ctr+1)+distributions.centerline_NC_moles_per_height.value.cal(mole_ctr))*distance/2;  %sum all the calculated NC moles from temperatures
                end
            end

            %get NC mole fraction based on mole amount based on estimation
            NC.NC_molefraction_est.value=NC.moles_total_est.value/(NC.moles_total_init.value+NC.moles_h2o_test.value);
            steam.pressPartEst.value=steam.press.value.*(1-NC.NC_molefraction_est.value);
            NC.NC_molefraction_est.error=NC.NC_molefraction_est.value*sqrt((steam.mixing_zone_start.error/steam.mixing_zone_start.value)^2+(steam.press.error/steam.press.value)^2+(steam.temp.error/steam.temp.value)^2);  % &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
            % estimate tube length occupied by NC mixture, based on initial conditions estimate of total NC moles
            NC.length_init.value=length_NC(coolant.temp.value+273.15,steam.press.value,distributions.centerline_molefr_h2o.value.cal(end),NC.moles_N2_test.value,NC.moles_He_test.value,NC.moles_total_init.value,eos_type);      
            % and based on deduced amount of NC moles from temeprature measurements
            NC.length_est.value=length_NC(coolant.temp.value+273.15,steam.press.value,distributions.centerline_molefr_h2o.value.cal(end),NC.moles_N2_test.value,NC.moles_He_test.value,NC.moles_total_est.value,eos_type);      


%             facility.wall_heatflux_powerbased.value=steam.powerOffset.value/(pi*0.02*1.3); %delivered power over tube area
            facility.wall_heatflux_powerbased.value=steam.power.value/(pi*0.02*(1.3-NC.length_est.value)); %delivered power over tube area

            %errors
            NC.N2_molefraction_init.error=NC.N2_molefraction.error;
            NC.He_molefraction_init.error=NC.He_molefraction.error;
            NC.NC_molefraction.error=NC.N2_molefraction.error;  
            NC.moles_total_init.error=NC.moles_N2_test.error+NC.moles_He_test.error;
            NC.moles_total_est.error=1; %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            try   %try because in old recordings there is no TF9603
                NC.length_init.error=error_NC_length(NC.length_init.value,NC.moles_total_init.value,mean(calibratedData.TF9603)+273.15,steam.press.value*10^5,NC.moles_total_init.error,0.05,steam.press.error*10^5);  %*10^5 so it's in pascal
                NC.length_est.error=error_NC_length(NC.length_init.value,NC.moles_total_est.value,mean(calibratedData.TF9603)+273.15,steam.press.value*10^5,NC.moles_total_est.error,0.05,steam.press.error*10^5);  %*10^5 so it's in pascal
            catch
            end

            %distributions
            distributions.NC_length_init.position_y=[1,1330-NC.length_init.value*1000-1,1330-NC.length_init.value*1000,1330];
            distributions.NC_length_init.position_x=zeros(numel(distributions.NC_length_init.position_y),1);
            distributions.NC_length_est.position_y=[1,1330-NC.length_est.value*1000-1,1330-NC.length_est.value*1000,1330];
            distributions.NC_length_est.position_x=zeros(numel(distributions.NC_length_est.position_y),1);
            distributions.centerline_NC_moles_per_height.position_y=distributions.centerline_molefr_NC.position_y;
            distributions.centerline_NC_moles_per_height.position_x=distributions.centerline_molefr_NC.position_x;
            try
                distributions.NC_length_init.error=NC.length_init.error;
                distributions.NC_length_est.error=NC.length_est.error; 
            catch

            end
            distributions.NC_length_init.value.cal=[0,0,1,1];
            distributions.NC_length_est.value.cal=[0,0,1,1];

            % compare assumed values and actual values of NC moles in the
            % facility
            file.NCratio=NC.moles_total_est.value/NC.moles_total_init.value; %this value is used to figure out if the recording has any value at all
        catch
            disp('stupid old file')
        end
        %% Boundary conditions ==============================================================================================================
        %  values and errors
        
        %Boundary conditions -values
        BC.Wall_dT.value=facility.wall_dT.value;
        BC.Coolant_flow.value=coolant.mflow.value;
        BC.Coolant_temp.value=coolant.temp.value;
        BC.Steam_pressure.value=steam.press.value;
        BC.NC_molefraction.value=NC.NC_molefraction.value;
        BC.He_molefraction.value=NC.He_molefraction.value;
        BC.N2_molefraction.value=NC.N2_molefraction.value;

        %Boundary conditions - errors
        BC.Wall_dT.error=facility.wall_dT.error;
        BC.Coolant_flow.error=coolant.mflow.error;
        BC.Coolant_temp.error=coolant.temp.error;
        BC.Steam_pressure.error=steam.press.error;
        try
            BC.NC_molefraction.error=NC.NC_molefraction.error;
            BC.He_molefraction.error=NC.He_molefraction.error;
            BC.N2_molefraction.error=NC.N2_molefraction.error;
        catch
        end

       
        %% ADD UNITS
        disp('5. Adding measurments units')
        % coolant thermodynamic conditions - measured               
        coolant.vflow.unit='m3/h';     
        coolant.temp.unit=[char(176),'C']; 
        coolant.press.unit='bar';   
        coolant.temp_inlet.unit=[char(176),'C']; 
        coolant.temp_outlet.unit=[char(176),'C']; 
        coolant.temp_inlet_TC.unit=[char(176),'C'];
        coolant.temp_outlet_TC.unit=[char(176),'C'];

        % coolant properties - calculated (some with IAPWS_IF97)
        coolant.dT.unit=[char(176),'C']; 
        coolant.dT_TC.unit=[char(176),'C']; 
        coolant.dens.unit='kg/m3'; %take inversion, cause IAPWS calcualtes specific volume (m3/kg)
        coolant.mflow.unit='kg/h'; 
        coolant.enthalpy.unit='kJ/kg'; 
        coolant.spec_heat.unit='J/(kg*K)'; %multiply by 1000 so unit is J/kg*K
        coolant.power.unit='W'; 
        coolant.power_Offset.unit='W';
        coolant.power_TC_Offset.unit='W';
        coolant.power_TC.unit='W'; 
        coolant.dynvis.unit='Pa*s'; 
        coolant.kinvis.unit='m2/s'; 
        coolant.thermcond.unit='W/(m*K)'; 
        coolant.prandtl.unit='1'; 
        coolant.velocity.unit='m/s'; %flow area = 0.008641587 m2
        coolant.reynolds.unit='1'; % hydraulic diameter of the annulus = 0.0791 m
        coolant.htc_dittusBoelter.unit='W/(m2*K)'; 
        coolant.htc_gnielinski.unit='W/(m2*K)'; 
        coolant.htc_laminar.unit='W/(m2*K)';
        coolant.htc.unit='W/(m2*K)';

        % steam side thermodynamic codnitions - measured
        steam.press.unit='bar'; 
        steam.pressPartEst.unit='bar'; 
        steam.pressPart.unit='bar'; 
        steam.press_init.unit='bar';
        steam.temp_init.unit='C';
        steam.power.unit='W'; 
        steam.powerOffset.unit='W';  
        steam.temp.unit=[char(176),'C']; 
        steam.heater_temp.unit=[char(176),'C']; 
        
        %steam side thermocouples centerline
        steam.TF9603.unit=[char(176),'C']; 
        steam.TF9604.unit=[char(176),'C']; 
        steam.TF9605.unit=[char(176),'C']; 
        steam.TF9606.unit=[char(176),'C']; 
        steam.TF9607.unit=[char(176),'C']; 
        steam.TF9608.unit=[char(176),'C']; 
        steam.TF9609.unit=[char(176),'C']; 
        steam.TF9610.unit=[char(176),'C']; 
        steam.TF9611.unit=[char(176),'C']; 
        steam.TF9612.unit=[char(176),'C']; 
        steam.TF9613.unit=[char(176),'C']; 
        steam.TF9614.unit=[char(176),'C']; 

        % steam properties - calculated (some with IAPWS_IF97)
        steam.boiling_point.unit=[char(176),'C']; 
        steam.density.unit='kg/m3'; 
        steam.enthalpy.unit='kJ/kg';   
        steam.enthalpy_liquid.unit='kJ/kg'; 
        steam.evap_heat.unit='J/kg';
        steam.mflow.unit='kg/s';  
        steam.mFlux.unit='kg/m^2s';
        steam.vflow.unit='m3/s'; 
        steam.velocity.unit='m/s';
        steam.mixing_zone_length.unit='mm';
        steam.mixing_zone_start.unit='mm';
        steam.mixing_zone_end.unit='mm';
        
        steam.mixing_zone_lengthInt.unit='mm';
        steam.mixing_zone_startInt.unit='mm';
        steam.mixing_zone_endInt.unit='mm';
        
    % steam - coolant interface - facility
        facility.wall_dT.unit=[char(176),'C']; 
        facility.powerOffset.unit='W';
        facility.powerOffset_TC.unit='W';
        facility.heat_losses.unit='W'; 
        facility.heat_losses_TC.unit='W'; 
        facility.dT_losses.unit=[char(176),'C'];
        facility.wallThermcond.unit='W/(m*K)';
        facility.wall_htc.unit='W/(m2*K)'; 
        facility.wall_heatflux_dT.unit='W/m2'; 
        facility.wall_heatflux_powerbased.unit='W/m2'; 
        facility.wall_heatflow_dT.unit='W'; 
%         facility.voltage.unit='V';
        facility.current.unit='A';
        facility.NCtank_press.unit='Bar';
        facility.NCtank_temp.unit=[char(176),'C']; 
        
    % NC mole fractions units
        NC.N2_inNC_mfrac.unit='1';
        steam.molefraction.unit='1';
        steam.moleFr_660.unit='1';
        NC.N2_molefraction.unit='1';
        NC.He_molefraction.unit='1';
        NC.NC_molefraction.unit='1';
        NC.N2_molefraction_init.unit='1';
        NC.He_molefraction_init.unit='1';
        NC.NC_molefraction_est.unit='1';
        %AAAAAAAAAAAAAAAAAAAAAAAAAAa
        NC.moles_h2o_test.error=1;  % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        NC.moles_h2o_test.unit='mol';
        NC.moles_N2_test.unit='mol';
        NC.moles_He_test.unit='mol';
        NC.moles_total_init.unit='mol';
        NC.moles_total_est.unit='mol';
        NC.length_init.unit='1';
        NC.length_est.unit='1';
        
        if  fast_flag
        % GHFS units
            GHFS.GHFS1_raw.unit='V';
            GHFS.GHFS2_raw.unit='V';
            GHFS.GHFS3_raw.unit='V';
            GHFS.GHFS4_raw.unit='V';
            
            GHFS.GHFS1_offset_raw.unit='V';
            GHFS.GHFS2_offset_raw.unit='V';
            GHFS.GHFS3_offset_raw.unit='V';
            GHFS.GHFS4_offset_raw.unit='V';
            
            GHFS.GHFS1_temp.unit=[char(176),'C'];
            GHFS.GHFS2_temp.unit=[char(176),'C'];
            GHFS.GHFS3_temp.unit=[char(176),'C'];
            GHFS.GHFS4_temp.unit=[char(176),'C'];
            
            GHFS.wall_dT_GHFS1.unit=[char(176),'C'];
            GHFS.wall_dT_GHFS2.unit=[char(176),'C'];
            GHFS.wall_dT_GHFS3.unit=[char(176),'C'];
            GHFS.wall_dT_GHFS4.unit=[char(176),'C'];
            
            GHFS.GHFS1.unit='W/m2';
            GHFS.GHFS2.unit='W/m2';
            GHFS.GHFS3.unit='W/m2';
            GHFS.GHFS4.unit='W/m2';
            
            GHFS.wall_heatflux_GHFS1.unit='W/m2';
            GHFS.wall_heatflux_GHFS2.unit='W/m2';
            GHFS.wall_heatflux_GHFS3.unit='W/m2';
            GHFS.wall_heatflux_GHFS4.unit='W/m2';
            
            GHFS.total_HF_dT.unit='W';
            GHFS.total_HF_GHFS.unit='W';
            GHFS.total_mflow_dT.unit='kg/s';
            GHFS.total_mflow_GHFS.unit='kg/s';
            
            GHFS.GHFS1sens.unit='V/W';
            GHFS.GHFS2sens.unit='V/W';
            GHFS.GHFS3sens.unit='V/W';
            GHFS.GHFS4sens.unit='V/W';
            
            GHFS.GHFS1sensCALC.unit='V/W';
            GHFS.GHFS2sensCALC.unit='V/W';
            GHFS.GHFS3sensCALC.unit='V/W';
            GHFS.GHFS4sensCALC.unit='V/W';
            
        % Movable probe units   
            MP.MP1.unit='V';
            MP.MP1_filmthick.unit='mm';
            MP.MP2.unit='V';
            MP.MP3.unit='V';
            MP.MP4.unit='V';
        end

        if MP_flag
            MP.Pos.unit='mm';
            MP.Temp.unit=[char(176),'C'];
            MP.Temp_smooth.unit=[char(176),'C'];
            MP.T_boundlayer_forward.unit='mm';
            MP.T_boundlayer_backward.unit='mm';
            MP.T_boundlayer_mean.unit='mm';
        end
        
    % BC units
       
        BC.Wall_dT.unit=facility.wall_dT.unit;
        BC.Coolant_flow.unit=coolant.mflow.unit;
        BC.Coolant_temp.unit=coolant.temp.unit;
        BC.Steam_pressure.unit=steam.press.unit;
        BC.NC_molefraction.unit=NC.NC_molefraction.unit;
        BC.He_molefraction.unit=NC.He_molefraction.unit;  
        BC.N2_molefraction.unit=NC.N2_molefraction.unit;
        
    % Distribution units
        distributions.GHFS_TC.unit=[char(176),'C'];
        distributions.MP_backward_molefr_h2o.unit='1';
        distributions.MP_backward_partpress_h2o.unit='bar';
        distributions.MP_backward_temp.unit=[char(176),'C'];
        distributions.MP_forward_molefr_h2o.unit=1;
        distributions.MP_forward_partpress_h2o.unit='bar';
        distributions.MP_forward_temp.unit=[char(176),'C'];
        distributions.MP_backward_temp_smooth.unit=[char(176),'C'];
        distributions.MP_forward_temp_smooth.unit=[char(176),'C'];
        distributions.centerline_molefr_h2o.unit='1';
        distributions.centerline_molefr_NC.unit='1';
        distributions.centerline_NC_moles_per_height.unit='mol/m';
        distributions.centerline_partpress_h2o.unit='bar';
        distributions.centerline_temp.unit=[char(176),'C'];
        distributions.coolant_temp_0deg.unit=[char(176),'C'];
        distributions.coolant_temp_180deg.unit=[char(176),'C'];
        distributions.outer_wall_temp_0deg.unit=[char(176),'C'];
        distributions.outer_wall_temp_180deg.unit=[char(176),'C'];
        distributions.wall_dT.unit=[char(176),'C'];
        distributions.wall_inner.unit=[char(176),'C'];
        distributions.wall_outer.unit=[char(176),'C'];
        distributions.NC_length_init.unit=1;
        distributions.NC_length_est.unit=1;
        distributions.MP_forward_MP1.unit=[char(176),'V'];
        distributions.MP_backward_MP1.unit=[char(176),'V'];
        distributions.MP_forward_MP2.unit=[char(176),'V'];
        distributions.MP_backward_MP2.unit=[char(176),'V'];
        distributions.MP_forward_MP3.unit=[char(176),'V'];
        distributions.MP_backward_MP3.unit=[char(176),'V'];
        distributions.MP_forward_MP4.unit=[char(176),'V'];
        distributions.MP_backward_MP4.unit=[char(176),'V'];

%% calculate standard deviations
        disp('6. Calculating standard deviations')
        paramList={'steam','coolant','facility','GHFS','MP'};
        
        %for the listed parameters, look through their fields,
        %identify if those fields contain subfield .var
        %and if yes, based on the time-varying values
        %calculate standard deviation, and store in new subfield .std
        for procCtr=1:numel(paramList)
            currParam=paramList{procCtr};
            vars=fieldnames(eval(currParam));

            for varCtr=1:numel(vars)
                currVar=vars{varCtr};
                subFields=fieldnames(eval([currParam,'.',currVar]));
                if any(ismember(subFields,'var'))
                   eval([currParam,'.',currVar,'.std=std(',currParam,'.',currVar,'.var);'])
                end
            end
        end
        
        %add st dev to centerline distribution
        try
            distributions.centerline_temp.std=[steam.TF9603.std,steam.TF9604.std,steam.TF9605.std,steam.TF9606.std,steam.TF9607.std,steam.TF9608.std,steam.TF9609.std,steam.TF9610.std,steam.TF9611.std,steam.TF9612.std,steam.TF9613.std,steam.TF9614.std];
        catch
        end
      
%% Analyze dynamic behaviour of NC mixing front only in continous injection tests

        if frontDynamics_flag
            disp('Calculating NC mixing front behaviour since no steady-state option was chosen')
            %calculate the onset of mixing front passage for every sensor
            av_window=1;

            
            pathPrint=[splitdir{1},'NCFrontPlot'];
            if ~exist(pathPrint,'dir')
                mkdir(pathPrint)
            end
            
            sensorList={'TF9603','TF9604','TF9605','TF9606','TF9608','TF9610','TF9611','TF9612','TF9613'}; %,'TF9614'};
            sensorPos=[220,320,420,520,670,820,920,1020,1120];%,1220];
            sensorDist=diff(sensorPos);
            colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

            for sensCntr=1:numel(sensorList)

                currSens=sensorList{sensCntr};
                currYData=steam.(currSens).var;
                smoothYData=smooth(currYData,10);
                
                yAmount=numel(currYData);
                % This part, based on variable name, assign appropriate period
                % (GHFS1, GHFS2, GHFS3, GHFS4, MP1, MP2, MP3, MP4 - fast period)
                % rest slow, but not MP_Pos, MP_Temp, GHFS1_temp etc
                if contains(currSens,'GHFS')
                    period=timing.fast;
                else
                    period=timing.slow;
                end

                currXData=period:period:yAmount*period;

                %call function that does the magic (based on bits and pieces from steady_state.m)
                [frontArrivalMiddle(sensCntr),frontArrivalDev(sensCntr),frontArrivalStart(sensCntr),frontArrivalEnd(sensCntr),frontDataTime{sensCntr}]=mixingFrontDynamics(smoothYData,currXData,av_window,currSens,pathPrint,file_list);
                
                             
            end
            
            h1=figure('visible','off');
            hold on
            for sensCntr=1:numel(sensorList)     
                plot(frontDataTime{sensCntr},'LineWidth',1,'Color',colorstring{sensCntr})    
            end
            title([file_list,' NC Front in time'],'interpreter', 'none')
            ylabel(['Temperature [',char(176),'C]'])
            xlabel('Residence time [s]')
            legend(sensorList)
            h1.Children(2).XLabel.FontWeight='bold';
            h1.Children(2).YLabel.FontWeight='bold';
            pathPrintName=[pathPrint,'\','NCFrontTIME_',file_list];
            saveas(h1,pathPrintName,'png')
            print(h1,pathPrintName,'-dmeta')
            close(h1)
            
%                 figure
%                 plot(difference(avCntr,:)) 
%                 avLeg{avCntr}=num2str(av_window(avCntr));
            %calculate time it takes for the front to travel from one
            %sensor to another
            frontArrivalMidDiff=-diff(frontArrivalMiddle);
            frontArrivalDevDiff=-diff(frontArrivalDev);
            frontArrivalStartDiff=-diff(frontArrivalStart);
            frontArrivalEndDiff=-diff(frontArrivalEnd);
            %fix zeros
            frontArrivalMidDiff(frontArrivalMidDiff==0)=1;
            frontArrivalDevDiff(frontArrivalDevDiff==0)=1;
            frontArrivalStartDiff(frontArrivalStartDiff==0)=1;
            frontArrivalEndDiff(frontArrivalEndDiff==0)=1;
            %based on the time and distnace between sensors estimate
            %velocity
            frontVelMid=sensorDist./frontArrivalMidDiff;
            frontVelDev=sensorDist./frontArrivalDevDiff;
            frontVelSt=sensorDist./frontArrivalStartDiff;
            frontVelEnd=sensorDist./frontArrivalEndDiff;

            frontVelAvg=(frontVelMid+frontVelDev+frontVelSt+frontVelEnd)./4;

%             figure
%             hold on
%             plot(frontVelMid)
%             plot(frontVelDev)
%             plot(frontVelSt)
%             plot(frontVelEnd)
%             plot(frontVelAvg)
%             title('NC front velocities based on different parameters')
%             ylabel('Velocity mm/s')
%             xlabel('Sensor')
%             legend('Mid','Dev','St','End','Avg');

            %add one velocity for last / first sensor
            frontVelAvg(end+1)=frontVelAvg(end);
            
            %get NC front size in time as seen by the sensor
            frontResidenceTime=frontArrivalEnd-frontArrivalStart;
            %convert time to mm, based on estimated front velocity
            frontSize=abs(round(frontResidenceTime.*frontVelAvg)); %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
            
            h2=figure('Visible','off');
            title(file_list)
            hold on
            s1=subplot(3,1,1);
            plot(sensorPos,frontVelAvg,'.','MarkerSize',14,'Color',colorstring{1})
%             title('NC front velocities based on different parameters')
            ylabel('Velocity [mm/s]')
%             xlabel('Sensor')
            s1.XLabel.FontWeight='bold';
            s1.YLabel.FontWeight='bold';
            
            s2=subplot(3,1,2);
            plot(sensorPos,frontResidenceTime,'.','MarkerSize',14,'Color',colorstring{2})
%             title('Front residence time per sensor')
            ylabel('Residence time [s]')
%             xlabel('Sensor')
            s2.XLabel.FontWeight='bold';
            s2.YLabel.FontWeight='bold';
            
            s3=subplot(3,1,3);
            plot(sensorPos,frontSize,'.','MarkerSize',14,'Color',colorstring{3})
%             title('Front Size in mm per sensor')
            ylabel('Mixing length [mm]')
            xlabel('Sensor vertical position [mm]')
            h2.Position=[403 -100 660 820];
            pathPrintName=[pathPrint,'\','FrontDetails_',file_list];
            s3.XLabel.FontWeight='bold';
            s3.YLabel.FontWeight='bold';
            
            h2.Position=[ 403,  100,   560,   520];
            saveas(h2,pathPrintName,'png')   
            print(h2,pathPrintName,'-dmeta')
            close(h2)
            
            %store for later processing
            steam.contInj.vel=frontVelAvg;
            steam.contInj.restTme=frontResidenceTime;
            steam.contInj.mixL=frontSize;
            %resample front data to fit virtual length coordinates
            h3=figure('visible','off');
            hold on
%             h4=figure('visible','off');
%             hold on
%% mixing zone in temperature
            for frontCntr=1:numel(frontSize)
                currSens=sensorList{frontCntr};
                currYData=steam.(currSens).var;
                %get stds of front
                frontStd(frontCntr)=mean(movstd(frontDataTime{frontCntr},round(numel(frontDataTime{frontCntr})/20)));%/mean(frontDataTime{frontCntr}));

                %add padding to get right of edge effects
                set(0, 'CurrentFigure', h3)
                x=frontDataTime{frontCntr}';
                padding=30;
                dataPad=[repmat(x(1), 1, padding), x, repmat(x(end), 1, padding) ];

                resampledDataPad=resample(dataPad,frontSize(frontCntr), numel(x));
                padding_mod=ceil(padding*frontSize(frontCntr)/numel(x));
                frontDataEulerian{frontCntr}=resampledDataPad(padding_mod+1:end-padding_mod);
                steam.contInj.frontData{frontCntr}=currYData(frontArrivalStart(frontCntr):frontArrivalEnd(frontCntr));
                steam.contInj.frontArriv{frontCntr}=frontArrivalStart(frontCntr);
                steam.contInj.frontDep{frontCntr}=frontArrivalEnd(frontCntr);
                %padding distorts final data by 1 mm shortening
                %sometimes
                plot(frontDataEulerian{frontCntr},'LineWidth',1,'Color',colorstring{frontCntr})
                
                steam.(['mixFront_',sensorList{frontCntr}]).value=frontSize(frontCntr);
                steam.(['mixFront_',sensorList{frontCntr}]).var=frontDataEulerian{frontCntr};
                steam.(['mixFront_',sensorList{frontCntr}]).error=1;
                steam.(['mixFront_',sensorList{frontCntr}]).unit='various';
                
            end
            legend(sensorList)
%             title([file_list,' NC Front in mm'],'interpreter', 'none')
            ylabel(['Temperature [',char(176),'C]'])
            xlabel('Length [mm]')
            box on
            xlim([0 400])
            h3.Children(2).XLabel.FontWeight='bold';
            h3.Children(2).YLabel.FontWeight='bold';
            pathPrintName=[pathPrint,'\','NCFrontLENGTH_',file_list];
            saveas(h3,pathPrintName,'png')
            print(h3,pathPrintName,'-dmeta')
            close(h3)
%% mixing zone in heat flux
            hHFS=figure('Visible','off');
            hold on
            hfsSensorList={'GHFS1','GHFS2','GHFS3','GHFS4'};
            frontList=[1,3,5,7]; % corresponds to locations of GHFS 
            for frHFS=1:numel(hfsSensorList)
                currSens=hfsSensorList{frHFS};
                currFront=frontList(frHFS);
                currYData=GHFS.(currSens).var;
                %get stds of front
%                 frontStd(frontCntr)=mean(movstd(frontDataTime{frontCntr},round(numel(frontDataTime{frontCntr})/20)));%/mean(frontDataTime{frontCntr}));

                %add padding to get right of edge effects
                set(0, 'CurrentFigure', hHFS)
                x=currYData(frontArrivalStart(currFront)/timing.fast:frontArrivalEnd(currFront)/timing.fast);
                padding=30/timing.fast;
                dataPad=[repmat(x(1), 1, padding), x', repmat(x(end), 1, padding) ];

                resampledDataPad=resample(dataPad,frontSize(currFront), numel(dataPad));
                padding_mod=ceil(padding*numel(resampledDataPad)/numel(dataPad));
                frontDataEulerianHFS{frHFS}=resampledDataPad(padding_mod+1:end-padding_mod);

                %padding distorts final data by 1 mm shortening
                %sometimes
                plot(frontDataEulerianHFS{frHFS},'LineWidth',1,'Color',colorstring{frHFS})
                
                steam.(['mixFront_',hfsSensorList{frHFS}]).var=frontDataEulerianHFS{frHFS};
                steam.(['mixFront_',hfsSensorList{frHFS}]).error=1;
                steam.(['mixFront_',hfsSensorList{frHFS}]).unit='various';
                
            end
            legend(hfsSensorList)
%             title([file_list,' NC Front in mm'],'interpreter', 'none')
            ylabel('Heat flux [W/m^2]')
            xlabel('Length [mm]')
            xlim([0 400])
            hHFS.Children(2).XLabel.FontWeight='bold';
            hHFS.Children(2).YLabel.FontWeight='bold';
            pathPrintName=[pathPrint,'\','NCFrontGHFS_LENGTH_',file_list];
            saveas(hHFS,pathPrintName,'png')
            print(hHFS,pathPrintName,'-dmeta')
            close(hHFS)

%%
%             pathPrintName=[pathPrint,'\',file_list,'_NCFrontFFT'];
%             saveas(h4,pathPrintName,'png')
%             close(h4)
            
            h3=figure('visible','off');
            hold on
            plot(frontStd,'.','MarkerSize',14);
%             legend(sensorList)
            title([file_list,' NC Front norm std'],'interpreter', 'none')
            ylabel('Norm std')
            xlabel('sensor')
            pathPrintName=[pathPrint,'\','NCFrontStd_',file_list];
            saveas(h3,pathPrintName,'png')
            print(h3,pathPrintName,'-dmeta')
            close(h3)
            
            steam.contInj.frontSTD=frontStd;
            %calculate velocity from pressure drop in NC tank
            
            %find NC feeding onset            
            volNCtank=0.005; % m3
            pressNCtank=facility.NCtank_press.var.*10^5;  %10^5 to convert bar to Pa
            tempNCtank=smooth(facility.NCtank_temp.var,100)+273.15;
            NCtankMoles=pressNCtank.*volNCtank./(tempNCtank.*8.3144598);  %n=PV/RT
            
            NCtankDiff=smooth(diff(NCtankMoles),20);
            %find where moles are falling
            NCtankDiffMask(NCtankDiff>=0)=0;
            NCtankDiffMask(NCtankDiff<0)=1;
            %this require image processing toolbox
            % Make measurements of lengths of connected "1" regions.
            measurements = regionprops(logical(NCtankDiffMask), 'Area', 'PixelIdxList');
            % Sort them to find the longest one.
            [~, sortIndexes] = sort([measurements.Area], 'Descend');
            % Get the starting and ending indexes of the largest one.
            NCfeedStart = measurements(sortIndexes(1)).PixelIdxList(1);
            if strcmp(file_list,'NC-MFR-ABS-He-4_LEAK')
                NCfeedStart=820;
            end
            
            steam.contInj.NCpress=facility.NCtank_press.var(NCfeedStart:end);
            
%             %test feeding start recognition
%             figure
%             plot(NCtankMoles)
%             hold on
%             plot([NCfeedStart NCfeedStart],ylim,'--r')
        
            
            %calculate tube fill with NC gases
            feedingTime=NCfeedStart:1:numel(steam.press.var);
%             molesTube=-(NCtankMoles-max(NCtankMoles));   %XXXXX
            molesTube=-(NCtankMoles-NCtankMoles(NCfeedStart));   
            molesTube=molesTube(NCfeedStart:end);
            NCdelay=NCfeedStart-frontArrivalStart(end);
            molesTubewhenstart=molesTube(abs(NCdelay));
            molesTube=molesTube+molesTubewhenstart;  
            
%             figure
%             plot(molesTube)
%             title([file_list,' Moles in Tube'],'interpreter', 'none')
            
            %top is not pure NC gas, assume some residual steam at
            %saturation
            pressTotal=steam.press.var(NCfeedStart:end).*10^5;  %10^5 to convert bar to Pa
            tempSteam=steam.TF9603.var(NCfeedStart:end)+273.15; %K
            
            %Easier way
            tempTop=steam.TF9613.var(NCfeedStart:end)+273.15;
            PpartSteamTop=IAPWS_IF97('psat_T',tempTop)*10^6;  %-0.4 hack
%             PpartNCTop=pressTotal-PpartSteamTop;
%             PpartNCTop(PpartNCTop<=0)=0.0001;
% 
%             moleRatio=PpartSteamTop./PpartNCTop;
%             molesTubefixed=molesTube+molesTube.*moleRatio;
            h2oMfr=PpartSteamTop./pressTotal;
            h2oMfr(h2oMfr>1)=1;
            molesTubefixed=molesTube./h2oMfr;
            tubeFillVol=molesTubefixed.*8.3144598.*tempSteam./pressTotal;  %V=nRT/P
            
            %Complicated way
            %--------------------------------------------------------------------------------------------------------------------------------------------------------
%             frontThickfit=fit(frontArrivalStart',frontSize','poly1');           
%             NCfrontSize=frontThickfit(feedingTime);
% %             figure
% %             hold on
% %             plot(frontThickfit, frontArrivalStart',frontSize')
% %             plot(feedingTime,NCfrontThickness )
% 
%             %counting from top of the tube
%             sensorPosfromTop=abs(sensorPos-1120)+110;
%             frontPosfit=fit(frontArrivalStart',sensorPosfromTop','poly1'); 
%             NCfrontPosition=frontPosfit(feedingTime);
% %             figure
% %             hold on
% %             plot(frontPosfit, frontArrivalStart,sensorPosfromTop)
% %             plot(feedingTime,NCfrontPosition)
%             
%             for frontCntr=1:numel(NCfrontSize)
%                 if NCfrontPosition(frontCntr)<NCfrontSize(frontCntr)
%                     fullFront(frontCntr)=0;
%                     frontSizeMod(frontCntr)=NCfrontPosition(frontCntr);
%                     deadZoneSize(frontCntr)=0;
%                     deadZoneTemp(frontCntr)=tempSteam(frontCntr)-NCfrontPosition(frontCntr)/NCfrontSize(frontCntr)*(tempSteam(frontCntr)-tempTop(frontArrivalEnd(1)));
%                 else
%                     fullFront(frontCntr)=1;
%                     frontSizeMod(frontCntr)=NCfrontSize(frontCntr);
%                     deadZoneSize(frontCntr)=NCfrontPosition(frontCntr)-frontSizeMod(frontCntr);
%                     deadZoneTemp(frontCntr)=tempTop(frontCntr);
%                 end
%             end
            %------------------------------------------------------------------------------------------------------------------------------------------------
            %Based on last measurement only
%             tempSteam=steam.temp.var(frontArrivalStart(1))+273.15; %K
%             tempTop=steam.TF9613.var(frontArrivalStart(1))+273.15;
%             PpartSteamTop=IAPWS_IF97('psat_T',tempTop)*10^6;
%             PpartNCTop=pressTotal-PpartSteamTop;
%             PpartNCTop(PpartNCTop<0)=0.1;
           
%             moleRatio=PpartSteamTop./PpartNCTop;
%             molesTubefixed=molesTube+molesTube.*moleRatio;
%             tubeFillVol=molesTubefixed.*8.314.*tempSteam./pressTotal;  %V=nRT/P
            
            %
            tubeFillLength=tubeFillVol./(pi*0.01^2).*1000;  % *1000 to mm
            
            frontStartZeroed=frontArrivalStart-frontArrivalStart(end)+frontArrivalStart(end)-feedingTime(1);  %move everything towards zero on X axis
            
            h4=figure('visible','off');
            h4.Position=([500 200 500, 250]);
            plot(feedingTime-feedingTime(1),sensorPos(end)-tubeFillLength,'-.','LineWidth',2)
            hold on
            sensorPosBackward=-(sensorPos-sensorPos(end))+110; %because we observe last one first, we have to start counting backward
            plot(frontStartZeroed, sensorPos(end)-(sensorPosBackward-sensorPosBackward(end)),'.-','MarkerSize',12,'LineWidth',1.5)  % substract last term, to set it as a starting point
            xlim([frontStartZeroed(end)-10 frontStartZeroed(1)+10])
            ylim([sensorPos(1)-50 sensorPos(end)+50])
            grid on
            title(' NC gas plug downward expansion','interpreter', 'none')
            ylabel('Vertical position [mm]')
            xlabel('Time [s]')
            legend('Calculated based on pressure drop','Observed with thermocouples','Location','NorthEast','FontSize','11')
            pathPrintName=[pathPrint,'\','NCFrontTIMEadvancement_',file_list];
            saveas(h4,pathPrintName,'png')
            print(h4,pathPrintName,'-dmeta')
%             savefig(h4,[pathPrintName,'.fig'])
%             close(h4)

            %velocity vs front size
            NCmoleFlow=smooth(diff(molesTube),20);  % pseudo mole over s

            if sum(frontArrivalStart<NCfeedStart)
                frontArrivalStart(frontArrivalStart<NCfeedStart)=NCfeedStart+1;
            end
            NCmoleFlowSnapshots=NCmoleFlow(frontArrivalStart-NCfeedStart);
            steam.contInj.frontArriv=frontArrivalStart;
            h6=figure('visible','off');
            h6.Position=([500 200 500, 250]);
            plot(NCmoleFlow,'-','LineWidth',1.5)
            grid on
%             title(' NC feeding rate','interpreter', 'none')
            ylabel('Feeding rate [mol/s]')
            xlabel('Time [s]')
            pathPrintName=[pathPrint,'\','NCFeedingRate_',file_list];
            saveas(h6,pathPrintName,'png')
            print(h6,pathPrintName,'-dmeta')
            
            steam.contInj.NCfeed=NCmoleFlow;
            
            %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            steamMoleFlow=steam.mflow.var.*(1000/18.01528);  % times 1000 to move from kg/s to g/s and divide by molar mass of steam to move to moles over second
            steamMoleFlow=smooth(steamMoleFlow,50);
            steamMoleFlowSnapshots=steamMoleFlow(frontArrivalStart);
            moleRatio=steamMoleFlowSnapshots./NCmoleFlowSnapshots;
            
            h5=figure('visible','off');
            title([file_list,' Front Size vs mixture mole ratio'],'interpreter', 'none')
            subplot(2,1,1)
            plot(moleRatio,frontSize,'.')
            xlim([min(moleRatio) max(moleRatio)])   
            ylabel('Front Size')
            xlabel('Mole ratio')
            subplot(2,1,2)
            plot(steamMoleFlowSnapshots,frontSize,'.','MarkerSize',14)
            xlim([min(steamMoleFlowSnapshots) max(steamMoleFlowSnapshots)])
            
            fitParam=polyfit(steamMoleFlowSnapshots,frontSize',1);
            txt1=['y = ',num2str(fitParam(1)),' * x + ',num2str(fitParam(2))];
            yL=get(gca,'YLim'); 
            xL=get(gca,'XLim');   
            text((xL(1)+xL(2))/2,yL(2),txt1,...
              'HorizontalAlignment','left',...
              'VerticalAlignment','top',...
              'BackgroundColor',[1 1 1],...
              'FontSize',12);
            
            ylabel('Front Size')
            xlabel('Steam Moleflow')
            pathPrintName=[pathPrint,'\','NCFrontSizevsMolarRatio_',file_list];
            saveas(h5,pathPrintName,'png')
            print(h5,pathPrintName,'-dmeta')
            close(h5)
            
            %front std's
            
        end
        
%% Sort variables and save
        disp('7. Sorting and storing data in .mat files')
        
        %sorting
        coolant=orderfields(coolant);
        steam=orderfields(steam);
        facility=orderfields(facility);
        BC=orderfields(BC);
        GHFS=orderfields(GHFS);   
        MP=orderfields(MP);
        distributions=orderfields(distributions);

        %saving
%         if fast_flag && MP_flag
            save(processed_data_file_name,'steam','coolant','file','facility','distributions','NC','BC','GHFS','MP','timing');
%             disp('fast+MP')
%         elseif fast_flag
%             save(processed_data_file_name,'steam','coolant','file','facility','distributions','NC','BC','GHFS');
%             disp('fast')
%         elseif MP_flag
%             save(processed_data_file_name,'steam','coolant','file','facility','distributions','NC','BC','MP');
%             disp('MP')
%         else
%             save(processed_data_file_name,'steam','coolant','file','facility','distributions','NC','BC');
%             disp('only slow')
%         end
        
        % print a table with input data for RELAP5
        disp('8. Creating input files for ClosedTubeSimulator2015')
        try
            RELAP{1,1}='Pps';
            RELAP{2,1}='NC';
            RELAP{3,1}='Helium';
            RELAP{4,1}='Pss';
            RELAP{5,1}='Tss';
            RELAP{6,1}='Mflowss';
            RELAP{7,1}='Power';
            RELAP{1,2}=steam.press_init.value;
            RELAP{2,2}=NC.N2_molefraction_init.value+NC.He_molefraction_init.value;
            RELAP{3,2}=NC.He_molefraction_init.value;
            RELAP{4,2}=coolant.press.value;
            RELAP{5,2}=coolant.temp_inlet.value;
            RELAP{6,2}=coolant.mflow.value;
            RELAP{7,2}=steam.power.value;
            xlswrite([file.directory,'\',file.name,'_RELAP_INPUT'],RELAP)
        catch ME
            ME.message
            disp('Relap input not created - error, possibly data which was processed in the old way')
        end

        % if user was in interactive mode and updated defaults, store them in file
        if interactive_flag
            if smooth_update_defaults 
                s=pwd;
                disp(s)
                disp('8. Updating default processing parameters in adv_options.txt')
                %get updated values
                updated_options.avg_window=avg_window;
                updated_options.limiting_factor=limiting_factor;
                updated_options.x_limit=x_limit;
                updated_options.frame_size=frame_size;
                updated_options.smoothing_type=smoothing_type;
                updated_options.sgolay_order=sgolay_order;
                updated_options_names=fieldnames(updated_options);
                %open file for writing
                fileID=fopen('adv_options.txt','wt+');
                %write to file
                for n=1:numel(updated_options_names)
                    line_to_write=[updated_options_names{n},' ',num2str(updated_options.(updated_options_names{n}))];
                    fprintf(fileID,'%s\n',line_to_write);
                end

                %close file
                fclose(fileID);
            end
        end
    end
    
disp('Processing finished, ready for a new file')
disp('*****************************************\n')


end