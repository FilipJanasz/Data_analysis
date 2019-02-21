function varargout = gui(varargin)
    % profile on
    clc
    % Determine where your m-file's folder is.
    script_folder = fileparts(which(mfilename)); 
    % Add that folder plus all subfolders to the path.
    addpath(genpath(script_folder)); 
    cd(script_folder)

    % GUI MATLAB code for gui.fig
    %      GUI, by itself, creates a new GUI or raises the existing
    %      singleton*.
    %
    %      H = GUI returns the handle to a new GUI or the handle to
    %      the existing singleton*.
    %
    %      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUI.M with the given input arguments.
    %
    %      GUI('Property','Value',...) creates a new GUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before gui_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to gui_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %

    % Edit the above text to modify the response to help gui
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_OutputFcn, ...
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
    % cd('D:\Data\Data_analysis');
    % End initialization code - DO NOT EDIT

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, ~, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gui (see VARARGIN)
    % Choose default command line output for gui
    handles.output = hObject;
    handles.plotcounter=0;
    handles.clear_old_flag=0;
    handles.adv_options_flag=0;
    %load and display logo
    logo=imread('precise_logo.png');
    axes(handles.logo_axes);
    imshow(logo);
    
    %read and store custom expresions
    [name,expression]=textread('custom_expressions.txt','%s %s');
    for expressionCntr=1:numel(name)
        handles.custom(expressionCntr).name=name{expressionCntr};
        handles.custom(expressionCntr).expression=expression{expressionCntr};
    end
    
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
    
    
% profile viewer
    % UIWAIT makes gui wait for user response (see UIRESUME)
    % uiwait(handles.main_gui);

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(~, ~, handles) 

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
    clear steam coolant facility NC distributions file BC GHFS MP timing
    
    %update handles structure
    guidata(hObject, handles)
    
    % based on user choice, acces and process picked files
    clear_flag=0;
    interactive_flag=handles.interactive_checkbox.Value;
    st_state_flag=handles.st_state.Value;
    frontDynamics_flag=handles.frontDynamics.Value;
      
    % call function down the line for file processing
    [steam, coolant, facility, NC, distributions, file, BC, GHFS, MP,timing]=gui_main(interactive_flag,st_state_flag,clear_flag,frontDynamics_flag,handles);
    
    %transfer data to handles structure
    handles.steam=steam;
    handles.coolant=coolant;
    handles.facility=facility;
    handles.NC=NC;
    handles.file=file;
    handles.BC=BC;
    handles.GHFS=GHFS;
    handles.MP=MP;
    handles.timing=timing;
    handles.distributions=distributions;
   
    % push the data to main workspace, just in case
    assignin('base','steam',handles.steam)
    assignin('base','coolant',handles.coolant)
    assignin('base','facility',handles.facility)
    assignin('base','file',handles.file)
    assignin('base','distributions',handles.distributions)
    assignin('base','NC',handles.NC)
    assignin('base','BC',handles.BC)
    assignin('base','GHFS',handles.GHFS)
    assignin('base','MP',handles.MP)
    assignin('base','timing',handles.timing)

    % based on what variables are present, set possible choices to
    % popupmenus for plotting
    vars={'steam','coolant','facility','NC','BC','GHFS','MP','custom'};

    handles.popupmenu_x_axis.String=vars;
    handles.popupmenu_y_axis.String=vars;

    %two lines below reset popupmenu values to first object on the list
    handles.popupmenu_x_axis.Value=1;
    handles.popupmenu_y_axis.Value=1;
    handles.popupmenu_x_axis_var.Value=1;
    handles.popupmenu_y_axis_var.Value=1;

    %update variables popupmenus
    handles.popupmenu_x_axis_var.String=fieldnames(handles.(vars{1}));   %the () around vars{1} allows for dynamic field name usage
    handles.popupmenu_y_axis_var.String=fieldnames(handles.(vars{1}));   %http://blogs.mathworks.com/videos/2009/02/27/dynamic-field-name-usage/
    
    %update filtration popupmenus
    handles.popupmenu17.String=[vars,{'timing'}];
    handles.popupmenu17.Value=1;
    handles.popupmenu18.String=fieldnames(handles.(vars{1}));
    handles.popupmenu18.Value=1;
    
    %update data selector listbox
    file_list={file(1:end).name};
    handles.plot_exclude.String=file_list;
    mark_file=1:1:numel(file_list);
    handles.plot_exclude.Value=mark_file;
    
    %update handles structure
    guidata(hObject, handles)
%     profile viewer

% --- Executes on button press in addData_pushbutton.
function addData_pushbutton_Callback(hObject, eventdata, handles)
    %essentially the same as process, but appending to the data present
    %before in structure handles
    % profile on
    clear steam coolant facility NC distributions file BC GHFS MP timing

    %update handles structure
    guidata(hObject, handles)
    
    % based on user choice, acces and process picked files
    clear_flag=0;
    interactive_flag=get(handles.interactive_checkbox,'Value');
    st_state_flag=get(handles.st_state,'Value');
    frontDynamics_flag=handles.frontDynamics.Value;
    
    % call function down the line for file processing
    [steam, coolant, facility, NC, distributions, file, BC, GHFS, MP,timing]=gui_main(interactive_flag,st_state_flag,clear_flag,frontDynamics_flag,handles);
    
    %transfer data to handles structure
    handles.steam=[handles.steam,steam];
    handles.coolant=[handles.coolant,coolant];
    handles.facility=[handles.facility,facility];
    handles.NC=[handles.NC,NC];
    handles.file=[handles.file,file];
    handles.BC=[handles.BC,BC];
    handles.GHFS=[handles.GHFS,GHFS];
    handles.MP=[handles.MP,MP];
    handles.timing=[handles.timing,timing];
    handles.distributions=[handles.distributions,distributions];
   
    % push the data to main workspace, just in case
    assignin('base','steam',handles.steam)
    assignin('base','coolant',handles.coolant)
    assignin('base','facility',handles.facility)
    assignin('base','file',handles.file)
    assignin('base','distributions',handles.distributions)
    assignin('base','NC',handles.NC)
    assignin('base','BC',handles.BC)
    assignin('base','GHFS',handles.GHFS)
    assignin('base','MP',handles.MP)
    assignin('base','timing',handles.timing)

%     % based on what variables are present, set possible choices to
%     % popupmenus for plotting
%     vars={'steam','coolant','facility','NC','BC','GHFS','MP','custom'};
% 
%     handles.popupmenu_x_axis.String=vars;
%     handles.popupmenu_y_axis.String=vars;
% 
%     %two lines below reset popupmenu values to first object on the list
%     handles.popupmenu_x_axis.Value=1;
%     handles.popupmenu_y_axis.Value=1;
%     handles.popupmenu_x_axis_var.Value=1;
%     handles.popupmenu_y_axis_var.Value=1;
% 
%     %update variables popupmenus
%     handles.popupmenu_x_axis_var.String=fieldnames(handles.(vars{1}));    %the () around vars{1} allows for dynamic field name usage
%     handles.popupmenu_y_axis_var.String=fieldnames(handles.(vars{1}));    %http://blogs.mathworks.com/videos/2009/02/27/dynamic-field-name-usage/
    
    %update data selector listbox
    file_list={handles.file(1:end).name};
    handles.plot_exclude.String=file_list;
    mark_file=1:1:numel(file_list);
    handles.plot_exclude.Value=mark_file;
    
    %update handles structure
    guidata(hObject, handles)
