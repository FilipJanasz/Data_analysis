function varargout = gui_distributions(varargin)
    % Edit the above text to modify the response to help gui_distributions

    % Last Modified by GUIDE v2.5 19-May-2019 15:27:12

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_distributions_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_distributions_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT

% --- Executes just before gui_distributions is made visible.
function gui_distributions_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gui_distributions (see VARARGIN)

    % Choose default command line output for gui_distributions
    handles.output = hObject;
    handles.data=varargin{1};
    handles.files=varargin{2};
    handles.filepath=varargin{3};
    vars=fields(handles.data);
    handles.plotcounter=0;
    %set fields for calibrated option popupmenu
    calibration_option={'cal','non_cal'};

    %sett file popup menu proeprly
    set(handles.file_popupmenu,'String',handles.files)
    set(handles.file_popupmenu,'Value',1);

    %set vars popup menu properly
    set(handles.var_popupmenu,'String',vars)
    set(handles.var_popupmenu,'Value',1);

    %set val popup menu properly
    set(handles.cal_popupmenu,'String',calibration_option)
    set(handles.cal_popupmenu,'Value',1);

    %set post callback function to zoom utility
    set(zoom,'ActionPostCallback',@(x,y) adjustLimits(handles));
    set(pan,'ActionPostCallback',@(x,y) adjustLimits(handles));

    % Update handles structure
    guidata(hObject, handles);

function adjustLimits(handles)
    x=round(xlim(handles.var_axes),1);
    y=round(ylim(handles.var_axes),2);

    handles.xmin_edit.String=num2str(x(1));
    handles.xmax_edit.String=num2str(x(2));
    handles.ymin_edit.String=num2str(y(1));
    handles.ymax_edit.String=num2str(y(2));
    
    %fix axes colors
    yyaxis right
    handles.var_axes.YColor=[0.1500    0.1500    0.1500];
    yyaxis left
    handles.var_axes.YColor=[0.1500    0.1500    0.1500];
    yyaxis right
    
    handles.var_axes.XGrid='on';  
    handles.var_axes.XMinorGrid='on';
    handles.var_axes.YGrid='on';
    handles.var_axes.YMinorGrid='on';

% --- Outputs from this function are returned to the command line.
function varargout = gui_distributions_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes on selection change in var_popupmenu.
function var_popupmenu_Callback(hObject, eventdata, handles)
    
    if strfind(handles.var_popupmenu.String{handles.var_popupmenu.Value},'MP_')
        handles.uipanel6.Visible='on';
    else
        handles.uipanel6.Visible='off';
    end
    
    % Update handles structure
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function var_popupmenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in plot_pushbutton.
function plot_pushbutton_Callback(hObject, eventdata, handles)
%     profile on
    %check for which recording plot is to be made
    file=get(handles.file_popupmenu,'Value');
        
    % get user choice for calibration mode
    list_cal=get(handles.cal_popupmenu,'String');
    val_cal=get(handles.cal_popupmenu,'Value');
    calibration_mode=list_cal{val_cal};

    % get choice of phase to be plotted
    list_y=get(handles.var_popupmenu,'String');
    val_y=get(handles.var_popupmenu,'Value');
    y_param=list_y{val_y}; 
    
%get full time varying data for current distributions and it's size
try 
full_matrix=handles.data(file).(y_param).var;
[rows,columns]=size(full_matrix);
timeDat=1;
catch
    timeDat=0;
