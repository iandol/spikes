function xcent = centroid(x,w)
%  xcent = centroid(x,w)
%  calculate centroid of w in units of x
%  find a centroid for each column if w is a matrix

%	Author(s): R. Johnson
%	$Revision: 1.0 $  $Date: 1995/11/28 $

if nargin<2
	w = x;
	end

if min(size(w))==1, 
% Make w a column.
	w = w(:); 
	end 

[m,n] = size(w);

if nargin<2
	x = 1:m;
	end

if min(size(x))>1, 
  error('x must be a vector.'); 
else
  x = x(:);
end

if length(x)~=m,
  error('x must have the same number of elements as the rows of w.');
  end

xcent = sum(w.*(x*ones(1,n)))./sum(w);
