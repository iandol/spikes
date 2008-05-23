function x=goodness(a,b,t)

% x=goodness(a,b,t)
%
% Does a standard squared goodness of fit, by calculating the residuals
% between a (the real data) and b (the model line) and squaring them. I 
% then compare the model against a line constructed from the mean of the 
% data, to get a percentage of variance explained by the model.
%
% t is whether to use the mean ('m'), mean fractional error ('mfe'),
% a spontaneous value ('number'), or r2 ('r2')
%
% Make sure both vectors have the same dimensions

if nargin < 3    
    t='m';
end    

switch t
    
case 'm'
    
    res=sum((a-b).^2);         %work out the raw residuals, square them, and then sum them    
    m=mean(a);                     %mean of the data    
    tot=sum((a-m).^2);         %work out the total sum of squares, which is the data-mean 
    
    x=(tot-res)/tot;           %work out the goodness of fit
    x=x*100;
        
case 'mfe'
    
    x=(sum((b-a).^2)/mean(b)^2)/length(b);
    
case 'r2'
    
    res=sum((a-b).^2);         %work out the raw residuals, square them, and then sum them    
    m=mean(a);                     %mean of the data    
    tot=sum((a-m).^2);         %work out the total sum of squares, which is the data-mean 
    
     x=1-(res/tot);
    
otherwise
    
    res=sum((a-b).^2);         %work out the raw residuals, square them, and then sum them    
    m=str2num(t);                 %mean of the data    
    tot=sum((a-m).^2);         %work out the total sum of squares, which is the data-mean 
    
    x=(tot-res)/tot;           %work out the goodness of fit
    x=x*100;
   
end

