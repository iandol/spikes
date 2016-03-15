function varargout = spikes_UI(varargin)
% SPIKES_UI Application M-file for spikes_UI.fig
%    FIG = SPIKES_UI launch spikes_UI GUI.
%    SPIKES_UI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 12-Feb-2016 14:08:58

if nargin == 0  % LAUNCH GUI
	
	fig = openfig(mfilename,'new',varargin{:});
	
	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
	
	if nargout > 0
		varargout{1} = fig;
	end
	
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
	
	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch ME
		t=ME.getReport;
		disp(t);
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
function varargout = CellMenu_Callback(h, eventdata, handles, varargin)

global sv;                                   
sv.firstunit=get(h,'Value');
if strcmp(sv.loaded,'yes')
	sv.reload='yes';
	spikes('Load');
end

% --------------------------------------------------------------------
function varargout = SBinWidth_Callback(h, eventdata, handles, varargin)

global sv;                       
sv.BinWidth=str2num(get(h,'String'));
if strcmp(sv.loaded,'yes')
	sv.reload='yes';
	spikes('Load');
end

% --------------------------------------------------------------------
function varargout = SStartMod_Callback(h, eventdata, handles, varargin)

global sv;                       
sv.StartMod=str2num(get(h,'String')); 

% --------------------------------------------------------------------
function varargout = SEndMod_Callback(h, eventdata, handles, varargin)

global sv;                       
sv.EndMod=str2num(get(h,'String'));

% --------------------------------------------------------------------
function varargout = SStartTrial_Callback(h, eventdata, handles, varargin)

global sv;                       
sv.StartTrial=str2num(get(h,'String'));
if sv.StartTrial>sv.EndTrial
	sv.StartTrial=1;
	set(h,'String',num2str(sv.StartTrial));
end

% --------------------------------------------------------------------
function varargout = SEndTrial_Callback(h, eventdata, handles, varargin)

global sv;                       
sv.EndTrial=str2num(get(h,'String'));
if sv.EndTrial<sv.StartTrial
	sv.EndTrial=sv.StartTrial;
	set(h,'String',num2str(sv.EndTrial));
end

% --- Executes on selection change in SPlotMenu.
function SPlotMenu_Callback(hObject, eventdata, handles)
global data;

data.plottype=get(hObject,'Value');
			
spikes('ChoosePlot');

% --------------------------------------------------------------------
function varargout = XHoldMenu_Callback(h, eventdata, handles, varargin)
global sv; 
sv.xval=get(h,'Value');
if get(gh('XHoldCheck'),'Value')==1
	spikes('ChoosePlot');
end

% --------------------------------------------------------------------
function varargout = YHoldMenu_Callback(h, eventdata, handles, varargin)
global sv; 
sv.yval=get(h,'Value');
if get(gh('YHoldCheck'),'Value')==1
	spikes('ChoosePlot');
end

% --- Executes on selection change in ZHoldMenu.
function ZHoldMenu_Callback(h, eventdata, handles)
global sv; 
sv.zval=get(h,'Value');
if get(gh('ZHoldCheck'),'Value')==1
	spikes('ChoosePlot');
end

% --- Executes on button press in XHoldCheck.
function XHoldCheck_Callback(h, eventdata, handles)
global sv; 
sv.xlock=get(h,'Value');
%spikes('ChoosePlot');

% --- Executes on button press in YHoldCheck.
function YHoldCheck_Callback(h, eventdata, handles)
global sv; 
sv.ylock=get(h,'Value');
%spikes('ChoosePlot');

% --- Executes on button press in ZHoldCheck.
function ZHoldCheck_Callback(h, eventdata, handles)
global sv; 
sv.zlock=get(h,'Value');
%spikes('ChoosePlot');

% --------------------------------------------------------------------
function varargout = SMeasureButton_Callback(h, eventdata, handles, varargin)
global sv
set(findobj('Tag','SMinEdit'),'UserData','no');
set(findobj('Tag','SMaxEdit'),'UserData','no');
sv.MeasureButton = true;
spikes('Measure');

% --- Executes on button press in SQuickFFT.
function SQuickFFT_Callback(hObject, eventdata, handles)
% hObject    handle to SQuickFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sv
if ~isfield(sv,'ffttoggle')
	sv.ffttoggle = true;
