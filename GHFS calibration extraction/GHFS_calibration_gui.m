function varargout = GHFS_calibration_gui(varargin)
    % profile on
    clc
    % Determine where your m-file's folder is.
    script_folder = fileparts(which(mfilename)); 
    % Add that folder plus all subfolders to the path.
    addpath(genpath(script_folder));
    cd(script_folder)
    cd ..
    mainfold=cd;
    addpath(mainfold);
    addpath('D:\Data_analysis\errorbarxy');
    addpath('D:\Data_analysis\convertTDMS');

    % GHFS_CALIBRATION_GUI MATLAB code for GHFS_calibration_gui.fig
    %      GHFS_CALIBRATION_GUI, by itself, creates a new GHFS_CALIBRATION_GUI or raises the existing
    %      singleton*.
    %
    %      H = GHFS_CALIBRATION_GUI returns the handle to a new GHFS_CALIBRATION_GUI or the handle to
    %      the existing singleton*.
    %
    %      GHFS_CALIBRATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GHFS_CALIBRATION_GUI.M with the given input arguments.
    %
    %      GHFS_CALIBRATION_GUI('Property','Value',...) creates a new GHFS_CALIBRATION_GUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GHFS_CALIBRATION_GUI before GHFS_calibration_gui_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to GHFS_calibration_gui_OpeningFcn via varargin.
    %
    %      *See GHFS_CALIBRATION_GUI Options on GUIDE's Tools menu.  Choose "GHFS_CALIBRATION_GUI allows only one
    %      instance to run (singleton)".
    %

    % Edit the above text to modify the response to help GHFS_calibration_gui
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @GHFS_calibration_gui_OpeningFcn, ...
                       'gui_OutputFcn',  @GHFS_calibration_gui_OutputFcn, ...
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

