function [timeStep, value,varName]=CFDreadTime(fileName)
    
    %open file
    fid=fopen(fileName);
    
    %skip to first lines to get to data
    fgetl(fid);
    header=fgetl(fid);
    pos=find(header=='"');
    varName=header(pos(3)+1:pos(4)-1);
    
    %get data and store
    data=textscan(fid,'%f32%f32');
    timeStep=data{1};
    value=data{2};
    
    %close file
    fclose(fid);

end