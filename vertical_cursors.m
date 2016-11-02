% Disclaimer
% Modified code of Jiro Doke, posted on 22 Feb 2011 here:
% http://ch.mathworks.com/matlabcentral/answers/1758-crosshairs-or-just-vertical-line-across-linked-axis-plots

function vertical_cursors(handles)

    set(gcf,'WindowButtonDownFcn', @clickFcn,'WindowButtonUpFcn', @unclickFcn);
    % Set up cursor text
    allLines = findobj(gcf, 'type', 'line');
    hText = nan(1, length(allLines));
    for id = 1:length(allLines)
       hText(id) = text(NaN, NaN, '','Parent', get(allLines(id), 'Parent'),'BackgroundColor', 'white','Color', get(allLines(id), 'Color'));
    end
    % Set up cursor lines
    allAxes = findobj(gcf, 'Type', 'axes');
    hCur = nan(1, length(allAxes));
    for id = 1:length(allAxes)
       hCur(id) = line([NaN NaN], ylim(allAxes(id)),'Color', 'black', 'Parent', allAxes(id));
    end
    
    function clickFcn(varargin)
        % Initiate cursor if clicked anywhere but the figure
        if strcmpi(get(gco, 'type'), 'figure')
           set(hCur, 'XData', [NaN NaN]);                % <-- EDIT
           set(hText, 'Position', [NaN NaN]);            % <-- EDIT
        else
           set(gcf, 'WindowButtonMotionFcn', @dragFcn)
           dragFcn()
        end
    end

    function dragFcn(varargin)
        % Get mouse location
        pt = get(gca, 'CurrentPoint');
        % Update cursor line position
        set(hCur, 'XData', [pt(1), pt(1)]);
        % Update cursor text
        for idx = 1:length(allLines)
           xdata = get(allLines(idx), 'XData');
           ydata = get(allLines(idx), 'YData');
           if pt(1) >= xdata(1) && pt(1) <= xdata(end)
%               y = interp1(xdata, ydata, pt(1));
%               set(hText(idx), 'Position', [pt(1), y],'String', sprintf('(%0.2f, %0.2f)', pt(1), y));
            set(handles.IC_table,'Data',num2str(pt(1)))
           else
              set(hText(idx), 'Position', [NaN NaN]);
           end
        end
    end

    function unclickFcn(varargin)
        set(gcf, 'WindowButtonMotionFcn', '');
    end
end