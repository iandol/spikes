function dog(action)

global dogdata

if nargin<1,
	action='Initialize';
end

%%%%%%%%%%%%%%See what dog needs to do%%%%%%%%%%%%%
switch(action)
	
	case 'Initialize'
		
		dogfig
		version = 'Difference of Gaussian Modeller V1.3';
		set(gh('dgUITitle'),'String', version);
		dog('Plot')
		%rotate3d
		
		
	case 'Plot'
		
		a1=str2num(get(gh('dgcampedit'),'String'));
		a2=str2num(get(gh('dgsampedit'),'String'));
		sd1=str2num(get(gh('dgcsizeedit'),'String'));
		sd2=str2num(get(gh('dgssizeedit'),'String'));
		dclevel=str2num(get(gh('dgdcedit'),'String'));
		shiftp=str2num(get(gh('dgshiftedit'),'String'));
		
		xD=str2num(get(gh('dgxspaceedit'),'String'));
		yD=str2num(get(gh('dgyspaceedit'),'String'));
		offset = str2num(get(gh('dgoffset'),'String'));
		
		res = str2num(get(gh('dgResolution'),'String'));
		stepx=xD/res;
		stepy=yD/res;
		mu=1;
		
		x=-xD:stepx:xD;
		y=-yD:stepy:yD;
		xTmp=-xD:stepx:xD;
		
		x=x-offset;
		
		% f=(a1*exp(-x.^2/sd1^2))-(a2*exp(-x.^2/sd2^2));  %dog equation
		c=(a1*exp(-(x.*2/sd1).^2));
		s=(a2*exp(-(x.*2/sd2).^2));
		[yy,ff,xx]=dogsummate([a1 sd1 a2 sd2 dclevel 0],xTmp); 
		f=dclevel+(c-s);
		s=-s;
		if get(gh('dgRectifyBox'),'Value')==1
			f(f<0)=0;
		end
		
		axes(gh('dg2daxis'));
		plot(xTmp,c,'r--',xTmp,s,'g--',xTmp,f,'k-')
		hold on
		plot(xx,ff,'b:')
		hold off
		set(gca,'XMinorTick','on');
		legend('Centre','Surround','DOG','Summate function')
		title('1D Difference of Gaussians')
		axis tight
		set(gca,'FontSize',10)
		xlabel('Visual Space (deg)')
		ylabel('Visual sensitivity')
		set(gca,'Tag','dg2daxis')
		
		for a=1:length(x);
			% This is Allito and Usrey's equation...
			%         for b=1:length(y);
			%             f(a,b)=(a1*exp(-(x(a)^2)/(2*sd1^2))*exp(-(y(b)^2)/(2*sd1^2)))-(a2*exp(-(x(a)^2)/(2*sd2^2))*exp(-(y(b)^2)/(2*sd2^2)));
			%         end
			f(a,:)=dclevel+((a1*exp(-((x(a)^2)+(y.^2))/sd1^2))-(a2*exp(-((x(a)^2)+(y.^2))/sd2^2))); %halfmatrixhalfloop
			%f(a,:)=(a1*exp(-((x(a)+y)/sd1).^2))-(a2*exp(-((x(a)+y)/sd2).^2));  %halfmatrixhalfloop
		end
		
		if get(gh('RectifyBox'),'Value')==1
			f(f<0)=0;
		end
		
		axes(gh('dg3daxis'))
		[xx,yy]=meshgrid(xTmp,y);
		pcolor(xx,yy,f');
		set(gca,'XMinorTick','on');
		shading interp
		lighting phong
		camlight left
		axis tight
		axis square
		axis vis3d
		title('2D Difference of Gaussians')
		set(gca,'FontSize',10)
		xlabel('X Space (deg)')
		ylabel('Y Space (deg)')
		set(gca,'Tag','dg3daxis')
		
	case 'Summate'
		
		a1=str2num(get(gh('dgcampedit'),'String'));
		a2=str2num(get(gh('dgsampedit'),'String'));
		sd1=str2num(get(gh('dgcsizeedit'),'String'));
		sd2=str2num(get(gh('dgssizeedit'),'String'));
		dclevel=str2num(get(gh('dgdcedit'),'String'));
		shiftp=str2num(get(gh('dgshiftedit'),'String'));
		
		offset = str2num(get(gh('dgoffset'),'String'));
		
		x(1)=a1;
		x(2)=sd1;
		x(3)=a2;
		x(4)=sd2;
		x(5)=dclevel;
		x(6)=shiftp;
		x(7)=offset;
		
		SI=(a2*sd2)/(a1*sd1);
		s=0:0.1:9;
		
		if get(gh('dgcampedit'),'Value') == 1
			ROG = 1;
		else
			ROG = 0;
		end
		
		if get(gh('dgRectifyBox'),'Value') == 1
			rectify = 1;
		else
			rectify = 0;
		end
		
		sc=dogsummate(x,s,[],ROG,rectify);
		
		%     for i=1:length(s)
		%         x=-s(i)/2:0.1:s(i)/2;
		%         f=(a1*exp(-((2*x)/sd1).^2))-(a2*exp(-((2*x)/sd2).^2));
		%         sc(i)=trapz(x,f);
		%         %f=(a1*exp(-x.^2/sd1^2))-(a2*exp(-x.^2/sd2^2));
		%         %sc(i)=trapz(x,f);
		%     end
		
		mn = sc(1);
		mx = max(sc);
		plateau = sc(end);
		
		psup = (1-((plateau-mn)/(mx-mn)))*100;
		
		figure
		plot(s,sc,'k-o')
		title([['Summation Curve | SI = ' num2str(SI)] ' | % Sup = ' num2str(psup)])
		xlabel('Stimulus Size (degrees)')
		ylabel('Model Response')
		
end
