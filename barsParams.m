function varargout = barsParams(varargin)
% BARSPARAMS MATLAB code for barsParams.fig
%      BARSPARAMS, by itself, creates a new BARSPARAMS or raises the existing
%      singleton*.
%
%      H = BARSPARAMS returns the handle to a new BARSPARAMS or the handle to
%      the existing singleton*.
%
%      BARSPARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BARSPARAMS.M with the given input arguments.
%
%      BARSPARAMS('Property','Value',...) creates a new BARSPARAMS or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before barsParams_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to barsParams_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help barsParams

% Last Modified by GUIDE v2.5 10-Nov-2011 08:14:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @barsParams_OpeningFcn, ...
                   'gui_OutputFcn',  @barsParams_OutputFcn, ...
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

% --- Executes just before barsParams is made visible.
function barsParams_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to barsParams (see VARARGIN)

% Choose default command line output for barsParams
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes barsParams wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = barsParams_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function burn_iter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to burn_iter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function burn_iter_Callback(hObject, eventdata, handles)
% hObject    handle to burn_iter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of burn_iter as text
%        str2double(get(hObject,'String')) returns contents of burn_iter as a double

%guidata(hObject,handles)



% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
% if isfield(handles, 'metricdata') && ~isreset
%     return;
% end
% 
% handles.metricdata.density = 0;
% handles.metricdata.volume  = 0;
% 
% set(handles.burn_iter, 'String', handles.metricdata.density);
% set(handles.volume,  'String', handles.metricdata.volume);
% set(handles.mass, 'String', 0);
% 
% set(handles.unitgroup, 'SelectedObject', handles.english);
% 
% set(handles.text4, 'String', 'lb/cu.in');
% set(handles.text5, 'String', 'cu.in');
% set(handles.text6, 'String', 'lb');
% 
% % Update handles structure
% guidata(handles.figure1, handles);



function conf_level_Callback(hObject, eventdata, handles)
% hObject    handle to conf_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of conf_level as text
%        str2double(get(hObject,'String')) returns contents of conf_level as a double


% --- Executes during object creation, after setting all properties.
function conf_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to conf_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dparams_Callback(hObject, eventdata, handles)
% hObject    handle to dparams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dparams as text
%        str2double(get(hObject,'String')) returns contents of dparams as a double


% --- Executes during object creation, after setting all properties.
function dparams_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dparams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function k_Callback(hObject, eventdata, handles)
% hObject    handle to k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of k as text
%        str2double(get(hObject,'String')) returns contents of k as a double


% --- Executes during object creation, after setting all properties.
function k_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in prior_id.
function prior_id_Callback(hObject, eventdata, handles)
% hObject    handle to prior_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns prior_id contents as cell array
%        contents{get(hObject,'Value')} returns selected item from prior_id


% --- Executes during object creation, after setting all properties.
function prior_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prior_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setParams.
function setParams_Callback(hObject, eventdata, handles)
% hObject    handle to setParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sv
if exist('sv','var') && ~ isempty(sv)
	
	s = get(handles.prior_id,'String');
	v = get(handles.prior_id,'Value');
	sv.bars.prior_id = s{v};
	sv.bars.k = str2num(get(handles.k,'String'));
	sv.bars.dparams = str2num(get(handles.dparams,'String'));
	sv.bars.burn_iter = str2num(get(handles.burn_iter,'String'));
	sv.bars.conf_level = str2num(get(handles.conf_level,'String'));
	sv.bars.usezero = get(handles.usezero,'Value');
	close(handles.figure1);
	
end


% --- Executes on button press in usezero.
function usezero_Callback(hObject, eventdata, handles)
% hObject    handle to usezero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of usezero
