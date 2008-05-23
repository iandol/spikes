function varargout = spikefig(varargin)
% SPIKEFIG Application M-file for spikefig.fig
%    FIG = SPIKEFIG launch spikefig GUI.
%    SPIKEFIG('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 13-Mar-2007 09:03:17

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
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
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
function varargout = CellMenu_Callback(h, eventdata, handles, varargin)

global sv;                                   
sv.firstunit=get(h,'Value');
if strcmp(sv.loaded,'yes')
	sv.reload='yes';
	spikes('Load');
end

% --------------------------------------------------------------------
function varargout = BinWidth_Callback(h, eventdata, handles, varargin)

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

% --------------------------------------------------------------------
function varargout = SEndTrial_Callback(h, eventdata, handles, varargin)

global sv;                       
sv.EndTrial=str2num(get(h,'String'));

% --- Executes on selection change in PlotMenu.
function PlotMenu_Callback(hObject, eventdata, handles)
global data sv;

data.plottype=get(hObject,'Value');
switch data.plottype
	case 1 %raster
		if data.numvars>0 sv.xlock=1; set(gh('XHoldCheck'),'Value',1); end
		if data.numvars>1 sv.ylock=1; set(gh('YHoldCheck'),'Value',1); end
		if data.numvars>2 sv.zlock=1; set(gh('ZHoldCheck'),'Value',1); end		
	case 2 %psth
		if data.numvars>0 sv.xlock=1; set(gh('XHoldCheck'),'Value',1); end
		if data.numvars>1 sv.ylock=1; set(gh('YHoldCheck'),'Value',1); end
		if data.numvars>2 sv.zlock=1; set(gh('ZHoldCheck'),'Value',1); end		
	case 3 %tuning curve
		if sv.xlock==1 & data.numvars==1
			sv.xlock=0;
			set(gh('XHoldCheck'),'Value',0);
		elseif sv.xlock==1 & sv.ylock==1 & data.numvars==2
			sv.xlock=0;
			set(gh('XHoldCheck'),'Value',0);
		end
	case 4 %surface
		sv.xlock=0;
		sv.ylock=0;
		set(gh('XHoldCheck'),'Value',0);
		set(gh('YHoldCheck'),'Value',0);
end
			
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
% spikes('ChoosePlot');

% --- Executes on button press in YHoldCheck.
function YHoldCheck_Callback(h, eventdata, handles)
global sv; 

sv.ylock=get(h,'Value');
% spikes('ChoosePlot');

% --- Executes on button press in ZHoldCheck.
function ZHoldCheck_Callback(h, eventdata, handles)
global sv; 

sv.zlock=get(h,'Value');
% spikes('ChoosePlot');

% --------------------------------------------------------------------
function varargout = MeasureButton_Callback(h, eventdata, handles, varargin)

set(findobj('Tag','MinEdit'),'UserData','no');
set(findobj('Tag','MaxEdit'),'UserData','no');
spikes('Measure');

% --------------------------------------------------------------------
function varargout = WrappedMenu_Callback(h, eventdata, handles, varargin)

global sv;              
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
function varargout = TypeMenu_Callback(h, eventdata, handles, varargin)

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
function varargout = MinEdit_Callback(h, eventdata, handles, varargin)

global mint;                                                                                          
set(h,'UserData','yes');                                                                           
mint=str2num(get(h,'String'));                                                                     
x=str2num(get(findobj('Tag','MaxEdit'),'String'));                                                    
if ~isempty(x) & x>mint;                                                                              
	spikes('Measure');                                                                                    
end;    

% --------------------------------------------------------------------
function varargout = MaxEdit_Callback(h, eventdata, handles, varargin)

global maxt;                                                                                          
set(h,'UserData','yes');                                                                           
maxt=str2num(get(h,'String')) ;                                                                    
x=str2num(get(findobj('Tag','MinEdit'),'String'));                                                    
if ~isempty(x) & x>=0;                                                                                
	spikes('Measure');                                                                                    
end;

% --------------------------------------------------------------------
function varargout = AxisMenu_Callback(h, eventdata, handles, varargin)

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
case '------------'
case 'Auto Renderer'
	set(gcf,'RendererMode','auto');
case 'Painters Renderer'
	set(gcf,'RendererMode','manual');
	set(gcf,'Renderer','painters');
case 'ZBuffer Renderer'
	set(gcf,'RendererMode','manual');
	set(gcf,'Renderer','zbuffer');
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
		set(gh('MinEdit'),'Selected','on');			
	case 'x'
		set(gh('MaxEdit'),'Selected','on');
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
	sv.reload=[data.filename ' | Cell ' num2str(data.cell)];
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
	sv.reload=[data.filename ' | Cell ' num2str(data.cell)];
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


% --- Executes during object creation, after setting all properties.
function SContourLevels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SContourLevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SCutTransient.
function SCutTransient_Callback(hObject, eventdata, handles)
% hObject    handle to SCutTransient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SCutTransient



function SCutAmount_Callback(hObject, eventdata, handles)
% hObject    handle to SCutAmount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SCutAmount as text
%        str2double(get(hObject,'String')) returns contents of SCutAmount as a double


% --- Executes during object creation, after setting all properties.
function SCutAmount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SCutAmount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