%     profile viewer


    
    % --- Executes on button press in reprocess_btn.
function reprocess_btn_Callback(hObject, eventdata, handles)
       % profile on
    %essentially the same as process, but with different flag
    clear steam coolant facility NC distributions file BC GHFS MP timing

    % based on user choice, access and process picked files
    clear_flag=1;
    interactive_flag=get(handles.interactive_checkbox,'Value');
    st_state_flag=get(handles.st_state,'Value');
    frontDynamics_flag=handles.frontDynamics.Value;
    
    [steam, coolant, facility, NC, distributions, file, BC, GHFS, MP,timing]=gui_main(interactive_flag,st_state_flag,clear_flag,frontDynamics_flag,handles);
    
    %transfer data to handles structure
    handles.steam=steam;
    handles.coolant=coolant;
    handles.facility=facility;
    handles.NC=NC;
    handles.file=file;
    handles.BC=BC;
    handles.GHFS=GHFS;
    handles.MP=MP;
    handles.timing=timing;
    handles.distributions=distributions;
   
    % push the data to main workspace, just in case
    assignin('base','steam',handles.steam)
    assignin('base','coolant',handles.coolant)
    assignin('base','facility',handles.facility)
    assignin('base','file',handles.file)
    assignin('base','distributions',handles.distributions)
    assignin('base','NC',handles.NC)
    assignin('base','BC',handles.BC)
    assignin('base','GHFS',handles.GHFS)
    assignin('base','MP',handles.MP)
    assignin('base','timing',handles.timing)

    % based on what variables are present, set possible choices to
    % popupmenus for plotting
    vars={'steam','coolant','facility','NC','BC','GHFS','MP','custom'};

    handles.popupmenu_x_axis.String=vars;
    handles.popupmenu_y_axis.String=vars;

    %two lines below reset popupmenu values to first object on the list
    handles.popupmenu_x_axis.Value=1;
    handles.popupmenu_y_axis.Value=1;
    handles.popupmenu_x_axis_var.Value=1;
    handles.popupmenu_y_axis_var.Value=1;

    %update variables popupmenus
    handles.popupmenu_x_axis_var.String=fieldnames(handles.(vars{1}));    %the () around vars{1} allows for dynamic field name usage
    handles.popupmenu_y_axis_var.String=fieldnames(handles.(vars{1}));    %http://blogs.mathworks.com/videos/2009/02/27/dynamic-field-name-usage/
    
    %update filtration popupmenus
    handles.popupmenu17.String=[vars,{'timing'}];
    handles.popupmenu17.Value=1;
    handles.popupmenu18.String=fieldnames(handles.(vars{1}));
    handles.popupmenu18.Value=1;
    
    %update data selector listbox
    file_list={handles.file(1:end).name};
    handles.plot_exclude.String=file_list;
    mark_file=1:1:numel(file_list);
    handles.plot_exclude.Value=mark_file;
    
    %update handles structure
    guidata(hObject, handles)
  %  profile viewer
  
% --------------------------------------------------------------------
function load_RELAP_dat_Callback(hObject, eventdata, handles)

    clear RELAP_dat_primary RELAP_dat_secondary 
    [RELAP_datPrimary,RELAP_datSecondary,RELAP_datExt]=load_relap(handles);
    handles.RELAP_primary=RELAP_datPrimary;
    handles.RELAP_secondary=RELAP_datSecondary;
    handles.RELAP_ext=RELAP_datExt;
    assignin('base','RELAP_primary',handles.RELAP_primary)
    assignin('base','RELAP_secondary',handles.RELAP_secondary)
    assignin('base','RELAP_ext',handles.RELAP_ext)
    
    vars=handles.popupmenu_x_axis.String;
    
    if isempty(find(strcmp(vars,'RELAP_primary'), 1))
        vars{end+1}='RELAP_primary';        
    end
    
    if isempty(find(strcmp(vars,'RELAP_secondary'), 1))
        vars{end+1}='RELAP_secondary';        
    end
    
    if isempty(find(strcmp(vars,'RELAP_ext'), 1))
        vars{end+1}='RELAP_ext';        
    end
    
    
    %create vertical distributions for primary side
    RelDistr=fields(RELAP_datPrimary);
    RelDistr(1)=[];
    for n=1:numel(RelDistr)  %by variables
        for m=1:numel(RELAP_datPrimary) %for files
            name=['RELAP_',RelDistr{n}];
            handles.distributions(m).(name)=RELAP_datPrimary(m).(RelDistr{n}).var;
            
            %switch units
            switch RelDistr{n}
                case 'tempg'
                    handles.distributions(m).(name)=handles.distributions(m).(name)-273.15;
                case 'tempf'
                    handles.distributions(m).(name)=handles.distributions(m).(name)-273.15;
                case 'htvat'
                    handles.distributions(m).(name)=handles.distributions(m).(name)-273.15;
                case 'p'
                    handles.distributions(m).(name)=handles.distributions(m).(name)./10^5;     
            end
        end
    end  
    
    handles.popupmenu_x_axis.String=vars;
    handles.popupmenu_y_axis.String=vars;

    %two lines below reset popupmenu values to first object on the list
    handles.popupmenu_x_axis.Value=1;
    handles.popupmenu_y_axis.Value=1;
    handles.popupmenu_x_axis_var.Value=1;
    handles.popupmenu_y_axis_var.Value=1;

    %update variables popupmenus
    handles.popupmenu_x_axis_var.String=fieldnames(handles.(vars{1}));    %the () around vars{1} allows for dynamic field name usage
    handles.popupmenu_y_axis_var.String=fieldnames(handles.(vars{1}));    %http://blogs.mathworks.com/videos/2009/02/27/dynamic-field-name-usage/
    
    %update filtration popupmenus
    try 
        handles.popupmenu17.String=[vars;{'timing'}];
    catch
        handles.popupmenu17.String=[vars,{'timing'}];
        for n=1:numel(RELAP_datPrimary)
            handles.file(n).name=RELAP_datPrimary(n).file;
        end
        handles.timing.fast=ones(n,1);  %artificial values so that code works
        handles.timing.slow=ones(n,1);
        handles.timing.MP=ones(n,1);     
    end
    handles.popupmenu17.Value=1;
    handles.popupmenu18.String=fieldnames(handles.(vars{1}));
    handles.popupmenu18.Value=1;
    
    %update data selector listbox
    file_list={handles.file(1:end).name};
    handles.plot_exclude.String=file_list;
    mark_file=1:1:numel(file_list);
    handles.plot_exclude.Value=mark_file;
    
    %update handles structure
    guidata(hObject, handles)

