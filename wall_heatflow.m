function heatFlow=wall_heatflow(heatFlux,sensor_pos,mix_layer_start)
        
    %get heat flux until first sensor
    heatFlow_perM=heatFlux(1)*sensor_pos(1)/1000;
    
    %get heat flux in between the sensors
    for n=1:numel(heatFlow_perM)-1
        heatFlow_perM=heatFlow_perM+(heatFlux(n+1)+heatFlux(n))/2*(sensor_pos(n+1)-sensor_pos(n))/1000;
    end
    
    %check how far condensaion front goes
    if mix_layer_start+100 >= sensor_pos(end)
        heatFlow_perM=heatFlow_perM+heatFlux(end)*(mix_layer_start-sensor_pos(end))/1000;        
    end
    heatFlow=heatFlow_perM*pi*0.02;

end