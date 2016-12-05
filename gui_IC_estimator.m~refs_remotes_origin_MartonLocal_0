function varargout = gui_IC_estimator(varargin)
% gui_IC_estimator MATLAB code for gui_IC_estimator.fig
%      gui_IC_estimator, by itself, creates a new gui_IC_estimator or raises the existing
%      singleton*.
%
%      H = gui_IC_estimator returns the handle to a new gui_IC_estimator or the handle to
%      the existing singleton*.
%
%      gui_IC_estimator('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in gui_IC_estimator.M with the given input arguments.
%
%      gui_IC_estimator('Property','Value',...) creates a new gui_IC_estimator or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_IC_estimator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_IC_estimator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_IC_estimator

% Last Modified by GUIDE v2.5 03-Nov-2016 14:05:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_IC_estimator_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_IC_estimator_OutputFcn, ...
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


% --- Executes just before gui_IC_estimator is made visible.
function gui_IC_estimator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user table_1 (see GUIDATA)
% varargin   command line arguments to gui_IC_estimator (see VARARGIN)

% Choose default command line output for gui_IC_estimator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_IC_estimator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_IC_estimator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user table_1 (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in 'Calculate gui_IC_estimator' button.
function CalculateIC_Callback(hObject, eventdata, handles)
% hObject    handle to CalculateIC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user table_1 (see GUIDATA)

% table_1 = get(handles.table_1, 'table_1'); %getting table_1 from upper GUI table
data = get(handles.table_1, 'data');
data=data(~cellfun('isempty',data));
rownum=numel(data)/6;
data=reshape(data,rownum,6);
data2=data(:,1);
data3=data(:,2:end);
data3=str2double(data3);
% NC tank pressure calculation using NCfilling_estimation_fun macro (Redlich Kwong + ideal gas
T_room=20; %[°C]
vol_waterTank=0.0025;
vol_heaterTank=0.0040675;
mol_m_air=28.97;
R=8.3144621;
eos=1;
test_amount=size(data3);
mole_fr_NC=data3(:,1);
N2_NC_mole_fr=data3(:,2);
test_press=data3(:,3); 
wall_dT=data3(:,4);
% Residual gas in demineralized water (1 bar, room temperature)
dens_dissair=0.023; % [g air/kg water] 25°C room temperature
dens_water=997.13; % 25°C room temperature
m_deminw=dens_water*vol_waterTank;
m_dissair=dens_dissair*m_deminw; % [g]
n_dissair=m_dissair/mol_m_air;
p_diss_N2=(0.74*n_dissair*R*(T_room+273.15))/vol_heaterTank;

for n=1:test_amount(1);
    if mole_fr_NC(n)==0;
            press_NC_tank_both=0;
            press_NC_tank_He=0;
    else
            [press_NC_tank_both, press_NC_tank_He]=NCfilling_estimation_fun((1-mole_fr_NC(n)),N2_NC_mole_fr(n),T_room,test_press(n),eos);
    end
    y{n,1}=data2{n}; % Hardcopy the experiment name to column 1 from IC table
    if N2_NC_mole_fr(n) > 0;
        y{n,2}=press_NC_tank_both-p_diss_N2/100000;
    else
        y{n,2}=press_NC_tank_both;  % NC tank pressure [bar]
    end
    y{n,3}=press_NC_tank_He; % He pressure [bar]
    y{n,4}=mole_fr_NC(n); % NC mole fraction [-]
    y{n,5}=N2_NC_mole_fr(n); % N2 mole fraction [-]
    y{n,6}=test_press(n); % Test pressure [bar]
    y{n,7}=IAPWS_IF97('Tsat_p',test_press(n)*(1-mole_fr_NC(n))/10)-273.15; % Steam boiling point [°C]
    y{n,8}=y{n,7}-wall_dT(n); % Coolant temperature [°C]
    y{n,9}=IAPWS_IF97('psat_T',y{n,8}+273.15)*10; % Coolant saturation pressure [bar]
    y{n,10}=data3(n,4); % Coolant flow [m3/h]
    y{n,11}=data3(n,3); % wall dT [°C]
end

set(handles.table_2, 'data', y);

% Plotting N2 mole fraction and coolant temperature
axes(handles.axes_IC);
plot(cell2mat(y(:,4)),cell2mat(y(:,8)),'-x');
xlabel('N2 mole fraction [-]');
ylabel('Coolant temperature [°C]');
grid on;
axis auto;

% --- Executes on button press in 'Print to.xls' button.
function Print_Callback(hObject, eventdata, handles)
% hObject    handle to Print (see GCBO)
% eventdata  reserved - to be defined in a future vrsion of MATLAB
% handles    structure with handles and user table_1 (see GUIDATA)
ICtable = get(handles.table_2, 'data');
headers=get(handles.table_2,'columnname');
headers=headers';
ICtable(2:end+1,:)=ICtable;
ICtable(1,:)=headers;
xlswrite('PRECISE_IC_table.xlsx',ICtable);
open('PRECISE_IC_table.xlsx');
