% DESIGN: Creates an anova-type design matrix from a vector of group
%           identifiers.
%
%     Usage: G = design(grp)
%
%         grp = row or column vector of group identifiers.
%         ------------------------------------------------------------
%         G =   [n x g] design matrix for n observations and g groups.
%

% RE Strauss, 6/16/93
%   11/23/99 - addition of isvector() call.

function G = design(grp)
  if (~isvector(grp))
    error('  DESIGN: group identifiers must be vector.');
  end;

  nobs = length(grp);               % Number of observatons
  index = uniquef(grp);
  ngrps = length(index);            % Number of groups
  G = zeros(nobs,ngrps);            % Initialize G to zeros
  for i = 1:nobs
    for g = 1:ngrps
      if (grp(i)==index(g))
        G(i,g) = 1;                 % Set appropriate cells to one
        break;
      end;
    end;
  end;

  return;
