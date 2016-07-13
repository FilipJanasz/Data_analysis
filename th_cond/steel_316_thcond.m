function th_cond_interp=steel_316_thcond(T)

    data=xlsread('D:\Data\Data_analysis\th_cond\steel_316_thcond.xlsx');
    temp=data(:,1);
    th_cond=data(:,2);
    th_cond_interp=interp1(temp,th_cond,T);
%     plot(temp,th_cond)
%     hold on
%     plot(T,th_cond_interp,'ro')
end