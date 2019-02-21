% function [timeStep, value,varName]=CFDreadDist(fileName)
function [x, value,varName]=CFDreadDist(fileName) %modded 01.08.2018
    %open file
    fid=fopen(fileName);
    
    %skip to first lines to get to data
    fgetl(fid);
    
    %get header
    header=fgetl(fid);
    pos=find(header=='"');
%     varName=header(pos(3)+1:pos(4)-1);
    varName=header(pos(end-1)+1:pos(end)-1);  %modded 01.08.2018
    
    %skip two extra empty lines
    fgetl(fid);
    fgetl(fid);
    
    %get data and store
    data=textscan(fid,'%f32%f32');
%     timeStep=data{1};
%     value=data{2};
    
    x=data{2}; %modded 01.08.2018
    value=data{1};
    
    %close file
    fclose(fid);

end