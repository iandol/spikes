function gaussfit2D(action)

global gdat
global o

if nargin<1,
    action='Initialize';
end

%%%%%%%%%%%%%%See what gauss needs to do%%%%%%%%%%%%%
switch(action)
    
 case 'Initialize'
    
	gdat=[];
	gaussfit2D_UI;

	gdat.c1.mat=o.cell1.matrix;
	gdat.c1.max=max(max(gdat.c1.mat));
	gdat.c1.min=min(min(gdat.c1.mat));
	gdat.c2.mat=o.cell2.matrix;
	gdat.c2.max=max(max(gdat.c2.mat));
	gdat.c2.min=min(min(gdat.c2.mat));
	gdat.c1.name=o.cell1.filename;
	gdat.c2.name=o.cell2.filename;
	gdat.xvals=o.cell1.xvalues;
	gdat.xvalsorig=o.cell1.xvalues;
	gdat.yvals=o.cell1.yvalues;
	gdat.yvalsorig=o.cell1.yvalues;
	gdat.xhold=o.xhold-ceil(o.cell1.xrange/2);
	gdat.yhold=o.yhold-ceil(o.cell1.yrange/2);
	gdat.normalise=0;
	gdat.invert=0;
	gdat.firstfit=0;
	gdat.testtrial=0;

	InterpolateMatrix(1);
	InterpolateMatrix(2);
	
	%---------------------------------------------------------------------------------------------set defaults for each cell
	
	set(gh('C1Edit'),'String',num2str(max(max(gdat.c1.mat))));      %magnitude
	set(gh('D1Edit'),'String',num2str(max(max(gdat.c2.mat))));

	[a,b]=find(gdat.c1.mat==max(max(gdat.c1.mat)));	
	t=gdat.xvals(b(1));
	t2=gdat.yvals(a(1));
	set(gh('C2Edit'),'String',t); %X position
	set(gh('C3Edit'),'String',t2); %Y position
	[a,b]=find(gdat.c2.mat==max(max(gdat.c2.mat)));	
	t=gdat.xvals(b(1));
	t2=gdat.yvals(a(1));
	set(gh('D2Edit'),'String',t); %X position
	set(gh('D3Edit'),'String',t2); %Y position


	set(gh('C4Edit'),'String','1');      %width
	set(gh('D4Edit'),'String','1');   

	set(gh('C5Edit'),'String',num2str(min(min(gdat.c1.mat))));      %spontaneous
	set(gh('D5Edit'),'String',num2str(min(min(gdat.c2.mat))));      

	drawgauss(1);
	drawgauss(2);    
	GetVector;
    
    %============================================================
case 'CPlot'
    %============================================================
	set(gh('REdit'),'String','Parameter for control cell modified by user');
	pause(0.1)	
    drawgauss(1);
	GetVector;
    
    %============================================================
case 'DPlot'
    %============================================================
	set(gh('REdit'),'String','Parameter for drug cell modified by user');
	pause(0.1)	
	drawgauss(2)
	GetVector;
    
    %============================================================
case 'CFit'
    %============================================================
	fitgauss(1);
	drawgauss(1);
	GetVector;
    
    %============================================================
case 'DFit'
    %============================================================
	fitgauss(2);
	drawgauss(2);
	GetVector;
    
    %============================================================
case 'Normalise'
    %============================================================
    
   if gdat.normalise==0
        gdat.c1.mat=100*(gdat.c1.mat/gdat.c1.max);
        gdat.c2.mat=100*(gdat.c2.mat/gdat.c2.max);
        set(gh('C1Edit'),'String','100');
        set(gh('D1Edit'),'String','100');
        gdat.normalise=1;
    else
        gdat.c1.mat=(gdat.c1.mat*gdat.c1.max)/100;
        gdat.c2.mat=(gdat.c2.mat*gdat.c2.max)/100;
        set(gh('C1Edit'),'String',num2str(gdat.c1.max));
        set(gh('D1Edit'),'String',num2str(gdat.c2.max));
        gdat.normalise=0;
    end
    
    drawgauss(1);
    drawgauss(2);
    
    %============================================================
case 'Invert'
    %============================================================
    
    if gdat.invert==0
        gdat.c1.mat=100*(1-((gdat.c1.mat-gdat.c1.min)/(gdat.c1.max-gdat.c1.min)));
        gdat.c2.mat=100*(1-((gdat.c2.mat-gdat.c2.min)/(gdat.c2.max-gdat.c2.min)));
        gdat.invert=1;
        set(gh('InvertBox'),'Enable','off');
    else
        
    end
    
    drawgauss(1);
    drawgauss(2);    
    
    %============================================================
case 'TestTrials'
    %============================================================
	
	TestTrials;
	
case 'SpawnGaussLeft'
	
	axes(gh('CGAxis'));
	h=gca;		
	hnew=figure;
	set(gcf,'Units','Normalized');
	set(gcf,'Position',[0.1 0.1 0.7 0.7]);
	c=copyobj(h,hnew);
	set(c,'Units','Normalized');
	set(c,'Position',[0.1 0.1 0.8 0.8]);
	set(c,'Tag','');
	set(c,'UserData','');
	xlabel('X Position (deg)');
	ylabel('Y Position (deg)');
	colorbar;
	
case 'SpawnGaussRight'
	
	axes(gh('DGAxis'));
	h=gca;		
	hnew=figure;
	set(gcf,'Units','Normalized');
	set(gcf,'Position',[0.1 0.1 0.7 0.7]);
	c=copyobj(h,hnew);
	set(c,'Units','Normalized');
	set(c,'Position',[0.1 0.1 0.8 0.8]);
	set(c,'Tag','');
	set(c,'UserData','');
	xlabel('X Position (deg)');
	ylabel('Y Position (deg)');
	colorbar;		

end


