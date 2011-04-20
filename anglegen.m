angle=[0:15];
distance=linspace(19,31,16);
depth = 22;
singleangle = 5;

figure
subplot(1,2,1)
for i=1:16
   opp(i)=tan(radians(angle(i)))*depth;
end
plot(angle,opp)
set(gca,'FontSize',15)
xlabel('Angle (degs)')
ylabel(['Distance on Surface (mm) assuming LGN depth at: ' num2str(depth) 'mm']);


subplot(1,2,2)
for i=1:16
   opp(i)=tan(radians(singleangle))*distance(i);
end
plot(distance,opp)
set(gca,'FontSize',15)
xlabel('Depth (mm)')
ylabel(['Distance on Surface (mm) assuming ' num2str(singleangle) 'deg electrode angle'])


