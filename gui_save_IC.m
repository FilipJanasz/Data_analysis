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

    % Last Modified by GUIDE v2.5 04-Nov-2016 10:52:13

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
    handles.file=varargin{1};
    handles.PA9601=varargin{2};
    handles.PA9701=varargin{3};
%     TF9601=varargin{4};
    handles.TF9602=varargin{4};
    handles.TF9701=varargin{5};
    handles.filepath=varargin{6};

    % set parameters
    set(handles.fileName,'String',handles.file)
    axes(handles.IC_plot)
    
    % plot values
    subplot(2,1,1)
    hold on
    plot(handles.PA9601,'r')
    plot(handles.PA9701,'k')
    legend('PA9601','PA9701','Location','eastoutside')
%     t=title(['Initial condition graphs for file:  ', file]);
%     set(t,'interpreter','none')
    ylabel('Press [bar]')
    hold off
    subplot(2,1,2)
    hold on
%     plot(TF9601,'b')
    plot(handles.TF9602,'g')
    plot(handles.TF9701,'b')
    legend('TF9602','TF9701','Location','eastoutside')
    ylabel('Temp [C]')
    hold off
    
    
    % Update handles structure
    guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = gui_save_IC_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;


% --- Executes on button press in IC_finder.
function IC_finder_Callback(hObject, eventdata, handles)

%     set(handles.IC_table,'Visible','On')
    


% --- Executes during object creation, after setting all properties.
function IC_table_CreateFcn(hObject, eventdata, handles)

function testEdit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function testEdit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function T_Htank_vac_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function T_Htank_vac_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function time_Htank_vac_Callback(hObject, eventdata, handles)
    timeChoice=str2double(get(handles.time_Htank_vac,'String'));
    if timeChoice<=0
        timeChoice=1;
        set(handles.time_Htank_vac,'String',timeChoice)
    elseif timeChoice>numel(handles.PA9601)
        timeChoice=numel(handles.PA9601);
        set(handles.time_Htank_vac,'String',timeChoice)
    end
    P_Htank_vac=handles.PA9601(timeChoice);
    T_Htank_vac=handles.TF9602(timeChoice);
    set(handles.P_Htank_vac,'String',num2str(P_Htank_vac))
    set(handles.T_Htank_vac,'String',num2str(T_Htank_vac))

% --- Executes during object creation, after setting all properties.
function time_Htank_vac_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function P_Htank_vac_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function P_Htank_vac_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in Htank_vac_pushbutton.
function Htank_vac_pushbutton_Callback(hObject, eventdata, handles)
    param='Htank_vac';
    if ~isfield(handles,'hCur')
        handles.hCur=[];
    end
    handles.hCur=vertical_cursors(handles,param,handles.hCur);
    
    % Update handles structure
    guidata(hObject, handles);

function T_NCtank_vac_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function T_NCtank_vac_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function time_NCtank_vac_Callback(hObject, eventdata, handles)
    timeChoice=str2double(get(handles.time_NCtank_vac,'String'));
    if timeChoice<=0
        timeChoice=1;
        set(handles.time_NCtank_vac,'String',num2str(timeChoice))
    elseif timeChoice>numel(handles.PA9701)
        timeChoice=numel(handles.PA9701);
        set(handles.time_NCtank_vac,'String',num2str(timeChoice))
    end
    P_NCtank_vac_temp=handles.PA9701(timeChoice);
    T_NCtank_vac_temp=handles.TF9701(timeChoice);
    set(handles.P_NCtank_vac,'String',num2str(P_NCtank_vac_temp))
    set(handles.T_NCtank_vac,'String',num2str(T_NCtank_vac_temp))

% --- Executes during object creation, after setting all properties.
function time_NCtank_vac_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function P_NCtank_vac_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function P_NCtank_vac_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in NCtank_vac_pushbutton.
function NCtank_vac_pushbutton_Callback(hObject, eventdata, handles)
    param='NCtank_vac';
    if ~isfield(handles,'hCur')
        handles.hCur=[];
    end
    handles.hCur=vertical_cursors(handles,param,handles.hCur);
    
    % Update handles structure
    guidata(hObject, handles);

function T_Htank_h2o_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function T_Htank_h2o_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function time_Htank_h2o_Callback(hObject, eventdata, handles)
    timeChoice=str2double(get(handles.time_Htank_h2o,'String'));
    if timeChoice<=0
        timeChoice=1;
        set(handles.time_Htank_h2o,'String',num2str(timeChoice))
    elseif timeChoice>numel(handles.PA9601)
        timeChoice=numel(handles.PA9601);
        set(handles.time_Htank_h2o,'String',num2str(timeChoice))
    end
    P_Htank_h2o_temp=handles.PA9601(timeChoice);
    T_Htank_h2o_temp=handles.TF9602(timeChoice);
    set(handles.P_Htank_h2o,'String',num2str(P_Htank_h2o_temp))
    set(handles.T_Htank_h2o,'String',num2str(T_Htank_h2o_temp))

