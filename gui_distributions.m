function varargout = gui_distributions(varargin)
    % Edit the above text to modify the response to help gui_distributions

    % Last Modified by GUIDE v2.5 14-Jul-2016 18:02:37

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

    % Update handles structure
    guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = gui_distributions_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes on selection change in var_popupmenu.
function var_popupmenu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function var_popupmenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in plot_pushbutton.
function plot_pushbutton_Callback(hObject, eventdata, handles)

    file=get(handles.file_popupmenu,'Value');
    
    % get user choice for calibration mode
    list_cal=get(handles.cal_popupmenu,'String');
    val_cal=get(handles.cal_popupmenu,'Value');
    calibration_mode=list_cal{val_cal};

    % get choice of x phase to be plotted
    list_y=get(handles.var_popupmenu,'String');
    val_y=get(handles.var_popupmenu,'Value');
    y_param=list_y{val_y}; 
    value_dat=handles.data(file).(y_param).value.(calibration_mode);
    vertical_pos=handles.data(file).(y_param).position_y;
    horizontal_pos=handles.data(file).(y_param).position_x;
      
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
    
    % if Normalize box is checked, normalize graph to between 0 an 1
    if get(handles.normalize, 'Value')
        %find and substract minimum (makes min value in the signal = 0)
        min_val=min(value_dat);
        value_dat=value_dat-min_val;
        %find the new maximum and divide by it (makes the max value in the signal =1
        max_val=max(value_dat);
        value_dat=value_dat./max_val;
    end
    
    % plot with nice color and get user defined line style
    colorstring = 'kbgrmcy';

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
        line_color=colorstring(handles.plotcounter);
    end
    
    if strcmp(line_marker,'none')
        line_marker='';
    end
    
    if strcmp(line_style,'none')
        line_style='';
    end
    
    %warn if user is about to do something not too smart
    if y_amount>5000 && ~isempty(line_marker)  
        button = questdlg('You''re about to plot a lot of points with line markers enabled - might be slow. Continue with markers?');
        if strcmp(button,'No')
            line_marker='';
        end
    end
    
    %combine input into line specification string
    line_spec=[line_style,line_color,line_marker];
    
    %PLOTTING PLOTTING PLOTTING
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
            handles.graph{handles.plotcounter}=plot(x_dat,value_dat,line_spec);
        end
    catch
        errordlg('Plotting error, check matlab window for details')
    end
    box off
    
    %add legend and create graph name
    handles.graph_name{handles.plotcounter}=[handles.files{file},' ',y_param];
    handles.legend=legend(handles.graph_name{1:end});
    
    set(handles.legend,'interpreter','none')
    legend_state=get(handles.legend_on,'Value');
    if (legend_state && handles.plotcounter>0)
        set(handles.legend,'Visible','On')   
    elseif handles.plotcounter>0
        set(handles.legend,'Visible','Off')
    end
    
    %label axes
    ylabel([y_param,'  [',handles.data(file).(y_param).unit,']'], 'interpreter', 'none');
    xlabel('Position [mm]', 'interpreter', 'none')
    
    %update list of graphs
    set(handles.graph_list,'String',handles.graph_name)
    set(handles.graph_list,'Value', handles.plotcounter)
    
    %store data in the figure
    handles.value_dat{handles.plotcounter}=value_dat;
    handles.x_dat{handles.plotcounter}=x_dat;
    
    %send updated handles back up
    guidata(hObject, handles);

% --- Executes on button press in hold_checkbox.
function hold_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on selection change in file_popupmenu.
function file_popupmenu_Callback(hObject, eventdata, handles)

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
        delete(handles.graph{del_choice})
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
    % 1. Ask user for the file name
    saveDataName = uiputfile({'*.png';'*.jpg';'*.pdf';'*.eps';'*.fig';}, 'Save as');
    [~, file_name, ext] = fileparts(saveDataName);

    % 2. Save .fig file with the name
    hgsave(handles.var_axes,file_name)

    % 3. Display a hidden figure and load saved .fig to it
    f=figure('Visible','off','Position',[250,200,800,650]); %size adjusted to match the figure
    movegui(f,'center')
    h=hgload(file_name);
    %VERY CRUCIAL, MAKE SURE THAT AXES BELONG TO THE NEW FIGURE
    %OTHERWISE DOESNT WORK, FOR SOME STUPID REASON
    h.Parent=f;
    %optionally make visible
%         f.Visible='on';
%         f.Name=saveDataName;
    % 4.save again, to desired format, if it different than fig
    if ~strcmp(ext,'.fig')
        delete([file_name,'.fig'])  
        export_fig (saveDataName, '-transparent','-p','0.02')           % http://ch.mathworks.com/matlabcentral/fileexchange/23629-export-fig   
    end
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
    handles.axes_flag=2;
    guidata(hObject, handles);

% --- Executes when selected object is changed in uipanel_buttongroup.
function uipanel_buttongroup_SelectionChangeFcn(hObject, eventdata, handles)

    if get(handles.vertical_radiobutton, 'Value')
        handles.axes_flag=1;
    elseif get(handles.horizontal_radiobutton, 'Value')
        handles.axes_flag=2;
    elseif get(handles.threed_radiobutton, 'Value')
        handles.axes_flag=3;
    end
    guidata(hObject, handles);

% --- Executes on button press in normalize.
function normalize_Callback(hObject, eventdata, handles)

% --- Executes on button press in boundary_layer.
function boundary_layer_Callback(hObject, eventdata, handles)
     
    %get user choice
    graph_choice=get(handles.graph_list,'Value');
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
        av_window=str2double(get(handles.av_window,'String'));
        lim_factor=str2double(get(handles.lim_factor,'String'));
        position_lim=str2double(get(handles.position_lim,'String'));
        
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
        box off
        
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
            set(handles.legend,'Visible','On')   
        elseif handles.plotcounter>0
            set(handles.legend,'Visible','Off')
        end

        %update list of graphs
        set(handles.graph_list,'String',handles.graph_name)  
        
        %Plotting processing graphs
        if get(handles.bl_graph,'Value')
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
        set(handles.bl_calc,'String',num2str(boundary_layer))
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
% hObject    handle to position_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of position_lim as text
%        str2double(get(hObject,'String')) returns contents of position_lim as a double


% --- Executes during object creation, after setting all properties.
function position_lim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to position_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
