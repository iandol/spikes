function [x,deltat1,deltat2]=geom6(sep,sf,tf)

%Wei's complimentary angle model Variant, - there are several parameters:
%
% sep = separation of the cells (d in the original equation)
% x = relative orientation of the bar/s, will be 0 when link or complimentary
% angle is set
% compangle = complimentary angle
% sf/tf used to get v (velocity)
%
% This version just gives the mean ratio between control and complimentary

v=tf/sf; %get our velocity

w=1/sf;

%------- the linking angle

compangle=0;
x=radians(-180:180); %matlab works in radians

for j=1:length(x)
	deltat1(j)=(sin(x(j))*sep)/v;; %wei limk case	
end

x=degs(x);
deltat1=deltat1*1000; %get into milliseconds

%--------the Complimentary angle

compangle=asin(w/sep); %work out our complimentary angle
xx=radians(-180:180); %matlab works in radian

for j=1:length(xx)
	if xx(j)<0
		deltat2(j)=(w-(sin(asin(w/sep)-xx(j))*sep))/v;
	else
		deltat2(j)=((sin(compangle+xx(j)))*(sep-(w/sin(compangle+xx(j)))))/v;		
	end
end

xx=degs(xx);
deltat2=deltat2*1000; %get into milliseconds

meandiff=mean(deltat1./deltat2);

figure
plot(x,deltat1,'k-o',xx,deltat2,'r-o')

xlabel('Relative Orientation (degs)')
ylabel('Time Difference (ms)')
title(['Mean Difference: ' num2str(meandiff) ' for a seperation of ' num2str(sep) 'degs and SF of ' num2str(sf) 'c/d'])

legend('Link Angle','Complimentary Angle',0)
