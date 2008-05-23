function [x,xx,ratio,p]=geom7(sep,a,b,sf)

%Rowlands complimentary angle model modified to give half-width OT
% - there are several parameters:
%
% sep = separation of the cells (d in the original equation)
% a/b = RF sizes for cell 1 and 2
% sf = spatial frequency

if length(sep)<=1 %just want one value
    
    w=(1/sf)/2; %get wavelength from spatial frequency - divide by 2 because light bar is 'half'
    
    a=a/2;
    b=b/2;
    %-------------for the linking angle
    y=0;
    
    x=asin(((a+b+w)/(2*sep))+sin(y))-y;
    
    p=degs(asin((a+b+w)/(2*sep))); %spit out George model value as confirmation
    
    x=degs(x); %get us back our degrees
    %---------------------------------------
    
    %------------for the complimentary angle
    y=asin(w/sep);
    
    xx=asin(((a+b+w)/(2*sep))+sin(y))-y;
    
    xx=degs(xx); %get us back our degrees
    %----------------------------------------
    
    ratio=xx/x;
    
    figure;
    plot([1,2],[x,xx],'k-o');
    ylabel('Angle to get Half-width (degs)')
    xlabel('Condition')
    title(['Ratio Difference: ' num2str(ratio) ' | Sep: ' num2str(sep) 'degs | SF: ' num2str(sf) 'c/d | RF1: ' num2str(a) ' | RF2: ' num2str(b)])
    axis([0 3 -inf inf])
    
else %run through multiple cells
    
    w=(1./sf)/2; %do this once so loop is quicker
    a=a/2;
    b=b/2;
    
    for i=1:length(sep)           
        
        %-------------for the linking angle-------
        y=0;
        
        x(i)=asin(((a(i)+b(i)+w(i))/(2*sep(i)))+sin(y))-y;
        
        p(i)=degs(asin((a(i)+b(i)+w(i))/(2*sep(i)))); %spit out George model value as confirmation 
        %---------------------------------------
        
        %------------for the complimentary angle
        y=asin(w(i)/sep(i));
        
        xx(i)=asin(((a(i)+b(i)+w(i))/(2*sep(i)))+sin(y))-y;
         %---------------------------------------
    end
    
    x=degs(x);
    
    xx=degs(xx);
    
    ratio=xx./x;
    
    stem3(x,xx,ratio,'filled')
    xlabel('Link Tuning')
    ylabel('Complimentary Tuning')
    zlabel('Ratio Complimentary/Link')
    x=x';
    xx=xx';
    ratio=ratio';
    p=p';
    
end
    
    
    
    