% --- Executes during object creation, after setting all properties.
function time_Htank_h2o_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function P_Htank_h2o_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function P_Htank_h2o_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in Htank_h2o_pushbutton.
function Htank_h2o_pushbutton_Callback(hObject, eventdata, handles)
    param='Htank_h2o';
    if ~isfield(handles,'hCur')
        handles.hCur=[];
    end
    handles.hCur=vertical_cursors(handles,param,handles.hCur);
    
    % Update handles structure
    guidata(hObject, handles);

function T_NCtank_He_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function T_NCtank_He_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function time_NCtank_He_Callback(hObject, eventdata, handles)
    timeChoice=str2double(get(handles.time_NCtank_He,'String'));
    if timeChoice<=0
        timeChoice=1;
        set(handles.time_NCtank_He,'String',num2str(timeChoice))
    elseif timeChoice>numel(handles.PA9701)
        timeChoice=numel(handles.PA9701);
        set(handles.time_NCtank_He,'String',num2str(timeChoice))
    end
    P_NCtank_He_temp=handles.PA9701(timeChoice);
    T_NCtank_He_temp=handles.TF9701(timeChoice);
    set(handles.P_NCtank_He,'String',num2str(P_NCtank_He_temp))
    set(handles.T_NCtank_He,'String',num2str(T_NCtank_He_temp))

% --- Executes during object creation, after setting all properties.
function time_NCtank_He_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function P_NCtank_He_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function P_NCtank_He_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in NCtank_He_pushbutton.
function NCtank_He_pushbutton_Callback(hObject, eventdata, handles)
    param='NCtank_He';
    if ~isfield(handles,'hCur')
        handles.hCur=[];
    end
    handles.hCur=vertical_cursors(handles,param,handles.hCur);
    
    % Update handles structure
    guidata(hObject, handles);

function T_NCtank_full_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function T_NCtank_full_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function time_NCtank_full_Callback(hObject, eventdata, handles)
    timeChoice=str2double(get(handles.time_NCtank_full,'String'));
    if timeChoice<=0
        timeChoice=1;
        set(handles.time_NCtank_full,'String',num2str(timeChoice))
    elseif timeChoice>numel(handles.PA9701)
        timeChoice=numel(handles.PA9701);
        set(handles.time_NCtank_full,'String',num2str(timeChoice))
    end
    P_NCtank_full_temp=handles.PA9701(timeChoice);
    T_NCtank_full_temp=handles.TF9701(timeChoice);
    set(handles.P_NCtank_full,'String',num2str(P_NCtank_full_temp))
    set(handles.T_NCtank_full,'String',num2str(T_NCtank_full_temp))

% --- Executes during object creation, after setting all properties.
function time_NCtank_full_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function P_NCtank_full_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function P_NCtank_full_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in NCtank_full_pushbutton.
function NCtank_full_pushbutton_Callback(hObject, eventdata, handles)
    param='NCtank_full';
    if ~isfield(handles,'hCur')
        handles.hCur=[];
    end
    handles.hCur=vertical_cursors(handles,param,handles.hCur);
    
    % Update handles structure
    guidata(hObject, handles);

function T_Htank_full_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function T_Htank_full_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function time_Htank_full_Callback(hObject, eventdata, handles)
    timeChoice=str2double(get(handles.time_Htank_full,'String'));
    if timeChoice<=0
        timeChoice=1;
        set(handles.time_Htank_full,'String',num2str(timeChoice))
    elseif timeChoice>numel(handles.PA9601)
        timeChoice=numel(handles.PA9601);
        set(handles.time_Htank_full,'String',num2str(timeChoice))
    end
    P_Htank_full_temp=handles.PA9601(timeChoice);
    T_Htank_full_temp=handles.TF9602(timeChoice);
    set(handles.P_Htank_full,'String',num2str(P_Htank_full_temp))
    set(handles.T_Htank_full,'String',num2str(T_Htank_full_temp))

% --- Executes during object creation, after setting all properties.
function time_Htank_full_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function P_Htank_full_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function P_Htank_full_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in Htank_full_pushbutton.
function Htank_full_pushbutton_Callback(hObject, eventdata, handles)
    param='Htank_full';
    if ~isfield(handles,'hCur')
        handles.hCur=[];
    end
    handles.hCur=vertical_cursors(handles,param,handles.hCur);
    
    % Update handles structure
    guidata(hObject, handles);


