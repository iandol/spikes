function dogfit(action)

%***************************************************************
%
%  DOGFit, Computes Area Summation Model Fits
%
%     Completely GUI, not run-line commands needed
%
% [ian] 1.0 Initial release
% [ian] 1.5 Updated for Matlab 9
% [ian] fix for two variable data properly
%***************************************************************

global data
global fd
global sv

if nargin<1,
	action='Initialize';
end

%%%%%%%%%%%%%%See what dog needs to do%%%%%%%%%%%%%
switch(action)
	
	%-------------------------------------------------------------------
	case 'Initialize'
	%-------------------------------------------------------------------
		fd.version = 1.901;
		version=['DOG-Fit Model Fitting Routine ' sprintf('%.4f',fd.version) ' | Started on ', datestr(now)];
		set(0,'DefaultAxesLayer','top');
		set(0,'DefaultAxesTickDir','out');
		fd.uihandle = dogfitfig;
		set(gcf,'Name', version);
		set(gh('DFDisplayMenu'),'Value',3);
		set(gh('InfoText'),'String','Welcome to the DOG Model Fitter. Choose ''Import'' to load data from Spikes, or ''Load Data'' to load a previous model file.');
		tic;matlabpool
		fprintf('matlabpool took: %g seconds to initialize\n',toc)
		%-------------------------------------------------------------------
	case 'Import'
		%-------------------------------------------------------------------
		
		if isempty(data)
			errordlg('Sorry, I can''t find the spikes data structure, are you running spikes?')
			error('can''t find data...');
		end
		
		set(gh('DFLoadText'),'String',['Data Loaded: ' data.filename ' (' data.matrixtitle ')']);
		
		switch data.numvars
			case 0
				errordlg('Sorry, 0 variable data cannot be used.')
				error('not enough variables');
			otherwise
				if sv.xlock==1 && sv.ylock==0
					fd.x=data.yvalues;
				else
					fd.x=data.xvalues;
				end
				fd.y=data.matrix;
				if ~(length(fd.x)==length(fd.y))
					error('Dimension error in input!!!')
				end
				fd.e=data.errormat;
		end
		
		set(gh('caedit'),'String',num2str(max(fd.y)*1.5));            %set to the max firing rate *1.5
		tmp=fd.x(find(fd.y==max(fd.y)));
		set(gh('csedit'),'String',num2str(tmp(1)));  %set to the optimum diameter
		set(gh('saedit'),'String',num2str(max(fd.y)*1.5/2));         %set to half the max firing rate
		tmp=fd.x(find(fd.y==max(fd.y)))*2;
		set(gh('ssedit'),'String',num2str(tmp(1))); %set to 2x optimum
		
		xo(1)=str2num(get(gh('caedit'),'String'));
		xo(2)=str2num(get(gh('csedit'),'String'));
		xo(3)=str2num(get(gh('saedit'),'String'));
		xo(4)=str2num(get(gh('ssedit'),'String'));
		
		if min(fd.x)==0
			fd.dc=fd.y(find(fd.x==min(fd.x)));
			xo(5)=fd.dc;
			set(gh('dcedit'),'String',num2str(fd.dc));
			fd.s=0;
			xo(6)=fd.s;
			set(gh('sedit'),'String',num2str(fd.s));
			fd.lb=round([fd.dc/2 0.1 fd.dc/2 0.1 0 0]);
			fd.ub=round([max(fd.y)*5 max(fd.x) max(fd.y)*5 max(fd.x) max(fd.y) 0]);
			set(gh('lb1'),'String',num2str(fd.lb(1)));
			set(gh('lb2'),'String',num2str(fd.lb(2)));
			set(gh('lb3'),'String',num2str(fd.lb(3)));
			set(gh('lb4'),'String',num2str(fd.lb(4)));
			set(gh('lbdc'),'String',num2str(fd.lb(5)));
			set(gh('lbs'),'String',num2str(fd.lb(6)));
			set(gh('lb4'),'String',num2str(fd.lb(4)));
			set(gh('ub1'),'String',num2str(fd.ub(1)));
			set(gh('ub2'),'String',num2str(fd.ub(2)));
			set(gh('ub3'),'String',num2str(fd.ub(3)));
			set(gh('ub4'),'String',num2str(fd.ub(4)));
			set(gh('ubdc'),'String',num2str(fd.ub(5)));
			set(gh('ubs'),'String',num2str(fd.ub(6)));
		else
			fd.dc=1;
			xo(5)=fd.dc;
			set(gh('dcedit'),'String',num2str(fd.dc));
			fd.s=0;
			xo(6)=fd.s;
			set(gh('sedit'),'String',num2str(fd.s));
			fd.lb=[0 0.1 0 0.1 0 0];
			fd.ub=[max(fd.y)*5 max(fd.x) max(fd.y)*5 max(fd.x) max(fd.y) 0];
			set(gh('lb1'),'String',num2str(fd.lb(1)));
			set(gh('lb2'),'String',num2str(fd.lb(2)));
			set(gh('lb3'),'String',num2str(fd.lb(3)));
			set(gh('lb4'),'String',num2str(fd.lb(4)));
			set(gh('lbdc'),'String',num2str(fd.lb(5)));
			set(gh('lbs'),'String',num2str(fd.lb(6)));
			set(gh('ub1'),'String',num2str(fd.ub(1)));
			set(gh('ub2'),'String',num2str(fd.ub(2)));
			set(gh('ub3'),'String',num2str(fd.ub(3)));
			set(gh('ub4'),'String',num2str(fd.ub(4)));
			set(gh('ubdc'),'String',num2str(fd.ub(5)));
			set(gh('ubs'),'String',num2str(fd.ub(6)));
		end
		
		fd.title=data.matrixtitle;
		fd.file=data.filename;
		axes(gh('sfaxis'));
		cla;
		fitnumber=str2num(get(gh('DFSmoothNumber'),'String'));
		xx=linspace(min(fd.x),max(fd.x),fitnumber);
		yy=dogsummate(xo,xx);
		yy(find(yy<0))=0;
		areabar(fd.x,fd.y,fd.e,[.8 .8 .8]);
		hold on;
		plot(xx,yy,'r-');
		hold off;
		set(gca,'FontSize',9);
		xlabel('Diameter (deg)');
		ylabel('Firing Rate');
		title(['Summation Curves (' fd.title ')']);
		legend('Data','Model');
		set(gca,'Tag','sfaxis','UserData','SpawnAxes');
		dogplot(xo);
		axes(gh('raxis'));
		axis([-inf inf -100 100]);
		set(gca,'FontSize',9);
		xlabel('Diameter (deg)');
		ylabel('Normalised Residuals (% Max of Data)');
		title('Residuals of the Data-Model');
		set(gca,'Tag','raxis','UserData','SpawnAxes');
		set(gh('InfoText'),'String','Tuning curve data loaded and rough initial guesses have been made, you may now let the computer find the optimum parameters "Fit IT!", or enter parameters directly via the edit boxes.');
		
		%-------------------------------------------------------------------
	case 'FitIt'
		%-------------------------------------------------------------------
		
		set(gh('InfoText'),'String','Now trying to find the optimum parameters for the model fit to this data, please wait...');
		drawnow;
		if get(gh('DFSmooth'),'Value')==1
			fittype=get(gh('DFSmoothMenu'),'String');
			fittype=fittype{get(gh('DFSmoothMenu'),'Value')};
			fitnumber=str2num(get(gh('DFSmoothNumber'),'String'));
			x=linspace(min(fd.x),max(fd.x),fitnumber);
			y=interp1(fd.x,fd.y,x,fittype);
			if isfield(fd,'e')            %we have error onfo
				e=interp1(fd.x,fd.e,x,fittype);
				fd.es=e;
			end
			fd.xs=x;
			fd.ys=y;
		else
			x=fd.x;
			y=fd.y;
			if isfield(fd,'e')            %we have error onfo
				e=fd.e;
			end
		end
		
		if get(gh('LargeScale'),'Value')==1
			ls='on';
		else
			ls='off';
		end
		
		disp=get(gh('DFDisplayMenu'),'String');
		disp=disp{get(gh('DFDisplayMenu'),'Value')};
		
		sf=1;
		
		options = optimset('Display',disp,'LargeScale',ls);
		xo=[0 0 0 0 0 0];
		xo(1)=str2num(get(gh('caedit'),'String'));
		xo(2)=str2num(get(gh('csedit'),'String'));
		xo(3)=str2num(get(gh('saedit'),'String'));
		xo(4)=str2num(get(gh('ssedit'),'String'));
		xo(5)=str2num(get(gh('dcedit'),'String'));
		xo(6)=str2num(get(gh('sedit'),'String'));
		if get(gh('DFUseCHF'),'Value') == 0; xo(6)=xo(6)/sf; end%needed or else fmincon doesnt jump values enough to shift it
		
		if get(gh('DFUsenlinfit'),'Value')==0 && get(gh('ConstrainBox'),'Value')==1
			lb(1)=str2num(get(gh('lb1'),'String'));
			lb(2)=str2num(get(gh('lb2'),'String'));
			lb(3)=str2num(get(gh('lb3'),'String'));
			lb(4)=str2num(get(gh('lb4'),'String'));
			lb(5)=str2num(get(gh('lbdc'),'String'));
			lb(6)=str2num(get(gh('lbs'),'String'));
			if get(gh('DFUseCHF'),'Value') == 0; if lb(6)>0;lb(6)=lb(6)/sf;end;end
			ub(1)=str2num(get(gh('ub1'),'String'));
			ub(2)=str2num(get(gh('ub2'),'String'));
			ub(3)=str2num(get(gh('ub3'),'String'));
			ub(4)=str2num(get(gh('ub4'),'String'));
			ub(5)=str2num(get(gh('ubdc'),'String'));
			ub(6)=str2num(get(gh('ubs'),'String'));
			if get(gh('DFUseCHF'),'Value') == 0; if ub(6)>0;ub(6)=ub(6)/sf;end;end
			if get(gh('DFUseCHF'),'Value') == 0
				if get(gh('Surround'),'Value')==1
					[o,f,exit,output]=fmincon(@dogsummate,xo,[],[],[],[],lb,ub,@sumconfun,options,x,y);
				else
					[o,f,exit,output]=fmincon(@dogsummate,xo,[],[],[],[],lb,ub,[],options,x,y);
				end
			else
				nmax = 16;
				lb(7) = nmax;
				ub(7) = nmax;
				xo(7) = nmax;
				[o,f,exit,output]=fmincon(@DOG_CHF,xo,[],[],[],[],lb,ub,[],options,x,y);
			end
		elseif get(gh('DFUsenlinfit'),'Value')==0
			[o,f,exit,output]=fminunc(@dogsummate,xo,options,x,y);
		elseif get(gh('DFUsenlinfit'),'Value')==1
			opts=statset('Display',disp,'DerivStep',0.01,'Robust','off');
			xo=xo(1:5);
			[o,r,J]=nlinfit(x,y,@dogsummate,xo,opts);
			ci=nlparci(o,r,J)
			if o(5)<0.001 %silly to have tiny spontaneous rates
				o(5)=0;
			end
			o(6)=0;
		end
		
		fd.text=['Parameters found...'];
		set(gh('InfoText'),'String',fd.text);
		
		fd.dc=o(5);
		if get(gh('DFUseCHF'),'Value') == 0;
			fd.s=o(6)*sf;
		else
			fd.s=o(6);
		end	
		fd.xo=o;
		if get(gh('ConstrainBox'),'Value')==1 && get(gh('DFUsenlinfit'),'Value')==0
			fd.lb=lb;
			if get(gh('DFUseCHF'),'Value') == 0;fd.lb(6)=fd.lb(6)*sf;end
			fd.ub=ub;
			if get(gh('DFUseCHF'),'Value') == 0;fd.ub(6)=fd.ub(6)*sf;end
			fd.output=output;
		end
		
		set(gh('caedit'),'String',num2str(fd.xo(1)));
		set(gh('csedit'),'String',num2str(fd.xo(2)));
		set(gh('saedit'),'String',num2str(fd.xo(3)));
		set(gh('ssedit'),'String',num2str(fd.xo(4)));
		set(gh('dcedit'),'String',num2str(fd.xo(5)));
		set(gh('sedit'),'String',num2str(fd.xo(6)));
		
		if get(gh('DFUseCHF'),'Value') == 0
			yy=dogsummate(fd.xo,x);
		else
			try
				xoc=fd.xo;
				nmax = 16;
				xoc(7) = nmax;
				yy=DOG_CHF(xoc,x);
			catch
				fprintf('\nCHF Failed!!!\n')
				yy=dogsummate(fd.xo,x);
			end
		end
		axes(gh('sfaxis'));
		cla;
		if isfield(fd,'e')            %we have error onfo
			areabar(x,y,e,[.8 .8 .8]);
			hold on
			plot(x,yy,'r-')
			hold off
		else
			plot(x,y,'k-',x,yy,'r-');
		end
		set(gca,'FontSize',9)
		xlabel('Diameter (deg)');
		ylabel('Firing Rate');
		title(['Summation Curves (' fd.title ')']);
		legend('Data','Model');
		set(gca,'Tag','sfaxis','UserData','SpawnAxes');
		dogplot(fd.xo);
		res=((y-yy)/max(y))*100;
		axes(gh('raxis'));
		plot(x,res);
		axis([-inf inf -100 100]);
		set(gca,'FontSize',9);
		xlabel('Diameter (deg)');
		ylabel('Normalised Residuals (% Max of Data)');
		title('Residuals of the Data-Model');
		fd.goodness=goodness(y,yy);
		fd.goodness2=goodness(y,yy,'mfe');
		legend(['fit = ' num2str(fd.goodness) '%']);
		set(gca,'Tag','raxis','UserData','SpawnAxes');
		
		sindex=((xo(3)*xo(4))/(xo(1)*xo(2)));
		
		if exist('exit','var') && exit<=0
			fd.text=['Warning: Algorithm didn''t converge. Try to fit it using these latest parameters, if there is still no convergence, use new initial parameters. Goodness:' num2str(fd.goodness) '% | ' num2str(fd.goodness2) ' MFE. SI=' num2str(sindex)];
			set(gh('InfoText'),'String',fd.text);
		elseif exist('output','var')
			fd.text=[num2str(output.iterations) ' iterations and ' num2str(output.funcCount) ' :- ' output.algorithm '. Goodness:' num2str(fd.goodness) '% | ' num2str(fd.goodness2) ' MFE | SI=' num2str(sindex)];
			set(gh('InfoText'),'String',fd.text);
		else
			fd.text=['Goodness:' num2str(fd.goodness) '% | ' num2str(fd.goodness2) ' MFE. SI=' num2str(sindex)];
			set(gh('InfoText'),'String',fd.text);
		end
		
		fd.res=res;
		fd.yy=yy;
		
		%fid=fopen('c:\temp.txt','wt+');
		%ttt=num2str([fd.xo,fd.goodness,fd.goodness2])
		%fprintf(fid,'%s\n',ttt);
		%fclose(fid);
		xog=[fd.xo(1:end-1),fd.goodness,fd.goodness2];
		s=[sprintf('%s\t',fd.title),sprintf('%0.6g\t',xog)];
		clipboard('Copy',s(1:end-1));
		
		%-------------------------------------------------------------------
	case 'RePlot'
		%-------------------------------------------------------------------
		
		set(gh('InfoText'),'String','Replotting values entered by the user......');
		if get(gh('DFSmooth'),'Value')==1
			fittype=get(gh('DFSmoothMenu'),'String');
			fittype=fittype{get(gh('DFSmoothMenu'),'Value')};
			fitnumber=str2num(get(gh('DFSmoothNumber'),'String'));
			x=linspace(min(fd.x),max(fd.x),fitnumber);
			y=interp1(fd.x,fd.y,x,fittype);
			if isfield(fd,'e')            %we have error onfo
				e=interp1(fd.x,fd.e,x,fittype);
				fd.es=e;
			end
			fd.xs=x;
			fd.ys=y;
		else
			x=fd.x;
			y=fd.y;
			if isfield(fd,'e')            %we have error onfo
				e=fd.e;
			end
		end
		
		xo(1)=str2num(get(gh('caedit'),'String'));
		xo(2)=str2num(get(gh('csedit'),'String'));
		xo(3)=str2num(get(gh('saedit'),'String'));
		xo(4)=str2num(get(gh('ssedit'),'String'));
		xo(5)=str2num(get(gh('dcedit'),'String'));
		xo(6)=str2num(get(gh('sedit'),'String'));
		
		fd.xo=xo;
		fd.dc=fd.xo(5);
		fd.s=fd.xo(6);
		axes(gh('sfaxis'));
		cla;
		tic
		if get(gh('DFUseCHF'),'Value') == 0
			yy=dogsummate(xo,x);
		else
			try
				xoc=xo;
				nmax = 16;
				xoc(7) = nmax;
				yy=DOG_CHF(xoc,x);
			catch
				fprintf('\nCHF Failed!!!\n')
				yy=dogsummate(xo,x);
			end
		end
		fprintf('Curve Generation took: %g seconds\n',toc)
		yy(yy<0)=0;
		if isfield(fd,'e') %we have error info
			%areabar(x,y,e,[.8 .8 .8]);
			areabar(fd.x,fd.y,fd.e,[0.8 0.8 0.8]);
			hold on;
			plot(x,yy,'r-');
			axis tight
			hold off;
		else
			plot(x,y,'k-',x,yy,'r-');
		end
		set(gca,'FontSize',9)
		xlabel('Diameter (deg)');
		ylabel('Firing Rate');
		title(['Summation Curves (' fd.title ')']);
		legend('Data','Model','Location','Best');
		set(gca,'Tag','sfaxis','UserData','SpawnAxes');
		dogplot(xo);
		res=((y-yy)/max(y))*100;
		axes(gh('raxis'));
		plot(x,res)
		axis([-inf inf -100 100])
		set(gca,'FontSize',9)
		xlabel('Diameter (deg)');
		ylabel('Normalised Residuals (% Max of Data)');
		title('Residuals of the Data-Model')
		set(gca,'Tag','raxis','UserData','SpawnAxes');
		set(gh('InfoText'),'String','Finished replotting user-modified difference of gaussian parameters.');
		fd.goodness=goodness(y,yy);
		fd.goodness2=goodness(y,yy,'mfe');
		legend(['fit = ' num2str(fd.goodness) '%'])
		xog=[fd.xo,fd.goodness,fd.goodness2];
		s=[sprintf('%s\t',fd.title),sprintf('%0.6g\t',xog)]
		clipboard('Copy',s);
		
		%-------------------------------------------------------------------
	case 'Load Data'
		%-------------------------------------------------------------------
		
		[fn,pn]=uigetfile({'*.mat','Mat File (MAT)'},'Select File Type to Load:');
		if isequal(fn,0)|isequal(pn,0);errordlg('No File Selected or Found!');error('File not selected');end
		cd(pn);
		load(fn);
		
		set(gh('DFLoadText'),'String',['Data Loaded: ' fd.file ' (' fd.title ')']);
		
		set(gh('lb1'),'String',num2str(fd.lb(1)));
		set(gh('lb2'),'String',num2str(fd.lb(2)));
		set(gh('lb3'),'String',num2str(fd.lb(3)));
		set(gh('lb4'),'String',num2str(fd.lb(4)));
		if length(fd.lb)>4
			set(gh('lbdc'),'String',num2str(fd.lb(5)));
		else
			set(gh('lbdc'),'String','0');
		end
		set(gh('ub1'),'String',num2str(fd.ub(1)));
		set(gh('ub2'),'String',num2str(fd.ub(2)));
		set(gh('ub3'),'String',num2str(fd.ub(3)));
		set(gh('ub4'),'String',num2str(fd.ub(4)));
		if length(fd.ub)>4
			set(gh('ubdc'),'String',num2str(fd.ub(5)));
		else
			set(gh('ubdc'),'String',num2str(max(fd.y)));
		end
		set(gh('caedit'),'String',num2str(fd.xo(1)));
		set(gh('csedit'),'String',num2str(fd.xo(2)));
		set(gh('saedit'),'String',num2str(fd.xo(3)));
		set(gh('ssedit'),'String',num2str(fd.xo(4)));
		set(gh('dcedit'),'String',num2str(fd.dc));
		if isfield(fd,'s')
			set(gh('sedit'),'String',num2str(fd.s));
		else
			fd.s=0.1
			set(gh('sedit'),'String',num2str(fd.s));
		end
		
		dogfit('RePlot')
		
		%-------------------------------------------------------------------
	case 'Save Data'
		%-------------------------------------------------------------------
		
		t0=textwrap({fd.text},60);
		t=['DogFit Model Output File'];
		t1=['Data fitted from: ' fd.file];
		t2=['Parameters: ' fd.title];
		t3=['Model parameters were: ' num2str(fd.xo)];
		t4=['Model Fit to data: ' num2str(fd.goodness) '%'];
		fd.metatext=[{t};{''};{t1};{t2};{t3};{t4};{''};t0];
		uisave({'fd'})
		
		%-------------------------------------------------------------------
	case 'Save Text'
		%-------------------------------------------------------------------
		[f,p]=uiputfile({'*.txt','Text Files';'*.*','All Files'},'Save Information to:');
		cd(p)
		fid=fopen([p,f],'wt+');
		t0=textwrap({fd.text},60);
		t=['DogFit Model Output File'];
		t1=['Data fitted from: ' fd.file];
		t2=['Parameters: ' fd.title];
		t4=['Model parameters were: ' num2str(fd.xo)];
		t5=['Model Fit to data: ' num2str(fd.goodness) '%'];
		t=[{t};{''};{t1};{t2};{t3};{t4};{''};t0];
		for i=1:length(t)
			fprintf(fid,'%s\n',t{i});
		end
		fclose(fid);
		
		%-------------------------------------------------------------------
	case 'Spawn'
		%-------------------------------------------------------------------
		
		h=figure;
		set(gcf,'Position',[200 200 800 500]);
		set(gcf,'Units','Characters');
		c=copyobj(findobj('UserData','SpawnAxes'),h);
		set(c,'Tag',' ');
		set(c,'UserData','');
		axes(c(end))
		text(0,0,num2str([fd.xo,fd.goodness,fd.goodness2]))
		
		%-------------------------------------------------------------------
	case 'Exit'
		%-------------------------------------------------------------------
		if matlabpool('size') > 0
			matlabpool close;
		end
		close(fd.uihandle);
		clear fd;
		
		%--------------------------------------------------
