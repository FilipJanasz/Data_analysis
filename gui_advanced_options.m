function varargout = gui_advanced_options(varargin)
    % GUI_ADVANCED_OPTIONS MATLAB code for gui_advanced_options.fig
    %      GUI_ADVANCED_OPTIONS, by itself, creates a new GUI_ADVANCED_OPTIONS or raises the existing
    %      singleton*.
    %
    %      H = GUI_ADVANCED_OPTIONS returns the handle to a new GUI_ADVANCED_OPTIONS or the handle to
    %      the existing singleton*.
    %
    %      GUI_ADVANCED_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUI_ADVANCED_OPTIONS.M with the given input arguments.
    %
    %      GUI_ADVANCED_OPTIONS('Property','Value',...) creates a new GUI_ADVANCED_OPTIONS or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before gui_advanced_options_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to gui_advanced_options_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help gui_advanced_options

    % Last Modified by GUIDE v2.5 18-Jul-2016 17:16:31

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_advanced_options_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_advanced_options_OutputFcn, ...
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


% --- Executes just before gui_advanced_options is made visible.
function gui_advanced_options_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gui_advanced_options (see VARARGIN)

    % Choose default command line output for gui_advanced_options
    handles.output = hObject;
    
    %get data from file (read in callbacl in gui.m) and set them in this
    %gui
    options = varargin{1};
    %for all the options, assign odd values as field names and even values
    %as said fields values
    %field names from the text file have to agree with object handles in
    %this gui
    for options_ctr=1:numel(options)/2;
        odd_ctr=options_ctr*2-1;
        even_ctr=options_ctr*2;
        if ~strcmp(options{odd_ctr},'smoothing_type')
        	set(handles.(options{odd_ctr}),'String',options{even_ctr})
        else
            set(handles.(options{odd_ctr}),'Value',str2double(options{even_ctr}))
            %in case smoothing default is Savitzky - Golay
            if str2double(options{even_ctr})==2
                set(handles.text25,'Visible','On')
                set(handles.sgolay_order,'Visible','On')
            end
        end
    end

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes gui_advanced_options wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    
% --- Outputs from this function are returned to the command line.
function varargout = gui_advanced_options_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    
    varargout{1} = handles.output;

function x_limit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function x_limit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function limiting_factor_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function limiting_factor_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function avg_window_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function avg_window_CreateFcn(hObject, eventdata, handles)
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

% --- Executes on button press in apply_btn.
function apply_btn_Callback(hObject, eventdata, handles)
    %get updated values
    options.avg_window=str2double(get(handles.avg_window,'String'));
    options.limiting_factor=str2double(get(handles.limiting_factor,'String'));
    options.x_limit=str2double(get(handles.x_limit,'String'));
    options.frame_size=str2double(get(handles.frame_size,'String'));
    options.smoothing_type=get(handles.smoothing_type,'Value');
    options.sgolay_order=str2double(get(handles.sgolay_order,'String'));
    options_names=fieldnames(options);
    %open file for writing
    fileID=fopen('adv_options.txt','wt+');
    
    %write to file
    for n=1:numel(options_names)
        line_to_write=[options_names{n},' ',num2str(options.(options_names{n}))];
        fprintf(fileID,'%s\n',line_to_write);  
    end
    
    %close file
    fclose(fileID);
