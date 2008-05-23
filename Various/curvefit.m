function [pout,yfitted]=curvefit(x,y,arg3,options)
% CURVEFIT   Curve fitting and plotting routine 
%            CURVEFIT(X,Y) plots the points specified by the vectors
%            X and Y using the symbol '*', and simultaneously plots a 
%            straight line that represents the best linear fit to 
%            the data.
%
%            CURVEFIT(X,Y,N) for integer N fits an Nth order polynomial
%            to the data.
%
%            CURVEFIT(X,Y,[F1(x) F2(x) ...]) fits Y to the closest 
%            linear combinations of the vectors F1(x), F2(x), etc.
%            This is useful for fitting arbitrary functions of X to Y.
%            (Ie. curvefit(X,Y,[exp(X) cos(2*X)])
%
%            [P, Yfitted]=CURVEFIT(X,Y,...) returns the estimated fitting
%            coefficients in the vector P, and the corresponding fitted
%            Y in the Yfitted vector.  In the polynomial fitting case, 
%            the P coefficients are ordered highest order first (slope, 
%            then y-intercept in the 1st order case).
%
%            CURVEFIT(X,Y,N,OPTIONS) allow the caller to specify certain
%            options.  If OPTIONS(1)=1, then no plot is generated.  This 
%            useful if the caller is only interested in the returned
%            values.  If OPTIONS(2)=1, then the X-axis is plotted on 
%            a log scale.  If OPTIONS(3)=1, then the Y-axis is plotted on
%            a log scale. If OPTIONS(4) is specified, it's value is 
%            assumed to be a character representing the symbol to use
%            to plot the original data, which has a default value of '*'.  
%            This element can be set to the character 'i' for invisible if 
%            only the best-fit curve is desired in the plot.
%
%            NOTE: The output Parameter P has been changed to output
%                  a row vector with coefficients in descending powers
%                  of x, for compatibility with other Matlab routines. 

%            Written by Jim Rees, 5 Mar. 1992

if nargin<2, error('Too few arguments'); end
F = [];
if nargin<4, 
	options=[0 0 0 '.']; 
else
	options=options(:).';  % Forces options to be a row vector

	% This zeros all non-existent terms.
	if length(options)<4, options(4)='.'; end  
end

% Make x and y be column vectors.
x = x(:); y = y(:);

if nargin<3, 
	N=1;  % Fit a straight line
else
	% If arg3 is a scalar, set N to it.
	[r,c]=size(arg3);
	if max([r c])==1, N=arg3;
	else
		F=arg3;
		if r<c, F=F.'; end
	end
end

% If F isn't defined already (polynomial case), set it up here.
if isempty(F),
	P = polyfit(x,y,N);
	yfitted = polyval(P,x);
else,
	for k=1:N+1, F(:,k)=x.^(N+1-k); end;
	% Perform the least squares fit.
	P=F\y; yfitted=F*P;
end
if options(1)~=1,   % If we're plotting...

	% Determine which plot command to use.
	if options(2)==0,
		if options(3)==0, 
			plotcmd = 'plot';
		else
			plotcmd = 'semilogy';
		end
	else
		if options(3)==0,
			plotcmd = 'semilogx';
		else
			plotcmd = 'loglog';
		end
	end

	% Plot
	eval([plotcmd '(x,yfitted,''r.'',x,yfitted,''k-'')']);
%
end

% Set pout to P if the caller is expecting returned values.
if nargout>=1, pout=P.' ; end