% --------------------------------------------------------------------
function plot_button_Callback(hObject, eventdata, handles)
%     profile on
    %make sure data is loaded
    if ~isfield(handles,'steam') && ~isfield(handles,'CFD') && ~isfield(handles,'RELAP_ext')
        errordlg('No data available for plotting - load data first')
    end
    
    %point to plotting axes and clear them
    axes(handles.var_axes);
    
    %adjust hold option based on GUI tickbox
    hold_flag=get(handles.hold_checkbox, 'Value');
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
    
    % get choice of files to be plotted
    file_choice=handles.plot_exclude.Value;
    files_chosen=numel(file_choice);
    handles.fileChoice{handles.plotcounter}=file_choice;
    
    % get choice of x/y axis phase to be plotted
    list_x=handles.popupmenu_x_axis.String;
    list_y=handles.popupmenu_y_axis.String;
    val_x=handles.popupmenu_x_axis.Value;
    val_y=handles.popupmenu_y_axis.Value;
    x_param=list_x{val_x};
    y_param=list_y{val_y};        
    
    % get choice of what parameter of each phase is to be plotted
    list_x_var=handles.popupmenu_x_axis_var.String;
    list_y_var=handles.popupmenu_y_axis_var.String;
    val_x_var=handles.popupmenu_x_axis_var.Value;
    val_y_var=handles.popupmenu_y_axis_var.Value;
    x_param_var=list_x_var{val_x_var};
    y_param_var=list_y_var{val_y_var};
    
    %allocate
    x_dat=ones(1,files_chosen);
    y_dat=ones(1,files_chosen);
    x_err=ones(1,files_chosen);
    y_err=ones(1,files_chosen);
    y_st_dev=ones(1,files_chosen);
    
    %extract data values, error values abd st_dev values, if applicable applying file choice filter
    if strcmp(x_param,'custom')
        customExpressionFunX=@(x) eval(handles.custom(val_x_var).expression);
        %for error estimation
        curExp=handles.custom(val_x_var).expression;
        curExp=erase(curExp,'(x)');
        valPos=strfind(curExp,'value');
        dotPos=strfind(curExp,'.');
%             expVarNum=[1,expVarNum];
        XexpErr='sqrt(0';
        for nExp=1:numel(valPos)
            currVal=valPos(nExp);
            goodDots=find(dotPos<currVal);
            firstDot=dotPos(goodDots(end-2));
            midDot=dotPos(goodDots(end-1));
            lastDot=dotPos(goodDots(end));
            %these above are used to cut the full expression strings to
            %extract variables
            xParamErr=curExp(firstDot+1:midDot-1);
            xParamVarErr=curExp(midDot+1:lastDot-1);
            XexpErr=[XexpErr,'+(handles.',xParamErr,'(x).',xParamVarErr,'.error/handles.',xParamErr,'(x).',xParamVarErr,'.value)^2'];
        end
        XexpErr=[XexpErr,')'];
        XerrFun=@(x,handles) eval(XexpErr);
    end
    
    for cntr=1:files_chosen
        if strcmp(x_param,'custom')
            x_dat(cntr)=customExpressionFunX(file_choice(cntr));
            x_err(cntr)=XerrFun(file_choice(cntr),handles)*x_dat(cntr);
        else
            x_dat(cntr)=handles.(x_param)(file_choice(cntr)).(x_param_var).value;
            x_err(cntr)=handles.(x_param)(file_choice(cntr)).(x_param_var).error;
        end
%      errorSource=[1.01E-07,1.13E-07,1.47E-07,1.65E-07,1.85E-07];
   
        if strcmp(y_param,'custom')
            currExpr=handles.custom(val_y_var).expression;
            customExpressionFunY=@(x) eval(handles.custom(val_y_var).expression);
            y_dat(cntr)=customExpressionFunY(file_choice(cntr));
            y_err(cntr)=1;
%             y_err(cntr)=errorSource(cntr);
        else
            y_dat(cntr)=handles.(y_param)(file_choice(cntr)).(y_param_var).value;
            y_err(cntr)=handles.(y_param)(file_choice(cntr)).(y_param_var).error;
        end
        try
            y_st_dev(cntr)=handles.(y_param)(file_choice(cntr)).(y_param_var).std;
            st_dev_available=1;
        catch
            st_dev_available=0;
        end
    end
    
    
    %filter out NaNs in y_dat
    
    any_nanX=isnan(x_dat);
    any_nanY=isnan(y_dat);
    any_nan=~(any_nanX+any_nanY);
    y_dat=y_dat(any_nan);    
    x_dat=x_dat(any_nan);   
    y_err=y_err(any_nan);   
    x_err=x_err(any_nan);  
    y_st_dev=y_st_dev(any_nan);  
    if isnan(y_dat)
        disp('NaN values found and filtered')
    end
    
    %sort all fields by x_dat
    tempSort=[x_dat',y_dat',x_err',y_err'];
    [tempSort,sortOrder]=sortrows(tempSort,1); %sortOrder to manage point labels 
    handles.sortOrder{handles.plotcounter}=sortOrder;
    x_dat=tempSort(:,1)';
    y_dat=tempSort(:,2)';
    x_err=tempSort(:,3)';
    y_err=tempSort(:,4)';
    
    %if user wants only std values, plot y_st_dev instead of y_dat 
    st_dev_only_flag=get(handles.stdev_only_checkbox, 'Value');
    if st_dev_only_flag && st_dev_available
        y_dat=y_st_dev;
    end
    
    %get units for the plot
    if strcmp(x_param,'custom')
        x_unit=1;
    else
        x_unit=handles.(x_param)(1).(x_param_var).unit;
    end
    
    if strcmp(y_param,'custom')
        y_unit=1;
    else
        y_unit=handles.(y_param)(1).(y_param_var).unit;
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
    %colorstring = 'kbgrmcy'; 
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
    
    marker_color_all=get(handles.marker_color, 'String');
    marker_color_no=get(handles.marker_color, 'Value');
    marker_color=marker_color_all{marker_color_no};
    
    marker_size=str2double(handles.marker_size.String);
    % arrange user defined styling parameters
    if strcmp(line_color,'auto')
        line_color=colorstring{handles.plotcounter};
    else
        line_color=colorstring{line_color_no-1};
    end
    
    if strcmp(marker_color,'auto')
        marker_color=colorstring{handles.plotcounter};
    else
        marker_color=colorstring{marker_color_no-1};
    end
%     
%     if strcmp(line_marker,'none')
%         line_marker='';
%     end
%     
%     if strcmp(line_style,'none')
%         line_style='';
%     end
    
    %combine input into line specification string
    line_spec={line_color,line_style,line_width,line_marker,marker_color,marker_size};
    
    %check if user wants errorbars
    xerr_flag=get(handles.xerr_checkbox, 'Value');
    yerr_flag=get(handles.yerr_checkbox, 'Value');
    if ~xerr_flag
        x_err=[];
    end
    if ~yerr_flag
        y_err=[];
    end
        
    %§ PLOTTING PLOTTING PLOTTING
    %plot data according to user preferences
    if handles.subPlot.Value
        f=figure;
        figure(f)
        s1=subplot(2,1,1);
        figure(f)

        line_spec2={handles.graph{1}.hMain.Color,handles.graph{1}.hMain.LineStyle,handles.graph{1}.hMain.LineWidth,handles.graph{1}.hMain.Marker,handles.graph{1}.hMain.MarkerFaceColor,handles.graph{1}.hMain.MarkerSize};
        upper=errorbarxy(handles.graph{1}.hMain.XData, handles.graph{1}.hMain.YData, x_err, y_err,{line_spec2, 'k', 'k'});
