function gaborfit(action)

%***************************************************************
%
%  Gabor Fit, Computes RF Fits
%
%     Completely GUI, not run-line commands needed
%
% [ian] 1.0 Initial release
%
%***************************************************************

global data
global gabdat

if nargin<1,
    action='Initialize';
end

%%%%%%%%%%%%%%See what dog needs to do%%%%%%%%%%%%%
switch(action)

    %-------------------------------------------------------------------
case 'Initialize'
    %-------------------------------------------------------------------
	
	gaborfit_UI;
	gabdat.storeval=0;
    version=['GABOR-Fit Model Fitting Routine V1.0a | Started on ', datestr(now)];
    set(0,'DefaultAxesLayer','top')
	set(0,'DefaultAxesTickDir','out')
    set(gcf,'Name', version);
    set(gh('GBInfoText'),'String','Welcome to the GABOR Model Fitter.');
	
	%-------------------------------------------------------------------
case 'Import'
	%-------------------------------------------------------------------

   gabdat=[];
    if isempty(data)
        errordlg('Sorry, I can''t find the spikes data structure, are you running spikes?')
        error;
    end

   switch data.numvars
	case 0
		errordlg('Sorry, 0 variable data cannot be used.')
		error;
	otherwise
        gabdat.x=data.xvalues;   
		gabdat.y=data.yvalues;
		gabdat.z=data.matrix;
		if get(gh('GFNormalise'),'Value')==1
			set(gh('GFlb9'),'String','0');
			set(gh('GFub9'),'String','0');
			set(gh('GFlb10'),'String','1');
			set(gh('GFub10'),'String','1');
			gabdat.z=gabdat.z-min(min(gabdat.z));
			gabdat.z=gabdat.z/max(max(gabdat.z));
		end
		gabdat.e=data.errormat;
	end
	
	%set up values on data
% 	set(gh('GFub1'),'String',num2str(max(max(gabdat.z))*2));
% 	set(gh('GFub2'),'String',num2str(max(max(gabdat.z))*2));
	set(gh('GFlb8'),'String',num2str(min(gabdat.y)));
	set(gh('GFub8'),'String',num2str(max(gabdat.y)));
	set(gh('GFlb7'),'String',num2str(min(gabdat.x)));
	set(gh('GFub7'),'String',num2str(max(gabdat.x)));
	set(gh('GFlb8'),'String',num2str(min(gabdat.y)));
	set(gh('GFub8'),'String',num2str(max(gabdat.y)));
	set(gh('GFspont'),'String',num2str(round(min(min(gabdat.z))/2)));
	set(gh('GFlb9'),'String',num2str(round(min(min(gabdat.z))/2)));
	set(gh('GFub9'),'String',num2str(round(min(min(gabdat.z))*2)));
	set(gh('GFamp'),'String',num2str(round(max(max(gabdat.z)))));
	set(gh('GFlb10'),'String',num2str(round(max(max(gabdat.z))/2)));
	set(gh('GFub10'),'String',num2str(round(max(max(gabdat.z))*2)));
		
    gabdat.title=data.matrixtitle;
    gabdat.file=data.filename;
	set(gh('GBLoadText'),'String',['Data Loaded: ' gabdat.title ]);	
    cla;
	
	if get(gh('GFIntCheck'),'Value')==1
		fittype=get(gh('GFIntMenu'),'String');
        fittype=fittype{get(gh('GFIntMenu'),'Value')};
		xx=linspace(min(gabdat.x),max(gabdat.x),80);
		yy=linspace(min(gabdat.y),max(gabdat.y),80);
		[x,y]=meshgrid(gabdat.x,gabdat.y);
		gabdat.xvals=xx;
		gabdat.yvals=yy;
		[xx,yy]=meshgrid(gabdat.xvals,gabdat.yvals);
		gabdat.data=interp2(x,y,gabdat.z,xx,yy,fittype);
	else
		gabdat.xvals=gabdat.x;
		gabdat.yvals=gabdat.y;
		gabdat.data=gabdat.z;
	end
	
	axes(gh('GFAxis1'));
	surf(gabdat.xvals,gabdat.yvals,gabdat.data);
	view(0,90);
	title(['DATA - min=' num2str(min(min(gabdat.z))) ' | max =  ' num2str(max(max(gabdat.z)))]);
	axis square;
	box on;
	axis tight;
	shading interp;
	set(gca,'Tag','GFAxis1');
	
	plotgabor;
	
	set(gh('GBInfoText'),'String','Data and Initial Parameters have been succesfully loaded...');
	
    %-------------------------------------------------------------------
