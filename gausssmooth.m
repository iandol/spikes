function ysmoothed = gausssmooth(x,y,fwhm,sym)

%----------------------------------------------------
% Function to convolve data with a Gaussian Kernel
%
% sy = gausssmooth(x,y,fwhm)
%
% x = X input values
% y = Y input values
% fwhm = full-width at half-maximum, more intuitive than sigma
%
% Ian Andolina 2002
%----------------------------------------------------

if ~exist('sym','var')
	sym = true;
end
sig = fwhm/sqrt(8*log(2));

ysmoothed = zeros(size(y));
for i = 1:length(x)
  kerny =  exp(-(x-x(i)).^2/(2*sig^2));
  if sym==false && i > 1
	 kerny(1:i-1) =  kerny(1:i-1)/2;
  end
  kerny = kerny / sum(kerny);
  ysmoothed(i) = sum(y.*kerny);
end