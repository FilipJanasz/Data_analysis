function [CFD_time,CFD_dist,file]=load_CFD(handles)
     try   
%         default_dir='D:\CFD\Results';
        default_dir=uigetdir('D:\CFD2018\results');
        try
            %find files based on characteristic
            [directoryFile, file_listTime]=fileFinder('.out',1,default_dir,0);    % files with time-resolved data        
            fileAmountTime=numel(file_listTime);
            uniqueTimefile=unique(file_listTime);  %every dir has the same files in them
            [~, file_listDist]=fileFinder('.txt',1,default_dir,0);    % files with line distributions   
            fileAmountDist=numel(file_listDist);
            uniqueDistfile=unique(file_listDist); %every dir has the same files in them
            
            uniqueDir=unique(directoryFile); %every dir has the same files in them
            dirAmount=numel(uniqueDir);
        catch
            error('Files not chosen, retry and point to files to be processed')
        end
        
        % start waitbar
        h = waitbar(0,'Loading data, please wait');
        waitBarCntr=1;
        
        filesTotal=fileAmountTime+fileAmountDist;
         
        for dirCnt=1:dirAmount
            
            file(dirCnt).name=uniqueDir{dirCnt};
            file(dirCnt).directory=uniqueDir{dirCnt};

            for fcTime=1:numel(uniqueTimefile)
                
                    
        
                    currFile=file_listTime{fcTime};
                    currPath=[uniqueDir{dirCnt},'\',currFile,'.out'];
                    try
                        [timing, timeVar,~]=CFDreadTime(currPath);
                    catch
                        disp(['File ',currPath,' is empty'])
                        timeVar=zeros(100,1);
                    end

                    %fix units
                    if contains(currFile,'Temp')
                        timeVar=timeVar-273.15;  
                    elseif contains(currFile,'press')
                        timeVar=timeVar./100000;  
                    elseif contains(currFile,'udm4')
                        timeVar=-timeVar.*(2*pi);  
                    elseif contains(currFile,'MFlow')
                        timeVar=timeVar.*(2*pi);  
                    end
                    
                    CFD_time(dirCnt).(currFile).time=timing;
                    CFD_time(dirCnt).(currFile).var=timeVar;
                    CFD_time(dirCnt).(currFile).value=mean(timeVar(end-20:end));  %average ten last values
                    CFD_time(dirCnt).(currFile).std=std(timeVar(end-20:end));
                    CFD_time(dirCnt).(currFile).error=1;
                    CFD_time(dirCnt).(currFile).unit='NA';

                    %fancy bling wait bar:
                    waitbar(waitBarCntr/filesTotal,h)
                    waitBarCntr=waitBarCntr+1;
            end
            
            %sometimes distribution files are missing, so try catch
            if numel(uniqueDistfile)>0
                for fcDist=1:numel(uniqueDistfile)
                        currFile=file_listDist{fcDist};
                        currPath=[uniqueDir{dirCnt},'\',currFile,'.txt'];
                        try
                            [position, distribution,~]=CFDreadDist(currPath);
                        catch
                            disp(['File ',currPath,' is empty'])
                            position=1:1:100;
                            distribution=zeros(numel(position),1);
                        end

                        %fix units
                        if contains(currFile,'temp')
                            distribution=distribution-273.15; 
                        elseif contains(currFile,'press')
                            distribution=distribution./100000;
                        elseif contains(currFile,'udm4')
                            distribution=-distribution.*(2*pi); 
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
            else
                CFD_dist(1).empty.position_y=0;  %to align with measurements
                CFD_dist(1).empty.var=0;
                CFD_dist(1).empty.error=1;
                CFD_dist(1).empty.unit='NA';
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