end
    
    if ~contains(y_param,'RELAP')
        %get user choice for averaging period for distributions and obtain data
        %to plot
        handles.useMeanFlag=handles.useMean_radiobutton.Value;
        if handles.useMeanFlag
            value_dat=handles.data(file).(y_param).value.(calibration_mode);
        else
            %get interval parameters entered by user in GUI
            intervalCenter=str2double(handles.intervalCenter_edit.String);
            intervalWidth=str2double(handles.intervalWidth_edit.String);
            
            %estimate averaging interval start and end based on user entered
            %data
            intervalStart=intervalCenter-floor(intervalWidth/2);
            intervalEnd=intervalCenter+floor(intervalWidth/2);

            if intervalStart<1
                intervalStart=1;
            end
            if intervalEnd>rows
                intervalEnd=rows;
            end

            %calculate average data for given paramteters
            distribution_avg=zeros(1,columns);

            for columnCntr=1:columns
                distribution_avg(columnCntr)=mean(full_matrix(intervalStart:intervalEnd,columnCntr));
            end
            value_dat=distribution_avg;
        end
        
        % get positions
        vertical_pos=handles.data(file).(y_param).position_y;
        horizontal_pos=handles.data(file).(y_param).position_x;
        
    else %if values from relap, do something special 
        value_dat=handles.data(file).(y_param);
        unitLength=80;
        vertical_pos=(unitLength:unitLength:numel(value_dat)*unitLength);
        vertical_pos=vertical_pos-620; %offset proper
        horizontal_pos=zeros(numel(value_dat),1);
    end
    
    %add standard deviations if desired
    st_dev_flag=get(handles.stdev_checkbox, 'Value');
    try
            y_st_dev=handles.data(file).(y_param).std;
            st_dev_available=1;
    catch
            st_dev_available=0;
    end
    
    %if user wants only std values, plot y_st_dev instead of y_dat 
    st_dev_only_flag=get(handles.stdev_only_checkbox, 'Value');
    if st_dev_only_flag && st_dev_available
        value_dat=y_st_dev;
    end
    
    
     
    
    % to lessen the computation burden in case of replotting
    % only replace Y data and keep other parts of graphs untouched
    if handles.replot_checkbox.Value && handles.plotcounter>0
        handles.graph{handles.plotcounter}.YData=value_dat;
        handles.value_dat{handles.plotcounter}=value_dat;
        return
    end
    
    % figure out how many data points are to be plotted
    y_amount=numel(value_dat);
    
    %define axes
    axes(handles.var_axes);
    
    %check if user wants to hold previous graphs
    axes(handles.var_axes);
    hold_flag=get(handles.hold_checkbox, 'Value');
    if ~hold_flag
        hold off
        cla(handles.var_axes)
        xlabel('');
        yyaxis right
        ylabel('');
        yyaxis left
        ylabel('');
        %clear all variables (for same case calling the general clearing
        %function fails to deliver)
        try
            handles=rmfield(handles,'graph_name');
            handles=rmfield(handles,'graph');
            handles=rmfield(handles,'x_dat');
            handles=rmfield(handles,'value_dat');
        catch
        end
        handles.plotcounter=1;    
    else
        hold on
        handles.plotcounter=handles.plotcounter+1;
    end
    
    %check which y axis to use for plotting
    y_axis_flag=get(handles.y_axis_primary,'Value');
    
    if y_axis_flag
        % if clause below clears y axis on the opposite axis if hold flag
        % is off
        if ~hold_flag
            yyaxis right
            handles.var_axes.YTick=[];
        end
        % set the desired axes to plot and restore the axis to be visible
        yyaxis left
        handles.var_axes.YTickMode='auto';
        handles.axischoice{handles.plotcounter}=1;
    else
        % if clause below clears y axis on the opposite axis if hold flag
        % is off
        if ~hold_flag
            yyaxis left
            handles.var_axes.YTick=[];
        end
        % set the desired axes to plot and restore the axis to be visible
        yyaxis right
        handles.var_axes.YTickMode='auto';
        handles.axischoice{handles.plotcounter}=2;
    end
        
    %if clause below allows user to choose plotting direction (along or
    %across the tube, or 3D, but 3D is handled below)
    if handles.axes_flag==1
        x_dat=vertical_pos;
    elseif handles.axes_flag==2
        x_dat=horizontal_pos;
    end
    
    %check and apply smoothing to the data
    if get(handles.smooth_enable,'Value')
        smoothing_type_set=get(handles.smoothing_type,'String');
        smoothing_type_val=get(handles.smoothing_type,'Value');
        smoothing_type=smoothing_type_set{smoothing_type_val};

        frame_size=str2double(get(handles.frame_size,'String'));

        %based on user choice apply appropriate smoothing algorithm
        switch smoothing_type
            case 'Moving Average'  
                value_dat=smooth(value_dat,frame_size,'moving');
            case 'Savitzky-Golay'
                sgolay_order=str2double(get(handles.sgolay_order,'String'));
                value_dat=smooth(value_dat,frame_size,'sgolay',sgolay_order);
            case 'Lowess'
                value_dat=smooth(value_dat,frame_size,'lowess');
            case 'Loess'
                value_dat=smooth(value_dat,frame_size,'loess');
            case 'RLowess'
                value_dat=smooth(value_dat,frame_size,'rlowess');
            case 'RLoess'
                value_dat=smooth(value_dat,frame_size,'rloess');
        end
        
        %forwad info for legend
        smooth_str=[' | smooth ',smoothing_type];
        
    else
        smooth_str='';
    end
    
    % if Normalize box is checked, normalize graph to between 0 an 1
    if get(handles.normalize, 'Value')
        %find and substract minimum (makes min value in the signal = 0)
        min_val=min(value_dat);
        value_dat=value_dat-min_val;
        %find the new maximum and divide by it (makes the max value in the signal =1
        max_val=max(value_dat);
        value_dat=value_dat./max_val;
        %forwad info for legend
        norm_str=' | normalized';
     
    else
        norm_str='';
    end
    
    %check is user wants to plot -y instead of y
    flip_y_axis=get(handles.flip_y_axis,'Value');
    
    if flip_y_axis
        value_dat=-value_dat;
        %forwad info for legend
        flip_str=' | -y';
    else
        flip_str='';
    end
    
    % plot with nice color and get user defined line style
%     colorstring = 'kbgrmcy';
    colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};
    line_style_all=get(handles.line_style, 'String');
    line_style_no=get(handles.line_style, 'Value');
    line_style=line_style_all{line_style_no};
    
    line_marker_all=get(handles.line_marker, 'String');
    line_marker_no=get(handles.line_marker, 'Value');
    line_marker=line_marker_all{line_marker_no};
    
    line_color_all=get(handles.line_color, 'String');
    line_color_no=get(handles.line_color, 'Value');
    line_color=line_color_all{line_color_no};
    
    % arrange user defined styling parameters
    if strcmp(line_color,'auto')
        line_color=colorstring{handles.plotcounter};
    end
    
