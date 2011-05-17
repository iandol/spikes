function varargout = spikereport(varargin)
% SPIKEREPORT M-file for spikereport.fig
%      SPIKEREPORT, by itself, creates a new SPIKEREPORT or raises the existing
%      singleton*.
%
%      H = SPIKEREPORT returns the handle to a new SPIKEREPORT or the handle to
%      the existing singleton*.
%
%      SPIKEREPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPIKEREPORT.M with the given input arguments.
%
%      SPIKEREPORT('Property','Value',...) creates a new SPIKEREPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spikereport_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spikereport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 17-May-2011 13:26:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spikereport_OpeningFcn, ...
                   'gui_OutputFcn',  @spikereport_OutputFcn, ...
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


% --- Executes just before spikereport is made visible.
function spikereport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spikereport (see VARARGIN)
global rlist
% Choose default command line output for spikereport
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

rlist=[];
if ismac
	if ~exist(['~' filesep 'MatlabFiles' filesep],'dir')
		mkdir(['~' filesep 'MatlabFiles' filesep]);
	end
	rlist.usingmac=1;
	rlist.basepath=['~' filesep 'MatlabFiles' filesep];
else
	if ~exist('c:\MatlabFiles','dir')
		mkdir('c:\MatlabFiles')
	end
	rlist.usingmac=0;
	rlist.basepath=['c:' filesep 'MatlabFiles' filesep];
end
rlist.format='PDF';
set(handles.RepFormatMenu,'Value',2);
rlist.size=1;
rlist.index=1;
rlist.tag=[];
rlist.celllist=[];
rlist.guilock=0;
rlist.saveMatFiles = 1;
rlist.item{1}.filename='Template -';
rlist.item{1}.cell=1;
rlist.item{1}.minmod='1';
rlist.item{1}.maxmod='inf';
rlist.item{1}.mintrial='1';
rlist.item{1}.maxtrial='inf';
rlist.item{1}.binwidth='20';
rlist.item{1}.wrap=1;
rlist.item{1}.gaussian=0;
rlist.item{1}.analmethod=1;
rlist.item{1}.mintime='0';
rlist.item{1}.maxtime='inf';
rlist.item{1}.plotpsth=1;
rlist.item{1}.plotisi=1;
rlist.item{1}.tuningcurve=0;
rlist.item{1}.xaxis='-inf inf';
rlist.item{1}.yaxis='-inf inf';
rlist.item{1}.zaxis='-inf inf';
rlist.item{1}.showinfo=0;
rlist.item{1}.showprotocol=0;
rlist.item{1}.justimages=0;
rlist.item{1}.notes=' ';
rlist.item{1}.hold=0;
rlist.item{1}.holdvalx=-1;
rlist.item{1}.holdvaly=-1;
rlist.item{1}.holdvalz=-1;
rlist.item{1}.plotmethod=7;
rlist.item{1}.errormethod=1;
rlist.item{1}.cuttransient=0;
rlist.item{1}.cutamount=60;
% set(gh('RepFileList'),'String',rlist.item{1}.title);
% set(gh('RepFileList'),'Value',1);
UpdateFileList;
RepFileList_Callback(gh('RepFileList'));


% --- Outputs from this function are returned to the command line.
function varargout = spikereport_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ------
function UpdateFileList()
global rlist
for i=1:rlist.size
	filelist{i}=[rlist.item{i}.filename ' | Cell ' num2str(rlist.item{i}.cell)];
	if i==rlist.index
		filelist{i}=[filelist{i} '  *'];
	end
	if max(rlist.tag==i)>0
		filelist{i}=[filelist{i} ' @'];
    end
    if isfield(rlist.item{i},'notes') 
        note=rlist.item{i}.notes;
        if ~strcmp(note,' ')
            filelist{i}=[filelist{i} ' | ' note];
        end
    end
end
set(gh('RepFileList'),'String',filelist);
set(gh('RepFileList'),'Value',rlist.index);

function FlushGUI()
global rlist
set(gh('RepFileList'),'Value',rlist.index);
RepFileList_Callback(gh('RepFileList'));
RepHoldCheck_Callback(gh('RepHoldCheck'));

