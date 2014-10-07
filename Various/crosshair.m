function [Xpoint,Ypoint] = crosshair(action);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  crosshair
%
%  A gui interface for reading (x,y) values from a plot.
%
%  A set of mouse driven crosshairs is placed on the current axes,
%  and displays the current (x,y) values of the line plot.  There is an
%  option to provide data specific values or interpolated values.  The
%  resolution of the data specific values depends on both the data
%  resolution and the GUI interface (mainly mouse movement resolution).
%  The interpolated values appear to provide a more continuous function,
%  however they too depend on the GUI interface resolution.  There are
%  currently no options for extrapolation.  Further help is given in
%  the tool tips of the GUI.
%  
%  For multiple traces, plots with the same length(xdata) are
%  tracked. Each mouse click returns Xpoint,Ypoint values and selecting 
%  'done' will remove the GUI and restore the mouse buttons to previous 
%  values.  Selecting 'exit' will remove the GUI and close the figure.
%
%  Useage:  x = [1:10]; y(1,:) = sin(x); y(2,:) = cos(x);
%           figure; plot(x,y); crosshair
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%  Licence:        GNU GPL, no express or implied warranties
%  History: 03/96, Richard G. Cobb <cobbr@plk.af.mil>
%           08/01, Darren.Weber@flinders.edu.au
%                  replaced obsolete 'table1' with 'interp1'; fixed bug
%                  with number of 'traces'; rationalized calculations into
%                  a common subfunction for x,y point calc in 'down','up', 
%                  & 'move' button functions; added option to turn on/off
%                  interpolation and the exit button; simplified updates 
%                  to graphics using global GUI handle structure.
%           11/01, Darren.Weber@flinders.edu.au
%                  added tooltips for several GUI handles
%                  added multiple interpolation methods
%                  added GUI for data matrix indices (given no interpolation)
%                  added option to select trace nearest to mouse click point
%                  reversed order of lines in data matrix to be consistent
%                    with the value returned from the nearest trace subfunction
%                  create crosshair lines after finding all plot lines to
%                    avoid confusing them with the plot lines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global DATA XHR_HANDLES

if ~exist('action','var') 
    action = 'init';
elseif isempty(action)
    action = 'init';
end
    
