function varargout = gbfitfig(varargin)
% GBFITFIG M-file for gbfitfig.fig
%      GBFITFIG, by itself, creates a new GBFITFIG or raises the existing
%      singleton*.
%
%      H = GBFITFIG returns the handle to a new GBFITFIG or the handle to
%      the existing singleton*.
%
%      GBFITFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GBFITFIG.M with the given input arguments.
%
%      GBFITFIG('Property','Value',...) creates a new GBFITFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gbfitfig_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gbfitfig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gbfitfig

% Last Modified by GUIDE v2.5 04-Apr-2006 16:17:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gbfitfig_OpeningFcn, ...
                   'gui_OutputFcn',  @gbfitfig_OutputFcn, ...
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


% --- Executes just before gbfitfig is made visible.
function gbfitfig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gbfitfig (see VARARGIN)

% Choose default command line output for gbfitfig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gbfitfig wait for user response (see UIRESUME)
% uiwait(handles.GaborFitFigure);


% --- Outputs from this function are returned to the command line.
function varargout = gbfitfig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in GFLoad.
function GFLoad_Callback(hObject, eventdata, handles)
% hObject    handle to GFLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborfit('Load Data');

% --- Executes on button press in GFSave.
function GFSave_Callback(hObject, eventdata, handles)
% hObject    handle to GFSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborfit('Save Data');

% --- Executes on button press in GFFitIT.
function GFFitIT_Callback(hObject, eventdata, handles)
% hObject    handle to GFFitIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborfit('FitIt');

% --- Executes on button press in GFExit.
function GFExit_Callback(hObject, eventdata, handles)
% hObject    handle to GFExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);

function GBInfoText_Callback(hObject, eventdata, handles)
% hObject    handle to GBInfoText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GBInfoText as text
%        str2double(get(hObject,'String')) returns contents of GBInfoText as a double


% --- Executes during object creation, after setting all properties.
function GBInfoText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GBInfoText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFsigma2_Callback(hObject, eventdata, handles)
% hObject    handle to GFsigma2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFsigma2 as text
%        str2double(get(hObject,'String')) returns contents of GFsigma2 as a double
gaborfit('RePlot');

% --- Executes during object creation, after setting all properties.
function GFsigma2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFsigma2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFtheta2_Callback(hObject, eventdata, handles)
% hObject    handle to GFtheta2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFtheta2 as text
%        str2double(get(hObject,'String')) returns contents of GFtheta2 as a double
gaborfit('RePlot');

% --- Executes during object creation, after setting all properties.
function GFtheta2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFtheta2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFtheta_Callback(hObject, eventdata, handles)
% hObject    handle to GFtheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFtheta as text
%        str2double(get(hObject,'String')) returns contents of GFtheta as a double
gaborfit('RePlot');

% --- Executes during object creation, after setting all properties.
function GFtheta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFtheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFsigma1_Callback(hObject, eventdata, handles)
% hObject    handle to GFsigma1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFsigma1 as text
%        str2double(get(hObject,'String')) returns contents of GFsigma1 as a double
gaborfit('RePlot');

% --- Executes during object creation, after setting all properties.
function GFsigma1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFsigma1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlambda_Callback(hObject, eventdata, handles)
% hObject    handle to GFlambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlambda as text
%        str2double(get(hObject,'String')) returns contents of GFlambda as a double
gaborfit('RePlot');

% --- Executes during object creation, after setting all properties.
function GFlambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFphase_Callback(hObject, eventdata, handles)
% hObject    handle to GFphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFphase as text
%        str2double(get(hObject,'String')) returns contents of GFphase as a double
gaborfit('RePlot');

% --- Executes during object creation, after setting all properties.
function GFphase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GFImport.
function GFImport_Callback(hObject, eventdata, handles)
% hObject    handle to GFImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborfit('Import');


function GFxoff_Callback(hObject, eventdata, handles)
% hObject    handle to GFxoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFxoff as text
%        str2double(get(hObject,'String')) returns contents of GFxoff as a double
gaborfit('RePlot');

% --- Executes during object creation, after setting all properties.
function GFxoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFxoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFyoff_Callback(hObject, eventdata, handles)
% hObject    handle to GFyoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFyoff as text
%        str2double(get(hObject,'String')) returns contents of GFyoff as a double
gaborfit('RePlot');

% --- Executes during object creation, after setting all properties.
function GFyoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFyoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GFLargeScale2.
function GFLargeScale2_Callback(hObject, eventdata, handles)
% hObject    handle to GFLargeScale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GFLargeScale2


