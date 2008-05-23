function [v,i]=minim(data,value)

%MINIM        [value,index]=minim(data,val)
%
%     Finds the closest number in a data vector to the value specified

v=0;
x=inf;

for j=1:max(size(data));
   s=abs(data(j)-value);
   if s<=x
      x=s;
      v=data(j);
   end
end

i=find(data==v);

