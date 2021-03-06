function varargout = gui_boundary_layer_interactive(varargin)
    % GUI_BOUNDARY_LAYER_INTERACTIVE MATLAB code for gui_boundary_layer_interactive.fig
    %      GUI_BOUNDARY_LAYER_INTERACTIVE by itself, creates a new GUI_BOUNDARY_LAYER_INTERACTIVE or raises the
    %      existing singleton*.
    %
    %      H = GUI_BOUNDARY_LAYER_INTERACTIVE returns the handle to a new GUI_BOUNDARY_LAYER_INTERACTIVE or the handle to
    %      the existing singleton*.
    %
    %      GUI_BOUNDARY_LAYER_INTERACTIVE('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUI_BOUNDARY_LAYER_INTERACTIVE.M with the given input arguments.
    %
    %      GUI_BOUNDARY_LAYER_INTERACTIVE('Property','Value',...) creates a new GUI_BOUNDARY_LAYER_INTERACTIVE or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before gui_boundary_layer_interactive_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to gui_boundary_layer_interactive_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help gui_boundary_layer_interactive

    % Last Modified by GUIDE v2.5 21-Jul-2016 16:46:14

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_boundary_layer_interactive_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_boundary_layer_interactive_OutputFcn, ...
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

% --- Executes just before gui_boundary_layer_interactive is made visible.
function gui_boundary_layer_interactive_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gui_boundary_layer_interactive (see VARARGIN)

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
    
    % Choose default command line output for gui_boundary_layer_interactive
    handles.user_satisfied = 1;
    
    % Get input data
    handles.MP_forward.temp=varargin{1}.forward.norm_temp;
    handles.MP_forward.pos=varargin{1}.forward.pos;
    handles.MP_forward.lower=varargin{1}.forward.lower;
    handles.MP_forward.upper=varargin{1}.forward.upper;
    handles.MP_forward.blayer=-varargin{1}.forward.blayer;      %minus is essential
    
    handles.MP_backward.temp=varargin{1}.backward.norm_temp;
    handles.MP_backward.pos=varargin{1}.backward.pos;
    handles.MP_backward.lower=varargin{1}.backward.lower;
    handles.MP_backward.upper=varargin{1}.backward.upper;
    handles.MP_backward.blayer=-varargin{1}.backward.blayer;    %minus is essential
    
    handles.first_loop=varargin{5};
    
    %set GUI parameters   
    handles.old.avg_window=varargin{2};
    handles.old.limiting_factor=varargin{3};
    handles.old.x_limit=varargin{4};
    set(handles.avg_window,'String',num2str(varargin{2}))
    set(handles.limiting_factor,'String',num2str(varargin{3}))
    set(handles.x_limit,'String',num2str(varargin{4}))
    
    %show extra button
    if ~handles.first_loop
        set(handles.yes_and_update_button,'Visible','On')
    end
    %plot the smoothed and original data
%     figure
    axes(handles.boundary_layer_axes)
    
    %foward movement boundary layer plot
    subplot(2,1,1)
    hold on
    plot(handles.MP_forward.pos,handles.MP_forward.temp,'r')
    plot([handles.MP_forward.blayer handles.MP_forward.blayer], ylim,'r-.')
    y_limits=ylim;
    plot(xlim,[handles.MP_forward.lower handles.MP_forward.lower],'--k')
    plot(xlim,[handles.MP_forward.upper handles.MP_forward.upper],'--k')
    plot(xlim,[median(handles.MP_forward.temp) median(handles.MP_forward.temp)],'m') 
    legend('Profile forward','Boundary layer forward','Location','southwest')
    hold off
    %backward movement boundary layer plot
    subplot(2,1,2)
    hold on
    plot(handles.MP_backward.pos,handles.MP_backward.temp,'b')
    plot([handles.MP_backward.blayer handles.MP_backward.blayer], ylim,'b-.')
    plot(xlim,[handles.MP_backward.lower handles.MP_backward.lower],'--k')
    plot(xlim,[handles.MP_backward.upper handles.MP_backward.upper],'--k')
    plot(xlim,[median(handles.MP_backward.temp) median(handles.MP_backward.temp)],'m') 
    ylim(y_limits);  %match y axes limits of the graph above
    legend('Profile backward','Boundary layer backward','Location','southwest')
    hold off
    
    % Update handles structure
    guidata(hObject, handles); 

%     % Make the GUI modal
%     set(handles.figure1,'WindowStyle','modal')
    
    % UIWAIT makes gui wait for user response (see UIRESUME)
    uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_boundary_layer_interactive_OutputFcn(hObject, eventdata, handles)
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
    handles.new.avg_window=str2double(get(handles.avg_window,'String'));
    handles.new.limiting_factor=str2double(get(handles.limiting_factor,'String'));
    handles.new.x_limit=str2double(get(handles.x_limit,'String'));
    handles.update_defaults = 0;
    %if user wants to redo the calculation, but did not modify any inputs
    if handles.new.avg_window == handles.old.avg_window && handles.new.limiting_factor == handles.old.limiting_factor && handles.new.x_limit == handles.old.x_limit
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

function avg_window_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function avg_window_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function limiting_factor_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function limiting_factor_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function x_limit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function x_limit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
