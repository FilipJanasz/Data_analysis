function [steam, coolant, facility, NC, distributions, file, BC, GHFS, MP,timing]=file_processing(interactive_flag,file_list,directory,st_state_flag,options)
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
                steady_data=temp_dat.UNsteady_data;
                disp('Proccessed data not found but UNsteady state data found, loading without looking for steady state period and recalculating')
                disp('Check if "steady state" checkbox is in the right state')
            end
            
            % verify which types of data are available
            if isfield(steady_data,'GHFS1')
                fast_flag=1;
            else
                fast_flag=0;
            end

            if isfield(steady_data,'MP_Pos')
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
                            steady_data.(curr_channel)=data.(curr_channel)(fast_start:fast_end);
                        elseif ~isempty(strfind(curr_channel,'MP_TF')) || ~isempty(strfind(curr_channel,'MP_Pos')) 
%                             eval(['steady_data.',curr_channel,'=data.',curr_channel,'(st_state_start_relative/period_MP:st_state_end_relative/period_MP);']);                          
                            st_state_start_MP=floor(st_state_start_relative/numel(data.TF9602)*numel(data.(curr_channel)));
                            st_state_end_MP=floor(st_state_end_relative/numel(data.TF9602)*numel(data.(curr_channel)));                            
                            steady_data.(curr_channel)=data.(curr_channel)(st_state_start_MP:st_state_end_MP);
%                             steady_data.(curr_channel)=data.(curr_channel)(st_state_start_relative/period_MP:st_state_end_relative/period_MP);
                        else
%                             eval(['steady_data.',curr_channel,'=data.',curr_channel,'(st_state_start_relative:st_state_end_relative);']);
                            try
                                steady_data.(curr_channel)=data.(curr_channel)(st_state_start_relative:st_state_end_relative);
                            catch
                                disp(['Problematic channel: ',curr_channel,' - not extracting steady state from it. Check the data'])
                                steady_data.(curr_channel)=data.(curr_channel);
                            end
                        end
                    end
    %                 st_state_data=steady_data.PA9601;
                    % SECOND PARAMTER FOR STEADY STATE SEARCH
                    st_state_data=steady_data.TF9503;
                end
                % append power
                steady_data.power=joule_heating(steady_data.HE9601_I,230);
                % append timing
                steady_data.timing=timing;
                %save
                save(steady_data_file_name,'steady_data');
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
                steady_data=UNsteady_data;
            end
         

        end
    
        %% Apply any calibration data previosly obtained to the raw data (especially thermoelements)
        disp('2. Applying any avaialble calibration look up tables')
        interp_data=cal_data_interpolate(steady_data);
        cal_fields=fields(interp_data);
        cal_steady_data=steady_data;
        for cal_cntr=1:numel(cal_fields)
            try
            cal_steady_data.(cal_fields{cal_cntr})=cal_steady_data.(cal_fields{cal_cntr})+interp_data.(cal_fields{cal_cntr});
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
        timing=steady_data.timing;
        
        % coolant side
        coolant.vflow.var=cal_steady_data.FV3801;  
        coolant.velocity.var=coolant.vflow.var/3600/0.008641587;
%         coolant_water_residence_time=1.5/mean(coolant.velocity.var); % how long does it take coolant water to travel the height of the facility
        % facility height (1.5 m) divide by velocity [m/s]
        coolant.temp.var=(cal_steady_data.TF9502+cal_steady_data.TF9501)/2;
        coolant.press.var=cal_steady_data.PA9501;  
        coolant.temp_inlet.var=cal_steady_data.TF9501;
        coolant.temp_inlet_TC.var=(cal_steady_data.TF9503+cal_steady_data.TF9504)/2;
        coolant.temp_outlet.var=cal_steady_data.TF9502;
        coolant.temp_outlet_TC.var=(cal_steady_data.TF9507+cal_steady_data.TF9508)/2;
        coolant.dT.var=coolant.temp_outlet.var-coolant.temp_inlet.var;
        
        % GHFS var & MP var
        if  fast_flag==1
                        
            GHFS.GHFS1_raw.var=cal_steady_data.GHFS1;
            GHFS.GHFS2_raw.var=cal_steady_data.GHFS2;
            GHFS.GHFS3_raw.var=cal_steady_data.GHFS3;
            GHFS.GHFS4_raw.var=cal_steady_data.GHFS4;
            
            GHFS_offset=[0.01735 -0.14407 0.28317 -0.20995];
            
            % thermocouple cal_steady_data.TCH2_2W is broken
            % as a workaround, use average between two thermocouples
            if ~isfield(cal_steady_data,'TCH2_2W')
                cal_steady_data.TCH2_2W=(cal_steady_data.TCH1_2W+cal_steady_data.TCH3_2W)./2;
            elseif isnan(cal_steady_data.TCH2_2W)
                cal_steady_data.TCH2_2W=(cal_steady_data.TCH1_2W+cal_steady_data.TCH3_2W)./2;
            end
            GHFS.GHFS1_temp.var=cal_steady_data.TCH1_2W;
            GHFS.GHFS2_temp.var=cal_steady_data.TCH2_2W;