%============================================================
%
%============================================================
function drawgauss(s)

global gdat

switch s
case 1 %control
	
	axval(1)=str2num(get(gh('GF2XMin1'),'String'));
	axval(2)=str2num(get(gh('GF2XMax1'),'String'));
	axval(3)=str2num(get(gh('GF2YMin1'),'String'));
	axval(4)=str2num(get(gh('GF2YMax1'),'String'));

	p(1)=str2num(get(gh('C1Edit'),'String')); 
	p(2)=str2num(get(gh('C2Edit'),'String'));
	p(3)=str2num(get(gh('C3Edit'),'String'));
	p(4)=str2num(get(gh('C4Edit'),'String'));
	p(5)=str2num(get(gh('C5Edit'),'String'));

	gdat.c1.p=p;
	clear xx yy

	if axval(1)~=axval(2) || axval(3)~=axval(4)
		xx=linspace(axval(1),axval(2),60);
		yy=linspace(axval(3),axval(4),60);
		gdat.c1.gauss=gauss(p,xx,yy); 
	else
		gdat.c1.gauss=gauss(p,gdat.xvals,gdat.yvals); 
	end

	axes(gh('CDAxis'));
	pos=get(gh('CDAxis'),'Position');
	pcolor(gdat.xvals,gdat.yvals,gdat.c1.mat);
	axis square;
	shading interp;
	colorbar('south');
	set(gca,'Tag','CDAxis');

	axes(gh('CGAxis'));
	if exist('xx','var')
	pcolor(xx,yy,gdat.c1.gauss);
	else
	pcolor(gdat.xvals,gdat.yvals,gdat.c1.gauss);
	end
	axis square;
	shading interp;
	colorbar('south');
	set(gca,'Tag','CGAxis');

	g=goodness2(gdat.c1.mat,gdat.c1.gauss,'m');
	g2=goodness2(gdat.c1.mat,gdat.c1.gauss,num2str(p(5)));	
	g3=goodness2(gdat.c1.mat,gdat.c1.gauss,'mfe');	
	gdat.c1.g=[g,g3];
	set(gh('CEdit'),'String',strvcat(['Mean: ' num2str(g) '%'],['Spont: ' num2str(g2) '%'],['MFE: ' num2str(g3)]));
	t=['Control File:' gdat.c1.name ' Drug File: ' gdat.c2.name ']'];
	set(gh('REdit'),'String',t);
    	    
case 2 %drug
	
	axval(1)=str2num(get(gh('GF2XMin2'),'String'));
	axval(2)=str2num(get(gh('GF2XMax2'),'String'));
	axval(3)=str2num(get(gh('GF2YMin2'),'String'));
	axval(4)=str2num(get(gh('GF2YMax2'),'String'));
    
    if get(gh('LockBox'),'Value')==0
        p(1)=str2num(get(gh('D1Edit'),'String'));	    
        p(2)=str2num(get(gh('D2Edit'),'String'));
        p(3)=str2num(get(gh('D3Edit'),'String'));
        p(4)=str2num(get(gh('D4Edit'),'String'));
        p(5)=str2num(get(gh('D5Edit'),'String'));	
    else 
        p(1)=str2num(get(gh('D1Edit'),'String'));	
        p(2)=str2num(get(gh('C2Edit'),'String')); 
        p(3)=str2num(get(gh('C3Edit'),'String'));
        p(4)=str2num(get(gh('C4Edit'),'String'));
        p(5)=str2num(get(gh('D5Edit'),'String'));	
        set(gh('D1Edit'),'String',num2str(p(1)));
        set(gh('D2Edit'),'String',num2str(p(2)));
        set(gh('D3Edit'),'String',num2str(p(3)));
        set(gh('D4Edit'),'String',num2str(p(4)));
        set(gh('D5Edit'),'String',num2str(p(5)));
	end
    
	clear xx yy;
	if axval(1)~=axval(2) || axval(3)~=axval(4)
		xx=linspace(axval(1),axval(2),60);
		yy=linspace(axval(3),axval(4),60);
		gdat.c2.gauss=gauss(p,xx,yy); 
	else
		gdat.c2.gauss=gauss(p,gdat.xvals,gdat.yvals); 
	end   

	axes(gh('DDAxis'));    
	cla    
	pcolor(gdat.xvals,gdat.yvals,gdat.c2.mat);
	axis square;
	shading interp;
	colorbar('south');
	set(gca,'Tag','DDAxis');

	axes(gh('DGAxis'));    
	cla    
	if exist('xx','var')
		pcolor(xx,yy,gdat.c2.gauss);
	else
		pcolor(gdat.xvals,gdat.yvals,gdat.c2.gauss);
	end
	axis square;
	shading interp;
	colorbar('south');
	set(gca,'Tag','DGAxis');
	
	g=goodness2(gdat.c2.mat,gdat.c2.gauss,'m');
	g2=goodness2(gdat.c2.mat,gdat.c2.gauss,num2str(p(5)));
	g3=goodness2(gdat.c2.mat,gdat.c2.gauss,'mfe');
	gdat.c2.g=[g,g3];
	set(gh('DEdit'),'String',strvcat(['Mean: ' num2str(g) '%'],['Spont: ' num2str(g2) '%'],['MFE: ' num2str(g3)]));
	t=['Control File:' gdat.c1.name ' Drug File: ' gdat.c2.name ']'];
	set(gh('REdit'),'String',t);
end

if isfield(gdat.c1,'g')==1 && isfield(gdat.c2,'g')==1
    t1=[gdat.c1.p,gdat.c1.g];
    t2=[gdat.c2.p,gdat.c2.g];
    s=[sprintf('%s\t',gdat.c1.name),sprintf('%0.6g\t',t1),sprintf('%s\t',gdat.c2.name),sprintf('%0.6g\t',t2)];
    clipboard('Copy',s);    
