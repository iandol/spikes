function varargout = gaborgen(varargin)
% GABORGEN M-file for gaborgen.fig
%      GABORGEN, by itself, creates a new GABORGEN or raises the existing
%      singleton*.
%
%      H = GABORGEN returns the handle to a new GABORGEN or the handle to
%      the existing singleton*.
%
%      GABORGEN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GABORGEN.M with the given input arguments.
%
%      GABORGEN('Property','Value',...) creates a new GABORGEN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gaborgen_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gaborgen_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gaborgen

% Last Modified by GUIDE v2.5 03-Apr-2006 14:18:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gaborgen_OpeningFcn, ...
                   'gui_OutputFcn',  @gaborgen_OutputFcn, ...
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


% --- Executes just before gaborgen is made visible.
function gaborgen_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gaborgen (see VARARGIN)

% Choose default command line output for gaborgen
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gaborgen wait for user response (see UIRESUME)
% uiwait(handles.figure1);
doplot;
colormap(jet(256));

% --- Outputs from this function are returned to the command line.
function varargout = gaborgen_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function gabgensigma1_Callback(hObject, eventdata, handles)
% hObject    handle to gabgensigma1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgensigma1 as text
%        str2double(get(hObject,'String')) returns contents of gabgensigma1 as a double
doplot;


% --- Executes during object creation, after setting all properties.
function gabgensigma1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgensigma1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgensigma2_Callback(hObject, eventdata, handles)
% hObject    handle to gabgensigma2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgensigma2 as text
%        str2double(get(hObject,'String')) returns contents of gabgensigma2 as a double
doplot;


% --- Executes during object creation, after setting all properties.
function gabgensigma2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgensigma2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgentheta_Callback(hObject, eventdata, handles)
% hObject    handle to gabgentheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgentheta as text
%        str2double(get(hObject,'String')) returns contents of gabgentheta as a double
doplot;


% --- Executes during object creation, after setting all properties.
function gabgentheta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgentheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgentheta2_Callback(hObject, eventdata, handles)
% hObject    handle to gabgentheta2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgentheta2 as text
%        str2double(get(hObject,'String')) returns contents of gabgentheta2 as a double
doplot;


% --- Executes during object creation, after setting all properties.
function gabgentheta2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgentheta2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgenlambda_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenlambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgenlambda as text
%        str2double(get(hObject,'String')) returns contents of gabgenlambda as a double
doplot;


% --- Executes during object creation, after setting all properties.
function gabgenlambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgenlambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgenxoff_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenxoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgenxoff as text
%        str2double(get(hObject,'String')) returns contents of gabgenxoff as a double
doplot;


% --- Executes during object creation, after setting all properties.
function gabgenxoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgenxoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgenphase_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgenphase as text
%        str2double(get(hObject,'String')) returns contents of gabgenphase as a double
doplot;


% --- Executes during object creation, after setting all properties.
function gabgenphase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgenphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgenyoff_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenyoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgenyoff as text
%        str2double(get(hObject,'String')) returns contents of gabgenyoff as a double
doplot;


% --- Executes during object creation, after setting all properties.
function gabgenyoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgenyoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function gabgenxmin_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenxmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgenxmin as text
%        str2double(get(hObject,'String')) returns contents of gabgenxmin as a double
doplot;

% --- Executes during object creation, after setting all properties.
function gabgenxmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgenxmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgenxmax_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenxmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgenxmax as text
%        str2double(get(hObject,'String')) returns contents of gabgenxmax as a double
doplot;

% --- Executes during object creation, after setting all properties.
function gabgenxmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgenxmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgenxsteps_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenxsteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgenxsteps as text
%        str2double(get(hObject,'String')) returns contents of gabgenxsteps as a double
doplot;

% --- Executes during object creation, after setting all properties.
function gabgenxsteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgenxsteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gabgenymax_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgenymax as text
%        str2double(get(hObject,'String')) returns contents of gabgenymax as a double
doplot;

% --- Executes during object creation, after setting all properties.
function gabgenymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgenymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgenysteps_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenysteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgenysteps as text
%        str2double(get(hObject,'String')) returns contents of gabgenysteps as a double
doplot;

% --- Executes during object creation, after setting all properties.
function gabgenysteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgenysteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gabgenymin_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gabgenymin as text
%        str2double(get(hObject,'String')) returns contents of gabgenymin as a double
doplot;

% --- Executes during object creation, after setting all properties.
function gabgenymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gabgenymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in gabgengrid.
function gabgengrid_Callback(hObject, eventdata, handles)
% hObject    handle to gabgengrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotate3d;

% --- Executes on button press in gabgenax.
function gabgenax_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
persistent gabaxis
if gabaxis<1
	axis on
	gabaxis=1;
else
	axis off 
	gabaxis=0;
end

% --- Executes on button press in gabgenreset.
function gabgenreset_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
view(0,90);

