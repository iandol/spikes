function D = circVar(alpha, w)
%
% computes measure of dispersion for circular data
%
% input:
%	alpha	sample of angles in radians
%	[w		weightings in case of binned angle data]
%
% output:
%	D		measure of angular dispersion
%
% PHB 3/19/2006 1:59PM
%
% references:
%   Statistical analysis of circular data, N.I. Fisher
%   Topics in circular statistics, S.R. Jammalamadaka et al. 
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

D = 1 - R;