%     if strcmp(line_marker,'none')
%         line_marker='';
%     end
%     
%     if strcmp(line_style,'none')
%         line_style='';
%     end
    
    %warn if user is about to do something not too smart
    if y_amount>5000 && ~isempty(line_marker)  
        button = questdlg('You''re about to plot a lot of points with line markers enabled - might be slow. Continue with markers?');
        if strcmp(button,'No')
            line_marker='';
        end
    end
    
        inclBounding=handles.minMax.Value;
    
    if inclBounding && timeDat
        hold on
        %calculate bounding array
        distrMin=zeros(1,columns);
        distrMax=zeros(1,columns);
        distrStd=zeros(1,columns);
        for columnCntr=1:columns
            distrMin(columnCntr)=min(full_matrix(:,columnCntr));
            distrMax(columnCntr)=max(full_matrix(:,columnCntr));
            distrStd(columnCntr)=std(full_matrix(:,columnCntr));
        end
        
        x2=[x_dat, fliplr(x_dat)];
        inBetween=[distrMin,fliplr(distrMax)];
%         inBetween=[value_dat-distrStd,fliplr(value_dat+distrStd)];
        fBound=fill(x2,inBetween,'g');
        fBound.FaceAlpha=0.1;
        fBound.FaceColor=colorstring{handles.plotcounter};
        fBound.EdgeAlpha=0.5;

        fBound.EdgeColor=colorstring{handles.plotcounter};
        fBound.Marker='none';
    elseif inclBounding && ~timeDat
        handles.minMax.Value=0;
        waitfor(msgbox("Time resolved data / STD data not available for Min-Max bounding region plotting","Min - Max error"));
    end
    
    %PLOTTING PLOTTING PLOTTING==================================================================
    %depending on user choice, plot along chosen axis, 3D, with or without
    %errorbars
    try
        if get(handles.err_checkbox, 'Value')&& (handles.axes_flag~=3)
            error_bar=ones(length(x_dat),1)*0.1;
            handles.graph{handles.plotcounter}=errorbar(x_dat,value_dat,error_bar,'Color',colorstring(handles.plotcounter),'marker','.');
        elseif handles.axes_flag==3
            colormap(jet)
            x_interp=vertical_pos(1):(vertical_pos(end)-vertical_pos(1))/50:vertical_pos(end);
            y_interp=interp1(vertical_pos,value_dat,x_interp);
            hold on  
            scatter3(vertical_pos,horizontal_pos,value_dat,'filled','MarkerFaceColor',[0 0 0])
            surf(x_interp,[horizontal_pos(1),horizontal_pos(1)+1],[y_interp; y_interp])
            if ~hold_flag
                hold off
            end          
    %         plot3(x_dat,z_dat,y_dat,'Color',colorstring(handles.plotcounter),'marker','.')
            grid on
            set(gca, 'XColor', [0.5 0.5 0.5],'YColor',[0.5 0.5 0.5],'ZColor',[0.5 0.5 0.5])  
        else
            handles.graph{handles.plotcounter}=plot(x_dat,value_dat);
        end
        
        
    catch ME
        display(ME)
        errordlg('Plotting error, check matlab window for details')
    end
    
    h=handles.graph{handles.plotcounter};
    h.Color=line_color;
    h.LineStyle=line_style;
    h.LineWidth=1.5;
    h.Marker=line_marker;
    h.MarkerFaceColor=line_color;
    h.MarkerEdgeColor=line_color;
    h.MarkerSize=14;
    box on
    % add standard deviations if desired
    if st_dev_flag && st_dev_available
        hold on
%         handles.graph{handles.plotcounter+1}=plot(x_dat,y_st_dev,'.-g');
%         handles.graph{handles.plotcounter+2}=plot(x_dat,y_st_dev_max,'.-g');
%         plot(x_dat,value_dat-y_st_dev,'.-g');
%         plot(x_dat,value_dat+y_st_dev,'.-b');
        for std_ctr=1:numel(y_st_dev)
            %plot vertical line with a span od 2 * st dev
            h=line([x_dat(std_ctr),x_dat(std_ctr)],[value_dat(std_ctr)-y_st_dev(std_ctr),value_dat(std_ctr)+y_st_dev(std_ctr)]);
            h.LineWidth=1;
            %add horizontal line ends
            lineLength=4;
            if handles.axes_flag==1
                h_horz1=line([x_dat(std_ctr)-lineLength,x_dat(std_ctr)+lineLength],[value_dat(std_ctr)-y_st_dev(std_ctr),value_dat(std_ctr)-y_st_dev(std_ctr)]);
                h_horz2=line([x_dat(std_ctr)-lineLength,x_dat(std_ctr)+lineLength],[value_dat(std_ctr)+y_st_dev(std_ctr),value_dat(std_ctr)+y_st_dev(std_ctr)]);
                h_horz1.LineWidth=1;
                h_horz2.LineWidth=1;   
            end
        end
        
        if ~hold_flag
            hold off
        end
    elseif st_dev_flag && ~st_dev_available
        msgbox('Standard deviation data not available for the chosen variables / files - omitting')
    end
       

    %add legend and create graph name
    processing_string=[smooth_str,norm_str,flip_str];
    handles.graph_name{handles.plotcounter}=[handles.files{file},' ',y_param,processing_string];
    handles.legend=legend(handles.graph_name{1:end});

    set(handles.legend,'interpreter','none')
    legend_state=get(handles.legend_on,'Value');
    if (legend_state && handles.plotcounter>0)
        set(handles.legend,'Visible','On')   
    elseif handles.plotcounter>0
        set(handles.legend,'Visible','Off')
    end

     %create label strings
    y_paramtxt=strrep(y_param,'_',' ');
    y_paramtxt=strrep(y_paramtxt,'N2','N_2');
    %special case for RELAP files
    if ~contains(y_param,'RELAP') 
        yLabString=[y_paramtxt,'  [',handles.data(file).(y_param).unit,']'];
    else
        yLabString=y_paramtxt;
    end
    
    xLabString='Position [mm]';

    %label axes
    yLab=ylabel(yLabString);
    xLab=xlabel(xLabString);
    
    %edit labels
    xLab.FontSize=str2double(handles.fontX.String);
    yLab.FontSize=str2double(handles.fontY.String);
    
    %store labels
    handles.xLab.String=xLabString;
    handles.yLab.String=yLabString;
    
    %update list of graphs
    set(handles.graph_list,'String',handles.graph_name)
    set(handles.graph_list,'Value', handles.plotcounter)

    %store data in the figure
    handles.value_dat{handles.plotcounter}=value_dat;
    handles.x_dat{handles.plotcounter}=x_dat;
  
    %adjustLimits
    adjustLimits(handles)
    
    %send updated handles back up
    guidata(hObject, handles);

