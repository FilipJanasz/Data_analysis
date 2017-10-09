clc
clear all

trimAt=3500;

file='D:\Data\data4analysis\2016.11.18 Marton Leak Tests\DATA\NC-MFR-ABS-N2-4_LEAK_45.mat';

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