%             GHFS.GHFS2_temp.var=(cal_steady_data.TCH1_2W+cal_steady_data.TCH3_2W)./2;  % one TC is broken, this is a work around that might fail
            GHFS.GHFS3_temp.var=cal_steady_data.TCH3_2W;
            GHFS.GHFS4_temp.var=cal_steady_data.TCH4_2W;
               
            GHFS.wall_dT_GHFS1.var=cal_steady_data.TCH1_2W-cal_steady_data.TCH1_3W;
            GHFS.wall_dT_GHFS2.var=cal_steady_data.TCH2_2W-(cal_steady_data.TCH1_3W+cal_steady_data.TCH3_3W)./2;
%             GHFS.wall_dT_GHFS2.var=(cal_steady_data.TCH1_2W+cal_steady_data.TCH3_2W)./2-cal_steady_data.TCH2_3W; % one TC is broken, this is a work around that might fail
            GHFS.wall_dT_GHFS3.var=cal_steady_data.TCH3_2W-cal_steady_data.TCH3_3W;
            GHFS.wall_dT_GHFS4.var=cal_steady_data.TCH4_2W-cal_steady_data.TCH4_3W;
            
            % HEATFLUXES
            % from GHFS
            
            %measured by microscope + image recognition
            GHFS.GHFS1.area=84.78; % mm^2
            GHFS.GHFS2.area=85.54; % mm^2
            GHFS.GHFS3.area=82.34; % mm^2
            GHFS.GHFS4.area=84.31; % mm^2
            
            %based on amplifier tests
            GHFS.GHFS1.amplification=10000; % 
            GHFS.GHFS2.amplification=10000; % 
            GHFS.GHFS3.amplification=10000; % 
            GHFS.GHFS4.amplification=10000; % 
            
            GHFS_string={'GHFS1','GHFS2','GHFS3','GHFS4'}; %contains names of all sensors in facility
            %call function with appropriate data and recalculate heat flux from meaured voltage
            for ghfs_cntr=1:numel(GHFS_string)
                GHFS.(GHFS_string{ghfs_cntr}).var=GHFS_heatflux(GHFS.([GHFS_string{ghfs_cntr},'_raw']),GHFS.(GHFS_string{ghfs_cntr}).area,GHFS.([GHFS_string{ghfs_cntr},'_temp']),GHFS.(GHFS_string{ghfs_cntr}).amplification,GHFS_offset(ghfs_cntr));
            end
            
            % from dT (0.003 is distance between thermocouples in mm)
            GHFS_wall_htc=2*15/(0.023*log(0.03/0.023));
            GHFS.wall_heatflux_GHFS1.var=GHFS.wall_dT_GHFS1.var.*GHFS_wall_htc;
            GHFS.wall_heatflux_GHFS2.var=GHFS.wall_dT_GHFS2.var.*GHFS_wall_htc;
            GHFS.wall_heatflux_GHFS3.var=GHFS.wall_dT_GHFS3.var.*GHFS_wall_htc;
            GHFS.wall_heatflux_GHFS4.var=GHFS.wall_dT_GHFS4.var.*GHFS_wall_htc;
            
            %movable probe
            MP.MP1.var=cal_steady_data.MP1;
            MP.MP2.var=cal_steady_data.MP2;
            MP.MP3.var=cal_steady_data.MP3;
            MP.MP4.var=cal_steady_data.MP4;
        end
        
        % steam side thermodynamic codnitions - measured
        steam.press.var=cal_steady_data.PA9601; % [bar]        
        steam.power.var=cal_steady_data.power;        
        steam.temp.var=cal_steady_data.TF9602; % [C]  
        steam.heater_temp.var=cal_steady_data.TW9602; % [C] 
        
        % steam side thermocouples - centerline
        try
            steam.TF9603.var=cal_steady_data.TF9603;
            steam.TF9604.var=cal_steady_data.TF9604;
            steam.TF9605.var=cal_steady_data.TF9605;
            steam.TF9606.var=cal_steady_data.TF9606;
            steam.TF9607.var=cal_steady_data.TF9606.*(1/3)+cal_steady_data.TF9608.*(2/3);
            steam.TF9608.var=cal_steady_data.TF9608;
            steam.TF9609.var=cal_steady_data.TF9608.*(2/3)+cal_steady_data.TF9610.*(1/3);
            steam.TF9610.var=cal_steady_data.TF9610;
            steam.TF9611.var=cal_steady_data.TF9611;
            steam.TF9612.var=cal_steady_data.TF9612;
            steam.TF9613.var=cal_steady_data.TF9613;
            steam.TF9614.var=cal_steady_data.TF9614;
        catch
            disp('No data for thermocouples TF9603-TF9614 - old recording probably')
        end
         %distributions.centerline_temp.position_y=[220 320 420 520 620 670 720 820 920 1020 1120 1220];
        % steam - coolant interface - facility
        facility.wall_dT.var=steam.temp.var-coolant.temp.var;   
        
