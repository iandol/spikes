function varargout = opro_UI(varargin)
% OPRO_UI Application M-file for opro_UI.fig
%    FIG = OPRO_UI launch opro_UI GUI.
%    OPRO_UI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 12-May-2013 17:06:13

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
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		s=lasterror;
		disp(s.message);
		for i=1:length(s.stack)
			disp(s.stack(i));
		end
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
function varargout = ExitButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.ExitButton.
opro('Exit')

% --------------------------------------------------------------------
function varargout = OrbanizeIt_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.OrbanizeIt.
opro('OrbanizeIt')

% --------------------------------------------------------------------
function varargout = SpawnButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.SpawnButton.
opro('Spawn');

% --------------------------------------------------------------------
function varargout = MeasureButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.MeasureButton.
opro('Measure');

% --------------------------------------------------------------------
function varargout = LoadButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.LoadButton.
opro('Load');

% --------------------------------------------------------------------
function varargout = StatsText_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.StatsText.
opro('Save Text')

% --------------------------------------------------------------------
function varargout = StatsText_ButtondownFcn(h, eventdata, handles, varargin)
% Stub for ButtondownFcn of the uicontrol handles.StatsText.
opro('Save Text')

% --------------------------------------------------------------------
function varargout = BurstBox_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.BurstBox.

% --------------------------------------------------------------------
function varargout = NormaliseMenu_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.NormaliseMenu.

opro('Normalise')

% --------------------------------------------------------------------
function varargout = SP1Edit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.SP1Edit.

% --------------------------------------------------------------------
function varargout = SP2Edit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.SP2Edit.

% --------------------------------------------------------------------
function varargout = Pushbutton2_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.Pushbutton2.
opro('Spontaneous')

% --------------------------------------------------------------------
function varargout = ThresholdBox_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.ThresholdBox.

% --------------------------------------------------------------------
function varargout = AlphaEdit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.AlphaEdit.

% --------------------------------------------------------------------
function varargout = OPStatsMenu_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.OPStatsMenu.

% --------------------------------------------------------------------
function varargout = OPPlotMenu_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.OPPlotMenu.

% --------------------------------------------------------------------
function varargout = LogBox_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.LogBox.

% --------------------------------------------------------------------
function varargout = CentredBox_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.CentredBox.

% --------------------------------------------------------------------
function varargout = HelpButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.HelpButton.
vshelp('OPro')

% --------------------------------------------------------------------
function varargout = CellSelectMenu_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.CellSelectMenu.


% --------------------------------------------------------------------
function varargout = MatrixBox_Callback(h, eventdata, handles, varargin)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function OPNBootstraps_Callback(hObject, eventdata, handles)
% hObject    handle to OPNBootstraps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OPNBootstraps as text
%        str2double(get(hObject,'String')) returns contents of OPNBootstraps as a double


% --- Executes during object creation, after setting all properties.
function OPNBootstraps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OPNBootstraps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in OPMeasureMenu.
function OPMeasureMenu_Callback(hObject, eventdata, handles)
% hObject    handle to OPMeasureMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns OPMeasureMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OPMeasureMenu


% --- Executes during object creation, after setting all properties.
function OPMeasureMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OPMeasureMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OPBootstrapFun.
function OPBootstrapFun_Callback(hObject, eventdata, handles)
% hObject    handle to OPBootstrapFun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns OPBootstrapFun contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OPBootstrapFun


% --- Executes during object creation, after setting all properties.
function OPBootstrapFun_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OPBootstrapFun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OpShowPlots.
function OpShowPlots_Callback(hObject, eventdata, handles)
% hObject    handle to OpShowPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OpShowPlots


% --- Executes on button press in OPShowPlots.
function OPShowPlots_Callback(hObject, eventdata, handles)
% hObject    handle to OPShowPlots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OPShowPlots


% --- Executes on button press in OPAutoMeasure.
function OPAutoMeasure_Callback(hObject, eventdata, handles)
% hObject    handle to OPAutoMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OPAutoMeasure




% --- Executes on button press in OReparseVars.
function OReparseVars_Callback(hObject, eventdata, handles)
% hObject    handle to OReparseVars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
opro('Reparse')



function OPWindow_Callback(hObject, eventdata, handles)
% hObject    handle to OPWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OPWindow as text
%        str2double(get(hObject,'String')) returns contents of OPWindow as a double


function OPShift_Callback(hObject, eventdata, handles)
% hObject    handle to OPShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OPShift as text
%        str2double(get(hObject,'String')) returns contents of OPShift as a double



% --- Executes on selection change in OPHoldZ.
function OPHoldZ_Callback(hObject, eventdata, handles)
% hObject    handle to OPHoldZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OPHoldZ contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OPHoldZ


function OPmint_Callback(hObject, eventdata, handles)
% hObject    handle to OPmint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OPmint as text
%        str2double(get(hObject,'String')) returns contents of OPmint as a double



function OPmaxt_Callback(hObject, eventdata, handles)
% hObject    handle to OPmaxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OPmaxt as text
%        str2double(get(hObject,'String')) returns contents of OPmaxt as a double


function OPSigma_Callback(hObject, eventdata, handles)
% hObject    handle to OPSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OPSigma as text
%        str2double(get(hObject,'String')) returns contents of OPSigma as a double