% --- Executes on button press in gabgenspawn.
function gabgenspawn_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenspawn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x=getstate;
axes(gh('gabgenaxis'));
c=colormap;
h=gca;
childfigure=figure;   
copyobj(h,childfigure)
figpos(1,[600 400]);
set(gca,'Units','Normalized');
set(gca,'Position',[0.1300    0.1100    0.6626    0.8150]); 
colormap(c);
t=[num2str(x.sigma1) sprintf('\t') num2str(x.sigma2) sprintf('\t') num2str(x.theta*(180/pi)) sprintf('\t') num2str(x.theta2*(180/pi)) sprintf('\t') num2str(x.lambda) sprintf('\t') num2str(x.phase*(180/pi)) sprintf('\t') num2str(x.xoff) sprintf('\t') num2str(x.yoff)];
tt=[num2str(x.sigma1) '     ' num2str(x.sigma2) '     ' num2str(x.theta*(180/pi)) '     ' num2str(x.theta2*(180/pi)) '     ' num2str(x.lambda) '     ' num2str(x.phase*(180/pi)) '     ' num2str(x.xoff) '     ' num2str(x.yoff)];
title(tt);
clipboard('Copy',t);	

% --- Executes on button press in gabgensave.
function gabgensave_Callback(hObject, eventdata, handles)
% hObject    handle to gabgensave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x=getstate;
uisave('x');

% --- Executes on button press in gabgenload.
function gabgenload_Callback(hObject, eventdata, handles)
% hObject    handle to gabgenload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiload;
setstate(x);
doplot;

%--------------------------------------------------------------------------
function doplot()

x=getstate;

axes(gh('gabgenaxis'));
s=view;
surf(x.m,x.n,x.gabdata);
view(s);
axis square;
axis tight;
box on
shading interp;
tt=[num2str(x.sigma1) '     ' num2str(x.sigma2) '     ' num2str(x.theta*(180/pi)) '     ' num2str(x.theta2*(180/pi)) '     ' num2str(x.lambda) '     ' num2str(x.phase*(180/pi)) '     ' num2str(x.xoff) '     ' num2str(x.yoff)];
title(tt);
xlabel('X Position (deg)');
ylabel('Y Position (deg)');
set(gca,'Tag','gabgenaxis');
fixfig;

%--------------------------------------------------------------------------
function ggd=getstate()
ggd.xmin=str2double(get(gh('gabgenxmin'),'String'));
ggd.xmax=str2double(get(gh('gabgenxmax'),'String'));
ggd.xstep=str2double(get(gh('gabgenxsteps'),'String'));

ggd.ymin=str2double(get(gh('gabgenymin'),'String'));
ggd.ymax=str2double(get(gh('gabgenymax'),'String'));
ggd.ystep=str2double(get(gh('gabgenysteps'),'String'));

ggd.m=linspace(ggd.xmin,ggd.xmax,ggd.xstep);
ggd.n=linspace(ggd.ymin,ggd.ymax,ggd.ystep);

ggd.sigma1=str2double(get(gh('gabgensigma1'),'String'));
ggd.sigma2=str2double(get(gh('gabgensigma2'),'String'));
ggd.theta=str2double(get(gh('gabgentheta'),'String'))*(pi/180);
ggd.theta2=str2double(get(gh('gabgentheta2'),'String'))*(pi/180);
ggd.lambda=str2double(get(gh('gabgenlambda'),'String'));
ggd.phase=str2double(get(gh('gabgenphase'),'String'))*(pi/180);
ggd.xoff=str2double(get(gh('gabgenxoff'),'String'));
ggd.yoff=str2double(get(gh('gabgenyoff'),'String'));

ggd.gabdata=gabor(ggd.m, ggd.n, ggd.sigma1, ggd.sigma2, ggd.theta, ggd.theta2, ggd.lambda, ggd.phase, ggd.xoff, ggd.yoff);

%--------------------------------------------------------------------------
function setstate(x);
set(gh('gabgenxmin'),'String',num2str(x.xmin));
set(gh('gabgenxmax'),'String',num2str(x.xmax));
set(gh('gabgenxsteps'),'String', num2str(x.xstep));

set(gh('gabgenymin'),'String',num2str(x.ymin));
set(gh('gabgenymax'),'String',num2str(x.ymax));
set(gh('gabgenysteps'),'String', num2str(x.ystep));

set(gh('gabgensigma1'),'String',num2str(x.sigma1));
set(gh('gabgensigma2'),'String', num2str(x.sigma2));
set(gh('gabgentheta'),'String',num2str((x.theta*(180/pi))));
set(gh('gabgentheta2'),'String',num2str((x.theta2*(180/pi))));
set(gh('gabgenlambda'),'String', num2str(x.lambda));
set(gh('gabgenphase'),'String', num2str((x.phase*(180/pi))));
set(gh('gabgenxoff'),'String', num2str(x.xoff));
set(gh('gabgenyoff'),'String', num2str(x.yoff));

% --- Executes on button press in gabgencolormapedit.
function gabgencolormapedit_Callback(hObject, eventdata, handles)
% hObject    handle to gabgencolormapedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colormapeditor