%         facility.voltage.var=cal_steady_data.HE9601_U;
        facility.current.var=cal_steady_data.HE9601_I;
        facility.NCtank_press.var=cal_steady_data.PA9701;
        facility.NCtank_temp.var=cal_steady_data.TF9701;
        
        
        %% mean values
        % coolant thermodynamic conditions - measured               
        coolant.vflow.value=mean(cal_steady_data.FV3801);        
        coolant.temp.value=(mean(cal_steady_data.TF9502)+mean(cal_steady_data.TF9501))/2;
        coolant.press.value=mean(cal_steady_data.PA9501);  
        coolant.temp_inlet.value=mean(cal_steady_data.TF9501);
        coolant.temp_outlet.value=mean(cal_steady_data.TF9502);
        coolant.temp_inlet_TC.value=(mean(cal_steady_data.TF9503)+mean(cal_steady_data.TF9504))/2;
        coolant.temp_outlet_TC.value=(mean(cal_steady_data.TF9507)+mean(cal_steady_data.TF9508))/2;
        
        % coolant properties - calculated (some with IAPWS_IF97)
        coolant.dT.value=coolant.temp_outlet.value-coolant.temp_inlet.value; 
        coolant.dT_TC.value=coolant.temp_outlet_TC.value-coolant.temp_inlet_TC.value; 
        coolant.dens.value=1/IAPWS_IF97('v_pT',coolant.press.value/10,coolant.temp.value+273.15); %take inversion, cause IAPWS calcualtes specific volume (m3/kg)
        coolant.mflow.value=coolant.vflow.value*coolant.dens.value;
        coolant.enthalpy.value=IAPWS_IF97('h_pT',coolant.press.value/10,coolant.temp.value+273.15);
        coolant.spec_heat.value=IAPWS_IF97('cp_ph',coolant.press.value/10,coolant.enthalpy.value)*1000; %multiply by 1000 so unit is J/kg*K
        coolant.power.value=coolant.mflow.value/3600*coolant.spec_heat.value*coolant.dT.value;
        coolant.power_TC.value=coolant.mflow.value/3600*coolant.spec_heat.value*coolant.dT_TC.value;
        coolant.dynvis.value=IAPWS_IF97('mu_pT',coolant.press.value/10,coolant.temp.value+273.15);
        coolant.kinvis.value=coolant.dynvis.value/coolant.dens.value;
        coolant.thermcond.value=IAPWS_IF97('k_pT',coolant.press.value/10,coolant.temp.value+273.15);
        coolant.prandtl.value=coolant.spec_heat.value*coolant.dynvis.value/coolant.thermcond.value;
        coolant.velocity.value=coolant.vflow.value/3600/0.008641587; %flow area = 0.008641587 m2
        coolant.reynolds.value=coolant.velocity.value*coolant.dens.value*0.0791/coolant.dynvis.value;% hydraulic diameter of the annulus = 0.0791 m
        coolant.htc_dittusboleter.value=0.023*coolant.reynolds.value^0.8*coolant.prandtl.value^0.4*coolant.thermcond.value/0.0791;
        coolant.htc_gnielinski.value=htc_gnielinski(coolant.reynolds.value,coolant.thermcond.value,coolant.prandtl.value,0.0791);
                
        % steam side thermodynamic codnitions - measured
        steam.press.value=mean(cal_steady_data.PA9601); % [bar]        
        steam.power.value=mean(steam.power.var);        
        steam.temp.value=mean(cal_steady_data.TF9602); % [C] 
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
        facility.heat_losses.value=steam.power.value-coolant.power.value;
        facility.heat_losses_TC.value=steam.power.value-coolant.power_TC.value;
        facility.dT_losses.value=(coolant.power.value+facility.heat_losses.value)/(coolant.mflow.value/3600*coolant.spec_heat.value);  % how much more dT should there be in coolant water
        facility.wall_htc.value=2*15/(0.02*log(0.03/0.02));
        facility.wall_heatflux_dT.value=facility.wall_htc.value*facility.wall_dT.value;
        facility.wall_heatflow_dT.value=facility.wall_heatflux_dT.value*2*pi*0.021/2*1;  %last term is inner wall area of the test tube
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
            MP.MP2.value=mean(MP.MP2.var);
            MP.MP3.value=mean(MP.MP3.var);
            MP.MP4.value=mean(MP.MP4.var);

        end
        
        %% MOVABLE PORT POSITION AND TEMEPRATURE CALCULATION
        if MP_flag %this is not available for all the calculations
            for rounding_counter=1:numel(cal_steady_data.MP_Pos)
                MP.Pos.var(rounding_counter,1)=round(cal_steady_data.MP_Pos(rounding_counter)*10);  %rounding to the first digit to the right of the decimal point
                MP.Pos.var(rounding_counter,1)=MP.Pos.var(rounding_counter,1)/10;
            end
