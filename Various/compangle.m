function angle=compangle(sf,sep)

angle=asin((1/sf)/sep);

angle=degs(angle);

sep=0:0.1:4;


for i=1:length(sep)
    ang(i)=asin((1/sf)/sep(i));
end

ang=degs(ang);

figure;
plot(sep,ang)
xlabel('Separation')
ylabel('Complimentary Angle')