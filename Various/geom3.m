function [x,delta1,delta2]=geom3(sep,sf,tf)

%Rowlands complimentary angle model - there are several parameters:
%
% sep = separation of the cells (d in the original equation)
% x = relative orientation of the bar/s, will be 0 when link or complimentary
% angle is set
% y = angle between line connecting two fields and edge of bar/s
% tf/sf used to get v (velocity)

a=15;

v=tf/sf; %get our velocity

%-------------for the linking angle
y=0; 

x=radians(-a:a); %matlab works in radians

for i=1:length(x)
    deltat1(i)=(sep*(sin(x(i)+y)-sin(y)))/v; %rowlands simplified equation
end

x=degs(x); %get us back our degrees
deltat1=deltat1*1000; %get into milliseconds
%---------------------------------------

%------------for the complimentary angle
y=asin((1/sf)/sep);

xx=radians(-a:a); %matlab works in radians

for i=1:length(xx)
    deltat2(i)=(sep*(sin(xx(i)+y)-sin(y)))/v; %rowlands simplified equation
end

xx=degs(xx); %get us back our degrees
deltat2=deltat2*1000; %get into milliseconds
deltat2(find(deltat2==0))=0.00000001;
%----------------------------------------

meandiff=mean(deltat1./deltat2);

figure;
plot(x,deltat1,'k-o',xx,deltat2,'r-o');

ylabel('Time Difference (ms)')
xlabel('Relative Angle (degs)')
title(['Mean Difference: ' num2str(meandiff) ' for a seperation of ' num2str(sep) 'degs and SF of ' num2str(sf) 'c/d'])

legend('Linking Angle','Complimentary Angle',0)
