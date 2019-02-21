function [offset,offset_TC]=fixHeatLosses(steamPower,coolantdT)

%way to get coefficients for polynomial
% lookUpTable=[99.0581, 120.9117, 131.8601, 141.7365 ; 0.0027, 244.5844, 303.7459, 365.5879];  %based on NOFLUX recordings, where temp steam = temp coolant
% p=polyfit(lookUpTable(1,:),lookUpTable(2,:),2);

% lookUpTable_TC=[100.4545, 121.2022, 134.2322, 144.3299 ; 8.0024, 143.6114, 233.1409, 304.3527];  %based on NOFLUX recordings, where temp steam = temp coolant
% p_TC=polyfit(lookUpTable_TC(1,:),lookUpTable_TC(2,:),2);
% 
% lookUpTable=[100.4545, 121.2022, 134.2322, 144.3299 ; 335.6214,738.5609,916.0640,973.9001];
% p=polyfit(lookUpTable(1,:),lookUpTable(2,:),2);
% 

% p=[-0.2229,69.2365,-4.3719e+03];
% p_TC=[0.0093    4.4823 -536.0159];


offset=ones(1,numel(coolantdT));
% offset_TC=ones(1,numel(coolantTemp));

p=[13.55,0.9884,-2176];

% if std(coolantdT)<0.1
    dT=mean(coolantdT);    
    stPow=mean(steamPower);
    tempOffset=p(1) + p(2)*stPow + p(3)*dT;
    offset=offset.*tempOffset; 
    offset_TC=offset;
% else
%     for n=1:numel(coolantTemp)
%         dT=coolantTemp(n);
%         offset(n)=p(1)*dT^2 + p(2)*dT + p(3);
%         offset_TC(n)=p_TC(1)*dT^2 + p_TC(2)*dT + p_TC(3);
%     end
% end