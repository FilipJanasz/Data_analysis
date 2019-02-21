function s0=GHFSsensitivity(temp,sensorNo)

%polynomials parameters obtained based on calibation data
switch sensorNo
    case 1
%         params=[1.85708718412337e-11, -5.51140171607391e-09, 3.0703482112192e-07, -3.35112878095702e-05];
%         s0=params(1).*temp.^3 + params(2).*temp.^2 + params(3).*temp + params(4);          
        params=[-2.16273698013406e-10, 2.53980695627833e-07, 1.7148700053351e-05];
%         params=[ 1.42792526043756e-09      -1.7136517645688e-07      3.52223143210178e-05];   %noncal
        s0=params(1).*temp.^2 + params(2).*temp.^1 + params(3);  
        
    case 3
%         params=[-1.54979550734357e-11, 6.62624746843647e-09, -1.06998275180135e-06, 1.73325135502836e-05];
%         s0=params(1).*temp.^3 + params(2).*temp.^2 + params(3).*temp + params(4);  
        params=[-5.21638017219409e-10, 3.12276293164821e-07, -1.35998984051081e-06];
%         params=[- 6.65363517703176e-10     -1.82286468085306e-07       2.6893955102986e-05];%noncal
        s0=params(1).*temp.^2 + params(2).*temp.^1 + params(3);
        
    case 2
%         params=[-1.54979550734357e-11, 6.62624746843647e-09, -1.06998275180135e-06, 1.73325135502836e-05];
%         s0=params(1).*temp.^3 + params(2).*temp.^2 + params(3).*temp + params(4);  
        params=[-8.08580338879095e-10, 1.21886577912904e-05];
%         params=[1.13532572723485e-07       7.3021155298948e-06];%noncal
        s0=params(1).*temp + params(2);  
       
    case 4
%         params=[2.59480339448195e-09, -8.23247672463039e-07, 1.7090598022382e-05];
%         s0=params(1).*temp.^2 + params(2).*temp + params(3);  
        params=[2.90314112653402e-09, -9.23349199861565e-07, 9.22945581494838e-05];
%         params=[5.92205564560724e-10     -1.58976346542548e-07       4.8791784960577e-05]; %noncal
        s0=params(1).*temp.^2 + params(2).*temp + params(3); 
end