%         upper.hMain.Color=handles.graph{1}.hMain.Color
        lab2=ylabel(handles.var_axes.YLabel.String);
        lab2.FontSize=14;
        grid on
        grid minor
        box on
        subplot(2,1,2)
        figure(f)
        handles.graph{handles.plotcounter}=errorbarxy(x_dat, y_dat, x_err, y_err,{line_spec, 'k', 'k'});
        grid on
        grid minor
        box on
    else    
        handles.graph{handles.plotcounter}=errorbarxy(x_dat, y_dat, x_err, y_err,{line_spec, 'k', 'k'});
    end
    box on    
    
    %add standard deviations if desired
    st_dev_flag=handles.stdev_checkbox.Value;
    if st_dev_flag && st_dev_available
        hold on
%         handles.graph{handles.plotcounter+1}=plot(x_dat,y_st_dev,'.-g');
%         handles.graph{handles.plotcounter+2}=plot(x_dat,y_st_dev_max,'.-g');
%         plot(x_dat,y_dat-y_st_dev,'.-g');
%         plot(x_dat,y_dat+y_st_dev,'.-b');
        for std_ctr=1:numel(y_st_dev)
            %plot vertical line with a span od 2 * st dev
            h=line([x_dat(std_ctr),x_dat(std_ctr)],[y_dat(std_ctr)-y_st_dev(std_ctr),y_dat(std_ctr)+y_st_dev(std_ctr)]);
            h.LineWidth=1;
            %add horizontal line ends
%             lineLength=4;
%             h_horz1=line([x_dat(std_ctr)-lineLength,x_dat(std_ctr)+lineLength],[y_dat(std_ctr)-y_st_dev(std_ctr),y_dat(std_ctr)-y_st_dev(std_ctr)]);
%             h_horz2=line([x_dat(std_ctr)-lineLength,x_dat(std_ctr)+lineLength],[y_dat(std_ctr)+y_st_dev(std_ctr),y_dat(std_ctr)+y_st_dev(std_ctr)]);
%             h_horz1.LineWidth=1;
%             h_horz2.LineWidth=1;        
        end
        
        if ~hold_flag
            hold off
        end
    elseif st_dev_flag && ~st_dev_available
        msgbox('Standard deviation data not available for the chosen variables / files - omitting')
    end
    %assign and store a name to the graph
    processing_string=[norm_str,flip_str];
%     handles.graph_name{handles.plotcounter}=[x_param_var,' ',y_param_var,' ',processing_string];
    y_param_var=strrep(y_param_var,'_',' ');
    y_param_var=strrep(y_param_var,'N2','N_2');   
    x_param_var=strrep(x_param_var,'_',' ');
    handles.graph_name{handles.plotcounter}=[x_param_var,' vs ',y_param_var,' ',processing_string];
%     if st_dev_flag && st_dev_available
%         handles.graph_name{handles.plotcounter+1}=[x_param_var,' ',y_param_var,' std min'];
%         handles.graph_name{handles.plotcounter+1}=[x_param_var,' ',y_param_var,' std max'];
%     end
    
     %add legend
    handles.legend=legend(handles.graph_name{1:end});
    %set(handles.legend,'interpreter','none')

    legend_state=get(handles.legend_on,'Value');
    if (legend_state && handles.plotcounter>0)
        set(handles.legend,'Visible','On')   
    elseif handles.plotcounter>0
        set(handles.legend,'Visible','Off')
    end
    
    %add graph axes labeling
    
%     xlabel([x_param,' ',x_param_var,' [',x_unit,']'], 'interpreter', 'none','fontsize',20)
%     ylabel([y_param,' ',y_param_var,' [',y_unit,']'], 'interpreter', 'none','fontsize',20)
    x_param_var=strrep(x_param_var,'_',' ');
    y_param_var=strrep(y_param_var,'_',' ');
    x_param_var=strrep(x_param_var,'N2','N_2');
    y_param_var=strrep(y_param_var,'N2','N_2');
    xlb=xlabel([x_param_var,' [',x_unit,']']);
    ylb=ylabel([y_param_var,' [',y_unit,']']);
    handles.ed_xLabel.String=[x_param_var,' [',x_unit,']'];
    handles.ed_yLabel.String=[y_param_var,' [',y_unit,']'];
    xlb.FontSize=str2double(handles.fontX.String);
    ylb.FontSize=str2double(handles.fontY.String);
%     xlabel([x_param_var,' [',x_unit,']'], 'interpreter', 'none')
%     ylabel([y_param_var,' [',y_unit,']'], 'interpreter', 'none')
    
    %add point labeling - two loops solution to account for possible missing NaN values
    label_flag=get(handles.checkbox_point_labels, 'Value');
    if label_flag == 1
        %create each label
        for cntr=1:files_chosen
            str_label{cntr}=[handles.file(file_choice(cntr)).name,' ',y_param_var];     
        end
        
        %remove values for previoiusly filtered NaN data
        str_label=str_label(any_nan);
        
        %since data is sorted, apply the same sorting key to labels
        for labCntr=1:numel(str_label)
            tempLab{labCntr}=str_label{sortOrder(labCntr)};
        end
        str_label=tempLab;   
        
        %place text
        for cntr=1:numel(str_label)
            text(x_dat(cntr),y_dat(cntr),str_label{cntr},'interpreter','none'); 
        end       
    end    
    
    %store data in the figure
    handles.y_dat{handles.plotcounter}=y_dat;
    handles.x_dat{handles.plotcounter}=x_dat;
%     if st_dev_flag && st_dev_available
%         handles.y_dat{handles.plotcounter+1}=y_dat;
%         handles.x_dat{handles.plotcounter+1}=x_dat;
%         handles.y_dat{handles.plotcounter+2}=y_dat;
%         handles.x_dat{handles.plotcounter+2}=x_dat;
%     end
    
    %update data info
    set(handles.graph_list,'String',handles.graph_name)
    set(handles.graph_list,'Value', handles.plotcounter)
%     if st_dev_flag && st_dev_available
%         handles.plotcounter=handles.plotcounter+2;
%     end
        
    %adjustLimits
    if ~handles.subPlot.Value
        adjustLimits(handles)
    end
    
    %adjust gridlines
    Xmaj=handles.xmaj_radiobutton.Value;
    Xminor=handles.xmingrid_radiobutton.Value;
    Ymaj=handles.ymaj_radiobutton.Value;
    Yminor=handles.ymingrid_radiobutton.Value;
    if Xmaj
        handles.var_axes.XGrid='on';
    else
        handles.var_axes.XGrid='off';
    end
    
    if Xminor
        handles.var_axes.XMinorGrid='on';
    else
        handles.var_axes.XMinorGrid='off';
    end
    
    if Ymaj
        handles.var_axes.YGrid='on';
    else
        handles.var_axes.YGrid='off';
    end
    
    if Yminor
        handles.var_axes.YMinorGrid='on';
    else
        handles.var_axes.YMinorGrid='off';
    end
    
    
    guidata(hObject, handles)
