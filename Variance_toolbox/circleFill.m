
function h = circleFill(center,radius,color,width,edgeColor)

nums = 0:360;

x = center(1) + radius * cos(2*pi*nums/360);
y = center(2) + radius * sin(2*pi*nums/360);


h = fill(x,y,color);
set(h,'linewidth',width,'EdgeColor', edgeColor);