end %end of main program switch
%--------------------------------------------------


% ------------------------------Plots the DOG--------------------------------------
% --------------------------------------------------------------------------------------
function dogplot(xo)

x=5;
y=5;
stepx=x/20;
stepy=y/20;

x=-x:stepx:x;
y=-y:stepy:y;

i=find(xo==0);
xo(i)=0.0000000000001;
for a=1:length(x);
	f(a,:)=(xo(5)+(xo(1)*exp(-((x(a)^2)+(y.^2))/xo(2)^2))-(xo(3)*exp(-((x(a)^2)+(y.^2))/xo(4)^2)));  %halfmatrixhalfloop
end
axes(gh('axis3d'))
imagesc(x,y,f)
%[xx,yy]=meshgrid(x,y);
%surf(xx,yy,f);
% shading interp
% lighting phong
% camlight left
axis tight
axis square
axis vis3d
set(gca,'FontSize',9)
xlabel('X Space (deg)')
ylabel('Y Space (deg)')
title('2D DOG')
zlabel('Amplitude')
set(gca,'Tag','axis3d','UserData','SpawnAxes')


% % ------------------------------Summate1 Function--------------------------------
% % ------------------------------------------------------------------------------------------
%
% function [y,f]=summate1(x,xdata)
%
% % This generates a summation curve (y) using a DOG equation
% % compatible with the optimisation toolbox.
% %
% % y=summate1(x,xdata)
% %
% % x= the set of parameters for the DOG model
% %
% % x(1) = centre amplitude
% % x(2) = centre size
% % x(3) = surround amplitude
% % x(4) = surround size
% % x(5) = DC level
% % x(6) = Shift Parameter
% %
% % xdata = the x-axis values of the summation curve to model
% %
% % it will output a tuning curve from the model parameters
%
% a=find(x==0);
% x(a)=0.0000000000001;
% for i=1:length(xdata)
%     if xdata(i)==0
%         sc(i)=x(5)+0;
%     else
%         %space=-xdata(i):xdata(i)/80:xdata(i);        % generate the 'stimulus'
%         %f=(x(1)*exp(-space.^2/x(2)^2))-(x(3)*exp(-space.^2/x(4)^2));          % do the DOG!
%         %sc(i)=trapz(space,f)+x(5);   % integrate area under the curve
%         space=(-xdata(i)/2):(xdata(i)/2)/(80-1):(xdata(i)/2);         % generate the 'stimulus'
%         f=(x(1)*exp(-((2*space)/x(2)).^2))-(x(3)*exp(-((2*space)/x(4)).^2));
%         sc(i)=x(5)+trapz(space,f);
%     end
% end
%
% if x(6)>0                                        %this does the rectification for small diameter non-linearity
%     [m,i]=minim(xdata,x(6));
%     if m>0
%         sc(1:i)=x(5);
%     end
% end
%
% y=sc;
%
% % ------------------------------Summate2 Function--------------------------------
% % ------------------------------------------------------------------------------------------
%
% function y=summate2(x,xdata,data)
% % it will output a mean squared estimate of the residuals between model and data
%
% sc=summate1(x,xdata);
% y=sum((data-sc).^2);  %percentage
% %y=(sum((sc-data).^2)/mean(sc)^2)/length(sc)*1000;  %scaled MFE