if strcmp(action, 'init');
    
    XHR_HANDLES.plot = gcf; % Get current figure handles
    XHR_HANDLES.axis = gca; % Get current axis handles
    
    % store current button fcn
    DATA.button = get(XHR_HANDLES.plot,'WindowButtonDownFcn');
    % set XHR button down fcn
    set(XHR_HANDLES.plot,'WindowButtonDownFcn','crosshair(''down'');');
    
    % Paint GUI
    interpstr   =   'none|nearest|linear|spline|cubic';
    interp      =   uicontrol('Style','popup','Units','Normalized',...
                              'Position',[.00 .95 .10 .05],...
                              'TooltipString','MATLAB INTERPOLATION METHODS (none = raw values).', ...
                              'String',interpstr);
                          
    x_value_label = uicontrol('Style','edit','Units','Normalized',...
                              'Position',[.10 .95 .10 .05],...
                              'BackGroundColor',[.7 .7 .7],'String','X value');
    x_value       = uicontrol('Style','edit','Units','Normalized',...
                              'Position',[.20 .95 .15 .05],...
                              'BackGroundColor',[ 0 .7 .7],'String',' ');                      
    y_value_label = uicontrol('Style','edit','Units','Normalized',...
                              'Position',[.35 .95 .10 .05],...
                              'BackGroundColor',[.7 .7 .7],'String','Y value');
    y_value       = uicontrol('Style','edit','Units','Normalized',...
                              'Position',[.45 .95 .15 .05],...
                              'BackGroundColor',[ 0 .7 .7],'String',' ');
    
    y_index_label = uicontrol('Style','edit','Units','Normalized',...
                              'Position',[.92 .85 .08 .05],...
                              'BackGroundColor',[.7 .7 .7],'String','Yindex',...
                              'TooltipString','Y index into plot Y data matrix.  Same as trace number.');
    y_index       = uicontrol('Style','edit','Units','Normalized',...
                              'Position',[.92 .80 .08 .05],...
                              'BackGroundColor',[ 0 .7 .7],'String','');
    x_index_label = uicontrol('Style','edit','Units','Normalized',...
                              'Position',[.92 .75 .08 .05],...
                              'BackGroundColor',[.7 .7 .7],'String','Xindex',...
                              'TooltipString','X index into plot Y data matrix.  Only available for interpolation = ''none''.');
    x_index       = uicontrol('Style','edit','Units','Normalized',...
                              'Position',[.92 .70 .08 .05],...
                              'BackGroundColor',[ 0 .7 .7],'String','');
    x_prev        = uicontrol('Style','Push','Units','Normalized',...
                              'Position',[.92 .65 .08 .05],...
                              'String','Prev X',...
                              'Tag','crosshair_NEXTX',...
                              'TooltipString','Goto Previous X Index (no interpolation).',...
                              'CallBack','crosshair(''prevx'');');
    x_next        = uicontrol('Style','Push','Units','Normalized',...
                              'Position',[.92 .60 .08 .05],...
                              'String','Next X',...
                              'Tag','crosshair_NEXTX',...
                              'TooltipString','Goto Next X Index (no interpolation).',...
                              'CallBack','crosshair(''nextx'');');
                              
    closer        = uicontrol('Style','Push','Units','Normalized',...
                              'Position',[.80 .00 .10 .05],...
                              'String','Done',...
                              'Tag','crosshair_DONE',...
                              'TooltipString','Close crosshair', ...
                              'CallBack','crosshair(''done'');');
    exit          = uicontrol('Style','Push','Units','Normalized',...
                              'Position',[.90 .00 .10 .05],...
                              'String','Exit',...
                              'Tag','crosshair_EXIT',...
                              'TooltipString','Close crosshair and Figure', ...
                              'CallBack','crosshair(''exit'');');
                          
    
    % Get Line Data from Plot

    % Lines are referenced as axis children, among other
    % axis children; so first get all axis children
    sibs = get(XHR_HANDLES.axis,'Children');
    
    % Now search axis children for any line types.
    % Because the columns of the y data matrix in a plot
    % command seem to be reversed in the axis children, 
    % count down from max sibs to the first sib.
    linesfound = 0;
    DATA.xdata = [];
    DATA.ydata = [];
    DATA.xpoint = [];
    DATA.ypoint = [];
    DATA.xindex = 1;
    DATA.yindex = 1;
    i = max(size(sibs));
    while i >= 1
        if isgraphics(sibs( i ),'line')
            
            % OK, found a line among the axis children.
            linesfound = linesfound + 1;
            
            % put line data into a column of DATA.xdata|DATA.ydata
            DATA.xdata(:,linesfound) = get(sibs(i),'XData').';
            DATA.ydata(:,linesfound) = get(sibs(i),'YData').';
        end
        i = i - 1;
    end
    
    % 'traces' string variable must be in ascending order
    traces  = '';
    i = 1;
    while i <= linesfound;
        if i < linesfound
            tracelabel = sprintf('Column %4d|',i);            
        else
            tracelabel = sprintf('Column %4d',i);
        end
        traces = strcat(traces,tracelabel);
        i = i + 1;
    end
    
    % If more than one line, provide GUI for line selection
    
    % Switch off||on Trace Selection GUI
    Vis = 'Off';
    if linesfound > 1,
        Vis = 'On';
    elseif linesfound == 0
        error('No lines found in the current plot window\n');
    end
    
    % Create Trace Index
    
    xhairs_on       =   uicontrol('Style','Edit', 'Units','Normalized',...
                                  'Position',[.00 .00 .15 .05],...
                                  'Visible',Vis,'String','Select Trace :',...
                                  'TooltipString','Select trace to follow with crosshairs.');
    trace_switcher  =   uicontrol('Style','Popup','Units','Normalized',...
                                  'Position',[.15 .00 .20 .05],...
                                  'BackGroundColor','w','String',traces,...
                                  'Visible',Vis,...
                                  'CallBack',['[Xpoint,Ypoint] = crosshair(''up'');',]);    
    neartrace_check =   uicontrol('Style','checkbox', 'Units','Normalized',...
                                  'Position',[.36 .00 .19 .05],...
                                  'Visible',Vis,'String','Nearest Trace','Value',0,...
                                  'TooltipString','Trace nearest to mouse click. Updates ''Select Trace''; switch off to keep trace constant.');
    
    % Set X,Y cross hair lines
    % Do this after finding all the line axis children
    % to avoid confusing these lines with those of the
    % plot itself (counted above).
    x_rng = get(XHR_HANDLES.axis,'Xlim');
    y_rng = get(XHR_HANDLES.axis,'Ylim');
    
    XHR_HANDLES.xline = line(x_rng,[y_rng(1) y_rng(1)]);
    XHR_HANDLES.yline = line(x_rng,[y_rng(1) y_rng(1)]);
    
    set(XHR_HANDLES.xline,'Color','r');
    set(XHR_HANDLES.yline,'Color','r');
    
    % Save GUI handles
    XHR_HANDLES.interp = interp;
    XHR_HANDLES.xvalLabel = x_value_label;
    XHR_HANDLES.xval = x_value;
    XHR_HANDLES.xindexLabel = x_index_label;
    XHR_HANDLES.xindex = x_index;
    XHR_HANDLES.xnext = x_next;
    XHR_HANDLES.xprev = x_prev;
    XHR_HANDLES.yvalLabel = y_value_label;
    XHR_HANDLES.yval = y_value;
    XHR_HANDLES.yindexLabel = y_index_label;
    XHR_HANDLES.yindex = y_index;
    XHR_HANDLES.trace = trace_switcher;
    XHR_HANDLES.xhairs = xhairs_on;
    XHR_HANDLES.neartrcheck = neartrace_check;
    XHR_HANDLES.close = closer;
    XHR_HANDLES.exit = exit;
    
    DATA = updateDATA(XHR_HANDLES,DATA);
    Xpoint = get(XHR_HANDLES.xval,'Value');
    Ypoint = get(XHR_HANDLES.yval,'Value');
    
