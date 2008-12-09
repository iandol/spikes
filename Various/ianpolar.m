function hpol = ianpolar(varargin)
%IANPOLAR  Polar coordinate plot.
%   POLAR(THETA, RHO) makes a plot using polar coordinates of
%   the angle THETA, in radians, versus the radius RHO.
%   POLAR(THETA,RHO,S) uses the linestyle specified in string S.
%   See PLOT for a description of legal linestyles.
%
%   POLAR(AX,...) plots into AX instead of GCA.
%
%   H = POLAR(...) returns a handle to the plotted object in H.
%
%   Example:
%      t = 0:.01:2*pi;
%      polar(t,sin(2*t).*cos(2*t),'--r')
%
%   See also PLOT, LOGLOG, SEMILOGX, SEMILOGY.

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,5,nargs,'struct'));

if nargs < 1 || nargs > 5
    error('MATLAB:polar:InvalidInput', 'Requires 2 to 5 data arguments.')
elseif nargs == 2 
    theta = args{1};
    rho = args{2};
	sizevals=100;
	colorvals=[0 0 0];
    if ischar(rho)
        line_style = rho;
        rho = theta;
        [mr,nr] = size(rho);
        if mr == 1
            theta = 1:nr;
        else
            th = (1:mr)';
            theta = th(:,ones(1,nr));
        end
    else
        line_style = 'ko';
	end
	setting.scalesize=0;
	settings.changecolour=0;
	settings.filled=1;
elseif nargs == 1
    theta = args{1};
    line_style = 'ko';
    rho = ones(length(theta),1);
	sizevals=100;
	colorvals=[0 0 0];
    [mr,nr] = size(rho);
    if mr == 1
        theta = 1:nr;
    else
        th = (1:mr)';
        theta = th(:,ones(1,nr));
	end
	settings.scalesize=0;
	settings.changecolour=0;
	settings.filled='filled';
elseif nargs == 3 % nargs == 3
    [theta,rho,sizevals] = deal(args{1:3});
	sizevals=(sizevals./max(sizevals))*100;
	colorvals=[0 0 0];
	settings.scalesize=0;
	settings.changecolour=0;
	settings.filled='filled';
elseif nargs == 4 % nargs == 4
    [theta,rho,sizevals,colorvals] = deal(args{1:4});
	sizevals=(sizevals./max(sizevals))*100;
	settings.changecolour=0;
	settings.filled='filled';
elseif nargs == 5
	[theta,rho,sizevals,colorvals,settings] = deal(args{1:5});
	if ~isfield(settings,'changecolour')
		settings=struct('changecolour',0);
	end
	if isfield(settings,'scalesize')
		if settings.scalesize==1
			sizevals=(sizevals./max(sizevals))*100;
		end
	end
	if ~isfield(settings,'filled')
		settings=struct('filled','filled');
	end
end

if ischar(theta) || ischar(rho)
    error('MATLAB:polar:InvalidInputType', 'Input arguments must be numeric.');
end
if ~isequal(size(theta),size(rho))
    error('MATLAB:polar:InvalidInput', 'THETA and RHO must be the same size.');
end

if min(sizevals)<=0
	sizevals(find(sizevals==0))=0.1;
end

if size(colorvals,2)==1 && settings.changecolour==1
	%colorvalsn=zeros(length(colorvals),3);
	for i=1:length(colorvals)
		if colorvals(i)==1
			colorvalsn(i,:)=[0 0 0];
		elseif colorvals(i)==2
			colorvalsn(i,:)=[1 0 0];
		elseif colorvals(i)==3
			colorvalsn(i,:)=[0 0 1];
		elseif colorvals(i)==4
			colorvalsn(i,:)=[0 1 0];
		elseif colorvals(i)==5
			colorvalsn(i,:)=[1 0 1];
		else
			colorvalsn(i,:)=[0.5 0.5 0.5];
		end
	end
	colorvals=colorvalsn;
end


% get hold state
cax = newplot(cax);

next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

% get x-axis text color so grid is in same color
tc = get(cax,'xcolor');
ls = get(cax,'gridlinestyle');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle  = get(cax, 'DefaultTextFontAngle');
fName   = get(cax, 'DefaultTextFontName');
fSize   = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits  = get(cax, 'DefaultTextUnits');
set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
    'DefaultTextFontName',   get(cax, 'FontName'), ...
    'DefaultTextFontSize',   get(cax, 'FontSize'), ...
    'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
    'DefaultTextUnits','data')

