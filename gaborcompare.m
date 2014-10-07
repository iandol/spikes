function gaborcompare(action)

%***************************************************************
%
%  Gabor Fit, Computes RF Fits
%
%     Completely GUI, not run-line commands needed
%
% [ian] 1.0 Initial release
%
%***************************************************************

%global data
global gabc

if nargin<1,
    action='Initialize';
end

%%%%%%%%%%%%%%See what dog needs to do%%%%%%%%%%%%%
switch(action)

    %-------------------------------------------------------------------
case 'Initialize'
    %-------------------------------------------------------------------
	
	gabversion='1.6';
	gabc=[];
	gaborcompare_UI;
	gabc.storeval=0;
	gabc.storedp=[];
    version=['GABOR-Compare V', gabversion, ' | Started on ', datestr(now)];
    set(0,'DefaultAxesLayer','top');
	set(0,'DefaultAxesTickDir','out');
    set(gcf,'Name', version);
    set(gh('GBInfoText'),'String','Welcome to the GABOR Compare.');
	colormap(rbmap);
	
	plotgaussian;
	plotgabor;
	makeoutput;
	comparefields;
		
    %-------------------------------------------------------------------
case 'RePlot'
    %-------------------------------------------------------------------

	set(gh('GCoutputtext'),'String','Please wait...');
	plotgaussian;
	plotgabor;	
	makeoutput;
	comparefields;
	
    %-------------------------------------------------------------------
case 'RePlot Gauss'
    %-------------------------------------------------------------------

	set(gh('GCoutputtext'),'String','Please wait...');
	plotgaussian;
	makeoutput;
	comparefields;

    %-------------------------------------------------------------------
case 'RePlot Gabor'
    %-------------------------------------------------------------------

	set(gh('GCoutputtext'),'String','Please wait...');
	plotgabor;
	makeoutput;
  	comparefields;
	
    %-------------------------------------------------------------------
case 'RePlot Output'
    %-------------------------------------------------------------------

	set(gh('GCoutputtext'),'String','Please wait...');
	makeoutput;
	comparefields;
	
  %-------------------------------------------------------------------
case 'StoreDP'
  %-------------------------------------------------------------------
	
	gabc.storedp=gabc.currentdp;
	comparefields;
	
  %-------------------------------------------------------------------
case 'ResetDP'
  %-------------------------------------------------------------------

	gabc.storedp=[];
	comparefields;
	
    %-------------------------------------------------------------------
case 'StoreIt'
    %-------------------------------------------------------------------
	
	getstate;
	
	if isfield(gabc,'storeval')
		gabc.storeval=gabc.storeval+1;
	else
		gabc.storeval=1;
	end
	gabc.store(gabc.storeval).xmin=gabc.xmin;
	gabc.store(gabc.storeval).xmax=gabc.xmax;
	gabc.store(gabc.storeval).ymin=gabc.ymin;
	gabc.store(gabc.storeval).ymax=gabc.ymax;
	gabc.store(gabc.storeval).steps=gabc.steps;
	gabc.store(gabc.storeval).xpos=gabc.xpos;
	gabc.store(gabc.storeval).ypos=gabc.ypos;
	gabc.store(gabc.storeval).width=gabc.width;
	gabc.store(gabc.storeval).spont=gabc.spont;
	
	newitem=[gabc.store(gabc.storeval).title];
	history=get(gh('GCHistory'),'String');
	if ischar(history)
		history={history};
	end
	if gabc.storeval==1
		newitems=newitem;
	else
		newitems=[history;newitem];
	end
	set(gh('GCHistory'),'String',newitems);
	set(gh('GCHistory'),'Value',gabc.storeval);
	
  %-------------------------------------------------------------------
case 'GetHistory'
    %-------------------------------------------------------------------
	
	val=get(gh('GCHistory'),'Value');
	lb=gabc.store(val).lb;
	ub=gabc.store(val).ub;
	xo=gabc.store(val).xo;
	
	if ~isfield(gabc,'spont')
		gabc.spont=0;
	end

	setstate(lb,ub,xo);	
	
	gabc.storecurrent=val;
	

    %-------------------------------------------------------------------
