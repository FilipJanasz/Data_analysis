function varargout = gui_IC(varargin)
    % GUI_IC MATLAB code for gui_IC.fig
    %      GUI_IC, by itself, creates a new GUI_IC or raises the existing
    %      singleton*.
    %
    %      H = GUI_IC returns the handle to a new GUI_IC or the handle to
    %      the existing singleton*.
    %
    %      GUI_IC('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUI_IC.M with the given input arguments.
    %
    %      GUI_IC('Property','Value',...) creates a new GUI_IC or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before gui_IC_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to gui_IC_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help gui_IC

    % Last Modified by GUIDE v2.5 20-Sep-2017 17:52:05

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_IC_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_IC_OutputFcn, ...
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

% --- Executes just before gui_IC is made visible.
function gui_IC_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gui_IC (see VARARGIN)

    % Choose default command line output for gui_IC
    handles.output = hObject;
    handles.data=varargin{1};
    handles.files_legal_names=varargin{2};
    handles.timing=varargin{3};
    handles.filepath_IC=varargin{4};
    handles.filepath=varargin{5};
    handles.files=varargin{6};
    handles.plotcounter=0;

    %for storing and clearing curves
    handles.graph{1}=0;

    %sett file popup menu proeprly
    set(handles.file_popupmenu,'String',handles.files_legal_names)
    set(handles.file_popupmenu,'Value',1);

    %set first popup menu properly
    vars=fields(handles.data.(handles.files_legal_names{1}));
    set(handles.var_popupmenu,'String',vars)
    set(handles.var_popupmenu,'Value',1);

    %set second popup menu properly
    set(handles.property_popupmenu,'Value',1);

    %update variables popupmenus
    properties=fields(handles.data.(handles.files_legal_names{1}).(vars{1}));
    set(handles.property_popupmenu,'String',properties)

    % Update handles structure
    guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = gui_IC_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

% --- Executes on selection change in file_popupmenu.
function file_popupmenu_Callback(hObject, eventdata, handles)
    file_list=get(handles.file_popupmenu,'String');
    file_val=get(handles.file_popupmenu,'Value');
    file=file_list{file_val};
    
    %get vars for a given file
    vars=fields(handles.data.(file));
    
    %the next line is to set the second popupmenu to common value, otherwise it breaks
%     set(handles.var_popupmenu,'Value',1);
    set(handles.var_popupmenu,'String',fieldnames(handles.data.(file)))

    %the next line is to set the second popupmenu to common value, otherwise it breaks
%     set(handles.property_popupmenu,'Value',1);
%     set(handles.property_popupmenu,'String',fieldnames(handles.data.(file).(vars{1})))

% --- Executes during object creation, after setting all properties.
function file_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in var_popupmenu.
function var_popupmenu_Callback(hObject, eventdata, handles)
    file_list=get(handles.file_popupmenu,'String');
    file_val=get(handles.file_popupmenu,'Value');
    file=file_list{file_val};

    vars_list=get(handles.var_popupmenu,'String');
    vars_val=get(handles.var_popupmenu,'Value');
    vars=vars_list{vars_val};
       
    %the next line is to set the second popupmenu to common value, otherwise it breaks
    set(handles.property_popupmenu,'Value',1);
    set(handles.property_popupmenu,'String',fieldnames(handles.data.(file).(vars)))

% --- Executes during object creation, after setting all properties.
function var_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in property_popupmenu.
function property_popupmenu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function property_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in plot_pushbutton.
function plot_pushbutton_Callback(hObject, eventdata, handles)
    
    % This part gets data to be handled
    file_list=get(handles.file_popupmenu,'String');
    file_val=get(handles.file_popupmenu,'Value');
    file=file_list{file_val};
%     file_choice=get(handles.file_popupmenu,'Value');
    
    % get choice of facility element (steam, coolant, faclity, GHFS etc.) to be plotted
    list_y=get(handles.var_popupmenu,'String');
    val_y=get(handles.var_popupmenu,'Value');
    y_param=list_y{val_y};       
    
    % get choice of what parameter of a facility element is to be plotted
    list_y_var=get(handles.property_popupmenu,'String');
    val_y_var=get(handles.property_popupmenu,'Value');
    y_param_var=list_y_var{val_y_var};
    y_dat=handles.data.(file).(y_param).(y_param_var);

    % figure out how many data points are to be plotted
    y_amount=numel(y_dat);
    
    % This part, based on variable name, assign appropriate period
    % (GHFS1, GHFS2, GHFS3, GHFS4, MP1, MP2, MP3, MP4 - fast period)
    % rest slow, but not MP_Pos, MP_Temp, GHFS1_temp etc
    if  strcmp(y_param,'fast_IC')
        period=handles.timing.fast;
    elseif  strcmp(y_param,'mp_IC')
        period=handles.timing.MP;
    elseif strcmp(y_param,'general_IC')
        period=handles.timing.slow;
    end

    x_dat=period:period:y_amount*period;
    sample_rate=1/period;
    
    % if NOTCH filter box is checked, apply notch filter with the frequency
    % described in GUI 
    % accepts a few values for frequency, delimited with a comma and
    % applies filter for each of them one my one
    % based on http://ch.mathworks.com/help/dsp/ref/fdesign.notch.html
    if get(handles.notch_filter, 'Value')
        notch_passband=str2double(get(handles.notch_passband, 'String'));
        notch_order=str2double(get(handles.notch_order, 'String'));
        notch_freq=get(handles.notch_freq, 'String');
        notch_frequencies=strsplit(notch_freq,',');
        notch_stopband_att=str2double(get(handles.notch_stopband_att,'String'));  %Ast in matlab description
          
        freq_amount=numel(notch_frequencies);
        for filt_ctr=1:freq_amount
            wo=str2double(notch_frequencies{filt_ctr})/((sample_rate)/2);
            if wo<=0 || wo >=1
                errordlg('Notch filter error - check if desired notch frequency is appropriate for the processed signal')
            end
            %calculate quality factor
            notch_Qf=str2double(notch_frequencies{filt_ctr})/notch_passband;
            
            %design a filter
            if isnan(notch_stopband_att)
                f(filt_ctr)=fdesign.notch('N,F0,Q',notch_order,wo,notch_Qf);
            else
                f(filt_ctr)=fdesign.notch('N,F0,Q,Ast',notch_order,wo,notch_Qf,notch_stopband_att);
            end
            
            h(filt_ctr)=design(f(filt_ctr));

%             notch_bw=wo/notch_Qf;
%             [num,den] = iirnotch(wo,notch_bw);
%             y_dat=filtfilt(num,den,y_dat);
        end
        
        %if more than one frequency, then cascade the filter
        total_flt=dfilt.cascade(h(1:end));
        y_dat=filter(total_flt,y_dat);
        
        %update filter info
        notch_type=designmethods(f(filt_ctr));
        set(handles.notch_type,'String',notch_type);
        
        %forwad info for legend
        notch_str=[' | notch ',notch_type{1}];
        
    else
        notch_str='';
    end

    % if LOW PASS filter box is checked, apply notch filter with the frequency
    % described in GUI 
    if get(handles.lowpass_filter, 'Value')
        lowpass_freq=str2double(get(handles.lowpass_freq, 'String'));
        lowpass_order=str2double(get(handles.lowpass_order, 'String'));
        
        Fnorm=lowpass_freq/(sample_rate/2);
        
        if Fnorm<=0 || Fnorm >=1
            errordlg('Lowpass filter error - check if desired cutoff frequency is appropriate for the processed signal')
        end
        lowpass_type_list=get(handles.lowpass_type, 'String');
        lowpass_type_value=get(handles.lowpass_type, 'Value');
        lowpass_type=lowpass_type_list{lowpass_type_value};
        switch lowpass_type
            case 'Butterworth'
%                 design_method='butter';
                [num,den]=butter(lowpass_order,Fnorm);
            case 'Chebyshev I'
                [num,den]=cheby1(lowpass_order,0.01,Fnorm);
%                 design_method='cheby1';
            case 'Chebyshev II'
                [num,den]=cheby2(lowpass_order,20,Fnorm);
%                 design_method='cheby2';
            case 'Elliptic'
                [num,den]=ellip(lowpass_order,0.01,30,Fnorm);
%                 design_method='ellip';
        end
        % apply filter to data
        y_dat=filtfilt(num,den,y_dat);
        
        %forwad info for legend
        lowpass_str=[' | lowp ',lowpass_type];
        
    else
        lowpass_str='';
    end
    
    %check and apply smoothing to the data
    if get(handles.smooth_enable,'Value')
        smoothing_type_set=get(handles.smoothing_type,'String');
        smoothing_type_val=get(handles.smoothing_type,'Value');
        smoothing_type=smoothing_type_set{smoothing_type_val};

        frame_size=str2double(get(handles.frame_size,'String'));

        %based on user choice apply appropriate smoothing algorithm
        switch smoothing_type
            case 'Moving Average'  
                y_dat=smooth(y_dat,frame_size,'moving');
            case 'Savitzky-Golay'
                sgolay_order=str2double(get(handles.sgolay_order,'String'));
                y_dat=smooth(y_dat,frame_size,'sgolay',sgolay_order);
            case 'Lowess'
                y_dat=smooth(y_dat,frame_size,'lowess');
            case 'Loess'
                y_dat=smooth(y_dat,frame_size,'loess');
            case 'RLowess'
                y_dat=smooth(y_dat,frame_size,'rlowess');
            case 'RLoess'
                y_dat=smooth(y_dat,frame_size,'rloess');
        end
        
        %forwad info for legend
        smooth_str=[' | smooth ',smoothing_type];
        
    else
        smooth_str='';
    end

   
    % if Normalize box is checked, normalize graph to between 0 an 1
    if get(handles.normalize, 'Value')
        %find and substract minimum (makes min value in the signal = 0)
        min_val=min(y_dat);
        y_dat=y_dat-min_val;
        %find the new maximum and divide by it (makes the max value in the signal =1
        max_val=max(y_dat);
        y_dat=y_dat./max_val;
        %forwad info for legend
        norm_str=' | normalized';
     
    else
        norm_str='';
    end
    
    %check is user wants to plot -y instead of y
    flip_y_axis=get(handles.flip_y_axis,'Value');
    
    if flip_y_axis
        y_dat=-y_dat;
        %forwad info for legend
        flip_str=' | -y';
    else
        flip_str='';
    end
    
    %define axes
    axes(handles.var_axes);
        
    %check if user wants to hold previous graphs
    hold_flag=get(handles.hold_checkbox, 'Value');
    if ~hold_flag
        hold off
        cla(handles.var_axes)
        xlabel('');
        yyaxis right
        ylabel('');
        yyaxis left
        ylabel('');
        %clear all variables (for same case calling the general clearing
        %function fails to deliver)
        try
            handles=rmfield(handles,'graph_name');
            handles=rmfield(handles,'graph');
            handles=rmfield(handles,'x_dat');
            handles=rmfield(handles,'y_dat');
        catch
        end
        handles.plotcounter=1;
    else
        hold on
        handles.plotcounter=handles.plotcounter+1;
    end
    
     %check which y axis to use for plotting
    y_axis_flag=get(handles.y_axis_primary,'Value');
    
    if y_axis_flag
        % if clause below clears y axis on the opposite axis if hold flag
        % is off
        if ~hold_flag
            yyaxis right
            handles.var_axes.YTick=[];
        end
        % set the desired axes to plot and restore the axis to be visible
        yyaxis left
        handles.var_axes.YTickMode='auto';
    else
        % if clause below clears y axis on the opposite axis if hold flag
        % is off
        if ~hold_flag
            yyaxis left
            handles.var_axes.YTick=[];
        end
        % set the desired axes to plot and restore the axis to be visible
        yyaxis right
        handles.var_axes.YTickMode='auto'; 
    end
    
    % plot with nice color and get user defined line style
    colorstring = 'kbgrmcy';

    line_style_all=get(handles.line_style, 'String');
    line_style_no=get(handles.line_style, 'Value');
    line_style=line_style_all{line_style_no};
    
    line_marker_all=get(handles.line_marker, 'String');
    line_marker_no=get(handles.line_marker, 'Value');
    line_marker=line_marker_all{line_marker_no};
    
    line_color_all=get(handles.line_color, 'String');
    line_color_no=get(handles.line_color, 'Value');
    line_color=line_color_all{line_color_no};
    
    % arrange user defined styling parameters
    if strcmp(line_color,'auto')
        line_color=colorstring(handles.plotcounter);
%         line_color='';
    end
    
    if strcmp(line_marker,'none')
        line_marker='';
    end
    
    if strcmp(line_style,'none')
        line_style='';
    end
    
    %warn if user is about to do something not too smart
    if y_amount>5000 && ~isempty(line_marker)  
        button = questdlg('You''re about to plot a lot of points with line markers enabled - might be slow. Continue with markers?');
        if strcmp(button,'No')
            line_marker='';
            set(handles.line_marker,'Value',2)
        end
    end
    
    %combine input into line specification string
    line_spec=[line_style,line_color,line_marker];
    
    %PLOTTING PLOTTING PLOTTING PLOTTING PLOTTING PLOTTING
    handles.graph{handles.plotcounter}=plot(x_dat,y_dat,line_spec);
    box off
    
    %assign and store a name to the graph
    processing_string=[notch_str,lowpass_str,smooth_str,norm_str,flip_str];
    handles.graph_name{handles.plotcounter}=[file,' ',y_param,' ',y_param_var,' ',processing_string];
    
    %add legend
    handles.legend=legend(handles.graph_name{1:end});
    set(handles.legend,'interpreter','none')

    legend_state=get(handles.legend_on,'Value');
    if (legend_state && handles.plotcounter>0)
        set(handles.legend,'Visible','On')   
    elseif handles.plotcounter>0
        set(handles.legend,'Visible','Off')
    end
    
    %add label
%     ylabel([y_param_var,'  [',handles.data.(file).(y_param).(y_param_var).unit,']'], 'interpreter', 'none');
    xlabel('Time [s]', 'interpreter', 'none')
    
    %store data in the figure
    handles.y_dat{handles.plotcounter}=y_dat;
    handles.x_dat{handles.plotcounter}=x_dat;
    handles.currentclr=colorstring(handles.plotcounter);
    handles.sample_rate{handles.plotcounter}=sample_rate;
    handles.period{handles.plotcounter}=period;
    handles.y_amount{handles.plotcounter}=y_amount;
    
    %update data info
    set(handles.graph_list,'String',handles.graph_name)
    set(handles.graph_list,'Value', handles.plotcounter)
    set(handles.cross_cor_1,'String',handles.graph_name)
%     set(handles.cross_cor_1,'Value', handles.plotcounter)
    set(handles.cross_cor_2,'String',handles.graph_name)
    set(handles.cross_cor_2,'Value', handles.plotcounter)
    set(handles.aq_period,'String',num2str(period));
    set(handles.aq_freq,'String',num2str(sample_rate));
    set(handles.points_no,'String',num2str(y_amount));
    set(handles.data_name,'String',handles.graph_name{handles.plotcounter});

    %send updated handles back up
    guidata(hObject, handles);

% --- Executes on button press in hold_checkbox.
function hold_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in clear_pushbutton.
function clear_pushbutton_Callback(hObject, eventdata, handles)

    % clear screen
    clc
    
    % clear axes
    axes(handles.var_axes);
    xlabel('');
    yyaxis right
    cla
    ylabel('');
    yyaxis left
    cla
    ylabel('');
    
    % delete legend
    if isfield(handles,'legend')
        delete(handles.legend)
    end
    
    %reset GUI elements
    set(handles.graph_list,'String','NA')
    set(handles.graph_list,'Value', 1)
    set(handles.cross_cor_1,'String','NA')
    set(handles.cross_cor_1,'Value', 1)
    set(handles.cross_cor_2,'String','NA')
    set(handles.cross_cor_2,'Value', 1)
    set(handles.aq_period,'String','NA');
    set(handles.aq_freq,'String','NA');
    set(handles.points_no,'String','NA');
    set(handles.data_name,'String','NA');
    
    % reset variables
    handles.plotcounter=0;
    
    %if user presses "clear all" before those fields are created
    %it will throw an error, hence try - catch mess
    try
        handles=rmfield(handles,'graph_name');
        handles=rmfield(handles,'graph');
        handles=rmfield(handles,'x_dat');
        handles=rmfield(handles,'y_dat');
    catch
    end    
    
    %forward changes in handles
    guidata(hObject, handles);
       
% --- Executes on button press in line_delete.
function line_delete_Callback(hObject, eventdata, handles)

    if handles.plotcounter>1
        %get user choice for deltion
        del_choice=get(handles.graph_list,'Value');

        %delete
        delete(handles.graph{del_choice})
        handles.graph{del_choice}=[];
        handles.graph=handles.graph(~cellfun('isempty',handles.graph));

        %update variables
        handles.plotcounter=handles.plotcounter-1;

        handles.x_dat{del_choice}=[]; %first set desired cell to empty
        handles.x_dat=handles.x_dat(~cellfun('isempty',handles.x_dat)); %remove empty cells

        handles.y_dat{del_choice}=[]; %first set desired cell to empty
        handles.y_dat=handles.y_dat(~cellfun('isempty',handles.y_dat)); %remove empty cells

        handles.sample_rate{del_choice}=[];
        handles.sample_rate=handles.sample_rate(~cellfun('isempty',handles.sample_rate));

        handles.period{del_choice}=[];
        handles.period=handles.period(~cellfun('isempty',handles.period));

        handles.y_amount{del_choice}=[];
        handles.y_amount=handles.y_amount(~cellfun('isempty',handles.y_amount));

        handles.graph_name{del_choice}=[]; %first set desired cell to empty
        handles.graph_name=handles.graph_name(~cellfun('isempty',handles.graph_name)); %remove empty cells

        %redraw updated legend
        handles.legend=legend(handles.graph_name{1:end});
        set(handles.legend,'interpreter','none')
        legend_state=get(handles.legend_on,'Value');
        if (legend_state && handles.plotcounter>0)
            set(handles.legend,'Visible','On')   
        elseif handles.plotcounter>0
            set(handles.legend,'Visible','Off')
        end

        %update GUI
        set(handles.graph_list,'String',handles.graph_name)
        set(handles.graph_list,'Value', handles.plotcounter)
        set(handles.cross_cor_1,'String',handles.graph_name)
        set(handles.cross_cor_1,'Value', 1)
        set(handles.cross_cor_2,'String',handles.graph_name)
        set(handles.cross_cor_2,'Value', handles.plotcounter)
    
    else
        clear_pushbutton_Callback(hObject, eventdata, handles)
        %for some reason, doesn't work otherwise
        handles.plotcounter=0;
    end
    
    %forward changes in handles
    guidata(hObject, handles);

function toolbar_save_fig_ClickedCallback(hObject, eventdata, handles)
    %saving figure is problematic due to two y axes
    
    % 0. move to file directory, based on default value stored in GUI    
    old_folder=cd(handles.filepath_IC);
    
    % 1. Ask user for the file name
    saveDataName = uiputfile({'*.png';'*.jpg';'*.pdf';'*.eps';'*.fig';}, 'Save as');
    [~, file_name, ext] = fileparts(saveDataName);
    
    % 2. Save .fig file with the name
    hgsave(handles.var_axes,file_name)

    % 3. Display a hidden figure and load saved .fig to it
    f=figure('Visible','off');
    movegui(f,'center')
    h=hgload(file_name);
    %VERY CRUCIAL, MAKE SURE THAT AXES BELONG TO THE NEW FIGURE
    %OTHERWISE DOESNT WORK, FOR SOME STUPID REASON
    h.Parent=f;   
    %adjust figure size so it matches the axes
    f.Units='characters';
    f.Position=h.Position.*1.2;
    %optionally make visible
%         f.Visible='on';
%         f.Name=saveDataName;

    % 4.save again, to desired format, if it different than fig
    if ~strcmp(ext,'.fig')
        delete([file_name,'.fig'])  
        export_fig (saveDataName, '-transparent','-p','0.02')           % http://ch.mathworks.com/matlabcentral/fileexchange/23629-export-fig   
    end
    msgbox(['Figure saved succesfully as ',saveDataName])
    %move back to original directory
    cd(old_folder)

% --- Executes on button press in flip_y_axis.
function flip_y_axis_Callback(hObject, eventdata, handles)

function frame_size_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function frame_size_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in y_axis_primary.
function y_axis_primary_Callback(hObject, eventdata, handles)

    yyaxis left
%     set(handles.hold_checkbox,'Value', 0);
   
% --- Executes on button press in y_axis_secondary.
function y_axis_secondary_Callback(hObject, eventdata, handles)

    yyaxis right
    % handles.plotcounter=handles.plotcounter+1;
    set(handles.hold_checkbox,'Value', 1);
    guidata(hObject, handles);

% --- Executes on button press in fit_axes.
function fit_axes_Callback(hObject, eventdata, handles)

    axes(handles.var_axes);
    axis auto
    x=xlim;
    xmin=num2str(x(1));
    xmax=num2str(x(2));
    y=ylim;
    ymin=num2str(y(1));
    ymax=num2str(y(2));

% --- Executes on button press in normalize.
function normalize_Callback(hObject, eventdata, handles)

% --- Executes on button press in FFT.
function FFT_Callback(hObject, eventdata, handles)
    
    if ~isfield(handles,'y_dat')
        errordlg('No data to perform FFT - plot data to graph first')
    end
    
    current_graph=get(handles.graph_list,'Value');
    y=handles.y_dat{current_graph};
    x=handles.x_dat{current_graph};

    T = x(2)-x(1);      % Sampling period
    Fs = 1/T;           % Sampling frequency

    L = numel(y);       % Length of signal
    % t = x;              % Time vector

    Y=fft(y);           % calculates fft
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;

    % remove spike at 0
    P1(1)=0;

    % plot
    figure
    plot(f,P1)
    title('Single-Sided Amplitude Spectrum of X(t)')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')

function notch_freq_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function notch_freq_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in notch_filter.
function notch_filter_Callback(hObject, eventdata, handles)

function notch_passband_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function notch_passband_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in lowpass_filter.
function lowpass_filter_Callback(hObject, eventdata, handles)

function lowpass_freq_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function lowpass_freq_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function lowpass_order_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function lowpass_order_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in line_color.
function line_color_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function line_color_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in line_marker.
function line_marker_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function line_marker_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in line_style.
function line_style_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function line_style_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in lowpass_type.
function lowpass_type_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function lowpass_type_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in lowpass_response.
function lowpass_response_Callback(hObject, eventdata, handles)
    current_graph=get(handles.graph_list,'Value');
    lowpass_freq=str2double(get(handles.lowpass_freq, 'String'));
    lowpass_order=str2double(get(handles.lowpass_order, 'String'));
    
    %verify that data was loaded into program
    if ~isfield(handles,'sample_rate')
       errordlg('Choose and load data before testing the filter')
    end
    
    %get normalized frequency
    Fnorm=lowpass_freq/(handles.sample_rate{current_graph}/2);
    %make sure it's correct
    if Fnorm<=0 || Fnorm >=1
        errordlg('Lowpass filter error - check if desired cutoff frequency is appropriate for the processed signal')
    end
    
    %get user requirements for filter
    filter_type_list=get(handles.lowpass_type, 'String');
    filter_type_value=get(handles.lowpass_type, 'Value');
    filter_type=filter_type_list{filter_type_value};
    
    %based on choice, build a required filter
    switch filter_type
        case 'Butterworth'
    %                 design_method='butter';
            [num,den]=butter(lowpass_order,Fnorm);
        case 'Chebyshev Type I'
            [num,den]=cheby1(lowpass_order,0.01,Fnorm);
    %                 design_method='cheby1';
        case 'Chebyshev Type II'
            [num,den]=cheby2(lowpass_order,20,Fnorm);
    %                 design_method='cheby2';
        case 'Elliptic'
            [num,den]=ellip(lowpass_order,0.01,30,Fnorm);
    %                 design_method='ellip';
    end
    fvtool(num,den,'Color','white')

% --- Executes on button press in notch_response.
function notch_response_Callback(hObject, eventdata, handles)
    current_graph=get(handles.graph_list,'Value');
    notch_passband=str2double(get(handles.notch_passband, 'String'));
    notch_order=str2double(get(handles.notch_order, 'String'));
    notch_freq=get(handles.notch_freq, 'String');
    notch_frequencies=strsplit(notch_freq,',');
    notch_stopband_att=str2double(get(handles.notch_stopband_att,'String'));  %Ast in matlab description
    
    freq_amount=numel(notch_frequencies);
    for filt_ctr=1:freq_amount
        if ~isfield(handles,'sample_rate')
            errordlg('Choose and load data before testing the filter')
        end 
        wo=str2double(notch_frequencies{filt_ctr})/((handles.sample_rate{current_graph})/2);
        if wo<=0 || wo >=1
            errordlg('Notch filter error - check if desired notch frequency is appropriate for the processed signal')
        end
         %calculate quality factor
        notch_Qf=str2double(notch_frequencies{filt_ctr})/notch_passband;
   
        %design a filter
        if isnan(notch_stopband_att)
            f(filt_ctr)=fdesign.notch('N,F0,Q',notch_order,wo,notch_Qf);
        else
            f(filt_ctr)=fdesign.notch('N,F0,Q,Ast',notch_order,wo,notch_Qf,notch_stopband_att);
        end
%         f(filt_ctr)=fdesign.notch('N,F0,Q',notch_order,wo,notch_Qf);
        h(filt_ctr)=design(f(filt_ctr));

    end

    %if more than one frequency, then cascade the filter
    %update filter info
    notch_type=designmethods(f(filt_ctr));
    set(handles.notch_type,'String',notch_type);
    total_flt=dfilt.cascade(h(1:end));
    fvtool(total_flt,'Color','white')

function notch_order_Callback(hObject, eventdata, handles)

    notch_order=str2double(get(handles.notch_order, 'String'));
    if mod(notch_order,2)==1
        %for some reason, first button must be repeated in order for both to be
        %shown. I don't understand, but whatever
        button = questdlg('Notch filter order must be even. Changel value to','Notch order error',num2str(notch_order-1),num2str(notch_order+1),num2str(notch_order-1));
        set(handles.notch_order, 'String',button)
    end

% --- Executes during object creation, after setting all properties.
function notch_order_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function notch_stopband_att_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function notch_stopband_att_CreateFcn(hObject, eventdata, handles)
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

% --- Executes on button press in smooth_enable.
function smooth_enable_Callback(hObject, eventdata, handles)

% --- Executes on selection change in graph_list.
function graph_list_Callback(hObject, eventdata, handles)

    current_graph=get(handles.graph_list,'Value');
    set(handles.aq_period,'String',num2str(handles.period{current_graph}));
    set(handles.aq_freq,'String',num2str(handles.sample_rate{current_graph}));
    set(handles.points_no,'String',num2str(handles.y_amount{current_graph}));
    set(handles.data_name,'String',handles.graph_name{current_graph});

% --- Executes during object creation, after setting all properties.
function graph_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in legend_on.
function legend_on_Callback(hObject, eventdata, handles)

    %toggle legend visibility, if there is one
    legend_state=get(handles.legend_on,'Value');

    if (legend_state && handles.plotcounter>0)
        set(handles.legend,'Visible','On')   
    elseif handles.plotcounter>0
        set(handles.legend,'Visible','Off')
    end

% --- Executes on selection change in cross_cor_1.
function cross_cor_1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function cross_cor_1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in cross_cor_2.
function cross_cor_2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function cross_cor_2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in cross_cor_btn.
function cross_cor_btn_Callback(hObject, eventdata, handles)
    %get user choice
    data_1_choice=get(handles.cross_cor_1,'Value');
    data_2_choice=get(handles.cross_cor_2,'Value');
    signal_framing=str2double(get(handles.sigframe,'String'));
    
    %get data based on user choice
    y_data_1=handles.y_dat{data_1_choice};
    y_data_2=handles.y_dat{data_2_choice};
    
    x_data_1=handles.x_dat{data_1_choice};
    x_data_2=handles.x_dat{data_2_choice};
        
    sample_rate_1=handles.sample_rate{data_1_choice};
    sample_rate_2=handles.sample_rate{data_2_choice};
    
    %force data to start at 0 (important for interp1)
    x_data_1=x_data_1-x_data_1(1);
    x_data_2=x_data_2-x_data_2(1);
    
    %if data was sampled at two different sample rates - resample the slower one 
    %based on http://ch.mathworks.com/help/matlab/ref/interp1.html
    
    %interpolation verification
%     figure
%     subplot(2,1,1)
%     plot(y_data_1)
%     subplot(2,1,2)
%     plot(y_data_2,'r')
    
    if sample_rate_1>sample_rate_2
        y_data_2=interp1(x_data_2,y_data_2,x_data_1);
        %change the x data of the slower one to the faster one
        x_data_2=x_data_1;  
        sample_rate_2=sample_rate_1;
        %remove NaN wowrkaround
        y_data_2(find(isnan(y_data_2)))=y_data_2(1);
    elseif sample_rate_1<sample_rate_2
        y_data_1=interp1(x_data_1,y_data_1,x_data_2);
        %change the x data of the slower one to the faster one
        x_data_1=x_data_2;
        sample_rate_1=sample_rate_2;
        %remove NaN wowrkaround
        y_data_1(find(isnan(y_data_1)))=y_data_1(1);
    end
    
%     y_data_2(3490001)
%     find(isnan(y_data_1))
% numel(y_data_1)
% numel(y_data_2)
    %test
%     x_test=1:0.1:100;
%     y_data_1=sin(x_test);
%     y_data_1=awgn(y_data_1,10);
%     a=ones(1,50)*mean(y_data_1);
%     y_data_2=30.*[a,y_data_1(1:numel(y_data_1)-numel(a))];
%     y_data_2=awgn(y_data_2,10);
%     numel(y_data_1)
%     numel(y_data_2)

    %interpolation verification
%     figure
%     subplot(2,1,1)
%     plot(y_data_1)
%     subplot(2,1,2)
%     plot(y_data_2,'r')
    
    %define maximum lag for which cross correlation is calculated
    maxlag=str2double(get(handles.maxlag,'String'))*sample_rate_1;
    
    %calculate crosscorelation for each frame of the signal, nased on user
    %chice
    %convert frame span from %
    signal_framing_real=signal_framing/100;  %convert from % to normal number
    %estimate into how many frames the signal should be divided
    frames=ceil(1/signal_framing_real);
    %estimate how big in terms of data points
    y_data_2_amount=numel(y_data_1);
    frame_span=ceil(y_data_2_amount*signal_framing_real);
    %define borders of first iteration
    xcorr_start=1;
    xcorr_end=frame_span;
    %launch new figure window
    figure
    
    for corr_ctr=1:frames
        %extraxt appropriate data based on current frame borders
        x_data_2_current_frame=xcorr_start:1:xcorr_end;
        y_data_2_current_frame=y_data_2(xcorr_start:xcorr_end);
        %calculate and store correlation for current frame
        [cor{corr_ctr},lag{corr_ctr}] = xcorr(y_data_1,y_data_2_current_frame);
%         find(isnan(cor{corr_ctr}))
        %calculate lag
        [~,I] = max(abs(cor{corr_ctr}));
        lagDiff(corr_ctr) = lag{corr_ctr}(I);                           %lag in data points
        timeDiff(corr_ctr) = lagDiff(corr_ctr)/sample_rate_1;     %lag in seconds
    
        %plot in separate figure
        subplot(3,1,1)
        hold on
        plot(lag{corr_ctr}./sample_rate_1,cor{corr_ctr})
        subplot(3,1,2)
        hold on
        yyaxis left
        plot(x_data_2_current_frame/sample_rate_1,y_data_2_current_frame)
        subplot(3,1,3)
        yyaxis left
        plot((x_data_2_current_frame+lagDiff(corr_ctr))/sample_rate_1,y_data_2_current_frame)
        hold on
        
        %update the framing position
        xcorr_start=xcorr_end+1;
        xcorr_end=xcorr_end+frame_span;
        
        if xcorr_end>y_data_2_amount
            xcorr_end=y_data_2_amount;
        end
    end
    subplot(3,1,2)
    yyaxis right
    plot(x_data_1,y_data_1,'r')
    legend(num2str(timeDiff(1:end)))
    subplot(3,1,3)
    yyaxis right
    plot(x_data_1,y_data_1,'r')
    xlabel('Lag [s]')
    

    
    
%     if lagDiff==0
%         lagDiff=1;
%     end
%     y_data_1_aligned = y_data_1(abs(lagDiff):end);
%     x_data_1_aligned = (0:length(y_data_1_aligned)-1)/sample_rate_1;

%     figure
%     subplot(2,1,1)
%     plot(x_data_1_aligned,y_data_1_aligned)
%     hold on
%     subplot(2,1,2)
%     plot(x_data_2,y_data_2,'r')
%     xlabel('Time (s)')
%     hold off

function maxlag_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function maxlag_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sigframe_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function sigframe_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in rescale_pushbutton.
function rescale_pushbutton_Callback(hObject, eventdata, handles)
    xmin=str2double(get(handles.xmin_edit,'String'));
    xmax=str2double(get(handles.xmax_edit,'String'));
    ymin=str2double(get(handles.ymin_edit,'String'));
    ymax=str2double(get(handles.ymax_edit,'String'));
    set(handles.var_axes,'xlim',[xmin xmax])
    set(handles.var_axes,'ylim',[ymin ymax])


% --- Executes on button press in fitaxes_pushbutton.
function fitaxes_pushbutton_Callback(hObject, eventdata, handles)
    axes(handles.var_axes);
    axis auto
    x=xlim;
    xmin=num2str(x(1));
    xmax=num2str(x(2));
    y=ylim;
    ymin=num2str(y(1));
    ymax=num2str(y(2));
    set(handles.xmin_edit,'String',xmin)
    set(handles.xmax_edit,'String',xmax)
    set(handles.ymin_edit,'String',ymin)
    set(handles.ymax_edit,'String',ymax)

function xmax_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function xmax_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function ymin_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ymin_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function ymax_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ymax_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function xmin_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function xmin_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --------------------------------------------------------------------
function saveIC_ClickedCallback(hObject, eventdata, handles)



% --------------------------------------------------------------------
function graphs_ClickedCallback(hObject, eventdata, handles)
    
    
    % This part gets data to be handled
    file_list=get(handles.file_popupmenu,'String');
    file_val=get(handles.file_popupmenu,'Value');
    file=file_list{file_val};
    
    PA9601=handles.data.(file).general_IC.PA9601;
    PA9701=handles.data.(file).general_IC.PA9701;
%     TF9601=handles.data.(file).general_IC.TF9601;
    TF9602=handles.data.(file).general_IC.TF9602;
    TF9701=handles.data.(file).general_IC.TF9701;
    
    file_proper_name=handles.files(file_val);  %the minus signes were first replaced with floor signs, so now we go back...
    gui_save_IC(file_proper_name,PA9601,PA9701,TF9602,TF9701,handles.filepath)
    
%     hFig=figure('Name',['Initial condition graphs for file:  ', file],'NumberTitle','off');
   

% --- Executes on button press in GHFSoffset_pushbutton.
function GHFSoffset_pushbutton_Callback(hObject, eventdata, handles)

    %get all files
    file_list=get(handles.file_popupmenu,'String');
    file_amount=numel(file_list);

    %calculate offsets
    file_cntr=1;
    for n=1:file_amount
        if isfield(handles.data.(file_list{n}),'fast_IC')      
            GHFS1_offset(file_cntr)=mean(handles.data.(file_list{n}).fast_IC.GHFS1);       
            GHFS2_offset(file_cntr)=mean(handles.data.(file_list{n}).fast_IC.GHFS2);
            GHFS3_offset(file_cntr)=mean(handles.data.(file_list{n}).fast_IC.GHFS3);
            GHFS4_offset(file_cntr)=mean(handles.data.(file_list{n}).fast_IC.GHFS4);

            GHFS1_var(file_cntr)=var(handles.data.(file_list{n}).fast_IC.GHFS1);
            GHFS2_var(file_cntr)=var(handles.data.(file_list{n}).fast_IC.GHFS2);
            GHFS3_var(file_cntr)=var(handles.data.(file_list{n}).fast_IC.GHFS3);
            GHFS4_var(file_cntr)=var(handles.data.(file_list{n}).fast_IC.GHFS4); 
            
            file_cntr=file_cntr+1;
        end
    end
    
    %add mode
    GHFS1_offset(end+1)=mode(GHFS1_offset);
    GHFS2_offset(end+1)=mode(GHFS2_offset);
    GHFS3_offset(end+1)=mode(GHFS3_offset);
    GHFS4_offset(end+1)=mode(GHFS4_offset);
    
    GHFS1_var(end+1)=mode(GHFS1_var);
    GHFS2_var(end+1)=mode(GHFS2_var);
    GHFS3_var(end+1)=mode(GHFS3_var);
    GHFS4_var(end+1)=mode(GHFS4_var);
    
    
    %store data for table
    data4table=[GHFS1_offset',GHFS2_offset',GHFS3_offset',GHFS4_offset',GHFS1_var',GHFS2_var',GHFS3_var',GHFS4_var'];
    %create and populate the table
    tableFig=figure;
    tableFig.Position=[360 502 960 420];
    tableTab=uitable;
    tableTab.Position=[0 0 960 400];
    tableTab.Data=data4table;
    
    %fix column naming
    tableTab.ColumnName={'GHFS1_offset','GHFS2_offset','GHFS3_offset','GHFS4_offset'};
    tableTab.RowName=file_list;

%     figure
%     plot(GHFS1_var,GHFS1_offset,'.')
%     figure
%     plot(GHFS2_var,GHFS2_offset,'.')
%     figure
%     plot(GHFS3_var,GHFS3_offset,'.')
%     figure
%     plot(GHFS4_var,GHFS4_offset,'.')
