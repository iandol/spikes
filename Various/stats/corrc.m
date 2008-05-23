% CORR: Calculates the Pearson product-moment correlations among a set of
%       variables, or between a reference variable and a set of variables, or
%       among all possible pairs of two sets of variables.
%       Returns a single correlation for two variables.
%       Correlation between one or two invariant variables is defined to be zero;
%       the diagonal self-correlation for an invariant variable is also defined
%       to be zero.
%          Missing values are replaced by means, by variable.
%          Provides 2-tailed probabilities, either as asymptotic small-sample
%       estimates or via independent randomization of variables.  Probabilities 
%       are NOT simultaneous (see CORRPROB).
%          Provides confidence intervals for correlation coefficients, either as
%       asymptotic small-sample estimates or via bootstrapping original
%       observations.  Confidence intervals are NOT simultaneous (see CORRCI).
%
%     Syntax: [r,prob,CI_low,CI_high] = corr(X1,{X2},{kind},{iter},{CI_level})
%
%       X1 =        [N x P1] data matrix.  If P1=1, it is taken to be the
%                     reference variable.
%       X2 =        optional [N x P2] data matrix.  If P2=1, it is taken to be
%                     the reference variable.  If X2 is a scalar, it is assumed 
%                     that X2 has been omitted and kind, iter and CI_level 
%                     are in argument positions 2-4.
%       kind =      optional flag indicating modified correlation coefficients:
%                     0 = Pearson product-moment correlation [default]
%                     1 = Spearman rank correlation
%                     2 = vector correlation
%       iter =      optional number of iterations for randomized probabilities  
%                     and confidence intervals [default = 0].
%       CI_level =  optional percentage width of confidence intervals 
%                     [default = 95].
%       -------------------------------------------------------------------------
%       r =         [P1 x P1] symmetric correlation (if only X1 is specified);
%                   [P1 x 1] vector of correlations (if X1 & ref are specified);
%                   [1 x P2] vector of correlations (if ref & X2 are specified);
%                   [P1 x P2] rectangular matrix of correlations (if X1 & X2 are
%                     both specified);
%                   [1 x 1] scalar correlation (if X1 is an [N x 2] matrix or
%                     ref1 & ref2 are both specified).
%       prob =      corresponding probabilities, either asymptotic (small-sample)
%                     if iter=0, or via randomization if iter>0.
%       CI_low =    corresponding lower confidence limits, either asymptotic
%                     (small-sample) if iter=0, or via bootstrapping
%                     if iter>0.
%       CI_high =   corresponding upper confidence limits.
%

% Note: Any changes to the documentation of this function should be made in parallel
%       to RANKCORR() and VECTCORR().

% RE Strauss, 5/12/95
%    9/ 9/96 -  missing values replaced by means for each variable.
%   10/14/97 -  if X1 or X2 input are row vectors, convert to column vectors.
%    5/23/99 -  many miscellaneous changes, including incorporation of rankcorr() 
%                 and vectcorr().
%    9/30/99 -  added input error messages.
%    1/21/02 -  renamed 'special' to 'kind'.
%    3/7/04 -   replaced 'ranks' by 'RankCols'.

