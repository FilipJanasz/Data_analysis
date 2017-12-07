function [timeStep, value,varName]=CFDreadDist(fileName)
    
    %open file
    fid=fopen(fileName);
    
    %skip to first lines to get to data
    fgetl(fid);
    
    %get header
    header=fgetl(fid);
    pos=find(header=='"');
    varName=header(pos(3)+1:pos(4)-1);
    
    %skip two extra empty lines
    fgetl(fid);
    fgetl(fid);
    
    %get data and store
    data=textscan(fid,'%f32%f32');
    timeStep=data{1};
    value=data{2};
    
    %close file
    fclose(fid);

end