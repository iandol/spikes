function [x,deltat1,deltat2]=geom5(sep,sf,tf)

%Wei's complimentary angle model, - there are several parameters:
%
% sep = separation of the cells (d in the original equation)
% x = relative orientation of the bar/s, will be 0 when link or complimentary
% angle is set
% compangle = complimentary angle
% tf/sf used to get v (velocity)
%
% This version just gives the mean ratio between control and complimentary

a=15;

v=tf/sf; %get our velocity

w=1/sf;

%------- the linking angle

compangle=0;
x=radians(-a:a); %matlab works in radians

for j=1:length(x)
	deltat1(j)=(sin(x(j))*sep)/v;; %wei limk case	
end

x=degs(x);
deltat1=deltat1*1000; %get into milliseconds

%--------the Complimentary angle

compangle=asin(w/sep); %work out our complimentary angle
xx=radians(-a:a); %matlab works in radians

for j=1:length(xx)	
	deltat2(j)=((sin(compangle+xx(j)))*(sep-(w/sin(compangle+xx(j)))))/v;
end

xx=degs(xx);
deltat2=deltat2*1000; %get into milliseconds
deltat2(find(deltat2==0))=0.000000001; %to stop divide-by-zero errors

meandiff=mean(deltat1./deltat2);

figure
plot(x,deltat1,'k-o',xx,deltat2,'r-o')

xlabel('Relative Orientation (degs)')
ylabel('Time Difference (ms)')
title(['Mean Difference: ' num2str(meandiff) ' for a seperation of ' num2str(sep) 'degs and SF of ' num2str(sf) 'c/d'])

legend('Link Angle','Complimentary Angle',0)
