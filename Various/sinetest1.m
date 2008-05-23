% sinetest1.m
%
a = -0.25;
b = pi/4;
x = sin(.01:.01:10*pi)+a*(cos(b*pi +(.02:.02:20*pi)).^2);
x(find(x<=0.2))=0.2;
figure(1);
plot(x)
x2 = xcorr(x,400);
figure(2);
plot(x2)
x3 = sin(.01:.01:10*pi);
x3(find(x3<=0.2))=0.2;
figure(3)
plot(x3)
x4 = xcorr(x3,400);
figure(2)
hold on
plot(x4*(max(x2)/max(x4)),'r')
