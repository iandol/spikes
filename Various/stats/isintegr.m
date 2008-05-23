% ISINTEGR: Returns TRUE if a matrix consists of all integers,
%           FALSE otherwise. Omits NaN and infinite values.
%
%     Usage: isint = isintegr(A,epsilon)
%
%           A =       input matrix.
%           epsilon = threshhold for decimal portion of numbers
%                       [default = eps].
%           ---------------------------------------------------
%           isint =   boolean flag.
%

% RE Strauss, 6/3/97

% 9/24/98 - changes for Matlab v5

function isint = isintegr(A,epsilon)
  if (nargin < 2)
    epsilon = eps;
  end;

  A = abs(A(:));                  % Convert to column vector of abs values

  indx = find(~finite(A));        % Remove NaN's and infinite values
  if (~isempty(indx))
    A(indx) = [];
  end;

  isint = all(A-floor(A) < epsilon);  % Check for neglible fractions
  return;
