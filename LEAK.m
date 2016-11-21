function varargout = LEAK(varargin)
% LEAK MATLAB code for LEAK.fig
%      LEAK, by itself, creates a new LEAK or raises the existing
%      singleton*.
%
%      H = LEAK returns the handle to a new LEAK or the handle to
%      the existing singleton*.
%
%      LEAK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LEAK.M with the given input arguments.
%
%      LEAK('Property','Value',...) creates a new LEAK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LEAK_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LEAK_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LEAK

% Last Modified by GUIDE v2.5 20-Nov-2016 13:47:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LEAK_OpeningFcn, ...
                   'gui_OutputFcn',  @LEAK_OutputFcn, ...
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


% --- Executes just before LEAK is made visible.
function LEAK_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LEAK (see VARARGIN)

% Choose default command line output for LEAK
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LEAK wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LEAK_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% T [K], p [Pa], m [g], dens [kg/m3]
% Gas constant
R=8.3144621; % [J/molK]
R_He=2077; % [J/kgK]
R_N2=296.8; % [J/kgK]
% Molar masses [g/mol]
mol_m_N2=28.0134;
mol_m_He=4;
mol_m_h2o=18.02;
mol_m_air=28.97;
% Volumes [m3]
vol_heaterTank=0.0040675;
vol_NCtank=0.00501;
vol_waterTank=0.0025;
% Areas [m2]
Di_valve=0.006;
A_valve_full=(Di_valve*Di_valve)*pi/4;
% Residual gas in demineralized water (1 bar, room temperature)
dens_dissair=0.023; % [g air/kg water] 25°C room temperature
dens_water=997.13; % 25°C room temperature
m_deminw=dens_water*vol_waterTank;
m_dissair=dens_dissair*m_deminw; % [g]
n_dissair=m_dissair/mol_m_air;
%% Test conditions
% Areas [m2]
pos_valv=0.01;
A_valve=pos_valv*A_valve_full;
T_NCtank=295.15;
T_room=293.15;
Tsat=IAPWS_IF97('Tsat_p',0.4);
vol_satwater=1; 
m_h2o=(400000*(vol_heaterTank-vol_satwater)*mol_m_h2o)/(R*Tsat);  
m_diss=m_dissair;
%% Reading NC IC from table
data = get(handles.uitable1, 'data');
data=data(~cellfun('isempty',data));
rownum=numel(data)/3;
data=reshape(data,rownum,3);
data=str2double(data);
p_heaterTank=100000*data(:,1);
p_NCtank=100000*data(:,2);
mole_fr_N2=data(:,3);
mole_fr_He=1-mole_fr_N2;
% Densities [kg/m3]
dens_He_NCtank=p_NCtank/(R_He*T_NCtank);
dens_He_heaterTank=p_heaterTank/(R_He*Tsat);
dens_N2_NCtank=p_NCtank/(R_N2*T_NCtank);
dens_N2_heaterTank=p_heaterTank/(R_N2*Tsat);
%% Calculate transient
time=0;
t_final=1200;
dt=1;
Nsteps=round(t_final/dt);
for i=1:Nsteps;
    if p_NCtank <= p_heaterTank;
        break
    elseif p_NCtank >= p_heaterTank && mole_fr_N2==0;
        dens_gas_NCtank=dens_He_NCtank;
        %dens_gas_heaterTank=dens_xxx_heaterTank;
        time=time+dt;
        v_gas=sqrt(2*((p_NCtank/dens_gas_NCtank)-(p_heaterTank/dens_gas_NCtank)));
        m_He=v_gas*dens_gas_NCtank*A_valve*time;
        %gas_mass=m_h2o+m_diss+m_He;
        Q_vol=v_gas*A_valve;
        p_NCtank=p_NCtank*exp(-Q_vol/vol_NCtank*dt);
        % plotting
        axes(handles.axes1);
        plot(time,p_NCtank,'-x');
        xlabel('Time [s]' );
        ylabel('NC tank pressure [Pa]');
        grid on;
        axis auto;
        hold on;
        set(handles.edit1,'string',num2str(1000*m_He));
        set(handles.edit2,'string',num2str(time));
    else p_NCtank >= p_heaterTank && mole_fr_N2==1;
        dens_gas_NCtank=dens_N2_NCtank;
        %dens_gas_heaterTank=dens_N2_heaterTank;
        time=time+dt;
        v_gas=sqrt(2*((p_NCtank/dens_gas_NCtank)-(p_heaterTank/dens_gas_NCtank)));
        m_N2=v_gas*dens_gas_NCtank*A_valve*time;
        %gas_mass=m_h2o+m_diss+m_N2;
        Q_vol=v_gas*A_valve;
        p_NCtank=p_NCtank*exp(-Q_vol/vol_NCtank*dt);
        % plotting
        axes(handles.axes1);
        plot(time,p_NCtank,'-x');
        xlabel('Time [s]' );
        ylabel('NC tank pressure [Pa]');
        grid on;
        axis auto;
        hold on;
        set(handles.edit1,'string',num2str(1000*m_N2));
        set(handles.edit2,'string',num2str(time));
    end
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
set(gcf,'units','pixels');
set(handles.axes1,'units','pixels');
pos1=get(handles.axes1,'position');
pos2=get(handles.axes1,'TightInset');
pos=[pos1(1)-pos2(1) pos1(2)-pos2(2) pos1(3)+pos2(1)+pos2(3) pos1(4)+pos2(2)+pos2(4)];
cutout=getframe(gcf,pos);

imwrite(cutout.cdata,'NCtank_pressure.jpg');

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit1.
function edit1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
