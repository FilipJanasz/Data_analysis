function varargout = gui_save_IC(varargin)
    % GUI_SAVE_IC MATLAB code for gui_save_IC.fig
    %      GUI_SAVE_IC, by itself, creates a new GUI_SAVE_IC or raises the existing
    %      singleton*.
    %
    %      H = GUI_SAVE_IC returns the handle to a new GUI_SAVE_IC or the handle to
    %      the existing singleton*.
    %
    %      GUI_SAVE_IC('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUI_SAVE_IC.M with the given input arguments.
    %
    %      GUI_SAVE_IC('Property','Value',...) creates a new GUI_SAVE_IC or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before gui_save_IC_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to gui_save_IC_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help gui_save_IC

    % Last Modified by GUIDE v2.5 02-Nov-2016 17:43:49

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_save_IC_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_save_IC_OutputFcn, ...
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


% --- Executes just before gui_save_IC is made visible.
function gui_save_IC_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;
    file=varargin{1};
    PA9601=varargin{2};
    PA9701=varargin{3};
    TF9601=varargin{4};
    TF9602=varargin{5};
    TF9701=varargin{6};

    % set parameters
    set(handles.fileName,'String',file)
    axes(handles.IC_plot)
    
    % plot values
    subplot(2,1,1)
    hold on
    plot(PA9601,'r')
    plot(PA9701,'k')
    legend('PA9601','PA9701','Location','eastoutside')
%     t=title(['Initial condition graphs for file:  ', file]);
%     set(t,'interpreter','none')
    ylabel('Press [bar]')
    hold off
    subplot(2,1,2)
    hold on
    plot(TF9601,'b')
    plot(TF9602,'g')
    plot(TF9701,'r')
    legend('TF9601','TF9602','Location','eastoutside')
    ylabel('Temp [C]')
    hold off
    
    
    % Update handles structure
    guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = gui_save_IC_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;


% --- Executes on button press in IC_finder.
function IC_finder_Callback(hObject, eventdata, handles)

    set(handles.IC_table,'Visible','On')
    vertical_cursors(handles)


% --- Executes during object creation, after setting all properties.
function IC_table_CreateFcn(hObject, eventdata, handles)



function testEdit_Callback(hObject, eventdata, handles)
% hObject    handle to testEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of testEdit as text
%        str2double(get(hObject,'String')) returns contents of testEdit as a double


% --- Executes during object creation, after setting all properties.
function testEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
