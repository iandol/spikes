% ANOVA: Single-classification unbalanced fixed-effects analysis of variance.
%        Optionally randomizes the observations among groups to determine
%        the significance level of F (Manly, 1991, 64-90).  Deletes missing data.
%
%   Syntax: [F,pr,df,ss,ms,varcomp,varprop] = anova(x,grps,{iter},{CI_level})
%
%         x =         [n x 1] observations for a single variable.
%         grps =      [n x 1] classification variable.
%         iter =      optional number of randomization iterations [default = 0].
%         CI_level =  percentage confidence level for bootstrapped variance
%                       components [default = 95].
%         -------------------------------------------------------------------------
%         F =         observed F-statistic value.
%         pr =        significance level of the test, either asymptotic (if iter=0)
%                       or randomized (if iter>0).
%         df =        [3 x 1] vector of degrees of freedom (among-group,
%                       within-group, total).
%         ss =        [3 x 1] vector of sums-of-squares (among-group, within-group,
%                       total).
%         ms =        [2 x 1] vector of mean-squares (among-group, within-group).
%         varcomp =   [2 x 1 vector of variance-component estimates (among-group,
%                       within-group), or [2 x 3] matrix if bootstrapped
%                       (row 1 = estimates, row 2 = lower confidence limits,
%                       (row 3 = upper confidence limits).
%         varprop =   [2 x 1] vector of variance components as proportions of
%                       total (among-group, within-group), or [2 x 3] matrix if
%                       bootstrapped (as with varcomp).
%

% RE Strauss, 9/26/96
%   5/13/99 - miscellaneous improvements.
%   3/24/00 - check ranges of variance proportions.
%   8/1/01  - delete missing data.

function [F,pr,df,ss,ms,varcomp,varprop] = anova(x,grps,iter,CI_level)
  if (nargin < 3) iter = []; end;
  if (nargin < 4) CI_level = []; end;

  get_resvect = 0;
  get_varcomps = 0;

  if (nargout > 2)
    get_resvect = 1;
  end;
  if (nargout > 5)
    get_varcomps = 1;
  end;

  if (isempty(iter))
    iter = 0;
  end;
  if (isempty(CI_level))
    CI_level = 0.95;
  end;

  if (CI_level > 1)
    CI_level = CI_level/100;
  end;
  alpha = 1 - CI_level;

  [n,p] = size(x);
  if (n==1)                           % Input must be column vector
    x = x';
    [n,p] = size(x);
  elseif (p>1)
    error('  ANOVA: Dependent variable must be a vector.');
  end;
  
  i = find(isfinite(x));
  x = x(i);
  grps = grps(i);
  [n,p] = size(x);

  % Statistics independent of group composition

  G = design(grps);                   % Design matrix
  ngrps = size(G,2);                  % Number of groups

  if (ngrps<1)
    error('  ANOVA: Must have more than one group.');
  end;

  totmean = mean(x)*ones(n,1);        % Matching vector of grand means
  y = x - totmean;                    % Deviations from grand mean
  ssto = y'*y;                        % Total sum-of-squares

  dfto = n-1;                         % Total df
  dfa  = ngrps-1;                     % Among-group df
  dfe  = dfto - dfa;                  % Within-group df

  % Statistics dependent on group composition

  gbar = inv(G'*G)*G'*x;              % Group means
  xbar = G*gbar;                      % Matching vector of group means
  e = x - xbar;                       % Deviations from group means

  sse = e'*e;                         % Within-group sum-of-squares
  ssa = ssto - sse;                   % Among-group sum-of-squares

  msa = ssa / dfa;                    % Among-group mean-squares
  mse = sse / dfe;                    % Within-group mean-squares
  F = msa / mse;                      % Observed F-statistic

  % Estimates of variance components

  if (get_varcomps)
    gn = diag(G'*G);                    % Group sample sizes
    n0 = (1/(ngrps-1)) * (sum(gn)-(gn'*gn/sum(gn)));
    s2e = mse;
    s2a = (msa-mse)/n0;
    s2to = s2a + s2e;
    varcomp = [s2a; s2e];
    varprop = [s2a/s2to; s2e/s2to];
  end;

  % Output matrices

  if (get_resvect)
    df = [dfa dfe dfto]';
    ss = [ssa sse ssto]';
    ms = [msa mse]';
  end;

  % Significance level of observed F-statistic

  if (iter==0)                        % Asymptotic significance level
    pr = 1 - fcdf(F,dfa,dfe);
  else                                % Randomized significance level
    [ci,pr] = bootstrp('anovaf',[0,1,0],iter,alpha,x,grps,0,1,0);
  end;

  % Bootstrap variance components

  if (get_varcomps & iter>0)
    ci = bootstrp('anovaf',[1,0,0],iter,alpha,x,grps,0,0,1);

    vc = ci(:,1:2);                   % Extract confidence intervals for
    vp = ci(:,3:4);                   %   components and proportions

    vc(:,1) = (max([vc(:,1)'; eps eps]))';
    vp(:,1) = (max([vp(:,1)'; eps eps]))';
    vp(:,2) = (min([vp(:,2)'; 1-eps 1-eps]))';

    varcomp = [varcomp'; vc]';
    varprop = [varprop'; vp]';
  end;

  return;