end
if sv.ffttoggle == true
	set(findobj('Tag','SMinEdit'),'UserData','no');
	set(findobj('Tag','SMaxEdit'),'UserData','no');
	set(findobj('Tag','AnalysisMenu'),'Value',6);
	sv.AnalysisMethod=6;
	set(gh('SOverrideTime'),'Value',1);
	set(gh('SMinEdit'),'String','0');
	set(gh('SMinEdit'),'Enable','off');
	set(gh('SMinEdit'),'UserData','no');
	set(gh('SMaxEdit'),'String','Inf');
	set(gh('SMaxEdit'),'Enable','off');
	set(gh('SMinEdit'),'UserData','no');
	set(gh('Measurebutton'),'Enable','off');
	sv.ffttoggle = false;
else
	set(findobj('Tag','AnalysisMenu'),'Value',1);
	sv.AnalysisMethod=1;
	sv.ffttoggle = true;
end
sv.MeasureButton = true;
spikes('Measure');

% --------------------------------------------------------------------
function varargout = WrappedMenu_Callback(h, eventdata, handles, varargin)
global sv;
global mint maxt;
mint=0;
maxt=inf;
set(gh('SMinEdit'),'String','0');
set(gh('SMaxEdit'),'String','Inf');
sv.Wrapped=get(h,'Value');
if strcmp(sv.loaded,'yes')
	sv.reload='yes';
	spikes('Load');
end

% --------------------------------------------------------------------
function varargout = AnalysisMenu_Callback(h, eventdata, handles, varargin)

global sv;                   
sv.AnalysisMethod=get(h,'Value');

% --------------------------------------------------------------------
function varargout = STypeMenu_Callback(h, eventdata, handles, varargin)

global sv;                  
Value=get(h,'Value');          
String=get(h,'String');        
sv.PlotType=String{Value};           
spikes('ChoosePlot')

% --------------------------------------------------------------------
function varargout = CMapMenu_Callback(h, eventdata, handles, varargin)

global sv;              
Value=get(h,'Value');  
String=get(h,'String');
sv.CMap=String{Value};
if strcmp(sv.CMap,'jet')
	colormap(jet(256));
elseif strcmp(sv.CMap,'hot')
	colormap(hot(256));
elseif strcmp(sv.CMap,'bone')
	colormap(bone(256));
else
	colormap(String{Value});	
end

% --------------------------------------------------------------------
function varargout = ShadingMenu_Callback(h, eventdata, handles, varargin)

global sv;           
Value=get(h,'Value');      
String=get(h,'String');
sv.ShadingType=String{Value};    
switch(sv.ShadingType)           
case 'Flat'                   
	sv.ShadingType='flat';     
	shading(sv.ShadingType)    
case 'Interpolated'           
	sv.ShadingType='interp';   
	shading(sv.ShadingType)    
case 'Faceted'                
	sv.ShadingType='faceted';  
	shading(sv.ShadingType)    
end

% --------------------------------------------------------------------
function varargout = LightMenu_Callback(h, eventdata, handles, varargin)

global sv;                  
Value=get(h,'Value');          
String=get(h,'String');        
sv.LightAdd=String{Value};           
camlight(sv.LightAdd);

% --------------------------------------------------------------------
function varargout = SmoothingSlider_Callback(h, eventdata, handles, varargin)

global sv;                                                       
Value=get(h,'Value');                                                  
sv.SmoothValue=round(Value);                                                 
a=strcat('Resolution: ',num2str(sv.SmoothValue));                            
set(findobj('Tag','SmoothingText'),'String',a);
spikes('ChoosePlot');

% --------------------------------------------------------------------
function varargout = SmoothingMenu_Callback(h, eventdata, handles, varargin)

global sv;                    
Value=get(h,'Value');              
String=get(h,'String');            
sv.SmoothType=String{Value};
spikes('ChoosePlot');

% --------------------------------------------------------------------
function varargout = LightingMenu_Callback(h, eventdata, handles, varargin)

global sv;                    
Value=get(h,'Value');              
String=get(h,'String');            
sv.Lighting=String{Value};       
spikes('ChoosePlot');

% --------------------------------------------------------------------
function varargout = ErrorMenu_Callback(h, eventdata, handles, varargin)

