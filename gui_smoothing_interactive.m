function varargout = gui_smoothing_interactive(varargin)
    % GUI_SMOOTHING_INTERACTIVE MATLAB code for gui_smoothing_interactive.fig
    %      GUI_SMOOTHING_INTERACTIVE by itself, creates a new GUI_SMOOTHING_INTERACTIVE or raises the
    %      existing singleton*.
    %
    %      H = GUI_SMOOTHING_INTERACTIVE returns the handle to a new GUI_SMOOTHING_INTERACTIVE or the handle to
    %      the existing singleton*.
    %
    %      GUI_SMOOTHING_INTERACTIVE('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUI_SMOOTHING_INTERACTIVE.M with the given input arguments.
    %
    %      GUI_SMOOTHING_INTERACTIVE('Property','Value',...) creates a new GUI_SMOOTHING_INTERACTIVE or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before gui_smoothing_interactive_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to gui_smoothing_interactive_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help gui_smoothing_interactive

    % Last Modified by GUIDE v2.5 22-Jul-2016 14:38:30

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_smoothing_interactive_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_smoothing_interactive_OutputFcn, ...
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

% --- Executes just before gui_smoothing_interactive is made visible.
function gui_smoothing_interactive_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gui_smoothing_interactive (see VARARGIN)

    % Determine the position of the dialog - centered on the callback figure
    % if available, else, centered on the screen
    set(hObject,'Visible','off')
    FigPos=get(0,'DefaultFigurePosition');
    OldUnits = get(hObject, 'Units');
    set(hObject, 'Units', 'pixels');
    OldPos = get(hObject,'Position');
    FigWidth = OldPos(3);
    FigHeight = OldPos(4);
    if isempty(gcbf)
        ScreenUnits=get(0,'Units');
        set(0,'Units','pixels');
        ScreenSize=get(0,'ScreenSize');
        set(0,'Units',ScreenUnits);

        FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
        FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
    else
        GCBFOldUnits = get(gcbf,'Units');
        set(gcbf,'Units','pixels');
        GCBFPos = get(gcbf,'Position');
        set(gcbf,'Units',GCBFOldUnits);
        FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                       (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
    end
    FigPos(3:4)=[FigWidth FigHeight];
    set(hObject,'Position',FigPos);
    set(hObject,'Units',OldUnits);
    set(hObject,'Visible','on')
    
    % Choose default command line output for gui_smoothing_interactive
    handles.user_satisfied = 1;
    
    % Get input data
    handles.MP_temp_var=varargin{1};
    handles.MP_temp_smooth_var=varargin{2};
    handles.first_loop=varargin{6};
    
    %set GUI parameters   
    handles.old.smoothing_type=varargin{3};
    handles.old.frame_size=varargin{4};
    handles.old.sgolay_order=varargin{5};
    set(handles.smoothing_type,'Value',varargin{3})
    set(handles.frame_size,'String',num2str(varargin{4}))
    set(handles.sgolay_order,'String',num2str(varargin{5}))
    
    smoothing_type_set=get(handles.smoothing_type,'String');
    smoothing_type=smoothing_type_set{varargin{3}};

    %based on user choice hide or reveal extra buttons
    if strcmp(smoothing_type, 'Savitzky-Golay')
            set(handles.text25,'Visible','On')
            set(handles.sgolay_order,'Visible','On')
    end
    
    if ~handles.first_loop
        set(handles.yes_and_update_button,'Visible','On')
    end
    
    %plot the smoothed and original data
%     figure
    axes(handles.smoothing_axes)
    hold on
    plot(handles.MP_temp_var)
    plot(handles.MP_temp_smooth_var)
    legend('Raw data','Smoothed data','Location','southwest')
    hold off
    
    % Update handles structure
    guidata(hObject, handles); 

%     % Make the GUI modal
%     set(handles.figure1,'WindowStyle','modal')
    
    % UIWAIT makes gui wait for user response (see UIRESUME)
    uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_smoothing_interactive_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.user_satisfied;
    varargout{2} = handles.new;
    varargout{3} = handles.update_defaults;

    % The figure can be deleted now
    delete(handles.figure1);

% --- Executes on button press in yes_button.
function yes_button_Callback(hObject, eventdata, handles)
    handles.user_satisfied = 1;
    handles.new = 1;
    handles.update_defaults = 0;

    % Update handles structure
    guidata(hObject, handles);

    % Use UIRESUME instead of delete because the OutputFcn needs
    % to get the updated handles structure.
    uiresume(handles.figure1);
    
% --- Executes on button press in yes_and_update_button.
function yes_and_update_button_Callback(hObject, eventdata, handles)
    handles.user_satisfied = 1;
    handles.new = 1;
    handles.update_defaults = 1;

    % Update handles structure
    guidata(hObject, handles);

    % Use UIRESUME instead of delete because the OutputFcn needs
    % to get the updated handles structure.
    uiresume(handles.figure1);

% --- Executes on button press in no_button.
function no_button_Callback(hObject, eventdata, handles)
    %read values from gui for next iteration
    handles.user_satisfied = 0;
    handles.new.smoothing_type=get(handles.smoothing_type,'Value');
    handles.new.frame_size=str2double(get(handles.frame_size,'String'));
    handles.new.sgolay_order=str2double(get(handles.sgolay_order,'String'));
    handles.update_defaults = 0;
    %if user wants to redo the calculation, but did not modify any inputs
    if handles.new.smoothing_type == handles.old.smoothing_type && handles.new.frame_size == handles.old.frame_size && handles.new.sgolay_order == handles.old.sgolay_order
        button = questdlg('No parameters were modified for reruning the calculation - do you want to continue?','You not smart','Yes','No','No'); 
        if strcmp(button,'No')
            return
        end
    end
        % Update handles structure
    guidata(hObject, handles);

    % Use UIRESUME instead of delete because the OutputFcn needs
    % to get the updated handles structure.
    uiresume(handles.figure1);

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


% --------------------------------------------------------------------
function uitoggletool6_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
