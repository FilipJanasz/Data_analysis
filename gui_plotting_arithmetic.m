function varargout = gui_plotting_arithmetic(varargin)
    % GUI_PLOTTING_ARITHMETIC MATLAB code for gui_plotting_arithmetic.fig
    %      GUI_PLOTTING_ARITHMETIC, by itself, creates a new GUI_PLOTTING_ARITHMETIC or raises the existing
    %      singleton*.
    %
    %      H = GUI_PLOTTING_ARITHMETIC returns the handle to a new GUI_PLOTTING_ARITHMETIC or the handle to
    %      the existing singleton*.
    %
    %      GUI_PLOTTING_ARITHMETIC('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUI_PLOTTING_ARITHMETIC.M with the given input arguments.
    %
    %      GUI_PLOTTING_ARITHMETIC('Property','Value',...) creates a new GUI_PLOTTING_ARITHMETIC or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before gui_plotting_arithmetic_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to gui_plotting_arithmetic_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help gui_plotting_arithmetic

    % Last Modified by GUIDE v2.5 14-Nov-2016 16:39:22

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_plotting_arithmetic_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_plotting_arithmetic_OutputFcn, ...
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


% --- Executes just before gui_plotting_arithmetic is made visible.
function gui_plotting_arithmetic_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.medium=varargin{1};
    handles.var=varargin{2};
    handles.steam=varargin{3};
    handles.NC=varargin{4};
    handles.var_axes=varargin{5};
    %copy the popupmenus from the main gui
    set(handles.popupmenu_medium,'String',handles.medium);
    set(handles.popupmenu_medium,'Value',1);
    
    set(handles.popupmenu_var,'String',handles.var.(handles.medium{1}));
    
    set(handles.popupmenu_var,'Value',1);
    
    handles.output = hObject;
    guidata(hObject, handles);

% UIWAIT makes gui_plotting_arithmetic wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_plotting_arithmetic_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;

% --- Executes on selection change in popupmenu_medium.
function popupmenu_medium_Callback(hObject, eventdata, handles)

    curr_medium_list=get(handles.popupmenu_medium,'String');
    curr_medium_val=get(handles.popupmenu_medium,'Value');
    curr_medium=curr_medium_list{curr_medium_val};
       
    %the next line is to set the second popupmenu to common value, otherwise it breaks
    set(handles.popupmenu_var,'String',handles.var.(curr_medium));
    set(handles.popupmenu_var,'Value',1);
    

% --- Executes during object creation, after setting all properties.
function popupmenu_medium_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in popupmenu_var.
function popupmenu_var_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupmenu_var_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function x_dat_expression_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function x_dat_expression_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function y_dat_expression_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function y_dat_expression_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in insertX_pushbutton.
function insertX_pushbutton_Callback(hObject, eventdata, handles)
    %reads user choice of variable and inserts in a proper box
    curr_medium_list=get(handles.popupmenu_medium,'String');
    curr_medium_val=get(handles.popupmenu_medium,'Value');
    curr_medium=curr_medium_list{curr_medium_val};
    
    curr_var_list=get(handles.popupmenu_var,'String');
    curr_var_val=get(handles.popupmenu_var,'Value');
    curr_var=curr_var_list{curr_var_val};
    
    string_so_far=get(handles.x_dat_expression,'String');
    
    if strcmp(string_so_far,'Type expression here')
        string_so_far=[];
    end
    
    string_to_return=[string_so_far,curr_medium,'.',curr_var,'.value'];
    set(handles.x_dat_expression,'String',string_to_return);


% --- Executes on button press in insertY_pushbutton.
function insertY_pushbutton_Callback(hObject, eventdata, handles)
    %reads user choice of variable and inserts in a proper box
    curr_medium_list=get(handles.popupmenu_medium,'String');
    curr_medium_val=get(handles.popupmenu_medium,'Value');
    curr_medium=curr_medium_list{curr_medium_val};
    
    curr_var_list=get(handles.popupmenu_var,'String');
    curr_var_val=get(handles.popupmenu_var,'Value');
    curr_var=curr_var_list{curr_var_val};
    
    string_so_far=get(handles.y_dat_expression,'String');
    
    if strcmp(string_so_far,'Type expression here')
        string_so_far=[];
    end
    
    string_to_return=[string_so_far,curr_medium,'.',curr_var,'.value'];
    set(handles.y_dat_expression,'String',string_to_return);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    %because of the data structure, it is crucial to add a counter reference after
    %each variable - this piece of code does it automatically, allowing the
    %user to type in expression in more natural way
    
    %for x expression
    Xstr=get(handles.x_dat_expression,'String');
    curr_medium_list=get(handles.popupmenu_medium,'String');
    pos=[];
    for mediumCntr=1:numel(curr_medium_list)
       pos=[pos,strfind(Xstr,curr_medium_list{mediumCntr})+numel(curr_medium_list{mediumCntr})];
    end

    %sort "pos" so we can start adding from the back, not affecting positions in front
    pos=sort(pos,'descend');

    for insrtCntr=1:numel(pos)
        Xstr=[Xstr(1:pos(insrtCntr)-1),'(cntr)',Xstr(pos(insrtCntr):end)];
    end
    
    %for y expression
    Ystr=get(handles.y_dat_expression,'String');
    curr_medium_list=get(handles.popupmenu_medium,'String');
    pos=[];
    for mediumCntr=1:numel(curr_medium_list)
       pos=[pos,strfind(Ystr,curr_medium_list{mediumCntr})+numel(curr_medium_list{mediumCntr})];
    end

    %sort "pos" so we can start adding from the back, not affecting positions in front
    pos=sort(pos,'descend');

    for insrtCntr=1:numel(pos)
        Ystr=[Ystr(1:pos(insrtCntr)-1),'(cntr)',Ystr(pos(insrtCntr):end)];
    end
% 
%     %plotting temp
%     steam=handles.steam;
%     NC=handles.NC;
% %     try
%         for cntr=1:numel(steam)
%             x_dat(cntr)=eval(Xstr);
%             y_dat(cntr)=eval(Ystr);
%         end
% %     catch
% %         disp('Wrong expression')
% %     end
% 
% axes(handles.var_axes)
% plot(x_dat,y_dat,'r.')