global sv;                    
Value=get(h,'Value');              
String=get(h,'String');            
sv.ErrorMode=String{Value};

% --------------------------------------------------------------------
function varargout = AxisBox_Callback(h, eventdata, handles, varargin)
Value=get(h,'Value');                                     
if Value==1                                                  
	set(findobj('UserData','AxesEdit'),'String','-inf inf');     
	set(findobj('UserData','AxesEdit'),'Enable','off');          
else                                                         
	set(findobj('UserData','AxesEdit'),'Enable','on');
end 
set(findobj('UserData','AxesEdit'),'BackgroundColor',[1,1,1]);
set(findobj('UserData','AxesEdit'),'ForegroundColor',[0,0,0]);
% --------------------------------------------------------------------
function varargout = IndPSTHMes_Callback(h, eventdata, handles, varargin)

if get(gco,'value')==1 | (get(gco,'value')==0 & get(findobj('tag','GlobPSTHMes'),'value')==0)  
	set(findobj('tag','GlobPSTHMes'),'value',0);
	set(gco,'value',1);
end

% --------------------------------------------------------------------
function varargout = GlobPSTHMes_Callback(h, eventdata, handles, varargin)

if get(gco,'value')==1 | (get(gco,'value')==0 & get(findobj('tag','IndPSTHMes'),'value')==0)  
	set(findobj('tag','IndPSTHMes'),'value',0);                                                   
	set(gco,'value',1);                                                                           
end

% --------------------------------------------------------------------
function varargout = SpikeMenu_Callback(h, eventdata, handles, varargin)
spikes('SpikeSet')

% --------------------------------------------------------------------
function varargout = AnalMenu_Callback(h, eventdata, handles, varargin)

Value=get(h,'Value');              
String=get(h,'String');            
anal=String{Value};                   
spikes(anal);

% --------------------------------------------------------------------
function varargout = SMinEdit_Callback(h, eventdata, handles, varargin)

global sv

set(h,'UserData','yes');                                                                           
maxh=gh('SMaxEdit');
mint=str2num(get(h,'String')); 
maxt=str2num(get(maxh,'String'));

if get(findobj('Tag','SUseWindow'),'Value')==1
	window=str2num(get(gh('SISIWindow'),'String'));
	maxt=window+mint;
	set(maxh,'String',num2str(maxt));
	set(maxh,'UserData','yes');
end
if mint>=maxt; mint = maxt-10; end
if mint<0
	mint=0;
	set(h,'String',num2str(mint));
end
sv.mint=mint;
sv.maxt=maxt;
spikes('Measure');

% --------------------------------------------------------------------
function varargout = SMaxEdit_Callback(h, eventdata, handles, varargin)

global sv

set(h,'UserData','yes');  
minh=gh('SMinEdit');
mint=str2num(get(minh,'String'));
maxt=str2num(get(h,'String')); 

if mint>=maxt; mint = maxt-10; end
if mint<0
	mint=0;
	maxt=Inf;
	set(minh,'String',num2str(mint));
	set(h,'String',num2str(maxt));
end

if get(gh('SUseWindow'),'Value')==1
	window=str2num(get(gh('SISIWindow'),'String'));
	mint=maxt-window;
	if mint<=0
		mint=0;
		maxt=window;
	end
	set(minh,'String',num2str(mint));
	set(h,'String',num2str(maxt));
	set(h,'UserData','yes'); 
end

sv.mint=mint;
sv.maxt=maxt;
spikes('Measure');

% --------------------------------------------------------------------
function varargout = SAxisMenu_Callback(h, eventdata, handles, varargin)

global sv

Value=get(h,'Value');                      
String=get(h,'String');                    
axival=String{Value};
switch axival
case 'Axis Above Data'
	set(gca,'Layer','top');
	sv.layer='top';
case 'Axis Below Data'
	set(gca,'Layer','bottom');
	sv.layer='bottom';
case 'Ticks Facing In'
	tickdir('in');
	sv.ticks='in';
case 'Ticks Facing Out'	
	tickdir('out');
	sv.ticks='out';
case 'Axis Box On'
	box on
    sv.box='on';
case 'Axis Box Off'
	box off
    sv.box='off';
case 'Flip X and Y'
	set(gca,'View',[90 90]);
case 'Y Axis Normal'
	set(gca,'YDir','normal');
