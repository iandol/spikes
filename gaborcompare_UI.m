function varargout = gaborcompare_UI(varargin)
% GABORCOMPARE_UI M-file for gaborcompare_UI.fig
%      GABORCOMPARE_UI, by itself, creates a new GABORCOMPARE_UI or raises the existing
%      singleton*.
%
%      H = GABORCOMPARE_UI returns the handle to a new GABORCOMPARE_UI or the handle to
%      the existing singleton*.
%
%      GABORCOMPARE_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GABORCOMPARE_UI.M with the given input arguments.
%
%      GABORCOMPARE_UI('Property','Value',...) creates a new GABORCOMPARE_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gaborcompare_UI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gaborcompare_UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gaborcompare_UI

% Last Modified by GUIDE v2.5 04-May-2006 10:21:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gaborcompare_UI_OpeningFcn, ...
                   'gui_OutputFcn',  @gaborcompare_UI_OutputFcn, ...
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


% --- Executes just before gaborcompare_UI is made visible.
function gaborcompare_UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gaborcompare_UI (see VARARGIN)

% Choose default command line output for gaborcompare_UI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gaborcompare_UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gaborcompare_UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function GCxmin_Callback(hObject, eventdata, handles)
% hObject    handle to GCxmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCxmin as text
%        str2double(get(hObject,'String')) returns contents of GCxmin as a double
gaborcompare('RePlot');

% --- Executes during object creation, after setting all properties.
function GCxmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCxmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCxmax_Callback(hObject, eventdata, handles)
% hObject    handle to GCxmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCxmax as text
%        str2double(get(hObject,'String')) returns contents of GCxmax as a double
gaborcompare('RePlot');

% --- Executes during object creation, after setting all properties.
function GCxmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCxmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCymin_Callback(hObject, eventdata, handles)
% hObject    handle to GCymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCymin as text
%        str2double(get(hObject,'String')) returns contents of GCymin as a double
gaborcompare('RePlot');

% --- Executes during object creation, after setting all properties.
function GCymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCymax_Callback(hObject, eventdata, handles)
% hObject    handle to GCymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCymax as text
%        str2double(get(hObject,'String')) returns contents of GCymax as a double
gaborcompare('RePlot');

% --- Executes during object creation, after setting all properties.
function GCymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCstep_Callback(hObject, eventdata, handles)
% hObject    handle to GCstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCstep as text
%        str2double(get(hObject,'String')) returns contents of GCstep as a double
gaborcompare('RePlot');

% --- Executes during object creation, after setting all properties.
function GCstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCxpos_Callback(hObject, eventdata, handles)
% hObject    handle to GCxpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCxpos as text
%        str2double(get(hObject,'String')) returns contents of GCxpos as a double
gaborcompare('RePlot Gauss');

% --- Executes during object creation, after setting all properties.
function GCxpos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCxpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCypos_Callback(hObject, eventdata, handles)
% hObject    handle to GCypos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCypos as text
%        str2double(get(hObject,'String')) returns contents of GCypos as a double
gaborcompare('RePlot Gauss');

% --- Executes during object creation, after setting all properties.
function GCypos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCypos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCwidth_Callback(hObject, eventdata, handles)
% hObject    handle to GCwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCwidth as text
%        str2double(get(hObject,'String')) returns contents of GCwidth as a double
gaborcompare('RePlot Gauss');

% --- Executes during object creation, after setting all properties.
function GCwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCsigma1_Callback(hObject, eventdata, handles)
% hObject    handle to GCsigma1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCsigma1 as text
%        str2double(get(hObject,'String')) returns contents of GCsigma1 as a double
gaborcompare('RePlot Gabor');

% --- Executes during object creation, after setting all properties.
function GCsigma1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCsigma1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCsigma2_Callback(hObject, eventdata, handles)
% hObject    handle to GCsigma2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCsigma2 as text
%        str2double(get(hObject,'String')) returns contents of GCsigma2 as a double
gaborcompare('RePlot Gabor');

% --- Executes during object creation, after setting all properties.
function GCsigma2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCsigma2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCtheta_Callback(hObject, eventdata, handles)
% hObject    handle to GCtheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCtheta as text
%        str2double(get(hObject,'String')) returns contents of GCtheta as a double
gaborcompare('RePlot Gabor');

% --- Executes during object creation, after setting all properties.
function GCtheta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCtheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GClambda_Callback(hObject, eventdata, handles)
% hObject    handle to GClambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GClambda as text
%        str2double(get(hObject,'String')) returns contents of GClambda as a double
gaborcompare('RePlot Gabor');

% --- Executes during object creation, after setting all properties.
function GClambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GClambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCphase_Callback(hObject, eventdata, handles)
% hObject    handle to GCphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCphase as text
%        str2double(get(hObject,'String')) returns contents of GCphase as a double
gaborcompare('RePlot Gabor');

% --- Executes during object creation, after setting all properties.
function GCphase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCxoff_Callback(hObject, eventdata, handles)
% hObject    handle to GCxoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCxoff as text
%        str2double(get(hObject,'String')) returns contents of GCxoff as a double
gaborcompare('RePlot Gabor');

% --- Executes during object creation, after setting all properties.
function GCxoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCxoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GCyoff_Callback(hObject, eventdata, handles)
% hObject    handle to GCyoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCyoff as text
%        str2double(get(hObject,'String')) returns contents of GCyoff as a double
gaborcompare('RePlot Gabor');

% --- Executes during object creation, after setting all properties.
function GCyoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCyoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in GCSpawn.
function GCSpawn_Callback(hObject, eventdata, handles)
% hObject    handle to GCSpawn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborcompare('Spawn');