end

%============================================================
%
%============================================================
function fitgauss(s)

global gdat

disp='iter';
ls='off';
options = optimset('Display',disp,'LargeScale',ls);

xlim=str2num(get(gh('G2XLim'),'String'));
ylim=str2num(get(gh('G2YLim'),'String'));
wlim=str2num(get(gh('G2WLim'),'String'));
switch s
case 1
	
	p(1)=str2num(get(gh('C1Edit'),'String'));
    p(2)=str2num(get(gh('C2Edit'),'String'));
    p(3)=str2num(get(gh('C3Edit'),'String'));
    p(4)=str2num(get(gh('C4Edit'),'String'));
    p(5)=str2num(get(gh('C5Edit'),'String'));
	
	if gdat.testtrial==0
		lb=[str2num(get(gh('G2L1'),'String')) str2num(get(gh('G2L2'),'String')) str2num(get(gh('G2L3'),'String')) str2num(get(gh('G2L4'),'String')) str2num(get(gh('G2L5'),'String'))];
		ub=[str2num(get(gh('G2U1'),'String')) str2num(get(gh('G2U2'),'String')) str2num(get(gh('G2U3'),'String')) str2num(get(gh('G2U4'),'String')) str2num(get(gh('G2U5'),'String'))];
		set(gh('REdit'),'String','Now Searching for the Optimal 2D Gaussian parameters, please wait...');
	else %we constrain from the optimum overall fit for each trial
		lb=[max(max(gdat.c1.mat))-20 p(2)-xlim p(3)-ylim p(4)-wlim min(min(gdat.c1.mat))-10];
		ub=[max(max(gdat.c1.mat))+20 p(2)+xlim p(3)+ylim p(4)+wlim min(min(gdat.c1.mat))+10];
	end
	
	[p,f,exit,output]=fmincon(@dogauss,p,[],[],[],[],lb,ub,[],options,gdat.xvals,gdat.yvals,gdat.c1.mat);
	
	if exit>=0 && gdat.testtrial==0
        t=['Computation Finished.  Optimal Parameters Found. [Control File:' gdat.c1.name ' Drug File: ' gdat.c2.name ']'];
		set(gh('REdit'),'String',t);    
        t=['Found Optimal Parameters.  Drug File: ' gdat.c2.name ']'];
		set(gh('CEdit'),'String',t)
		gdat.firstfit=1;
	elseif exit<0 && gdat.testtrial==0
        t=['Computation Finished.  Optimal Parameters Not Found. [Control File:' gdat.c1.name ' Drug File: ' gdat.c2.name ']'];
		set(gh('REdit'),'String',t);
        t=['Did not converge, run again. Drug File: ' gdat.c2.name ']'];
		set(gh('CEdit'),'String',t)
	end
			
	if gdat.testtrial==0				
		set(gh('C1Edit'),'String',num2str(p(1)));
		set(gh('C2Edit'),'String',num2str(p(2)));
		set(gh('C3Edit'),'String',num2str(p(3)));
		set(gh('C4Edit'),'String',num2str(p(4)));
		set(gh('C5Edit'),'String',num2str(p(5)));
		gdat.c1.p=p;  
	else
		if exit<0
			gdat.c1trial(gdat.testtrial).fail=1;
		else
			gdat.c1trial(gdat.testtrial).fail=0;
		end
		gdat.c1trial(gdat.testtrial).p=p;
	end
	
	case 2
        
		p(1)=str2num(get(gh('D1Edit'),'String'));	    
    p(2)=str2num(get(gh('D2Edit'),'String'));
    p(3)=str2num(get(gh('D3Edit'),'String'));
    p(4)=str2num(get(gh('D4Edit'),'String'));
    p(5)=str2num(get(gh('D5Edit'),'String'));
    
	if get(gh('LockBox'),'Value')==1 && gdat.testtrial==0
		lb=[str2num(get(gh('G2L1'),'String')) p(2) p(3) p(4) str2num(get(gh('G2L5'),'String'))];
		ub=[str2num(get(gh('G2U1'),'String')) p(2) p(3) p(4) str2num(get(gh('G2U5'),'String'))];
		set(gh('REdit'),'String','Now Searching for the Optimal 2D Gaussian parameters, please wait...');	
	elseif gdat.testtrial==0
		lb=[str2num(get(gh('G2L1'),'String')) str2num(get(gh('G2L2'),'String')) str2num(get(gh('G2L3'),'String')) str2num(get(gh('G2L4'),'String')) str2num(get(gh('G2L5'),'String'))];
		ub=[str2num(get(gh('G2U1'),'String')) str2num(get(gh('G2U2'),'String')) str2num(get(gh('G2U3'),'String')) str2num(get(gh('G2U4'),'String')) str2num(get(gh('G2U5'),'String'))];
		set(gh('REdit'),'String','Now Searching for the Optimal 2D Gaussian parameters, please wait...');
	else
		lb=[max(max(gdat.c2.mat))-20 p(2)-xlim p(3)-ylim p(4)-wlim min(min(gdat.c2.mat))-10];
		ub=[max(max(gdat.c2.mat))+20 p(2)+xlim p(3)+ylim p(4)+wlim min(min(gdat.c2.mat))+10];
	 end

	[p,f,exit,output]=fmincon(@dogauss,p,[],[],[],[],lb,ub,[],options,gdat.xvals,gdat.yvals,gdat.c2.mat);
	
	if exit>=0 && gdat.testtrial==0
        t=['Computation Finished.  Optimal Parameters Found. [Control File:' gdat.c1.name ' Drug File: ' gdat.c2.name ']'];
		set(gh('REdit'),'String',t);    
        t=['Found Optimal Parameters.  Drug File: ' gdat.c2.name ']'];
		set(gh('DEdit'),'String',t)
	elseif exit<0 && gdat.testtrial==0
        t=['Computation Finished.  Optimal Parameters Not Found. [Control File:' gdat.c1.name ' Drug File: ' gdat.c2.name ']'];
		set(gh('REdit'),'String',t);
        t=['Did not converge, run again. Drug File: ' gdat.c2.name ']'];
		set(gh('DEdit'),'String',t)
	end
			
	if gdat.testtrial==0				
		set(gh('D1Edit'),'String',num2str(p(1)));
		set(gh('D2Edit'),'String',num2str(p(2)));
		set(gh('D3Edit'),'String',num2str(p(3)));
		set(gh('D4Edit'),'String',num2str(p(4)));
		set(gh('D5Edit'),'String',num2str(p(5)));
		gdat.c2.p=p;  
	else
		if exit<0
			gdat.c2trial(gdat.testtrial).fail=1;
		else
			gdat.c2trial(gdat.testtrial).fail=0;
		end
		gdat.c2trial(gdat.testtrial).p=p;
	end
	
