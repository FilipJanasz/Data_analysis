function [timeStep, value,varName]=CFDreadTime(fileName)
    
    %open file
    fid=fopen(fileName);
    
    %skip to first lines to get to data
    fgetl(fid);
    fgetl(fid);  %added 01.08.2018
    header=fgetl(fid);
    pos=find(header=='"');
%     varName=header(pos(3)+1:pos(4)-1);
    varName=header(pos(end-1)+1:pos(end)-1); %modded 01.08.2018
    
    %get data and store %modded 01.08.2018
    data=textscan(fid,'%f%f%f');
    timeStep=data{2};
    value=data{3};
    
%     data=textscan(fid,'%f32%f32');
%     timeStep=data{1};
%     value=data{2};
%     
    %close file
    fclose(fid);

end