function [pval Z] = circTestR(alpha, w)
%
% computes Rayleigh test for non-uniformity
%
% H0: p(alpha) is uniform
%
% input:
%	alpha	sample of angles in radians
%	[w		weightings in case of binned angle data]
%
% output:
%	pval	p-value of Rayleigh's R test
%	Z		critical value
%
% PHB 3/19/2006 3:45PM
%
% reference:
%   Statistical analysis of circular data, N.I. Fisher, p. 70
%
% copyright (c) 2006 philipp berens
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens
% distributed under GPL with no liability
% http://www.gnu.org/copyleft/gpl.html

if size(alpha,2) > size(alpha,1)
	alpha = alpha';
end

if nargin<2
	R = circResLength(alpha);
else
	R = circResLength(alpha,w);
end

N = length(alpha);

Z = N * R^2;

pval = exp(-Z);

if N < 50
  pval = pval * (1 + (2*Z - Z^2) / (4*N) - ...
   (24*Z - 132*Z^2 + 76*Z^3 - 9*Z^4) / (288*N^2));
end

