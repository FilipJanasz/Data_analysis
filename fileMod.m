close all
clear all
clc


data=load('D:\data\2016.06.14 VEL-CLNT-NC\DATA\VEL-CLNT-NC-3');
ff=fields(data);
% mean(data.HE9601_I.Data)
% data.HE9601_I.Data=[data.HE9601_I.Data;zeros(110,1)];

mean(data.HE9601_I.Data)
numel(data.HE9601_I.Data)

for n=1:numel(ff)
    try
        data.(ff{n}).Data=[data.(ff{n}).Data;data.(ff{n}).Data(1:100)];
    catch
    end
    eval([ff{n},'=data.',(ff{n}),';']);
end
mean(data.HE9601_I.Data)
numel(data.HE9601_I.Data)
clear ans cutAt ff n data
save('D:\data\2016.06.14 VEL-CLNT-NC\DATA\out')