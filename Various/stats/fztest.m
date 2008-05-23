function z=fztest(r1,n1,r2,n2)
% Fisher Z Test for correlation coefficients

r1=0.5*log((1+r1)/(1-r1));
r2=0.5*log((1+r2)/(1-r2));

z=(r1-r2)/sqrt((1/(n1-3))+(1/(n2-3)));