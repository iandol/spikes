function fig = drawphasefig()
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

load drawphasefig

h0 = figure('Color',[0.8 0.8 0.8], ...
	'Colormap',mat0, ...
	'FileName','D:\Matlab\user\drawphasefig.m', ...
	'MenuBar','none', ...
	'NumberTitle','off', ...
	'PaperPosition',[18 180 576 432], ...
	'PaperType','A4', ...
	'PaperUnits','points', ...
	'Position',[355 146 650 542], ...
	'Resize','off', ...
	'Tag','Fig1', ...
	'ToolBar','none');
h1 = axes('Parent',h0, ...
	'Units','pixels', ...
	'Box','on', ...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[1 1 1], ...
	'ColorOrder',mat1, ...
	'Position',[80 164 493 362], ...
	'Tag','Axes1', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.4979674796747968 -0.0664819944598336 9.160254037844386], ...
	'Tag','Axes1Text4', ...
	'VerticalAlignment','cap');
set(get(h2,'Parent'),'XLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[-0.0589430894308943 0.4958448753462604 9.160254037844386], ...
	'Rotation',90, ...
	'Tag','Axes1Text3', ...
	'VerticalAlignment','baseline');
set(get(h2,'Parent'),'YLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','right', ...
	'Position',[-0.1626016260162602 1.044321329639889 9.160254037844386], ...
	'Tag','Axes1Text2', ...
	'Visible','off');
set(get(h2,'Parent'),'ZLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',mat2, ...
	'Tag','Axes1Text1', ...
	'VerticalAlignment','bottom');
set(get(h2,'Parent'),'Title',h2);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'ListboxTop',0, ...
	'Position',[1.5 0.75 479.25 105], ...
	'Style','frame', ...
	'Tag','Frame2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'ListboxTop',0, ...
	'Position',[260.25 84.74999999999999 110.25 15], ...
	'String','Outer Frequency (Hz)', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'ListboxTop',0, ...
	'Position',[260.25 68.69999999999999 110.25 15], ...
	'String','Centre Phase (deg)', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','drawphase(''Phase'');', ...
	'FontSize',10, ...
	'ListboxTop',0, ...
	'Position',[189 84.75 69.75 15], ...
	'String','4', ...
	'Style','edit', ...
	'Tag','EditFrequency');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','drawphase(''Phase'');', ...
	'FontSize',10, ...
	'ListboxTop',0, ...
	'Position',[189 69 69.75 15], ...
	'String','0', ...
	'Style','edit', ...
	'Tag','EditPhase');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback',mat3, ...
	'ListboxTop',0, ...
	'Position',[420.75 8.25 56.25 18.75], ...
	'String','Exit', ...
	'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','drawphase(''Loop'');', ...
	'ListboxTop',0, ...
	'Position',[421.5 52.5 54.75 18.75], ...
	'String','Loop', ...
	'Tag','Pushbutton2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontName','Arial', ...
	'FontSize',6, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[3.75 4.5 126 93.75], ...
	'String',mat4, ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'Callback','drawphase(''Spawn'');', ...
	'ListboxTop',0, ...
	'Position',[421.5 30 54.75 18.75], ...
	'String','Spawn', ...
	'Tag','Pushbutton2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','drawphase(''Phase'');', ...
	'FontSize',10, ...
	'ListboxTop',0, ...
	'Position',[189 36.75 69.75 15], ...
	'String','-0.5', ...
	'Style','edit', ...
	'Tag','EditLevel', ...
	'TooltipString','Edit the rectify level between -1and 1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'ListboxTop',0, ...
	'Position',[260.25 36.59999999999999 110.25 15], ...
	'String','Input Rectification Level', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'ListboxTop',0, ...
	'Position',[4.5 2.25 180 14.25], ...
	'String','Rectify Centre/Surround Before Calculation?', ...
	'Style','checkbox', ...
	'Tag','RectifyBox', ...
	'TooltipString','Do, or don''t rectify, depending on hypothesis', ...
	'UserData','[ ]', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','drawphase(''Phase'');', ...
	'FontSize',10, ...
	'ListboxTop',0, ...
	'Position',[189 53.25 69.75 15], ...
	'String','0', ...
	'Style','edit', ...
	'Tag','EditPhase2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'ListboxTop',0, ...
	'Position',[260.25 52.64999999999999 110.25 15], ...
	'String','Surround Phase (deg)', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','drawphase(''Phase'');', ...
	'FontSize',10, ...
	'ListboxTop',0, ...
	'Position',[189 21 69.75 15], ...
	'String','0', ...
	'Style','edit', ...
	'Tag','EditLevel2', ...
	'TooltipString','Edit the rectify level between -1and 1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'ListboxTop',0, ...
	'Position',[260.25 20.55 110.25 15], ...
	'String','Output Rectification Level', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','drawphase(''Phase'');', ...
	'FontSize',10, ...
	'ListboxTop',0, ...
	'Position',[189 4.5 69.75 15], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','EditStrength', ...
	'TooltipString','Edit the strength; 1=equal');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'ListboxTop',0, ...
	'Position',[260.25 4.5 110.25 15], ...
	'String','Strength of Surround', ...
	'Style','text', ...
	'Tag','StaticText1');
if nargout > 0, fig = h0; end