case 'Y Axis Reverse'
	set(gca,'YDir','reverse');
case '------------'
case 'Auto Renderer'
	set(gcf,'RendererMode','auto');
case 'Painters Renderer'
	set(gcf,'RendererMode','manual');
	%set(gcf,'Renderer','painters');
case 'ZBuffer Renderer'
	set(gcf,'RendererMode','manual');
	%set(gcf,'Renderer','zbuffer');
case'OpenGL Renderer'
	set(gcf,'RendererMode','manual');
	set(gcf,'Renderer','OpenGL');
otherwise
	eval(['axis ' axival])
end

% --------------------------------------------------------------------
function varargout = GaussBox_Callback(h, eventdata, handles, varargin)

Value=get(h,'Value');
if Value==0
	set(handles.GaussEdit,'Enable','off')
else
	set(handles.GaussEdit,'Enable','on')
end
set(handles.GaussEdit,'Backgroundcolor',[1,1,1])
set(handles.GaussEdit,'Foregroundcolor',[0,0,0])

% --------------------------------------------------------------------
function varargout = PropBox_Callback(h, eventdata, handles, varargin)
global sv;                    
Value=get(h,'Value');
sv.PropAxis=Value;

% --- Executes on button press in colormapedit.
function colormapedit_Callback(hObject, eventdata, handles)
% hObject    handle to colormapedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colormapeditor;


% --- Executes on selection change in spikehistory.
function spikehistory_Callback(hObject, eventdata, handles)
% hObject    handle to spikehistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns spikehistory contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spikehistory

global sv; 
contents = get(hObject,'String');
value = get(hObject,'Value');
sv.reload=contents{value};
spikes('Load');


% --- Executes on button press in ReloadButton.
function ReloadButton_Callback(hObject, eventdata, handles)
% hObject    handle to ReloadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sv;
if strcmp(sv.loaded,'yes')
	sv.reload='yes';
	spikes('Load');
end


% --- Executes on key press over SpikeFig with no controls selected.
function SpikeFig_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to SpikeFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sv;

char=get(hObject,'CurrentCharacter');
	
switch char		
	case 'r'
		sv.reload='yes';
		spikes('Load');			
	case 'l'
		spikes('Load');	
	case 'm'
		spikes('Measure');
	case 'n'
		set(gh('SMinEdit'),'Selected','on');			
	case 'x'
		set(gh('SMaxEdit'),'Selected','on');
	case '1'
		set(gh('CellMenu'),'Value',1);
		sv.firstunit=1;
		if strcmp(sv.loaded,'yes')
			sv.reload='yes';
			spikes('Load');
		end
	case '2'
		set(gh('CellMenu'),'Value',2);
		sv.firstunit=2;
		if strcmp(sv.loaded,'yes')
			sv.reload='yes';
			spikes('Load');
		end
	case '3'
		set(gh('CellMenu'),'Value',3);
		sv.firstunit=3;
		if strcmp(sv.loaded,'yes')
			sv.reload='yes';
			spikes('Load');
		end
	case '4'
		set(gh('CellMenu'),'Value',4);
		sv.firstunit=4;
		if strcmp(sv.loaded,'yes')
			sv.reload='yes';
			spikes('Load');
		end
	case '5'
		set(gh('CellMenu'),'Value',5);
		sv.firstunit=5;
		if strcmp(sv.loaded,'yes')
			sv.reload='yes';
			spikes('Load');
		end
	case '6'
		set(gh('CellMenu'),'Value',6);
		sv.firstunit=6;
		if strcmp(sv.loaded,'yes')
			sv.reload='yes';
			spikes('Load');
		end			
end


% --- Executes on button press in PrevFileButton.
function PrevFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrevFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sv;
global data;
if strcmp(sv.loaded,'yes')
	if data.zipload == true
		sv.reload = [data.sourcepath ' | Cell ' num2str(data.cell)];
	else
		sv.reload=[data.filename ' | Cell ' num2str(data.cell)];
	end
	sv.loadtype='previous';
	spikes('Load');
end

% --- Executes on button press in NextFileButton.
function NextFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sv;
global data;
if strcmp(sv.loaded,'yes')
	if data.zipload == true
		sv.reload = [data.sourcepath ' | Cell ' num2str(data.cell)];
	else
		sv.reload=[data.filename ' | Cell ' num2str(data.cell)];
	end
	sv.loadtype='next';
	spikes('Load');