% Mouse Click Down
elseif strcmp(action,'down');

    set(XHR_HANDLES.plot,'WindowButtonMotionFcn','crosshair(''move'');');
    set(XHR_HANDLES.plot,'WindowButtonUpFcn','[Xpoint,Ypoint] = crosshair(''up'');');
    
    DATA = updateDATA(XHR_HANDLES,DATA);
    Xpoint = get(XHR_HANDLES.xval,'Value');
    Ypoint = get(XHR_HANDLES.yval,'Value');
    
% Mouse Drag Motion
elseif strcmp(action,'move');
    
    DATA = updateDATA(XHR_HANDLES,DATA);
    Xpoint = get(XHR_HANDLES.xval,'Value');
    Ypoint = get(XHR_HANDLES.yval,'Value');
    
% Mouse Click Up
elseif strcmp(action,'up');
    
    set(XHR_HANDLES.plot,'WindowButtonMotionFcn',' ');
    set(XHR_HANDLES.plot,'WindowButtonUpFcn',' ');
    
    DATA = updateDATA(XHR_HANDLES,DATA);
    Xpoint = get(XHR_HANDLES.xval,'Value');
    Ypoint = get(XHR_HANDLES.yval,'Value');

    
% Next or Previous X point
elseif or(strcmp(action,'nextx'),strcmp(action,'prevx'));
    
    DATA = moveX(XHR_HANDLES,DATA,action);
    Xpoint = get(XHR_HANDLES.xval,'Value');
    Ypoint = get(XHR_HANDLES.yval,'Value');

