function padaxis(axish,amount)

if nargin<1
	axish=gca;
end
if nargin<2
	amount=0.1;
end

limits=axis(axish);
xrange=abs(limits(2)-limits(1))*amount;
yrange=abs(limits(4)-limits(3))*amount;

newlimits=[limits(1)-xrange limits(2)+xrange limits(3)-yrange limits(4)+yrange];
axis(axish,newlimits);