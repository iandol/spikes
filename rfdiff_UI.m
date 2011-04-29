function varargout = rfdiff_UI(varargin)
% RFDIFF_UI M-file for rfdiff_UI.fig
%      RFDIFF_UI, by itself, creates a new RFDIFF_UI or raises the existing
%      singleton*.
%
%      H = RFDIFF_UI returns the handle to a new RFDIFF_UI or the handle to
%      the existing singleton*.
%
%      RFDIFF_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RFDIFF_UI.M with the given input arguments.
%
%      RFDIFF_UI('Property','Value',...) creates a new RFDIFF_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rfdiff_UI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rfdiff_UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rfdiff_UI

% Last Modified by GUIDE v2.5 29-Apr-2011 11:13:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rfdiff_UI_OpeningFcn, ...
                   'gui_OutputFcn',  @rfdiff_UI_OutputFcn, ...
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


% --- Executes just before rfdiff_UI is made visible.
function rfdiff_UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rfdiff_UI (see VARARGIN)

% Choose default command line output for rfdiff_UI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rfdiff_UI wait for user response (see UIRESUME)
% uiwait(handles.RFDiffUI);


% --- Outputs from this function are returned to the command line.
function varargout = rfdiff_UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in RFDLoad.
function RFDLoad_Callback(hObject, eventdata, handles)
% hObject    handle to RFDLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rfdiff('Load')


% --- Executes on button press in RFDExit.
function RFDExit_Callback(hObject, eventdata, handles)
% hObject    handle to RFDExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);


% --- Executes on button press in RFDMeasure.
function RFDMeasure_Callback(hObject, eventdata, handles)
% hObject    handle to RFDMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rfd
rfd.reload=1;
rfdiff('Load');

% --- Executes on button press in RFDDoStats.
function RFDDoStats_Callback(hObject, eventdata, handles)
% hObject    handle to RFDDoStats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function RFDStartRun_Callback(hObject, eventdata, handles)
% hObject    handle to RFDStartRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDStartRun as text
%        str2double(get(hObject,'String')) returns contents of RFDStartRun as a double



function RFDEndRun_Callback(hObject, eventdata, handles)
% hObject    handle to RFDEndRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDEndRun as text
%        str2double(get(hObject,'String')) returns contents of RFDEndRun as a double


% --- Executes on button press in RFDDOn.
function RFDDOn_Callback(hObject, eventdata, handles)
% hObject    handle to RFDDOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDDOn



function RFDDX_Callback(hObject, eventdata, handles)
% hObject    handle to RFDDX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDDX as text
%        str2double(get(hObject,'String')) returns contents of RFDDX as a double


function RFDDY_Callback(hObject, eventdata, handles)
% hObject    handle to RFDDY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDDY as text
%        str2double(get(hObject,'String')) returns contents of RFDDY as a double



% --- Executes on button press in RFDEOn.
function RFDEOn_Callback(hObject, eventdata, handles)
% hObject    handle to RFDEOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDEOn



function RFDEX_Callback(hObject, eventdata, handles)
% hObject    handle to RFDEX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDEX as text
%        str2double(get(hObject,'String')) returns contents of RFDEX as a double


function RFDEY_Callback(hObject, eventdata, handles)
% hObject    handle to RFDEY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDEY as text
%        str2double(get(hObject,'String')) returns contents of RFDEY as a double


% --- Executes on button press in RFDFOn.
function RFDFOn_Callback(hObject, eventdata, handles)
% hObject    handle to RFDFOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDFOn



function RFDFX_Callback(hObject, eventdata, handles)
% hObject    handle to RFDFX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDFX as text
%        str2double(get(hObject,'String')) returns contents of RFDFX as a double



function RFDFY_Callback(hObject, eventdata, handles)
% hObject    handle to RFDFY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDFY as text
%        str2double(get(hObject,'String')) returns contents of RFDFY as a double


% --- Executes on button press in RFDGOn.
function RFDGOn_Callback(hObject, eventdata, handles)
% hObject    handle to RFDGOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDGOn



function RFDGX_Callback(hObject, eventdata, handles)
% hObject    handle to RFDGX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDGX as text
%        str2double(get(hObject,'String')) returns contents of RFDGX as a double




function RFDGY_Callback(hObject, eventdata, handles)
% hObject    handle to RFDGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDGY as text
%        str2double(get(hObject,'String')) returns contents of RFDGY as a double




% --- Executes on button press in RFDExternal.
function RFDExternal_Callback(hObject, eventdata, handles)
% hObject    handle to RFDExternal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDExternal



function RFDX_Callback(hObject, eventdata, handles)
% hObject    handle to RFDX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDX as text
%        str2double(get(hObject,'String')) returns contents of RFDX as a double





function RFDY_Callback(hObject, eventdata, handles)
% hObject    handle to RFDY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDY as text
%        str2double(get(hObject,'String')) returns contents of RFDY as a double