% --- Executes on button press in RepLoad.
function RepLoad_Callback(hObject, eventdata, handles)
% hObject    handle to RepLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;

[fn,pn]=uigetfile({'*.zip;*.smr;*.txt;*.mat','All Spikes Filetypes (*.zip *.smr *.txt *.mat)';'*.*','All Files'},'Select File Type to Load:','MultiSelect','on');

if ~iscell(fn)
	fn={fn};
end
if fn{1}==0
    helpdlg('No File Selected...');
    error('No File Selected');
end
cd(pn);

for j=1:length(fn)
	[p,n,e]=fileparts([pn fn{j}]);
	if ~isempty(regexpi(e,'.matx'))
		load([p filesep n e]);
	end
	if ~isfield(rlist,'celllist') || isempty(rlist.celllist)
		cellloop=1;
	else
		cellloop=length(rlist.celllist);
	end
	for i=1:cellloop		
		rlist.size=rlist.size+1;
		rlist.index=rlist.size;
		if ~isfield(rlist,'celllist') || isempty(rlist.celllist)
			rlist.item{rlist.index}.cell=get(gh('RepCellMenu'),'Value');
		else
			rlist.item{rlist.index}.cell=rlist.celllist(i);
		end			
		switch e
			case '.mat'
				rlist.item{rlist.index}.filename=data.filename;
				if data.wrapped==1
					rlist.item{rlist.index}.wrap=1
				else
					rlist.item{rlist.index}.wrap=1
				end
				rlist.item{rlist.index}.mintrial=data.raw{1}.starttrial;
				rlist.item{rlist.index}.maxtrial=data.raw{1}.endtrial;
				rlist.item{rlist.index}.binwidth=data.binwidth;
			otherwise
				rlist.item{rlist.index}.filename=[p filesep n e];
				rlist.item{rlist.index}.wrap=get(gh('RepWrapCheck'),'Value');
				rlist.item{rlist.index}.mintrial=get(gh('RepMinTrials'),'String');
				rlist.item{rlist.index}.maxtrial=get(gh('RepMaxTrials'),'String');
				rlist.item{rlist.index}.binwidth=get(gh('RepBinWidth'),'String');
		end
		rlist.item{rlist.index}.minmod=get(gh('RepMinMods'),'String');
		rlist.item{rlist.index}.maxmod=get(gh('RepMaxMods'),'String');
		rlist.item{rlist.index}.gaussian=get(gh('RepGaussianCheck'),'Value');
		rlist.item{rlist.index}.analmethod=get(gh('RepTypeMenu'),'Value');
		rlist.item{rlist.index}.mintime=get(gh('RepMinTime'),'String');
		rlist.item{rlist.index}.maxtime=get(gh('RepMaxTime'),'String');
		rlist.item{rlist.index}.plotpsth=get(gh('RepPlotPSTHCheck'),'Value');
		rlist.item{rlist.index}.plotisi=get(gh('RepPlotISICheck'),'Value');
		rlist.item{rlist.index}.tuningcurve=get(gh('RepPlotTCCheck'),'Value');
		rlist.item{rlist.index}.xaxis=get(gh('RepXAxis'),'String');
		rlist.item{rlist.index}.yaxis=get(gh('RepYAxis'),'String');
		rlist.item{rlist.index}.zaxis=get(gh('RepZAxis'),'String');
		rlist.item{rlist.index}.showinfo=get(gh('ShowInfoCheck'),'Value');
		rlist.item{rlist.index}.showprotocol=get(gh('ShowProtocolCheck'),'Value');
		rlist.item{rlist.index}.justimages=get(gh('JustImagesCheck'),'Value');	
		rlist.item{rlist.index}.hold=get(gh('RepHoldCheck'),'Value');	
		rlist.item{rlist.index}.plotmethod=get(gh('RepPlotMenu'),'Value');
		rlist.item{rlist.index}.errormethod=get(gh('RepErrorMenu'),'Value');
		rlist.item{rlist.index}.holdvalx=str2double(get(gh('RepHoldValX'),'String'));
		rlist.item{rlist.index}.holdvaly=str2double(get(gh('RepHoldValY'),'String'));
		rlist.item{rlist.index}.holdvalz=str2double(get(gh('RepHoldValZ'),'String'));
		rlist.item{rlist.index}.cuttransient=get(gh('RepCutTransient'),'Value');
		rlist.item{rlist.index}.cutamount=str2double(get(gh('RepCutAmount'),'String'));
	end
