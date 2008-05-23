% BOOTSAMP: Randomly sample the rows of a matrix, with replacement.  If a
%           group-identification vector is provided as a second argument,
%           sampling is done randomly within groups, maintaining the group
%           sample sizes and sequence of group membership.
%
%     Syntax: Y = bootsamp(X,{grps})
%
%           X =    [n x p] input data matrix; any vector is assumed to be a 
%                   column vector.
%           grps = group-identification row or column vector.
%           ---------------------------------------------------------------
%           Y =    [n x p] bootstrapped sample.
%

% RE Strauss, 11/6/97
%   9/20/99 - update handling of null input arguments.
%   2/9/00 -  convert input vectors to columns.

function Y = bootsamp(X,grps)
  if (nargin < 2) grps = []; end;

  if (isvect(X))                  % Convert vectors to columns
    X = X(:);
  end;
  grps = grps(:);

  [n,p] = size(X);

  if (isempty(grps))                % Sample from entire matrix
    r = ceil(n*rand(n,1));            % Random indices
    while (std(r)==0)                 % If all indices identical,
      r = ceil(n*rand(n,1));          %   resample
    end;
    Y = X(r,:);                       % Rearrange into output matrix
  else                              % Or sample within groups
    Y = zeros(n,p);                   % Allocate output matrix
    G = design(grps);                 % Design matrix
    [n,ngrps] = size(G);              % Number of obs and groups
    for g = 1:ngrps                   % For each group,
      index = find(G(:,g));             % Get indices to nonzero elements
      ng = length(index);               % Sample size of current group
      r = ceil(ng*rand(ng,1));          % Random indices for group
      while (std(r)==0)                 % If all indices identical,
        r = ceil(ng*rand(ng,1));        %   resample
      end;
      Y(index,:) = X(index(r),:);       % Stash into output matrix
    end;
  end;

  return;