case 'Load Data'
    %-------------------------------------------------------------------

	clear gabc;
    uiload;
	
	if ~isfield(gabc,'spont')
		gabc.spont=0;
	end
	
   setstate;   
   
   plotgaussian;
   plotgabor;
   makeoutput;
   comparefields;
   
    %-------------------------------------------------------------------
case 'Save Data'
    %-------------------------------------------------------------------

    uisave('gabc')

    %-------------------------------------------------------------------
case 'Spawn'
    %-------------------------------------------------------------------

	map=colormap;
	pos=get(gcf,'Position');
	axes(gh('GCAxis1'));
	h(1)=gca;
	axes(gh('GCAxis2'));
	h(2)=gca;
	axes(gh('GCAxis3'));
	h(3)=gca;

	hnew=figure;
	whitebg(hnew);
	set(gcf,'Units','Characters');
	set(gcf,'Position',pos);
	c=copyobj(h,hnew, 'legacy');
	set(c,'Tag',' ');
	set(c,'UserData','');
	colormap(map);
	suplabel([gabc.string]);
	
    %-------------------------------------------------------------------
case 'Spawn Gaussian'
    %-------------------------------------------------------------------
	
	axes(gh('GCAxis1'));
	h=gca;		
	hnew=figure;
	%whitebg(hnew,[1 1 1]);
	docontour=get(gh('GCcontourplot'),'Value');
	if docontour==0
		if get(gh('GCgaussinvert'),'Value')==0
			cmap=zeros(256,3);
			cmap(:,1)=linspace(0,1,256);
			colormap(cmap);
		else
			cmap=zeros(256,3);
			cmap(:,3)=linspace(0,1,256);
			colormap(cmap);
		end
	else
		colormap([0 0 0;0 0 0;0 0 0]);
	end
	set(gcf,'Units','Normalized');
	set(gcf,'Position',[0.1 0.1 0.7 0.7]);
	c=copyobj(h,hnew, 'legacy');
	set(c,'Units','Normalized');
	set(c,'Position',[0.1 0.1 0.8 0.8]);
	set(c,'Tag','');
	set(c,'UserData','');
	xlabel('X Position (deg)');
	ylabel('Y Position (deg)');
	colorbar;
	
    %-------------------------------------------------------------------
case 'Spawn Output'
    %-------------------------------------------------------------------
	
	axes(gh('GCAxis3'));
	cmap=colormap;
	h=gca;		
	hnew=figure;
	whitebg(hnew,[1 1 1]);
	set(gcf,'Units','Normalized');
	set(gcf,'Position',[0.1 0.1 0.7 0.7]);
	c=copyobj(h,hnew, 'legacy');
	set(c,'Units','Normalized');
	set(c,'Position',[0.1 0.1 0.8 0.8]);
	set(c,'Tag','');
	set(c,'UserData','');
	xlabel('X Position (deg)');
	ylabel('Y Position (deg)');
	colormap(cmap);
	colorbar;

    %--------------------------------------------------
end %end of main program switch
	%--------------------------------------------------


% ------------------------------Plots the GABOR--------------------------------------
% --------------------------------------------------------------------------------------
function plotgabor()

	global gabc

	getstate;
			
	gabc.gabordata=gabor(gabc.xvals,gabc.yvals,gabc.gabo(1),gabc.gabo(2),gabc.gabo(3),gabc.gabo(4),gabc.gabo(5),gabc.gabo(6),gabc.gabo(7),gabc.gabo(8));
	
	if get(gh('GCgaborzero'),'Value')==0
		gabc.gabordata=gabc.gabordata-min(min(gabc.gabordata));
	end
	gabc.gabordata=(gabc.gabordata/max(max(gabc.gabordata)))*100;
		
	doplot('gabor');
	
