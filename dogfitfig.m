function varargout = dogfitfig(varargin)
% DOGFITFIG Application M-file for dogfitfig.fig
%    FIG = DOGFITFIG launch dogfitfig GUI.
%    DOGFITFIG('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 06-Sep-2011 11:55:48

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
function varargout = ConstrainBox_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.checkbox1.
if get(gcbo,'Value')==1;
    set(handles.bound,'Enable','on');
else
    set(handles.bound,'Enable','off');    
end


% --------------------------------------------------------------------
function varargout = ImportButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.ImportButton.
dogfit('Import')

% --------------------------------------------------------------------
function varargout = LoadButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.LoadButton.
dogfit('Load Data')

% --------------------------------------------------------------------
function varargout = DFDisplayMenu_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.DFDisplayMenu.

% --------------------------------------------------------------------
function varargout = DFSmooth_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.DFSmooth.
if get(handles.DFSmooth,'Value')==1
    set(handles.DFSmoothMenu,'Enable','on')
else
    set(handles.DFSmoothMenu,'Enable','off')
end

% --------------------------------------------------------------------
function varargout = Surround_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.Surround.

% --------------------------------------------------------------------
function varargout = LargeScale_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.LargeScale.


% --------------------------------------------------------------------
function varargout = caedit_Callback(h, eventdata, handles, varargin)
dogfit('RePlot')

% --------------------------------------------------------------------
function varargout = csedit_Callback(h, eventdata, handles, varargin)
dogfit('RePlot')

% --------------------------------------------------------------------
function varargout = saedit_Callback(h, eventdata, handles, varargin)
dogfit('RePlot')

% --------------------------------------------------------------------
function varargout = ssedit_Callback(h, eventdata, handles, varargin)
dogfit('RePlot')

% --------------------------------------------------------------------
function varargout = dcedit_Callback(h, eventdata, handles, varargin)
dogfit('RePlot')

% --------------------------------------------------------------------
function varargout = sedit_Callback(h, eventdata, handles, varargin)
dogfit('RePlot')

% --------------------------------------------------------------------
function varargout = SaveButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.SaveButton.
dogfit('Save Data')

% --------------------------------------------------------------------
function varargout = FitItButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.FitItButton.
dogfit('FitIt')

% --------------------------------------------------------------------
function varargout = ExitButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.ExitButton.
close(gcf);

% --------------------------------------------------------------------
function varargout = DFSmoothMenu_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.DFSmoothMenu.

% --------------------------------------------------------------------
function varargout = SpawnButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.SpawnButton.
dogfit('Spawn')

% --------------------------------------------------------------------
function varargout = InfoText_ButtondownFcn(h, eventdata, handles, varargin)
% Stub for ButtondownFcn of the uicontrol handles.InfoText.
dogfit('Save Text')

% --------------------------------------------------------------------
function varargout = InfoText_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.InfoText.
dogfit('Save Text')

% --------------------------------------------------------------------
function varargout = ub1_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = ub2_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = ub3_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = ub4_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = ubdc_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = ubs_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = lb1_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = lb2_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = lb3_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = lb4_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = lbdc_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = lbs_Callback(h, eventdata, handles, varargin)


% --- Executes on button press in DFUseNLinFit.
function DFUseNLinFit_Callback(hObject, eventdata, handles)
% hObject    handle to DFUseNLinFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DFUseNLinFit


% --- Executes on button press in DFUsenlinfit.
function DFUsenlinfit_Callback(hObject, eventdata, handles)
% hObject    handle to DFUsenlinfit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DFUsenlinfit



function DFSmoothNumber_Callback(hObject, eventdata, handles)
% hObject    handle to DFSmoothNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DFSmoothNumber as text
%        str2double(get(hObject,'String')) returns contents of DFSmoothNumber as a double


% --- Executes during object creation, after setting all properties.
function DFSmoothNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DFSmoothNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in DFUseROG.
function DFUseROG_Callback(hObject, eventdata, handles)
% hObject    handle to DFUseROG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DFUseROG
v = get(hObject,'Value');
if v == 1
	set(handles.DFUseCHF,'Value',0)
end

% --- Executes on button press in DFUseCHF.
function DFUseCHF_Callback(hObject, eventdata, handles)
% hObject    handle to DFUseCHF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DFUseCHF
v = get(hObject,'Value');
if v == 1
	set(handles.DFUseROG,'Value',0)
end
