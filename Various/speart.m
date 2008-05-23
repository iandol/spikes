function [rs,t]=speart(x,y)

% Spearmans rs correlation

if length(x)~=length(y)
   error('Wrong input size')
end

n=length(x);
r1=ranks(x);
r2=ranks(y);

c=(r1-mean(r1));
d=(r2-mean(r2));
a=sum(c.*d);
b=((sqrt(sum((r1-mean(r1)).^2)))*(sqrt(sum((r2-mean(r2)).^2))));
rs=a/b;

t=rs.*sqrt((n-2)/(1-rs.^2));