%  profile viewer

% --- Executes on selection change in popupmenu_x_axis_var.
function popupmenu_x_axis_var_Callback(~, ~, ~)



% --- Executes during object creation, after setting all properties.
function popupmenu_x_axis_var_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_y_axis_var.
function popupmenu_y_axis_var_Callback(~, ~, ~)



% --- Executes during object creation, after setting all properties.
function popupmenu_y_axis_var_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in polyfit.
function polyfit_Callback(hObject, ~, handles)

    %get user choice for fitting
    graph_choice=get(handles.graph_list,'Value');
    graph=handles.graph_name{graph_choice};
    
    %get data
    y_dat=handles.y_dat{graph_choice};
    x_dat=handles.x_dat{graph_choice};
    yaxis=handles.axischoice{graph_choice};
    rSquared_flag=handles.rSquared.Value;
    
    
    %filter out NaNs in y_dat
    
    any_nanX=isnan(x_dat);
    any_nanY=isnan(y_dat);
    any_nan=~(any_nanX+any_nanY);
    y_dat=y_dat(any_nan);    
    x_dat=x_dat(any_nan);   
    if isnan(y_dat)
        disp('NaN values found and filtered')
    end 
    
    
    %set appropriate y axis
    if yaxis==1
        yyaxis left
    elseif yaxis==2
        yyaxis right
    end
    
    %increase plot counter
    handles.plotcounter=handles.plotcounter+1;
    
    %do the fit 
    fit_flag=handles.polyfit.Value;
    poly_err_flag=handles.poly_error.Value;
    if fit_flag
        fitTypesAll=handles.fitType.String;
        fitTypeChoice=handles.fitType.Value;
        fitType=fitTypesAll{fitTypeChoice};
        
        [fitRes, gof] = curveFit(x_dat,y_dat,fitType);
        hold on
        %preserve labels
        oldLabelX=handles.var_axes.XLabel.String;
        labelXfont=handles.var_axes.XLabel.FontSize;
        oldLabelY=handles.var_axes.YLabel.String;
        labelYfont=handles.var_axes.YLabel.FontSize;
        if poly_err_flag
            handles.graph{handles.plotcounter}.hMain=plot( fitRes, 'r--','predobs');
        else
            handles.graph{handles.plotcounter}.hMain=plot( fitRes, 'r--');
        end
        hold off
        handles.var_axes.XLabel.String=oldLabelX;
        handles.var_axes.XLabel.FontSize=labelXfont;
        handles.var_axes.YLabel.String=oldLabelY;
        handles.var_axes.YLabel.FontSize=labelYfont;

    end
    
    
    %show info about fit
    if rSquared_flag
        
        eq = formula(fitRes);
        parameters = coeffnames(fitRes); %All the parameter names
        values = coeffvalues(fitRes); %All the parameter values
        for idx = 1:numel(parameters)
            param = parameters{idx};
            l = length(param);
            loc = regexp(eq, param); %Location of the parameter within the string
            while ~isempty(loc)     
                %Substitute parameter value
                eq = [eq(1:loc-1), num2str(values(idx)), eq(loc+l:end)];
                loc = regexp(eq, param);
            end
        end
        
        eq=sprintf([['y = ',eq],'\n',['R^2 ',num2str(gof.rsquare)]]);
        % display equation
        yL=get(handles.var_axes,'YLim'); 
        xL=get(handles.var_axes,'XLim');   
        ht=text((xL(1)+xL(2))/1.8,yL(1)+0.75*(yL(2)-yL(1)),eq,...
             'HorizontalAlignment','left',...
             'VerticalAlignment','top',...
             'BackgroundColor',[1 1 1],...
             'FontSize',12);
         
        ht.EdgeColor=[0.15 0.15 0.15];
    end
%      
    %update variables
    handles.x_dat{handles.plotcounter}=xlim;    %just so there is something in there
    handles.y_dat{handles.plotcounter}=ylim;    %just so there is something in there
    handles.graph_name{handles.plotcounter}=[graph,'fit type ',num2str(fitType)];
    handles.axischoice{handles.plotcounter}=yaxis;
    
    %update legend
    handles.legend=legend(handles.graph_name{1:end});
%     set(handles.legend,'interpreter','none')
    legend_state=get(handles.legend_on,'Value');
    if (legend_state && handles.plotcounter>0)
        set(handles.legend,'Visible','On')   
    elseif handles.plotcounter>0
        set(handles.legend,'Visible','Off')
    end
    
    %update GUI
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

    vars_list=handles.popupmenu_x_axis.String;
    vars_val=handles.popupmenu_x_axis.Value;
    vars=vars_list{vars_val};
       
    %the next line is to set the second popupmenu to common value, otherwise it breaks
    handles.popupmenu_x_axis_var.Value=1;
    
    %due to different data structure of variable 'custom', this if
    %statement is neccessary
    if strcmp(vars,'custom')
        handles.popupmenu_x_axis_var.String={handles.custom.name};
    else
        handles.popupmenu_x_axis_var.String=fieldnames(handles.(vars));
    end
    
% --- Executes during object creation, after setting all properties.
function popupmenu_x_axis_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in popupmenu_y_axis.
function popupmenu_y_axis_Callback(hObject, eventdata, handles)

    vars_list=handles.popupmenu_y_axis.String;
    vars_val=handles.popupmenu_y_axis.Value;
    vars=vars_list{vars_val}; 
    
    %the next line is to set the second popupmenu to common value, otherwise it breaks
    handles.popupmenu_y_axis_var.Value=1;
    
    %due to different data structure of variable 'custom', this if
    %statement is neccessary
    if strcmp(vars,'custom')
        handles.popupmenu_y_axis_var.String={handles.custom.name};
    else
        handles.popupmenu_y_axis_var.String=fieldnames(handles.(vars));
    end

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
    if a~=1 && b~=0 && a~=0
        handles.graph_name{handles.plotcounter}=[' y = ',num2str(a),'* x + ',num2str(b)];
    elseif a~=1 && a~=0
        handles.graph_name{handles.plotcounter}=[' y = ',num2str(a),'* x'];
    elseif b~=0 && a~=0
        handles.graph_name{handles.plotcounter}=[' y = ','x + ',num2str(b)];
    elseif a~=0
        handles.graph_name{handles.plotcounter}=[' y = ','x'];
    elseif a==0
        handles.graph_name{handles.plotcounter}=[' y = ',num2str(b)];
    end
    
    if b<0
        handles.graph_name{handles.plotcounter}=strrep(handles.graph_name{handles.plotcounter},'+','');
    end
    
    %update legend
    handles.legend=legend(handles.graph_name{1:end});