end
UpdateFileList;
FlushGUI;

% --- Executes on button press in RepLoadMat.
function RepLoadMat_Callback(hObject, eventdata, handles)
% hObject    handle to RepLoadMat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;
[fn,pn]=uigetfile({'*.mat','Mat Files';'*.*','All Files'},'Select File Type to Load:','MultiSelect','off');

load([pn fn]);
UpdateFileList;
FlushGUI;

% --- Executes on selection change in RepCellMenu.
function RepCellMenu_Callback(hObject, eventdata, handles)
% hObject    handle to RepCellMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RepCellMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RepCellMenu
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.cell=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.cell=get(hObject,'Value');
	end
end
UpdateFileList;

% --- Executes on selection change in RepFileList.
function RepFileList_Callback(hObject, eventdata, handles)
% hObject    handle to RepFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RepFileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RepFileList
global rlist;
rlist.index=get(hObject,'Value');

set(gh('RepCellMenu'),'Value',rlist.item{rlist.index}.cell);
set(gh('RepMinMods'),'String',rlist.item{rlist.index}.minmod);
set(gh('RepMaxMods'),'String',rlist.item{rlist.index}.maxmod);
set(gh('RepMinTrials'),'String',rlist.item{rlist.index}.mintrial);
set(gh('RepMaxTrials'),'String',rlist.item{rlist.index}.maxtrial);
set(gh('RepBinWidth'),'String',rlist.item{rlist.index}.binwidth);
set(gh('RepWrapCheck'),'Value',rlist.item{rlist.index}.wrap);
set(gh('RepGaussianCheck'),'Value',rlist.item{rlist.index}.gaussian);
set(gh('RepTypeMenu'),'Value',rlist.item{rlist.index}.analmethod);
set(gh('RepMinTime'),'String',rlist.item{rlist.index}.mintime);
set(gh('RepMaxTime'),'String',rlist.item{rlist.index}.maxtime);
set(gh('RepPlotPSTHCheck'),'Value',rlist.item{rlist.index}.plotpsth);
if isfield(rlist.item{rlist.index},'plotisi')
	set(gh('RepPlotISICheck'),'Value',rlist.item{rlist.index}.plotisi);
end
set(gh('RepPlotTCCheck'),'Value',rlist.item{rlist.index}.tuningcurve);
set(gh('RepXAxis'),'String',rlist.item{rlist.index}.xaxis);
set(gh('RepYAxis'),'String',rlist.item{rlist.index}.yaxis);
set(gh('RepZAxis'),'String',rlist.item{rlist.index}.zaxis);
set(gh('ShowInfoCheck'),'Value',rlist.item{rlist.index}.showinfo);
set(gh('ShowProtocolCheck'),'Value',rlist.item{rlist.index}.showprotocol);
set(gh('JustImagesCheck'),'Value',rlist.item{rlist.index}.justimages);
set(gh('RepHoldCheck'),'Value',rlist.item{rlist.index}.hold);	
if isfield(rlist.item{rlist.index},'holdvalx')
	set(gh('RepHoldValX'),'String',num2str(rlist.item{rlist.index}.holdvalx));
end
if isfield(rlist.item{rlist.index},'holdvaly')
	set(gh('RepHoldValY'),'String',num2str(rlist.item{rlist.index}.holdvaly));
end
if isfield(rlist.item{rlist.index},'holdvalz')
	set(gh('RepHoldValZ'),'String',num2str(rlist.item{rlist.index}.holdvalz));
end
if isfield(rlist.item{rlist.index},'errormethod')
	set(gh('RepErrorMenu'),'Value',rlist.item{rlist.index}.errormethod);
end
if isfield(rlist.item{rlist.index},'plotmethod')
	set(gh('RepPlotMenu'),'Value',rlist.item{rlist.index}.plotmethod);