%     profile viewer
% --- Executes on button press in hold_checkbox.
function hold_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on selection change in file_popupmenu.
function file_popupmenu_Callback(hObject, eventdata, handles)
    
    %update recording length
    if  handles.useInterval_radiobutton.Value       
        
        %update file length
        %check for which recording plot is to be made
        file=get(handles.file_popupmenu,'Value');

        % get choice of phase to be plotted
        list_y=get(handles.var_popupmenu,'String');
        val_y=get(handles.var_popupmenu,'Value');
        y_param=list_y{val_y}; 
    
        %get user choice for averaging period for distributions and obtain data
        %to plot
        handles.useMeanFlag=handles.useMean_radiobutton.Value;
        [row,~]=size(handles.data(file).(y_param).var); 
        
        %update text
        handles.recordingLength_text.String=num2str(row);
        
        %update slider
        handles.intervalCenter_slider.Max=row;
        handles.intervalCenter_slider.SliderStep=[1/(row-1) , (0.1*row)/(row-1)];
        handles.intervalCenter_slider.Value=floor(row/2);
        
        %update edit box
        handles.intervalCenter_edit.String=num2str(floor(row/2));
    end

% --- Executes during object creation, after setting all properties.
function file_popupmenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in clear_pushbutton.
function clear_pushbutton_Callback(hObject, eventdata, handles)
    
    %point to right axes
    axes=handles.var_axes;
    
    % clear screen
    clc
    
    % clear axesaxes(handles.var_axes);
    xlabel('');
    yyaxis right
    cla
    ylabel('');
    yyaxis left
    cla
    ylabel('');
    
    % delete legend
    if isfield(handles,'legend')
        delete(handles.legend)
    end
    
    %reset GUI elements
    set(handles.graph_list,'String','NA')
    set(handles.graph_list,'Value', 1)
    
    % reset variables
    handles.plotcounter=0;
    
    %if user presses "clear all" before those fields are created
    %it will throw an error, hence try - catch mess
    try
        handles=rmfield(handles,'graph_name');
        handles=rmfield(handles,'graph');
        handles=rmfield(handles,'x_dat');
        handles=rmfield(handles,'value_dat');
        handles=rmfield(handles,'axischoice');
    catch
    end
    
    guidata(hObject, handles);
    
% --- Executes on button press in line_delete.
function line_delete_Callback(hObject, eventdata, handles)
    
    if handles.plotcounter>1
        %get user choice for deltion
        del_choice=get(handles.graph_list,'Value');

        %delete
        delete(handles.graph{del_choice});
        handles.graph{del_choice}=[];
        handles.graph=handles.graph(~cellfun('isempty',handles.graph));

        %update variables
        handles.plotcounter=handles.plotcounter-1;

        handles.graph_name{del_choice}=[]; %first set desired cell to empty
        handles.graph_name=handles.graph_name(~cellfun('isempty',handles.graph_name)); %remove empty cells
        
        handles.x_dat{del_choice}=[]; %first set desired cell to empty
        handles.x_dat=handles.x_dat(~cellfun('isempty',handles.x_dat)); %remove empty cells
        
        handles.value_dat{del_choice}=[]; %first set desired cell to empty
        handles.value_dat=handles.value_dat(~cellfun('isempty',handles.value_dat)); %remove empty cells
        
        handles.axischoice{del_choice}=[]; %first set desired cell to empty
        handles.axischoice=handles.axischoice(~cellfun('isempty',handles.axischoice)); %remove empty cells

        %redraw updated legend
        handles.legend=legend(handles.graph_name{1:end});
        set(handles.legend,'interpreter','none')
        legend_state=get(handles.legend_on,'Value');
        if (legend_state && handles.plotcounter>0)
            set(handles.legend,'Visible','On')   
        elseif handles.plotcounter>0
            set(handles.legend,'Visible','Off')
        end

        %update GUI
        set(handles.graph_list,'String',handles.graph_name)
        set(handles.graph_list,'Value', handles.plotcounter)
    else
        clear_pushbutton_Callback(hObject, eventdata, handles)
        %for some reason, doesn't work otherwise
        handles.plotcounter=0;
    end
    
    %forward changes in handles
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function toolbar_save_fig_ClickedCallback(hObject, eventdata, handles)
        
    %saving figure is problematic due to two y axes
    % 0. move to file directory, based on default value stored in GUI    
    cd(handles.filepath)
    
    % 1. Ask user for the file name
    saveDataName = uiputfile({'*.png';'*.jpg';'*.pdf';'*.eps';'*.fig';}, 'Save as');
    [~, file_name, ext] = fileparts(saveDataName);

    
    % 2. Save .fig file with the name
    hgsave(handles.var_axes,file_name)

    % 3. Display a hidden figure and load saved .fig to it
    f=figure('Visible','off');
    movegui(f,'center')
    h=hgload(file_name);
    h.Parent=f;   
    f.Position=[300   200   1250   680];
    
    %fix fonts etc
    h.XAxis(1).FontSize=24;
    h.XAxis(1).Label.FontSize=24;
    h.XAxis(1).Label.FontWeight='bold';
    h.Legend.FontSize=20;
