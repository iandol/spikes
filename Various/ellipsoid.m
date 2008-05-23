% ellipsoid.m   Create a 3-d ellipsoid showing a face into the axis of rotation
%  n.garfield		Sept 1997
clf
a = 200;
b = 150;
e = sqrt(a*a - b*b)/a;

k = 6;
n = 2^k - 1;
q=13;

theta = pi*(-n+2*q:2:n)/n;		% need an equal number of theta and phi values
phi = pi/2*(-(n-q):2:n-q)'/(n-q);% theta is columns, phi is rows

x = cos(phi)*cos(theta);	% build the open ellipsoid
y = cos(phi)*sin(theta);
z = sin(phi)*(ones(size(theta)).*(e));
[nr,nc] = size(x);

ra(1,3) = max(z(:,1))+.15;	% create the rotational axis
ra(2,3) = min(z(:,1))-.15;

th2 = pi*(-(n-5):2:n-5)'/n;	% create the rotational arrow
[thr thc] = size(th2);
th2(:,2) = ones(thr,1).*phi(nr-3);
th2(:,3) = cos(th2(:,2)).*cos(th2(:,1));
th2(:,4) = cos(th2(:,2)).*sin(th2(:,1));
th2(:,5) = ones(thr,1).*ra(1,3);
th2(thr+1,3) = th2(thr-3,3);	% create the arrow head
th2(thr+2,3) = th2(thr,3);
th2(thr+3,3) = th2(thr-3,3);
th2(thr+1,4) = th2(thr-3,4);
th2(thr+2,4) = th2(thr,4);
th2(thr+3,4) = th2(thr-3,4);
th2(thr+1,5) = th2(thr,5)+.04;
th2(thr+2,5) = th2(thr,5);
th2(thr+3,5) = th2(thr,5)-.04;

fox = x(:,1);	% create a polygon for one face
foy = y(:,1);
foz = z(:,1);
fox(nr+1,1) = x(1,1);	% close the polygon
foy(nr+1,1) = y(1,1);
foz(nr+1,1) = z(1,1);
ftx = x(:,nc);		% create the second polygon for the other face
fty = y(:,nc);
ftz = z(:,nc);
ftx(nr+1,1) = x(1,nc);	% close the polygon
fty(nr+1,1) = y(1,nc);
ftz(nr+1,1) = z(1,nc);

epv = min(ftx);
epi = find(ftx==epv);
epm = zeros(2,3);
epm(2,:) = [ftx(epi,1) fty(epi,1) ftz(epi,1)]; % equatorial plane on face 2

ftax = ftx(1:epi,1);	% fudge to get the equatorial plane to draw
ftay = fty(1:epi,1);
ftaz = ftz(1:epi,1);
ftax(epi+2,1) = ftax(1,1);
ftay(epi+2,1) = ftay(1,1);
ftaz(epi+2,1) = ftaz(1,1);
ftbx = ftx(epi:nr,1);
ftby = fty(epi:nr,1);
ftbz = ftz(epi:nr,1);
[tr tc] = size(ftbx);
ftbx(tr+2,1) = ftbx(1,1);
ftby(tr+2,1) = ftby(1,1);
ftbz(tr+2,1) = ftbz(1,1);

					% plotting
%F = surf(x,y,z);
F = surfl(x,y,z);
set(F,'BackFaceLighting','unlit')
set(F,'FaceLighting','gouraud')
hold on
view(-45,10)
fill3(fox,foy,foz,[.75 .75 .75])	% face one
fill3(ftx,fty,ftz,'w')			% face two at theta=0;
%fill3(ftax,ftay,ftaz,'w')		% half face two to get equatorial line
%fill3(ftbx,ftby,ftbz,'w')		% half face tow
ha =line(ra(:,1),ra(:,2),ra(:,3));	% rotational axis (vertical)
set(ha,'Color','k')
hr = line(th2(:,3),th2(:,4),th2(:,5));	% rotational circular arrow 
he = line(epm(:,1),epm(:,2),epm(:,3));	% equatorial axis
set(he,'Color','b')
%axis square
axis equal
xlabel('x')
ylabel('y')
zlabel('z')
t1=text(-.72, 0, .25,'Semiminor axis\rightarrow','HorizontalAlignment','left');
t2=text(-.8, 0, -.04,'\uparrowSemimajor axis','HorizontalAlignment','left');
set(t2,'Rotation',9.25)
title('ellipsoid of rotation')