end
	
%============================================================
%
%============================================================
function f=dogauss(p,x,y,z)

zz=gauss(p,x,y);

f=sum(sum((z-zz).^2));

%============================================================
%
%============================================================
function f=gauss(p,y,x)

a=find(p==0);
p(a)=0.0000000000001;

for a=1:length(x);
	f(a,:)=p(5)+(p(1)*exp(-(((x(a)-p(3))^2)+((y-p(2)).^2))/(1*p(4))^2));  %halfmatrixhalfloop
end

%============================================================
%
%============================================================
function [theta,rho]=GetVector(x1,y1,x2,y2)

global gdat

if get(gh('GFAngleCorrect'),'Value')==1
	rotang=1;
	rectang=0;
else
	rotang=0;
	rectang=0;
end

globalx=str2num(get(gh('G2GlobalX'),'String'));
globaly=str2num(get(gh('G2GlobalY'),'String'));

if nargin<4
	x1=gdat.c1.p(2);
	y1=gdat.c1.p(3);
	x2=gdat.c2.p(2);
	y2=gdat.c2.p(3);
end

if nargin ==4 || isnan(globalx) || isnan(globaly)
	xx=x2-x1;
	yy=y2-y1;
	[theta,rho]=cart2pol(xx,yy);
	gdat.theta=rad2ang(theta,rectang,rotang);
	gdat.rho=rho;
else
	xx1=x1-globalx;
	xx2=x2-globalx;
	yy1=y1-globaly;
	yy2=y2-globaly;
	[theta(1),rho(1)]=cart2pol(xx1,yy1);
	[theta(2),rho(2)]=cart2pol(xx2,yy2);
	gdat.theta=rad2ang(theta,rectang,rotang);
	%gdat.theta(2)=rad2ang(theta(2),rectang,rotang);
	gdat.rho=rho;
	%gdat.rho(2)=rho(2);
end	

if nargin<4
	if length(theta)>1
		t=strvcat([num2str(rad2ang(theta(1),rectang,rotang))],[num2str(rho(1))],[num2str(rad2ang(theta(2),rectang,rotang))],[num2str(rho(2))]);
	else
		t=strvcat([num2str(rad2ang(theta,rectang,rotang))],[num2str(rho)]);
	end
	set(gh('GVectorText'),'String',t);
end

%============================================================
%
%============================================================
function InterpolateMatrix(s,amount)

global gdat

if nargin<2
	amount=120;
end

switch s
case 1
	xx=linspace(min(gdat.xvalsorig),max(gdat.xvalsorig),amount);
	yy=linspace(min(gdat.yvalsorig),max(gdat.yvalsorig),amount);
	[x,y]=meshgrid(gdat.xvalsorig,gdat.yvalsorig);	
	[xx,yy]=meshgrid(xx,yy);
	gdat.c1.mat=interp2(x,y,gdat.c1.mat,xx,yy,'linear');
case 2
	xx=linspace(min(gdat.xvalsorig),max(gdat.xvalsorig),amount);
	yy=linspace(min(gdat.yvalsorig),max(gdat.yvalsorig),amount);
	[x,y]=meshgrid(gdat.xvalsorig,gdat.yvalsorig);
	gdat.xvals=xx;
	gdat.yvals=yy;
	[xx,yy]=meshgrid(xx,yy);
	gdat.c2.mat=interp2(x,y,gdat.c2.mat,xx,yy,'linear');	
end

%============================================================
%
%============================================================
function TestTrials()

global gdat
global o

if get(gh('GFAngleCorrect'),'Value')==1
	rotang=1;
	rectang=0;
else
	rotang=0;
	rectang=0;
end

gdat.c1trial=[];
gdat.c2trial=[];

if ~isfield(o,'cell1raws') || ~isfield(o,'cell2raws') || gdat.firstfit == 0
	errordlg('Sorry, you haven''t measured the data in opro, or fitted the cell yet');
	error('Sorry, you haven''t measured the data in opro, or fitted the cell yet');
end

