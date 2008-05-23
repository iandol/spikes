function meandiff=geom4b(sep,sf,tf)

%Wei's complimentary angle model, - there are several parameters:
%
% sep = separation of the cells (d in the original equation)
% x = relative orientation of the bar/s, will be 0 when link or complimentary
% angle is set
% compangle = complimentary angle
% sf/tf used to get v (velocity)
%
% This version just gives the mean ratio between control and complimentary

for i=1:length(sep) %for each point in our data stream
	
	if sep(i)<1/sf(i) %wavelength bigger than separation
		meandiff(i)=nan;
	else
		v=tf(i)/sf(i); %get our velocity		
		
		%------- the linking angle
		
		y=0; %link case
		x=radians(-20:1:20); %matlab works in radians
		
		for j=1:length(x)
			deltat1(j)=(sep(i)*(sin(x(j)+y)-sin(y)))/v; %rowlands simplified equation
		end
		
		deltat1=deltat1*1000; %get into milliseconds
		
		%--------the Complimentary angle
		
		y=asin((1/sf(i))/sep(i)); %complimentary case
		xx=radians(-20:1:20); %matlab works in radians
		
		for j=1:length(xx)
			deltat2(j)=(sep(i)*(sin(xx(j)+y)-sin(y)))/v; %rowlands simplified equation
		end
		
		deltat2=deltat2*1000; %get into milliseconds
		
		meandiff(i)=mean(deltat1./deltat2);
		
	end
	
end

meandiff=meandiff';