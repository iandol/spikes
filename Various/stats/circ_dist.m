function r =  circ_dist(x,y)
%
% r = circ_dist(alpha, x)
%   Difference x-y around the circle computed efficiently.
%
%   Input:
%     x       sample of linear random variable
%     y       sample of linear random variable
%
%   Output:
%     r       matrix with pairwise differences
%
% References:
%     Biostatistical Analysis, J. H. Zar, p. 651
%
% PHB 6/7/2008
%
% Copyleft (c) 2008 Philipp Berens
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html
% Distributed under GPLv3 with no liability
% http://www.gnu.org/copyleft/gpl.html

r = angle(repmat(exp(1i*x),length(x),1) ...
       ./ repmat(exp(1i*y'),1,length(x)));