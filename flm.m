function x=flm(y)

z=1;
for i=1:10
   a=y/i;
   if ceil(a)/a==1
      x(z)=i;
      z=z+1;
   end
end

for i=1:max(size(x))
   m(i)=y/x(i);
end

n=abs(m-x);

[o,i]=min(n);

x=x(i);
   
   