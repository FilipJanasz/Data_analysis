function [steam, coolant, facility, NC, distributions, file, BC, GHFS, MP,timing]=gui_main(interactive_flag,st_state_flag,clear_flag,handles)
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
    dirChoice=[dirChoice,'\DATA'];
    try
        [file_list, fileCounter]=filter_tdms_files(dirChoice);
        dirChoice={dirChoice};
        dir_amount=1;
        fileCounter={fileCounter};
        %remove .tdms from the string
        file_list=strrep(file_list,'.tdms','');
        file_list={file_list};
    catch
        error('Files not chosen, retry and point to files to be processed')
    end

    %update file path in GUI
    set(handles.file_path_disp,'String',newDefaultDir);
    
    %get options for processing
    fid=fopen('adv_options.txt','rt');
    options=textscan(fid,'%s');
    options=options{1};
    fclose(fid);
    options=str2double(options(2:2:numel(options)));

    
    %% PROCESS FILES
    %start waitbar
    h = waitbar(0,'Loading data, please wait');
    for dir_counter=1:dir_amount
%         cd(directories{dir_counter})  %move to data directory, so it's easier on the user when picking again
        for fc=1:fileCounter{dir_counter}
            disp(file_list{dir_counter}{fc})
            %if reprocessing
            if clear_flag==1
                disp('Reprocessing - deleting old "processed" files')
                file_to_del_name=[dirChoice{dir_counter},'\','processed_steady_data_',file_list{dir_counter}{fc},'.mat'];   
                delete(file_to_del_name)
                disp(['Deleting file  ','processed_steady_data_',file_list{dir_counter}{fc},'.mat'])
            end
            
            [steam(fc), coolant(fc), facility(fc), NC(fc), distributions(fc), file(fc),BC(fc), GHFS(fc), MP(fc),timing(fc)]=file_processing(interactive_flag,file_list{dir_counter}{fc},dirChoice{dir_counter},st_state_flag,options);

            %fancy bling wait bar:
            waitbar(fc/fileCounter{dir_counter},h)
           
            % below is for debugging
%            [steam1, coolant1, facility1, NC1, distributions1, file1,BC1, GHFS1, MP1, timing1]=file_processing(interactive_flag,file_list{dir_counter}{fc},directories{dir_counter},st_state_flag,options);
%            steam(fc)=steam1;
%            coolant(fc)=coolant1;
%            facility(fc)=facility1;
%            NC(fc)=NC1;
%            distributions(fc)=distributions1;
%            file(fc)=file1;
%            BC(fc)=BC1;
%            GHFS(fc)=GHFS1;
%            MP(fc)=MP1;
%            timing1
%            timing(fc)=timing1;
        end
    end
    
    %close waitbar
    close(h) 
    
    disp('-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-')
    disp('Processing of all files completed')
    msgbox('Processing of all files completed')

end