% Exit crosshairs GUI
elseif or(strcmp(action,'done'),strcmp(action,'exit'));
    
    Xpoint = get(XHR_HANDLES.xval,'Value');
    Ypoint = get(XHR_HANDLES.yval,'Value');
    
    delete(XHR_HANDLES.interp);
    delete(XHR_HANDLES.xline);
    delete(XHR_HANDLES.yline);
    delete(XHR_HANDLES.xvalLabel);
    delete(XHR_HANDLES.xval);
    delete(XHR_HANDLES.xindexLabel);
    delete(XHR_HANDLES.xindex);
    delete(XHR_HANDLES.xnext);
    delete(XHR_HANDLES.xprev);
    delete(XHR_HANDLES.yvalLabel);
    delete(XHR_HANDLES.yval);
    delete(XHR_HANDLES.yindexLabel);
    delete(XHR_HANDLES.yindex);
    delete(XHR_HANDLES.trace);
    delete(XHR_HANDLES.xhairs);
    delete(XHR_HANDLES.neartrcheck);
    delete(XHR_HANDLES.close);
    delete(XHR_HANDLES.exit);
    
    if strcmp(action,'exit');
        
        close(XHR_HANDLES.plot);
    else
        
        set(XHR_HANDLES.plot,'WindowButtonUpFcn','');
        set(XHR_HANDLES.plot,'WindowButtonMotionFcn','');
        set(XHR_HANDLES.plot,'WindowButtonDownFcn',DATA.button);
        
        refresh(XHR_HANDLES.plot);
    end
    
    clear DATA XHR_HANDLES;
    