%     h.Legend.Location='northeast';
    
    for axN=1:2
        h.YAxis(axN).FontSize=24;
        h.YAxis(axN).Label.FontSize=24;
        h.YAxis(axN).Label.FontWeight='bold'; 
    end
    set(h,'Position',[23 6.8451 201.9200 41.9241])

    for chN=1:numel(h.Children)
        h.Children(chN).LineWidth=2*h.Children(chN).LineWidth;
        h.Children(chN).MarkerSize=2*h.Children(chN).MarkerSize;
    end
    % 4.save again, to desired format, if it is different than fig
    if ~strcmp(ext,'.fig')
        delete([file_name,'.fig']) 
%         set(h,'Position',[23 6.8451 201.9200 41.9241])
        export_fig (saveDataName, '-transparent','-p','0.02')           % http://ch.mathworks.com/matlabcentral/fileexchange/23629-export-fig   
        savefig(f,file_name)
%         set(h,'Position',[23 6.8451 201.9200 41.9241])
        print(f,file_name,'-dmeta')
    else
        savefig(f,file_name)
    end
    delete(f); % clear figure
    msgbox(['Figure saved succesfully as ',saveDataName])


    % --- Executes on selection change in cal_popupmenu.
    function cal_popupmenu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function cal_popupmenu_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in err_checkbox.
function err_checkbox_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function uipanel_buttongroup_CreateFcn(hObject, eventdata, handles)
    handles.axes_flag=1;
    guidata(hObject, handles);

% --- Executes when selected object is changed in uipanel_buttongroup.
function uipanel_buttongroup_SelectionChangeFcn(hObject, eventdata, handles)

    if handles.vertical_radiobutton.Value
        handles.axes_flag=1;
    elseif handles.horizontal_radiobutton.Value
        handles.axes_flag=2;
    elseif handles.threed_radiobutton.Value
        handles.axes_flag=3;
    end
    guidata(hObject, handles);

% --- Executes on button press in normalize.
function normalize_Callback(hObject, eventdata, handles)

% --- Executes on button press in boundary_layer.
function boundary_layer_Callback(hObject, eventdata, handles)
     
    %get user choice
    graph_choice=handles.graph_list.Value;
    graph=handles.graph_name{graph_choice};
    yaxis=handles.axischoice{graph_choice};
    
    %set appropriate y axis
    if yaxis==1
        yyaxis left
    elseif yaxis==2
        yyaxis right
    end
    
    %verify the choice
    if isempty(strfind(graph,'MP')) 
        errordlg('Boundary layer can only be estimated for data from movable probe - pick correct data')
    else         
        %get user preference
        av_window=str2double(handles.av_window.String);
        lim_factor=str2double(handles.lim_factor.String);
        position_lim=str2double(handles.position_lim.String);
        
        %get data
        y_dat=handles.value_dat{graph_choice};
        x_dat=handles.x_dat{graph_choice};
        
        %check if user choice is appropriate
        if av_window>numel(x_dat)
            errordlg('Avg window is larger than the data set - may artificailly underpredict boundary layer thickness')
        end
        
        %call function that does the magic (based on bits and pieces from steady_state.m)
        [boundary_layer,calc_data_norm,calc_data_norm_lower,calc_data_norm_upper,x_dat,y_dat]=boundary_layer_calc(y_dat,x_dat,av_window,lim_factor,position_lim);
       
        %point to main axes
        axes(handles.var_axes);
        hold on
%         hold_flag=get(handles.hold_checkbox, 'Value');
%         if ~hold_flag
%             hold off
%         else
%             hold on
%         end
        
        %increase plot counter
        handles.plotcounter=handles.plotcounter+1;
        
        %PLOTTING PLOTTING PLOTTING
        %plot boundary layer on main graph
        handles.graph{handles.plotcounter}=plot([boundary_layer boundary_layer], ylim,'g');
        box on
        
        %update variables
        handles.x_dat{handles.plotcounter}=[boundary_layer boundary_layer];
        handles.value_dat{handles.plotcounter}=ylim;
        handles.graph_name{handles.plotcounter}=[graph,' boundary_layer'];
        handles.axischoice{handles.plotcounter}=yaxis;

        %update legend
        handles.legend=legend(handles.graph_name{1:end});
        set(handles.legend,'interpreter','none')
        legend_state=get(handles.legend_on,'Value');
        if (legend_state && handles.plotcounter>0)
            handles.legend.Visible='On';   
        elseif handles.plotcounter>0
            handles.legend.Visible='Off';
        end

        %update list of graphs
        handles.graph_list.String=handles.graph_name;  
        
        %Plotting processing graphs
        handles.bl_graph.Value
        if handles.bl_graph.Value
            figure
            subplot(2,1,1)
            hold on
            plot(x_dat,y_dat,'.')
            plot([boundary_layer boundary_layer], ylim,'g')
            
            subplot(2,1,2)
            hold on
            plot(x_dat,calc_data_norm,'.')
            plot([boundary_layer boundary_layer], ylim*0.991,'g')
            plot(xlim,[calc_data_norm_lower calc_data_norm_lower],'--k')
            plot(xlim,[calc_data_norm_upper calc_data_norm_upper],'--k')
            plot(xlim,[median(calc_data_norm) median(calc_data_norm)],'m') 
        end
        
        %update gui
        handles.bl_calc.String=num2str(boundary_layer);
        %forward changes
        guidata(hObject, handles);
    end