% ------------------------------Summate2 Function--------------------------------
% ------------------------------------------------------------------------------------------

function y=summateNL(x,xdata,data)
% for nlinfit it needs Y to be y'

sc=dogsummate(x,xdata);
y=sc';

% ------------------------------Inequality Function--------------------------------
% --------------------------------------------------------------------------------------
function [c,ceq]=sumconfun(x,varargin)
%  support function for fitting summation curves

c=[x(2)-x(4)];
ceq=[];

%%%%%%%%%%%%%%%%%
% fun_DOG_patch_series_dvary.m
%%%%%%%%%%%%%%%%%
% Requires:
%  'fun_X_series_dvary.m'
%%%%%
% fun_DOG_patch_series_dvary evaluates the DOG-model response  
% for a set of circular grating patch of diameter d using the SERIES expansion
% x(1): A1
% x(2): aa1
% x(3): A2
% x(4): aa2
% x(5): dc
% x(6): kd
% x(7): nmax
% Note that x-coordinate is patch diameter d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function y=DOG_CHF(x,xdata,data,rectify)
if nargin < 1
	x(1) = 10;
	x(2) = 0.5;
	x(3) = 8;
	x(4) = 1;
	x(5) = 0;
	x(6) = 2*pi;
	x(7) = 16;
end
if length(x)==6 %we need to add nmax
	x(7) = 16;