% --- Executes on button press in RFDHOn.
function RFDHOn_Callback(hObject, eventdata, handles)
% hObject    handle to RFDHOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDHOn



function RFDHX_Callback(hObject, eventdata, handles)
% hObject    handle to RFDHX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDHX as text
%        str2double(get(hObject,'String')) returns contents of RFDHX as a double




function RFDHY_Callback(hObject, eventdata, handles)
% hObject    handle to RFDHY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDHY as text
%        str2double(get(hObject,'String')) returns contents of RFDHY as a double

% --- Executes on button press in RFDIOn.
function RFDIOn_Callback(hObject, eventdata, handles)
% hObject    handle to RFDIOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDIOn



function RFDIX_Callback(hObject, eventdata, handles)
% hObject    handle to RFDIX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDIX as text
%        str2double(get(hObject,'String')) returns contents of RFDIX as a double



function RFDIY_Callback(hObject, eventdata, handles)
% hObject    handle to RFDIY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDIY as text
%        str2double(get(hObject,'String')) returns contents of RFDIY as a double



% --- Executes on selection change in RFDZValue1.
function RFDZValue1_Callback(hObject, eventdata, handles)
% hObject    handle to RFDZValue1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RFDZValue1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RFDZValue1


% --- Executes on selection change in RFDZValue2.
function RFDZValue2_Callback(hObject, eventdata, handles)
% hObject    handle to RFDZValue2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RFDZValue2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RFDZValue2



% --- Executes on selection change in RFDZValue3.
function RFDZValue3_Callback(hObject, eventdata, handles)
% hObject    handle to RFDZValue3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RFDZValue3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RFDZValue3




% --- Executes on selection change in RFDStatsTest.
function RFDStatsTest_Callback(hObject, eventdata, handles)
% hObject    handle to RFDStatsTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RFDStatsTest contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RFDStatsTest


% --- Executes on selection change in RFDYValue1.
function RFDYValue1_Callback(hObject, eventdata, handles)
% hObject    handle to RFDYValue1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RFDYValue1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RFDYValue1




% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7



% --- Executes on selection change in RFDYValue3.
function RFDYValue3_Callback(hObject, eventdata, handles)
% hObject    handle to RFDYValue3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RFDYValue3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RFDYValue3


% --- Executes on selection change in RFDYValue2.
function RFDYValue2_Callback(hObject, eventdata, handles)
% hObject    handle to RFDYValue2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RFDYValue2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RFDYValue2

% --- Executes on button press in RFDYToggle.
function RFDYToggle_Callback(hObject, eventdata, handles)
% hObject    handle to RFDYToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDYToggle

switch get(hObject,'Value')
	case 0
		set(gh('RFDYValue1'),'Enable','off');
		set(gh('RFDYValue2'),'Enable','off');
		set(gh('RFDYValue3'),'Enable','off');
	case 1
		set(gh('RFDYValue1'),'Enable','on');
		set(gh('RFDYValue2'),'Enable','on');
		set(gh('RFDYValue3'),'Enable','on');
end


% --- Executes on button press in RFDHideABC.
function RFDHideABC_Callback(hObject, eventdata, handles)
% hObject    handle to RFDHideABC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDHideABC





% --- Executes on button press in RFDUseFFT.
function RFDUseFFT_Callback(hObject, eventdata, handles)
% hObject    handle to RFDUseFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDUseFFT



function RFDFFTHarmonic_Callback(hObject, eventdata, handles)
% hObject    handle to RFDFFTHarmonic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDFFTHarmonic as text
%        str2double(get(hObject,'String')) returns contents of RFDFFTHarmonic as a double


% --- Executes on button press in RFDJOn.
function RFDJOn_Callback(hObject, eventdata, handles)
% hObject    handle to RFDJOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDJOn



function RFDJX_Callback(hObject, eventdata, handles)
% hObject    handle to RFDJX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDJX as text
%        str2double(get(hObject,'String')) returns contents of RFDJX as a double


function RFDJY_Callback(hObject, eventdata, handles)
% hObject    handle to RFDJY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDJY as text
%        str2double(get(hObject,'String')) returns contents of RFDJY as a double


% --- Executes on button press in RFDKOn.
function RFDKOn_Callback(hObject, eventdata, handles)
% hObject    handle to RFDKOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RFDKOn



function RFDKX_Callback(hObject, eventdata, handles)
% hObject    handle to RFDKX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDKX as text
%        str2double(get(hObject,'String')) returns contents of RFDKX as a double


function RFDKY_Callback(hObject, eventdata, handles)
% hObject    handle to RFDKY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RFDKY as text
%        str2double(get(hObject,'String')) returns contents of RFDKY as a double



% --- Executes on button press in RFDMetricSpace.
function RFDMetricSpace_Callback(hObject, eventdata, handles)
% hObject    handle to RFDMetricSpace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