angcut=get(gh('G2AngCut'),'Value');
zeroopt=get(gh('G2ZeroOpt'),'Value');
scell=get(gh('G2TrialCell'),'Value');
switch scell
	case 1
		gdat.originalmatrix1=gdat.c1.mat;
		xopt=gdat.c1.p(2);
		yopt=gdat.c1.p(3);
		for i=1:length(o.cell1raws{1})
			for j=1:size(o.cell1raws,1)
				for k=1:size(o.cell1raws,2)
					cell1trial(i).matrix(j,k)=sum(o.cell1raws{j,k}(i).trial);
				end
			end
		end
	case 2
		gdat.originalmatrix2=gdat.c2.mat;
		xopt=gdat.c2.p(2);
		yopt=gdat.c2.p(3);
		for i=1:length(o.cell2raws{1})
			for j=1:size(o.cell2raws,1)
				for k=1:size(o.cell2raws,2)
					cell2trial(i).matrix(j,k)=sum(o.cell2raws{j,k}(i).trial);
				end
			end
		end
	case 3
		gdat.originalmatrix1=gdat.c1.mat;
		xopt1=gdat.c1.p(2);
		yopt1=gdat.c1.p(3);
		for i=1:length(o.cell1raws{1})
			for j=1:size(o.cell1raws,1)
				for k=1:size(o.cell1raws,2)
					cell1trial(i).matrix(j,k)=sum(o.cell1raws{j,k}(i).trial);
				end
			end
		end
		gdat.originalmatrix2=gdat.c2.mat;
		xopt2=gdat.c2.p(2);
		yopt2=gdat.c2.p(3);
		for i=1:length(o.cell2raws{1})
			for j=1:size(o.cell2raws,1)
				for k=1:size(o.cell2raws,2)
					cell2trial(i).matrix(j,k)=sum(o.cell2raws{j,k}(i).trial);
				end
			end
		end
end

if zeroopt==1
	xopt=0;
	yopt=0;
	xopt1=0;
	yopt1=0;
	xopt2=0;
	yopt2=0;
end

ignoretrials=str2num(get(gh('G2IgnoreTrials'),'String'));

h=figure;
switch scell
	case 3
		figpos(1,[800 800]);
		otherwise
		figpos(1,[350 720]);
end

a=0;

if exist('cell1trial','var') && exist('cell2trial','var')
	numtrials=min([length(cell1trial) length(cell2trial)]);
elseif exist('cell1trial','var')
	numtrials=length(cell1trial);
else
	numtrials=length(cell2trial);
end

globalx=str2num(get(gh('G2GlobalX'),'String'));
globaly=str2num(get(gh('G2GlobalY'),'String'));
			
