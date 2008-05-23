% RankCols:  For an input data matrix, returns a corresponding matrix in which
%            elements have been replaced by their ranks by column.  Ties are
%            assigned their mean ranks (=midranks).  If a grouping vector is 
%            provided, ranks are assigned within groups.
%
%     Usage: R = RankCols(X,{grps})
%
%       X = [n x p] data matrix.
%       grps = optional [n x 1] vector of group identifiers.
%        ---------------------------------------------------
%       R = [n x p] of corresponding ranks by column.
%

% RE Strauss, 6/19/93
%   5/9/99 -  allow for single row vector
%   5/26/99 - add option of within-group ranks
%   3/7/04 -  change function name from 'ranks' to 'RankCols' to avoid conflicts with Matlab fns.

function R = RankCols(X,grps)
  if (nargin < 2) grps = []; end;

  within_grps = 0;
  if (~isempty(grps))
    within_grps = 1;
    ugrps = uniquef(grps);
    ngrps = length(ugrps);
  end;

  [N,P] = size(X);

  row_vect = 0;
  if (N==1 & P>1)
    row_vect = 1;
    X = X';
    [N,P] = size(X);
  end;

  R = zeros(N,P);

  for p = 1:P                       % Cycle thru variables
    x = X(:,p);                       % Extract current variable
    if (within_grps)                  % Cycle thru groups
      for ig = 1:ngrps
        i = find(grps==ugrps(ig));
        R(i,p) = rankasgn(x(i));
      end;
    else                              % Or rank entire column
      R(:,p) = rankasgn(x);
    end;
  end;

  if (row_vect)
    R = R';
  end;

  return;

