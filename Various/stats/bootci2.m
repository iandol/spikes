% BOOTCI: Finds the lower and upper confidence limits for a
%         statistic, given a specified confidence level and a distribution
%         of bootstrapped values.  One column vector of estimates is returned
%         for each column of the distribution matrix.  Estimates are
%         interpolated within distributions.
%           If only the bootstrap distribution is passed, the strict percentile
%         confidence limits are returned.  If the observed statistic estimates
%         are passed, the confidence limits are bias-corrected.
%         If a matrix of jackknifed statistic estimates is also passed, the
%         confidence limits are both bias- and acceleration-corrected.
%         See Efron and Tibshirani (1993).
%
%     Syntax: ci = bootci(distrib,{estval},{jackest},{ci_level})
%
%           distrib =  [iter x P] matrix of bootstrapped statistics for each of 
%                        P statistics.
%           estval =   optional vector (length P) of observed statistic estimates.
%           jackest =  optional [N x P] matrix of jackknifed statistic estimates,
%                        corresponding to the deletion of each of N observations.
%           ci_level = optional scalar probability level [default = 0.95].
%           ----------------------------------------------------------------------
%           ci =       [2 x P] matrix of estimates:
%                         row 1 = lower confidence limits
%                             2 = upper confidence limits
%

% Note:  Jackknife statistic estimates are used as an input argument rather than 
% the original data matrix for estimating the skewness of the influence function 
% so as to avoid assuming any particular calculation of the statistic from 
% the data.

% RE Strauss, 3/20/94
%   1/14/00 - changed handling of input arguments;
%               allow for missing values in distributions.
%   2/19/00 - corrected the values returned for an invariant distribution;
%               changed to sort cols only if necessary.
%  12/19/01 - corrected problem with small distribution vector.

function ci = bootci2(distrib,estval,jackest,ci_level)
  if (nargin < 2) estval = []; end;
  if (nargin < 3) jackest = []; end;
  if (nargin < 4) ci_level = []; end;

  if (isempty(ci_level))
    ci_level = 0.95;
  end;
  if (ci_level > 1)
    ci_level = ci_level / 100;
  end;

  bias_correct = 0;
  accel_correct = 0;
  if (~isempty(estval))
    bias_correct = 1;
  end;
  if (bias_correct & ~isempty(jackest))
    accel_correct = 1;
  end;

bias_correct = 0;       % ---> Bias correction not working
accel_correct = 0;

  [iter,P] = size(distrib);           % Size of bootstrapped distribution(s)
  issort = issorted(distrib);         % Determine whether cols are sorted
  ci = zeros(2,P);                    % Allocate return vector

  for v = 1:P;                        % Cycle thru variables
    D = distrib(:,v);                   % Extract distribution
    if (~issort(v))                     % Sort if necessary
      D = sort(D);
    end;

    iter = length(D);
    i = find(~isfinite(D));             % Check for missing values
    if (~isempty(i))
      D(i) = [];
      iter = length(D);
    end;

    if (var(D)>0)                       % If distribution is not invariant,
      L = (1-ci_level)/2;                 % Percentiles of confidence-interval
      U = 1-L;
%L_U = [L U]

      if (bias_correct)                   % Bias correction
        E = estval(v);                      % Extract estimate
%E
%minmaxD = [min(D) max(D)]
        s = sum(D<=E)/iter;
        if (s < 0.5)
          s = max(s,1/iter);
        else
          s = min(s,1-(1/iter));
        end;
        z0 = norminv(s);                    % Bias-correction factor
        a = 0;

        if (accel_correct)                  % Acceleration correction
          J = jackest(:,v);                   % Extract jackknife statistic estimates
          dev = mean(J)*ones(length(J),1) - J;  % Deviations from mean
          a = sum(dev.^3)/(6*sum(dev.^2)^1.5);  % Skewness of influence function
          if (~finite(a))
            a = 0;
          end;
        end;

        zl = z0 + norminv(L);               % Adjust percentiles
        L = normcdf(z0 + zl/(1-a*zl));
        zu = z0 + norminv(U);
        U = normcdf(z0 + zu/(1-a*zu));
%s
%z0_zl_zu = [z0 zl zu]
%L_U = [L U]
      end;

      indx = iter * L;                      % Find lower confidence limit
      low =  min(max(floor(indx),1),iter);
      high = max(min(ceil(indx),iter),1);

      if (high-low > 0)
        delta = (indx - low)/(high - low);
        ci(1,v) = D(low) + delta*(D(high)-D(low));
      else
        ci(1,v) = D(low);
      end;

      indx = iter * U;                    % Find upper confidence limit
      low =  min(max(floor(indx),1),iter);
      high = max(min(ceil(indx),iter),1);

      if (high-low > 0)
        delta = (indx - low)/(high - low);
        ci(2,v) = D(low) + delta*(D(high)-D(low));
      else
        ci(2,v) = D(low);
      end;

    else
      if (bias_correct)
        ci(1,v) = estval(v);
        ci(2,v) = estval(v);
      else
        if (isempty(D))
          ci(:,v) = [NaN;NaN];
        else
          ci(:,v) = D([1,1],1);
        end;
      end;
    end;
  end;

  return;
