function varargout = splotfig(varargin)
% SPLOTFIG Application M-file for splotfig.fig
%    FIG = SPLOTFIG launch splotfig GUI.
%    SPLOTFIG('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 26-Oct-2011 12:51:21

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

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
function varargout = AxCheck_Callback(h, eventdata, handles, varargin)

Value=get(h,'Value');                        
if Value==1                                     
set(findobj('UserData','AxEdit'),'Enable','off')
else                                            
set(findobj('UserData','AxEdit'),'Enable','on') 
end         

% --------------------------------------------------------------------
function varargout = SPAnalMenu_Callback(h, eventdata, handles, varargin)

Value=get(h,'Value');  
String=get(h,'String');
String=String{Value};     
splot(String);   


% --- Executes on button press in SPlotISI.
function SPlotISI_Callback(hObject, eventdata, handles)
% hObject    handle to SPlotISI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SPlotISI


% --- Executes on selection change in SPXBox.
function SPXBox_Callback(hObject, eventdata, handles)
% hObject    handle to SPXBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SPXBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SPXBox
global spdata
spdata.linfo=[];
spdata.latency = [];
spdata.bars = [];
spdata.changetitle=0;
splot('Plot');

% --- Executes on selection change in SPYBox.
function SPYBox_Callback(hObject, eventdata, handles)
% hObject    handle to SPYBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SPYBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SPYBox
global spdata
spdata.linfo=[];
spdata.latency = [];
spdata.bars = [];
spdata.changetitle=0;splot('Plot');


% --- Executes on selection change in SPBARSpriorid.
function SPBARSpriorid_Callback(hObject, eventdata, handles)
% hObject    handle to SPBARSpriorid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SPBARSpriorid contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SPBARSpriorid


function SPBARSdparams_Callback(hObject, eventdata, handles)
% hObject    handle to SPBARSdparams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPBARSdparams as text
%        str2double(get(hObject,'String')) returns contents of SPBARSdparams as a double

function SPBARSburniter_Callback(hObject, eventdata, handles)
% hObject    handle to SPBARSburniter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPBARSburniter as text
%        str2double(get(hObject,'String')) returns contents of SPBARSburniter as a double


function SPBARSconflevel_Callback(hObject, eventdata, handles)
% hObject    handle to SPBARSconflevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPBARSconflevel as text
%        str2double(get(hObject,'String')) returns contents of SPBARSconflevel as a double


function SPSpPos_Callback(hObject, eventdata, handles)
% hObject    handle to SPSpPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPSpPos as text
%        str2double(get(hObject,'String')) returns contents of SPSpPos as a double


% --- Executes on button press in SPExport.
function SPExport_Callback(hObject, eventdata, handles)
% hObject    handle to SPExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function SPPercentage_Callback(hObject, eventdata, handles)
% hObject    handle to SPPercentage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPPercentage as text
%        str2double(get(hObject,'String')) returns contents of SPPercentage as a double


% --- Executes during object creation, after setting all properties.
function SPPercentage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPPercentage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SPBaseline.
function SPBaseline_Callback(hObject, eventdata, handles)
% hObject    handle to SPBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SPBaseline
