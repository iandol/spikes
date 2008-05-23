function varargout = crosscorfig(varargin)
% CROSSCORFIG Application M-file for crosscorfig.fig
%    FIG = CROSSCORFIG launch crosscorfig GUI.
%    CROSSCORFIG('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 28-Nov-2006 20:46:45

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
function varargout = XCorRaw_ResizeFcn(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = CCPolyBox_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = CCIntBox_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = CCExport_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = CCLoadX_Callback(h, eventdata, handles, varargin)
crosscor('Load');


% --------------------------------------------------------------------
function varargout = CCBinWidth_Callback(h, eventdata, handles, varargin)
global xv
xv.BinWidth=str2num(get(h,'string'));


% --------------------------------------------------------------------
function varargout = CCWindow_Callback(h, eventdata, handles, varargin)
global xv
xv.Window=str2num(get(h,'string'));


% --------------------------------------------------------------------
function varargout = CCFromTime_Callback(h, eventdata, handles, varargin)
global xv
xv.FromTime=str2num(get(h,'string'));

% --------------------------------------------------------------------
function varargout = CCToTime_Callback(h, eventdata, handles, varargin)
global xv
xv.ToTime=str2num(get(h,'string'));


% --------------------------------------------------------------------
function varargout = CCStartTrial_Callback(h, eventdata, handles, varargin)
global xv
xv.StartTrial=str2num(get(h,'string'));
set(gh('ShuffleNumber'),'value',1); %so no illegal value is used when contents change
set(gh('ShuffleNumber'),'String',nums2strs(1:(xv.EndTrial-xv.StartTrial)));
set(gh('ShuffleNumber'),'value',xv.EndTrial-xv.StartTrial);

% --------------------------------------------------------------------
function varargout = CCEndTrial_Callback(h, eventdata, handles, varargin)
global xv
xv.EndTrial=str2num(get(h,'string'));
set(gh('ShuffleNumber'),'value',1); %so no illegal value is used when contents change
set(gh('ShuffleNumber'),'String',nums2strs(1:(xv.EndTrial-xv.StartTrial)));
set(gh('ShuffleNumber'),'value',xv.EndTrial-xv.StartTrial);

% --------------------------------------------------------------------
function varargout = Shuffle_Callback(h, eventdata, handles, varargin)
if (get(h,'Value')>1)
    set(findobj('tag','ShuffleNumber'),'Enable','on')
    set(findobj('tag','ShufflePValue'),'Enable','on')
else
    set(findobj('tag','ShuffleNumber'),'Enable','off')
    set(findobj('tag','ShufflePValue'),'Enable','off')
end

% --------------------------------------------------------------------
function varargout = ShuffleNumber_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = ShufflePValue_Callback(h, eventdata, handles, varargin)
global xv
if ~isempty(str2num(get(h,'string')))
    if (str2num(get(h,'string'))>0 & str2num(get(h,'string'))<1)
        xv.pValue=str2num(get(h,'string'));
    else
        set(h,'string',num2str(xv.pValue));
    end
end

% --------------------------------------------------------------------
function varargout = CCFirstCell_Callback(h, eventdata, handles, varargin)
global xv
xv.firstunit=get(h,'Value');

% --------------------------------------------------------------------
function varargout = CCSecondCell_Callback(h, eventdata, handles, varargin)
global xv
xv.secondunit=get(h,'Value');

% --------------------------------------------------------------------
function varargout = CCAnalMenu_Callback(h, eventdata, handles, varargin)
v=get(h,'Value');
s=get(h,'String');
crosscor(s{v});

% --------------------------------------------------------------------
function varargout = CCExitButton_Callback(h, eventdata, handles, varargin)
clear xdata xv; 
close;

% --------------------------------------------------------------------
function varargout = CCStartBin_Callback(h, eventdata, handles, varargin)
global xv; 
xv.StartBin=get(h,'Value');

% --------------------------------------------------------------------
function varargout = CCEndBin_Callback(h, eventdata, handles, varargin)
global xv; 
xv.EndBin=get(h,'Value');

% --------------------------------------------------------------------
function varargout = RatioValue_Callback(h, eventdata, handles, varargin)

% --- Executes on button press in CCSaveModel.
function CCSaveModel_Callback(hObject, eventdata, handles)
% hObject    handle to CCSaveModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Converts array of numbers to a cell array of strings   
function [cellout]=nums2strs(arrayin)
	for n=1:length(arrayin)
      cellout{n}=num2str(arrayin(n));
   end
%End of function

%GH Gets Handle From Tag
function [handle] = gh(tag)
handle=findobj('Tag',tag);
%End of handle getting routine


% --- Executes during object creation, after setting all properties.
function ZAxisEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZAxisEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ZAxisEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ZAxisEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ZAxisEdit as text
%        str2double(get(hObject,'String')) returns contents of ZAxisEdit as a double


% --- Executes on button press in AxisBox.
function AxisBox_Callback(hObject, eventdata, handles)
% hObject    handle to AxisBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AxisBox


% --- Executes on button press in ZAxisBox3.
function ZAxisBox3_Callback(hObject, eventdata, handles)
% hObject    handle to ZAxisBox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ZAxisBox3


% --- Executes on selection change in TypeMenu.
function TypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to TypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns TypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TypeMenu


% --- Executes on selection change in CCHold1.
function CCHold1_Callback(hObject, eventdata, handles)
% hObject    handle to CCHold1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns CCHold1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CCHold1


% --- Executes during object creation, after setting all properties.
function CCHold1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CCHold1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CCHold2.
function CCHold2_Callback(hObject, eventdata, handles)
% hObject    handle to CCHold2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns CCHold2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CCHold2


% --- Executes during object creation, after setting all properties.
function CCHold2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CCHold2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CCWrapPSTH.
function CCWrapPSTH_Callback(hObject, eventdata, handles)
% hObject    handle to CCWrapPSTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CCWrapPSTH


% --- Executes on selection change in SmoothingMenu.
function SmoothingMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothingMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SmoothingMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SmoothingMenu
global SmoothType; 
contents = get(hObject,'String');
SmoothType=contents{get(hObject,'Value')};



function CCGauss1_Callback(hObject, eventdata, handles)
% hObject    handle to CCGauss1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CCGauss1 as text
%        str2double(get(hObject,'String')) returns contents of CCGauss1 as a double


% --- Executes during object creation, after setting all properties.
function CCGauss1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CCGauss1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CCGauss2_Callback(hObject, eventdata, handles)
% hObject    handle to CCGauss2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CCGauss2 as text
%        str2double(get(hObject,'String')) returns contents of CCGauss2 as a double


% --- Executes during object creation, after setting all properties.
function CCGauss2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CCGauss2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CCGauss3_Callback(hObject, eventdata, handles)
% hObject    handle to CCGauss3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CCGauss3 as text
%        str2double(get(hObject,'String')) returns contents of CCGauss3 as a double


% --- Executes during object creation, after setting all properties.
function CCGauss3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CCGauss3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CCGauss4_Callback(hObject, eventdata, handles)
% hObject    handle to CCGauss4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CCGauss4 as text
%        str2double(get(hObject,'String')) returns contents of CCGauss4 as a double


% --- Executes during object creation, after setting all properties.
function CCGauss4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CCGauss4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CCGauss3Lock.
function CCGauss3Lock_Callback(hObject, eventdata, handles)
% hObject    handle to CCGauss3Lock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CCGauss3Lock


