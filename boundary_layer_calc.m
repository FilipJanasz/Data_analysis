function [boundary_layer,calc_dat_norm,calc_data_norm_lower,calc_data_norm_upper,x_dat,y_dat]=boundary_layer_calc(y_dat,x_dat,av_window,lim_factor,position_lim)
   
    %initialize flags
    flag_st=0;
  
    %calc cutoff - process only restricted positions
    x_dat(x_dat<position_lim)=[];
    y_dat=y_dat(end-numel(x_dat)+1:end);
    
    %convert av_window in % of the available positions to data points
    av_window=ceil(av_window/100*numel(x_dat));
    
    calc_dat=y_dat;
    calc_dat_norm=calc_dat./median(calc_dat);
  
    %preallocate
    st_dev_local=zeros(1,numel(calc_dat)-1);
    
    %calculate standart deviation for every point, based on neighbourhood
    %described by av_window
    for i=2:numel(calc_dat)
        set_st=i-av_window/2;
        set_end=i+av_window/2;

        %if there's not enough points on left or right of the point
        if set_st<1
            set_st=1;
        end
        if set_end>numel(calc_dat_norm)
            set_end=length(calc_dat_norm);
        end

        %define the interval based on start and end conditions
        sub_var=calc_dat_norm(set_st:set_end);
        
        %calculate st_dev for this interval and store it
        st_dev_local(i-1)=std(sub_var);

    end
    
    % get the mode of all st_devs (more resistant than median)
    st_dev_mode=mode(st_dev_local);

    %while loop flag
    flag=1;
    
    % points_min=1/3*numel(calc_data_norm);
    while_count=0;
    while flag==1 && while_count<10
        
        %safety switch to exit the loop
        while_count=while_count+1;
        
        % get lower and upper bonds for the data
         calc_data_norm_lower=median(calc_dat_norm)-lim_factor*st_dev_mode;
        calc_data_norm_upper=median(calc_dat_norm)+lim_factor*st_dev_mode;

        % if those values are to low
        if calc_data_norm_lower>0.99925
            calc_data_norm_lower=0.99925;
        end

        if calc_data_norm_upper<1.00075
            calc_data_norm_upper=1.00075;
        end

        bl_points=find(calc_dat_norm<calc_data_norm_lower);  %points that lie below assumd border belong to boudnary layer

        %in case none of the points fit the desired conditions, lessen the
        %restriction (in form of lim_factor_effective

        if ~isempty(bl_points)% && numel(points)>points_min
            flag=0;
        else
            lim_factor=lim_factor+0.1;
        end
    end
    
    %transpose points vector
    bl_points=bl_points';
    try
        bl_points_extra=[bl_points(2:end) bl_points(end)-1];
    catch
%         errordlg('Boundary layer not found - adjust parameters and check the data')
        error('Boundary layer not found - adjust parameters and check the data')
    end
    % substract values from those two vectors of positions 
    % you get zeros in the result, where the points where consecutive
    substr=abs(bl_points-bl_points_extra)-1;
    if substr(1)==0
        substr(1)=1;
    end

    % locate where are all non zero elements
    % basically, all keep the structure of vector substr but replace all non
    % zero values with ones
    position_vec=substr~=0;
    
    % make sure there's at least one starting and ending point pair
    if position_vec(1)==0 && position_vec(2)==0
        position_vec(1)=1;
        flag_st=1;
    end

    % find starts of each chain of zeros
    boundary_layer_start=strfind(position_vec,[1 0])+1;
    if flag_st
        boundary_layer_start(1)=boundary_layer_start(1)-1;
    end

    % if no chain exists
    if isempty(boundary_layer_start)
%         errordlg('Boundary layer not found - adjust parameters and check the data')
        error('Boundary layer not found - adjust parameters and check the data')
    end
    
    % max added to ensure that code only finds right - most position
    % (closest to the wall in PRECISE)
    % the others are false - positives
    boundary_layer=max(x_dat(bl_points(boundary_layer_start)-1));
    
end
