% CORRPRCI: Independent (not simultaneous) asymptotic probabilities and 
%           confidence intervals for a correlation matrix.
%
%     Usage: [pr,CI_low,CI_high] = corrprci(R,n,{CI_level})
%
%         R =         [p x p] correlation matrix.
%         n =         sample size.
%         CI_level =  optional percentage width of confidence intervals 
%                       [default = 95].
%         -------------------------------------------------------------------
%         pr =        [p x p] symmetric matrix of 2-tailed significance levels.
%         CI_low =    [p x p] matrix of lower confidence bounds.
%         CI_high =   [p x p] matrix of upper confidence bounds.
%

% RE Strauss, 5/24/99
%   11/9/01 - set pr=NaN if r=NaN.

function [pr,CI_low,CI_high] = corrprci(R,n,CI_level)
  if (nargin < 3) CI_level = []; end;

  get_CI = 0;
  if (nargout > 1)
    get_CI = 1;
  end;

  if (isempty(CI_level))
    CI_level = 0.95;
  end;

  if (CI_level > 1)
    CI_level = CI_level/100;
  end;
  alpha2 = 1-((1-CI_level)/2);

  df = n-2;
  t = R.*sqrt(df./(1-(R-10*eps).^2));
  pr = 2*(1-tcdf(abs(t),df));
  [i,j] = find(~isfinite(R));
  if (~isempty(i))
    for k = 1:length(i)
      pr(i(k),j(k)) = NaN;
    end;
  end;

  if (get_CI)
    [z,stderr] = corrz(R,n);
    df = n-1;
    t = tinv(alpha2,df);
    CI_low =  tanh(z - t*stderr);
    CI_high = tanh(z + t*stderr);
  end;

  return;
