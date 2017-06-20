function RELAP_dat=load_relap(handles)
     try   
%         default_dir=get(handles.file_path_disp,'String');  
        default_dir='D:\Data\Relap5';

%         dirChoice=[dirChoice,'\DATA'];
        try
%             [file_list, fileCounter]=
            %find files based on characteristic
            [directory, file_list]=fileFinder('simplified_for_Matlab',1,default_dir,1);           
            fileAmount=numel(file_list);
        catch
            error('Files not chosen, retry and point to files to be processed')
        end
        
        h = waitbar(0,'Loading data, please wait');

            for fc=1:fileAmount
                disp(file_list{fc})
                load([directory{fc},'\',file_list{fc}]);
                RELAP_dat(fc).file=exp_cmp_data.file;
                % get parameters for primary side
                var_list=fieldnames(exp_cmp_data.primary);
                for var_cntr=1:numel(var_list)
                    RELAP_dat(fc).(var_list{var_cntr}).value=mean(exp_cmp_data.primary.(var_list{var_cntr})(:,end));
                    RELAP_dat(fc).(var_list{var_cntr}).var=exp_cmp_data.primary.(var_list{var_cntr})(:,end);
                    RELAP_dat(fc).(var_list{var_cntr}).error=0;
                    RELAP_dat(fc).(var_list{var_cntr}).unit='-';
                end
                %fancy bling wait bar:
                waitbar(fc/fileAmount,h)
            end


            %close waitbar
            close(h) 

            disp('-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-')
            disp('Processing of all files completed')
            msgbox('Processing of all files completed')
    catch ME
        close(h) 
        msgbox('File processing error, check matlab command window for details')
        rethrow(ME)
    end
end