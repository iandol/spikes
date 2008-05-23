function f=gauss(p,x,y)

a=find(p==0);
p(a)=0.0000000000001;

for a=1:length(x);
	f(a,:)=p(5)+(p(1)*exp(-(((x(a)-p(3))^2)+((y-p(2)).^2))/(1*p(4))^2));  %halfmatrixhalfloop
end

ztmp = p(5)*(exp(-0.5*(X-p(1)).^2./(p(3)^2)-0.5*(Y-p(2)).^2./(p(4)^2))) - m;