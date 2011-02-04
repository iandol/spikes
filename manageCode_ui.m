function varargout = manageCode_ui(varargin)
% MANAGECODE_UI M-file for manageCode_ui.fig
%      MANAGECODE_UI, by itself, creates a new MANAGECODE_UI or raises the existing
%      singleton*.
%
%      H = MANAGECODE_UI returns the handle to a new MANAGECODE_UI or the handle to
%      the existing singleton*.
%
%      MANAGECODE_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANAGECODE_UI.M with the given input arguments.
%
%      MANAGECODE_UI('Property','Value',...) creates a new MANAGECODE_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manageCode_ui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manageCode_ui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manageCode_ui

% Last Modified by GUIDE v2.5 02-Feb-2011 14:15:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manageCode_ui_OpeningFcn, ...
                   'gui_OutputFcn',  @manageCode_ui_OutputFcn, ...
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


% --- Executes just before manageCode_ui is made visible.
function manageCode_ui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manageCode_ui (see VARARGIN)

% Choose default command line output for manageCode_ui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manageCode_ui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = manageCode_ui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in mCCodebase.
function mCCodebase_Callback(hObject, eventdata, handles)
% hObject    handle to mCCodebase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mCCodebase contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mCCodebase

function mCRemoteVersion_Callback(hObject, eventdata, handles)
% hObject    handle to mCRemoteVersion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mCRemoteVersion as text
%        str2double(get(hObject,'String')) returns contents of mCRemoteVersion as a double


function mCLocalVersion_Callback(hObject, eventdata, handles)
% hObject    handle to mCLocalVersion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mCLocalVersion as text
%        str2double(get(hObject,'String')) returns contents of mCLocalVersion as a double



% --- Executes on button press in mCAddPath.
function mCAddPath_Callback(hObject, eventdata, handles)
% hObject    handle to mCAddPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mCInstall.
function mCInstall_Callback(hObject, eventdata, handles)
% hObject    handle to mCInstall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mCQuit.
function mCQuit_Callback(hObject, eventdata, handles)
% hObject    handle to mCQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
