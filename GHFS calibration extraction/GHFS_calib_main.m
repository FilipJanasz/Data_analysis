function [file,data]=GHFS_calib_main(clear_flag,filePath_default)
%%  PICK A FOLDER FOR PROCCESSING  
         
    %display gui to pick directory
    oldCd=cd;
    cd('D:\Movable Probe\Probe Calibration_Guillaume');
    directories = uigetdir(filePath_default,'Pick a directory');
    cd(oldCd);
    try
        [file_list, fileCounter]=filter_tdms_files(directories);
        directories={directories};
        dir_amount=1;
        fileCounter={fileCounter};
        %remove .tdms from the string
        file_list=strrep(file_list,'.tdms','');
        file_list={file_list};
    catch ME
        error('Files not chosen, retry and point to files to be processed')
    end
        
    %% LOAD & PROCESS FILES
    
    for dir_counter=1:dir_amount
%         cd(directories{dir_counter})  %move to data directory, so it's easier on the user when picking again
        for fc=1:fileCounter{dir_counter}
            disp(file_list{dir_counter}{fc})
            %if reprocessing
            if clear_flag==1
                disp('Reprocessing - deleting old "processed" files')
                file_to_del_name=[directories{dir_counter},'\','processed_data_',file_list{dir_counter}{fc},'.mat'];   
                delete(file_to_del_name)
                disp(['Deleting file  ','processed_steady_data_',file_list{dir_counter}{fc},'.mat'])
            end
            
%             [file(fc),data(fc)]=GHFS_processing_fun(file_list{dir_counter}{fc},directories{dir_counter});
            [fileTemp,dataTemp]=GHFS_processing_fun(file_list{dir_counter}{fc},directories{dir_counter});

            file(fc)=fileTemp;
            data(fc)=dataTemp;
            % below is for debugging
%            [steam1, coolant1, facility1, NC1, distributions1, file1,BC1, GHFS1, MP1]=file_processing(interactive_flag,file_list{dir_counter}{fc},directories{dir_counter},st_state_flag,options);
%            steam(fc)=steam1;
%            coolant(fc)=coolant1;
%            facility(fc)=facility1;
%            NC(fc)=NC1;
%            distributions(fc)=distributions1;
%            file(fc)=file1;
%            BC(fc)=BC1;
%            GHFS(fc)=GHFS1;
%            MP1
%            MP(fc)=MP1
        end
    end

    disp('-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-')
    disp('Processing of all files completed')
    msgbox('Processing of all files completed')

%     figure
%     hold on
%     plot(data.hfx_power.var)
%     plot(data.hfx_dT.var)
%     plot(data.hfx_rad.var)
     
end
    
