function [pval mu F] = circ_wwtest(alpha1, alpha2, w1, w2)
%
% [pval, F] = circ_wwtest(alpha1, alpha2, w1, w2)
%   Parametric Watson-Williams two-sample test for equal means.
%   H0: the two populations have equal means
%   HA: the two populations have unequal means
%
%   Note: 
%   Use with binned data is only advisable if binning is finer than 10 deg.
%   In this case, alpha1 and alpha2 are assumed to be equal and correspond
%   to bin centers.
%
%   The Watson-Williams two-sample test assumes underlying von-Mises
%   distributrions.
%
%   Input:
%     alpha1	sample of angles in radians of population 1
%     alpha2	sample of angles in radians of population 2
%     [w1     number of incidences in case of binned angle data]
%     [w2     number of incidences in case of binned angle data]
%
%   Output:
%     pval    p-value of the Watson-Williams two-sample test. Discard H0 if
%             pval is small.
%     mu      best estimate of shared population mean if H0 is not
%             discarded at the 0.05 level and NaN otherwise.
%     F       test statistic of the Watson-Williams test.
%
%
% PHB 7/6/2008
%
% References:
%   Biostatistical Analysis, J. H. Zar
%
% Copyleft (c) 2008 Philipp Berens
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html
% Distributed under GPLv3 with no liability
% http://www.gnu.org/copyleft/gpl.html

if size(alpha1,2) > size(alpha1,1)
	alpha1 = alpha1';
end

if size(alpha2,2) > size(alpha2,1)
	alpha2 = alpha2';
end


if nargin<3
  % if no specific weighting has been specified
  % assume no binning has taken place
	w1 = ones(size(alpha1));
  w2 = ones(size(alpha2));
  alpha = [alpha1; alpha2];
  w = ones(size(alpha));
else
  if size(w1,2) > size(w1,1)
    w1 = w1';
  end 
  if size(w2,2) > size(w2,1)
    w2 = w2';
  end 
  alpha = alpha1;     % here we assume both bin centers to be equal
  w = w1+w2;
end

% number of samples
n1 = sum(w1);
n2 = sum(w2);
n = n1 + n2;

% resultant vector lengths
r1 = circ_r(alpha1,w1);
r2 = circ_r(alpha2,w2);
r = circ_r(alpha,w);
rw = (n1*r1 + n2*r2)/n;

% check for assumptions
if  rw < .7 || n/2 < 10
  error('Test not applicable. Numer of samples to low or average resultant vector length to low.')
end

% compute test statistic (equ. 27.14)
F = ktable(rw) * ((n-2)*(n1*r1+n2*r2-n*r)/(n-n1*r1-n2*r2)); 
pval = 1-fcdf(F,1,n-2);

% compute estimate of population mean
if pval > 0.05
  mu = circ_mean(alpha,w);
else 
  mu = NaN;
end




function k = ktable(rw)

% Colum 2 from table B37 in Zar, JH. 
% The first entry corresponds to r=.7, the last one to r=1.
k = [1.1851 1.1794 1.1738 1.1682 1.1627 1.1572 1.1517 1.1461 1.1406 ...
1.1351 1.1285 1.1239 1.1182 1.1124 1.1066 1.1007 1.0947 1.0885 1.0823 ...
1.0759 1.0694 1.0627 1.0560 1.0491 1.0422 1.0351 1.0279 1.0207 1.0134 ...
1.0060 1];

idx = round((rw-.7)*100)+1;
k = k(idx);