end
if isfield(rlist.item{rlist.index},'cuttransient')
	set(gh('RepCutTransient'),'Value',rlist.item{rlist.index}.cuttransient);
end
if isfield(rlist.item{rlist.index},'cutamount')
	set(gh('ReCutAmount'),'String',num2str(rlist.item{rlist.index}.cutamount));
end

UpdateFileList;
RepHoldCheck_Callback(gh('RepHoldCheck'));



function RepMinMods_Callback(hObject, eventdata, handles)
% hObject    handle to RepMinMods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepMinMods as text
%        str2double(get(hObject,'String')) returns contents of RepMinMods as a double
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.minmod=get(hObject,'String');

else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.minmod=get(hObject,'String');
	end
end


function RepMaxMods_Callback(hObject, eventdata, handles)
% hObject    handle to RepMaxMods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepMaxMods as text
%        str2double(get(hObject,'String')) returns contents of RepMaxMods as a double
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.maxmod=get(hObject,'String');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.maxmod=get(hObject,'String');
	end
end


function RepMinTrials_Callback(hObject, eventdata, handles)
% hObject    handle to RepMinTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepMinTrials as text
%        str2double(get(hObject,'String')) returns contents of RepMinTrials as a double
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.mintrial=get(hObject,'String');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.mintrial=get(hObject,'String');
	end
end


function RepMaxTrials_Callback(hObject, eventdata, handles)
% hObject    handle to RepMaxTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepMaxTrials as text
%        str2double(get(hObject,'String')) returns contents of RepMaxTrials as a double
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.maxtrial=get(hObject,'String');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.maxtrial=get(hObject,'String');
	end
end

% --- Executes on selection change in RepTypeMenu.
function RepTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to RepTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RepTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RepTypeMenu
global rlist;

if isempty(rlist.tag)
	rlist.item{rlist.index}.analmethod=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.analmethod=get(hObject,'Value');
	end
end

function RepMinTime_Callback(hObject, eventdata, handles)
% hObject    handle to RepMinTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepMinTime as text
%        str2double(get(hObject,'String')) returns contents of RepMinTime as a double
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.mintime=get(hObject,'String');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.mintime=get(hObject,'String');
	end
end

function RepMaxTime_Callback(hObject, eventdata, handles)
% hObject    handle to RepMaxTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepMaxTime as text
%        str2double(get(hObject,'String')) returns contents of RepMaxTime as a double
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.maxtime=get(hObject,'String');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.maxtime=get(hObject,'String');
	end
end

% --- Executes on button press in RepMoveUp.
function RepMoveUp_Callback(hObject, eventdata, handles)
% hObject    handle to RepMoveUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;
current=rlist.index;
switch current
	case 1		
	case 2
		%new=[rlist.item(2), rlist.item(1), rlist.item(3:end)];
		%rlist.item=new;
	otherwise
		new=[rlist.item(1:current-2),rlist.item(current),rlist.item(current-1),rlist.item(current+1:end)];
		rlist.item=new;
		rlist.index=current-1;
end
UpdateFileList;

% --- Executes on button press in RepMoveDown.
function RepMoveDown_Callback(hObject, eventdata, handles)
% hObject    handle to RepMoveDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;
current=rlist.index;
switch current
	case 1
	case 2
		new=[rlist.item(1), rlist.item(current+1), rlist.item(current), rlist.item(current+1:end)];
		rlist.item=new;
		rlist.index=current+1;
	otherwise
		if current~=rlist.size	
			new=[rlist.item(1:current-1),rlist.item(current+1), rlist.item(current), rlist.item(current+2:end)];
			rlist.item=new;
			rlist.index=current+1;
		end
end

UpdateFileList;

% --- Executes on button press in RepClone.
function RepClone_Callback(hObject, eventdata, handles)
% hObject    handle to RepClone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist
if rlist.index>1
    if isempty(rlist.tag)
        item=rlist.item(rlist.index);
        newlist=[rlist.item(1:rlist.index),item,rlist.item(rlist.index+1:end)];
        rlist.item=newlist;
        rlist.size=rlist.size+1;
        rlist.index=rlist.index+1;
        UpdateFileList;
	else		
        index=unique(rlist.tag);
		rlist.tag=[];
        for i=1:length(index)
            if index(i)>1
                rlist.item{rlist.size+1}=rlist.item{index(i)};
                rlist.size=rlist.size+1;
				rlist.tag=[rlist.tag rlist.size];
            end
		end
        UpdateFileList;
    end
