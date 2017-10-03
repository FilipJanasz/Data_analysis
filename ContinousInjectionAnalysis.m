function varargout = ContinousInjectionAnalysis(varargin)
% CONTINOUSINJECTIONANALYSIS MATLAB code for ContinousInjectionAnalysis.fig
%      CONTINOUSINJECTIONANALYSIS, by itself, creates a new CONTINOUSINJECTIONANALYSIS or raises the existing
%      singleton*.
%
%      H = CONTINOUSINJECTIONANALYSIS returns the handle to a new CONTINOUSINJECTIONANALYSIS or the handle to
%      the existing singleton*.
%
%      CONTINOUSINJECTIONANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTINOUSINJECTIONANALYSIS.M with the given input arguments.
%
%      CONTINOUSINJECTIONANALYSIS('Property','Value',...) creates a new CONTINOUSINJECTIONANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ContinousInjectionAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ContinousInjectionAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ContinousInjectionAnalysis

% Last Modified by GUIDE v2.5 03-Oct-2017 14:41:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ContinousInjectionAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @ContinousInjectionAnalysis_OutputFcn, ...
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


% --- Executes just before ContinousInjectionAnalysis is made visible.
function ContinousInjectionAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ContinousInjectionAnalysis (see VARARGIN)

handles.handlesParent=varargin{1};
% Choose default command line output for ContinousInjectionAnalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ContinousInjectionAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ContinousInjectionAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in boundary_layer.
function boundary_layer_Callback(hObject, eventdata, handles)
    %get user choice
    graph_choice=handles.handlesParent.graph_list.Value;
    graph=handles.handlesParent.graph_name{graph_choice};
    yaxis=handles.handlesParent.axischoice{graph_choice};
    
    %set appropriate y axis
    if yaxis==1
        yyaxis left
    elseif yaxis==2
        yyaxis right
    end
    
    %verify the choice
%     if isempty(strfind(graph,'MP')) 
%         errordlg('Boundary layer can only be estimated for data from movable probe - pick correct data')
%     else         
        %get user preference
        av_window=str2double(handles.av_window.String);
        lim_factor=str2double(handles.lim_factor.String);
        position_lim=str2double(handles.position_lim.String);
        
        %get data
        y_dat=handles.handlesParent.y_dat{graph_choice};
        x_dat=handles.handlesParent.x_dat{graph_choice};
        
        %check if user choice is appropriate
        if av_window>numel(x_dat)
            errordlg('Avg window is larger than the data set - may artificailly underpredict boundary layer thickness')
        end
        
        %call function that does the magic (based on bits and pieces from steady_state.m)
        [boundary_layer,calc_data_norm,calc_data_norm_lower,calc_data_norm_upper,x_dat,y_dat]=boundary_layer_calc(y_dat,x_dat,av_window,lim_factor,position_lim);
       
        %point to main axes
        axes(handles.handlesParent.var_axes);
        hold on
%         hold_flag=get(handles.hold_checkbox, 'Value');
%         if ~hold_flag
%             hold off
%         else
%             hold on
%         end
        
        %increase plot counter
        handles.handlesParent.plotcounter=handles.handlesParent.plotcounter+1;
        
        %PLOTTING PLOTTING PLOTTING
        %plot boundary layer on main graph
        handles.handlesParent.graph{handles.handlesParent.plotcounter}=plot([boundary_layer boundary_layer], ylim,'g');
        box off
        
        %update variables
        handles.handlesParent.x_dat{handles.handlesParent.plotcounter}=[boundary_layer boundary_layer];
        handles.handlesParent.value_dat{handles.handlesParent.plotcounter}=ylim;
        handles.handlesParent.graph_name{handles.handlesParent.plotcounter}=[graph,' boundary_layer'];
        handles.handlesParent.axischoice{handles.handlesParent.plotcounter}=yaxis;

        %update legend
        handles.handlesParent.legend=legend(handles.handlesParent.graph_name{1:end});
        set(handles.handlesParent.legend,'interpreter','none')
        legend_state=get(handles.handlesParent.legend_on,'Value');
        if (legend_state && handles.handlesParent.plotcounter>0)
            handles.handlesParent.legend.Visible='On';   
        elseif handles.handlesParent.plotcounter>0
            handles.handlesParent.legend.Visible='Off';
        end

        %update list of graphs
        handles.handlesParent.graph_list.String=handles.handlesParent.graph_name;  
        
        %Plotting processing graphs
        if handles.bl_graph.Value
            figure
            subplot(2,1,1)
            hold on
            plot(x_dat,y_dat,'.')
            plot([boundary_layer boundary_layer], ylim,'g')
            
            subplot(2,1,2)
            hold on
            plot(x_dat,calc_data_norm,'.')
            plot([boundary_layer boundary_layer], ylim*0.991,'g')
            plot(xlim,[calc_data_norm_lower calc_data_norm_lower],'--k')
            plot(xlim,[calc_data_norm_upper calc_data_norm_upper],'--k')
            plot(xlim,[median(calc_data_norm) median(calc_data_norm)],'m') 
        end
        
        %update gui
        handles.handlesParent.bl_calc.String=num2str(boundary_layer);        
        %forward changes
        guidata(hObject, handles);
%     end



function av_window_Callback(hObject, eventdata, handles)
% hObject    handle to av_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of av_window as text
%        str2double(get(hObject,'String')) returns contents of av_window as a double


% --- Executes during object creation, after setting all properties.
function av_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to av_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lim_factor_Callback(hObject, eventdata, handles)
% hObject    handle to lim_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lim_factor as text
%        str2double(get(hObject,'String')) returns contents of lim_factor as a double


% --- Executes during object creation, after setting all properties.
function lim_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lim_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bl_graph.
function bl_graph_Callback(hObject, eventdata, handles)
% hObject    handle to bl_graph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bl_graph



function position_lim_Callback(hObject, eventdata, handles)
% hObject    handle to position_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of position_lim as text
%        str2double(get(hObject,'String')) returns contents of position_lim as a double


% --- Executes during object creation, after setting all properties.
function position_lim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to position_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
