function [x,deltat1,deltat2]=geom4(sep,sf,tf)

%Wei's complimentary angle model, - there are several parameters:
%
% sep = separation of the cells (d in the original equation)
% x = relative orientation of the bar/s, will be 0 when link or complimentary
% angle is set
% compangle = complimentary angle
% sf/tf used to get v (velocity)
%
% This version just gives the mean ratio between control and complimentary

a=30;
v=tf/sf; %get our velocity

w=1/sf;

compangle=asin(w/sep); %work out our complimentary angle

%------- the linking angle

x=radians(-a:a); %matlab works in radians

for j=1:length(x)
	deltat1(j)=(sin(x(j))*sep)/v; %wei limk case
end

x=degs(x);
deltat1=deltat1*1000; %get into milliseconds

%--------the Complimentary angle

xx=radians(-a:a); %matlab works in radians

for j=1:length(xx)
	deltat2(j)=(sin(compangle+xx(j))*(sep-(1/sf)))/v; %wei complimentary cas
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