% only do grids if hold is off
if ~hold_state

% make a radial grid
    hold(cax,'on');
% ensure that Inf values don't enter into the limit calculation.
    arho = abs(rho(:));
    maxrho = max(arho(arho ~= Inf));
    hhh=line([-maxrho -maxrho maxrho maxrho],[-maxrho maxrho maxrho -maxrho],'parent',cax);
    set(cax,'dataaspectratio',[1 1 1],'plotboxaspectratiomode','auto')
    v = [get(cax,'xlim') get(cax,'ylim')];
    ticks = sum(get(cax,'ytick')>=0);
    delete(hhh);
% check radial limits and ticks
    rmin = 0; rmax = v(4); rticks = max(ticks-1,2);
    if rticks > 5   % see if we can reduce the number
        if rem(rticks,2) == 0
            rticks = rticks/2;
        elseif rem(rticks,3) == 0
            rticks = rticks/3;
        end
    end

% define a circle
    th = 0:pi/50:2*pi;
    xunit = cos(th);
    yunit = sin(th);
% now really force points on x/y axes to lie on them exactly
    inds = 1:(length(th)-1)/4:length(th);
    xunit(inds(2:2:4)) = zeros(2,1);
    yunit(inds(1:2:5)) = zeros(3,1);
% plot background if necessary
    if ~ischar(get(cax,'color')),
       patch('xdata',xunit*rmax,'ydata',yunit*rmax, ...
             'edgecolor',tc,'facecolor',get(cax,'color'),...
             'handlevisibility','off','parent',cax);
    end

% draw radial circles
    c82 = cos(82*pi/180);
    s82 = sin(82*pi/180);
    rinc = (rmax-rmin)/rticks;
    for i=(rmin+rinc):rinc:rmax
        hhh = line(xunit*i,yunit*i,'linestyle',ls,'color',tc,'linewidth',1,...
                   'handlevisibility','off','parent',cax);
        text((i+rinc/20)*c82,(i+rinc/20)*s82, ...
            ['  ' num2str(i)],'verticalalignment','bottom',...
            'handlevisibility','off','parent',cax)
    end
    set(hhh,'linestyle','-') % Make outer circle solid

% plot spokes
    th = (1:6)*2*pi/12;
    cst = cos(th); snt = sin(th);
    cs = [-cst; cst];
    sn = [-snt; snt];
    line(rmax*cs,rmax*sn,'linestyle',ls,'color',tc,'linewidth',1,...
         'handlevisibility','off','parent',cax)

% annotate spokes in degrees
    rt = 1.1*rmax;
    for i = 1:length(th)
        text(rt*cst(i),rt*snt(i),int2str(i*30),...
             'horizontalalignment','center',...
             'handlevisibility','off','parent',cax);
        if i == length(th)
            loc = int2str(0);
        else
            loc = int2str(180+i*30);
        end
        text(-rt*cst(i),-rt*snt(i),loc,'horizontalalignment','center',...
             'handlevisibility','off','parent',cax)
    end

% set view to 2-D
    view(cax,2);
% set axis limits
    axis(cax,rmax*[-1 1 -1.15 1.15]);
end

% Reset defaults.
set(cax, 'DefaultTextFontAngle', fAngle , ...
    'DefaultTextFontName',   fName , ...
    'DefaultTextFontSize',   fSize, ...
    'DefaultTextFontWeight', fWeight, ...
    'DefaultTextUnits',fUnits );

% transform data to Cartesian coordinates.
xx = rho.*cos(theta);
yy = rho.*sin(theta);

q = scatter(xx,yy,sizevals,colorvals,settings.filled);

set(get(gca,'Children'),'MarkerEdgeColor',[0 0 0])

if nargout == 1
    hpol = q;
end

if ~hold_state
    set(cax,'dataaspectratio',[1 1 1]), axis(cax,'off'); set(cax,'NextPlot',next);
end
set(get(cax,'xlabel'),'visible','on')
set(get(cax,'ylabel'),'visible','on')

if ~isempty(q) && ~isdeployed
    makemcode('RegisterHandle',cax,'IgnoreHandle',q,'FunctionName','polar');
end
