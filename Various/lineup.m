function m=lineup(inp);
% lineup simply takes a matrix and turns it into a vector

s=size(inp);

if s(1) == 1 | s(2) == 1
    error('Sorry, needs a matrix')
end

s=(s(1)*s(2));
m=zeros(s,1);
for i=1:s
    m(i,1)=inp(i);
end

    


    