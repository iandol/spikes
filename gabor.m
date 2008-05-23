function gabor = gabor(m, n, sigma1,sigma2, theta, theta2, lambda,phase,xoff,yoff,spont,amp)
% gabor = 128+127.*GenerateGabor(256,256, 32,32, pi/2, pi/2, 64,pi/2);
% Generates an m X n image containing a Gabor function (offset from the centre
% by (xoff,yoff)). Envelope X s.d. is sigma1, Y s.d.  sigma2, theta is
% the envelope orientation, theta2 is the carrier (both in radians)
% lambda is the wavelength (pixels), phase is the phase (radians)

if nargin<=8
	xoff=0;
	yoff=0;
end

if nargin <=10
	spont=0;
	amp=1;
end

if length(m)==1 & length(n)==1
	[X,Y]=meshgrid(-m/2:m/2-1,-n/2:n/2-1);
	X  = X-xoff;
	Y  = Y-yoff;
	X2 = X;
else
	[X,Y]=meshgrid(m,n);
	X  = X-xoff;
	Y  = Y-yoff;
	X2 = X;
end

% speedy variables
c1=cos(pi-theta);
s1=sin(pi-theta);
c2=cos(pi/2-theta2);
s2=sin(pi/2-theta2);
sig1_squared=2*sigma1*sigma1;
sig2_squared=2*sigma2*sigma2;
lamb_multiplier=(2.0*pi)/lambda;

% rotate co-ordinates
Xt = X.*c1 + Y.*s1;
Yt = Y.*c1 - X.*s1;
Xt2 = X2.*c2 + Y.*s2;

gabor = cos(Xt2.*lamb_multiplier+phase).* exp(-(Xt.^2)/sig1_squared-(Yt.^2)/sig2_squared);
gabor = gabor*amp;
gabor = gabor+spont;