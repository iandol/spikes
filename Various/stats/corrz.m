% CORRZ: Fisher's z-transform of Pearson's correlation coefficient, its 
%        standard error, and 2-tailed probability of H0:rho=0.
%
%        Optionally applies Hotelling's (1953) small-sample modification
%        if sample size is provided, which is useful if the z-values are
%        to be analyzed but not back-transformed.
%
%        The inverse transformation is r = tanh(z).
%
%     Syntax: [Z,stderr,prob] = corrz(R,{N},{adjust})
%
%        R =      matrix of correlations.
%        N =      scalar sample size (applied to all correlations), or a
%                   corresponding matrix of sample sizes.  If N is not provided,
%                   the z-values are uncorrected.
%        adjust = boolean flag indicating whether Hotelling's modification is 
%                   (=1) or is not (=0) to be applied [default=1 if N is 
%                   supplied, 0 if not].
%        -----------------------------------------------------------------------
%        Z =      corresponding matrix of z-transformed values.
%        stderr = standard errors of Z, if sample sizes are provided.
%                   Returned as matrix of the same size as N.
%        prob =   corresponding matrix of significance levels for the test 
%                   against rho=0, returned if sample sizes are provided.
%

% Hotelling, H. 1953. New light on the correlation coefficient and its
%   transforms.  J.Roy.Stat.Soc.(B) 15:193.232

% RE Strauss, 2/18/97
%   5/25/99 - modified use of arguments and flags; changed df as per Sokal & 
%               Rohlf (1981).
%   6/15/00 - corrected problem with Hotelling modification when N isn't given.
%  10/28/04 - changed df from N-2 to N-3.

function [Z,stderr,prob] = corrz(R,N,adjust)
  if (nargin < 2) N = []; end;
  if (nargin < 3) adjust = []; end;

  got_sampsize = 0;
  get_stderr = 0;
  get_prob = 0;

  if (nargout > 1)
    get_stderr = 1;
  end;
  if (nargout > 2)
    get_prob = 1;
  end;

  if (~isempty(N))
    got_sampsize = 1;
  end;
  if (isempty(adjust))
    if (got_sampsize)
      adjust = 1;
    else
      adjust = 0;
    end;
  end;

  stderr = [];
  prob = [];

  if (get_stderr & ~got_sampsize)
    if (~got_sampsize)
      disp('  CORRZ Warning: no standard errors or probabilities without sample sizes');
    end;
  end;

  % Check and expand sample-size matrix

  if (got_sampsize)
    [rn,cn] = size(N);
    [rr,cr] = size(R);
    if (max([rn,cn]) > 1)             % If sample size is a matrix,
      if (rr~=rn | cr~=cn)              % Check its size
        error('  Error: correlation and sample-size matrices not compatible');
      end;
    end;
  end;

  % Check for extreme correlations
  
  o = 1-abs(R) < eps;                 % Check for pos/neg ones
  if (sum(sum(o)))
    R(o) = (1-eps) .* sign(R(o));     %   Replace with near-ones
  end;

  % Fisher transform

%   Z = 0.5 * log((1+R)./(1-R));
  Z = atanh(R);

  if (~adjust & got_sampsize)
    df = N-3;
    stderr = 1./sqrt(df);             % Standard errors

    if (get_prob)
      ts = Z ./ stderr;                 % Test statistic
      prob = 2*normcdf(-abs(ts),df);    % 2-tailed probabilities
    end;
  end;

  % Hotelling's correction

  if (adjust & got_sampsize)
    df = N-1;
    dZ = ((3*Z + Z)./(4*df)) - ((23*Z + 33*R - 5*R.^3)./(96*df.^2));
    Z = sign(Z) .* (abs(Z) - dZ);     % Adjust Z toward zero

    stderr = 1./sqrt(df);             % Standard errors

    if (get_prob)
      ts = Z ./ stderr;               % Test statistic
      prob = 2*tcdf(-abs(ts),df);     % 2-tailed probabilities
    end;
  end;

  return;
