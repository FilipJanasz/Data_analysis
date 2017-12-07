function [CFD_time,CFD_dist]=load_CFD(handles)
     try   
        default_dir='D:\CFD\Results';

        try
            %find files based on characteristic
            [directoryTime, file_listTime]=fileFinder('.out',1,default_dir,0);    % files with time-resolved data        
            fileAmountTime=numel(file_listTime);
            uniqueTimefile=unique(file_listTime);  %every dir has the same files in them
            [directoryDist, file_listDist]=fileFinder('.txt',1,default_dir,0);    % files with line distributions   
            fileAmountDist=numel(file_listDist);
            uniqueDistfile=unique(file_listDist); %every dir has the same files in them
            
            uniqueDir=unique(directoryDist); %every dir has the same files in them
            dirAmount=numel(uniqueDir);
        catch
            error('Files not chosen, retry and point to files to be processed')
        end
        
        % start waitbar
        h = waitbar(0,'Loading data, please wait');
        waitBarCntr=1;
        
        filesTotal=fileAmountTime+fileAmountDist;
         
        for dirCnt=1:dirAmount

            for fcTime=1:numel(uniqueTimefile)
                currFile=file_listTime{fcTime};
                currPath=[uniqueDir{dirCnt},'\',currFile,'.out'];
                [~, timeVar,~]=CFDreadTime(currPath);
                
                %fix units
                if contains(currFile,'temp')
                    timeVar=timeVar-273.15;  
                elseif contains(currFile,'press')
                    timeVar=timeVar./100000;  
                elseif contains(currFile,'udm4')
                    timeVar=-timeVar;  
                end
                
                CFD_time(dirCnt).(currFile).var=timeVar;
                CFD_time(dirCnt).(currFile).value=mean(timeVar(end-20:end));  %average ten last values
                CFD_time(dirCnt).(currFile).std=std(timeVar(end-20:end));
                CFD_time(dirCnt).(currFile).error=1;
                CFD_time(dirCnt).(currFile).unit='NA';

                %fancy bling wait bar:
                waitbar(waitBarCntr/filesTotal,h)
                waitBarCntr=waitBarCntr+1;
            end

            for fcDist=1:numel(uniqueDistfile)
                currFile=file_listDist{fcDist};
                currPath=[uniqueDir{dirCnt},'\',currFile,'.txt'];
                [position, distribution,~]=CFDreadDist(currPath);
                
                %fix units
                if contains(currFile,'temp')
                    distribution=distribution-273.15; 
                elseif contains(currFile,'press')
                    distribution=distribution./100000;
                elseif contains(currFile,'udm4')
                    timeVar=-timeVar;  
                end
                
                CFD_dist(dirCnt).(currFile).value.cal=distribution;
                if contains(currFile,'wall')
                    CFD_dist(dirCnt).(currFile).position_x=ones(1,numel(distribution))*10;
                elseif contains(currFile,'centerline')
                    CFD_dist(dirCnt).(currFile).position_x=zeros(1,numel(distribution));
                else
                    disp('unknown data position type, assiging default x-coordinate, check what is going on')
                    CFD_dist(dirCnt).(currFile).position_x=zeros(1,numel(distribution));
                end
                CFD_dist(dirCnt).(currFile).position_y=position.*1000-200;  %to align with measurements
                CFD_dist(dirCnt).(currFile).var=distribution;
                CFD_dist(dirCnt).(currFile).error=1;
                CFD_dist(dirCnt).(currFile).unit='NA';

               %fancy bling wait bar:
                waitbar(waitBarCntr/filesTotal,h)
                waitBarCntr=waitBarCntr+1;
            end
        end

        close(h) 

        disp('-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-')
        disp('Loading all CFD files completed')
        msgbox('Loading all CFD files completed')
    catch ME
        close(h) 
        msgbox('File processing error, check matlab command window for details')
        rethrow(ME)
    end
end