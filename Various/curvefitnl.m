function [p1,yfitted]=curvefitnl(x,y,fstring,iniguess,options)
% CURVEFITNL Nonlinear curve fitting and plotting routine.
%
%	     CURVEFITNL(X,Y,FSTRING,GUESS) acts as a front-end to the
%            leastsq function in the Optimization toolkit.  It plots
%            the data (X,Y) with '*' symbols, and plots a best fit 
%            curve along with the data whose form is specified by
%            FSTRING.  For example, to fit an single exponential curve 
%            to data, FSTRING could be 'p(1)*exp(p(2)*x)'.  p(1) and p(2)
%            are parameters to be estimated. You _must_ use the names 'p' 
%            and 'x' in FSTRING to refer to these quantities.  
%            GUESS is a vector which contains initial guesses for the 
%            unknown parameters.  If these initial guesses are not close
%            enough to the "true" parameters, the call to leastsq could 
%            fail with unpredictable results.
%
%            [p,Yfitted]=CURVEFITNL(X,Y,FSTRING,GUESS) returns the 
%            estimated parameters p(1), p(2), etc. in p, and returns
%            the resulting best fit data in Yfitted.
%
%            CURVEFITNL(X,Y,FSTRING,GUESS,OPTIONS) allows the caller to 
%            specify certain options.  If OPTIONS(1)=1, then no plot is 
%            generated.  This is useful if the caller is only interested in 
%            the returned values.  If OPTIONS(2)=1, then the X-axis is 
%            plotted on a log scale.  If OPTIONS(3)=1, then the Y-axis 
%            is plotted on a log scale. If OPTIONS(4) is specified, its 
%            value is assumed to be a character representing the symbol to 
%            use to plot the original data, which has a default value of '*'.  
%            This element can be set to the character 'i' for invisible if 
%            only the best-fit curve is desired in the plot.

%            Written by Jim Rees, 5 Mar. 1992

if nargin<4, error('Too few arguments'); end

if nargin<5, 
	options=[0 0 0 '*']; 
else
	options=options(:).';  % Forces options to be a row vector

	% This zeros all non-existent terms.
	if length(options)<4, options(4)='*'; end  
end

% Make x and y be column vectors.
x = x(:); y = y(:);

% Create the function file.  This is a little gross, and it might
% not be portable.

funfile='/tmp/curvefitnl_fun.m';
shortname='curvefitnl_fun';
eval(['delete ' funfile]);
fprintf(funfile,['function [F]=' shortname '(p,x,y)\n']);
fprintf(funfile,['F=(' fstring ')-y;\n']);
mpath_orig=matlabpath;
matlabpath([mpath_orig ':/tmp']);  % add /tmp to the matlab path

% Perform the least squares fit.
p=leastsq(shortname,iniguess,[],[],x,y);
yfitted=eval(fstring);

matlabpath(mpath_orig);  % Restore the original matlab path

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
	eval([plotcmd '(x,y,options(4),x,yfitted,''-'')']);

end
disp(options)

% Set ans to P if the caller is expecting returned values.
if nargout>=1, p1=p; end
