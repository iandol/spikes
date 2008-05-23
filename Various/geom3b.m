function meandiff=geom3b(sep,sf,tf)

%Wei's complimentary angle model, - there are several parameters:
%
% sep = separation of the cells (d in the original equation)
% x = relative orientation of the bar/s, will be 0 when link or complimentary
% angle is set
% compangle = complimentary angle
% tf/sf used to get v (velocity)
%
% This version just gives the mean ratio between control and complimentary

a=20;

for i=1:length(sep) %for each point in our data stream
	
	if sep(i)<1/sf(i) %wavelength bigger than separation
		meandiff(i)=nan;
	else
		v=tf(i)/sf(i); %get our velocity		
		
		%------- the linking angle
		
		y=0; %link case
		x=radians(-a:a); %matlab works in radians
		
		for j=1:length(x)
			deltat1(j)=(sep(i)*(sin(x(j)+y)-sin(y)))/v; %rowlands simplified equation
		end
		
		deltat1=deltat1*1000; %get into milliseconds
				
		%--------the Complimentary angle
		
		y=asin((1/sf(i))/sep(i)); %complimentary case
		xx=radians(-a:a); %matlab works in radians
		
		for j=1:length(xx)
			deltat2(j)=(sep(i)*(sin(xx(j)+y)-sin(y)))/v; %rowlands simplified equation
		end
		
		deltat2=deltat2*1000; %get into milliseconds
		
		deltat2(find(deltat2==0))=0.000000001; %to stop divide-by-zero errors
		
		meandiff(i)=nanmean(deltat1./deltat2);
		
	end
	
end

meandiff=meandiff';