function fig = TCPlotFigure()
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

load TCPlotFigure

h0 = figure('Color',[1 1 1], ...
	'Colormap',mat0, ...
	'FileName','D:\Matlab\user\TCPlotFigure.m', ...
	'MenuBar','none', ...
	'Name','Tuning Curve Plot Window', ...
	'NumberTitle','off', ...
	'PaperPosition',[18 180 576 432], ...
	'PaperUnits','points', ...
	'Position',[345 150 514 543], ...
	'Resize','off', ...
	'Tag','TCPlotFigure', ...
	'ToolBar','none');
h1 = axes('Parent',h0, ...
	'Units','pixels', ...
	'Box','on', ...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[1 1 1], ...
	'ColorOrder',mat1, ...
	'LineWidth',1.5, ...
	'NextPlot','replacechildren', ...
	'Position',[49 110 443 405], ...
	'Tag','TCurvePlotAxis', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.497737556561086 -0.05940594059405946 9.160254037844386], ...
	'Tag','Axes1Text4', ...
	'VerticalAlignment','cap');
set(get(h2,'Parent'),'XLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[-0.0656108597285068 0.4975247524752475 9.160254037844386], ...
	'Rotation',90, ...
	'Tag','Axes1Text3', ...
	'VerticalAlignment','baseline');
set(get(h2,'Parent'),'YLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','right', ...
	'Position',mat2, ...
	'Tag','Axes1Text2', ...
	'Visible','off');
set(get(h2,'Parent'),'ZLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',mat3, ...
	'Tag','Axes1Text1', ...
	'VerticalAlignment','bottom');
set(get(h2,'Parent'),'Title',h2);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'FontName','Helvetica', ...
	'FontSize',12, ...
	'ListboxTop',0, ...
	'Position',[18.75 25.5 126 18.75], ...
	'String','Optimum ... is ...', ...
	'Style','text', ...
	'Tag','PlotOptimumBox');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'FontName','Helvetica', ...
	'FontSize',12, ...
	'ListboxTop',0, ...
	'Position',[252 30.75 123 19.5], ...
	'String','HwHH', ...
	'Style','text', ...
	'Tag','PlotHwHHBox');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'FontName','Helvetica', ...
	'FontSize',12, ...
	'ListboxTop',0, ...
	'Position',[252 6.75 123 19.5], ...
	'String','HwHH', ...
	'Style','text', ...
	'Tag','PlotUserHwHHBox');
if nargout > 0, fig = h0; end
