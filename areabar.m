function areabar(xvalues,ydata,error,c1,varargin)

%Plots X and Y value data with error bar shown as a shaded
%area. Use:
%
% areabar(x,y,error,c1,plotoptions)
%
%     where c1 is the colour of the shaded options and plotoptions are
%     passed to the line plot

if min(size(xvalues)) > 1 || min(size(ydata)) > 1 || min(size(error)) > 1
   errordlg('Sorry, you can only plot vector data.')
   error('Areabar error')
end

if nargin <4 || isempty(c1)
	c1=[0.8 0.8 0.8];
end

alpha = 0.8;

x=size(xvalues);
y=size(ydata);
e=size(error);

if x(1) < x(2)             %need to organise to row
   xvalues=xvalues';
end
if y(1) < y(2)             %need to organise to row
   ydata=ydata';
end
if y(1) < y(2)             %need to organise to row
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
fill(areax,err,c1,'EdgeColor',c1,'FaceAlpha',alpha);
set(gca,'NextPlot','add');
plot(xvalues,ydata,varargin{:});
set(gca,'NextPlot','replacechildren');
set(gca,'PlotBoxAspectRatioMode','manual');
hold off;