% --- Executes on button press in GCExit.
function GCExit_Callback(hObject, eventdata, handles)
% hObject    handle to GCExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);

function GCoutputtext_Callback(hObject, eventdata, handles)
% hObject    handle to GCoutputtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCoutputtext as text
%        str2double(get(hObject,'String')) returns contents of GCoutputtext as a double


% --- Executes during object creation, after setting all properties.
function GCoutputtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCoutputtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GCstoredp.
function GCstoredp_Callback(hObject, eventdata, handles)
% hObject    handle to GCstoredp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborcompare('StoreDP');

% --- Executes on button press in GCresetdp.
function GCresetdp_Callback(hObject, eventdata, handles)
% hObject    handle to GCresetdp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborcompare('ResetDP');


function GCcutoff_Callback(hObject, eventdata, handles)
% hObject    handle to GCcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCcutoff as text
%        str2double(get(hObject,'String')) returns contents of GCcutoff as a double
gaborcompare('RePlot Output');

% --- Executes during object creation, after setting all properties.
function GCcutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in GChistory.
function GChistory_Callback(hObject, eventdata, handles)
% hObject    handle to GChistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns GChistory contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GChistory


% --- Executes during object creation, after setting all properties.
function GChistory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GChistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GCsethistory.
function GCsethistory_Callback(hObject, eventdata, handles)
% hObject    handle to GCsethistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborcompare('StoreIt');



% --- Executes on button press in GCresetaxis.
function GCresetaxis_Callback(hObject, eventdata, handles)
% hObject    handle to GCresetaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
view(2);

% --- Executes on button press in GCrotate.
function GCrotate_Callback(hObject, eventdata, handles)
% hObject    handle to GCrotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotate3d;

% --- Executes on button press in GCcopyview1.
function GCcopyview1_Callback(hObject, eventdata, handles)
% hObject    handle to GCcopyview1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=[];
axes(gh('GCAxis1'));
s=view;
axes(gh('GCAxis2'));
view(s);

% --- Executes on button press in GCcopyview2.
function GCcopyview2_Callback(hObject, eventdata, handles)
% hObject    handle to GCcopyview2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=view(gh('GCAxis2'));
view(gh('GCAxis1'),s);

function GCcirclemultiply_Callback(hObject, eventdata, handles)
% hObject    handle to GCcirclemultiply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCcirclemultiply as text
%        str2double(get(hObject,'String')) returns contents of GCcirclemultiply as a double
gaborcompare('RePlot Output');

% --- Executes during object creation, after setting all properties.
function GCcirclemultiply_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCcirclemultiply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in GCLoad.
function GCLoad_Callback(hObject, eventdata, handles)
% hObject    handle to GCLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborcompare('Load Data');

% --- Executes on button press in GCSave.
function GCSave_Callback(hObject, eventdata, handles)
% hObject    handle to GCSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborcompare('Save Data');



% --- Executes on button press in GCcolormapeditor.
function GCcolormapeditor_Callback(hObject, eventdata, handles)
% hObject    handle to GCcolormapeditor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colormapeditor;


% --- Executes on button press in GCcirclecheck.
function GCcirclecheck_Callback(hObject, eventdata, handles)
% hObject    handle to GCcirclecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GCcirclecheck
gaborcompare('RePlot Output');

function GCplateau_Callback(hObject, eventdata, handles)
% hObject    handle to GCplateau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of GCplateau as text
%        str2double(get(hObject,'String')) returns contents of GCplateau as a double
gaborcompare('RePlot Output');


% --- Executes during object creation, after setting all properties.
function GCplateau_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCplateau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in GCgradated.
function GCgradated_Callback(hObject, eventdata, handles)
% hObject    handle to GCgradated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GCgradated
gaborcompare('RePlot Output');

% --- Executes on button press in GCplateauoverride.
function GCplateauoverride_Callback(hObject, eventdata, handles)
% hObject    handle to GCplateauoverride (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GCplateauoverride
gaborcompare('RePlot Output');

% --- Executes on button press in GCgausscutoff.
function GCgausscutoff_Callback(hObject, eventdata, handles)
% hObject    handle to GCgausscutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GCgausscutoff
gaborcompare('RePlot Gauss');

% --- Executes on button press in GCgaussinvert.
function GCgaussinvert_Callback(hObject, eventdata, handles)
% hObject    handle to GCgaussinvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GCgaussinvert


% --- Executes on button press in GCgaussspawn.
function GCgaussspawn_Callback(hObject, eventdata, handles)
% hObject    handle to GCgaussspawn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborcompare('Spawn Gaussian');



% --- Executes on button press in GCoutputspawn.
function GCoutputspawn_Callback(hObject, eventdata, handles)
% hObject    handle to GCoutputspawn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborcompare('Spawn Output');



% --- Executes on button press in GCcontourplot.
function GCcontourplot_Callback(hObject, eventdata, handles)
% hObject    handle to GCcontourplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GCcontourplot
gaborcompare('RePlot');

function GCcontournumber_Callback(hObject, eventdata, handles)
% hObject    handle to GCcontournumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCcontournumber as text
%        str2double(get(hObject,'String')) returns contents of GCcontournumber as a double
gaborcompare('RePlot');

% --- Executes during object creation, after setting all properties.
function GCcontournumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCcontournumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function GCspont_Callback(hObject, eventdata, handles)
% hObject    handle to GCspont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GCspont as text
%        str2double(get(hObject,'String')) returns contents of GCspont as a double
gaborcompare('RePlot Gauss');

% --- Executes during object creation, after setting all properties.
function GCspont_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GCspont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GCgaborzero.
function GCgaborzero_Callback(hObject, eventdata, handles)
% hObject    handle to GCgaborzero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GCgaborzero


