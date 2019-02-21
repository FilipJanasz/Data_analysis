function [offset,offset_TC]=fixHeatLosses(coolantTemp)


% BASED ON POWER ONLY
% lookUpTable=[100.4545,121.2022,134.2322,144.3299;335.6187,538.9765,612.3181,608.3122]; %based on NOFLUX recordings, where temp steam = temp coolant
% p=polyfit(lookUpTable(1,:),lookUpTable(2,:),2);
% p=[-0.1649,46.6820,-2.6911e+03];


% BASED ON HEAT LOSSES
%way to get coefficients for polynomial
% lookUpTable_TC=[100.4545, 121.2022, 134.2322, 144.3299 ; 8.0024, 143.6114, 233.1409, 304.3527];  %based on NOFLUX recordings, where temp steam = temp coolant
% p_TC=polyfit(lookUpTable_TC(1,:),lookUpTable_TC(2,:),2);
 
% lookUpTable=[100.4545, 121.2022, 134.2322, 144.3299 ; 335.6214,738.5609,916.0640,973.9001];
% p=polyfit(lookUpTable(1,:),lookUpTable(2,:),2);
p=[-0.2229, 69.2365,-4.3719e+03];
p_TC=[0.0093    4.4823 -536.0159];

offset=ones(1,numel(coolantTemp));
offset_TC=ones(1,numel(coolantTemp));

if std(coolantTemp)<0.1
    temp=mean(coolantTemp);
    
    tempOffset_TC=p_TC(1)*temp^2 + p_TC(2)*temp + p_TC(3);
    offset_TC=offset.*tempOffset_TC;
    
    tempOffset=p(1)*temp^2 + p(2)*temp + p(3);
    offset=offset.*tempOffset; 
    
else
    for n=1:numel(coolantTemp)
        temp=coolantTemp(n);
        offset(n)=p(1)*temp^2 + p(2)*temp + p(3);
        offset_TC(n)=p_TC(1)*temp^2 + p_TC(2)*temp + p_TC(3);
    end
end