% ------------------------------Plots the Gaussian--------------------------------------
% --------------------------------------------------------------------------------------
function plotgaussian()

	global gabc

	getstate;
	
	p(1)=100;
	p(2)=gabc.xpos;
	p(3)=gabc.ypos;
	p(4)=gabc.width;
	p(5)=gabc.spont;
	
	gabc.gaussdata=gauss(p,gabc.xvals,gabc.yvals);
	
	if gabc.spont==0
		gabc.gaussdata=gabc.gaussdata-min(min(gabc.gaussdata));
	end
	gabc.gaussdata=(gabc.gaussdata/max(max(gabc.gaussdata)))*100;
	
	if get(gh('GCgausscutoff'),'Value')==1
		cutoff=str2num(get(gh('GCcutoff'),'String'));
		gabc.gaussdata(find(gabc.gaussdata<cutoff))=0;
	end
	
	doplot('gauss');
	
%============================================================
%
%============================================================
function makeoutput()

global gabc;

cutoff=str2num(get(gh('GCcutoff'),'String'));
gabc.cutoff=cutoff;

clip=gabc.gabordata;
clip=clip/max(clip(:));

if get(gh('GCplateauoverride'),'Value')==0
	c1 = clip(1,1);
	c2 = clip(1,end);
	c3 = clip(end,1);
	c4 = clip(end,end);

	med=median([c1 c2 c3 c4]);

	if (c1>med+0.02 || c1<med-0.02)
		c1=med;
	end
	if (c2>med+0.02 || c2<med-0.02)
		c2=med;
	end
	if (c3>med+0.02 || c3<med-0.02)
		c3=med;
	end
	if (c4>med+0.02 || c4<med-0.02)
		c4=med;
	end

	med=median([c1 c2 c3 c4]);
	set(gh('GCplateau'),'String',num2str(med));
else
	med=str2num(get(gh('GCplateau'),'String'));
end

maxval=max(max(clip));
minval=min(min(clip));

upper=((maxval-med)/100)*cutoff;
lower=((minval+med)/100)*cutoff;
upper=med+upper;
lower=med-lower;

clip(find(clip>=lower&clip<upper))=med;

if get(gh('GCgradated'),'Value')==0
	clip(find(clip<lower))=0;
	clip(find(clip>=upper))=1;
end

gabc.output=clip;

doplot('output');
docontour=get(gh('GCcontourplot'),'Value');
if docontour==0
	if med<0.01 || med<-0.01
		med=0.1;
	end
	colormap(rbmap(-1,1,med))
else
	colormap(gbmap(med));
end
	
%============================================================
%
%============================================================
function doplot(type)

global gabc;
docircle=0;
docontour=get(gh('GCcontourplot'),'Value');
switch type
	case 'gauss'
		data=gabc.gaussdata;
		axeslabel='GCAxis1';
		label='Gaussian';
		docircle=1;
		linewidth=1.5;
		if docontour==0
			circleposition=100;
			linecolor=[1 1 1];
		else
			circleposition=0.1;
			linecolor=[0 0 0];
		end
	case 'gabor'
		data=gabc.gabordata;
		axeslabel='GCAxis2';
		label='Gabor';
		docircle=1;		
		linewidth=1.5;
		if docontour==0
			circleposition=100;
			linecolor=[1 1 1];
		else
			circleposition=0.1;
			linecolor=[0 0 0];
		end
	case 'output'
		data=gabc.output;
		axeslabel='GCAxis3';
		label='Output';
		docircle=1;
		linewidth=2;
		if docontour==0
			circleposition=1;
			linecolor=[1 1 1];
		else
			circleposition=0.1;
			linecolor=[0 0 0];
		end		
end

axes(gh(axeslabel));
[az,el]=view;
if docontour==0
	surf(gabc.xvals,gabc.yvals,data);
else
	num=str2num(get(gh('GCcontournumber'),'String'));
	if num==0
		contour(gabc.xvals,gabc.yvals,data);
	else
		contour(gabc.xvals,gabc.yvals,data,num);
	end
end
title([label ' - min=' num2str(min(min(data))) ' | max =  ' num2str(max(max(data)))]);
set(gca,'Tag',axeslabel);
view([az,el]);
box on;
axis square;
axis tight;
if strcmp(label,'Gaussian')
	zlim([0 100]);
	caxis([0 100]);
end
if strcmp(label,'Gabor')
	set(gh('GCAxis1'),'CLim',[min(data(:)) max(data(:))]);
