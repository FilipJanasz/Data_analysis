function varargout = gui_custom_expressions(varargin)
    % GUI_CUSTOM_EXPRESSIONS MATLAB code for gui_custom_expressions.fig
    %      GUI_CUSTOM_EXPRESSIONS, by itself, creates a new GUI_CUSTOM_EXPRESSIONS or raises the existing
    %      singleton*.
    %
    %      H = GUI_CUSTOM_EXPRESSIONS returns the handle to a new GUI_CUSTOM_EXPRESSIONS or the handle to
    %      the existing singleton*.
    %
    %      GUI_CUSTOM_EXPRESSIONS('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUI_CUSTOM_EXPRESSIONS.M with the given input arguments.
    %
    %      GUI_CUSTOM_EXPRESSIONS('Property','Value',...) creates a new GUI_CUSTOM_EXPRESSIONS or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before gui_custom_expressions_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to gui_custom_expressions_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help gui_custom_expressions

    % Last Modified by GUIDE v2.5 17-Nov-2016 10:27:23

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_custom_expressions_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_custom_expressions_OutputFcn, ...
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


% --- Executes just before gui_custom_expressions is made visible.
function gui_custom_expressions_OpeningFcn(hObject, eventdata, handles, varargin)
    
    %read inputs
    handles.medium=varargin{1};
    handles.var=varargin{2};
    handles.x_var_handle=varargin{3};
    handles.x_var_value_handle=varargin{4};
    handles.y_var_handle=varargin{5};
    handles.y_var_value_handle=varargin{6};

   

    %copy the popupmenu contents from the main gui
    handles.popupmenu_medium.String=handles.medium;
    handles.popupmenu_medium.Value=1;
    
    handles.popupmenu_var.String=handles.var.(handles.medium{1});    
    handles.popupmenu_var.Value=1;
    
    %fill the listbox with available expressions from file
    [name,expression]=textread('custom_expressions.txt','%s %s');
    for expressionCntr=1:numel(name)
        handles.custom(expressionCntr).name=name{expressionCntr};
        handles.custom(expressionCntr).expression=expression{expressionCntr};
    end
    
    handles.custExpression_listbox.String=name;
    
    handles.output = hObject;
    guidata(hObject, handles);

% UIWAIT makes gui_custom_expressions wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_custom_expressions_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;

% --- Executes on selection change in popupmenu_medium.
function popupmenu_medium_Callback(hObject, eventdata, handles)

    curr_medium_list=handles.popupmenu_medium.String;
    curr_medium_val=handles.popupmenu_medium.Value;
    curr_medium=curr_medium_list{curr_medium_val};
       
    %the next line is to set the second popupmenu to common value, otherwise it breaks
    handles.popupmenu_var.String=handles.var.(curr_medium);
    handles.popupmenu_var.Value=1;
    

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

function customExpression_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function customExpression_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in insert_pushbutton.
function insert_pushbutton_Callback(hObject, eventdata, handles)
    %reads user choice of variable and inserts in a proper box
    curr_medium_list=handles.popupmenu_medium.String;
    curr_medium_val=handles.popupmenu_medium.Value;
    curr_medium=curr_medium_list{curr_medium_val};
    
    curr_var_list=handles.popupmenu_var.String;
    curr_var_val=handles.popupmenu_var.Value;
    curr_var=curr_var_list{curr_var_val};
    
    string_so_far=handles.customExpression.String;
    
    if strcmp(string_so_far,'Type expression here')
        string_so_far=[];
    end
    
    %update textbox
    string_to_return=[string_so_far,curr_medium,'.',curr_var,'.value'];
    handles.customExpression.String=string_to_return;
    
    %bring focus to textbox
    uicontrol(handles.customExpression)



% --- Executes on button press in custExpression_pushbutton.
function custExpression_pushbutton_Callback(hObject, eventdata, handles)
    %because of the data structure, it is crucial to add a counter reference after
    %each variable - this piece of code does it automatically, allowing the
    %user to type in expression in more natural way
    
    %for expression
    expressionStr=handles.customExpression.String;
    curr_medium_list=handles.popupmenu_medium.String;

    for mediumCntr=1:numel(curr_medium_list)
        curr_string=[curr_medium_list{mediumCntr},'.'];
        replace_string=['handles.',curr_medium_list{mediumCntr},'(x).'];
        expressionStr=strrep(expressionStr,curr_string,replace_string); %x is the file counter
    end

    
    if ~isempty(handles.customExpression.String)&&~strcmp(handles.customExpression.String,'Type expression here')
        %write custom expression to file
        custExprFile=fopen('custom_expressions.txt','a');
        fprintf(custExprFile,'%s \r\n',[handles.customExpression.String,' ', expressionStr]);
        fclose(custExprFile);
    
        %update data structure
        handles.custom(end+1).name=handles.customExpression.String;
        handles.custom(end).expression=expressionStr;

        %update listbox
        handles.custExpression_listbox.String={handles.custom.name};
        
        %update main GUI
        %get handle to the main gui
        hMain=findobj('Tag','main_gui');
        %get data structure from main gui
        originalData=guidata(hMain);
        %update relevant fields
        originalData.custom=handles.custom;
        %store it back to main gui
        guidata(hMain,originalData)
        
        %and dropdown boxes
        %first check if in first dropdownbox, 'custom' is selected
        x_var_string_list=handles.x_var_handle.String;
        x_var_value=handles.x_var_handle.Value;
        x_var_string=x_var_string_list(x_var_value);
        %and if yes, udpate the list
        if strcmp(x_var_string,'custom')
            handles.x_var_value_handle.Value=1;
            handles.x_var_value_handle.String={handles.custom.name};
        end
        %do the same for y
        y_var_string_list=handles.y_var_handle.String;
        y_var_value=handles.y_var_handle.Value;
        y_var_string=y_var_string_list(y_var_value);
        if strcmp(y_var_string,'custom')
            handles.y_var_value_handle.Value=1;
            handles.y_var_value_handle.String={handles.custom.name};
        end
        

    end
        %update handles structure
        handles.output = hObject;
        guidata(hObject, handles);

% --- Executes on button press in clear_pushbutton.
function clear_pushbutton_Callback(hObject, eventdata, handles)
    handles.customExpression.String=[];


% --- Executes on selection change in custExpression_listbox.
function custExpression_listbox_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function custExpression_listbox_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in deleteExpression_pushbutton.
function deleteExpression_pushbutton_Callback(hObject, eventdata, handles)
    %get delete selection
    deleteSelection=handles.custExpression_listbox.Value;
    
    %clear desired positions from list
    handles.custom(deleteSelection)=[];
    
    %update listbox
    handles.custExpression_listbox.Value=1;
    handles.custExpression_listbox.String={handles.custom.name};

    
    %update file
    custExprFile=fopen('custom_expressions.txt','w');
    for writeCntr=1:numel(handles.custom)
        fprintf(custExprFile,'%s \r\n',[handles.custom(writeCntr).name,' ', handles.custom(writeCntr).expression]);
    end
    fclose(custExprFile);

    %update main GUI
    %get handle to the main gui
    hMain=findobj('Tag','main_gui');
    %get data structure from main gui
    originalData=guidata(hMain);
    %update relevant fields
    originalData.custom=handles.custom;
    %store it back to main gui
    guidata(hMain,originalData)
        
    %and dropdown boxes
    %first check if in first dropdownbox, 'custom' is selected
    x_var_string_list=handles.x_var_handle.String;
    x_var_value=handles.x_var_handle.Value;
    x_var_string=x_var_string_list(x_var_value);
    %and if yes, udpate the list
    if strcmp(x_var_string,'custom')
        handles.x_var_value_handle.Value=1;
        handles.x_var_value_handle.String={handles.custom.name};
    end
    %do the same for y
    y_var_string_list=handles.y_var_handle.String;
    y_var_value=handles.y_var_handle.Value;
    y_var_string=y_var_string_list(y_var_value);
    if strcmp(y_var_string,'custom')
        handles.y_var_value_handle.Value=1;
        handles.y_var_value_handle.String={handles.custom.name};
    end
        
    %update handles structure
    handles.output = hObject;
    guidata(hObject, handles);
