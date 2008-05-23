%modgam.m; 28 MAY 01; 09 JUN 01
function [outt] = modgam(mo,mr,ns);
% mo,mr are the modulated order and rate functions; assume 1KHz sampling rate
% length should be at least (ns/mean(mr))+20%.
dt = .001;	% bin time in seconds
sr2 = 1000;	% 1KHz sampling rate for modulations
M = zeros(1,ns);
T = 1/mean(mr);	%initial moment to select modulation values; based on mean interval
for j=1:ns   
   tt = cumsum(M);
   momrx = ceil((tt(j) + T)*sr2);
   moa(j) = mo(momrx);
   mra(j) = mr(momrx);
   M(j)= gamrnd(moa(j),1/(moa(j)*mra(j)));
end

 outt=tt;
 