for i=1:numtrials
	gdat.testtrial=i;
	switch scell
		case 1
			gdat.c1.mat=cell1trial(i).matrix;
			if gdat.invert==1
				gdat.c1.max=max(max(gdat.c1.mat));
				gdat.c1.min=min(min(gdat.c1.mat));
				gdat.c1.mat=100*(1-((gdat.c1.mat-gdat.c1.min)/(gdat.c1.max-gdat.c1.min)));
			end
			InterpolateMatrix(1);
			fitgauss(1);
			p=gdat.c1trial(i).p;	
			xcontrol=p(2);
			ycontrol=p(3);	
			if max(ignoretrials==i)==0		
				[theta(i),rho(i)]=GetVector(xopt,yopt,xcontrol,ycontrol);
				w(i)=p(4);	
			end
			gauss1=gauss(p,gdat.xvals,gdat.yvals);  
			
			subaxis(ceil(numtrials),2,i+(i-1),'S',0,'P',0,'M',0);
			
			pcolor(gdat.xvals,gdat.yvals,gdat.c1.mat)
			g1=goodness2(gdat.c1.mat,gauss1,'m');	
			g2=goodness2(gdat.c1.mat,gauss1,'mfe');	
			if max(ignoretrials==i)==0
				ylabel(['# ' num2str(i)]);
			else
				ylabel(['CUT']);
			end
			shading interp;
			axis square;
			
			subaxis(ceil(numtrials),2,i+i,'S',0,'P',0,'M',0);
			pcolor(gdat.xvals,gdat.yvals,gauss1)
			ylabel([num2str(g1)],'FontSize',7);
			shading interp
			axis square
			
		case 2
			gdat.c2.mat=cell2trial(i).matrix;
			if gdat.invert==1
				gdat.c2.max=max(max(gdat.c2.mat));
				gdat.c2.min=min(min(gdat.c2.mat));
				gdat.c2.mat=100*(1-((gdat.c2.mat-gdat.c2.min)/(gdat.c2.max-gdat.c2.min)));
			end
			InterpolateMatrix(2);
			fitgauss(2);
			p=gdat.c2trial(i).p;	
			xdrug=p(2);
			ydrug=p(3);	
			if max(ignoretrials==i)==0		
				[theta(i),rho(i)]=GetVector(xopt,yopt,xdrug,ydrug);
				w(i)=p(4);	
			end
			gauss2=gauss(p,gdat.xvals,gdat.yvals);  
			subaxis(ceil(numtrials),2,i+(i-1),'S',0,'P',0,'M',0);
			pcolor(gdat.xvals,gdat.yvals,gdat.c2.mat)
			g1=goodness2(gdat.c2.mat,gauss2,'m');	
			g2=goodness2(gdat.c2.mat,gauss2,'mfe');
			if max(ignoretrials==i)==0
				ylabel(['# ' num2str(i)]);
			else
				ylabel(['CUT']);
			end
			shading interp;
			axis square;
			
			subaxis(ceil(numtrials),2,i+i,'S',0,'P',0,'M',0);
			pcolor(gdat.xvals,gdat.yvals,gauss2)
			ylabel([num2str(g1)],'FontSize',7);
			shading interp
			axis square
			
		case 3
			gdat.c1.mat=cell1trial(i).matrix;
			if gdat.invert==1
				gdat.c1.max=max(max(gdat.c1.mat));
				gdat.c1.min=min(min(gdat.c1.mat));
				gdat.c1.mat=100*(1-((gdat.c1.mat-gdat.c1.min)/(gdat.c1.max-gdat.c1.min)));
			end
			InterpolateMatrix(1);
			fitgauss(1);
			
			gdat.c2.mat=cell2trial(i).matrix;
			if gdat.invert==1
				gdat.c2.max=max(max(gdat.c2.mat));
				gdat.c2.min=min(min(gdat.c2.mat));
				gdat.c2.mat=100*(1-((gdat.c2.mat-gdat.c2.min)/(gdat.c2.max-gdat.c2.min)));
			end
			InterpolateMatrix(2);
			fitgauss(2);
			p1=gdat.c1trial(i).p;	
			p2=gdat.c2trial(i).p;	
			xcontrol=p1(2);
			ycontrol=p1(3);	
			xdrug=p2(2);
			ydrug=p2(3);	
			xx1(i)=xcontrol;
			yy1(i)=ycontrol;
			xx2(i)=xdrug;
			yy2(i)=ydrug;
			if max(ignoretrials==i)==0
				[theta1(i),rho1(i)]=GetVector(xopt1,yopt1,xcontrol,ycontrol); %compared to overall average gaussian fit 
				[theta2(i),rho2(i)]=GetVector(xopt2,yopt2,xdrug,ydrug); %compared to overall average gaussian fit 
				if ~isnan(globalx) && ~isnan(globaly)
					[theta1zero(i),rho1zero(i)]=GetVector(globalx,globaly,xcontrol,ycontrol); %compared to a global co-ordinate set in Gaussfit2D
					[theta2zero(i),rho2zero(i)]=GetVector(globalx,globaly,xdrug,ydrug); %compared to a global co-ordinate set in Gaussfit2D
				else
					[theta1zero(i),rho1zero(i)]=GetVector(0,0,xcontrol,ycontrol); %compared to zero
					[theta2zero(i),rho2zero(i)]=GetVector(0,0,xdrug,ydrug); %compared to zero
				end
				[theta(i),rho(i)]=GetVector(xcontrol,ycontrol,xdrug,ydrug); %vector between both cells
				w1(i)=p1(4);
				w2(i)=p2(4);
				if angcut==1; end	
			end

			gauss1=gauss(p1,gdat.xvals,gdat.yvals);
			gauss2=gauss(p2,gdat.xvals,gdat.yvals);
			
			a=a+1;
			subaxis(ceil(numtrials),4,a,'S',0,'P',0,'M',0);
			set(gca,'FontSize',5);
			pcolor(gdat.xvals,gdat.yvals,gdat.c1.mat);	
			if max(ignoretrials==i)==0
				ylabel(['# ' num2str(i)],'FontSize',8);
			else
				ylabel('CUT','FontSize',8);
			end
			shading interp;
			axis square;
			
			a=a+1;
			subaxis(ceil(numtrials),4,a,'S',0,'P',0,'M',0);
			pcolor(gdat.xvals,gdat.yvals,gauss1)
			g=goodness2(gdat.c1.mat,gauss1,'m');	
			set(gca,'FontSize',5);
			xaxlim=xlim;
			xaxlim=xaxlim(2);
			ylabel(num2str(g),'FontSize',8);
			text(xcontrol,ycontrol,[num2str(xcontrol) '\newline' num2str(ycontrol)],'FontSize',7);
			if max(ignoretrials==i)==0
				text((xaxlim+xaxlim/5),0,['V:' num2str(rho1zero(i)) '/' num2str(rho2zero(i)) '\newline A:' num2str(rad2ang(theta1zero(i),rectang,rotang)) '/' num2str(rad2ang(theta2zero(i),rectang,rotang))],'FontSize',7);
			end
			shading interp;			
			axis square;
			
			a=a+1;
			subaxis(ceil(numtrials),4,a,'S',0,'P',0,'M',0);
			pcolor(gdat.xvals,gdat.yvals,gdat.c2.mat)
			set(gca,'FontSize',5);
			shading interp;
			axis square;
						
			a=a+1;
			subaxis(ceil(numtrials),4,a,'S',0,'P',0,'M',0);
			pcolor(gdat.xvals,gdat.yvals,gauss2);
			g=goodness2(gdat.c2.mat,gauss2,'m');	
			set(gca,'FontSize',5);
			xaxlim=xlim;
			xaxlim=xaxlim(2);
			ylabel(num2str(g),'FontSize',8);
			text(xdrug,ydrug,[num2str(xdrug) '\newline' num2str(ydrug)],'FontSize',7);
			if max(ignoretrials==i)==0
				text((xaxlim+xaxlim/5),0,['V:' num2str(rho(i)) '\newline A:' num2str(rad2ang(theta(i),rectang,rotang))],'FontSize',7);
			end
			shading interp;
			axis square;			
	end
	drawnow;
end

switch scell
	case 1
		gdat.c1.mat=gdat.originalmatrix1;
	case 2
		gdat.c2.mat=gdat.originalmatrix2;
	case 3
		gdat.c1.mat=gdat.originalmatrix1;
		gdat.c2.mat=gdat.originalmatrix2;
end