% --- Executes on button press in legend_on.
function legend_on_Callback(hObject, eventdata, handles)
    %toggle legend visibility, if there is one
    legend_state=get(handles.legend_on,'Value');

    if (legend_state && handles.plotcounter>0)
        set(handles.legend,'Visible','On')   
    elseif handles.plotcounter>0
        set(handles.legend,'Visible','Off')
    end



% --- Executes on selection change in graph_list.
function graph_list_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function graph_list_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in flip_y_axis.
function flip_y_axis_Callback(hObject, eventdata, handles)

% --- Executes on button press in fit_axes.
function fit_axes_Callback(hObject, eventdata, handles)
    axes(handles.var_axes);
    axis auto
    x=xlim;
    xmin=num2str(x(1));
    xmax=num2str(x(2));
    y=ylim;
    ymin=num2str(y(1));
    ymax=num2str(y(2));
    
    % --- Executes on button press in y_axis_primary.
function y_axis_primary_Callback(hObject, eventdata, handles)

    yyaxis left
%     set(handles.hold_checkbox,'Value', 0);
   
% --- Executes on button press in y_axis_secondary.
function y_axis_secondary_Callback(hObject, eventdata, handles)

    yyaxis right
    % handles.plotcounter=handles.plotcounter+1;
    set(handles.hold_checkbox,'Value', 1);
    guidata(hObject, handles);

% --- Executes on selection change in line_color.
function line_color_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function line_color_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in line_marker.
function line_marker_Callback(hObject, eventdata, handles)

function line_marker_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in line_style.
function line_style_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function line_style_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function av_window_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function av_window_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function lim_factor_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function lim_factor_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in bl_graph.
function bl_graph_Callback(hObject, eventdata, handles)

function position_lim_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function position_lim_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function frame_size_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function frame_size_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in smoothing_type.
function smoothing_type_Callback(hObject, eventdata, handles)
    
    smoothing_type_set=get(handles.smoothing_type,'String');
    smoothing_type_val=get(handles.smoothing_type,'Value');
    smoothing_type=smoothing_type_set{smoothing_type_val};

    %based on user choice hide or reveal extra buttons
    switch smoothing_type  
        case 'Savitzky-Golay'
            set(handles.text25,'Visible','On')
            set(handles.sgolay_order,'Visible','On')
        otherwise
            set(handles.text25,'Visible','Off')
            set(handles.sgolay_order,'Visible','Off')
    end

% --- Executes during object creation, after setting all properties.
function smoothing_type_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function sgolay_order_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function sgolay_order_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in smooth_enable.
function smooth_enable_Callback(hObject, eventdata, handles)
    
    % --- Executes on button press in rescale_pushbutton.
function rescale_pushbutton_Callback(hObject, eventdata, handles)
    if handles.y_axis_primary.Value
        yyaxis left
    else
        yyaxis right
    end
    xmin=str2double(get(handles.xmin_edit,'String'));
    xmax=str2double(get(handles.xmax_edit,'String'));
    ymin=str2double(get(handles.ymin_edit,'String'));
    ymax=str2double(get(handles.ymax_edit,'String'));
    set(handles.var_axes,'xlim',[xmin xmax])
    set(handles.var_axes,'ylim',[ymin ymax])


% --- Executes on button press in fitaxes_pushbutton.
function fitaxes_pushbutton_Callback(hObject, eventdata, handles)
    axes(handles.var_axes);
    axis auto
    x=xlim;
    xmin=num2str(x(1));
    xmax=num2str(x(2));
    y=ylim;
    ymin=num2str(y(1));
    ymax=num2str(y(2));
    set(handles.xmin_edit,'String',xmin)
    set(handles.xmax_edit,'String',xmax)
    set(handles.ymin_edit,'String',ymin)
    set(handles.ymax_edit,'String',ymax)

function xmax_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function xmax_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function ymin_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ymin_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function ymax_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ymax_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function xmin_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function xmin_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in stdev_checkbox.
function stdev_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in stdev_only_checkbox.
function stdev_only_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in useMean_radiobutton.
function useMean_radiobutton_Callback(hObject, eventdata, handles)
    handles.useInterval_radiobutton.Value=~handles.useMean_radiobutton.Value;
    %if interval is to be used
    if  ~handles.useMean_radiobutton.Value
        handles.interval_uipanel.Visible='on';
        
        %update file length
        %check for which recording plot is to be made
        file=get(handles.file_popupmenu,'Value');

        % get choice of phase to be plotted
        list_y=get(handles.var_popupmenu,'String');
        val_y=get(handles.var_popupmenu,'Value');
        y_param=list_y{val_y}; 
    
        %get user choice for averaging period for distributions and obtain data
        %to plot
        handles.useMeanFlag=handles.useMean_radiobutton.Value;
        [row,~]=size(handles.data(file).(y_param).var);
        
        %update text
        handles.recordingLength_text.String=num2str(row);
        
        %update slider
        handles.intervalCenter_slider.Max=row;
        handles.intervalCenter_slider.SliderStep=[1/(row-1) , (0.1*row)/(row-1)];
        handles.intervalCenter_slider.Value=floor(row/2);
        
        %update edit box
        handles.intervalCenter_edit.String=num2str(floor(row/2));
        
    else
        handles.interval_uipanel.Visible='off';
    end

