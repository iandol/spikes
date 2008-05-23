function x=goodness2(a,b,t)

% x=goodness2(a,b,t)
%
% Does a standard squared goodness of fit for 2D data, by calculating the residuals
% between a (the real data) and b (the model line) and squaring them. I 
% then compare the model against a line constructed from the mean of the 
% data, to get a percentage of variance explained by the model.
%
% t is whether to use the mean ('m'), mean fractional error ('mfe'), r
% squared ('r2'), or a spontaneous value ('number')
%
% Make sure both vectors have the same dimensions

if nargin < 3   
    t='m';
end    

switch t
	
case 'ss'
    
    x=sum(sum((a-b).^2));   %work out the raw residuals, square them, and then sum them
    
case 'm'
    
    res=sum(sum((a-b).^2));   %work out the raw residuals, square them, and then sum them
    m=mean(mean(a));          %mean of the data
    tot=sum(sum((a-m).^2));   %work out the total sum of squares, which is the data-mean 
    
   x=(tot-res)/tot;      %work out the goodness of fit
   x=x*100;
        
case 'mfe'    
    
    x=(sum(sum(((b-a).^2)))/mean(mean(b)).^2)/(size(a,1)*size(a,2));
    
case 'r2'
    
    res=sum(sum((a-b).^2));   %work out the raw residuals, square them, and then sum them
    m=mean(mean(a));             %mean of the data
    tot=sum(sum((a-m).^2));   %work out the total sum of squares, which is the data-mean 
    
    x=1-(res/tot);
    
otherwise
    
    res=sum(sum((a-b).^2));         %work out the raw residuals, square them, and then sum them
    m=str2num(t);                            %mean of the data
    tot=sum(sum((a-m).^2));         %work out the total sum of squares, which is the data-mean 
    
    x=(tot-res)/tot;                         %work out the goodness of fit
    x=x*100;
        
end

