function heatFlow=wall_heatflow(heatFlux,sensor_pos,mix_layer_start)
        
    %convert pos to m from mm
    sensor_pos=sensor_pos./1000;
    
    %get heat flux until first sensor
    heatFlux_perM=heatFlux(1)*sensor_pos(1);
    
%     %get heat flux in between the sensors
%     for n=1:numel(sensor_pos)-1
%         heatFlux_perM=heatFlux_perM+(heatFlux(n+1)+heatFlux(n))/2*(sensor_pos(n+1)-sensor_pos(n));
%     end    
%     
%     %check how far condensaion front goes
%     if mix_layer_start+100 >= sensor_pos(end)
%         heatFlux_perM=heatFlux_perM+heatFlux(end)*(mix_layer_start-sensor_pos(end))/1000;        
%     end
% 
%     heatFlow=heatFlux_perM*pi*0.02;


 %get heat flux in between the sensors
    for n=2:numel(sensor_pos)
        HfAvg=(heatFlux(n-1)+heatFlux(n))/2;       %avg heat flux between sensors
        HfLength=(sensor_pos(n)-sensor_pos(n-1)); %distance between sensors
        heatFlux_perM(n)=HfAvg*HfLength;
    end
    
    %if mixing layer extends beyond the measure of the last sensor, assume
    %some extra heatFlux*m for that area
    if mix_layer_start >= sensor_pos(end)
        extraLength=mix_layer_start/1000-sensor_pos(end);
        heatFlux_perM(end+1)=heatFlux(end)*(extraLength);        
    end
    

    heatFlow=sum(heatFlux_perM.*pi.*0.02);  %times circumference of the tube (remaining part of area measurement)

end