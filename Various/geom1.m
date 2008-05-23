% geom1.m
%
% Geometric model for the synchronisation of two cells by a drifting bar
%
r1 = 0.4;
r2 = 0.4;
w = 0.4;
d = 0.6:0.1:10;
%
hwhh = (360/(2*pi))*asin((w+2*r2)./(2*d));
%
figure;
plot(d,hwhh);
[v,i]=minim(d,2);
['The HWHH at ' num2str(v) 'deg is:' num2str(hwhh(i))]
axis([0 4 0 60]);