% --- Executes on button press in useInterval_radiobutton.
function useInterval_radiobutton_Callback(hObject, eventdata, handles)
    handles.useMean_radiobutton.Value=~handles.useInterval_radiobutton.Value;
    
    %if interval is to be used
    if  handles.useInterval_radiobutton.Value       
        handles.interval_uipanel.Visible='on';
        
        %update file length
        %check for which recording plot is to be made
        file=get(handles.file_popupmenu,'Value');

        % get choice of phase to be plotted
        list_y=get(handles.var_popupmenu,'String');
        val_y=get(handles.var_popupmenu,'Value');
        y_param=list_y{val_y}; 
    
        %get user choice for averaging period for distributions and obtain data
        %to plot
        handles.useMeanFlag=handles.useMean_radiobutton.Value;
        [row,~]=size(handles.data(file).(y_param).var);
        
        %update text
        handles.recordingLength_text.String=num2str(row);
        
        %update slider
        handles.intervalCenter_slider.Max=row;
        handles.intervalCenter_slider.SliderStep=[1/(row-1) , (0.1*row)/(row-1)];
        handles.intervalCenter_slider.Value=floor(row/2);
                
        %update edit box
        handles.intervalCenter_edit.String=num2str(floor(row/2));
        
    else
        handles.interval_uipanel.Visible='off';
    end

function intervalCenter_edit_Callback(hObject, eventdata, handles)
    %control user entered values and correct if necessary
    if str2double(handles.intervalCenter_edit.String)>str2double(handles.recordingLength_text.String)
        handles.intervalCenter_edit.String=handles.recordingLength_text.String;
    elseif str2double(handles.intervalCenter_edit.String)<1
        handles.intervalCenter_edit.String='1';
    end
    handles.intervalCenter_slider.Value=str2double(handles.intervalCenter_edit.String);
    
    %if replotting is desired
    if handles.replot_checkbox.Value
        plot_pushbutton_Callback(hObject, eventdata, handles)
    end

% --- Executes during object creation, after setting all properties.
function intervalCenter_edit_CreateFcn(hObject, eventdata, handles)
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function intervalWidth_edit_Callback(hObject, eventdata, handles)
    %control user entered values and correct if necessary
    if str2double(handles.intervalWidth_edit.String)>str2double(handles.recordingLength_text.String)
        handles.intervalWidth_edit.String=handles.recordingLength_text.String;
    elseif str2double(handles.intervalWidth_edit.String)<1
        handles.intervalWidth_edit.String='1';
    end
    
    %if replotting is desired
    if handles.replot_checkbox.Value
        plot_pushbutton_Callback(hObject, eventdata, handles)
    end

% --- Executes during object creation, after setting all properties.
function intervalWidth_edit_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on slider movement.
function intervalCenter_slider_Callback(hObject, eventdata, handles)
    %adjust value of edit box based on the slider choice, but round to
    %nearest interger - otherwise it's pointless
    handles.intervalCenter_edit.String=num2str(round(handles.intervalCenter_slider.Value));
    
    %if replotting is desired
    if handles.replot_checkbox.Value
        plot_pushbutton_Callback(hObject, eventdata, handles)
    end

% --- Executes during object creation, after setting all properties.
function intervalCenter_slider_CreateFcn(hObject, eventdata, handles)
    %set slider properties
    handles.intervalCenter_slider.Min=1;
    handles.intervalCenter_slider.Max=2;
    handles.intervalCenter_slider.Value=1;

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in replot_checkbox.
function replot_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in storeMovie_checkbox.
function storeMovie_checkbox_Callback(hObject, eventdata, handles)


% --- Executes on button press in play_pushbutton.
function play_pushbutton_Callback(hObject, eventdata, handles)
    handles.replot_checkbox.Value=1;
    centerPos=str2double(handles.intervalCenter_edit.String);
    recordingLength=str2double(handles.recordingLength_text.String);
    %if video save is requested
    if handles.storeMovie_checkbox.Value
        vidObj = VideoWriter([handles.filepath,'\Time evolution ',handles.graph_name{end}]);
        open(vidObj);
    end
    %plotting loop
    while centerPos<recordingLength && ~handles.stop_pushbutton.Value
        plot_pushbutton_Callback(hObject, eventdata, handles)
        centerPos=centerPos+1;
        handles.intervalCenter_edit.String=num2str(centerPos);
        handles.intervalCenter_slider.Value=centerPos;
        if handles.storeMovie_checkbox.Value
            currFrame=getframe(handles.var_axes);
            writeVideo(vidObj,currFrame);

        end
        pause(0.05)
    end
    %switch stop button to default position
    handles.stop_pushbutton.Value=0;
    
    if handles.storeMovie_checkbox.Value
        % Close the file.
        close(vidObj);
    end
    
    
    % Update handles structure
    guidata(hObject, handles);

% --- Executes on button press in stop_pushbutton.
function stop_pushbutton_Callback(hObject, eventdata, handles)

