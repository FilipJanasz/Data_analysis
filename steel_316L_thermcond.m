function currTc=steel_316L_thermcond(temp)

    % data from http://www.ssina.com/composition/temperature.html, 316L steel (1.4404)
    % 1st order polynomial paramteres obtained from
    %     temps=[20 100 200 300];
    %     tcs=[14 14.9 16 17.3];
    %     polyfit(temps,tcs,1)
    
    currTc=0.0117*temp+13.7341;
end