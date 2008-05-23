function dog(action)

global dogdata

if nargin<1,
    action='Initialize';
end

%%%%%%%%%%%%%%See what dog needs to do%%%%%%%%%%%%%
switch(action)
    
 case 'Initialize' 
    
    dogfig
    dog('Plot')
    rotate3d
    
    
case 'Plot'
    
    a1=str2num(get(gh('campedit'),'String'));
    a2=str2num(get(gh('sampedit'),'String'));
    sd1=str2num(get(gh('csizeedit'),'String'));
    sd2=str2num(get(gh('ssizeedit'),'String'));
    x=str2num(get(gh('xspaceedit'),'String'));
    y=str2num(get(gh('yspaceedit'),'String'));
    stepx=x/100;
    stepy=y/100;
    mu=1;
    
    p(1)=2;
    p(2)=1;
    p(3)=1.5;
    p(4)=0.5;
    
    x=-x:stepx:x;
    y=-y:stepy:y;
    
   % f=(a1*exp(-x.^2/sd1^2))-(a2*exp(-x.^2/sd2^2));  %dog equation 
   c=(a1*exp(-(x/sd1).^2));
   s=(a2*exp(-(x/sd2).^2));
   f=c-s;   
   s=-s; 
    if get(gh('RectifyBox'),'Value')==1
        f(find(f<0))=0;
    end
	
    axes(gh('2daxis'));
    plot(x,c,'r--',x,s,'g--',x,f,'k-')
    legend('Centre','Surround','DOG')
    title('1D Difference of Gaussians')
    axis tight
    set(gca,'FontSize',7)
    xlabel('Visual Space (deg)')
    ylabel('Visual sensitivity')
    set(gca,'Tag','2daxis')
    	
	for a=1:length(x);
		f(a,:)=(a1*exp(-((x(a)^2)+(y.^2))/sd1^2))-(a2*exp(-((x(a)^2)+(y.^2))/sd2^2));  %halfmatrixhalfloop
        %f(a,:)=(a1*exp(-((x(a)+y)/sd1).^2))-(a2*exp(-((x(a)+y)/sd2).^2));  %halfmatrixhalfloop
	end
	
     if get(gh('RectifyBox'),'Value')==1
        f(find(f<0))=0;
    end
    
	axes(gh('3daxis2'))
	[xx,yy]=meshgrid(x,y);
	surf(xx,yy,f);
	shading interp
	lighting phong
	camlight left
	axis tight
	axis square
    axis vis3d
     title('2D Difference of Gaussians')
    set(gca,'FontSize',7)
    xlabel('X Space (deg)')
    ylabel('Y Space (deg)')    
    set(gca,'Tag','3daxis2')
    
case 'Summate'
    
    a1=str2num(get(gh('campedit'),'String'));
    a2=str2num(get(gh('sampedit'),'String'));
    sd1=str2num(get(gh('csizeedit'),'String'));
    sd2=str2num(get(gh('ssizeedit'),'String'));
    x=str2num(get(gh('xspaceedit'),'String'));
    y=str2num(get(gh('yspaceedit'),'String'));
    stepx=x/100;
    stepy=y/100;
    
    s=0.1:0.1:8;
    
    for i=1:length(s)
        x=-s(i)/2:0.1:s(i)/2;        
        f=(a1*exp(-((2*x)/sd1).^2))-(a2*exp(-((2*x)/sd2).^2));
        sc(i)=trapz(x,f);
        %f=(a1*exp(-x.^2/sd1^2))-(a2*exp(-x.^2/sd2^2));
        %sc(i)=trapz(x,f);
    end
    
    figure
    plot(s,sc,'k-o')  
    title('Summation Curve')
    xlabel('Stimulus Size (degrees)')
    ylabel('Model Response')
    
end


%GH Gets Handle From Tag
function [handle] = gh(tag)
handle=findobj('Tag',tag);
%End of handle getting routine