rho
bootfun=get(gh('G2BootstrapType'),'Value');
bootfuns=get(gh('G2BootstrapType'),'String');
bootfuns=bootfuns{bootfun};
bootn=str2num(get(gh('G2BootstrapN'),'String'));
alpha=str2num(get(gh('G2Alpha'),'String'));
switch scell
	case 3
		[thetaz,rhoz]=GetVector(mean(xx1),mean(yy1),mean(xx2),mean(yy2));
		wdiff=w1-w2;%wdiff is the width difference between each trial
		[h,vp]=ttest(rho,0,alpha); %rho is vector difference between each trial
		[h,wp]=ttest(wdiff,0,alpha);
		vci=bootci(bootn,{@mean,rho},'alpha',alpha);
		wci=bootci(bootn,{@mean,wdiff},'alpha',alpha);
		rci=bootci(bootn,{@circmean,theta},'alpha',alpha);
		rci=rad2ang(rci,rectang,rotang);
		[rthetadiffci,rthetadiff]=bootci(bootn,{@mean,(theta1zero-theta2zero)},'alpha',alpha); %compared to global or 0
		rthetadiffci=rad2ang(rthetadiffci); %we don't correct the angle as it is only the difference that is of interest
		rthetadiff=rad2ang(rthetadiff); %we don't correct the angle as it is only the difference that is of interest
		[rrhodiffci,rrhodiff]=bootci(bootn,{@mean,(rho1zero-rho2zero)},'alpha',alpha);%compared to global or 0
		
		switch bootfun
			case 1
				m=mean(bootstrp(bootn,@mean,rho1));
				m2=mean(bootstrp(bootn,@mean,w1));
				mm=mean(bootstrp(bootn,@mean,rho2));
				mm2=mean(bootstrp(bootn,@mean,w2));
				ci=bootci(bootn,{@mean,rho1},'alpha',alpha);
				ci2=bootci(bootn,{@mean,w1},'alpha',alpha);
				cii=bootci(bootn,{@mean,rho2},'alpha',alpha);
				cii2=bootci(bootn,{@mean,w2},'alpha',alpha);
			case 2
				m=mean(bootstrp(bootn,@geomean,rho1));
				m2=mean(bootstrp(bootn,@geomean,w1));
				mm=mean(bootstrp(bootn,@geomean,rho2));
				mm2=mean(bootstrp(bootn,@geomean,w2));
				ci=bootci(bootn,{@geomean,rho1},'alpha',alpha);
				ci2=bootci(bootn,{@geomean,w1},'alpha',alpha);
				cii=bootci(bootn,{@geomean,rho2},'alpha',alpha);
				cii2=bootci(bootn,{@geomean,w2},'alpha',alpha);
			case 3
				m=mean(bootstrp(bootn,@trimmean,rho1,5));
				m2=mean(bootstrp(bootn,@trimmean,w1,5));
				ci=bootci(bootn,{@trimmean,rho1,5},'alpha',alpha);
				ci2=bootci(bootn,{@trimmean,w1,5},'alpha',alpha);
				mm=mean(bootstrp(bootn,@trimmean,rho2,5));
				mm2=mean(bootstrp(bootn,@trimmean,w2,5));
				cii=bootci(bootn,{@trimmean,rho2,5},'alpha',alpha);
				cii2=bootci(bootn,{@trimmean,w2,5},'alpha',alpha);
			case 4
				m=mean(bootstrp(bootn,@trimmean,rho1,10));
				m2=mean(bootstrp(bootn,{@trimmean,w1,10}));
				ci=bootci(bootn,{@trimmean,rho1,10},'alpha',alpha);
				ci2=bootci(bootn,{@trimmean,w1,10},'alpha',alpha);
				mm=mean(bootstrp(bootn,@trimmean,rho2,10));
				mm2=mean(bootstrp(bootn,{@trimmean,w2,10}));
				cii=bootci(bootn,{@trimmean,rho2,10},'alpha',alpha);
				cii2=bootci(bootn,{@trimmean,w2,10},'alpha',alpha);
			case 5
				m=mean(bootstrp(bootn,{@trimmean,rho,25}));
				m2=mean(bootstrp(bootn,{@trimmean,w,25}));
				ci=bootci(bootn,{@trimmean,rho,25},'alpha',alpha);
				ci2=bootci(bootn,{@trimmean,w,25},'alpha',alpha);
				mm=mean(bootstrp(bootn,{@trimmean,rho1,25}));
				mm2=mean(bootstrp(bootn,{@trimmean,w1,25}));
				cii=bootci(bootn,{@trimmean,rho2,25},'alpha',alpha);
				cii2=bootci(bootn,{@trimmean,w2,25},'alpha',alpha);
			case 6
				m=mean(bootstrp(bootn,{@std,rho}));
				m2=mean(bootstrp(bootn,{@std,w}));
				ci=bootci(bootn,{@std,rho},'alpha',alpha);
				ci2=bootci(bootn,{@std,w},'alpha',alpha);
				mm=mean(bootstrp(bootn,{@std,rho1}));
				mm2=mean(bootstrp(bootn,{@std,w1}));
				cii=bootci(bootn,{@std,rho2},'alpha',alpha);
				cii2=bootci(bootn,{@std,w2},'alpha',alpha);
		end
		xcmean=mean(bootstrp(bootn,@mean,xx1));
		xcci=bootci(bootn,{@mean,xx1},'alpha',alpha);
		ycmean=mean(bootstrp(bootn,@mean,yy1));
		ycci=bootci(bootn,{@mean,yy1},'alpha',alpha);
		xdmean=mean(bootstrp(bootn,@mean,xx2));
		xdci=bootci(bootn,{@mean,xx2},'alpha',alpha);
		ydmean=mean(bootstrp(bootn,@mean,yy2));
		ydci=bootci(bootn,{@mean,yy2},'alpha',alpha);
		
		xdiff=xx2-xx1;
		ydiff=yy2-yy1;
		
		xdiffmean=mean(bootstrp(bootn,@mean,xdiff));
		xdiffci=bootci(bootn,{@mean,xdiff},'alpha',alpha);
		ydiffmean=mean(bootstrp(bootn,@mean,ydiff));
		ydiffci=bootci(bootn,{@mean,ydiff},'alpha',alpha);
		
