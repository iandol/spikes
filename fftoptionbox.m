function fig = fftoptionbox()
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
% This problem is solved by saving the output as a FIG-file.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.
% 
% NOTE: certain newer features in MATLAB may not have been saved in this
% M-file due to limitations of this format, which has been superseded by
% FIG-files.  Figures which have been annotated using the plot editor tools
% are incompatible with the M-file/MAT-file format, and should be saved as
% FIG-files.

mat1='if get(gco,''value'')==1 || (get(gco,''value'')==0  && get(findobj(''tag'',''RatioHarmonic''),''value'')==0);set(findobj(''tag'',''RatioHarmonic''),''value'',0);set(gco,''value'',1);end';
mat2='if get(gco,''value'')==1 | (get(gco,''value'')==0 & get(findobj(''tag'',''SingleHarmonic''),''value'')==0);set(findobj(''tag'',''SingleHarmonic''),''value'',0);set(gco,''value'',1);end';

h0 = figure('Color',[0.8 0.8 0.8], ...
	'FileName','fftoptionbox.m', ...
	'MenuBar','none', ...
	'Name','FFT Options', ...
	'NumberTitle','off', ...
	'PaperPosition',[18 180 576 432], ...
	'PaperUnits','points', ...
	'Position',[0 0 250 300], ...
	'Units','Pixels', ...
	'Resize','off', ...
	'Tag','FFTOptions Figure', ...
	'ToolBar','none');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.85 0.85 0.85], ...
	'ListboxTop',0, ...
	'Position',[0 0 250 300], ...
	'Style','frame', ...
	'Tag','Frame1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.85 0.85 0.85], ...
	'FontWeight','bold', ...
	'ForegroundColor',[0 0 0], ...
	'ListboxTop',0, ...
	'Position',[20 222 70 23], ...
	'String','Temporal Frequency', ...
	'Style','text', ...
	'Tag','Label');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Enable','inactive', ...
	'FontWeight','bold', ...
	'ForegroundColor',[0 0 0], ...
	'ListboxTop',0, ...
	'Position',[100 230 50 20], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','TempFreqBox');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.85 0.85 0.85], ...
	'FontWeight','bold', ...
	'ForegroundColor',[0 0 0], ...
	'ListboxTop',0, ...
	'Position',[160 230 20.25 15], ...
	'String','Hz', ...
	'Style','text', ...
	'Tag','StaticText3');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.85 0.85 0.85], ...
	'Callback',mat1, ...
	'FontWeight','light', ...
	'ListboxTop',0, ...
	'Position',[10 190 110 15], ...
	'String','Single Harmonic', ...
	'Style','radiobutton', ...
	'Tag','SingleHarmonic', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[130 190 60 20], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','SingHarmnBox');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.85 0.85 0.85], ...
	'Callback',mat2, ...
	'ListboxTop',0, ...
	'Position',[10 155 110 15], ...
	'String','Ratio', ...
	'Style','radiobutton', ...
	'Tag','RatioHarmonic');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[100 155 60 20], ...
	'Style','edit', ...
	'Tag','Harmn1Box');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.85 0.85 0.85], ...
	'FontSize',12, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[160 155 9 16.5], ...
	'String','/', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[175 155 60 20], ...
	'Style','edit', ...
	'Tag','Harmn2Box');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.85 0.85 0.85], ...
	'Callback','global choice; choice=1;', ...
	'ListboxTop',0, ...
	'Position',[20 20 200 18], ...
	'String','Continue', ...
	'Tag','FFTContinueButton');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.5 0.5 0.5], ...
	'FontAngle','italic', ...
	'FontName','Helvetica', ...
	'FontSize',12, ...
	'FontWeight','bold', ...
	'ForegroundColor',[1 1 0], ...
	'ListboxTop',0, ...
	'Position',[0 280 250 20], ...
	'String','FFT Options', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.6 0.6 0.6], ...
	'Callback','vshelp(''FFTOpts'')', ...
	'FontName','Helvetica', ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[227 282 15 15], ...
	'String','?', ...
	'Tag','Pushbutton4');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.85 0.85 0.85], ...
	'ListboxTop',0, ...
	'Position',[10 120 150 15], ...
	'String','Infinity Point = (max) x', ...
	'Style','checkbox', ...
	'Tag','SetInfPoint');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[160 120 50 20], ...
	'Style','edit', ...
	'Tag','InfPointBox');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.85 0.85 0.85], ...
	'ListboxTop',0, ...
	'Position',[10 90 120 14.25], ...
	'String','0/0 Point = (-1) x', ...
	'Style','text', ...
	'Tag','SetNaNPoint');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[160 90 50 20], ...
	'Style','edit', ...
	'Tag','ZeroPointBox');
if nargout > 0, fig = h0; end