case 'FitIt'
    %-------------------------------------------------------------------

    fitgabor;

    %-------------------------------------------------------------------
case 'RePlot'
    %-------------------------------------------------------------------

    plotgabor;
	
    %-------------------------------------------------------------------
case 'StoreIt'
    %-------------------------------------------------------------------
	
	getstate;
	
	if isfield(gabdat,'storeval')
		gabdat.storeval=gabdat.storeval+1;
	else
		gabdat.storeval=1;
	end
	gabdat.store(gabdat.storeval).title=gabdat.current;
	gabdat.store(gabdat.storeval).xo=gabdat.xo;
	gabdat.store(gabdat.storeval).lb=gabdat.lb;
	gabdat.store(gabdat.storeval).ub=gabdat.ub;	
	
	newitem=[gabdat.store(gabdat.storeval).title];
	history=get(gh('GFHistory'),'String');
	if ischar(history)
		history={history};
	end
	if gabdat.storeval==1
		newitems=[newitem];
	else
		newitems=[history;newitem];
	end
	set(gh('GFHistory'),'String',newitems);
	set(gh('GFHistory'),'Value',gabdat.storeval);
	
  %-------------------------------------------------------------------
case 'GetHistory'
    %-------------------------------------------------------------------
	
	val=get(gh('GFHistory'),'Value');
	lb=gabdat.store(val).lb;
	ub=gabdat.store(val).ub;
	xo=gabdat.store(val).xo;

	setstate(lb,ub,xo);	
	
	gabdat.storecurrent=val;
	
    %-------------------------------------------------------------------
case 'ReSet'
    %-------------------------------------------------------------------
	
	set(gh('GFsigma1'),'String','0.25');
	set(gh('GFsigma2'),'String','0.25');
	set(gh('GFtheta'),'String','90');
	set(gh('GFtheta2'),'String','90');
	set(gh('GFlambda'),'String','1');
	set(gh('GFphase'),'String','0');
	set(gh('GFxoff'),'String','0');
	set(gh('GFyoff'),'String','0');
	set(gh('GFspont'),'String','15');
	set(gh('GFamp'),'String','15');		
	
	plotgabor;

    %-------------------------------------------------------------------
case 'Load Data'
    %-------------------------------------------------------------------

	clear gabdat;
    uiload;
	
	axes(gh('GFAxis1'));
	surf(gabdat.xvals,gabdat.yvals,gabdat.data);
	view(0,90);
	title(['DATA - min=' num2str(min(min(gabdat.z))) ' | max =  ' num2str(max(max(gabdat.z)))]);
	axis square;
	box on;
	axis tight;
	shading interp;
	set(gca,'Tag','GFAxis1');
	
	set(gh('GBLoadText'),'String',['Data Loaded: ' gabdat.title ]);

   setstate(gabdat.lb,gabdat.ub,gabdat.xo);
   
   if gabdat.storeval>0
	   for i=1:gabdat.storeval
		   history{i}=gabdat.store(i).title;
	   end
	   set(gh('GFHistory'),'String',history);
	   if isfield(gabdat,'storecurrent')
		   set(gh('GFHistory'),'Value',gabdat.storecurrent);
	   else
		   set(gh('GFHistory'),'Value',gabdat.storeval);
	   end
   end	   

    %-------------------------------------------------------------------
case 'Save Data'
    %-------------------------------------------------------------------

    uisave('gabdat')

    %-------------------------------------------------------------------
case 'Spawn'
    %-------------------------------------------------------------------

	axes(gh('GFAxis1'));
	h(1)=gca;
	axes(gh('GFAxis2'));
	h(2)=gca;
	
    hnew=figure;
    set(gcf,'Position',[100 100 900 700]);
    set(gcf,'Units','Characters');
    c=copyobj(h,hnew, 'legacy');
    set(c,'Tag',' ');
    set(c,'UserData','');
    suplabel([gabdat.title sprintf('\n') gabdat.current2]);


    %--------------------------------------------------
end %end of main program switch
	%--------------------------------------------------