% --- Executes on button press in GFIntCheck2.
function GFIntCheck2_Callback(hObject, eventdata, handles)
% hObject    handle to GFIntCheck2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GFIntCheck2


% --- Executes on selection change in GFDisplayMenu.
function GFDisplayMenu_Callback(hObject, eventdata, handles)
% hObject    handle to GFDisplayMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns GFDisplayMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GFDisplayMenu


% --- Executes during object creation, after setting all properties.
function GFDisplayMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFDisplayMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in GFIntMenu.
function GFIntMenu_Callback(hObject, eventdata, handles)
% hObject    handle to GFIntMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns GFIntMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GFIntMenu


% --- Executes during object creation, after setting all properties.
function GFIntMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFIntMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlb1_Callback(hObject, eventdata, handles)
% hObject    handle to GFlb1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlb1 as text
%        str2double(get(hObject,'String')) returns contents of GFlb1 as a double


% --- Executes during object creation, after setting all properties.
function GFlb1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlb1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlb2_Callback(hObject, eventdata, handles)
% hObject    handle to GFlb2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlb2 as text
%        str2double(get(hObject,'String')) returns contents of GFlb2 as a double


% --- Executes during object creation, after setting all properties.
function GFlb2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlb2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlb3_Callback(hObject, eventdata, handles)
% hObject    handle to GFlb3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlb3 as text
%        str2double(get(hObject,'String')) returns contents of GFlb3 as a double


% --- Executes during object creation, after setting all properties.
function GFlb3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlb3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlb4_Callback(hObject, eventdata, handles)
% hObject    handle to GFlb4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlb4 as text
%        str2double(get(hObject,'String')) returns contents of GFlb4 as a double


% --- Executes during object creation, after setting all properties.
function GFlb4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlb4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlb5_Callback(hObject, eventdata, handles)
% hObject    handle to GFlb5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlb5 as text
%        str2double(get(hObject,'String')) returns contents of GFlb5 as a double


% --- Executes during object creation, after setting all properties.
function GFlb5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlb5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlb6_Callback(hObject, eventdata, handles)
% hObject    handle to GFlb6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlb6 as text
%        str2double(get(hObject,'String')) returns contents of GFlb6 as a double


% --- Executes during object creation, after setting all properties.
function GFlb6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlb6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlb7_Callback(hObject, eventdata, handles)
% hObject    handle to GFlb7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlb7 as text
%        str2double(get(hObject,'String')) returns contents of GFlb7 as a double


% --- Executes during object creation, after setting all properties.
function GFlb7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlb7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlb8_Callback(hObject, eventdata, handles)
% hObject    handle to GFlb8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlb8 as text
%        str2double(get(hObject,'String')) returns contents of GFlb8 as a double


% --- Executes during object creation, after setting all properties.
function GFlb8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlb8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFub1_Callback(hObject, eventdata, handles)
% hObject    handle to GFub1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFub1 as text
%        str2double(get(hObject,'String')) returns contents of GFub1 as a double


% --- Executes during object creation, after setting all properties.
function GFub1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFub1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFub2_Callback(hObject, eventdata, handles)
% hObject    handle to GFub2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFub2 as text
%        str2double(get(hObject,'String')) returns contents of GFub2 as a double


% --- Executes during object creation, after setting all properties.
function GFub2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFub2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFub3_Callback(hObject, eventdata, handles)
% hObject    handle to GFub3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFub3 as text
%        str2double(get(hObject,'String')) returns contents of GFub3 as a double


% --- Executes during object creation, after setting all properties.
function GFub3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFub3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFub4_Callback(hObject, eventdata, handles)
% hObject    handle to GFub4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFub4 as text
%        str2double(get(hObject,'String')) returns contents of GFub4 as a double


% --- Executes during object creation, after setting all properties.
function GFub4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFub4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFub5_Callback(hObject, eventdata, handles)
% hObject    handle to GFub5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFub5 as text
%        str2double(get(hObject,'String')) returns contents of GFub5 as a double


% --- Executes during object creation, after setting all properties.
function GFub5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFub5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFub6_Callback(hObject, eventdata, handles)
% hObject    handle to GFub6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFub6 as text
%        str2double(get(hObject,'String')) returns contents of GFub6 as a double


