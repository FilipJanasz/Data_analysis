function varargout = gui_fileFilter(varargin)
% GUI_FILEFILTER MATLAB code for gui_fileFilter.fig
%      GUI_FILEFILTER, by itself, creates a new GUI_FILEFILTER or raises the existing
%      singleton*.
%
%      H = GUI_FILEFILTER returns the handle to a new GUI_FILEFILTER or the handle to
%      the existing singleton*.
%
%      GUI_FILEFILTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FILEFILTER.M with the given input arguments.
%
%      GUI_FILEFILTER('Property','Value',...) creates a new GUI_FILEFILTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_fileFilter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_fileFilter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_fileFilter

% Last Modified by GUIDE v2.5 20-Sep-2017 11:50:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_fileFilter_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_fileFilter_OutputFcn, ...
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


% --- Executes just before gui_fileFilter is made visible.
function gui_fileFilter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_fileFilter (see VARARGIN)

handles.handlesParent=varargin{1};
filesInfo=handles.handlesParent.file;
handles.funcHandle=handles.handlesParent.filterPushbutton.Callback;
cols={'File','Ncratio','Plot?'};
dat(:,1)={filesInfo.name};
dat(:,2)={filesInfo.NCratio};

NCratioMat=cell2mat(dat(:,2)); %covnert cell to numbers easily
handles.NCratioMat=NCratioMat; %store in handles structure

%check if file exist and get / store filter mask
dir={filesInfo.directory};

%see how many of files frome each directory is there
for reachCntr=1:numel(dir)-1
    if strcmp(dir(reachCntr),dir(reachCntr+1))
        compare(reachCntr)=0;
    else
        compare(reachCntr)=1;
    end
end

%create vector that shows how are files names distributed
fileDistr=[1,find(compare)+1,numel(dir)+1];
handles.fileDistr=fileDistr;  %store here to make available to other functions in this GUI

dir=unique(dir,'stable');
handles.dir=dir; %store here to make available to other functions in this GUI

clr{1}=[];
clr{2}=[];
clr{3}=[];
filterMask=[];

for dirCntr=1:numel(dir)
    if exist([dir{dirCntr},'\filterMask.txt'],'file')
        %open and load filter mask
        fid=fopen([dir{dirCntr},'\filterMask.txt'], 'r' );
        tempClr{1}=logical(fgetl(fid)'-'0');
        tempClr{2}=logical(fgetl(fid)'-'0');
        tempClr{3}=logical(fgetl(fid)'-'0');
        tempfilterMask=num2cell(logical(fgetl(fid)'-'0'));
%         dat(:,3)=[dat(:,3);num2cell(logical(fgetl(fid)'-'0'))]
        fclose(fid);
        
        
    else
        currNCratioMat=NCratioMat(fileDistr(dirCntr):fileDistr(dirCntr+1)-1);
        %calculate filters
        tempClr{1}=(currNCratioMat>=0.9 & currNCratioMat<=1.1);                  % good ones
        tempClr{2}=((currNCratioMat>=0.7 & currNCratioMat<0.9)|(currNCratioMat>1.1 & currNCratioMat<=1.3)); % so so ones
        tempClr{3}=(currNCratioMat<0.7 | currNCratioMat>1.3);  %bad ones
        tempfilterMask=num2cell(tempClr{1});
        %store filter mask
        fid=fopen([dir{dirCntr},'\filterMask.txt'], 'wt' );
        fprintf(fid,'%s\n',num2str(tempClr{1}));
        fprintf(fid,'%s\n',num2str(tempClr{2}));
        fprintf(fid,'%s\n',num2str(tempClr{3}));
        fprintf(fid,'%s',num2str(tempClr{1}));%final mask overlay
        fclose(fid);
    end
    
    clr{1}=[clr{1};tempClr{1}];
    clr{2}=[clr{2};tempClr{2}];
    clr{3}=[clr{3};tempClr{3}];
    filterMask=[filterMask;tempfilterMask];
    
    if dirCntr==numel(dir)
            dat(:,3)=filterMask;
    end
end

%apply colors
NCratioMat=cellstr(num2str(NCratioMat)); %convert the numbers to strings and to cells

dat(logical(clr{1}),2) = strcat('<HTML><span style="color: #008000; font-weight: bold;">', NCratioMat(logical(clr{1})),'</span><HTML/>');
dat(logical(clr{2}),2) = strcat('<HTML><span style="color: #FFC300; font-weight: bold;">', NCratioMat(logical(clr{2})),'</span><HTML/>');
dat(logical(clr{3}),2) = strcat('<HTML><span style="color: #FF0000; font-weight: bold;">', NCratioMat(logical(clr{3})),'</span><HTML/>');

handles.dataTable1.Data=dat;
handles.dataTable1.ColumnName=cols;

handles.file=filesInfo;

% Choose default command line output for gui_fileFilter
handles.output = hObject;
% t=uitable('Data',dat,'ColumnName',cols);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_fileFilter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_fileFilter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected cell(s) is changed in dataTable1.
function dataTable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to dataTable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in applyPushbutton.
function applyPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to applyPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    filterMask=cell2mat({handles.dataTable1.Data{:,3}});
    %update main GUI
    handles.handlesParent.plot_exclude.Value=find(filterMask);
    
    %continue to store in file
    filterMask=num2str(filterMask);
    filterMask=filterMask(~isspace(filterMask));
    
    %check if file exist and get / store filter mask
    dir=handles.dir;
    fileDistr=handles.fileDistr;
    
    for dirCntr=1:numel(dir)
        currfilterMask=filterMask(fileDistr(dirCntr):fileDistr(dirCntr+1)-1);
        %read file, and store modified
        fid=fopen([dir{dirCntr},'\filterMask.txt'], 'r' );
        clr{1}=fgetl(fid);
        clr{2}=fgetl(fid);
        clr{3}=fgetl(fid);
        fclose(fid);
        
        fid=fopen([dir{dirCntr},'\filterMask.txt'], 'wt' );

        fprintf(fid,'%s\n',num2str(clr{1}));
        fprintf(fid,'%s\n',num2str(clr{2}));
        fprintf(fid,'%s\n',num2str(clr{3}));
        fprintf(fid,'%s',currfilterMask);      % modified line
        fclose(fid);
    end   
    
    % Update handles structure
    guidata(hObject, handles);


% --- Executes on button press in applyrangePushbutton.
function applyrangePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to applyrangePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NCratio=handles.NCratioMat;
min=str2double(handles.rangeminEdit.String);
max=str2double(handles.rangemaxEdit.String);
fittingRange=NCratio>=min & NCratio<=max;
handles.dataTable1.Data(:,3)=num2cell(fittingRange);



function rangeminEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rangeminEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rangeminEdit as text
%        str2double(get(hObject,'String')) returns contents of rangeminEdit as a double


% --- Executes during object creation, after setting all properties.
function rangeminEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rangeminEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rangemaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rangemaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rangemaxEdit as text
%        str2double(get(hObject,'String')) returns contents of rangemaxEdit as a double


% --- Executes during object creation, after setting all properties.
function rangemaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rangemaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
