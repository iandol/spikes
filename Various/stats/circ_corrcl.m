function [rho pval] = circ_corrcl(alpha, x)
%
% [rho pval ts] = circ_corrcc(alpha, x)
%   Correlation coefficient between one circular and one linear random
%   variable.
%
%   Input:
%     alpha   sample of angles in radians
%     x       sample of linear random variable
%
%   Output:
%     rho     correlation coefficient
%     pval    p-value
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

if size(alpha,2) > size(alpha,1)
	alpha = alpha';
end

if size(x,2) > size(x,1)
	x = x';
end

n = length(alpha);

% compute correlation coefficent for sin and cos independently
rxs = corr(x,sin(alpha));
rxc = corr(x,cos(alpha));
rcs = corr(sin(alpha),cos(alpha));

% compute angular-linear correlation (equ. 27.47)
rho = sqrt((rxc^2 + rxs^2 - 2*rxc*rxs*rcs)/(1-rcs^2));

% compute pvalue
pval = chi2pdf(n*rho^2,2);