% --- Executes just before GHFS_calibration_gui is made visible.
function GHFS_calibration_gui_OpeningFcn(hObject, ~, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to GHFS_calibration_gui (see VARARGIN)
    % Choose default command line output for GHFS_calibration_gui
    handles.output = hObject;
    handles.plotcounter=0;
    handles.clear_old_flag=0;
    handles.adv_options_flag=0;
    logo=imread('precise_logo.png');
    axes(handles.logo_axes);
    imshow(logo);
    % Update handles structure
    guidata(hObject, handles);
% profile viewer
    % UIWAIT makes GHFS_calibration_gui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GHFS_calibration_gui_OutputFcn(~, ~, handles) 

    % Get default command line output from handles structure
    % varargout{1} = handles.output;
    % h = findobj('Tag','pushbutton1');
    % varargout{2} = getappdata(h,'result');

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in process_btn.
function process_btn_Callback(hObject, ~, handles)
    % profile on
    clear data

    %update handles structure
    guidata(hObject, handles)
    
    % based on user choice, acces and process picked files
    clear_flag=0;
    handles.file_path_disp
    filePath_default=get(handles.file_path_disp,'String'); 
    
    % call function down the line for file processing
    [file,data]=GHFS_calib_main(clear_flag,filePath_default);
    
    %transfer data to handles structure
    handles.data=data;
    handles.file=file;
  
    % push the data to main workspace, just in case
    assignin('base','GHFS_data',handles.data)
    assignin('base','GHFS_file',handles.file)
    
    % based on what variables are present, set possible choices to
    % popupmenus for plotting
%     vars={'steam','coolant','facility','NC','BC','GHFS','MP'};
    vars=fields(data);
    vars=vars';

    set(handles.popupmenu_x_axis,'String',vars)
    set(handles.popupmenu_y_axis,'String',vars)

    %two lines below reset popupmenu values to first object on the list
    set(handles.popupmenu_x_axis,'Value',1);
    set(handles.popupmenu_y_axis,'Value',1);
    
    %update data selector listbox
    file_list={file(1:end).name};
    set(handles.plot_exclude,'String',file_list)
    mark_file=1:1:numel(file_list);
    set(handles.plot_exclude,'Value',mark_file)
    
    %update handles structure
    guidata(hObject, handles)
%     profile viewer
    
    % --- Executes on button press in reprocess_btn.
function reprocess_btn_Callback(hObject, eventdata, handles)
%     profile on
    %essentially the same as process, but with different flag
    clear steam coolant facility NC distributions file BC GHFS MP timing

    % based on user choice, access and process picked files
    clear_flag=1;
    filePath_default=get(handles.file_path_disp,'String'); 
    
    % call function down the line for file processing
    [file,data]=GHFS_calib_main(clear_flag,filePath_default);
    
    %transfer data to handles structure
    handles.data=data;
    handles.file=file;
    
    % push the data to main workspace, just in case
    assignin('base','GHFS_data',handles.data)
    assignin('base','GHFS_file',handles.file)

    % based on what variables are present, set possible choices to
    % popupmenus for plotting
%     vars={'steam','coolant','facility','NC','BC','GHFS','MP'};
    vars=fields(data);

    set(handles.popupmenu_x_axis,'String',vars)
    set(handles.popupmenu_y_axis,'String',vars)

    %two lines below reset popupmenu values to first object on the list
    set(handles.popupmenu_x_axis,'Value',1);
    set(handles.popupmenu_y_axis,'Value',1);

    %update data selector listbox
    file_list={file(1:end).name};
    set(handles.plot_exclude,'String',file_list)
    mark_file=1:1:numel(file_list);
    set(handles.plot_exclude,'Value',mark_file)
    
    %update handles structure
    guidata(hObject, handles)
%     profile viewer

function plot_button_Callback(hObject, eventdata, handles)
%     profile on
    %make sure data is loaded
    if ~isfield(handles,'data')
        errordlg('No data available for plotting - load data first')
    end
    
    % get choice of files to be plotted
    file_choice=get(handles.plot_exclude,'Value');
    files_chosen=numel(file_choice);

    % get choice of x/y axis phase to be plotted
    list_x=get(handles.popupmenu_x_axis,'String');
    list_y=get(handles.popupmenu_y_axis,'String');
    val_x=get(handles.popupmenu_x_axis,'Value');
    val_y=get(handles.popupmenu_y_axis,'Value');
    x_param_var=list_x{val_x};
    y_param_var=list_y{val_y};        
      
    %allocate
    x_dat=ones(1,files_chosen);
    y_dat=ones(1,files_chosen);
    x_err=ones(1,files_chosen);
    y_err=ones(1,files_chosen);
    
    %extract data values and error values, applying file choice filter
    for cntr=1:files_chosen
        x_dat(cntr)=handles.data(file_choice(cntr)).(x_param_var).value;
        y_dat(cntr)=handles.data(file_choice(cntr)).(y_param_var).value;
        x_err(cntr)=handles.data(file_choice(cntr)).(x_param_var).error;
        y_err(cntr)=handles.data(file_choice(cntr)).(y_param_var).error;
    end

    %get units for the plot
    x_unit=handles.data(1).(x_param_var).unit;
    y_unit=handles.data(1).(y_param_var).unit;
    
    hold_flag=get(handles.hold_checkbox, 'Value');
 
    %point to plotting axes and clear them
    axes(handles.var_axes);
        
    if  ~hold_flag
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
            handles=rmfield(handles,'y_dat');
        catch
        end
        handles.plotcounter=1;
        cla
    else
        hold on
        handles.plotcounter=handles.plotcounter+1;
    end
    
     % if Normalize box is checked, normalize graph to between 0 an 1
    if get(handles.normalize, 'Value')
        %find and substract minimum (makes min value in the signal = 0)
        min_val=min(y_dat);
        y_dat=y_dat-min_val;
        %find the new maximum and divide by it (makes the max value in the signal =1
        max_val=max(y_dat);
        y_dat=y_dat./max_val;
        %forwad info for legend
        norm_str=' | normalized';
     
    else
        norm_str='';
    end
    
    %check is user wants to plot -y instead of y
    flip_y_axis=get(handles.flip_y_axis,'Value');
    
    if flip_y_axis
        y_dat=-y_dat;
        %forwad info for legend
        flip_str=' | -y';
    else
        flip_str='';
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
    
    %line styling
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
    
    %combine input into line specification string
    line_spec=[line_style,line_color,line_marker];
    
    %check if user wants errorbars
    xerr_flag=get(handles.xerr_checkbox, 'Value');
    yerr_flag=get(handles.yerr_checkbox, 'Value');
    if ~xerr_flag
        x_err=[];
    end
    if ~yerr_flag
        y_err=[];
    end
    
    %PLOTTING PLOTTING PLOTTING PLOTTING PLOTTING
    %plot data according to user preferences
    
    handles.graph{handles.plotcounter}=errorbarxy(x_dat, y_dat, x_err, y_err,{line_spec, 'k', 'k'});
    box off
    %assign and store a name to the graph
    processing_string=[norm_str,flip_str];
    handles.graph_name{handles.plotcounter}=[x_param_var,' ',y_param_var,' ',processing_string];
    
     %add legend
    handles.legend=legend(handles.graph_name{1:end});
    set(handles.legend,'interpreter','none')

    legend_state=get(handles.legend_on,'Value');
    if (legend_state && handles.plotcounter>0)
        set(handles.legend,'Visible','On')   
    elseif handles.plotcounter>0
        set(handles.legend,'Visible','Off')
    end
    
    %add graph axes labeling
    
%     xlabel([x_param,' ',x_param_var,' [',x_unit,']'], 'interpreter', 'none','fontsize',20)
%     ylabel([y_param,' ',y_param_var,' [',y_unit,']'], 'interpreter', 'none','fontsize',20)
    xlabel([x_param_var,' [',x_unit,']'], 'interpreter', 'none')
    ylabel([y_param_var,' [',y_unit,']'], 'interpreter', 'none')
    
    %add point labeling
    label_flag=get(handles.checkbox_point_labels, 'Value');
    if label_flag == 1
        for cntr=1:files_chosen
            str_label=[handles.file(file_choice(cntr)).name,' ',y_param_var];
            text(x_dat(cntr),y_dat(cntr),str_label,'interpreter','none');            
        end   
    end
    
    %store data in the figure
    handles.y_dat{handles.plotcounter}=y_dat;
    handles.x_dat{handles.plotcounter}=x_dat;
    
    %update data info
    set(handles.graph_list,'String',handles.graph_name)
    set(handles.graph_list,'Value', handles.plotcounter)
        
    
    guidata(hObject, handles)
%  profile viewer


% --- Executes on button press in polyfit.
function polyfit_Callback(hObject, ~, handles)

    %get user choice for fitting
    graph_choice=get(handles.graph_list,'Value');
    graph=handles.graph_name{graph_choice};
    
    %get data
    y_dat=handles.y_dat{graph_choice};
    x_dat=handles.x_dat{graph_choice};
    yaxis=handles.axischoice{graph_choice};
    
    %set appropriate y axis
    if yaxis==1
        yyaxis left
    elseif yaxis==2
        yyaxis right
    end
    
    %increase plot counter
    handles.plotcounter=handles.plotcounter+1;
    
    %to the fit 
    fit_flag=get(handles.polyfit, 'Value');
    poly_err_flag=get(handles.poly_error,'Value');
    if fit_flag
        order=str2double(get(handles.edit1,'String'));
        if order==0
            order=1;
            set(handles.edit1,'String',num2str(order));
        end
        hold on
        if poly_err_flag
            [handles.graph{handles.plotcounter},p,~]=polyplot(x_dat,y_dat,order,'r','error','b--','linewidth',.3);
        else
            [handles.graph{handles.plotcounter},p,~]=polyplot(x_dat,y_dat,order,'r');
        end
        hold off
    end
    
    %display fit equation
    str_label=char(vpa(poly2sym(p),3));
    if get(handles.poly_equation,'Value')
        text(x_dat(1),y_dat(1),str_label,'interpreter','none');
    end
    
    %update variables
    handles.x_dat{handles.plotcounter}=xlim;    %just so there is something in there
    handles.y_dat{handles.plotcounter}=ylim;    %just so there is something in there
    handles.graph_name{handles.plotcounter}=[graph,'fit order ',num2str(order)];
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
    
    %update GHFS_CALIBRATION_GUI
    set(handles.graph_list,'String',handles.graph_name)
        
    %forward changes
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in popupmenu_x_axis.
function popupmenu_x_axis_Callback(hObject, eventdata, handles)

    vars_list=get(handles.popupmenu_x_axis,'String');
    vars_val=get(handles.popupmenu_x_axis,'Value');
    vars=vars_list{vars_val};
       
    
% --- Executes during object creation, after setting all properties.
function popupmenu_x_axis_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in popupmenu_y_axis.
function popupmenu_y_axis_Callback(hObject, eventdata, handles)

    vars_list=get(handles.popupmenu_y_axis,'String');
    vars_val=get(handles.popupmenu_y_axis,'Value');
    vars=vars_list{vars_val};  
    

% --- Executes during object creation, after setting all properties.
function popupmenu_y_axis_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit1_Callback(hObject, eventdata, handles)

function xmin_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function xmin_edit_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

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


% --- Executes on button press in rescale_pushbutton.
function rescale_pushbutton_Callback(hObject, eventdata, handles)
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
%         axis(handles.var_axes,'mode','auto')


% --- Executes on button press in interactive_checkbox.
function interactive_checkbox_Callback(hObject, eventdata, handles)

function uipanel5_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in xerr_checkbox.
function xerr_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in yerr_checkbox.
function yerr_checkbox_Callback(hObject, eventdata, handles)


% --- Executes on button press in xmaj_radiobutton.
function xmaj_radiobutton_Callback(hObject, eventdata, handles)
    ax=handles.var_axes;
    if (get(hObject,'Value') == get(hObject,'Max'))
        set(ax,'Xgrid','on')
        set(ax,'GridLineStyle', '-')
%         set(ax,'Xcolor',[0.5 0.5 0.5])
    else
        set(ax,'Xgrid','off')
    end


% --- Executes on button press in ymaj_radiobutton.
function ymaj_radiobutton_Callback(hObject, eventdata, handles)
    ax=handles.var_axes;
    if (get(hObject,'Value') == get(hObject,'Max'))
        set(ax,'Ygrid','on')
        set(ax,'GridLineStyle', '-')
%         set(ax,'Ycolor',[0.5 0.5 0.5])
    else
        set(ax,'Ygrid','off')
    end

function a_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function a_edit_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function b_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function b_edit_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in plotrfln_pushbutton.
function plotrfln_pushbutton_Callback(hObject, eventdata, handles)
     
    %point to plotting axes and clear them
    axes(handles.var_axes);
    
    %update plotcounter
    handles.plotcounter=handles.plotcounter+1;
    
    %check which y axis to use for plotting
    y_axis_flag=get(handles.y_axis_primary,'Value');
    
    %get user preference
    hold_flag=get(handles.hold_checkbox, 'Value');
    
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
    
    axes(handles.var_axes);
    a=str2double(get(handles.a_edit,'String'));
    b=str2double(get(handles.b_edit,'String'));
    handles.graph{handles.plotcounter}=refline(a,b);
    set(handles.graph{handles.plotcounter},'Color',[0.5 0.5 0.5])
    set(handles.graph{handles.plotcounter},'LineStyle','-.')
    
    %update variables
    handles.x_dat{handles.plotcounter}=a;    %just so there is something in there
    handles.y_dat{handles.plotcounter}=b;    %just so there is something in there
    handles.graph_name{handles.plotcounter}=['refline',a,' ',b];
    
    %update legend
    handles.legend=legend(handles.graph_name{1:end});
    set(handles.legend,'interpreter','none')
    legend_state=get(handles.legend_on,'Value');
    if (legend_state && handles.plotcounter>0)
        set(handles.legend,'Visible','On')   
    elseif handles.plotcounter>0
        set(handles.legend,'Visible','Off')
    end
    
    %update GHFS_CALIBRATION_GUI
    set(handles.graph_list,'String',handles.graph_name)
    set(handles.graph_list,'Value', handles.plotcounter)
        
    %forward changes
    guidata(hObject, handles);
    
% --- Executes on button press in xmingrid_radiobutton.
function xmingrid_radiobutton_Callback(hObject, eventdata, handles)
    ax=handles.var_axes;
    if (get(hObject,'Value') == get(hObject,'Max'))
        set(ax,'XMinorGrid','on')
        set(ax,'MinorGridLineStyle', ':')
    else
        set(ax,'XMinorGrid','off')
    end

% --- Executes on button press in ymingrid_radiobutton.
function ymingrid_radiobutton_Callback(hObject, eventdata, handles)
    ax=handles.var_axes;
    if (get(hObject,'Value') == get(hObject,'Max'))
        set(ax,'YMinorGrid','on')
        set(ax,'MinorGridLineStyle', ':')
    else
        set(ax,'YMinorGrid','off')
    end

% --- Executes on button press in checkbox_point_labels.
function checkbox_point_labels_Callback(hObject, eventdata, handles)

% --- Executes on button press in hold_checkbox.
function hold_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in st_state.
function st_state_Callback(hObject, eventdata, handles)

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

% --- Executes on selection change in line_color.
function line_color_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function line_color_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in line_marker.
function line_marker_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
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

function position_lim_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function position_lim_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
    
   % clear screen
    clc
    
    % clear axes
    axes(handles.var_axes);
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
    
    %reset GHFS_CALIBRATION_GUI elements
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
        handles=rmfield(handles,'y_dat');
        handles=rmfield(handles,'axischoice');
    catch
    end
        
    %forward changes in handles
    guidata(hObject, handles);
    
    % --- Executes on button press in line_delete.
function line_delete_Callback(hObject, eventdata, handles)

    if handles.plotcounter>1
        %get user choice for deltion
        del_choice=get(handles.graph_list,'Value');

        %delete
        try
            delete(handles.graph{del_choice}.hMain) %property of function errorbarxy
        catch
            delete(handles.graph{del_choice}) %for all other plot types
        end
        handles.graph{del_choice}=[];
        handles.graph=handles.graph(~cellfun('isempty',handles.graph));

        %update variables
        handles.plotcounter=handles.plotcounter-1;

        handles.x_dat{del_choice}=[]; %first set desired cell to empty
        handles.x_dat=handles.x_dat(~cellfun('isempty',handles.x_dat)); %remove empty cells

        handles.y_dat{del_choice}=[]; %first set desired cell to empty
        handles.y_dat=handles.y_dat(~cellfun('isempty',handles.y_dat)); %remove empty cells

        handles.graph_name{del_choice}=[]; %first set desired cell to empty
        handles.graph_name=handles.graph_name(~cellfun('isempty',handles.graph_name)); %remove empty cells
        
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

        %update GHFS_CALIBRATION_GUI
        set(handles.graph_list,'String',handles.graph_name)
        set(handles.graph_list,'Value', handles.plotcounter)
            
    else
        clear_Callback(hObject, eventdata, handles)
        %for some reason, doesn't work otherwise
        handles.plotcounter=0;
    end
    
    %forward changes in handles
    guidata(hObject, handles);

% --- Executes on selection change in graph_list.
function graph_list_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function graph_list_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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

% --- Executes on button press in normalize.
function normalize_Callback(hObject, eventdata, handles)

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

% --- Executes on button press in flip_y_axis.
function flip_y_axis_Callback(hObject, eventdata, handles)

% --- Executes on button press in poly_error.
function poly_error_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function toolbar_distributions_ClickedCallback(hObject, eventdata, handles)
    %make sure data is loaded
    if ~isfield(handles,'data')
        errordlg('No data available for plotting - load data first')
    end
    
    for l=1:numel(handles.file)
        file_name{l}=[handles.file(l).name];
    end
    
    %get path to where the processed files are
    filePath_default=get(handles.file_path_disp,'String');
   
    %call distribution function
    gui_distributions(handles.distributions,file_name,filePath_default);


% --------------------------------------------------------------------
function toolbar_time_dep_ClickedCallback(hObject, eventdata, handles)
    %make sure data is loaded
    if ~isfield(handles,'data')
        errordlg('No data available for plotting - load data first')
    end
    %code below extracts elements from the main struct array that have the
    %field "vars" storing time dependant experimental data and forwards it
    %to another GHFS_CALIBRATION_GUI
    vars={'data'};

    for k=1:numel(vars)
    field_names=fields(handles.(vars{k}));
        for i=1:numel(field_names)
            for j=1:numel(handles.(vars{k}))
                if isfield(handles.(vars{k})(j).(field_names{i}),'var')
                    time_dep_var.(vars{k})(j).(field_names{i}).var=handles.(vars{k})(j).(field_names{i}).var;
                    time_dep_var.(vars{k})(j).(field_names{i}).unit=handles.(vars{k})(j).(field_names{i}).unit;
                    time_dep_var.(vars{k})(j).(field_names{i}).error=handles.(vars{k})(j).(field_names{i}).error;
                end        
            end
        end
    end

    for l=1:numel(handles.file)
        file_name{l}=[handles.file(l).name];
    end
    assignin('base','time_var',time_dep_var);
    
    %get path to where the processed files are
    filePath_default=get(handles.file_path_disp,'String');
    
    %since for those files no timing was recorded, and data aq rate was 1Hz
    handles.timing.fast=1;
    handles.timing.slow=1;
    handles.timing.MP=1;
    
    %call new GHFS_calibration_gui
    gui_timedependant(time_dep_var,file_name,handles.timing,filePath_default);


% --------------------------------------------------------------------
function toolbar_save_fig_ClickedCallback(hObject, eventdata, handles)
        
    %saving figure is problematic due to two y axes
    % 0. move to file directory, based on default value stored in GHFS_CALIBRATION_GUI
    filePath_default=get(handles.file_path_disp,'String');
    cd(filePath_default)
    
    % 1. Ask user for the file name
    saveDataName = uiputfile({'*.png';'*.jpg';'*.pdf';'*.eps';'*.fig';'*.emf';}, 'Save as');
    [~, file_name, ext] = fileparts(saveDataName);
      
    % 2. Save .fig file with the name
    hgsave(handles.var_axes,file_name)

    % 3. Display a hidden figure and load saved .fig to it
    f=figure('Visible','off');
    movegui(f,'center')
    h=hgload(file_name);
    %VERY CRUCIAL, MAKE SURE THAT AXES BELONG TO THE NEW FIGURE
    %OTHERWISE DOESNT WORK, FOR SOME STUPID REASON
    h.Parent=f;   
    %adjust figure size so it matches the axes
    f.Units='characters';
%     f.Position=h.Position.*1.2;
    %optionally make visible
%         f.Visible='on';
%         f.Name=saveDataName;

    % 4.save again, to desired format, if it different than fig
    if ~strcmp(ext,'.fig')
        delete([file_name,'.fig'])  
        export_fig (saveDataName, '-transparent','-p','0.02')           % http://ch.mathworks.com/matlabcentral/fileexchange/23629-export-fig   
    end
    delete(f); % clear figure
    msgbox(['Figure saved succesfully as ',saveDataName])

% --- Executes on selection change in file_path_disp.
function file_path_disp_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function file_path_disp_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in plot_exclude.
function plot_exclude_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function plot_exclude_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

% --------------------------------------------------------------------
function toolbar_init_ClickedCallback(hObject, eventdata, handles)

init_conditions_viewer(handles.file,handles.timing)

% --- Executes on button press in poly_equation.
function poly_equation_Callback(hObject, eventdata, handles)

