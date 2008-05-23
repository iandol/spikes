function varargout = gaussfit2D_UI(varargin)
% GAUSSFIT2D_UI Application M-file for gaussfit2D_UI.fig
%    FIG = GAUSSFIT2D_UI launch gaussfit2D_UI GUI.
%    GAUSSFIT2D_UI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 14-Jun-2007 11:59:19

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
function varargout = C1Edit_Callback(h, eventdata, handles, varargin)

gaussfit2D('CPlot');


% --------------------------------------------------------------------
function varargout = C2Edit_Callback(h, eventdata, handles, varargin)

gaussfit2D('CPlot');


% --------------------------------------------------------------------
function varargout = C3Edit_Callback(h, eventdata, handles, varargin)

gaussfit2D('CPlot');


% --------------------------------------------------------------------
function varargout = C4Edit_Callback(h, eventdata, handles, varargin)

gaussfit2D('CPlot');


% --------------------------------------------------------------------
function varargout = C5Edit_Callback(h, eventdata, handles, varargin)

gaussfit2D('CPlot');


% --------------------------------------------------------------------
function varargout = D1Edit_Callback(h, eventdata, handles, varargin)

gaussfit2D('DPlot');


% --------------------------------------------------------------------
function varargout = D2Edit_Callback(h, eventdata, handles, varargin)

gaussfit2D('DPlot');


% --------------------------------------------------------------------
function varargout = D3Edit_Callback(h, eventdata, handles, varargin)

gaussfit2D('DPlot');


% --------------------------------------------------------------------
function varargout = D4Edit_Callback(h, eventdata, handles, varargin)

gaussfit2D('DPlot');


% --------------------------------------------------------------------
function varargout = D5Edit_Callback(h, eventdata, handles, varargin)

gaussfit2D('DPlot');


% --------------------------------------------------------------------
function varargout = CButton_Callback(h, eventdata, handles, varargin)

gaussfit2D('CFit');


% --------------------------------------------------------------------
function varargout = DButton_Callback(h, eventdata, handles, varargin)

gaussfit2D('DFit');


% --------------------------------------------------------------------
function varargout = CEdit_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = DEdit_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = REdit_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = LockBox_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = NormaliseBox_Callback(h, eventdata, handles, varargin)

gaussfit2D('Normalise');


% --------------------------------------------------------------------
function varargout = InvertBox_Callback(h, eventdata, handles, varargin)

gaussfit2D('Invert');



function GVectorText_Callback(hObject, eventdata, handles)
% hObject    handle to GVectorText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GVectorText as text
%        str2double(get(hObject,'String')) returns contents of GVectorText as a double


% --- Executes during object creation, after setting all properties.
function GVectorText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GVectorText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in G2TrialFit.
function G2TrialFit_Callback(hObject, eventdata, handles)
% hObject    handle to G2TrialFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gaussfit2D('TestTrials');
SpawnGauss

% --- Executes on selection change in G2BootstrapType.
function G2BootstrapType_Callback(hObject, eventdata, handles)
% hObject    handle to G2BootstrapType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns G2BootstrapType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from G2BootstrapType


% --- Executes during object creation, after setting all properties.
function G2BootstrapType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2BootstrapType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2BootstrapN_Callback(hObject, eventdata, handles)
% hObject    handle to G2BootstrapN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2BootstrapN as text
%        str2double(get(hObject,'String')) returns contents of G2BootstrapN as a double


% --- Executes during object creation, after setting all properties.
function G2BootstrapN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2BootstrapN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2L1_Callback(hObject, eventdata, handles)
% hObject    handle to G2L1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2L1 as text
%        str2double(get(hObject,'String')) returns contents of G2L1 as a double


% --- Executes during object creation, after setting all properties.
function G2L1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2L1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2L2_Callback(hObject, eventdata, handles)
% hObject    handle to G2L2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2L2 as text
%        str2double(get(hObject,'String')) returns contents of G2L2 as a double


% --- Executes during object creation, after setting all properties.
function G2L2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2L2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2L3_Callback(hObject, eventdata, handles)
% hObject    handle to G2L3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2L3 as text
%        str2double(get(hObject,'String')) returns contents of G2L3 as a double


% --- Executes during object creation, after setting all properties.
function G2L3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2L3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2L4_Callback(hObject, eventdata, handles)
% hObject    handle to G2L4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2L4 as text
%        str2double(get(hObject,'String')) returns contents of G2L4 as a double


% --- Executes during object creation, after setting all properties.
function G2L4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2L4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2L5_Callback(hObject, eventdata, handles)
% hObject    handle to G2L5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2L5 as text
%        str2double(get(hObject,'String')) returns contents of G2L5 as a double


% --- Executes during object creation, after setting all properties.
function G2L5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2L5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2U1_Callback(hObject, eventdata, handles)
% hObject    handle to G2U1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2U1 as text
%        str2double(get(hObject,'String')) returns contents of G2U1 as a double


% --- Executes during object creation, after setting all properties.
function G2U1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2U1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2U2_Callback(hObject, eventdata, handles)
% hObject    handle to G2U2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2U2 as text
%        str2double(get(hObject,'String')) returns contents of G2U2 as a double


% --- Executes during object creation, after setting all properties.
function G2U2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2U2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2U3_Callback(hObject, eventdata, handles)
% hObject    handle to G2U3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2U3 as text
%        str2double(get(hObject,'String')) returns contents of G2U3 as a double


% --- Executes during object creation, after setting all properties.
function G2U3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2U3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2U4_Callback(hObject, eventdata, handles)
% hObject    handle to G2U4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2U4 as text
%        str2double(get(hObject,'String')) returns contents of G2U4 as a double