% --- Executes on button press in analyze_pushbutton.
function analyze_pushbutton_Callback(hObject, eventdata, handles)
    
    %check for which recording plot is to be made
    file=get(handles.file_popupmenu,'Value');

    % get choice of phase to be plotted
    list_y=get(handles.var_popupmenu,'String');
    val_y=get(handles.var_popupmenu,'Value');
    y_param=list_y{val_y}; 
    
    
    full_matrix=handles.data(file).(y_param).var;
    [rows,columns]=size(full_matrix);

    %estimate averaging interval start and end based on user entered
    %data
    distribution_avg=zeros(1,rows);
    span=50;
    for rowCntr=1:rows
        intervalStart=rowCntr-span;
        intervalEnd=rowCntr+span;

        if intervalStart<1
            intervalStart=1;
        end
        if intervalEnd>rows
            intervalEnd=rows;
        end

        distribution_avg(rowCntr)=sum(mean(full_matrix(intervalStart:intervalEnd,:)))/columns;

    end
        
        
%     for frameCntr=1:frames
%         distavg=sum(handles.value_dat{handles.plotcounter});
%     end
    figure
    plot(diff(distribution_avg))



% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get handle to current line
    currLine=handles.graph_list.Value;
    try
        h=handles.graph{currLine}.hMain;
    catch
        h=handles.graph{currLine};
    end

    % ger parameters
    colorstring = {'[0, 0.4470, 0.7410]','[0.8500, 0.3250, 0.0980]','[0.9290, 0.6940, 0.1250]','[0.4940, 0.1840, 0.5560]','[0.4660, 0.6740, 0.1880]','[0.3010, 0.7450, 0.9330]','[0.6350, 0.0780, 0.1840]','[0, 0.5, 0]','[1, 0, 0]','[0, 0, 0]','[0,0,1]'};

    line_style_all=get(handles.line_style, 'String');
    line_style_no=get(handles.line_style, 'Value');
    line_style=line_style_all{line_style_no};

    line_marker_all=get(handles.line_marker, 'String');
    line_marker_no=get(handles.line_marker, 'Value');
    line_marker=line_marker_all{line_marker_no};

    line_color_all=get(handles.line_color, 'String');
    line_color_no=get(handles.line_color, 'Value');
    line_color=line_color_all{line_color_no};

    line_width=str2double(handles.line_width.String);

%     marker_color_all=get(handles.marker_color, 'String');
%     marker_color_no=get(handles.marker_color, 'Value');
%     marker_color=marker_color_all{marker_color_no};

    marker_size=str2double(handles.marker_size.String);
    % arrange user defined styling parameters
    if strcmp(line_color,'auto')
        line_color=colorstring{currLine};
    else
        line_color=colorstring{line_color_no-1};
    end

    marker_color=line_color;

    %combine input into line specification string
    spec={line_color,line_style,line_width,line_marker,marker_color,marker_size};

    h.Color=spec{1};
    h.LineStyle=spec{2};
    h.LineWidth=spec{3};
    h.Marker=spec{4};
    h.MarkerFaceColor=spec{5};
    h.MarkerEdgeColor=spec{5};
    h.MarkerSize=spec{6};
    h.Parent.XLabel.String=handles.xLab.String;
    %check which y axis to use for plotting
    y_axis_flag=get(handles.y_axis_primary,'Value');
    if y_axis_flag==1
        yyaxis left
    else
        yyaxis right
    end
    h.Parent.YLabel.String=handles.yLab.String;
    
    h.Parent.XLabel.FontSize=str2double(handles.fontX.String);
    h.Parent.YLabel.FontSize=str2double(handles.fontY.String);
    
    
    if handles.xOffBox.Value
        h.XData=h.XData-str2double(handles.xOffset.String);
    end
    
    % Update handles structure
    guidata(hObject, handles);


function xLab_Callback(hObject, eventdata, handles)
% hObject    handle to xLab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xLab as text
%        str2double(get(hObject,'String')) returns contents of xLab as a double


% --- Executes during object creation, after setting all properties.
function xLab_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xLab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yLab_Callback(hObject, eventdata, handles)
% hObject    handle to yLab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yLab as text
%        str2double(get(hObject,'String')) returns contents of yLab as a double


% --- Executes during object creation, after setting all properties.
function yLab_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yLab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fontX_Callback(hObject, eventdata, handles)
% hObject    handle to fontX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fontX as text
%        str2double(get(hObject,'String')) returns contents of fontX as a double


% --- Executes during object creation, after setting all properties.
function fontX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fontX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fontY_Callback(hObject, eventdata, handles)
% hObject    handle to fontY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fontY as text
%        str2double(get(hObject,'String')) returns contents of fontY as a double


% --- Executes during object creation, after setting all properties.
function fontY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fontY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function line_width_Callback(hObject, eventdata, handles)
% hObject    handle to line_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of line_width as text
%        str2double(get(hObject,'String')) returns contents of line_width as a double


% --- Executes during object creation, after setting all properties.
function line_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function marker_size_Callback(hObject, eventdata, handles)
% hObject    handle to marker_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of marker_size as text
%        str2double(get(hObject,'String')) returns contents of marker_size as a double


% --- Executes during object creation, after setting all properties.
function marker_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xOffset_Callback(hObject, eventdata, handles)
% hObject    handle to xOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xOffset as text
%        str2double(get(hObject,'String')) returns contents of xOffset as a double


% --- Executes during object creation, after setting all properties.
function xOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xOffBox.
function xOffBox_Callback(hObject, eventdata, handles)
% hObject    handle to xOffBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of xOffBox


% --- Executes on button press in minMax.
function minMax_Callback(hObject, eventdata, handles)
% hObject    handle to minMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of minMax