% ------------------------------Plots the GABOR--------------------------------------
% --------------------------------------------------------------------------------------
function plotgabor()

	global gabdat

	getstate;
	xo=gabdat.xo;
	
	if get(gh('GFLocktheta'),'Value')==1
		xo(4)=xo(3);
		set(gh('GFtheta2'),'String',num2str(xo(4)*(180/pi)));
	end
		
	gabdat.gabordata=gabor(gabdat.xvals,gabdat.yvals,xo(1),xo(2),xo(3),xo(4),xo(5),xo(6),xo(7),xo(8),xo(9),xo(10));
	
	if get(gh('GFNormalise'),'Value')==1
			gabdat.gabordata=gabdat.gabordata-min(min(gabdat.gabordata));
			gabdat.gabordata=gabdat.gabordata/max(max(gabdat.gabordata));
	end
	
	axes(gh('GFAxis2'));
	s=view;
	surf(gabdat.xvals,gabdat.yvals,gabdat.gabordata);
	title(['MODEL - min=' num2str(min(min(gabdat.gabordata))) ' | max =  ' num2str(max(max(gabdat.gabordata)))]);
	view(s);
	box on;
	axis square;
	axis tight;
	shading interp;
	set(gca,'Tag','GFAxis2');
		
	g(1)=goodness2(gabdat.data,gabdat.gabordata,'m');	
    g(2)=goodness2(gabdat.data,gabdat.gabordata,'mfe');
	g(3)=goodness2(gabdat.data,gabdat.gabordata,'ss');	
	t=['Current fit is: ' num2str(g(1)) ' (mean) | ' num2str(g(2)) ' (MFE) | ' num2str(g(3)) ' (sum of squares)' sprintf('\n\n') 'Values have been copied to clipboard in spreadsheet friendly format...'];

	set(gh('GBInfoText'),'String',t);
	
	xog=[xo,g];
	xog(3)=xog(3)*(180/pi);
	xog(4)=xog(4)*(180/pi);
	xog(6)=xog(6)*(180/pi);
	s=[sprintf('%s\t',gabdat.title),sprintf('%0.6g\t',xog)];
	clipboard('Copy',s);	
	gabdat.current=sprintf('%0.4g\t',xog);
	gabdat.current2=sprintf('%0.4g    ',xog);
	
% ------------------------------Fits the GABOR--------------------------------------
% --------------------------------------------------------------------------------------
function fitgabor()

global gabdat

disp=get(gh('GFDisplayMenu'),'String');
disp=disp{get(gh('GFDisplayMenu'),'Value')};
if get(gh('GFLargeScale'),'Value')==1
	ls='on';
else
	ls='off';
end
options = optimset('Display',disp,'LargeScale',ls,'MaxFunEvals',2000);

if get(gh('GFNormalise'),'Value')==1
	set(gh('GFlb9'),'String','0');
	set(gh('GFub9'),'String','0');
	set(gh('GFlb10'),'String','1');
	set(gh('GFub10'),'String','1');		
	set(gh('GFspont'),'String','0');
	set(gh('GFamp'),'String','1');
end

getstate;

set(gh('REdit'),'String','Now Searching for the Optimal 2D Gaussian parameters, please wait...');
pause(0.25)
[xo,f,exit,output]=fmincon(@dogabor,gabdat.xo,[],[],[],[],gabdat.lb,gabdat.ub,[],options,gabdat.xvals,gabdat.yvals,gabdat.data);
output
output.message
if exit>=0
	t='Computation Finished.  Optimal Parameters Found.';
	set(gh('GFInfoText'),'String',t);  
elseif exit<0
	t='Computation Finished.  Optimal Parameters Not Found.';
	set(gh('GFInfoText'),'String',t);  
end

set(gh('GFsigma1'),'String',num2str(xo(1)));
set(gh('GFsigma2'),'String',num2str(xo(2)));
set(gh('GFtheta'),'String',num2str(xo(3)*(180/pi)));
set(gh('GFtheta2'),'String',num2str(xo(4)*(180/pi)));
set(gh('GFlambda'),'String',num2str(xo(5)));
set(gh('GFphase'),'String',num2str(xo(6)*(180/pi)));
set(gh('GFxoff'),'String',num2str(xo(7)));
set(gh('GFyoff'),'String',num2str(xo(8)));
set(gh('GFspont'),'String',num2str(xo(9)));
set(gh('GFamp'),'String',num2str(xo(10)));

gabdat.xo=xo;

plotgabor;

%============================================================
%
%============================================================
function setstate(lb,ub,xo)

global gabdat;

set(gh('GFlb1'),'String',num2str(lb(1)));
set(gh('GFlb2'),'String',num2str(lb(2)));
set(gh('GFlb3'),'String',num2str(lb(3)));
set(gh('GFlb4'),'String',num2str(lb(4)));
set(gh('GFlb5'),'String',num2str(lb(5)));
set(gh('GFlb6'),'String',num2str(lb(6)));
set(gh('GFlb7'),'String',num2str(lb(7)));
set(gh('GFlb8'),'String',num2str(lb(8)));
set(gh('GFlb9'),'String',num2str(lb(9)));
set(gh('GFlb10'),'String',num2str(lb(10)));