function [r,prob,CI_low,CI_high] = corrc(X1,X2,kind,iter,CI_level)

  % ----- Initialize input and output arguments ----- %

  if (nargin < 2) X2 = []; end;
  if (nargin < 3) kind = []; end;
  if (nargin < 4) iter = []; end;
  if (nargin < 5) CI_level = []; end;

  if (isscalar(X2))                         % If X2 is a scalar,
    CI_level = iter;                        %   bump other arguments forward
    iter = kind;
    kind = X2;
    X2 = [];
  end;

  get_prob = 0;                                 % Output flags
  get_CI = 0; 
  given_X2 = 0;

  if (nargout>1) get_prob = 1; end;
  if (nargout>2) get_CI = 1; end;

  if (~isempty(X2))      given_X2 = 1; end;     % Default input parameters
  if (isempty(kind))     kind = 0; end;
  if (isempty(iter))     iter = 0; end;
  if (isempty(CI_level)) CI_level = 95; end;

  if (CI_level > 1)
    CI_level = CI_level/100;
  end;
  alpha = 1 - CI_level;

  if (kind<0 | kind>2 | ~isintegr(kind))
    error('  CORR: kind-correlation flag out of range');
  end;
  if (CI_level<0 | CI_level>1)
    error('  CORR: CI level out of range');
  end;

  [N1,P1] = size(X1);                        % If X1 or X2 is row vector,
  if (N1==1 & P1>1)                          %   convert to column vector
    X1 = X1';
    [N1,P1] = size(X1);
  end;
  if (given_X2)
    [N2,P2] = size(X2);
    if (N2==1 & P2>1)
      X2 = X2';
      [N2,P2] = size(X2);
    end;
  else
    N2 = 0;
    P2 = 0;
  end;

  if (given_X2)
    if (N1~=N2)
      error('  CORR: Number of observations must be identical');
    end;
  else
    if (P1<2)
      error('  CORR: Need at least two variables');
    end;
  end;
  N = N1;
  P = P1;

  if (get_CI)
    high_CI_limit = ceil((iter*CI_level));  % CI indices
    low_CI_limit = iter - high_CI_limit +1;
  end;

  prob = [];                                % Allocate output arguments
  CI_low = [];
  CI_high = [];

  % ----- Replace missing values with means, by variable ----- %

  for j = 1:P1
    indx = find(~finite(X1(:,j)));
    if (~isempty(indx))
      xj = X1(:,j);
      xj(indx) = [];
      X1(indx,j) = mean(xj) * ones(length(indx),1);
    end;
  end;

  if (given_X2)
    for j = 1:P2
      indx = find(~finite(X2(:,j)));
      if (~isempty(indx))
        xj = X2(:,j);
        xj(indx) = [];
        X2(indx,j) = mean(xj) * ones(length(indx),1);
      end;
    end;
  end;

  % ----- Deviations and ranks ----- %

  if (kind==1)                         % Ranks for Spearman correlations
    X1 = RankCols(X1);
    if (given_X2)
      X2 = RankCols(X2);
    end;
  end;

  if (kind~=2)                         % For Pearson and Spearman correlations
    X1 = X1 - ones(N,1)*mean(X1);           %   (but not vector correlations),
    X1 = X1/(N-1);                          %   convert data to avg devs from means
    if (given_X2)                           
      X2 = X2 - ones(N,1)*mean(X2);
      X2 = X2/(N-1);
    end;
  end;

  % ----- Correlations, probabilities, and confidence intervals ----- %

  r = corrf([X1 X2],[],[],[],P1,P2,0,0);  % Correlation matrix

  if (~iter)                          % Asymptotic confidence intervals
    if (get_prob & get_CI)
      [prob,CI_low,CI_high] = corrprci(r,N,CI_level);
    elseif (get_prob)
      prob = corrprci(r,N);
    end;
  end;

  if (iter & (get_prob | get_CI))     % Randomized probs and CI intervals
    procs = [0 0 0 1];                  % Set options
    if (get_prob)
      procs(2) = 1;
    end;
    if (get_CI)
      procs(1) = 1;
    end;

    if (get_CI)                         % Randomize for confidence intervals
      ci = bootstrp2('corrf',procs,iter,alpha,[X1 X2],[],[],P1,P2,1,0);
    end;
    if (get_prob)                       % Randomize for probabilities
      [c,pr] = bootstrp2('corrf',procs,iter,alpha,[X1 X2],[],[],P1,P2,1,1);
    end;

    if (given_X2)                     % Reshape matrices
      if (get_prob)
        prob = reshape(pr',P1,P2);
      end;
      if (get_CI)
        CI_low =  reshape(ci(1,:)',P1,P2);
        CI_high = reshape(ci(2,:)',P1,P2);
      end;
    else
      if (get_prob)
        prob = trisqmat(pr');
      end;
      if (get_CI)
        CI_low =  trisqmat(ci(1,:)',1);
        CI_high = trisqmat(ci(2,:)',1);
      end;
    end;
  end;

  if (~given_X2 & P1==2)              % Single correlation for two vars
    r = r(1,2);
    if (get_prob)
      prob = prob(1,2);
    end;
    if (get_CI)
      CI_low = CI_low(1,2);
      CI_high = CI_high(1,2);
     end;
  end;

  return;
