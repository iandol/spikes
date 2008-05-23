function canvas = sirds( elev, sw, sf, pad )
%SIRDS		Generate Single Image Random Dot Stereogram
%
%MAP=SIRDS( DEPTHMATRIX, STRIPWIDTH, STRIPFILTER, [, PAD]] )
%	This function generates colour Single Image Random Dot
%	Stereogram (SIRDS) mapping for an integer DEPTHMATRIX.  It
%	uses a random strip on the left side having width STRIPWIDTH,
%	and is filtered by STRIPFILTER (see FILTER2).  The simplest
%	STRIPFILTER is just [1].
%
%	To prevent banding and other artefacts, you must ensure a
%	minimum relationship between maximum value of DEPTHMATRIX,
%	and STRIPWIDTH.  As a guideline, STRIPWIDTH >= 2*MAX(DEPTHMATRIX).
%
%	The output MAP is real-valued in the range of 0 to 1.
%	MAP is larger than DEPTHMATRIX by (1+2*PAD)*STRIPWIDTH columns.
%
%	Mappings are best viewed with the IMAGE command (MAP must be
%	scaled to accommodate a given colour map -- see COLOR and CAXIS)
%	or with the CONTOUR command (with only a few contour levels). 
%
%	This function generates a *cross-eyed* mapping.  To generate a
%	*wall-eyed* mapping, invoke using -DEPTHMATRIX.
%
%	Additionally, one can specify that a zero-height border be added
%	to the left and right of the image.  The width of the border is
%	specified by the PAD*STRIPWIDTH.  The default value of PAD is 0.5;
%
%	One can create movies if desired.  See the Matlab MOVIE commands.
%
%	Example:
%		>> x = peaks(200);
%		>> sf = toeplitz(.9.^[0:31]); sf = sf-rot90(sf);
%		>> m = sirds(2*x,128,sf);
%		>> contour(m,3); axis equal;
%		>> colormap(cool(64)); image(64*m); axis equal;
%
%	This code is copyright (c) 1993,1995, Dave Caughey, and may be
%	used or disributed for any non-commercial use.  Credit is requested
%	for use in non-commercial publications.
%
%	E-mail: caughey@engr.uvic.ca
%	Dept. of Electrical and Computer Engineering
%	University of Victoria,  Victoria, B.C, Canada
%
%       If you like this m-file send me an e-mail (it's an ego thing).
%
%	See also: FILTER2, IMAGE, CONTOUR

%  Additional info:
%
%	Note! I do not have any references for SIRDS.  The following is
%	the best I can do in terms of explanation.
%
%	To create and SIRDS for an MxN depth matrix "D", start by generating
%	a Mx(N+W) canvas "C".  Fill the first W columns of the canvas with
%	(usually) random values.  Then, for each element C(i,j+W) of the 
%	canvas, assign it a value equal to element C(i,j+W-D(i,j)).
%	Repeat this procedure for each column in "D".
%
%	Thus, if for a given row i, the first W=4 columns contained the
%	pattern [a b c d] and the depth matrix contained the values
%	[0 0 0 1 1 2 1 0 0], row i of the canvas would look like
%	[a b c d a b c a b a a a b].
%
%	This m-file basically does what I just described, only optimized
%	heavily for Matlab's vectorized approach.
%
%  So, how does it work?
%	What has happened that the depth information in "D" has been turned
%	into spatial correlations in "C", but masked in the apparent
%	randomness of the first W columns.  How is this info used to create
%	depth perception?  Assume we have a canvas with the following
%	elements.
%
%         [  B      B      B      B    B    B    B      B      B  ]
%
%	When drawn on the screen (or printed on a page), and viewed
%	cross-eyed or wall-eyed, one can can prepare a ray diagram
%	(assume parallel rays) as follows:
%
%          \   /  \   /  \   /  \   /\   /\   /\   /  \   /  \   /
%           \ /    \ /    \ /    \ /  \ /  \ /  \ /    \ /    \ /
%            B      B      B      B    B    B    B      B      B
%           / \    / \    / \    / \  / \  / \  / \    / \    / \
%          /   \  /   \  /   \  /   \/   \/   \/   \  /   \  /   \
%         /     \/     \/     \/    /\   /\   /\    \/     \/    
%        /      /\     /\     /\   /  \ /  \ /  \   /\     /\ 
%
%	Where the rays from the left and right intersect is where
%	the mind perceives the depth.
%
%  Artefacts:
%	Note that because the pixel correlation is integer-based, the
%	perceived depth will be integer quanta.  That is, it will appear
%	as though all points in your image occur in a finite number
%	of plateaus.  Increasing the dynamic range of your depth matrix
%	will increase the depth resolution, but will require a bigger
%	STRIPWIDTH, and hence will take longer.
%
%	Also, if you notice that a flat background appears to vary
%	slightly in depth with a wavy appearance, this is due to the
%	rendering of an image onto a space (on the screen or printed
%	page) which does not correspond evenly.  As pixel locations are
%	truncated/rounded, there is a *slight* difference in the
%	correlations, and hence the perceived depth is off just a little.
%
%	Banding will occur if there are long stretches of unity slope.
%	For example, if the initial strip contains [a b c d e f], and the
%	depth matrix contains [ 0 0 0 5 4 3 2 1 0 0 0 0 ], the canvas will
%	contain [a b c d e f a b c c c c c c c c c c].

% 
% Parse arguments and set all unspecified values
%

if rem(sw,2)==1, sw = sw+1; end;	% make even strip width

if nargin == 3				% min number of input args,
    pad = 0.5;
elseif nargin ~= 4,			% illegal # of args
    help sirds
end;
pad = pad*sw;

%
% Error check depth matrix
%

if max(abs(elev(:)))>=sw,
    fprintf( 'sirds: depth values must be less than strip width\n' );
    return;
end;

%
% Determine the dimensions of the mapping
%

[N0Y,N0X] = size(elev);
NX = N0X+2*pad;

%
% Initialize the canvas, and the increment vectors
%

SF2 = size(sf,1);
firststrip = rand(sw+2*SF2,N0Y+2*SF2);
firststrip = filter2(sf,firststrip);
firststrip = firststrip(SF2+(1:sw),SF2+(1:N0Y));

canvas = [firststrip;firststrip;zeros(N0X,N0Y)];
off = size(canvas,1)*((1:N0Y)-1);

%
% Calculate the each columns' pixels
%	This the meat of the SIRDS function
%

fprintf('%d:', N0X); 
for c = (1:N0X)+sw,
    fprintf('.'); 
    cc = c-elev(:,c-sw)'+off;
    canvas(c+sw,:) = canvas(cc);
end
fprintf('\n'); 

%
% Strip off second left strip
%
canvas = canvas((sw+1):size(canvas,1),:);

%
% Pad the right
%

laststrip = canvas((1:pad)+N0X,:);
canvas = [firststrip((1:pad)+sw-pad,:);canvas;laststrip]';

%
% Convert to an integer number of output levels
%
minc = min(canvas(:));
maxc = max(canvas(:));
canvas = (canvas-minc)/(maxc-minc);