% --- Executes during object creation, after setting all properties.
function GFub6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFub6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFub7_Callback(hObject, eventdata, handles)
% hObject    handle to GFub7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFub7 as text
%        str2double(get(hObject,'String')) returns contents of GFub7 as a double


% --- Executes during object creation, after setting all properties.
function GFub7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFub7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFub8_Callback(hObject, eventdata, handles)
% hObject    handle to GFub8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFub8 as text
%        str2double(get(hObject,'String')) returns contents of GFub8 as a double


% --- Executes during object creation, after setting all properties.
function GFub8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFub8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFspont_Callback(hObject, eventdata, handles)
% hObject    handle to GFspont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFspont as text
%        str2double(get(hObject,'String')) returns contents of GFspont as a double
gaborfit('RePlot');

% --- Executes during object creation, after setting all properties.
function GFspont_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFspont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFamp_Callback(hObject, eventdata, handles)
% hObject    handle to GFamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFamp as text
%        str2double(get(hObject,'String')) returns contents of GFamp as a double
gaborfit('RePlot');

% --- Executes during object creation, after setting all properties.
function GFamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlb9_Callback(hObject, eventdata, handles)
% hObject    handle to GFlb9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlb9 as text
%        str2double(get(hObject,'String')) returns contents of GFlb9 as a double


% --- Executes during object creation, after setting all properties.
function GFlb9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlb9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFlb10_Callback(hObject, eventdata, handles)
% hObject    handle to GFlb10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFlb10 as text
%        str2double(get(hObject,'String')) returns contents of GFlb10 as a double


% --- Executes during object creation, after setting all properties.
function GFlb10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFlb10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFub10_Callback(hObject, eventdata, handles)
% hObject    handle to GFub10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFub10 as text
%        str2double(get(hObject,'String')) returns contents of GFub10 as a double


% --- Executes during object creation, after setting all properties.
function GFub10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFub10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GFub9_Callback(hObject, eventdata, handles)
% hObject    handle to GFub9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GFub9 as text
%        str2double(get(hObject,'String')) returns contents of GFub9 as a double


% --- Executes during object creation, after setting all properties.
function GFub9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFub9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in GFReset.
function GFReset_Callback(hObject, eventdata, handles)
% hObject    handle to GFReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborfit('ReSet');

% --- Executes on button press in GFLocktheta.
function GFLocktheta_Callback(hObject, eventdata, handles)
% hObject    handle to GFLocktheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GFLocktheta

% --- Executes on button press in GFSpawn.
function GFSpawn_Callback(hObject, eventdata, handles)
% hObject    handle to GFSpawn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaborfit('Spawn');

% --- Executes on button press in GFreset1.
function GFreset1_Callback(hObject, eventdata, handles)
% hObject    handle to GFreset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
view(2);

% --- Executes on button press in GFrotate.
function GFrotate_Callback(hObject, eventdata, handles)
% hObject    handle to GFrotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotate3d;

% --- Executes on button press in GFcopyview.
function GFcopyview_Callback(hObject, eventdata, handles)
% hObject    handle to GFcopyview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(gh('GFAxis1'));
s=view;
axes(gh('GFAxis2'));
view(s);

% --- Executes on button press in GFcopyview2.
function GFcopyview2_Callback(hObject, eventdata, handles)
% hObject    handle to GFcopyview2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(gh('GFAxis2'));
s=view;
axes(gh('GFAxis1'));
view(s);


% --- Executes on selection change in GFHistory.
function GFHistory_Callback(hObject, eventdata, handles)
% hObject    handle to GFHistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns GFHistory contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GFHistory
gaborfit('GetHistory');

% --- Executes during object creation, after setting all properties.
function GFHistory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GFHistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GFScratch.
function GFScratch_Callback(hObject, eventdata, handles)
% hObject    handle to GFScratch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with hanIdles and user data (see GUIDATA)
gaborfit('StoreIt');



% --- Executes on button press in GFLargeScale.
function GFLargeScale_Callback(hObject, eventdata, handles)
% hObject    handle to GFLargeScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GFLargeScale


% --- Executes on button press in GFNormalise.
function GFNormalise_Callback(hObject, eventdata, handles)
% hObject    handle to GFNormalise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GFNormalise
set(gh('GFlb9'),'String','0');
set(gh('GFub9'),'String','0');
set(gh('GFlb10'),'String','1');
set(gh('GFub10'),'String','1');

% --- Executes on button press in GFIntCheck.
function GFIntCheck_Callback(hObject, eventdata, handles)
% hObject    handle to GFIntCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GFIntCheck