% --- Executes during object creation, after setting all properties.
function G2U4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2U4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2U5_Callback(hObject, eventdata, handles)
% hObject    handle to G2U5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2U5 as text
%        str2double(get(hObject,'String')) returns contents of G2U5 as a double


% --- Executes during object creation, after setting all properties.
function G2U5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2U5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2XLim_Callback(hObject, eventdata, handles)
% hObject    handle to G2XLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2XLim as text
%        str2double(get(hObject,'String')) returns contents of G2XLim as a double


% --- Executes during object creation, after setting all properties.
function G2XLim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2XLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2YLim_Callback(hObject, eventdata, handles)
% hObject    handle to G2YLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2YLim as text
%        str2double(get(hObject,'String')) returns contents of G2YLim as a double


% --- Executes during object creation, after setting all properties.
function G2YLim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2YLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2IgnoreTrials_Callback(hObject, eventdata, handles)
% hObject    handle to G2IgnoreTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2IgnoreTrials as text
%        str2double(get(hObject,'String')) returns contents of G2IgnoreTrials as a double


% --- Executes during object creation, after setting all properties.
function G2IgnoreTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2IgnoreTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2WLim_Callback(hObject, eventdata, handles)
% hObject    handle to G2WLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2WLim as text
%        str2double(get(hObject,'String')) returns contents of G2WLim as a double


% --- Executes during object creation, after setting all properties.
function G2WLim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2WLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2Alpha_Callback(hObject, eventdata, handles)
% hObject    handle to G2Alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2Alpha as text
%        str2double(get(hObject,'String')) returns contents of G2Alpha as a double


% --- Executes during object creation, after setting all properties.
function G2Alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2Alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in G2TrialCell.
function G2TrialCell_Callback(hObject, eventdata, handles)
% hObject    handle to G2TrialCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns G2TrialCell contents as cell array
%        contents{get(hObject,'Value')} returns selected item from G2TrialCell


% --- Executes during object creation, after setting all properties.
function G2TrialCell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2TrialCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in G2AngCut.
function G2AngCut_Callback(hObject, eventdata, handles)
% hObject    handle to G2AngCut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of G2AngCut


% --- Executes on button press in G2ZeroOpt.
function G2ZeroOpt_Callback(hObject, eventdata, handles)
% hObject    handle to G2ZeroOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of G2ZeroOpt



function G2GlobalX_Callback(hObject, eventdata, handles)
% hObject    handle to G2GlobalX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2GlobalX as text
%        str2double(get(hObject,'String')) returns contents of G2GlobalX as a double


% --- Executes during object creation, after setting all properties.
function G2GlobalX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2GlobalX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function G2GlobalY_Callback(hObject, eventdata, handles)
% hObject    handle to G2GlobalY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of G2GlobalY as text
%        str2double(get(hObject,'String')) returns contents of G2GlobalY as a double


% --- Executes during object creation, after setting all properties.
function G2GlobalY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to G2GlobalY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GFAngleCorrect.
function GFAngleCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to GFAngleCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GFAngleCorrect





function GF2XMin1_Callback(hObject, eventdata, handles)
% hObject    handle to GF2XMin1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GF2XMin1 as text
%        str2double(get(hObject,'String')) returns contents of GF2XMin1 as a double


% --- Executes during object creation, after setting all properties.
function GF2XMin1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GF2XMin1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GF2XMax1_Callback(hObject, eventdata, handles)
% hObject    handle to GF2XMax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GF2XMax1 as text
%        str2double(get(hObject,'String')) returns contents of GF2XMax1 as a double


% --- Executes during object creation, after setting all properties.
function GF2XMax1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GF2XMax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GF2YMin2_Callback(hObject, eventdata, handles)
% hObject    handle to GF2YMin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GF2YMin2 as text
%        str2double(get(hObject,'String')) returns contents of GF2YMin2 as a double


% --- Executes during object creation, after setting all properties.
function GF2YMin2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GF2YMin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GF2YMax1_Callback(hObject, eventdata, handles)
% hObject    handle to GF2YMax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GF2YMax1 as text
%        str2double(get(hObject,'String')) returns contents of GF2YMax1 as a double
gaussfit2D('CPlot');

% --- Executes during object creation, after setting all properties.
function GF2YMax1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GF2YMax1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in GF2SpawnLeft.
function GF2SpawnLeft_Callback(hObject, eventdata, handles)
% hObject    handle to GF2SpawnLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaussfit2D('SpawnGaussLeft');

% --- Executes on button press in GF2SpawnRight.
function GF2SpawnRight_Callback(hObject, eventdata, handles)
% hObject    handle to GF2SpawnRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaussfit2D('SpawnGaussRight');



function GF2XMin2_Callback(hObject, eventdata, handles)
% hObject    handle to GF2XMin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GF2XMin2 as text
%        str2double(get(hObject,'String')) returns contents of GF2XMin2 as a double


% --- Executes during object creation, after setting all properties.
function GF2XMin2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GF2XMin2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GF2XMax2_Callback(hObject, eventdata, handles)
% hObject    handle to GF2XMax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GF2XMax2 as text
%        str2double(get(hObject,'String')) returns contents of GF2XMax2 as a double


% --- Executes during object creation, after setting all properties.
function GF2XMax2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GF2XMax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GF2YMax2_Callback(hObject, eventdata, handles)
% hObject    handle to GF2YMax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GF2YMax2 as text
%        str2double(get(hObject,'String')) returns contents of GF2YMax2 as a double
gaussfit2D('DPlot');

% --- Executes during object creation, after setting all properties.
function GF2YMax2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GF2YMax2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