end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D] = moveX(HANDLES,D,move)
    
    if strcmp(move,'nextx')
        % Increase current xindex by one
        D.xindex = D.xindex + 1;
    elseif strcmp(move,'prevx')
        % Decrease current xindex by one
        D.xindex = D.xindex - 1;
    end
    
    % Get x point/value at new xindex
    s = size(D.xdata);
    if  D.xindex <= 0
        D.xindex = 1;
    elseif D.xindex >= s(1)
        D.xindex = s(1);
    end
    D.xpoint = D.xdata(D.xindex,D.yindex);
    D.ypoint = D.ydata(D.xindex,D.yindex);
    
    set(HANDLES.interp,'Value',1);
    updateGUI(HANDLES,D);
    
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D] = updateDATA(HANDLES,D)

    CurrentPoint    = get(HANDLES.axis,'Currentpoint');
    D.xpoint        = CurrentPoint(1,1);
    D.ypoint        = CurrentPoint(1,2);
    
    InterpMethod    = get(HANDLES.interp,'Value');
    doNearTrace     = get(HANDLES.neartrcheck,'Value');
    
    if (doNearTrace > 0)
        
        [ D.xpoint, ...
          D.xindex, ...
          D.ypoint, ...
          D.yindex ] = NearestXYMatrixPoint( D.xdata,...
                                             D.ydata,...
                                             D.xpoint,...
                                             D.ypoint);
    else
        D.yindex = get(HANDLES.trace,'Value');
    end
    
    % Reinitialise x,y point to current mouse point
    CurrentPoint    = get(HANDLES.axis,'Currentpoint');
    D.xpoint        = CurrentPoint(1,1);
    D.ypoint        = CurrentPoint(1,2);

    % Now do interpolation (if any)
    D = interpY( D, InterpMethod );
    
    updateGUI(HANDLES,D);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateGUI(H,D)

    InterpMethod = get(H.interp,'Value');
    if (InterpMethod > 1)
        % There is no specific matrix x-index for an interpolated point
        set(H.xindex,'String','');
    else
        set(H.xindex,'String',num2str(D.xindex));
    end
    set(H.xindex,'Value',D.xindex);
    
    tracestr = sprintf('%d',D.yindex);
    set(H.yindex,'String',tracestr,'Value',uint16(D.yindex));
    set(H.trace,'Value',uint16(D.yindex));
    
    x_rng  = get(H.axis,'Xlim');
    y_rng  = get(H.axis,'Ylim');
    
    % Create the crosshair lines on the figure, crossing at the x,y point
    set(H.xline,'Xdata',[D.xpoint D.xpoint],'Ydata',y_rng);
    set(H.yline,'Ydata',[D.ypoint D.ypoint],'Xdata',x_rng);
    
    % Update the x,y values displayed for the x,y point
    xstring = sprintf('%14.6f',D.xpoint);
    ystring = sprintf('%14.6f',D.ypoint);
    set(H.xval,'String',xstring,'Value',D.xpoint);
    set(H.yval,'String',ystring,'Value',D.ypoint);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ DAT ] = interpY(DAT,interp)
    
    % In this function, xdata & ydata are arrays, not matrices
    xdata  = DAT.xdata(:,DAT.yindex);
    ydata  = DAT.ydata(:,DAT.yindex);
    
    if      DAT.xpoint >= max(xdata)                
            DAT.xpoint  = max(xdata);
            DAT.xindex  = find(xdata == max(xdata));
            DAT.ypoint  = ydata(DAT.xindex);
            return;
    elseif  DAT.xpoint <= min(xdata)
            DAT.xpoint  = min(xdata);
            DAT.xindex  = find(xdata == min(xdata));
            DAT.ypoint  = ydata(DAT.xindex);
            return;
    end
    
    % 'none|nearest|linear|spline|cubic'
    switch interp
    case 1
        % Given that xdata & ydata are the same length arrays,
        % we can find the ypoint given the nearest xpoint.
        [DAT.xpoint, DAT.xindex] = NearestXYArrayPoint( xdata, DAT.xpoint );
        DAT.ypoint = ydata(DAT.xindex);
    case 2
        DAT.ypoint = interp1( xdata, ydata, DAT.xpoint, 'nearest' );
    case 3
        DAT.ypoint = interp1( xdata, ydata, DAT.xpoint, 'linear' );
    case 4
        DAT.ypoint = interp1( xdata, ydata, DAT.xpoint, 'spline' );
    case 5
        DAT.ypoint = interp1( xdata, ydata, DAT.xpoint, 'cubic' );
    otherwise
        %use default (linear in matlabR12)
        DAT.ypoint = interp1( xdata, ydata, DAT.xpoint );
    end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ point, index ] = NearestXYArrayPoint( data_array, point )
    
    % In this function, input data_array is an array, not a matrix.
    % This function returns the data point in the array
    % that has the closest value to the value given (point).  In
    % the context of 'crosshair' the point is a mouse position.
    
    if      point >= max(data_array)
            point  = max(data_array);
            index  = find(data_array == point);
            return;
    elseif  point <= min(data_array)
            point  = min(data_array);
            index  = find(data_array == point);
            return;
    end
    
    data_sorted = sort(data_array);
    
    greater = find(data_sorted > point);
    greater_index = greater(1);
    
    lesser = find(data_sorted < point);
    lesser_index = lesser(length(lesser));
    
    greater_dif = data_sorted(greater_index) - point;
    lesser_dif  = point - data_sorted(lesser_index);
    
    if (greater_dif < lesser_dif)
        index = find(data_array == data_sorted(greater_index));
    else
        index = find(data_array == data_sorted(lesser_index));
    end
    point = data_array(index);
    
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ xpoint, xindex, ypoint, yindex ] = NearestXYMatrixPoint( Xdata, Ydata, xpoint, ypoint )

    % In this function, Xdata & Ydata are matrices of the same dimensions.
    % This function attempts to find the nearest values in Xdata & Ydata
    % to the mouse position (xpoint, ypoint).
    
    % It is assumed that Xdata has identical columns, so we only really
    % need the first column to find the nearest value to xpoint.
    
    [ xpoint, xindex ] = NearestXYArrayPoint( Xdata(:,1), xpoint );
    
    % Now, given the xpoint, we can select just that row of the
    % Ydata matrix corresponding to the xpoint.
    ydata = Ydata(xindex,:);
    
    % The ydata array is searched in same manner as the xdata
    % array for the nearest value.
    [ ypoint, yindex ] = NearestXYArrayPoint( ydata, ypoint );
    
return
