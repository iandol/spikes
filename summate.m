function [y,f]=summate(x,xdata)

% This generates a summation curve (y) using a DOG equation
% compatible with the optimisation toolbox.
%
% y=summate(x,xdata)
%
% x= the set of 4 parameters for the DOG model
%
% x(1) = centre amplitude
% x(2) = centre size
% x(3) = surround amplitude
% x(4) = surround size
% x(5) = DC level
%
% xdata = the x-axis values of the summation curve to model
%
% it will output a tuning curve from the model parameters

a=find(x==0);
x(a)=0.0000000000001;
for i=1:length(xdata)
    if xdata(i)==0
        sc(i)=x(5)+0;
    else
        %space=-xdata(i):xdata(i)/80:xdata(i);        % generate the 'stimulus'
        %f=(x(1)*exp(-space.^2/x(2)^2))-(x(3)*exp(-space.^2/x(4)^2));          % do the DOG!
        %sc(i)=trapz(space,f)+x(5);   % integrate area under the curve       
        space=(-xdata(i)/2):(xdata(i)/2)/(80-1):(xdata(i)/2);         % generate the 'stimulus'
        f=(x(1)*exp(-((2*space)/x(2)).^2))-(x(3)*exp(-((2*space)/x(4)).^2));
        sc(i)=x(5)+trapz(space,f);
    end
end

y=sc;


