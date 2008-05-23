function [RANK] = ranks(X)
%RANKS Produces a matrix of ranks of the original matrix
%	[RANK] = RANKS(X) returns a matrix RANK of the
%	data assigned a rank of 1 .. m in order from lowest to highest
%	for an input matrix X whose rows are observations and whose
%	columns are variables.
%
%	Tied observations are assigned the average rank.

% Jon Garibaldi: University of Plymouth: 31st Jan 1997
%
% Uses a 'clever' algorithm to set the rankings (including ties)
% without looping through each element of the ranking array,
% to greatly improve efficiency for large arrays.
%
% A matrix is formed where a 1 indicates that sorted elements
% either form the start of a set of tied observations or the
% end of a set of tied observations.  There must be an even
% number (including 0) of non-zero elements of this matrix.
% For example for two sets of twelve observations with no ties 
% in the first column and the 3rd & 4th tied and 10th, 11th and 12th
% tied in the second column would produce the matrix:
%	0	0
%	0	0
%	0	1
%	0	1
%	0	0
%	0	0
%	0	0
%	0	0
%	0	0
%	0	1
%	0	0
%	0	1
%
% Then for each column:
% 'find' the ones to produce the null vector for the first
% and [ 3, 4, 10, 12 ] for the second column.
% This vector then provides the indices which can be set
% with array operations. e.g. for column 1 ranks 1:12 = 1:12;
% for column 2 ranks 1:2 = 1:2, 3:4 = 3.5, 6:9 = 6:9 and 10:12 = 11
%
% 'dead' easy and very much quicker (~10x) than a brute force loop!


if nargin ~= 1
    error('Requires exactly one matrix input argument.'); 
end

[m, n]= size(X);
if m < 2 | n < 2
	error('Argument must be at least a 2x2 matrix.');
end

% sort to get order and indices
[Y, Z]= sort(X);

% initialise the target rank matrix
RANK= zeros(m, n);

% trickery to get a matrix of rank boundaries in sorted matrix
% i.e. the array E is 1 at each start&end of tied ranks
e= (Y(1:m-1,:) == Y(2:m,:));
E= xor([ e; zeros(1, n) ], [ zeros(1, n); e ]);

for i=1:n
	% get vector of start&end of tied rank pairs
	Ei= [find(E(:,i));m+1;m+1];
	Zi= Z(:,i);

	k1= 1;
	for j=1:2:size(Ei)
		k2= Ei(j) - 1;
		if k1 <= k2
			%disp(sprintf('set ranks %d to %d',k1,k2));
			RANK(Zi(k1:k2),i)= [k1:k2]';
		end
		k1= Ei(j);
		k2= Ei(j+1);
		if k1 < k2
			%disp(sprintf('set tied ranks %d to %d',k1,k2));
			RANK(Zi(k1:k2),i)= ones(k2-k1+1,1) .* (k1 + k2) / 2;
		end
		k1= k2 + 1;
	end
end