%     set(handles.legend,'interpreter','none')
    legend_state=get(handles.legend_on,'Value');
    if (legend_state && handles.plotcounter>0)
        set(handles.legend,'Visible','On')   
    elseif handles.plotcounter>0
        set(handles.legend,'Visible','Off')
    end
    
    %update GUI
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
        del_choice=handles.graph_list.Value;

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
%         set(handles.legend,'interpreter','none')
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
    if ~isfield(handles,'steam') && ~isfield(handles,'CFD') && ~isfield(handles,'RELAP_ext')
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
    if ~isfield(handles,'steam')&& ~isfield(handles,'CFD') && ~isfield(handles,'RELAP_ext')
        errordlg('No data available for plotting - load data first')
    end
    %code below extracts elements from the main struct array that have the
    %field "vars" storing time dependant experimental data and forwards it
    %to another GUI
    
%     vars={'steam','coolant','facility','GHFS','MP','RELAP','CFD'};
    vars=handles.popupmenu_x_axis.String;
    
    for k=1:numel(vars)
    field_names=fields(handles.(vars{k}));
        for i=1:numel(field_names)
            for j=1:numel(handles.(vars{k}))
                if isfield(handles.(vars{k})(j).(field_names{i}),'var')
                    if strcmp(vars{k},'CFD') %cfd has special field with actual flow time
                        time_dep_var.(vars{k})(j).(field_names{i}).time=handles.(vars{k})(j).(field_names{i}).time;
                    end
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
    
    %call new gui
    gui_timedependant(time_dep_var,file_name,handles.timing,filePath_default);


% --------------------------------------------------------------------
function toolbar_save_fig_ClickedCallback(hObject, eventdata, handles)
        
    %saving figure is problematic due to two y axes
    % 0. move to file directory, based on default value stored in GUI
    filePath_default=get(handles.file_path_disp,'String');
    cd(filePath_default)
    
    % 1. Ask user for the file name
    saveDataName = uiputfile({'*.png';'*.jpg';'*.pdf';'*.eps';'*.fig';'*.emf';}, 'Save as');
    [~, file_name, ext] = fileparts(saveDataName);
    
    % 2. Save .fig file with the name
    hgsave(handles.var_axes,file_name)

    % 3. Display a hidden figure and load saved .fig to it
    f=figure('Visible','on');
    movegui(f,'center')
    h=hgload(file_name);
    h.Parent=f;   
    f.Position=[300   200   1250   680];
    
    %fix fonts etc
    h.XAxis(1).FontSize=24;
    h.XAxis(1).Label.FontSize=24;
    h.XAxis(1).Label.FontWeight='bold';
    h.Legend.FontSize=24;
    h.Legend.Location='northeast';
    
    for axN=1:2
        h.YAxis(axN).FontSize=24;
        h.YAxis(axN).Label.FontSize=24;
        h.YAxis(axN).Label.FontWeight='bold'; 
    end
    set(h,'Position',[27 7.8451 201.9200 40.9241])

    for chN=1:numel(h.Children)
        h.Children(chN).LineWidth=3*h.Children(chN).LineWidth;
        h.Children(chN).MarkerSize=2*h.Children(chN).MarkerSize;
    end
    % 4.save again, to desired format, if it is different than fig
    if ~strcmp(ext,'.fig')
        delete([file_name,'.fig']) 
        set(h,'Position',[27 7.8451 201.9200 40.9241])
        export_fig (saveDataName, '-transparent','-p','0.02')           % http://ch.mathworks.com/matlabcentral/fileexchange/23629-export-fig   
        savefig(f,file_name)
        set(h,'Position',[27 7.8451 201.9200 40.9241])
        print(f,file_name,'-dmeta')
    else
        savefig(f,file_name)
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

% --- Executes on button press in adv_options_btn.
function adv_options_btn_Callback(hObject, eventdata, handles)
    handles.adv_options_flag=1;
    %get options for processing
    fid=fopen('adv_options.txt','rt');
    options=textscan(fid,'%s');
    options=options{1};
    fclose(fid);
    gui_advanced_options(options)
    %forward changes in handles
    guidata(hObject, handles);

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

% --------------------------------------------------------------------
function toolbar_init_ClickedCallback(hObject, eventdata, handles)
    init_conditions_viewer(handles)

% --------------------------------------------------------------------
function relap_ClickedCallback(hObject, eventdata, handles)
    
    %get path to relap
    try
        fid = fopen('RelapScriptPath.txt','r');
        relapPath = fgetl(fid);
        fclose(fid);
    catch
        relapPath='0';
    end
    
    worked=0;
    updateFlag=0;
    
    while ~worked
        addpath(relapPath);
        try
            RelapGUI(relapPath)
            worked=1;
        catch
            waitfor(msgbox('Matlab code for Relap integration not found. Please provide working path to ''2017ClosedTubeSimulator'''));
            relapPath=uigetdir;
            updateFlag=1;
        end  
    end
    
    if updateFlag
        fid = fopen('RelapScriptPath.txt','w');
        fprintf(fid,'%s',relapPath);
        fclose(fid);
    end

% --- Executes on button press in stdev_checkbox.
function stdev_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in stdev_only_checkbox.
function stdev_only_checkbox_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function toolbar_init_estimator_ClickedCallback(hObject, eventdata, handles)
    gui_IC_estimator



% --- Executes on button press in table_pushbutton.
function table_pushbutton_Callback(hObject, eventdata, handles)
    %prepare data for tbale display
    data4table=0;
%     try
        for tabCounter=1:numel(handles.x_dat)
            if data4table==0
                data4table=[handles.x_dat{tabCounter}',handles.y_dat{tabCounter}'];
            else
                data4table=[data4table,handles.x_dat{tabCounter}',handles.y_dat{tabCounter}'];
            end
        end

        %create and populate the table
        tableFig=figure;
        tableTab=uitable;
        tableTab.Position=[0 0 560 400];
        tableTab.Data=data4table;
        
        %get names of files for the plot
        filesChoice=handles.fileChoice{1};
        for n=1:numel(filesChoice)
            fileNames{n}=handles.file(filesChoice(n)).name;
        end
        %since data is sorted, apply the same sorting key the names
        sortOrder=handles.sortOrder{1};
        for filCntr=1:numel(fileNames)
            namesSorted{filCntr}=fileNames{sortOrder(filCntr)};
        end
        namesSorted=strrep(namesSorted,'_output_R_processed_for_Matlab','');
        tableTab.RowName=namesSorted;
        
        %fix column naming
        for nameCntr=1:numel(handles.graph_name)
            nameTemp=cell2mat(handles.graph_name(nameCntr));
            spacePos=strfind(nameTemp,'vs');
            name4table_x{nameCntr}=['<HTML>X_dat ',num2str(nameCntr),'<br />',nameTemp(1:spacePos(1)-1),'<HTML/>'];
            name4table_y{nameCntr}=['<HTML>Y_dat ',num2str(nameCntr),'<br />',nameTemp(spacePos(1)+1:end),'<HTML/>'];
        end

        tableTab.ColumnName=reshape([name4table_x;name4table_y],1,2*numel(handles.graph_name));
        tableTab.Position=[0 0 860 400];
