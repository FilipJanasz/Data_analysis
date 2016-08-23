function init_conditions_viewer(files,timing)
%     profile ON
    %figure out how many files entries are there in the loaded DATA
    %directory
    file_amount_temp=size(files);
    file_amount=file_amount_temp(2);
    
    %% Check which IC excel files are available
    %get the directory to data files
    DATA_directory=files.directory;
    
    %temporary move to DATA folder
    old_folder=cd(DATA_directory);

    %trim last four characters and replace them with IC, to point to proper
    %folder with initil condition files
    IC_directory=[DATA_directory(1:end-4),'IC'];
        
    %check if this set of experiments has a single or multiple initial
    %condition files
    single_IC=exist('IC.xlsx','file');
    if single_IC==2
        disp('Signle IC spreadsheet discovered')
        multiple_IC_flag=0;
    else
        %check for every data file if there exists corresponding IC file
        for file_ctr=1:file_amount
            multiple_IC=exist([files(file_ctr).name,'_IC.xlsx'],'file');
            if multiple_IC==2
                disp(['IC spreadsheet for data file ',files(file_ctr).name,' discovered']);
            else
                disp(['IC spreadsheet for data file ',files(file_ctr).name,' MISSING - check why!']);
            end
        end   
        
        multiple_IC_flag=1;
    end    
    
    %% Check which IC recording files are available 
    %move to directory with IC files
    cd(IC_directory)
    
    %check if files have been converted to .mat from tdms
    [file_list,~]=filter_tdms_files(IC_directory);
    %remove .tdms from the string
    file_list_dotmat=strrep(file_list,'tdms','mat');  
        
    %list all tdms files in there
    for file_ctr=1:numel(file_list_dotmat)
        
        %setup file names
        proccesed_file=strrep(file_list_dotmat{file_ctr},'.mat','-processed.mat');
        
        %check if file was already processed
        exist_proccessed_flag=exist(proccesed_file,'file');
        
        %if not
        if exist_proccessed_flag~=2
            %check if file was already converted to tdms
            exist_dotmat_flag=exist(file_list_dotmat{file_ctr},'file');
            % if corresponding .mat file does not exist, convert it
            if exist_dotmat_flag~=2
                disp([file_list{file_ctr},' file not converted to .mat - fixing now']);
                ignoreGroupNames=1;
                simpleConvertTDMS(file_list{file_ctr},ignoreGroupNames);                
            end
            
            %load data 
            load(file_list_dotmat{file_ctr})
            %then process the file and save
            temp_vars_list=whos ('-file',file_list_dotmat{file_ctr});
            vars_list={temp_vars_list.name};
            %remove non-data positions from the list
            removal_list={'Process_Data','Root','Untitled','XX','fileFolder','fileName','Time','Timestamp','MP_Time'};
            removal_amount=numel(removal_list);
            
            for removal_cnt=1:removal_amount
%                 all_vars_list(strcmp(all_vars_list, removal_list{removal_cnt})) = [];
%                 [I, ~] = find(cellfun(@(s) isequal(s, removal_list{removal_cnt}), all_vars_list));
                I = ismember(vars_list, removal_list{removal_cnt});
                vars_list(I) = [];
            end
            
            %check how many channels are out there
            channel_amount=length(vars_list);
            %load them into appropriate structure
            for i=1:channel_amount
                command=strcat('data.',vars_list{i},'=',vars_list{i},'.Data;');
                eval(command)
                %non eval version fails :(
%                 data.(list{i})=(list{i}).Data;  
            end
            
            %save reorganized file
            save(proccesed_file,'data')
            clear data            
        end
    end

    %% Verify that all the required IC recording files are there, according to available data files
    
    if ~multiple_IC_flag
        %in case of single IC spreadsheet, there should be three IC recordings
        %ideally - general, FAST and MP
        if numel(file_list_dotmat)==3
            disp('All IC recording files present, proceeding to load data')
        else
            disp('Some IC recording files missing - please verify. Proceeding to load available data')
        end
        %load all that is available
        
    else
        %in case of multiple IC spreadsheets, verify that there are three IC
        %recordings for each IC spreadsheet
        for file_ctr=1:file_amount
            gen_flag=exist([files(file_ctr).name,'-IC-processed.mat'],'file');
            fast_flag=exist([files(file_ctr).name,'-IC-FAST-processed.mat'],'file');
            MP_flag=exist([files(file_ctr).name,'-IC-MP-processed.mat'],'file');
            
            %remove hyphens from file names
            legal_file_name=strrep(files(file_ctr).name,'-','_');
            
            %if all files present, let the user know
            if gen_flag==2 && fast_flag==2 && MP_flag==2
                disp(['All IC recordings for file ',files(file_ctr).name, ' are present, proceeding to load data'])
            end
            
            %otherwise state which are missing
            if gen_flag~=2
                disp(['General IC recording missing for file ',files(file_ctr).name, 'proceeding to load available data'])
            else
                temp=load([files(file_ctr).name,'-IC-processed.mat']);
                IC_data.(legal_file_name).general_IC=temp.data;
            end
            
            if fast_flag~=2
                disp(['FAST sensors IC recording missing for file ',files(file_ctr).name,' proceeding to load available data'])
            else
                temp=load([files(file_ctr).name,'-IC-FAST-processed.mat']);
                IC_data.(legal_file_name).fast_IC=temp.data;
            end         
            
            if MP_flag~=2
                disp(['MP sensors IC recording missing for file ',files(file_ctr).name,' proceeding to load available data'])
            else
                temp=load([files(file_ctr).name,'-IC-MP-processed.mat']);
                IC_data.(legal_file_name).mp_IC=temp.data;
            end
            
        end
        
    end
    
    %move back to where the scripts are
    cd(old_folder)
    
    %store data in workspace
    assignin('base','IC_data',IC_data)
    %call gui for plotting
    %fix hyphens
    for file_ctr=1:file_amount
        files(file_ctr).name=strrep(files(file_ctr).name,'-','_');
    end
    gui_IC(IC_data,{files.name},timing,IC_directory);
%     profile VIEWER
    %now having all appropriate data, open GUI
end