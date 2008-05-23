% [s] = smooth(x, sigma, [binout=1])          Smooth a signal
%
% sigma is the std of the smoothing gaussian, in bins. Each bin is one
% vector element in x. Wraparound not considered here, watch out for it.
% 
% binout must be an integer >= 1. This is the subsampling rate for the
% output. Note that this is subsampling, not binning (sum will not be
% conserved). 
%
% Done in a dumb way here-- smoother prep should be directly in
% fourier space, not x-space.


function [s] = smooth(x, sigma, binout)
    
    if nargin < 3, binout=1; end;
    
    if iscolumn(x), x=x'; end;
    
    olength = length(x);
    x = [x, zeros(1, 2^(nextpow2(x)) - length(x))];
    
    smoother = [0:(length(x)/2 - 1), (-length(x)/2):-1];
    smoother = exp(-smoother.*smoother./(2*sigma*sigma));
    smoother = smoother/sum(smoother);
    
    s = real(ifft(fft(x).*fft(smoother)));
    
    s = s(1:(binout*floor(olength/binout)));
    
    s = reshape(s, binout, length(s)/binout);
    s = s(1,:);
    




