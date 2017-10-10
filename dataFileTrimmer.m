clc
clear all

trimAt=1300;

file='D:\data\2016.11.18 ContInj\DATA\NC-MFR-ABS-He-4_LEAK.mat';

data=load(file);

% removal_list={'Process_Data','Root','XX','fileFolder','fileName','Time','ci','convertVer'};
% % removal_amount=numel(removal_list);
% 
% data=rmfield(data,removal_list);

allFields=fields(data);

for fieldCntr=1:numel(allFields)
    try
        data.(allFields{fieldCntr}).Data(trimAt:end)=[];   
    catch
    end
end


save(file,'-struct','data')

clear all