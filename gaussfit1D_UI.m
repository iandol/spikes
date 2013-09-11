function varargout = gaussfit1D_UI(varargin)
% GAUSSFIG Application M-file for gaussfig.fig
%    FIG = GAUSSFIG launch gaussfig GUI.
%    GAUSSFIG('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 11-Sep-2013 18:53:50

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
	%set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

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
function varargout = H1Edit_Callback(h, eventdata, handles, varargin)

gaussfit1D('HPlot');

% --------------------------------------------------------------------
function varargout = V1Edit_Callback(h, eventdata, handles, varargin)

gaussfit1D('VPlot');


% --------------------------------------------------------------------
function varargout = D11Edit_Callback(h, eventdata, handles, varargin)

gaussfit1D('D1Plot');


% --------------------------------------------------------------------
function varargout = D21Edit_Callback(h, eventdata, handles, varargin)

gaussfit1D('D2Plot');



% --------------------------------------------------------------------
function varargout = HButton_Callback(h, eventdata, handles, varargin)

gaussfit1D('HFit');

% --------------------------------------------------------------------
function varargout = VButton_Callback(h, eventdata, handles, varargin)

gaussfit1D('VFit');

% --------------------------------------------------------------------
function varargout = D1Button_Callback(h, eventdata, handles, varargin)

gaussfit1D('D1Fit');

% --------------------------------------------------------------------
function varargout = D2Button_Callback(h, eventdata, handles, varargin)

gaussfit1D('D2Fit');


% --------------------------------------------------------------------
function varargout = HText_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = VText_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = D1Text_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = D2Text_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = LockPBox_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = LockMenu_Callback(h, eventdata, handles, varargin)



function D22Edit_Callback(hObject, eventdata, handles)
% hObject    handle to D22Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D22Edit as text
%        str2double(get(hObject,'String')) returns contents of D22Edit as a double
gaussfit1D('D2Plot');


function D23Edit_Callback(hObject, eventdata, handles)
% hObject    handle to D23Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D23Edit as text
%        str2double(get(hObject,'String')) returns contents of D23Edit as a double
gaussfit1D('D2Plot');


function D24Edit_Callback(hObject, eventdata, handles)
% hObject    handle to D24Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D24Edit as text
%        str2double(get(hObject,'String')) returns contents of D24Edit as a double
gaussfit1D('D2Plot');


function D21Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to D21Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D21Edit2 as text
%        str2double(get(hObject,'String')) returns contents of D21Edit2 as a double
gaussfit1D('D2Plot');


function D22Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to D22Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D22Edit2 as text
%        str2double(get(hObject,'String')) returns contents of D22Edit2 as a double
gaussfit1D('D2Plot');


function D23Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to D23Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D23Edit2 as text
%        str2double(get(hObject,'String')) returns contents of D23Edit2 as a double
gaussfit1D('D2Plot');


function D24Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to D24Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D24Edit2 as text
%        str2double(get(hObject,'String')) returns contents of D24Edit2 as a double
gaussfit1D('D2Plot');



function V2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to V2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of V2Edit as text
%        str2double(get(hObject,'String')) returns contents of V2Edit as a double
gaussfit1D('VPlot');


function V3Edit_Callback(hObject, eventdata, handles)
% hObject    handle to V3Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of V3Edit as text
%        str2double(get(hObject,'String')) returns contents of V3Edit as a double

gaussfit1D('VPlot');

function V4Edit_Callback(hObject, eventdata, handles)
% hObject    handle to V4Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of V4Edit as text
%        str2double(get(hObject,'String')) returns contents of V4Edit as a double
gaussfit1D('VPlot');


function V1Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to V1Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of V1Edit2 as text
%        str2double(get(hObject,'String')) returns contents of V1Edit2 as a double
gaussfit1D('VPlot');


function V2Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to V2Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of V2Edit2 as text
%        str2double(get(hObject,'String')) returns contents of V2Edit2 as a double
gaussfit1D('VPlot');


function V3Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to V3Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of V3Edit2 as text
%        str2double(get(hObject,'String')) returns contents of V3Edit2 as a double

gaussfit1D('VPlot');

function V4Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to V4Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of V4Edit2 as text
%        str2double(get(hObject,'String')) returns contents of V4Edit2 as a double
gaussfit1D('VPlot');



function H2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to H2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of H2Edit as text
%        str2double(get(hObject,'String')) returns contents of H2Edit as a double
gaussfit1D('HPlot');


function H3Edit_Callback(hObject, eventdata, handles)
% hObject    handle to H3Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of H3Edit as text
%        str2double(get(hObject,'String')) returns contents of H3Edit as a double



function H4Edit_Callback(hObject, eventdata, handles)
% hObject    handle to H4Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of H4Edit as text
%        str2double(get(hObject,'String')) returns contents of H4Edit as a double
gaussfit1D('HPlot');


function H1Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to H1Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of H1Edit2 as text
%        str2double(get(hObject,'String')) returns contents of H1Edit2 as a double
gaussfit1D('HPlot');


function H2Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to H2Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of H2Edit2 as text
%        str2double(get(hObject,'String')) returns contents of H2Edit2 as a double
gaussfit1D('HPlot');


function H3Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to H3Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of H3Edit2 as text
%        str2double(get(hObject,'String')) returns contents of H3Edit2 as a double
gaussfit1D('HPlot');


function H4Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to H4Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of H4Edit2 as text
%        str2double(get(hObject,'String')) returns contents of H4Edit2 as a double
gaussfit1D('HPlot');



function D12Edit_Callback(hObject, eventdata, handles)
% hObject    handle to D12Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D12Edit as text
%        str2double(get(hObject,'String')) returns contents of D12Edit as a double
gaussfit1D('D1Plot');


function D13Edit_Callback(hObject, eventdata, handles)
% hObject    handle to D13Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D13Edit as text
%        str2double(get(hObject,'String')) returns contents of D13Edit as a double
gaussfit1D('D1Plot');


function D14Edit_Callback(hObject, eventdata, handles)
% hObject    handle to D14Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D14Edit as text
%        str2double(get(hObject,'String')) returns contents of D14Edit as a double
gaussfit1D('D1Plot');


function D11Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to D11Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D11Edit2 as text
%        str2double(get(hObject,'String')) returns contents of D11Edit2 as a double
gaussfit1D('D1Plot');


function D12Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to D12Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D12Edit2 as text
%        str2double(get(hObject,'String')) returns contents of D12Edit2 as a double
gaussfit1D('D1Plot');


function D13Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to D13Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D13Edit2 as text
%        str2double(get(hObject,'String')) returns contents of D13Edit2 as a double
gaussfit1D('D1Plot');


function D14Edit2_Callback(hObject, eventdata, handles)
% hObject    handle to D14Edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of D14Edit2 as text
%        str2double(get(hObject,'String')) returns contents of D14Edit2 as a double
gaussfit1D('D1Plot');


% --- Executes on button press in GF1Spawn.
function GF1Spawn_Callback(hObject, eventdata, handles)
% hObject    handle to GF1Spawn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaussfit1D('Spawn');