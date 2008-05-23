% Isvect: Returns 1 if the input matrix is a vector, 0 if not.  Optionally 
%           returns the vector's length (=total number of cells, if not a 
%           vector), and a boolean flag indicating whether the vector is a 
%           colummn.
%
%     Usage: [isvect,ncells,iscol] = isvect(X,{kind})
%
%           X =       [r x c] matrix.
%           kind =    optional scalar indicating the kind of vector to be tested for:
%                       1 = row vector, 2 = column vector [default = either].
%           -------------------------------------------------------------------------
%           isvect =  boolean flag indicating whether (=1) or not (=0) the input 
%                       matrix is a vector.
%           ncells =  number of cells.
%           iscol =   boolean flag indicating whether (=1) or not (=0) the 
%                       vector is a column vector.
%

% RE Strauss, 11/20/99
%   5/4/00 -   corrected wrong decision for scalar input.
%   10/28/03 - added optional test for kind of vector.
%   4/5/05 -   changed name from isvector() to isvect() to avoid Matlab 7 conflict.

function [isv,ncells,iscol] = isvect(X,kind)
  if (nargin < 2) kind = []; end;

  [r,c] = size(X);
  isv = 0;
  ncells = 0;
  iscol = 0;

  if ([r c]==[1 1])                     % Is a scalar
    ncells = 1;
  elseif (min([r,c])==1)                % Is a vector
    ncells = max([r,c]);
    if (isempty(kind))                    % Is either kind of vector
      isv = 1;
      if (r>1)
        iscol = 1;
      end;
    else 
      switch (kind)
        case 1,                           % Is a row vector
          if (c>1)
            isv = 1;
          else
            iscol = 1;
          end;
        case 2,                           % Is a column vector
          if (r>1)
            isv = 1;
            iscol = 1;
          end;
        otherwise
          error('  Isvect: invalid ''kind'' flag.');
      end;
    end;
  else                                  % Is not a vector
    ncells = r.*c;
  end;

  return;
  