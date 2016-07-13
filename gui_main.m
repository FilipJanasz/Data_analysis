function [steam, coolant, facility, NC, distributions, file, BC, GHFS, MP,timing]=gui_main(userChoice,plot_flag,st_state_flag,boundary_layer_options,clear_flag)
       %%  PICK A SINGLE FOLDER FOR PROCCESSING  
   if userChoice==1
        %display gui to pick directory
        directories = uigetdir('Pick a directory');
        try
            [file_list, fileCounter]=filter_tdms_files(directories);
            directories={directories};
            dir_amount=1;
            fileCounter={fileCounter};
            %remove .tdms from the string
            file_list=strrep(file_list,'.tdms','');
            file_list={file_list};
        catch
            error('Files not chosen, retry and point to files to be processed')
        end
        
    %% PROCESS ALL SUBFOLDERS OF A CHOSEN FOLDER AND ALL FILES WITHIN THEM
%    elseif userChoice==2
%         %display gui to pick directory
%         directoryname = uigetdir('Pick a directory');
% 
%         try
%             %GET ALL FILES FROM DIRECTORY AND SUBFOLDERS
%             [directories,file_names]=subdir(directoryname);
%             dir_amount=numel(directories);
%             for dir_counter=1:dir_amount
%                 [file_list{dir_counter}, fileCounter{dir_counter}]=filter_tdms_files(directories{dir_counter},file_names{dir_counter});
%                 if file_list{dir_counter}{1}==1
%                     file_list(dir_counter)=[];
%                     directories(dir_counter)=[];
%                     fileCounter(dir_counter)=[];
%                 else
%                     %remove .tdms from the string
%                     file_list{dir_counter}=strrep(file_list{dir_counter},'.tdms','');
%                     %sum amount of files from each directory
%                 end        
%             end
%             %update amount of directories in case some of them were removed by the
%             %loop
%             dir_amount=numel(directories);
%         catch
%             error('Files not chosen, retry and point to files to be processed')
%         end


   
    %% PICK A SINGLE FILE FOR PROCESSING
    elseif userChoice==3

        % point to a file
        [file_list,directories,FilterIndex] = uigetfile('*.tdms','Choose .r file to process','MultiSelect','on');
        try
            %make sure its a cell array 
            if ~iscell(file_list)
                file_list={file_list};
            end            
            fileCounter={1};
            directories={directories};
            dir_amount=1;
            %remove .tdms from the string
            file_list=strrep(file_list,'.tdms','');
            file_list={file_list};
        catch
            error('Files not chosen, retry and point to files to be processed')
        end
    end


    %% PROCESS FILES

    for dir_counter=1:dir_amount
        for fc=1:fileCounter{dir_counter}
            disp(file_list{dir_counter}{fc})
            %if reprocessing
            if clear_flag==1
                disp('Reprocessing - deleting old "processed" files')
                file_to_del_name=[directories{dir_counter},'\','processed_steady_data_',file_list{dir_counter}{fc},'.mat'];   
                delete(file_to_del_name)
                disp(['Deleting file  ','processed_steady_data_',file_list{dir_counter}{fc},'.mat'])
            end
            
            [steam(fc), coolant(fc), facility(fc), NC(fc), distributions(fc), file(fc),BC(fc), GHFS(fc), MP(fc),timing(fc)]=file_processing(plot_flag,file_list{dir_counter}{fc},directories{dir_counter},st_state_flag,boundary_layer_options);
% below is for debugging
%            [steam1, coolant1, facility1, NC1, distributions1, file1,BC1, GHFS1, MP1]=file_processing(plot_flag,file_list{dir_counter}{fc},directories{dir_counter});
%            steam(fc)=steam1;
%            coolant(fc)=coolant1;
%            facility(fc)=facility1;
%            NC(fc)=NC1;
%            distributions(fc)=distributions1;
%            file(fc)=file1;
%            BC(fc)=BC1;
%            GHFS(fc)=GHFS1;
%            MP(fc)=MP1;
        end
    end
    
    disp('-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-')
    disp('Processing of all files completed')
    msgbox('Processing of all files completed')

end
