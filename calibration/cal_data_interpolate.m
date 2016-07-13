function interp_data=cal_data_interpolate(steady_data)
    [val,txt]=xlsread('TC_offset');
%     test_temp=mean(steady_data.TF9501);
    for n=1:numel(txt)
        cal_data.(txt{n})=val(:,n);
    end
    
    for m=2:numel(txt)
        try
            interp_data.(txt{m})=interp1(cal_data.Temp,cal_data.(txt{m}),mean(steady_data.(txt{m})));
%             interp_data_new_way(m)=interp_data.(txt{m});
%             interp_data_old_way(m)=interp1(cal_data.Temp,cal_data.(txt{m}),test_temp);            
        catch
        end
    end
%     assignin('base','interp_data',interp_data);
%     assignin('base','interp_data_old_way',interp_data_old_way);
end