function cal_data=cal_data_read
    [val,txt]=xlsread('TC_offset');

    for n=1:numel(txt)
        cal_data.(txt{n})=val(:,n);
    end
end