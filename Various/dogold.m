%DOG - difference of gaussian model -adjust parameters by editing the file and run

kc=50;
ks=.85;  %smaller=stronger
rc=1
rs=1.3
%r=-3:0.1:3

%xval=10;
%yval=10;
step=0.1;

% for 1-D
%for i=1:size(r,2)
%   s(i)=kc*exp(-(r(i)/rc).^2)-ks*exp(-(r(i)/rs).^2);
%end
%f(a,b)=kc/(pi*rc.^2)*exp(-(x(b).^2+y(b).^2)*rc.^2)...
%        -ks/(pi*rs.^2)*exp(-(x(b).^2+y(b).^2)*rs.^2);

%x=-xval:0.1:xval;
%y=-yval:0.1:yval;
%for a=1:size(x,2);
%   for b=1:size(x,2);
%      g(a,b)=kc*(rc.^-2)*(pi.^-1)*exp((-(x(a).^2+y(b).^2)/rc.^-2));
%   end
%end


%x=-xval:0.1:xval;
%y=-yval:0.1:yval;
%for a=1:size(x,2);
%   for b=1:size(x,2);
%      h(a,b)=(-ks*(rs.^-2)*(pi.^-1)*exp((-(x(a).^2+y(b).^2))/rs.^-2));
%   end
%end

x=-7:step:7;
y=-7:step:7;
for a=1:size(x,2);
   for b=1:size(y,2);
      f(a,b)=kc*(rc.^-2)*(pi.^-1)*exp((-(x(a).^2+y(b).^2)/rc.^-2))+(-ks*(rs.^-2)*(pi.^-1)*exp((-(x(a).^2+y(b).^2))/rs.^-2));
   end
end

[xx,yy]=meshgrid(x,y);
a=f; % or for 2 rf's a=[f f];
figure;
size(a)
whos
surf(xx,yy,a);
shading interp
lighting phong
camlight left
axis tight
axis square
axis vis3d
xlabel('x (deg)')
ylabel('y (deg)')

%figure
%subplot(1,2,1);
%surf(x,y,g);
%shading interp
%axis tight
%axis vis3d
%xlabel('x')
%ylabel('y')

%subplot(1,2,2);
%surf(x,y,h);
%shading interp
%axis tight
%axis vis3d
%xlabel('x')
%ylabel('y')
