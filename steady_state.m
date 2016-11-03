function [st_state_start,st_state_end]=steady_state(data,av_window,lim_factor,use_mov_av_flag,interactive_flag,file_list,process_counter,directory)

%initialize flags
flag_st=0;
flag_end=0;
calc_data=data;

%perform moving average to smooth the data if flag is marked

if use_mov_av_flag  
    temp=smooth(calc_data,av_window,'moving');
    calc_data=temp;    
end

calc_data_norm=calc_data./median(calc_data);

%initialize vars
st_dev_local=zeros(1,length(calc_data)-1)

%for each point of data, prepare a set spanning maximally from
%-1/2*av_window to +1/2*av_window points around it
%in this interval, calculate standard deviation
for i=2:length(calc_data)
    set_st=i-av_window/2;
    set_end=i+av_window/2;

    %if there's not enough points on left or right of the point
    if set_st<1
        set_st=1;
    end
    if set_end>numel(calc_data)
        set_end=length(calc_data);
    end

    %define the interval based on start and end conditions
%     set_st
%     set_end
%     numel(calc_data)
    sub_var=calc_data(set_st:set_end);
    %calculate st_dev for this interval and store it
    st_dev_local(i-1)=std(sub_var);

end

% get the median of all st_devs
st_dev_median=median(st_dev_local);


%% %FINDING STEADY STATE ONSET
%lim factor - how many st_dev is data allowed to vary
lim_factor_effective=lim_factor;
flag=1;
points_min=1/3*numel(calc_data_norm);
while_count=0;
while flag==1 && while_count<1000
    %safety switch to exit the loop
    while_count=while_count+1;
    % get lower and upper bonds for the data
    calc_data_norm_lower=median(calc_data_norm)-lim_factor_effective*st_dev_median;
    calc_data_norm_upper=median(calc_data_norm)+lim_factor_effective*st_dev_median;
   
    % if those values are to low
    if calc_data_norm_lower>0.99925
        calc_data_norm_lower=0.99925;
    end
    
    if calc_data_norm_upper<1.00075
        calc_data_norm_upper=1.00075;
    end
    
    upper=find(calc_data_norm<calc_data_norm_upper);
    lower=find(calc_data_norm>calc_data_norm_lower);
    points=intersect(lower,upper);
    
    %in case none of the points fit the desired conditions, lessen the
    %restriction (in form of lim_factor_effective
    
    if ~isempty(points) && numel(points)>points_min
        flag=0;
    else
        lim_factor_effective=lim_factor_effective+0.1;
    end
   
end

%transpose points vector
points=points';
points_extra=[points(2:end) points(end)-1];
% 3 substract values from those two vectors of positions 
% you get ones in the result, where the points where consecutive
substr=abs(points-points_extra)-1;
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

if position_vec(end)==0 && position_vec(end-1)==0
    position_vec(end)=1;
    flag_end=1;
end

% if position_vec(end)==0 && position_vec(end-1)==1
% end

% find starts of each chain of zeros
st=strfind(position_vec,[1 0])+1;
if flag_st
    st(1)=st(1)-1;
end

% find ending of each chain of zeros
ed=strfind(position_vec,[0 1]);
if flag_end
    ed(end)=ed(end)+1;
end

% if no chain exists
if isempty(st) && isempty(ed)
    error('-----====== Error: adjust averaging parameters =====-----')
elseif ~isempty(st) && isempty(ed)
    ed=st;
end

% in case we start with a end, remove it
if ed(1)<st(1)
    ed(1)=[];
end

if ed(end)<st(end) && ed(end)~=0
    st(end)=[];
end

% calcualte length of each found chain
st_state_length=(ed-st);
% pick the longest chain and find which chain is it
which_chain=find(st_state_length>max(st_state_length-0.0001));
% find what is the starting location of that chain
% first only among the 
chain_start_loc=points(st(which_chain))+1; % +1 just to be safe
chain_end_loc=points(ed(which_chain));
% st_state_start=chain_start_loc*av_window;
% st_state_end=chain_end_loc*av_window;
st_state_start=chain_start_loc;
st_state_end=chain_end_loc;
if numel(st_state_start)>1 || numel(st_state_end)>1
    st_state_start(2:end)=[];
    st_state_end(2:end)=[];
end


%% Plotting

    graph_dir=[directory,'\figures'];
    if ~exist(graph_dir,'dir')
        mkdir(graph_dir)
    end
    cd(graph_dir)

    if interactive_flag
        h = figure;
        set(h, 'Visible', 'on');
    else
        h = figure;
        set(h, 'Visible', 'off');
    end
    figure_name=['Data ',file_list,' iteration ',num2str(process_counter)];


    subplot(2,1,1)
    hold on
    title(['Masured data: |"',file_list,'"| iteration ',num2str(process_counter)], 'interpreter', 'none')
    plot(data,'.')
    plot([st_state_start st_state_start], ylim,'g')
    plot([st_state_end st_state_end], ylim,'r')
    xlim([-0.05*numel(data),1.05*numel(data)])

    subplot(2,1,2)
    hold on
    title(['Smoothed data: |"',file_list,'"| iteration ',num2str(process_counter)], 'interpreter', 'none')
    plot(calc_data_norm,'.')
    plot(xlim,[calc_data_norm_lower calc_data_norm_lower],'--k')
    plot(xlim,[calc_data_norm_upper calc_data_norm_upper],'--k')
    plot(xlim,[median(calc_data_norm) median(calc_data_norm)],'m') 
    plot([st_state_start st_state_start], ylim,'g')
    plot([st_state_end st_state_end], ylim,'r')
    xlim([-0.05*numel(calc_data_norm),1.05*numel(calc_data_norm)])

    % write graphs to file, as .emf and as .fig
    savefig(h,figure_name)
%     print(h,figure_name,'-dmeta')


end