end

% --- Executes on button press in PlotButton.
function PlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spikes('RePlot');

function SContourLevels_Callback(hObject, eventdata, handles)
% hObject    handle to SContourLevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SContourLevels as text
%        str2double(get(hObject,'String')) returns contents of SContourLevels as a double

% --- Executes on button press in SShowError.
function SShowError_Callback(hObject, eventdata, handles)
% hObject    handle to SShowError (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SShowError


function SXSlice_Callback(hObject, eventdata, handles)
% hObject    handle to SXSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SXSlice as text
%        str2double(get(hObject,'String')) returns contents of SXSlice as a double
spikes('RePlot');


function SYSlice_Callback(hObject, eventdata, handles)
% hObject    handle to SYSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SYSlice as text
%        str2double(get(hObject,'String')) returns contents of SYSlice as a double
spikes('RePlot');


% --- Executes on selection change in SSliceHistory.
function SSliceHistory_Callback(hObject, eventdata, handles)
% hObject    handle to SSliceHistory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SSliceHistory contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SSliceHistory
contents = get(hObject,'String');
if iscellstr(contents)
	contents = contents{get(hObject,'Value')};
	a=find(contents=='>');
	set(gh('SXSlice'),'String',contents(1:a-1));
	set(gh('SYSlice'),'String',contents(a+1:end));
elseif ~strcmp(contents,' ')
	a=find(contents=='>');
	set(gh('SXSlice'),'String',contents(1:a-1));
	set(gh('SYSlice'),'String',contents(a+1:end));
end
spikes('ChoosePlot');

% --- Executes on button press in SSliceSave.
function SSliceSave_Callback(hObject, eventdata, handles)
% hObject    handle to SSliceSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xslice=get(gh('SXSlice'),'String');
yslice=get(gh('SXSlice'),'String');

outstring=[xslice '>' yslice];

shistval=get(gh('SSliceHistory'),'Value');
shiststring=get(gh('SSliceHistory'),'String');

if size(shiststring,1)==1 && strcmp(' ',shiststring)
	set(gh('SSliceHistory'),'String',outstring);
elseif size(shiststring,1)==1
	shiststring={shiststring;outstring};
	set(gh('SSliceHistory'),'String',shiststring);
else
	shiststring{length(shiststring)+1}=outstring;
	set(gh('SSliceHistory'),'String',shiststring);
end

% --- Executes on button press in SSliceReset.
function SSliceReset_Callback(hObject, eventdata, handles)
% hObject    handle to SSliceReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data

set(gh('SXSlice'),'String',regexprep(num2str(data.xvalueso),'\s+',' '));
set(gh('SYSlice'),'String',regexprep(num2str(data.yvalueso),'\s+',' '));

spikes('ChoosePlot');

% --- Executes on button press in SOverrideTime.
function SOverrideTime_Callback(hObject, eventdata, handles)
% hObject    handle to SOverrideTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SOverrideTime
global sv
if get(hObject,'Value')==1
	set(gh('SMinEdit'),'String','0');
	set(gh('SMinEdit'),'Enable','off');
	set(gh('SMinEdit'),'UserData','no');
	set(gh('SMaxEdit'),'String','Inf');
	set(gh('SMaxEdit'),'Enable','off');
	set(gh('SMinEdit'),'UserData','no');
	set(gh('Measurebutton'),'Enable','off');
else
	set(gh('SMinEdit'),'Enable','on');
	set(gh('SMaxEdit'),'Enable','on');
	set(gh('Measurebutton'),'Enable','on');
end
sv.MeasureButton = false;

function STransientValue_Callback(hObject, eventdata, handles)
% hObject    handle to STransientValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of STransientValue as text
%        str2double(get(hObject,'String')) returns contents of STransientValue as a double


% --- Executes on button press in SCutTransient.
function SCutTransient_Callback(hObject, eventdata, handles)
% hObject    handle to SCutTransient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SCutTransient
if get(hObject,'Value')==0
	set(handles.STransientValue,'Enable','off')
else
	set(handles.STransientValue,'Enable','on')
end
set(handles.STransientValue,'BackgroundColor',[0.95,0.95,0.95])
set(handles.STransientValue,'ForegroundColor',[0,0,0])


function SWindow_Callback(hObject, eventdata, handles)
% hObject    handle to SWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SWindow as text
%        str2double(get(hObject,'String')) returns contents of SWindow as a double


% --- Executes on button press in SUseWindow.
function SUseWindow_Callback(hObject, eventdata, handles)
% hObject    handle to SUseWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SUseWindow


% --- Executes on button press in SRemoveMean.
function SRemoveMean_Callback(hObject, eventdata, handles)
% hObject    handle to SRemoveMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SRemoveMean


% --- Executes on button press in SAllPSTHs.
function SAllPSTHs_Callback(hObject, eventdata, handles)
% hObject    handle to SAllPSTHs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spikes('Plot All PSTHs');


% --- Executes on button press in SDoDOG.
function SDoDOG_Callback(hObject, eventdata, handles)
% hObject    handle to SDoDOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spikes('Difference of Gaussian');

% --- Executes on button press in SDoArea.
function SDoArea_Callback(hObject, eventdata, handles)
% hObject    handle to SDoArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spikes('Area Analysis');

% --- Executes on button press in SDoSurround.
function SDoSurround_Callback(hObject, eventdata, handles)
% hObject    handle to SDoSurround (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spikes('Surround Suppression');

% --- Executes on button press in SDoSPlot.
function SDoSPlot_Callback(hObject, eventdata, handles)
% hObject    handle to SDoSPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spikes('Plot Single PSTH');

% --- Executes on button press in SDoMetric.
function SDoMetric_Callback(hObject, eventdata, handles)
% hObject    handle to SDoMetric (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spikes('Metric Space');


% --- Executes on mouse press over figure background.
function SpikeFig_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SpikeFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spikes('Data Info');



function SPDogSpont_Callback(hObject, eventdata, handles)
% hObject    handle to SPDogSpont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPDogSpont as text
%        str2double(get(hObject,'String')) returns contents of SPDogSpont as a double




% --- Executes on button press in SLoadRAWButton.
function SLoadRAWButton_Callback(hObject, eventdata, handles)
% hObject    handle to SLoadRAWButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sv
sv.reload = '';
spikes('Load');


% --- Executes on button press in SdoBARS.
function SdoBARS_Callback(hObject, eventdata, handles)
% hObject    handle to SdoBARS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SdoBARS
global sv
sv.plotBARS = get(hObject,'Value');

function SPLXOffset_Callback(hObject, eventdata, handles)
% hObject    handle to SPLXOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPLXOffset as text
%        str2double(get(hObject,'String')) returns contents of SPLXOffset as a double
global sv
sv.startOffset = str2num(get(hObject,'String'));



function SPLXcellmap_Callback(hObject, eventdata, handles)
% hObject    handle to SPLXcellmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPLXcellmap as text
%        str2double(get(hObject,'String')) returns contents of SPLXcellmap as a double
global sv
global data
cellmap = str2num(get(hObject,'String'));
if length(cellmap) == 6
	sv.cellmap = cellmap;
	if isa(data.pR,'plxReader')
		data.pR.cellmap = sv.cellmap;
	end
else
	warndlg('You must enter 6 numerical values that map cell1-6 to plexon units!')
end


% --- Executes on button press in SPLXReport.
function SPLXReport_Callback(hObject, eventdata, handles)
% hObject    handle to SPLXReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data
if isa(data.pR,'plxReader')
	report behaviour;
end



function firstisi_Callback(hObject, eventdata, handles)
% hObject    handle to firstisi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstisi as text
%        str2double(get(hObject,'String')) returns contents of firstisi as a double


function PSTHEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PSTHEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PSTHEdit as text
%        str2double(get(hObject,'String')) returns contents of PSTHEdit as a double
global sv
s = get(hObject,'String');
sv.PSTHScale = str2num(s);

% --- Executes on button press in sDensityPlot.
function sDensityPlot_Callback(hObject, eventdata, handles)
% hObject    handle to sDensityPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spikes('Plot Density');

% --- Executes on button press in sBurstRatio.
function sBurstRatio_Callback(hObject, eventdata, handles)
% hObject    handle to sBurstRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spikes('Burst Ratio');
