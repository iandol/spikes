function handles = areabar(xvalues,ydata,error,c1,alpha,varargin)

%Plots X and Y value data with error bar shown as a shaded
%area. Use:
%
% areabar(x,y,error,c1,alpha,plotoptions)
%
%     where c1 is the colour of the shaded options and plotoptions are
%     passed to the line plot

if min(size(xvalues)) > 1 || min(size(ydata)) > 1 || min(size(error)) > 1
   errordlg('Sorry, you can only plot vector data.')
   error('Areabar error');
end

if nargin <4 || isempty(c1)
	c1=[0.7 0.7 0.7];
end

if nargin < 5 || isempty(alpha) || ischar(alpha)
	if exist('alpha','var') && ischar(alpha)
		[varargin{2:end+1}]=varargin{1:end};
		varargin{1} = alpha;
	end
	alpha = 1;
end

if nargin < 6 && isempty(varargin)
	varargin{1} = 'k-o';
	varargin{2} = 'MarkerFaceColor';
	varargin{3} = [0 0 0];
end

x=size(xvalues);
y=size(ydata);
e=size(error);

if x(1) < x(2)             %need to organise to row
   xvalues=xvalues';
end
if y(1) < y(2)             %need to organise to row
   ydata=ydata';
end
if e(1) < e(2)             %need to organise to row
   error=error';
end

x=length(xvalues);
err=zeros(x+x,1);
err(1:x,1)=ydata+error;
err(x+1:x+x,1)=flipud(ydata-error);
areax=zeros(x+x,1);
areax(1:x,1)=xvalues;
areax(x+1:x+x,1)=flipud(xvalues);
axis auto
handles.fill = fill(areax,err,c1,'EdgeColor','none','FaceAlpha',alpha);
set(gca,'NextPlot','add');
handles.plot = plot(xvalues,ydata,varargin{:});
set(gca,'NextPlot','replacechildren');
%set(gca,'PlotBoxAspectRatioMode','manual');
set(gca,'Layer','top');
set(gcf,'Renderer','painters');
box on;