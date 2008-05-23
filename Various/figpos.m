function figpos(position,size);

if nargin<1;
	position=1;
end
if nargin<2;
	pos=get(gcf,'Position');
	size=[pos(3) pos(4)];
end

scr=get(0,'ScreenSize');
width=scr(3);
height=scr(4);

switch(position)	
case 1 %centre it	
	x=(width/2)-(size(1)/2);
	y=(height/2)-((size(2)+40)/2);
	if x<1 x=0; end
	if y<1 y=0; end
	set(gcf,'Position',[x y size(1) size(2)]);
case 2 %a third off
	x=(width/3)-(size(1)/2);
	y=(height/2)-(size(2)/2);
	if x<1 x=0; end
	if y<1 y=0; end
	set(gcf,'Position',[x y size(1) size(2)]);
end