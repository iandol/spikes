function outv=addscatter(in,amount)
%adds amount of scatter for plotting, normal distribution

if nargin==1
	amount=10;
end

rn=(Scale(randn(size(in)))-0.5)*2;

maxx=max(max(in));

rn=rn*((maxx/100)*amount);

outv=in+rn;