end
shading interp;
if docircle==1
	mult=str2num(get(gh('GCcirclemultiply'),'String'));
	h=circle((gabc.width/2)*mult,gabc.xpos,gabc.ypos,'b',800);
	x=get(h,'XData');
	z=ones(1,length(x))*circleposition;
	set(h,'ZData',z,'LineWidth',linewidth,'Color',linecolor);
end



%============================================================
%
%============================================================
function comparefields(type)

global gabc;

[norm,rawdp]=dotproduct(gabc.gaussdata,gabc.gabordata);

dp=rawdp/norm;
gabc.currentdp=dp;

str=['Normalised Dot Product = ' sprintf('%0.5g',dp)];

if ~isempty(gabc.storedp)
	x=sprintf('%0.5g',(gabc.storedp/gabc.currentdp));
	str=[str sprintf('\n\n') 'Relative Dot Product (vs.:' sprintf('%0.5g',gabc.storedp) ') = ' x];
end

gabc.string=str;

set(gh('GCoutputtext'),'String',str);
	
%============================================================
%
%============================================================
function setstate()

global gabc;

set(gh('GCxmin'),'String',num2str(gabc.xmin));
set(gh('GCxmax'),'String',num2str(gabc.xmax));
set(gh('GCymin'),'String',num2str(gabc.ymin));
set(gh('GCymax'),'String',num2str(gabc.ymax));
set(gh('GCsteps'),'String',num2str(gabc.steps));

set(gh('GCxpos'),'String',num2str(gabc.xpos));
set(gh('GCypos'),'String',num2str(gabc.ypos));
set(gh('GCwidth'),'String',num2str(gabc.width));
set(gh('GCspont'),'String',num2str(gabc.spont));

set(gh('GCsigma1'),'String',num2str(gabc.gabo(1)));
set(gh('GCsigma2'),'String',num2str(gabc.gabo(2)));
set(gh('GCtheta'),'String',num2str(gabc.gabo(3)*(180/pi)));
set(gh('GClambda'),'String',num2str(gabc.gabo(5)));
set(gh('GCphase'),'String',num2str(gabc.gabo(6)*(180/pi)));
set(gh('GCxoff'),'String',num2str(gabc.gabo(7)));
set(gh('GCyoff'),'String',num2str(gabc.gabo(8)));

%============================================================
%
%============================================================
function getstate()

global gabc;

gabc.xmin=str2num(get(gh('GCxmin'),'String'));
gabc.xmax=str2num(get(gh('GCxmax'),'String'));
gabc.ymin=str2num(get(gh('GCymin'),'String'));
gabc.ymax=str2num(get(gh('GCymax'),'String'));
gabc.steps=str2num(get(gh('GCstep'),'String'));

gabc.xvals=linspace(gabc.xmin,gabc.xmax,gabc.steps);
gabc.yvals=linspace(gabc.ymin,gabc.ymax,gabc.steps);

gabc.xpos=str2num(get(gh('GCxpos'),'String'));
gabc.ypos=str2num(get(gh('GCypos'),'String'));
gabc.width=str2num(get(gh('GCwidth'),'String'));
gabc.spont=str2num(get(gh('GCspont'),'String'));

gabc.gabo(1)=str2num(get(gh('GCsigma1'),'String'));
gabc.gabo(2)=str2num(get(gh('GCsigma2'),'String'));
gabc.gabo(3)=str2num(get(gh('GCtheta'),'String'))*(pi/180);
gabc.gabo(4)=gabc.gabo(3);
gabc.gabo(5)=str2num(get(gh('GClambda'),'String'));
gabc.gabo(6)=str2num(get(gh('GCphase'),'String'))*(pi/180);
gabc.gabo(7)=str2num(get(gh('GCxoff'),'String'));
gabc.gabo(8)=str2num(get(gh('GCyoff'),'String'));

%============================================================
%
%============================================================
function f=gauss(p,x,y)

a=find(p==0);
p(a)=0.0000000000001;

for a=1:length(x);        
	f(a,:)=p(5)+(p(1)*exp(-(((x(a)-p(3))^2)+((y-p(2)).^2))/(1*p(4))^2));  %halfmatrixhalfloop      
end

