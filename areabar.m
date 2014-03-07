function handles = areabar(xvalues,ydata,error,c1,alpha,varargin)

%Plots X and Y value data with error bar shown as a shaded
%area. Use:
%
% areabar(x,y,error,c1,alpha,plotoptions)
%
%     where c1 is the colour of the shaded options and plotoptions are
%     passed to the line plot

if min(size(xvalues)) > 1 || min(size(ydata)) > 1 || min(size(error)) > 2
   warning('Sorry, you can only plot vector data.')
   error('Areabar error');
end

if strcmpi(get(gca,'NextPlot'),'add')
	NextPlot = 'add';
else
	NextPlot = 'replacechildren';
end

if nargin <4 || isempty(c1)
	c1=[0.5 0.5 0.5];
end

if nargin < 5 || isempty(alpha) || ischar(alpha)
	if exist('alpha','var') && ischar(alpha)
		[varargin{2:end+1}]=varargin{1:end};
		varargin{1} = alpha;
	end
	alpha = 0.5;
end

if nargin < 6 && isempty(varargin)
	varargin{1} = 'k-o';
	varargin{2} = 'MarkerFaceColor';
	varargin{3} = [0 0 0];
end

idx=find(isnan(ydata));
ydata(idx)=[];
xvalues(idx)=[];
error(idx)=[];

x=size(xvalues);
y=size(ydata);
e=size(error);

%need to organise to rows
if x(1) < x(2); xvalues=xvalues'; end
if y(1) < y(2); ydata=ydata'; end
if e(1) < e(2); error=error'; end

error(isnan(error)) = 0;

x=length(xvalues);
if size(error,2) == 2
	err=zeros(x+x,1);
	err(1:x,1)=error(:,1);
	err(x+1:x+x,1)=flipud(error(:,2));
else
	err=zeros(x+x,1);
	err(1:x,1)=ydata+error;
	err(x+1:x+x,1)=flipud(ydata-error);
end
areax=zeros(x+x,1);
areax(1:x,1)=xvalues;
areax(x+1:x+x,1)=flipud(xvalues);
axis auto
if max(c1) > 1; c1 = c1 / max(c1); end
handles.fill = fill(areax,err,c1,'EdgeColor','none','FaceAlpha',alpha);
set(gca,'NextPlot','add');
handles.plot = plot(xvalues,ydata,varargin{:});
set(get(get(handles.plot,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
set(gca,'NextPlot',NextPlot);
%set(gca,'PlotBoxAspectRatioMode','manual');
uistack(handles.plot,'top')
set(gca,'Layer','top');
if alpha == 1; set(gcf,'Renderer','painters'); end
box on;