end

% --- Executes on button press in RepDelete.
function RepDelete_Callback(hObject, eventdata, handles)
% hObject    handle to RepDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist
current=rlist.index;
if rlist.index>1
	if isempty(rlist.tag)
		rlist.size=rlist.size-1;
		rlist.index=rlist.index-1;
		rlist.item(current)=[];
	else
		rlist.item(rlist.tag)=[];		
		rlist.index=1;
		rlist.size=length(rlist.item);
		rlist.tag=[];
	end			
end
UpdateFileList;

% --- Executes on button press in RepEdit.
function RepEdit_Callback(hObject, eventdata, handles)
% hObject    handle to RepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;
newname=inputdlg('Edit Filename:','Spikes Report Generator Edit Filename:',1,{rlist.item{rlist.index}.filename});
if ~isempty(newname)
	if isempty(rlist.tag)
		rlist.item{rlist.index}.filename=newname{1};
	else
		for i=1:length(rlist.tag)
			rlist.item{rlist.tag(i)}.filename=newname{1};
		end
	end
	UpdateFileList;
end


% --- Executes on button press in RepNote.
function RepNote_Callback(hObject, eventdata, handles)
% hObject    handle to RepNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;
if ~isfield(rlist.item{rlist.index},'notes')
	rlist.item{rlist.index}.notes=' ';
end
notes=inputdlg('Add notes:','Spikes Report Generator Edit Notes:',1,{rlist.item{rlist.index}.notes});
if ~isempty(notes)
	if isempty(rlist.tag)
		rlist.item{rlist.index}.notes=notes{1};
	else
		for i=1:length(rlist.tag)
			rlist.item{rlist.tag(i)}.notes=notes{1};
		end
	end
	UpdateFileList;
end
% --- Executes on button press in RepTag.
function RepTag_Callback(hObject, eventdata, handles)
% hObject    handle to RepTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;
index=rlist.tag==rlist.index;
if isempty(index) || max(index)==0
	rlist.tag=unique([rlist.tag rlist.index]);
else
	rlist.tag(index)=[];
end
UpdateFileList;

% --- Executes on button press in RepUnTag.
function RepUnTag_Callback(hObject, eventdata, handles)
% hObject    handle to RepUnTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;
rlist.tag=[];
UpdateFileList;

% --- Executes on button press in RepGaussianCheck.
function RepGaussianCheck_Callback(hObject, eventdata, handles)
% hObject    handle to RepGaussianCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RepGaussianCheck
global rlist;
rlist.item{rlist.index}.gaussian=get(hObject,'Value');

% --- Executes on button press in RepWrapCheck.
function RepWrapCheck_Callback(hObject, eventdata, handles)
% hObject    handle to RepWrapCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RepWrapCheck
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.wrap=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.wrap=get(hObject,'Value');
	end
end	

function RepBinWidth_Callback(hObject, eventdata, handles)
% hObject    handle to RepBinWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepBinWidth as text
%        str2double(get(hObject,'String')) returns contents of RepBinWidth as a double
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.binwidth=get(hObject,'String');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.binwidth=get(hObject,'String');
	end
end	

% --- Executes on button press in RepPlotPSTHCheck.
function RepPlotPSTHCheck_Callback(hObject, eventdata, handles)
% hObject    handle to RepPlotPSTHCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RepPlotPSTHCheck
global rlist;

if isempty(rlist.tag)
	rlist.item{rlist.index}.plotpsth=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.plotpsth=get(hObject,'Value');
	end
end	

% --- Executes on button press in RepPlotTCCheck.
function RepPlotTCCheck_Callback(hObject, eventdata, handles)
% hObject    handle to RepPlotTCCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RepPlotTCCheck
global rlist;

