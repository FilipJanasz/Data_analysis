clc
clear all
close all
T=300:10:480;
p=1:1:10;

temp_am=length(T);
p_am=length(p);

v=zeros(temp_am,p_am);
cv=zeros(temp_am,p_am);
drho_dT=zeros(temp_am,p_am);
drho_dP=zeros(temp_am,p_am);
    
for i=1:temp_am
    for j=1:p_am
        [v(i,j), cv(i,j),drho_dT(i,j),drho_dP(i,j)]=f_h2o_properties(T(i),p(j));
    end
end

for i=1:temp_am
    for j=1:p_am-1
        dcv_dp(i,j)=(cv(i,j+1)-cv(i,j))/(p(j+1)-p(j));
    end
end
dcv_dp=dcv_dp';
for j=1:p_am
    for i=1:temp_am-1
        dcv_dT(i,j)=(cv(i+1,j)-cv(i,j))/(T(i+1)-T(i));
    end
end