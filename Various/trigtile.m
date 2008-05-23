function trigtile(symmetry,scale,trigsize);
%TRIGTILE  Create a tile figure made of interlocking polygons.
%
%   Parameters are symmetry,scale,size.
%     symmetry    : 3 to 20,  default  5.
%     scale       : 1 to 100, default  6.
%     trigsize    : 1 to 10,  default  1.
%
%   TRIGTILE with no arguments produces random symmetries and colors.
%   TRIGTILE(5,10,6) makes symmetry degree 5, scale 10, size 6 figure.
%
%   Written for Matlab 5.x
%   by Jim Clark E-Mail jclark01@pacbell.net
%   $Revision: 1.0 $  $Date: 1999/08/07 15:00:00 $
cla;
set (gcf,'Renderer','painters');
h = 1;
temp = rand * 2;
while (temp < .1)
   temp = rand * 2;
end
colormod = temp;
figure(h);
set(h,'DoubleBuffer','on');
if nargin == 0
   symmetry = fix(rand * 20 +.5); scale = 6;
   trigsize = 2;
   if symmetry < 7
      trigsize = 5;
   end   
   if symmetry < 4
      trigsize = 6;   
   end   
   if symmetry >10
      trigsize = 1;
   end
elseif nargin == 1
   scale = 6; trigsize = 1;
elseif nargin == 2
   trigsize = 1;
elseif nargin > 3
   error('Incorrect number of arguments')
end   
if symmetry > 20 
   symmetry = 20;
elseif symmetry < 3
   symmetry = 3;
end     
if scale > 100 
   scale = 100;
end
if scale < 1
   scale = 1;
end
if trigsize < 1
   trigsize = 1;   
end
%symmetry; trigsize;
axis([-scale scale -scale scale]);
symmetry = symmetry;
trigsize = trigsize;
if symmetry > 15
   trigsize = 1;
end
for k = 0 : 1 : symmetry-1
   a60(k+1) = 1/(symmetry-1);
   a61(k+1) = 0.0;
   factor = 2;
   if symmetry < 5
      factor = 1;
   end
   a66(k+1,1) = cos(k * factor * pi / symmetry);
   a66(k+1,2) = sin(k * factor * pi / symmetry);
end
odd = mod(symmetry,2);
if(symmetry == 4)
   odd = 1 - odd;
end
even = 1 - odd;
lcount = 0;
for i = 0:1:symmetry-2
   for j = i+1:1:symmetry-1
      if(odd |(even &(j ~= i + symmetry / 2)))
         lcount = lcount + 1;
         for i1 = 1:1:2 
            a63(1,i1) = a66(i+1,i1);
            a63(2,i1) = a66(j+1,i1);
         end
         d  =  a63(1,1) * a63(2,2) - a63(2,1) * a63(1,2);
         a59(1) = a60(i+1) + a61(i+1);
         a59(2) = a60(j+1) + a61(j+1);
         a64(1,1) =  a63(2,2) / d;
         a64(1,2) = -a63(1,2) / d;
         a64(2,1) = -a63(2,1) / d;
         a64(2,2) =  a63(1,1) / d;  
         for r = -trigsize : 1 : trigsize 
            for t = -trigsize : 1 : trigsize 
               temp1 = r - a59(1);
               temp2 = t - a59(2);
               temp3 = a64(1,1) * temp1 + a64(1,2) * temp2;
               temp4 = a64(2,1) * temp1 + a64(2,2) * temp2;
               for k = 0 : 1: symmetry-1
                  d=a66(k+1,1)*temp3+a66(k+1,2)*temp4+a60(k+1);
                  dt=int32(d);
                  dt = double(dt);
                  if(d < 0)
                     dt = dt - 1;
                  end   
                  a65(k+1) = dt + 1;
               end
               a65(i+1) = r;
               a65(j+1) = t;
               d  = 0;
               d1 = 0;
               for m = 0:1:symmetry-1
                  d  =  d  + a66(m+1,1) * a65(m+1);
                  d1 =  d1 + a66(m+1,2) * a65(m+1);
               end
               m = 0;
               for n = 1:1:2
                  for p = 1:1:2
                     m = m + 1;
                     x(m) = (d  + a63(1,1) * (n-1) + a63(2,1) * (p-1));
                     y(m) = (d1 + a63(1,2) * (n-1) + a63(2,2) * (p-1));
                  end
               end
               
               % color calculation        
               c2(1) = x(2) - x(1);
               c2(2) = y(2) - y(1);
               d3  = sqrt(c2(1) * c2(1) + c2(2) * c2(2));
               c2(1) = c2(1) / d3;
               c2(2) = c2(2) / d3;
               c3(1) = x(3) - x(1);
               c3(2) = y(3) - y(1);
               d3 = sqrt(c3(1) * c3(1) + c3(2) * c3(2));
               c3(1) = c3(1) / d3;
               c3(2) = c3(2) / d3; 
               d2 = acos(c2(1) * c3(1) + c2(2) * c3(2));
               if d2 < 0.0 
                  d2 = pi + d2;
               end
               color = d2 / 0.01745329;
               color = int32(color);
               color = double(color);
               if color == 135.0 & symmetry == 4
                  color = 45.0;
               end
               color = color*colormod;
               while (color > 64)
                  color = color - 64;
               end
               % drawing patch
               X1 = [x(1) x(2) x(4) x(3)];
               Y1 = [y(1) y(2) y(4) y(3)];
               h1 = patch(X1,Y1,color);
               set (h1, 'CDataMapping','direct');
            end
        end
     end
  end
end
lcount;
%'Trigtile Calculations Complete'  
% end of program 
