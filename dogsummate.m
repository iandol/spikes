function [y,f]=dogsummate(x,xdata,data,ROG,rectify)

% This generates a summation curve (y) using a DOG equation
% compatible with the optimisation toolbox.
%
% y=summate1(x,xdata)
%
% x= the set of parameters for the DOG model
%
% x(1) = centre amplitude
% x(2) = centre size
% x(3) = surround amplitude
% x(4) = surround size
% x(5) = DC level
% x(6) = Shift Parameter
% x(7) = Center offset
%
% xdata = the x-axis values of the summation curve to model
%
% it will output a tuning curve from the model parameters

if nargin < 2
	xdata=0:0.5:9;
end
if nargin < 3
	data=[];
end
if nargin < 4
	ROG=0;
end
if nargin < 5
	rectify = 0;
end
if length(x)==4
	x(5)=0;
	x(6)=0;
end
if length(x)==5
	x(6)=0;
end
if length(x)==6
	x(7)=0;
end

a=find(x==0);
x(a)=0.0000000000001;

for i=1:length(xdata)
	if xdata(i)==0
		sc(i)=x(5)+0;
	else
		%------------old code
		%space=-xdata(i):xdata(i)/80:xdata(i);        % generate the 'stimulus'
		%f=(x(1)*exp(-space.^2/x(2)^2))-(x(3)*exp(-space.^2/x(4)^2));          % do the DOG!
		%sc(i)=trapz(space,f)+x(5);   % integrate area under the curve
		%--------------------
		
		%------------current code
% 		space=(-xdata(i)/2):(xdata(i)/2)/(80-1):(xdata(i)/2);         % generate the 'stimulus'
% 		switch ROG
% 			case 0
% 				f=(x(1)*exp(-((2*space)/x(2)).^2))-(x(3)*exp(-((2*space)/x(4)).^2));
% 			case 1
% 				f=(x(1)*exp(-((2*space)/x(2)).^2))./(x(3)*exp(-((2*space)/x(4)).^2));
% 		end
		%-------------------------
		
		space=(-xdata(i)/2):(xdata(i)/2)/(80-1):(xdata(i)/2);         % generate the 'stimulus'
		space = space + x(7);
		switch ROG
			case 0
				f=(x(1)*exp(-((2*space)/x(2)).^2))-(x(3)*exp(-((2*space)/x(4)).^2));
			case 1
				f=(x(1)*exp(-((2*space)/x(2)).^2))./(x(3)*exp(-((2*space)/x(4)).^2));
		end
		
		sc(i)=x(5)+trapz(space,f);
	end
end

if x(6)>0.0000000000001                                        %this does the rectification for small diameter non-linearity
	[m,i]=minim(xdata,x(6));
	if m>0
		sc(1:i)=x(5);
	end
end

if rectify == 1
	sc(sc<0) = 0;
end

if ~isempty(data)
	y=sum((data-sc).^2);  %percentage
else
	y=sc;
end

if x(5)<0 %this is to stop the nlinfit, which has no upper or lower bounds to not select negative spontaneous levels.by making the fit really bad
	y=y/1000;
end