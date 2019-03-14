function [RELAP_primary, RELAP_secondary, RELAP_ext]=load_relap(handles)
     try   
%         default_dir=get(handles.file_path_disp,'String');  
        default_dir='D:\Relap5';

%         dirChoice=[dirChoice,'\DATA'];
        try
%             [file_list, fileCounter]=
            %find files based on characteristic
            [directory, file_list]=fileFinder('simplified_for_Matlab',1,default_dir,1);           
            fileAmount=numel(file_list);
        catch
            error('Files not chosen, retry and point to files to be processed')
        end
        
        % add remaining data files
        for fc=1:fileAmount
            file_list_ext{fc}=strrep(file_list{fc},'simplified_for_Matlab','extended_for_Matlab');
        end
        h = waitbar(0,'Loading data, please wait');

            for fc=1:fileAmount
                %load data
                disp(file_list{fc})
                load([directory{fc},'\',file_list{fc}]);    
                load([directory{fc},'\',file_list_ext{fc}]);  
                
                 % get values for primary side
                cutoffs=strfind(directory{fc},'_');
                cutoff=cutoffs(end);
                RELAP_primary(fc).file=[strrep(exp_cmp_data.file,'_output_R_processed_for_Matlab',''),directory{fc}(cutoff:end)];
                var_list_prim=fieldnames(exp_cmp_data.primary);
                for var_cntr_prim=1:numel(var_list_prim)
                    RELAP_primary(fc).(var_list_prim{var_cntr_prim}).value=mean(exp_cmp_data.primary.(var_list_prim{var_cntr_prim})(:,end));
                    RELAP_primary(fc).(var_list_prim{var_cntr_prim}).var=exp_cmp_data.primary.(var_list_prim{var_cntr_prim})(:,end);
                    RELAP_primary(fc).(var_list_prim{var_cntr_prim}).error=0;
                    RELAP_primary(fc).(var_list_prim{var_cntr_prim}).unit='-';
                end   
                
                 % get values for secondary side
                var_list_secondary=fieldnames(exp_cmp_data.secondary);
                for var_cntr_sec=1:numel(var_list_secondary)
                    RELAP_secondary(fc).(var_list_secondary{var_cntr_sec}).value=mean(exp_cmp_data.secondary.(var_list_secondary{var_cntr_sec})(:,end));
                    RELAP_secondary(fc).(var_list_secondary{var_cntr_sec}).var=exp_cmp_data.secondary.(var_list_secondary{var_cntr_sec})(:,end);
                    RELAP_secondary(fc).(var_list_secondary{var_cntr_sec}).error=0;
                    RELAP_secondary(fc).(var_list_secondary{var_cntr_sec}).unit='-';               
                end
               
                % get values from extended list
                var_list_ext=fieldnames(curr_expDat);
                for var_cntr_ext=1:numel(var_list_ext)
                    RELAP_ext(fc).(var_list_ext{var_cntr_ext}).value=curr_expDat.(var_list_ext{var_cntr_ext}).value;
                    RELAP_ext(fc).(var_list_ext{var_cntr_ext}).var=curr_expDat.(var_list_ext{var_cntr_ext}).var;
                    RELAP_ext(fc).(var_list_ext{var_cntr_ext}).error=0;
                    RELAP_ext(fc).(var_list_ext{var_cntr_ext}).unit='-';
                end
                
                % calc wall dT
                RELAP_ext(fc).wall_dT.value=RELAP_primary(fc).tempf.value-RELAP_secondary(fc).tempf.value;
                RELAP_ext(fc).wall_dT.error=0;
                RELAP_ext(fc).(var_list_ext{var_cntr_ext}).unit='-';
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