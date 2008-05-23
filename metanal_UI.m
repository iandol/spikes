function varargout = metanal_UI(varargin)
%METANAL_UI M-file for metanal_UI.fig
%      METANAL_UI, by itself, creates a new METANAL_UI or raises the existing
%      singleton*.
%
%      H = METANAL_UI returns the handle to a new METANAL_UI or the handle to
%      the existing singleton*.
%
%      METANAL_UI('Property','Value',...) creates a new METANAL_UI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to metanal_UI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      METANAL_UI('CALLBACK') and METANAL_UI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in METANAL_UI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help metanal_UI

% Last Modified by GUIDE v2.5 06-Jun-2006 10:09:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @metanal_UI_OpeningFcn, ...
                   'gui_OutputFcn',  @metanal_UI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before metanal_UI is made visible.
function metanal_UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for metanal_UI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes metanal_UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = metanal_UI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
