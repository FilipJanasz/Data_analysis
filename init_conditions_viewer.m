function init_conditions_viewer(handles)

   %%  PICK A FOLDER FOR PROCCESSING  
   
    % move to file directory, based on default value stored in GUI
    filePath_default=get(handles.file_path_disp,'String');
%     try
%         cd(filePath_default)
%     catch
%     end
    
    %display gui to pick directory
    dirChoice = uigetdir(filePath_default,'Pick a directory');
    newDefaultDir = dirChoice;
    IC_directory=[dirChoice,'\IC'];
    try
        [file_list, ~]=filter_tdms_files(IC_directory);
    catch
        error('Files not chosen, retry and point to files to be processed')
    end

    %update file path in GUI
    set(handles.file_path_disp,'String',newDefaultDir);
            
  
    
    %% Check which IC recording files are available and load them 
    %move to directory with IC files
    cd(IC_directory)
    
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
            removal_list={'Process_Data','Root','Untitled','XX','fileFolder','fileName','Time','Timestamp','MP_Time','ci','convertVer'};
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
    %filter files to contain only base component of the name
    rm_MP=cell2mat(cellfun(@(x) any(strfind(x,'-MP')),file_list,'UniformOutput',0));
    rm_FAST=cell2mat(cellfun(@(x) any(strfind(x,'-FAST')),file_list,'UniformOutput',0));
    files=file_list(find(~(rm_MP|rm_FAST)));
    files=strrep(files,'.tdms','');
    fileCounter=numel(files);
    
    for file_ctr=1:fileCounter
        gen_flag=exist([files{file_ctr},'-processed.mat'],'file');
        fast_flag=exist([files{file_ctr},'-FAST-processed.mat'],'file');
        MP_flag=exist([files{file_ctr},'-MP-processed.mat'],'file');

        %remove hyphens from file names
        legal_file_name=strrep(files{file_ctr},'-','_');

        %if all files present, let the user know
        if gen_flag==2 && fast_flag==2 && MP_flag==2
            disp(['All IC recordings for file ',files{file_ctr}, ' are present, proceeding to load data'])
        end

        %otherwise state which are missing
        if gen_flag~=2
            disp(['General IC recording missing for file ',files{file_ctr}, ', proceeding to load available data'])
        else
            temp=load([files{file_ctr},'-processed.mat']);
            IC_data.(legal_file_name).general_IC=temp.data;
        end

        if fast_flag~=2
            disp(['FAST sensors IC recording missing for file ',files{file_ctr},', proceeding to load available data'])
        else
            temp=load([files{file_ctr},'-FAST-processed.mat']);
            IC_data.(legal_file_name).fast_IC=temp.data;
        end         

        if MP_flag~=2
            disp(['MP sensors IC recording missing for file ',files{file_ctr},', proceeding to load available data'])
        else
            temp=load([files{file_ctr},'-MP-processed.mat']);
            IC_data.(legal_file_name).mp_IC=temp.data;
        end

    end
    
    %move back to directory above IC
    cd(dirChoice)
    
    %store data in workspace
    assignin('base','IC_data',IC_data)
    %call gui for plotting
    %fix hyphens
    for file_ctr=1:fileCounter
        files_legal_name{file_ctr}=strrep(files{file_ctr},'-','_');
    end
    timing.fast=0.1;
    timing.slow=1;
    timing.MP=0.1;
    %files have substituted _ for every -, otherwise it doesn't work as a
    %field name, thus I'm also passing the original list handles.file.name,
    %so that the function below can refer to files in directories
    gui_IC(IC_data,files_legal_name,timing,IC_directory,dirChoice,files);
%     profile VIEWER
    %now having all appropriate data, open GUI
end