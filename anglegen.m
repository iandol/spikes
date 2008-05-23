angle=[0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
distance=linspace(25,31,16);

figure
for i=1:16
   opp(i)=tan(radians(angle(i)))*30;
end
plot(angle,opp)
xlabel('Angle (degs)')
ylabel('Distance on Surface (mm)')
figure
for i=1:16
   opp(i)=tan(radians(10))*distance(i);
end
plot(distance,opp)
xlabel('Depth (mm)')
ylabel('Distance on Surface (mm)')


