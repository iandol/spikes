function fig = vs()
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

load vs

h0 = figure('Color',[0.8 0.8 0.8], ...
	'Colormap',mat0, ...
	'FileName','D:\Matlab\user\vs.m', ...
	'MenuBar','none', ...
	'NumberTitle','off', ...
	'PaperPosition',[18 180 576 432], ...
	'PaperType','a4letter', ...
	'PaperUnits','points', ...
	'Position',[366 168 426 528], ...
	'RendererMode','manual', ...
	'Tag','Fig1', ...
	'ToolBar','none');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontName','Arial Black', ...
	'FontSize',22, ...
	'ListboxTop',0, ...
	'Position',[0 359.25 318 30], ...
	'String','VS-Analysis Routines V2.2', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','h=gcf;close(h);vsplot(''Initialize'');', ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[24 297.75 108.75 25.5], ...
	'String','One Independant Variable', ...
	'Tag','Pushbutton1', ...
	'TooltipString','For processing of single variable raw VS text files');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','h=gcf;close(h);vsrfplot(''Initialize'');', ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[186.75 299.25 108.75 25.5], ...
	'String','Two Independant Variables', ...
	'Tag','Pushbutton1', ...
	'TooltipString','For processing of 2 variable raw VS text files (e.g RF maps, up to 3 cells)');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','h=gcf;close(h);temporal(''Initialize'');', ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[24 222 108.75 25.5], ...
	'String','Temporal Analysis', ...
	'Tag','Pushbutton1', ...
	'TooltipString','Temporal analysis based on the VS temporal scripts');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','close', ...
	'FontAngle','italic', ...
	'FontName','Arial', ...
	'FontSize',9, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[104.625 7.5 108.75 25.5], ...
	'String','Exit Analysis Menu', ...
	'Tag','Pushbutton1', ...
	'TooltipString','bye bye...');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','h=gcf;close(h);metanal(''Initialize'');', ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[186.75 222 108.75 25.5], ...
	'String','Meta-Analysis', ...
	'Tag','MetaButton', ...
	'TooltipString','Performs meta-analysis for tuning curve data');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','h=gcf;close(h);gettst2;', ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[186.75 144.75 108.75 25.5], ...
	'String','George Analysis', ...
	'Tag','MetaButton', ...
	'TooltipString','Georges Centroid plotting program');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','h=gcf;close(h);psthread;', ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[24 183.75 108.75 25.5], ...
	'String','Phase Plotter', ...
	'Tag','MetaButton', ...
	'TooltipString','Plots PSTH''s from VS and fits beat waveforms/ does fourier harmonic analysis');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback',mat1, ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[186.75 261 108.75 25.5], ...
	'String','Cross-Correlation Suite', ...
	'Tag','MetaButton', ...
	'TooltipString',mat2);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','h=gcf;close(h);gdef;', ...
	'FontAngle','italic', ...
	'FontName','Arial', ...
	'FontSize',9, ...
	'ListboxTop',0, ...
	'Position',[186.75 55.5 108.75 25.5], ...
	'String','Change Graphic Defaults', ...
	'Tag','MetaButton', ...
	'TooltipString','Change Matlab Default Options');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback',mat3, ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[186.75 183.75 108.75 25.5], ...
	'String','Cortical Cell Modeller', ...
	'Tag','MetaButton', ...
	'TooltipString',mat4);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback',mat5, ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[24 260.25 108.75 25.5], ...
	'String','Spike Analysis', ...
	'Tag','MetaButton', ...
	'TooltipString',mat6);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[3 351 312 5.25], ...
	'Style','frame', ...
	'Tag','Frame1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontName','Arial', ...
	'FontSize',12, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[99.375 329.25 119.25 20.25], ...
	'String','Main Programs:', ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[3 99.75 312 5.25], ...
	'Style','frame', ...
	'Tag','Frame1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontName','Arial', ...
	'FontSize',12, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[105 83.25 108 14.25], ...
	'String','Utilities:', ...
	'Style','text', ...
	'Tag','StaticText3');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','cellsep', ...
	'FontAngle','italic', ...
	'FontName','Arial', ...
	'FontSize',9, ...
	'ListboxTop',0, ...
	'Position',[24 55.5 108.75 25.5], ...
	'String','Find Linking Angle', ...
	'Tag','MetaButton', ...
	'TooltipString',mat7);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[3 44.25 312 5.25], ...
	'Style','frame', ...
	'Tag','Frame1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','h=gcf;close(h);drawphase;', ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[24 144 108.75 25.5], ...
	'String','Phase Modeller', ...
	'Tag','MetaButton', ...
	'TooltipString','Models Phase interactions between centre/surround linearly');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.76 0.76 0.76], ...
	'Callback','h=gcf;close(h);cfit;', ...
	'FontName','Arial', ...
	'ListboxTop',0, ...
	'Position',[104.625 111 108.75 25.5], ...
	'String','Drug Curve Comparison', ...
	'Tag','MetaButton', ...
	'TooltipString','Georges Centroid plotting program');
if nargout > 0, fig = h0; end