% --- Executes on button press in pureSteam_pushbutton.
function pureSteam_pushbutton_Callback(hObject, eventdata, handles)
    set(handles.time_NCtank_vac,'String','0')
    set(handles.T_NCtank_vac,'String','0')
    set(handles.P_NCtank_vac,'String','0')
    set(handles.time_NCtank_He,'String','0')
    set(handles.T_NCtank_He,'String','0')
    set(handles.P_NCtank_He,'String','0')
    set(handles.time_NCtank_full,'String','0')
    set(handles.T_NCtank_full,'String','0')
    set(handles.P_NCtank_full,'String','0')
    time_Htank_h2o_temp=get(handles.time_Htank_h2o,'String');
    T_Htank_h2o_temp=get(handles.T_Htank_h2o,'String');
    P_Htank_h2o_temp=get(handles.P_Htank_h2o,'String');
    set(handles.time_Htank_full,'String',time_Htank_h2o_temp)
    set(handles.T_Htank_full,'String',T_Htank_h2o_temp)
    set(handles.P_Htank_full,'String',P_Htank_h2o_temp)
    

% --- Executes on button press in onlyN2_pushbutton.
function onlyN2_pushbutton_Callback(hObject, eventdata, handles)
    time_NCtank_vac_temp=get(handles.time_NCtank_vac,'String');
    P_NCtank_vac_temp=get(handles.P_NCtank_vac,'String');
    T_NCtank_vac_temp=get(handles.T_NCtank_vac,'String');
    set(handles.T_NCtank_He,'String',T_NCtank_vac_temp)
    set(handles.P_NCtank_He,'String',P_NCtank_vac_temp)
    set(handles.time_NCtank_He,'String',time_NCtank_vac_temp)

% --- Executes on button press in onlyHe_pushbutton.
function onlyHe_pushbutton_Callback(hObject, eventdata, handles)
    time_NCtank_He_temp=get(handles.time_NCtank_He,'String');
    P_NCtank_He_temp=get(handles.P_NCtank_He,'String');
    T_NCtank_He_temp=get(handles.T_NCtank_He,'String');
    set(handles.T_NCtank_full,'String',T_NCtank_He_temp)
    set(handles.P_NCtank_full,'String',P_NCtank_He_temp)
    set(handles.time_NCtank_full,'String',time_NCtank_He_temp)


% --- Executes on button press in clearAll_pushbutton.
function clearAll_pushbutton_Callback(hObject, eventdata, handles)
    set(handles.time_NCtank_vac,'String',[])
    set(handles.T_NCtank_vac,'String',[])
    set(handles.P_NCtank_vac,'String',[])
    set(handles.time_Htank_vac,'String',[])
    set(handles.T_Htank_vac,'String',[])
    set(handles.P_Htank_vac,'String',[])
    set(handles.time_Htank_h2o,'String',[])
    set(handles.T_Htank_h2o,'String',[])
    set(handles.P_Htank_h2o,'String',[])
    set(handles.time_NCtank_He,'String',[])
    set(handles.T_NCtank_He,'String',[])
    set(handles.P_NCtank_He,'String',[])
    set(handles.time_NCtank_full,'String',[])
    set(handles.T_NCtank_full,'String',[])
    set(handles.P_NCtank_full,'String',[])
    set(handles.time_Htank_full,'String',[])
    set(handles.T_Htank_full,'String',[])
    set(handles.P_Htank_full,'String',[])


% --- Executes on button press in save_pushbutton.
function save_pushbutton_Callback(hObject, eventdata, handles)
    xlsArray={'P_htank_vac';'T_htank_vac';'P_NCtank_vac';'T_NCtank_vac';'P_htank_h2o';'T_htank_h2o';'P_NCtank_He';'T_NCtank_He';'P_NCtank';'T_NCtank';'P_htank_full';'T_htank_full'};

    xlsArray{1,2}=get(handles.P_Htank_vac,'String');
    xlsArray{2,2}=get(handles.T_Htank_vac,'String');
    
    
    xlsArray{3,2}=str2double(get(handles.P_NCtank_vac,'String'));
    xlsArray{4,2}=str2double(get(handles.T_NCtank_vac,'String'));
    
    xlsArray{5,2}=str2double(get(handles.P_Htank_h2o,'String'));
    xlsArray{6,2}=str2double(get(handles.T_Htank_h2o,'String'));
   
    xlsArray{7,2}=str2double(get(handles.P_NCtank_He,'String'));
    xlsArray{8,2}=str2double(get(handles.T_NCtank_He,'String'));
    
    xlsArray{9,2}=str2double(get(handles.P_NCtank_full,'String'));
    xlsArray{10,2}=str2double(get(handles.T_NCtank_full,'String'));
    
    xlsArray{11,2}=str2double(get(handles.P_Htank_full,'String'));
    xlsArray{12,2}=str2double(get(handles.T_Htank_full,'String'));
    
    if exist([handles.filepath,'\DATA\',handles.file{1},'.xlsx'],'file')
        delete([handles.filepath,'\DATA\',handles.file{1},'.xlsx'])
        disp(['Old IC xlsx for file: ',handles.file{1},' has been deleted'])
    end
    xlswrite([handles.filepath,'\DATA\',handles.file{1},'.xlsx'],xlsArray)
    disp(['IC xlsx for file: ',handles.file{1},' saved succefully'])

