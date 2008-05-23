function jackstat = jackknife(jackfun,varargin)
%JACKKNIFE Jackknife statistics.
%   JACKSTAT = JACKKNIFE(JACKFUN,...) draws jackknife data samples,
%   computes statistics on each sample using the function JACKFUN, and
%   returns the results in the matrix JACKSTAT.  JACKFUN is a function 
%   handle specified with @. Each row of JACKSTAT contains the results of
%   applying JACKFUN to one jackknife sample.  If JACKFUN returns a matrix
%   or array, then this output is converted to a row vector for storage in
%   JACKSTAT.
%
%   The third and later input arguments to JACKKNIFE are data (scalars,
%   column vectors, or matrices) that are used to create inputs to JACKFUN.
%   JACKKNIFE creates each jackknife sample by sampling with replacement
%   from the rows of the non-scalar data arguments (these must have the
%   same number of rows).  Scalar data are passed to JACKFUN unchanged.
%
%   Examples:
%
%   Estimate the bias of the MLE variance estimator of random samples
%   taken from the vector Y using jackknife.  The bias has a known formula
%   in this problem, so we can compare the jackknife value to this formula.
%
%      y = exprnd(5,100,1);
%      m = jackknife(@var, y, 1);
%      n = length(y);
%      bias = var(y,1) - var(y,0)         % known bias formula
%      jbias = (n - 1)*(mean(m)-var(y,1)) % jackknife estimate of the bias
%
%   See also BOOTSTRP, RANDOM, RANDSAMPLE, HIST, KSDENSITY.

%   Reference:
%      Efron, Bradley, & Tibshirani, Robert, J.
%      "An Introduction to the Bootstrap", 
%      Chapman and Hall, New York. 1993.

%   Copyright 1993-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2005/11/18 14:28:07 $

% Initialize matrix to identify scalar arguments to jackfun.
la = length(varargin);
scalard = zeros(la,1);

% find out the size information in varargin.
n = 1;
for k = 1:la
   [row,col] = size(varargin{k});
   if max(row,col) == 1
      scalard(k) = 1;
   end
   if row == 1 && col ~= 1
      row = col;
      varargin{k} = varargin{k}(:);
   end
   n = max(n,row);
end

if isempty(jackfun)
   jackstat = zeros(n,0);
   return
end

% Get result of jackfun on actual data and find its size.
jackstat = feval(jackfun,varargin{:});

% Initialize an array to contain the results of all the jackknife
% calculations, preserving the output type
jackstat(n,1:numel(jackstat)) = jackstat(:)';

% Do jackfun - n times.
if la==1 && ~any(scalard)
   % For special case of one non-scalar argument and one output, try to be fast
   X1 = varargin{1};   
   for jackiter = 1:n
      onesample = 1:n;
      onesample(jackiter)=[];
      tmp = feval(jackfun,X1(onesample,:));
      jackstat(jackiter,:) = (tmp(:))';
   end
elseif la==2 && ~any(scalard)
   % For two non-scalar arguments and one output, try to be fast
   X1 = varargin{1};
   X2 = varargin{2};
   for jackiter = 1:n
      onesample = 1:n;
      onesample(jackiter)=[];
      tmp = feval(jackfun,X1(onesample,:),X2(onesample,:));
      jackstat(jackiter,:) = (tmp(:))';
   end
else
   % General case
   db = cell(la,1);
   for jackiter = 1:n
      onesample = 1:n;
      onesample(jackiter)=[];
      for k = 1:la
         if scalard(k) == 0
            db{k} = varargin{k}(onesample,:);
         else
            db{k} = varargin{k};
         end
      end
      tmp = feval(jackfun,db{:});
      jackstat(jackiter,:) = (tmp(:))';
   end
end