if isempty(rlist.tag)
	rlist.item{rlist.index}.tuningcurve=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.tuningcurve=get(hObject,'Value');
	end
end	

function RepXAxis_Callback(hObject, eventdata, handles)
% hObject    handle to RepXAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepXAxis as text
%        str2double(get(hObject,'String')) returns contents of RepXAxis as a double
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.xaxis=get(hObject,'String');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.xaxis=get(hObject,'String');

	end
end	

function RepYAxis_Callback(hObject, eventdata, handles)
% hObject    handle to RepYAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepYAxis as text
%        str2double(get(hObject,'String')) returns contents of RepYAxis as a double
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.yaxis=get(hObject,'String');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.yaxis=get(hObject,'String');

	end
end	

function RepZAxis_Callback(hObject, eventdata, handles)
% hObject    handle to RepZAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepZAxis as text
%        str2double(get(hObject,'String')) returns contents of RepZAxis as a double
global rlist;
if isempty(rlist.tag)
	rlist.item{rlist.index}.zaxis=get(hObject,'String');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.zaxis=get(hObject,'String');

	end
end	

% --- Executes on button press in RepSave.
function RepSave_Callback(hObject, eventdata, handles)
% hObject    handle to RepSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;
[fn,pn]=uiputfile('*.mat','Place to Save Mat','report.mat');
file=[pn fn];
save(file,'rlist');

% --- Executes on button press in RepImport.
function RepImport_Callback(hObject, eventdata, handles)
% hObject    handle to RepImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;

% --- Executes on button press in RepGenerate.
function RepGenerate_Callback(hObject, eventdata, handles)
% hObject    handle to RepGenerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;
if isfield(rlist,'pn'); cd(rlist.pn); end;
out=['report.' rlist.format];
[fn,pn]=uiputfile('*.*','File to Save Report in',out);
rlist.fn=fn;
rlist.pn=pn;
save([rlist.basepath  'report.mat'], 'rlist');
reportout=['-o' rlist.pn rlist.fn];
reporttype=['-f' rlist.format];
report('spikereport',reportout,reporttype);


% --- Executes on button press in RepLockGUI.
function RepLockGUI_Callback(hObject, eventdata, handles)
% hObject    handle to RepLockGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RepLockGUI
global rlist
rlist.guilock=get(hObject,'Value');


% --- Executes on selection change in RepFormatMenu.
function RepFormatMenu_Callback(hObject, eventdata, handles)
% hObject    handle to RepFormatMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RepFormatMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RepFormatMenu
global rlist
contents = get(hObject,'String');
rlist.format=contents{get(hObject,'Value')};

% --- Executes on button press in ShowInfoCheck.
function ShowInfoCheck_Callback(hObject, eventdata, handles)
% hObject    handle to ShowInfoCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowInfoCheck
global rlist

if isempty(rlist.tag)
	rlist.item{rlist.index}.showinfo=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.showinfo=get(hObject,'Value');
	end
end	

% --- Executes on button press in ShowProtocolCheck.
function ShowProtocolCheck_Callback(hObject, eventdata, handles)
% hObject    handle to ShowProtocolCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowProtocolCheck
global rlist
rlist.item{rlist.index}.showprotocol=get(hObject,'Value');
if isempty(rlist.tag)
	rlist.item{rlist.index}.showprotocol=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.showprotocol=get(hObject,'Value');
	end
end
% --- Executes on button press in JustImagesCheck.
function JustImagesCheck_Callback(hObject, eventdata, handles)
% hObject    handle to JustImagesCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of JustImagesCheck
global rlist
if isempty(rlist.tag)
	rlist.item{rlist.index}.justimages=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.justimages=get(hObject,'Value');

	end
end

% --- Executes on key press over RepFileList with no controls selected.
function RepFileList_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to RepFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;

char=get(gcf,'CurrentCharacter');
%index=rlist.index;

