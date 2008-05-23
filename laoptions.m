function varargout = LAOptions(varargin)
% LAOPTIONS Application M-file for LAOptions.fig
%    FIG = LAOPTIONS launch LAOptions GUI.
%    LAOPTIONS('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 03-Jul-2002 16:50:44

global spdata

if nargin == 0  % LAUNCH GUI
    
    fig = openfig(mfilename);
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    set(handles.LAPopup1,'String',{'2 STDDEVS';'3 STDDEVS';'p<0.05';'p<0.01';'p<0.005';'p<0.001'}) 
    if isfield(spdata.spont,'mean')
        handles.spont.mean=spdata.spont.mean;
        handles.spont.sd=spdata.spont.sd;
        handles.spont.bin1=spdata.spont.bin1;
        handles.spont.bin2=spdata.spont.bin2;
        handles.spont.bin3=spdata.spont.bin3;
        set(handles.LAEdit1,'String',num2str(spdata.spont.mean))
        set(handles.LAEdit2,'String',num2str(spdata.spont.sd))
        set(handles.Bin1Edit,'String',num2str(spdata.spont.bin1))
        set(handles.Bin2Edit,'String',num2str(spdata.spont.bin2))
        set(handles.Bin3Edit,'String',num2str(spdata.spont.bin3))
    else
        handles.spont.mean=str2num(get(handles.LAEdit1,'String'));
        handles.spont.sd=str2num(get(handles.LAEdit2,'String'));
        handles.spont.bin1=str2num(get(handles.Bin1Edit,'String'));
        handles.spont.bin2=str2num(get(handles.Bin2Edit,'String'));
        handles.spont.bin3=str2num(get(handles.Bin3Edit,'String'));
    end
    s=get(handles.LAPopup1,'String');
    v=get(handles.LAPopup1,'Value');
    handles.method=s{v};
    guidata(fig, handles);
    
    % Wait for callbacks to run and window to be dismissed
    uiwait(fig);        
    
    if nargout > 0
        varargout{1} = fig;
    end
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end
    
end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = LAEdit1_Callback(h, eventdata, handles, varargin)

handles.spont.mean=str2num(get(h,'String'));
guidata(handles.LAFig, handles)

% --------------------------------------------------------------------
function varargout = LAEdit2_Callback(h, eventdata, handles, varargin)

handles.spont.sd=str2num(get(h,'String'));
guidata(handles.LAFig, handles)

% --------------------------------------------------------------------
function varargout = Bin1Edit_Callback(h, eventdata, handles, varargin)

handles.spont.bin1=str2num(get(h,'String'));
guidata(handles.LAFig, handles)

% --------------------------------------------------------------------
function varargout = Bin2Edit_Callback(h, eventdata, handles, varargin)

handles.spont.bin2=str2num(get(h,'String'));
guidata(handles.LAFig, handles)

% --------------------------------------------------------------------
function varargout = Bin3Edit_Callback(h, eventdata, handles, varargin)

handles.spont.bin3=str2num(get(h,'String'));
guidata(handles.LAFig, handles)

% --------------------------------------------------------------------
function varargout = LAPopup1_Callback(h, eventdata, handles, varargin)

global spdata

s=get(h,'String');
v=get(h,'Value');
handles.method=s{v};
if strcmp(handles.method,'2 STDDEVS') |  strcmp(handles.method,'3 STDDEVS')
    set(findobj('UserData','LABin'),'Enable','off');
    set(findobj('UserData','LASD'),'Enable','on');
else
    set(findobj('UserData','LABin'),'Enable','on');
    set(findobj('UserData','LASD'),'Enable','off');
	switch handles.method    
	case 'p<0.05'
		handles.spont.bin1=spdata.spont.ci05(2);
		handles.spont.bin2=spdata.spont.ci05(2);
		handles.spont.bin3=spdata.spont.ci05(2);
		set(handles.Bin1Edit,'String',num2str(handles.spont.bin1));
		set(handles.Bin2Edit,'String',num2str(handles.spont.bin2));
		set(handles.Bin3Edit,'String',num2str(handles.spont.bin3));
	case 'p<0.01'
		handles.spont.bin1=spdata.spont.ci01(2);
		handles.spont.bin2=spdata.spont.ci01(2);
		handles.spont.bin3=spdata.spont.ci05(2);
		set(handles.Bin1Edit,'String',num2str(handles.spont.bin1));
		set(handles.Bin2Edit,'String',num2str(handles.spont.bin2));
		set(handles.Bin3Edit,'String',num2str(handles.spont.bin3));
	case 'p<0.005'
		handles.spont.bin1=spdata.spont.ci005(2);
		handles.spont.bin2=spdata.spont.ci005(2);
		handles.spont.bin3=spdata.spont.ci025(2);
		set(handles.Bin1Edit,'String',num2str(handles.spont.bin1));
		set(handles.Bin2Edit,'String',num2str(handles.spont.bin2));
		set(handles.Bin3Edit,'String',num2str(handles.spont.bin3));
	case 'p<0.001'
		handles.spont.bin1=spdata.spont.ci001(2);
		handles.spont.bin2=spdata.spont.ci001(2);
		handles.spont.bin3=spdata.spont.ci005(2);
		set(handles.Bin1Edit,'String',num2str(handles.spont.bin1));
		set(handles.Bin2Edit,'String',num2str(handles.spont.bin2));
		set(handles.Bin3Edit,'String',num2str(handles.spont.bin3));
	end
end
guidata(handles.LAFig, handles)

% --------------------------------------------------------------------
function varargout = LAButton_Callback(h, eventdata, handles, varargin)

global spdata
spdata.spont.mean=handles.spont.mean;
spdata.spont.sd=handles.spont.sd;
spdata.spont.bin1=handles.spont.bin1;
spdata.spont.bin2=handles.spont.bin2;
spdata.spont.bin3=handles.spont.bin3;
spdata.method=handles.method;                
close(gcf);