set(gh('GFub1'),'String',num2str(ub(1)));
set(gh('GFub2'),'String',num2str(ub(2)));
set(gh('GFub3'),'String',num2str(ub(3)));
set(gh('GFub4'),'String',num2str(ub(4)));
set(gh('GFub5'),'String',num2str(ub(5)));
set(gh('GFub6'),'String',num2str(ub(6)));
set(gh('GFub7'),'String',num2str(ub(7)));
set(gh('GFub8'),'String',num2str(ub(8)));
set(gh('GFub9'),'String',num2str(ub(9)));
set(gh('GFub10'),'String',num2str(ub(10)));

set(gh('GFsigma1'),'String',num2str(xo(1)));
set(gh('GFsigma2'),'String',num2str(xo(2)));
set(gh('GFtheta'),'String',num2str(xo(3)*(180/pi)));
set(gh('GFtheta2'),'String',num2str(xo(4)*(180/pi)));
set(gh('GFlambda'),'String',num2str(xo(5)));
set(gh('GFphase'),'String',num2str(xo(6)*(180/pi)));
set(gh('GFxoff'),'String',num2str(xo(7)));
set(gh('GFyoff'),'String',num2str(xo(8)));
set(gh('GFspont'),'String',num2str(xo(9)));
set(gh('GFamp'),'String',num2str(xo(10)));

gabdat.lb=lb;
gabdat.ub=ub;
gabdat.xo=xo;

plotgabor;

%============================================================
%
%============================================================
function getstate()

global gabdat;

lb(1)=str2num(get(gh('GFlb1'),'String'));
lb(2)=str2num(get(gh('GFlb2'),'String'));
lb(3)=str2num(get(gh('GFlb3'),'String'));
lb(4)=str2num(get(gh('GFlb4'),'String'));
lb(5)=str2num(get(gh('GFlb5'),'String'));
lb(6)=str2num(get(gh('GFlb6'),'String'));
lb(7)=str2num(get(gh('GFlb7'),'String'));
lb(8)=str2num(get(gh('GFlb8'),'String'));
lb(9)=str2num(get(gh('GFlb9'),'String'));
lb(10)=str2num(get(gh('GFlb10'),'String'));

ub(1)=str2num(get(gh('GFub1'),'String'));
ub(2)=str2num(get(gh('GFub2'),'String'));
ub(3)=str2num(get(gh('GFub3'),'String'));
ub(4)=str2num(get(gh('GFub4'),'String'));
ub(5)=str2num(get(gh('GFub5'),'String'));
ub(6)=str2num(get(gh('GFub6'),'String'));
ub(7)=str2num(get(gh('GFub7'),'String'));
ub(8)=str2num(get(gh('GFub8'),'String'));
ub(9)=str2num(get(gh('GFub9'),'String'));
ub(10)=str2num(get(gh('GFub10'),'String'));

xo(1)=str2num(get(gh('GFsigma1'),'String'));
xo(2)=str2num(get(gh('GFsigma2'),'String'));
xo(3)=str2num(get(gh('GFtheta'),'String'))*(pi/180);
xo(4)=str2num(get(gh('GFtheta2'),'String'))*(pi/180);
xo(5)=str2num(get(gh('GFlambda'),'String'));
xo(6)=str2num(get(gh('GFphase'),'String'))*(pi/180);
xo(7)=str2num(get(gh('GFxoff'),'String'));
xo(8)=str2num(get(gh('GFyoff'),'String'));
xo(9)=str2num(get(gh('GFspont'),'String'));
xo(10)=str2num(get(gh('GFamp'),'String'));

gabdat.lb=lb;
gabdat.ub=ub;
gabdat.xo=xo;

%============================================================
%
%============================================================
function f=dogabor(xo,x,y,z)

if get(gh('GFLocktheta'),'Value')==1
	xo(4)=xo(3);
end

a=find(xo==0);
xo(a)=0.0000000000000000000000000000000000001;

zz=gabor(x,y,xo(1),xo(2),xo(3),xo(4),xo(5),xo(6),xo(7),xo(8),xo(9),xo(10));
if get(gh('GFNormalise'),'Value')==1
		zz=zz-min(min(zz));
		zz=zz/max(max(zz));
end


f=goodness2(z,zz,'mfe');