%     catch
%         msgbox('No data to be displayed - chose and plot data first')
%     end
  
% --- Executes on button press in AdvPlot_pushbutton.
function AdvPlot_pushbutton_Callback(hObject, eventdata, handles)
   
    %get handles to dropdown menus
    x_var_handle=handles.popupmenu_x_axis;
    x_var_value_handle=handles.popupmenu_x_axis_var;
    y_var_handle=handles.popupmenu_y_axis;
    y_var_value_handle=handles.popupmenu_y_axis_var;
    %get all main categories names
    list_medium=get(handles.popupmenu_x_axis,'String');
    
    %remove 'Custom' field from the list
    try
        if strcmp(list_medium{end},'custom')
            list_medium(end)=[];
        end
    catch
        msgbox('Data not present - load data first')
    end
    
    %and subcategories
    for namingCntr=1:numel(list_medium)
        list_variable.(list_medium{namingCntr})=fieldnames(handles.(list_medium{namingCntr}));
    end
    %pass it to the gui (instead of the whole "handles" structure
    gui_custom_expressions(list_medium,list_variable,x_var_handle,x_var_value_handle,y_var_handle,y_var_value_handle)

% --------------------------------------------------------------------
function MenuDataProcessing_Callback(hObject, eventdata, handles)



% --- Executes on button press in filterPushbutton.
function filterPushbutton_Callback(hObject, eventdata, handles)
    
    dir={handles.file.directory};
    dir=unique(dir,'stable');
    filterMask=[];
    for dirCntr=1:numel(dir)
        fid=fopen([dir{dirCntr},'\filterMask.txt'], 'r' );
        fgetl(fid);
        fgetl(fid);
        fgetl(fid);
%         clr{2}=logical(fgetl(fid)'-'0');
%         clr{3}=logical(fgetl(fid)'-'0');
        filterMask=[filterMask;logical(fgetl(fid)'-'0')];
        fclose(fid);
    end
    
    
    handles.plot_exclude.Value=find(filterMask);
    
    % Update handles structure
    guidata(hObject, handles);

% --- Executes on button press in editfilterPushbutton.
function editfilterPushbutton_Callback(hObject, eventdata, handles)

    gui_fileFilter(handles)


% --- Executes on button press in selectallPushbutton.
function selectallPushbutton_Callback(hObject, eventdata, handles)
    allFiles=numel(handles.plot_exclude.String);
    handles.plot_exclude.Value=1:1:allFiles;


% --------------------------------------------------------------------
function cfdGen_ClickedCallback(hObject, eventdata, handles)
    % hObject    handle to cfdGen (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if ~isfield(handles,'steam')
        msgbox('No data to write Fluent BC''s. Load data first!')
        return
    end
    
    %apply selection filter
    fileChoice=handles.plot_exclude.Value;
    filesAmt=numel(fileChoice);
    
    %get data
    for m=1:filesAmt
        n=fileChoice(m);
        steamFlow(m)=handles.steam(n).mflow.value;
        steamTemp(m)=handles.steam(n).temp.value;
        clntFlow(m)=handles.coolant(n).mflow.value/3600; %kg/s
        clntTemp(m)=handles.coolant(n).temp_inlet.value;
        clntPress(m)=handles.coolant(n).press.value;
        clntVel(m)=handles.coolant(n).velocity.value;
        initPress(m)=handles.steam(n).press_init.value;
        initTemp(m)=handles.steam(n).temp_init.value;
        initN2(m)=handles.NC(n).N2_molefraction_init.value;
        initHe(m)=handles.NC(n).He_molefraction_init.value;
        fileName{m}=handles.file(n).name;
    end
    
writeCFD(steamFlow,steamTemp,clntFlow,clntTemp,clntPress,clntVel,initPress,initTemp,initN2,initHe,fileName)  %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
msgbox('Fluent input macros for currently loaded files succesfully created')


% --------------------------------------------------------------------
function cfdRead_ClickedCallback(hObject, eventdata, handles)
    % hObject    handle to cfdRead (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    clear CFD CFDdistributions 
    [handles.CFD,CFDdistr,CFDfile]=load_CFD(handles);
    
    %append new distributions to global handles
    allFields=fieldnames(CFDdistr);
    for aCntr=1:numel(allFields)
        for fCntr=1:numel(CFDdistr)
            handles.distributions(fCntr).(['CFD_',allFields{aCntr}])=CFDdistr(fCntr).(allFields{aCntr});
        end
    end
    
    
    %check if normal files were loaded
    if ~isfield(handles,'file')
        handles.file=CFDfile;
        handles.timing.fast=ones(numel(CFDfile),1);  %artificial values so that code works
        handles.timing.slow=ones(numel(CFDfile),1);
        handles.timing.MP=ones(numel(CFDfile),1);
        assignin('base','file',handles.file)
    end
    %push data to workspace
    assignin('base','CFD',handles.CFD)
    assignin('base','distributions',handles.distributions)
    
    %update proper lists in gui
    vars=handles.popupmenu_x_axis.String;
    if isempty(find(strcmp(vars,'CFD'), 1))
      
        if isempty(vars)
            vars{1}='CFD';  
        elseif ischar(vars)
            temp=vars;
            vars=[];
            vars{1}=temp;
            vars{end+1}='CFD'; 
        else
            vars{end+1}='CFD';     
        end
    end
  
    handles.popupmenu_x_axis.String=vars;
    handles.popupmenu_y_axis.String=vars;

    %two lines below reset popupmenu values to first object on the list
    handles.popupmenu_x_axis.Value=1;
    handles.popupmenu_y_axis.Value=1;
    handles.popupmenu_x_axis_var.Value=1;
    handles.popupmenu_y_axis_var.Value=1;
% 
    %update variables popupmenus
    handles.popupmenu_x_axis_var.String=fieldnames(handles.(vars{1}));    %the () around vars{1} allows for dynamic field name usage
    handles.popupmenu_y_axis_var.String=fieldnames(handles.(vars{1}));    %http://blogs.mathworks.com/videos/2009/02/27/dynamic-field-name-usage/
%     
%     %update data selector listbox
%     file_list={handles.file(1:end).name};
%     handles.plot_exclude.String=file_list;
%     mark_file=1:1:numel(file_list);
%     handles.plot_exclude.Value=mark_file;
    
    %update handles structure
    guidata(hObject, handles)


% --------------------------------------------------------------------
function CFD_run_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to CFD_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currPath=cd;
cd('D:\CFD2018\inputs')
[file,path] = uigetfile('*.*','Pick Fluent Journal file');

%run fluent without graphics
% cmd=['fluent 2ddp -g -t6 -i ',path,file,' &'];
cmd=['fluent 2ddp -t4 -i ',path,file,' &'];
% system('cd /d D:\CFD2018')
system(cmd)
cd(currPath)




% --- Executes on button press in lineSpec.
function lineSpec_Callback(hObject, eventdata, handles)

    file_name='temp.fig';
    % 2. Save .fig file with the name
    hgsave(handles.var_axes,file_name)

    % 3. Display a hidden figure and load saved .fig to it
    f=figure('Visible','on');
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

    % 4.save again, to desired format, if it is different than fig

        delete(file_name) 



% --- Executes on selection change in marker_color.
function marker_color_Callback(hObject, eventdata, handles)
% hObject    handle to marker_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns marker_color contents as cell array
%        contents{get(hObject,'Value')} returns selected item from marker_color


% --- Executes during object creation, after setting all properties.
function marker_color_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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


% --- Executes on button press in line_update.
function line_update_Callback(hObject, eventdata, handles)

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

    marker_color_all=get(handles.marker_color, 'String');
    marker_color_no=get(handles.marker_color, 'Value');
    marker_color=marker_color_all{marker_color_no};

    marker_size=str2double(handles.marker_size.String);
    % arrange user defined styling parameters
    if strcmp(line_color,'auto')
        line_color=colorstring{currLine};
    else
        line_color=colorstring{line_color_no-1};
    end

    if strcmp(marker_color,'auto')
        marker_color=colorstring{currLine};
    else
        marker_color=colorstring{marker_color_no-1};
    end
    %     
    %     if strcmp(line_marker,'none')
    %         line_marker='';
    %     end
    %     
    %     if strcmp(line_style,'none')
    %         line_style='';
    %     end

    %combine input into line specification string
    spec={line_color,line_style,line_width,line_marker,marker_color,marker_size};

    h.Color=spec{1};
    h.LineStyle=spec{2};
    h.LineWidth=spec{3};
    h.Marker=spec{4};
    h.MarkerFaceColor=spec{5};
    h.MarkerEdgeColor=spec{5};
    h.MarkerSize=spec{6};
    h.Parent.XLabel.String=handles.ed_xLabel.String;
    %check which y axis to use for plotting
    y_axis_flag=get(handles.y_axis_primary,'Value');
    if y_axis_flag==1
        yyaxis left
    else
        yyaxis right
    end
    h.Parent.YLabel.String=handles.ed_yLabel.String;
    
    h.Parent.XLabel.FontSize=str2double(handles.fontX.String);
    h.Parent.YLabel.FontSize=str2double(handles.fontY.String);



function ed_xLabel_Callback(hObject, eventdata, handles)
% hObject    handle to ed_xLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_xLabel as text
%        str2double(get(hObject,'String')) returns contents of ed_xLabel as a double


% --- Executes during object creation, after setting all properties.
function ed_xLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_xLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_yLabel_Callback(hObject, eventdata, handles)
% hObject    handle to ed_yLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_yLabel as text
%        str2double(get(hObject,'String')) returns contents of ed_yLabel as a double


% --- Executes during object creation, after setting all properties.
function ed_yLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_yLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rSquared.
function rSquared_Callback(hObject, eventdata, handles)
% hObject    handle to rSquared (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rSquared


% --- Executes on selection change in fitType.
function fitType_Callback(hObject, eventdata, handles)
% hObject    handle to fitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fitType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fitType


% --- Executes during object creation, after setting all properties.
function fitType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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


% --- Executes on button press in frontDynamics.
function frontDynamics_Callback(hObject, eventdata, handles)
% hObject    handle to frontDynamics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of frontDynamics


% --- Executes on button press in subPlot.
function subPlot_Callback(hObject, eventdata, handles)
% hObject    handle to subPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of subPlot


% --- Executes on button press in switchVars.
function switchVars_Callback(hObject, eventdata, handles)
% hObject    handle to switchVars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Switch plotting variable axes
%start with higher level variable (steam, facility, NC etc)
tempX1=handles.popupmenu_x_axis.Value;
tempX2=handles.popupmenu_x_axis_var.Value;
handles.popupmenu_x_axis.Value=handles.popupmenu_y_axis.Value;
handles.popupmenu_y_axis.Value=tempX1;

%reset list of variables
tempX3=handles.popupmenu_x_axis_var.String;
handles.popupmenu_x_axis_var.String=handles.popupmenu_y_axis_var.String;
handles.popupmenu_y_axis_var.String=tempX3;
%point to correct element on the list
handles.popupmenu_x_axis_var.Value=handles.popupmenu_y_axis_var.Value;
handles.popupmenu_y_axis_var.Value=tempX2;




% --- Executes on button press in varFilter.
function varFilter_Callback(hObject, eventdata, handles)
% hObject    handle to varFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get chosen filter variable
% get choice of x/y axis phase to be plotted
    list_x=handles.popupmenu17.String;
    val_x=handles.popupmenu17.Value;
    x_param=list_x{val_x};      
    
    % get choice of what parameter of each phase is to be plotted
    list_x_var=handles.popupmenu18.String;
    val_x_var=handles.popupmenu18.Value;
    x_param_var=list_x_var{val_x_var};
    
    filesLoaded=numel(handles.file);
    %allocate
    x_dat=ones(1,filesLoaded);
    
    %extract data values, error values abd st_dev values, if applicable applying file choice filter
    for cntr=1:filesLoaded
        if strcmp(x_param,'custom')
%             x_dat(cntr)=eval(handles.custom(val_x_var).expression);
            customExpressionFunX=@(x) eval(handles.custom(val_x_var).expression);
            x_dat(cntr)=customExpressionFunX(cntr);
        elseif strcmp(x_param,'timing')
            x_dat(cntr)=handles.(x_param)(cntr).(x_param_var);
        else
            x_dat(cntr)=handles.(x_param)(cntr).(x_param_var).value;
        end
    end
    
    %get lower and upper boundaries and their positions
    minVal=str2double(handles.varMin.String);
    maxVal=str2double(handles.varMax.String);
    lower=find(x_dat>=minVal);
    upper=find(x_dat<=maxVal);
    
    %get final mask (intersection)
    finalMask=intersect(lower,upper);
    handles.plot_exclude.Value=finalMask;

% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in popupmenu17.
function popupmenu17_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    vars_list=handles.popupmenu17.String;
    vars_val=handles.popupmenu17.Value;
    vars=vars_list{vars_val};

    %the next line is to set the second popupmenu to common value, otherwise it breaks
    handles.popupmenu18.Value=1;

    %due to different data structure of variable 'custom', this if
    %statement is neccessary
    if strcmp(vars,'custom')
        handles.popupmenu18.String={handles.custom.name};
    else
        handles.popupmenu18.String=fieldnames(handles.(vars));
    end
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu17 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu17


% --- Executes during object creation, after setting all properties.
function popupmenu17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu18.
function popupmenu18_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu18 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu18


% --- Executes during object creation, after setting all properties.
function popupmenu18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function varMin_Callback(hObject, eventdata, handles)
% hObject    handle to varMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of varMin as text
%        str2double(get(hObject,'String')) returns contents of varMin as a double


% --- Executes during object creation, after setting all properties.
function varMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function varMax_Callback(hObject, eventdata, handles)
% hObject    handle to varMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of varMax as text
%        str2double(get(hObject,'String')) returns contents of varMax as a double


% --- Executes during object creation, after setting all properties.
function varMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