switch char		
	case '1'
		rlist.item{rlist.index}.cell=1;
		UpdateFileList;
	case '2'
		rlist.item{rlist.index}.cell=2;
		UpdateFileList;
	case '3'
		rlist.item{rlist.index}.cell=3;
		UpdateFileList;
	case '4'
		rlist.item{rlist.index}.cell=4;
		UpdateFileList;
	case '5'
		rlist.item{rlist.index}.cell=5;
		UpdateFileList;
	case '6'
		rlist.item{rlist.index}.cell=6;
		UpdateFileList;
	case 'w'
		if rlist.item{rlist.index}.wrap==0
			rlist.item{rlist.index}.wrap=1;
		else
			rlist.item{rlist.index}.wrap=0;
		end
		FlushGUI;
	case 'p'
		if rlist.item{rlist.index}.plotpsth==0
			rlist.item{rlist.index}.plotpsth=1;
		else
			rlist.item{rlist.index}.plotpsth=0;
		end
		FlushGUI;
    case 'r'
        if rlist.item{rlist.index}.tuningcurve==0
			rlist.item{rlist.index}.tuningcurve=1;
		else
			rlist.item{rlist.index}.tuningcurve=0;
		end
		FlushGUI;
	case 'v'
		if rlist.item{rlist.index}.showprotocol==0
			rlist.item{rlist.index}.showprotocol=1;			
		else
			rlist.item{rlist.index}.showprotocol=0;
		end
		FlushGUI;
	case 'i'
		if rlist.item{rlist.index}.justimages==0
			rlist.item{rlist.index}.justimages=1;			
		else
			rlist.item{rlist.index}.justimages=0;
		end
		FlushGUI;
	case 'x'
		RepDelete_Callback;
	case 'c'
		RepClone_Callback;
	case 'u'
		RepMoveUp_Callback;
	case 'd'
		RepMoveDown_Callback;
    case ' '
        RepTag_Callback;
	case 'a'
        RepTag_Callback;
	case 'g'
        RepUnTag_Callback;
	case 'e'
		RepEdit_Callback;
    case 'n'
		RepNote_Callback;
end

function RepFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to RepFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepFileEdit as text
%        str2double(get(hObject,'String')) returns contents of RepFileEdit as a double

% --- Executes on button press in RepExit.
function RepExit_Callback(hObject, eventdata, handles)
% hObject    handle to RepExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist
if ~isfield(rlist,'basepath')
	if ismac
		if ~exist(['~' filesep 'MatlabFiles' filesep],'dir')
			mkdir(['~' filesep 'MatlabFiles' filesep]);
		end
		rlist.usingmac=1;
		rlist.basepath=['~' filesep 'MatlabFiles' filesep];
	else
		if ~exist('c:\MatlabFiles','dir')
			mkdir('c:\MatlabFiles')
		end
		rlist.usingmac=0;
		rlist.basepath=['c:' filesep 'MatlabFiles' filesep];
	end
end
save([rlist.basepath  'reportbackup.mat'], 'rlist');
close(gcf);


function RepCellList_Callback(hObject, eventdata, handles)
% hObject    handle to RepCellList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepCellList as text
%        str2double(get(hObject,'String')) returns contents of RepCellList as a double
global rlist
rlist.celllist=str2num(get(hObject,'String'));

function RepRegEx_Callback(hObject, eventdata, handles)
% hObject    handle to RepRegEx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepRegEx as text
%        str2double(get(hObject,'String')) returns contents of RepRegEx as a double
global rlist
pattern=get(hObject,'String');
if isempty(pattern)
	rlist.tag=[];
else
	filelist=get(gh('RepFileList'),'String');
	rlist.tag=[];
	for i=1:rlist.size
		if regexpi(filelist{i},pattern)
			rlist.tag=[rlist.tag i];
		end
	end	
	rlist.tag=unique(rlist.tag);
end
UpdateFileList;

% --- Executes on button press in RepGenerate2.
function RepGenerate2_Callback(hObject, eventdata, handles)
% hObject    handle to RepGenerate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rlist;
out=['reportSD.' rlist.format];
[fn,pn]=uiputfile('*.*','File to Save Report in',out);
rlist.fn=fn;
rlist.pn=pn;
save([rlist.basepath  'report.mat'], 'rlist');
reportout=['-o' rlist.pn rlist.fn];
reporttype=['-f' rlist.format];
report('spikereportSD',reportout,reporttype);

