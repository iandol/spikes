function [h,p,ci,stats] = ttst2(x,y,alpha,tail)
%TTEST2 Hypothesis test: Compares the averages of two samples.
%   [H,P,CI,STATS] = TTEST2(X,Y,ALPHA,TAIL) performs a t-test to
%   determine whether two samples from a normal distribution (with
%   unknown but equal variances) could have the same mean.
%
%   The null hypothesis is: "means are equal".
%   For TAIL =  0  the alternative hypothesis is: "means are not equal."
%   For TAIL =  1, alternative: "mean of X is greater than mean of Y."
%   For TAIL = -1, alternative: "mean of X is less than mean of Y."
%   TAIL = 0 by default.
%
%   ALPHA is desired significance level (ALPHA = 0.05 by default). 
%   P is the p-value, or the probability of observing the given result
%     by chance given that the null hypothesis is true. Small values
%     of P cast doubt on the validity of the null hypothesis.
%   CI is a confidence interval for the true difference in means.
%   STATS is a structure with two elements named 'tstat' (the value
%     of the t statistic) and 'df' (its degrees of freedom).
%
%   H=0 => "Do not reject null hypothesis at significance level of alpha."
%   H=1 => "Reject null hypothesis at significance level of alpha."

%   References:
%      [1] E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, 1970, section 13.4. (Table 13.4.1 on page 210)

if nargin < 2, 
    error('Requires at least two input arguments'); 
end

[m1 n1] = size(x);
[m2 n2] = size(y);
if (m1 ~= 1 & n1 ~= 1) | (m2 ~= 1 & n2 ~= 1)
    error('Requires vector first and second inputs.');
end
x = x(~isnan(x));
y = y(~isnan(y));
 
if nargin < 4, 
    tail = 0; 
end 

if nargin < 3, 
    alpha = 0.05; 
end 

if (prod(size(alpha))>1), error('ALPHA must be a scalar.'); end
if (alpha<=0 | alpha>=1), error('ALPHA must be between 0 and 1.'); end

dfx = length(x) - 1;
dfy = length(y) - 1;
dfe  = dfx + dfy;
msx = dfx * var(x);
msy = dfy * var(y);

difference = mean(x) - mean(y);
pooleds    = sqrt((msx + msy) * (1/(dfx + 1) + 1/(dfy + 1)) / dfe);

ratio = difference / pooleds;
if (nargout>3), stats = struct('tstat', ratio, 'df', dfe); end

% Find the p-value for the tail = 1 test.
p  = 1 - ttcdf(ratio,dfe);

% Adjust the p-value for other null hypotheses.
if (tail == 0)
    p = 2 * min(p, 1-p);
    spread = tinvert(1 - alpha / 2,dfe) * pooleds;
    if (nargout>2), ci = [(difference - spread) (difference + spread)]; end
else
    spread = tinvert(1 - alpha,dfe) * pooleds;
    if (tail == 1)
       if (nargout>2), ci = [(difference - spread), Inf]; end
    else
       p = 1 - p;
       if (nargout>2), ci = [-Inf, (difference + spread)]; end
    end
end

% Determine if the actual significance exceeds the desired significance
h = 0;
if p <= alpha, 
    h = 1; 
end 

if isnan(p), 
    h = NaN; 
end