%             MP.Pos.var=cal_steady_data.MP_Pos;
            MP.Pos.value=mean(MP.Pos.var); %[mm, wall with fixed probe is 0]
            % MOD THIS ACCORDINGLY TO PROPER CHANNELS
            MP.Temp.var=cal_steady_data.MP_TF;
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
        
            %combine all into one matrix for further processing
            MP_matrix=[MP.Pos.var MP.Temp.var MP.Temp_smooth.var MP_direction'];

            %sort by movement direction and separate in two matrices
            MP_matrix=sortrows(MP_matrix,4);
            direction_forward=find(MP_matrix(:,4)==1);
            direction_backward=find(MP_matrix(:,4)==0);

            %as matrix is sorted by row 4, all forward and backward points
            %are grouped - first backward movement, then forward movement, simple to separate
            if numel(direction_forward)>0
                MP_data.forward=MP_matrix(direction_forward(1):direction_forward(end),1:3);
                forward_flag=1;
            else
                forward_flag=0;
            end

            if numel(direction_backward)>0
                MP_data.backward=MP_matrix(direction_backward(1):direction_backward(end),1:3);
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
                        %store all for the glorious future
                        MP_Temp_averaged.(directions{ctr})(n,:)=[processed_pos pos_temp pos_temp_smooth pos_std];
                        n=n+1;
                    else
                    end
                    %now clear the rows that were just processed, so program
                    %will at some point exit this unholy loop
                    MP_pos_sorted(1:interval(end))=[];
                    MP_temp_sorted(1:interval(end))=[];
                    MP_temp_sorted_filtered(1:interval(end))=[];
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
                if MP.T_boundlayer_forward.value < -5
                    MP.T_boundlayer_forward.value=0;
                end
                MP.T_boundlayer_forward.value=-MP.T_boundlayer_forward.value;
            catch
                disp('no boundlayer forward')
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
                disp('no boundlayer backward')
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
        if ~isfield(steady_data,'TCH2_2W')
            steady_data.TCH2_2W=(steady_data.TCH1_2W+steady_data.TCH3_2W)./2;
        end
        
        %time-varying data
        if MP_flag %MP_flag points to new files. which have modified TC layout
            %movable probe distributions
            if forward_flag
                distributions.MP_forward_temp.var=MP_Temp_averaged.forward(:,2);                
                distributions.MP_forward_temp_smooth.var=MP_Temp_averaged.forward(:,3);
            end
            if backward_flag
                distributions.MP_backward_temp.var=MP_Temp_averaged.backward(:,2);               
                distributions.MP_backward_temp_smooth.var=MP_Temp_averaged.backward(:,3);
            end 
            short_flag=0;
        end
          
        %centerline - 3 options are for legacy data file structure from
        %runs done in 2014 and 2015
        try
            distributions.centerline_temp.var=[steam.TF9603.var,steam.TF9604.var,steam.TF9605.var,steam.TF9606.var,steam.TF9607.var,steam.TF9608.var,steam.TF9609.var,steam.TF9610.var,steam.TF9611.var,steam.TF9612.var,steam.TF9613.var,steam.TF9614.var];
            centerline_flag=1;
        catch
            try
                distributions.centerline_temp.var=[cal_steady_data.TCH1_1F,MP.Temp.var,cal_steady_data.TCH2_1F,cal_steady_data.TCH3_1F,cal_steady_data.TCH4_1F];
                short_flag=0;
                centerline_flag=1;
            catch
                distributions.centerline_temp.var=[cal_steady_data.TCH1_1F,cal_steady_data.TCH2_1F,cal_steady_data.TCH3_1F,cal_steady_data.TCH4_1F];
                short_flag=1;
                centerline_flag=1;
            end
        end
        
        % the layout of TC's is the same for old and new files, hence no if /try catch structures
        distributions.coolant_temp_0deg.var=[cal_steady_data.TF9503,cal_steady_data.TF9505,cal_steady_data.TF9507];
        distributions.coolant_temp_180deg.var=[cal_steady_data.TF9504,cal_steady_data.TF9506,cal_steady_data.TF9508];
        distributions.outer_wall_temp_0deg.var=[cal_steady_data.TW9501,cal_steady_data.TW9503,cal_steady_data.TW9505,cal_steady_data.TW9507,cal_steady_data.TW9509,cal_steady_data.TW9511];
        distributions.outer_wall_temp_180deg.var=[cal_steady_data.TW9502,cal_steady_data.TW9504,cal_steady_data.TW9506,cal_steady_data.TW9508,cal_steady_data.TW9510,cal_steady_data.TW9512];
        
        %GHFS thermocouples
        try
            distributions.GHFS_TC.var=[cal_steady_data.HFS1TC,cal_steady_data.HFS2TC,cal_steady_data.HFS3TC,cal_steady_data.HFS4TC];
        catch
            distributions.GHFS_TC.var=[cal_steady_data.TCH1_2W,(cal_steady_data.TCH1_2W+cal_steady_data.TCH3_2W)./2,cal_steady_data.TCH3_2W,cal_steady_data.TCH4_2W];
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
            distributions.wall_outer.var=[cal_steady_data.TCH1_3W,cal_steady_data.TCH2_3W,cal_steady_data.TCH3_3W,cal_steady_data.TCH4_3W];
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
            end
            if backward_flag
                distributions.MP_backward_temp.value.cal=MP_Temp_averaged.backward(:,2);               
                distributions.MP_backward_temp.std=MP_Temp_averaged.backward(:,4);
                distributions.MP_backward_temp_smooth.value.cal=MP_Temp_averaged.backward(:,3);
            end 
            short_flag=0;
        end
          
        %centerline - 3 options are for legacy data file structure from
        %runs done in 2014 and 2015
        try
            distributions.centerline_temp.value.cal=[steam.TF9603.value,steam.TF9604.value,steam.TF9605.value,steam.TF9606.value,steam.TF9607.value,steam.TF9608.value,steam.TF9609.value,steam.TF9610.value,steam.TF9611.value,steam.TF9612.value,steam.TF9613.value,steam.TF9614.value];
            centerline_flag=1;
        catch
            try
                distributions.centerline_temp.value.cal=[mean(cal_steady_data.TCH1_1F),MP.Temp.value,mean(cal_steady_data.TCH2_1F),mean(cal_steady_data.TCH3_1F),mean(cal_steady_data.TCH4_1F)];
                short_flag=0;
                centerline_flag=1;
            catch
                distributions.centerline_temp.value.cal=[mean(cal_steady_data.TCH1_1F),mean(cal_steady_data.TCH2_1F),mean(cal_steady_data.TCH3_1F),mean(cal_steady_data.TCH4_1F)];
                short_flag=1;
                centerline_flag=1;
            end
        end
        
        % the layout of TC's is the same for old and new files, hence no if /try catch structures
        distributions.coolant_temp_0deg.value.cal=[mean(cal_steady_data.TF9503),mean(cal_steady_data.TF9505),mean(cal_steady_data.TF9507)];
        distributions.coolant_temp_180deg.value.cal=[mean(cal_steady_data.TF9504),mean(cal_steady_data.TF9506),mean(cal_steady_data.TF9508)];
        distributions.outer_wall_temp_0deg.value.cal=[mean(cal_steady_data.TW9501),mean(cal_steady_data.TW9503),mean(cal_steady_data.TW9505),mean(cal_steady_data.TW9507),mean(cal_steady_data.TW9509),mean(cal_steady_data.TW9511)];
        distributions.outer_wall_temp_180deg.value.cal=[mean(cal_steady_data.TW9502),mean(cal_steady_data.TW9504),mean(cal_steady_data.TW9506),mean(cal_steady_data.TW9508),mean(cal_steady_data.TW9510),mean(cal_steady_data.TW9512)];
        
        %GHFS thermocouples
        try
            distributions.GHFS_TC.value.cal=[mean(cal_steady_data.HFS1TC),mean(cal_steady_data.HFS2TC),mean(cal_steady_data.HFS3TC),mean(cal_steady_data.HFS4TC)];
        catch
            distributions.GHFS_TC.value.cal=[mean(cal_steady_data.TCH1_2W),mean((cal_steady_data.TCH1_2W+cal_steady_data.TCH3_2W)./2),mean(cal_steady_data.TCH3_2W),mean(cal_steady_data.TCH4_2W)];
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
            distributions.wall_outer.value.cal=[mean(cal_steady_data.TCH1_3W),mean(cal_steady_data.TCH2_3W),mean(cal_steady_data.TCH3_3W),mean(cal_steady_data.TCH4_3W)];
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
        distributions.coolant_temp_0deg.value.non_cal=[mean(steady_data.TF9503),mean(steady_data.TF9505),mean(steady_data.TF9507)];
        distributions.coolant_temp_180deg.value.non_cal=[mean(steady_data.TF9504),mean(steady_data.TF9506),mean(steady_data.TF9508)];
        distributions.outer_wall_temp_0deg.value.non_cal=[mean(steady_data.TW9501),mean(steady_data.TW9503),mean(steady_data.TW9505),mean(steady_data.TW9507),mean(steady_data.TW9509),mean(steady_data.TW9511)];
        distributions.outer_wall_temp_180deg.value.non_cal=[mean(steady_data.TW9502),mean(steady_data.TW9504),mean(steady_data.TW9506),mean(steady_data.TW9508),mean(steady_data.TW9510),mean(cal_steady_data.TW9512)];
        try
            distributions.centerline_temp.value.non_cal=[mean(steady_data.TCH1_1F),MP.Temp.value,mean(steady_data.TCH2_1F),mean(steady_data.TCH3_1F),mean(steady_data.TCH4_1F)];     
        catch
           
        end
        
        %GHFS thermocouples - non calibrated  
        try
            distributions.GHFS_TC.value.non_cal=[mean(steady_data.HFS1TC),mean(steady_data.HFS2TC),mean(steady_data.HFS3TC),mean(steady_data.HFS4TC)];
            %GHFS_TC_flag=1;
        catch
            distributions.GHFS_TC.value.non_cal=[mean(steady_data.TCH1_2W),mean(steady_data.TCH2_2W),mean(steady_data.TCH3_2W),mean(steady_data.TCH4_2W)];
            %GHFS_TC_flag=0;
        end
        
        %inner wall thermocouples
        try
            distributions.wall_inner.value.non_cal=[mean(steady_data.TCH1_2W),mean(steady_data.TCH2_2W),mean(steady_data.TCH3_2W),mean(steady_data.TCH4_2W)];
        catch
        end
        
        %outer wall thermocouples
        try
            distributions.wall_outer.value.non_cal=[mean(steady_data.TCH1_3W),mean(steady_data.TCH2_3W),mean(steady_data.TCH3_3W),mean(steady_data.TCH4_3W)];
        catch
        end
        
        %wall dT at GHFS positions
        try
            distributions.wall_dT.value.non_cal=[mean(steady_data.TCH1_2W-steady_data.TCH1_3W),mean(steady_data.TCH2_2W-steady_data.TCH2_3W),mean(steady_data.TCH3_2W-steady_data.TCH3_3W),mean(steady_data.TCH4_2W-steady_data.TCH4_3W)];
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
        end
       
        %==================================================================================================================
        %geometry - vertical distribution of sensors
        if MP_flag
            distributions.MP_forward_temp.position_y=ones(length(distributions.MP_forward_temp.value.cal),1)*(360+27.5);      
            distributions.MP_backward_temp.position_y=ones(length(distributions.MP_backward_temp.value.cal),1)*(360+27.5);
            distributions.MP_forward_temp_smooth.position_y=ones(length(distributions.MP_forward_temp_smooth.value.cal),1)*(360+27.5);
            distributions.MP_backward_temp_smooth.position_y=ones(length(distributions.MP_backward_temp_smooth.value.cal),1)*(360+27.5);
            distributions.MP_forward_partpress_h2o.position_y=ones(length(distributions.MP_forward_partpress_h2o.value.cal),1)*(360+27.5);    
            distributions.MP_backward_partpress_h2o.position_y=ones(length(distributions.MP_backward_partpress_h2o.value.cal),1)*(360+27.5);
            distributions.MP_forward_molefr_h2o.position_y=ones(length(distributions.MP_forward_partpress_h2o.value.cal),1)*(360+27.5);    
            distributions.MP_backward_molefr_h2o.position_y=ones(length(distributions.MP_backward_partpress_h2o.value.cal),1)*(360+27.5);
            
            %centerline geometry
            distributions.centerline_temp.position_y=[220 320 420 520 620 670 720 820 920 1020 1120 1220];
            distributions.GHFS_TC.position_y=[220 420 670 920];  %position of sensors in mm
        else
            if short_flag
                distributions.centerline_temp.position_y=[210+27.5 360+27.5 733+27.5 1035+27.5];
            else
                distributions.centerline_temp.position_y=[210+27.5 360+27.5 431+27.5 733+27.5 1035+27.5];
            end
            distributions.GHFS_TC.position_y=[210+27.5 431+27.5 733+27.5 1035+27.5];  %position of sensors in mm
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
        distributions.centerline_molefr_h2o.position_y=distributions.centerline_temp.position_y;
        distributions.centerline_partpress_h2o.position_y=distributions.centerline_temp.position_y;
        distributions.centerline_molefr_NC.position_y=distributions.centerline_temp.position_y;

        %geometry - horizontal distribution of sensors
        if MP_flag
            if forward_flag
                distributions.MP_forward_temp.position_x=MP_Temp_averaged.forward(:,1);
                distributions.MP_forward_temp_smooth.position_x=MP_Temp_averaged.forward(:,1);
                distributions.MP_forward_partpress_h2o.position_x=MP_Temp_averaged.forward(:,1);
                distributions.MP_forward_molefr_h2o.position_x=MP_Temp_averaged.forward(:,1);
            end
            if backward_flag
                distributions.MP_backward_temp.position_x=MP_Temp_averaged.backward(:,1);
                distributions.MP_backward_temp_smooth.position_x=MP_Temp_averaged.backward(:,1);
                distributions.MP_backward_partpress_h2o.position_x=MP_Temp_averaged.backward(:,1);
                distributions.MP_backward_molefr_h2o.position_x=MP_Temp_averaged.backward(:,1);
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
            
            
            
        %% DEFINE ERRORS ==============================================================================================================
        disp('4. Calculating measurement errors')
        %coolant - measured values
        coolant.vflow.error=error_volflow(coolant.vflow.value);
        coolant.temp.error=error_PT100; %function call
        coolant.temp_inlet.error=error_PT100;
        coolant.temp_outlet.error=error_PT100;
        coolant.press.error=error_press(coolant.press.value);
        coolant.temp_inlet_TC.error=0.05;
        coolant.temp_outlet_TC.error=0.05;
        %coolant - recalculated values
        coolant.dT.error =error_dT(coolant.temp.error );
        coolant.dT_TC.error=sqrt(coolant.temp_inlet_TC.error^2+coolant.temp_outlet_TC.error^2);
        coolant.dens.error =error_dens(coolant.temp.value,coolant.press.value,coolant.temp.error ,coolant.press.error );
        coolant.mflow.error =error_mflow(coolant.dens.error ,coolant.vflow.error ,coolant.dens.value,coolant.vflow.value,coolant.mflow.value);
        coolant.enthalpy.error =0.001*coolant.enthalpy.value; %ooooooooooooooooo
        coolant.spec_heat.error =0.001*coolant.spec_heat.value; %ooooooooooooooooo
        coolant.power.error =error_coolantpower(coolant.mflow.value,coolant.spec_heat.value,coolant.dT.value,coolant.power.value,coolant.mflow.error ,coolant.spec_heat.error ,coolant.dT.error );
        coolant.power_TC.error=error_coolantpower(coolant.mflow.value,coolant.spec_heat.value,coolant.dT_TC.value,coolant.power.value,coolant.mflow.error ,coolant.spec_heat.error ,coolant.dT_TC.error );
        coolant.dynvis.error =0.001*coolant.dynvis.value; %ooooooooooooooooo
        coolant.kinvis.error =0.001* coolant.kinvis.value; %ooooooooooooooooo
        coolant.thermcond.error =0.001*coolant.thermcond.value; %ooooooooooooooooo
        coolant.prandtl.error =0.001*coolant.prandtl.value; %ooooooooooooooooo
        coolant.velocity.error =sqrt((coolant.vflow.error/coolant.vflow.value)^2+(0.0001/0.021)^2+(0.0001/0.021)^2)*coolant.velocity.value;
        coolant.reynolds.error =0.001*coolant.reynolds.value; %ooooooooooooooooo
        coolant.htc_dittusboleter.error =0.001*coolant.htc_dittusboleter.value; %ooooooooooooooooo
        coolant.htc_gnielinski.error =0.001*coolant.htc_gnielinski.value; %oooooooooooooooooooooo
                      
        %steam - measured values
        steam.press.error=error_press(steam.press.value);
        steam.press_init.error=steam.press.error;
        steam.temp.error=error_PT100;
        steam.heater_temp.error=error_PT100;
        
        %steam thermocouple centerline
         %steam side thermocouples - centerline
        TCerror=0.1;
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
        steam.boiling_point.error =0.001*steam.boiling_point.value; %ooooooooooooooooo
        steam.enthalpy.error =0.005*steam.enthalpy.value; %ooooooooooooooooo
        steam.enthalpy_liquid.error =0.001*steam.enthalpy_liquid.value; %ooooooooooooooooo
        steam.evap_heat.error =0.001*steam.evap_heat.value; %ooooooooooooooooo
        steam.power.error =error_steam_power(mean(230),mean(cal_steady_data.HE9601_I),steam.power.value);  %XXXXXXXXXXXXXXXXXXX
        steam.mflow.error =error_mflow_steam(steam.power.value,steam.evap_heat.value,steam.mflow.value,steam.power.error ,steam.evap_heat.error );
        steam.density.error =error_dens(steam.temp.value,steam.press.value,steam.temp.error ,steam.press.error );
        steam.vflow.error =error_volflow_steam(steam.vflow.value,steam.mflow.value,steam.density.value,steam.mflow.error ,steam.density.error );
        steam.velocity.error =error_velocity(steam.velocity.value,steam.vflow.value,(pi*(0.021/2)^2),steam.vflow.error,0);
         
        %facility - calculated values only
        facility.wall_dT.error=error_dT(steam.temp.error);
        facility.heat_losses.error=sqrt(steam.power.error^2+coolant.power.error^2);
        facility.heat_losses_TC.error=sqrt(steam.power.error^2+coolant.power_TC.error^2);
        facility.dT_losses.error=sqrt((sqrt(facility.heat_losses.error^2+coolant.power.error^2)/(facility.heat_losses.value+coolant.power.value))^2+(coolant.mflow.error/coolant.mflow.value)^2+(coolant.spec_heat.error/coolant.spec_heat.value)^2)*facility.dT_losses.value;
        facility.wall_htc.error=0.001*facility.wall_htc.value;%ooooooooooooooooo
        facility.wall_heatflux_dT.error=error_wall_heatflux(facility.wall_heatflux_dT.value,facility.wall_htc.value,facility.wall_dT.value,facility.wall_htc.error ,facility.wall_dT.error );
        facility.wall_heatflow_dT.error=error_wall_heatflow(facility.wall_heatflow_dT.value,facility.wall_heatflux_dT.value,facility.wall_heatflux_dT.error );
%         facility.voltage.error=1;
        facility.current.error=1;
        facility.NCtank_press.error=error_press(facility.NCtank_press.value);
        facility.NCtank_temp.error=error_PT100;
        
         % GHFS - errors
        if  fast_flag==1
            [GHFS.GHFS1_raw.error,~]=error_DAS_m9215(GHFS.GHFS1_raw.value);
            [GHFS.GHFS2_raw.error,~]=error_DAS_m9215(GHFS.GHFS2_raw.value);
            [GHFS.GHFS3_raw.error,~]=error_DAS_m9215(GHFS.GHFS3_raw.value);
            [GHFS.GHFS4_raw.error,~]=error_DAS_m9215(GHFS.GHFS4_raw.value);
            
            GHFS.GHFS1_temp.error=0.05;
            GHFS.GHFS2_temp.error=0.05;
            GHFS.GHFS3_temp.error=0.05;
            GHFS.GHFS4_temp.error=0.05;
            
            GHFS.wall_dT_GHFS1.error=error_dT(GHFS.GHFS1_temp.error);
            GHFS.wall_dT_GHFS2.error=error_dT(GHFS.GHFS2_temp.error);
            GHFS.wall_dT_GHFS3.error=error_dT(GHFS.GHFS3_temp.error);
            GHFS.wall_dT_GHFS4.error=error_dT(GHFS.GHFS4_temp.error);
            
            GHFS.GHFS1.error=error_GHFS(GHFS.GHFS1.value,GHFS.GHFS1_raw.value);
            GHFS.GHFS2.error=error_GHFS(GHFS.GHFS2.value,GHFS.GHFS2_raw.value);
            GHFS.GHFS3.error=error_GHFS(GHFS.GHFS3.value,GHFS.GHFS3_raw.value);
            GHFS.GHFS4.error=error_GHFS(GHFS.GHFS4.value,GHFS.GHFS4_raw.value);
            
            GHFS.wall_heatflux_GHFS1.error=facility.wall_heatflux_dT.error;
            GHFS.wall_heatflux_GHFS2.error=facility.wall_heatflux_dT.error;
            GHFS.wall_heatflux_GHFS3.error=facility.wall_heatflux_dT.error;
            GHFS.wall_heatflux_GHFS4.error=facility.wall_heatflux_dT.error;

            % MP - errors
            MP.MP1.error=0.002*MP.MP1.value;
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
            
                 
        %% NC gases ==============================================================================================================
        %  values and errors
        
        % values
        [steam.molefraction.value,NC.N2_molefraction.value,NC.He_molefraction.value,steam.molefraction.error,NC.N2_molefraction.error,NC.He_molefraction.error,NC.N2_molefraction_init.value,NC.He_molefraction_init.value,steam.press_init.value,NC.moles_N2_htank.value,NC.moles_He_htank.value,NC.moles_N2_htank.error,NC.moles_He_htank.error]=NC_filling(steam.press.value,steam.temp.value,steam.press.error,steam.temp.error,file,eos_type);
        NC.NC_molefraction.value=NC.N2_molefraction.value + NC.He_molefraction.value;
        NC.moles_total_init.value=NC.moles_N2_htank.value+NC.moles_He_htank.value;
        
        % estimate tube length occupied by NC mixture, based on NC moles estimate calculated with recorded temperature
        %initialize
        NC.moles_total_est.value=0;
        
        if centerline_flag~=0
            for molefr_ctr=1:numel(distributions.centerline_temp.value.cal)
                distributions.centerline_NC_moles_per_height.value.cal(molefr_ctr)=NC_moles_estimate(distributions.centerline_temp.value.cal(molefr_ctr)+273.15,steam.press.value,distributions.centerline_molefr_NC.value.cal(molefr_ctr),NC.moles_N2_htank.value,NC.moles_He_htank.value,NC.moles_total_init.value,eos_type);  
            end
            
            for mole_ctr=1:numel(distributions.centerline_temp.value.cal)-1
                distance=(distributions.centerline_temp.position_y(mole_ctr+1)-distributions.centerline_temp.position_y(mole_ctr))/1000;  %divide by 1000 to convert mm to m
                %trapezoid (a+b)*h/2 a = value at mole_ctr b = value at mole_ctr+1 h = distance
                NC.moles_total_est.value=NC.moles_total_est.value+(distributions.centerline_NC_moles_per_height.value.cal(mole_ctr+1)+distributions.centerline_NC_moles_per_height.value.cal(mole_ctr))*distance/2;  %sum all the calculated NC moles from temperatures
            end
        end
        % estimate tube length occupied by NC mixture, based on initial conditions estimate of total NC moles
        NC.length_init.value=length_NC(coolant.temp.value+273.15,steam.press.value,distributions.centerline_molefr_h2o.value.cal(end),NC.moles_N2_htank.value,NC.moles_He_htank.value,NC.moles_total_init.value,eos_type);      
        % and based on deduced amount of NC moles from temeprature measurements
        NC.length_est.value=length_NC(coolant.temp.value+273.15,steam.press.value,distributions.centerline_molefr_h2o.value.cal(end),NC.moles_N2_htank.value,NC.moles_He_htank.value,NC.moles_total_est.value,eos_type);      
        
        %errors
        NC.N2_molefraction_init.error=NC.N2_molefraction.error;
        NC.He_molefraction_init.error=NC.He_molefraction.error;
        NC.NC_molefraction.error=NC.N2_molefraction.error+NC.N2_molefraction.error;  
        NC.moles_total_init.error=NC.moles_N2_htank.error+NC.moles_He_htank.error;
        NC.moles_total_est.error=1; %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        try   %try because in old recordings there is no TF9603
            NC.length_init.error=error_NC_length(NC.length_init.value,NC.moles_total_init.value,mean(cal_steady_data.TF9603)+273.15,steam.press.value*10^5,NC.moles_total_init.error,0.05,steam.press.error*10^5);  %*10^5 so it's in pascal
            NC.length_est.error=error_NC_length(NC.length_init.value,NC.moles_total_est.value,mean(cal_steady_data.TF9603)+273.15,steam.press.value*10^5,NC.moles_total_est.error,0.05,steam.press.error*10^5);  %*10^5 so it's in pascal
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
        BC.NC_molefraction.error=NC.NC_molefraction.error;
        BC.He_molefraction.error=NC.He_molefraction.error;
        BC.N2_molefraction.error=NC.N2_molefraction.error;  

       
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
        coolant.power_TC.unit='W'; 
        coolant.dynvis.unit='Pa*s'; 
        coolant.kinvis.unit='m2/s'; 
        coolant.thermcond.unit='W/(m*K)'; 
        coolant.prandtl.unit='1'; 
        coolant.velocity.unit='m/s'; %flow area = 0.008641587 m2
        coolant.reynolds.unit='1'; % hydraulic diameter of the annulus = 0.0791 m
        coolant.htc_dittusboleter.unit='W/(m2*K)'; 
        coolant.htc_gnielinski.unit='W/(m2*K)'; 

        % steam side thermodynamic codnitions - measured
        steam.press.unit='bar'; 
        steam.press_init.unit='bar';
        steam.power.unit='W';       
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
        steam.vflow.unit='m3/s'; 
        steam.velocity.unit='m/s'; 
        
    % steam - coolant interface - facility
        facility.wall_dT.unit=[char(176),'C']; 
        facility.heat_losses.unit='W'; 
        facility.heat_losses_TC.unit='W'; 
        facility.dT_losses.unit=[char(176),'C'];
        facility.wall_htc.unit='W/(m2*K)'; 
        facility.wall_heatflux_dT.unit='W/m2'; 
        facility.wall_heatflow_dT.unit='W'; 
%         facility.voltage.unit='V';
        facility.current.unit='A';
        facility.NCtank_press.unit='Bar';
        facility.NCtank_temp.unit=[char(176),'C']; 
        
    % NC mole fractions units
        steam.molefraction.unit='1';
        NC.N2_molefraction.unit='1';
        NC.He_molefraction.unit='1';
        NC.NC_molefraction.unit='1';
        NC.N2_molefraction_init.unit='1';
        NC.He_molefraction_init.unit='1';
        NC.moles_N2_htank.unit='mol';
        NC.moles_He_htank.unit='mol';
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
        
        % Movable probe units   
            MP.MP1.unit='V';
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

%% calculate standard deviations for steam cooland facility
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
            RELAP{5,1}='Superheat';
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