function trigart(symmetry,randomness,triangulate,trigsize,symcolor);
%TRIGART  Create an artistic drawing made of interlocking polygons.
%
%   Parameters are symmetry,randomness,triangulate,size.
%     symmetry    : 4 to 10, default  5.
%     randomness  : 0 to 20, default 10.
%     triangulate : 0 to  1, default  1.
%     trigsize    : 5 to 10, default  6.
%     symcolor    : 0 to  1, default  0.
%
%   TRIGART with no arguments produces random symmetries and colors.
%   TRIGART(5,0,0,6,0) makes symmetry degree 5, size 6 figure.
%   TRIGART(5,4,0,6,0) omits rand * 4 lines. 
%   TRIGART(5,4,1,6,0) trianglates all polygons.
%   TRIGART(5,4,1,8,0) creates a size 8 figure.
%   TRIGART(5,4,1,8,1) colors symmetrically.
%
%   Written for Matlab 5.x
%   by Jim Clark E-Mail jclark01@pacbell.net
%   $Revision: 1.0 $  $Date: 1999/08/08 15:00:00 $
global cmx1 cmx2 cmx3 cmy1 cmy2 cmy3 X1 Y1 hm;
cmx1 = []; cmx2 = []; cmy3 = [];
cmy1 = []; cmy2 = []; cmy3 = [];
X1 = []; Y1 = []; color = rand;
count = 0;
cla;
%symcolor=0;
%hold on;
icolor = rand * 128 ;
set (gcf,'Renderer','painters');
h = 1;
figure(h);
set(h,'DoubleBuffer','on');
%axis([0 9 4 13]);
if nargin == 0
   symmetry = fix(3+7 * rand + .5); 
   randomness = fix(20 * rand); 
   triangulate = fix(rand + .5); 
   trigsize = fix(5.5+rand*5);
   symcolor = 0;
elseif nargin == 1
   symcolor = 0;
	randomness = 10; triangulate = 1; trigsize = 5;
elseif nargin == 2
   symcolor = 0;
   triangulate = 1; trigsize = 5;
elseif nargin == 3
   symcolor = 0;
   trigsize = 5;
elseif nargin == 4
   symcolor = 0;
elseif nargin > 5
   error('Incorrect number of arguments')
end   
if symmetry > 10 
   symmetry = 10;
elseif symmetry < 3
   symmetry = 3;
end   
if randomness > 30  
   randomness = 30
elseif randomness < 0
   randomness = 0      
end    
if triangulate ~= 0 & triangulate ~= 1
      triangulate = 1;
end      
if trigsize > 30 
   trigsize = 30;
elseif trigsize < 1
   trigsize = 1;   
end
if symcolor ~= 0
   symcolor = 1;
end
halfmax = fix(trigsize/2);
factor = 2;
if (symmetry == 4)
   factor = 1;
end
step = 1;
for t=0:1:symmetry-1 %1
phi = ((t*pi*factor)+(pi*5*symmetry/180))/symmetry;
%pp = phi*180/pi  
vx(t+1) = cos(phi);
vy(t+1) = sin(phi);
mm(t+1) = vy(t+1)/vx(t+1);
for r=0:1:trigsize-1 %2
y1 = vy(t+1)*(t*0.1132) - vx(t+1)*(r-halfmax);  % offset 
x1 = vx(t+1)*(t*0.2137) + vy(t+1)*(r-halfmax);
b(t+1,r+1) = y1 - mm(t+1)*x1;		              % intercept 
end %2
end %1

% t is 1st direction, r is 2nd.  look for intersection between
% pairs of lines in these two directions. (will be x0,y0) 

% color = 0.2;
themax = fix(trigsize-1);
themin = fix(themax/2);
for minmin=0:step:themax %1 for
	rad1 = minmin*minmin;
	rad2 = (minmin+step)*(minmin+step);
	for n=1:1:themax-1 %2 for
		for m=1:1:themax-1 %3 for
			rad = (n-themin)*(n-themin)+(m-themin)*(m-themin);
         if rad >= rad1 & rad < rad2 %4  
            for t=0:1:symmetry-2 %5 for
               for r=t+1:1:symmetry-1 %6 for
                  x0 = (b(t+1,n+1) - b(r+1,m+1))/(mm(r+1)-mm(t+1));
                  y0 = mm(t+1)*x0 + b(t+1,n+1);
                  flag = 0;
                  for i=0:1:symmetry-1 %7 for
                     if i ~= t & i ~= r %8  
                        dx = -x0*vy(i+1)+(y0-b(i+1,1))*vx(i+1);
                        index(i+1) = fix(-dx);
                        if ((index(i+1)>(trigsize-3))|(index(i+1)<1)) %9
                           flag=1;
                        end %9
                     end %8
                  end %7
                  if flag==0 %7  
                     index(t+1) = n-1;    
                     index(r+1) = m-1;
                     x0 = 0;          
                     y0 = 0;
                     for i=0:1:symmetry-1 %8  
                        x0 = x0 + vx(i+1)*index(i+1);
                        y0 = y0 + vy(i+1)*index(i+1);
                     end %8
                     if symcolor == 0
                        color = color + rand*64;
                     while (color > 64)
                           color = color - 64;
                     end   
                     elseif (symcolor==1)  %8
                        %dot product
                        color=icolor*abs(vx(t+1)*vx(r+1)+vy(t+1)*vy(r+1));
                        while (color > 64)
                           color = color - 64;
                        end
                      end %9

                     pplot(x0,y0,0, color,randomness,triangulate,count);
                     x0 = x0 + vx(t+1);  
                     y0 = y0 + vy(t+1);
                     pplot(x0,y0,1,color,randomness,triangulate,count);
                     x0 = x0 + vx(r+1);  
                     y0 = y0 + vy(r+1);
                     pplot(x0,y0,1,color,randomness,triangulate,count);
                     x0 = x0 - vx(t+1);  
                     y0 = y0 - vy(t+1);
                     pplot(x0,y0,1,color,randomness,triangulate,count);
                     x0 = x0 - vx(r+1);
                     y0 = y0 - vy(r+1);
                     pplot(x0,y0,2,color,randomness,triangulate,count);
                   end %7
               end %6
            end %5
         end %4
      end %3
   end %2
end %1
%'Trigart Calculations Complete'   

function pplot(cmx,cmy,plotflag, color,randomness,triangulate,count)
global cmx1 cmx2 cmx3 cmy1 cmy2 cmy3 X1 Y1 hm;
%drawnow;
xx = cmx;
yy = cmy;
a = -pi*5/180;
cmx = xx * cos(a) - sin(a)*yy;
cmy = xx * sin(a) + cos(a)*yy;
if plotflag < 1 % 0=start line; 1=lineto; 2=endpoint  
   cmx1 = cmx; cmx2 = cmx; cmx3 = cmx;
   cmy1 = cmy; cmy2 = cmy; cmy3 = cmy;
   count = 0;
else %1
   if triangulate == 1
      cmx3 = []; cmy3 = []; cmz3 = [];
   else
      cmz3 = 0;
   end
   count = count + 1;
   
   if count>rand*randomness   
      X1 = [cmx cmx1 cmx2 cmx3];
      Y1 = [cmy cmy1 cmy2 cmy3];
      hm = patch(X1,Y1,color);
      set (hm, 'CDataMapping','direct');
      count = 0;
   end
   cmx3 = cmx2; cmx2 = cmx1; cmx1 = cmx;
   cmy3 = cmy2; cmy2 = cmy1; cmy1 = cmy;
end
