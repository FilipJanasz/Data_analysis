close all
clear all
clc


data=load('xxx');
ff=fields(data);

mean(data.HE9601_I.Data)
cutAt=100;

for n=1:numel(ff)
    try
        data.(ff{n}).Data = data.(ff{n}).Data(cutAt:end);
    catch
        data.(ff{n});
    end
end


mean(data.HE9601_I.Data)
for n=1:numel(ff)
    eval([ff{n},'=data.',(ff{n}),';']);
end

clear ans cutAt ff n data
save('xxx')