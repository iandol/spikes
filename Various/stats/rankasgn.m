% RANKASGN: Assigns ranks to a single vector of values.  Ties are assigned
%           their mean ranks (=midranks).
%
%     Usage: r = rankasgn(x)
%
%           x = [n x 1] data vector.
%           ----------------------------------
%           r = corresponding vector of ranks.
%

% RE Strauss, 5/26/99

function r = rankasgn(x)
  [n,c] = size(x);
  
  rowvect = 0;
  if (n==1 & c>1)
    x = x';
    [n,c] = size(x);
    rowvect = 1;
  end;

  if (c>1)
    error('RANKASGN: input vector required');
  end;

  r = zeros(n,1);               % Allocate output vector

  [x,index] = sort(x);          % Sort and get indices to x
  i = 1;
  while (i<n)
    if (x(i+1) ~= x(i))           % Not a tie
      r(index(i)) = i; % Stash rank
      i = i+1;
    else                          % Tie
      at_end = 0;
      for j = (i+1):n               % How far does it go?
        if (x(i) ~= x(j))
          j = j-1;
          break;
        end;
      end;
      midrank = mean(i:j);
      for k = i:j                   % Enter midrank into all the tied entries
        r(index(k)) = midrank;
      end;
      i = j+1;
    end;
  end;
  if (r(index(n)) == 0)           % Check last entry
    r(index(n)) = n;
  end;

  if (rowvect)
    r = r';
  end;

  return;