end
if nargin < 2
	xdata=[00.5 1 2 4 9];
end
if nargin < 3
	data=[];
end
if nargin < 4
	rectify=false;
end

xe(1)=x(2); xe(2)=x(6); xe(3)=x(7);
xi(1)=x(4); xi(2)=x(6); xi(3)=x(7);
y = x(5) + (x(1)*fun_X_series_dvary(xe,xdata)-x(3)*fun_X_series_dvary(xi,xdata));

if rectify == true
	y(y<0) = 0;
end

if ~isempty(data) %we've been passed data so return the squared error
	y=sum((data-y).^2);  %percentage
end

if x(5)<0 %this is to stop the nlinfit, which has no upper or lower bounds to not select negative spontaneous levels.by making the fit really bad
	y=y/1000;
end


%%%%%%%%%%%%%%%%%
% fun_X_series_dvary.m 
%%%%%%%%%%%%%%%%%
% fun_X_series_dvary evaluates the X-function needed to calculate the
% DOG-response to patch gratings as a function of d values using a series
% expression
% x(1): a
% x(2): kd
% x(3): nmax, number of terms summed over
% xdata: points on the d-axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function y = fun_X_series_dvary(x,xdata)
[~, ndmax]=size(xdata);
yp=zeros(1,ndmax);
yp=x(1)./xdata;
zp=x(1)*x(2);
nmax=x(3);
y=zeros(ndmax);

if matlabpool('size') > 0
	fprintf('Computing Hypergeometric function using parfor...')
	for nd=1:ndmax
	  parfor n=0:nmax
		  yy(n+1) = exp(-zp^2/4)/(4*yp(nd)^2)/factorial(n)*(1/4)^n*zp^(2*n)*double(mfun('Hypergeom',[n+1],[2],-1/(4*(yp(nd)^2))));
	  end
	  y(nd) = sum(yy);
	end
else
	fprintf('Computing Hypergeometric function serially...')
	for nd=1:ndmax
	  for n=0:nmax
	      y(nd) = y(nd) + exp(-zp^2/4)/(4*yp(nd)^2)/factorial(n)*(1/4)^n*zp^(2*n)*double(mfun('Hypergeom',[n+1],[2],-1/(4*(yp(nd)^2))));
	  end
	end
end