% 		tit=['Vp:' num2str(vp) ' Wp:' num2str(wp) ' Vci: ' num2str(vci(1)) ':' num2str(vci(2)) ' Wci: ' num2str(wci(1)) ':' num2str(wci(2)) ' rci: ' num2str(rci(1)) ':' num2str(rci(2))];
% 		tit=[tit '\newline vector: ' num2str(ci(1)) '|' num2str(m) '|' num2str(ci(2)) ' > ' num2str(cii(1)) '|' num2str(mm) '|' num2str(cii(2))];
% 		tit=[tit '\newline width:' num2str(ci2(1)) '|' num2str(m2) '|' num2str(ci2(2)) ' > ' num2str(cii2(1)) '|' num2str(mm2) '|' num2str(cii2(2))];
% 		tit=[tit '\newline Mean x/y diff then vector:' num2str(thetaz) ' A:' num2str(rad2ang(rhoz)) ' | Ind X/Y vectors then mean:' num2str(mean(thetax)) ' A:' num2str(rad2ang(circmean(rhox)))];
% 		tit=[tit '\newline X control:' num2str(xcci(1)) ':' num2str(xcmean) ':' num2str(xcci(2)) ' | Y:' num2str(ycci(1)) ':' num2str(ycmean) ':' num2str(ycci(2)) ' | X drug:' num2str(xdci(1)) ':' num2str(xdmean) ':' num2str(xdci(2)) ' | Y:' num2str(ydci(1)) ':' num2str(ydmean) ':' num2str(ydci(2))];
% 		tit=[tit '\newline X diff:' num2str(xdiffci(1)) ':' num2str(xdiffmean) ':' num2str(xdiffci(2)) ' | Y:' num2str(ydiffci(1)) ':' num2str(ydiffmean) ':' num2str(ydiffci(2))];
 		tit=['TRIAL V: ' num2str(mean(rho)) ' ANG: ' num2str(rad2ang(circmean(theta),rectang,rotang)) ' TTEST: ' num2str(vp) ' CI: ' num2str(vci(1)) '<>' num2str(vci(2)) ' | WIDTH TTEST: ' num2str(wp) ' CI: ' num2str(wci(1)) ' <> ' num2str(wci(2))];
 		tit=[tit '\newline Bootstrp V CTRL: ' num2str(ci(1)) ' < ' num2str(m) ' > ' num2str(ci(2)) ' | DRUG: ' num2str(cii(1)) ' < ' num2str(mm) ' > ' num2str(cii(2))];
 		tit=[tit '\newline Bootstrp W CTRL: ' num2str(ci2(1)) ' < ' num2str(m2) ' > ' num2str(ci2(2)) ' | DRUG: ' num2str(cii2(1)) ' < ' num2str(mm2) ' > ' num2str(cii2(2))];
 		tit=[tit '\newline CTRL X: ' num2str(xcci(1)) ' < ' num2str(xcmean) ' > ' num2str(xcci(2)) ' / Y: ' num2str(ycci(1)) ' < ' num2str(ycmean) ' > ' num2str(ycci(2)) ];
		tit=[tit '\newline DRUG X: ' num2str(xdci(1)) ' < ' num2str(xdmean) ' > ' num2str(xdci(2)) ' / Y: ' num2str(ydci(1)) ' < ' num2str(ydmean) ' > ' num2str(ydci(2))];
 		tit=[tit '\newline X DIFF: ' num2str(xdiffci(1)) ' < ' num2str(xdiffmean) ' > ' num2str(xdiffci(2)) ' | Y DIFF: ' num2str(ydiffci(1)) ' < ' num2str(ydiffmean) ' > ' num2str(ydiffci(2))];% ' | ANGLE DIFF:' num2str(rdiffci(1)) '<>' num2str(rdiffci(2))];
		tit=[tit '\newline alpha = ' num2str(alpha) ' | global/0 V CI: ' num2str(rrhodiffci(1)) ' <' num2str(rrhodiff) '> ' num2str(rrhodiffci(2)) ' | A CI: ' num2str(rthetadiffci(1)) ' <' num2str(rthetadiff) '> ' num2str(rthetadiffci(2))];
		h=suptitle(tit);
		clipboard('copy',tit);
		set(h,'FontSize',8,'FontName','verdana');
		gdat.testtrial=0;
	otherwise		
		switch bootfun
			case 1
				m=mean(bootstrp(bootn,@mean,rho));
				m2=mean(bootstrp(bootn,@mean,w));
				ci=bootci(bootn,{@mean,rho},'alpha',alpha);
				ci2=bootci(bootn,{@mean,w},'alpha',alpha);
			case 2
				m=mean(bootstrp(bootn,@geomean,rho));
				m2=mean(bootstrp(bootn,@geomean,w));
				ci=bootci(bootn,{@geomean,rho},'alpha',alpha);
				ci2=bootci(bootn,{@geomean,w},'alpha',alpha);
			case 3
				m=mean(bootstrp(bootn,@trimmean,rho,5));
				m2=mean(bootstrp(bootn,@trimmean,w,5));
				ci=bootci(bootn,{@trimmean,rho,5},'alpha',alpha);
				ci2=bootci(bootn,{@trimmean,w,5},'alpha',alpha);
			case 4
				m=mean(bootstrp(bootn,@trimmean,rho,10));
				m2=mean(bootstrp(bootn,{@trimmean,w,10}));
				ci=bootci(bootn,{@trimmean,rho,10},'alpha',alpha);
				ci2=bootci(bootn,{@trimmean,w,10},'alpha',alpha);
			case 5
				m=mean(bootstrp(bootn,{@trimmean,rho,25}));
				m2=mean(bootstrp(bootn,{@trimmean,w,25}));
				ci=bootci(bootn,{@trimmean,rho,25},'alpha',alpha);
				ci2=bootci(bootn,{@trimmean,w,25},'alpha',alpha);
			case 5
				m=mean(bootstrp(bootn,{@std,rho}));
				m2=mean(bootstrp(bootn,{@std,w}));
				ci=bootci(bootn,{@std,rho},'alpha',alpha);
				ci2=bootci(bootn,{@std,w},'alpha',alpha);
		end
		suptitle([bootfuns '\newline vector: ' num2str(ci(1)) '|' num2str(m) '|' num2str(ci(2)) ' \newline width:' num2str(ci2(1)) '|' num2str(m2) '|' num2str(ci2(2))]);
		gdat.testtrial=0;
end