% --- Executes on button press in RepPlotISICheck.
function RepPlotISICheck_Callback(hObject, eventdata, handles)
% hObject    handle to RepPlotISICheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RepPlotPSTHCheck
global rlist;

if isempty(rlist.tag)
	rlist.item{rlist.index}.plotisi=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.plotisi=get(hObject,'Value');
	end
end	

% --- Executes on selection change in RepErrorMenu.
function RepErrorMenu_Callback(hObject, eventdata, handles)
% hObject    handle to RepErrorMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RepErrorMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RepErrorMenu
global rlist;

if isempty(rlist.tag)
	rlist.item{rlist.index}.errormethod=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.errormethod=get(hObject,'Value');
	end
end

% --- Executes on button press in RepHoldCheck.
function RepHoldCheck_Callback(hObject, eventdata, handles)
% hObject    handle to RepHoldCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RepHoldCheck
global rlist

if isempty(rlist.tag)
	rlist.item{rlist.index}.hold=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.hold=get(hObject,'Value');
	end
end	
if rlist.item{rlist.index}.hold==1
    set(gh('RepHoldValX'),'Enable','on');
    set(gh('RepHoldValY'),'Enable','on');
    set(gh('RepHoldValZ'),'Enable','on');
else
    set(gh('RepHoldValX'),'Enable','off');
    set(gh('RepHoldValY'),'Enable','off');
    set(gh('RepHoldValZ'),'Enable','off');
end

function RepHoldValX_Callback(hObject, eventdata, handles)
% hObject    handle to RepHoldValX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepHoldValX as text
%        str2double(get(hObject,'String')) returns contents of RepHoldValX as a double
global rlist

if isempty(rlist.tag)
	rlist.item{rlist.index}.holdvalx=str2double(get(hObject,'String'));
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.holdvalx=str2double(get(hObject,'String'));
	end
end	

function RepHoldValY_Callback(hObject, eventdata, handles)
% hObject    handle to RepHoldValY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepHoldValY as text
%        str2double(get(hObject,'String')) returns contents of RepHoldValY as a double
global rlist

if isempty(rlist.tag)
	rlist.item{rlist.index}.holdvaly=str2double(get(hObject,'String'));
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.holdvaly=str2double(get(hObject,'String'));
	end
end	

function RepHoldValZ_Callback(hObject, eventdata, handles)
% hObject    handle to RepHoldValZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepHoldValZ as text
%        str2double(get(hObject,'String')) returns contents of RepHoldValZ as a double
global rlist

if isempty(rlist.tag)
	rlist.item{rlist.index}.holdvalz=str2double(get(hObject,'String'));
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.holdvalz=str2double(get(hObject,'String'));
	end
end	

% --- Executes on selection change in RepPlotMenu.
function RepPlotMenu_Callback(hObject, eventdata, handles)
% hObject    handle to RepPlotMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RepPlotMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RepPlotMenu
global rlist;

if isempty(rlist.tag)
	rlist.item{rlist.index}.plotmethod=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.plotmethod=get(hObject,'Value');
	end
end

% --- Executes on button press in RepCutTransient.
function RepCutTransient_Callback(hObject, eventdata, handles)
% hObject    handle to RepCutTransient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RepCutTransient
global rlist;

if isempty(rlist.tag)
	rlist.item{rlist.index}.cuttransient=get(hObject,'Value');
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.cuttransient=get(hObject,'Value');
	end
end


function RepCutAmount_Callback(hObject, eventdata, handles)
% hObject    handle to RepCutAmount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepCutAmount as text
%        str2double(get(hObject,'String')) returns contents of RepCutAmount as a double
global rlist;

if isempty(rlist.tag)
	rlist.item{rlist.index}.cutamount=str2double(get(hObject,'String'));
else
	for i=1:length(rlist.tag)
		rlist.item{rlist.tag(i)}.cutamount=str2double(get(hObject,'String'));
	end
end

% --- Executes on button press in RepSaveMatFiles.
function RepSaveMatFiles_Callback(hObject, eventdata, handles)
% hObject    handle to RepSaveMatFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RepSaveMatFiles
global rlist;
rlist.saveMatFiles = get(hObject,'Value');