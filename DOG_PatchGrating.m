%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOG_PatchGrating.m  - 07.01.06 %%
% Written by Gaute T. Einevoll (gaute.einevoll@umb.no)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Requires:
%  'fun_DOG_patch_series_dvary' which in turn requires 
%  'fun_X_series_dvary'
% THESE ARE ATTACHED AT THE END, SO THIS SCRIPT SHOULD BE ALL YOU NEED.
%  'fun_X_series_dvary' call the MATLAB function 'Hypergeom' which is only available
%  with the Symbolic Math Toolbox.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DOG_PatchGrating
if matlabpool('size') == 0
	tic;matlabpool
	fprintf('matlabpool took: %g seconds to initialize\n',toc)
	weOpenPool = true;
else
	fprintf('matlabpool seems open...\n');
	weOpenPool = false;
end

% Example DOG parameters
%A1=1; A2=0.9; aa1=0.3; aa2=0.6;
A1=61; A2=29.6; aa1=0.82; aa2=4.95;
para_DOG=[A1 aa1 A2 aa2];
sf = 0.75;
% Example grid of patch-grating diameters
d_grid=[0 0.3 0.5 0.7 1 1.5 2 4 6 9];
% Example grid of kd - note kd=2*pi*nud where nud is the spatial frequency of the grating
kd_grid=2*pi*sf;
% Value of nmax, that is the highest value of n in the series summation of X
nmax=4;

try
	for ikd=1:size(kd_grid,2)
	  %Evaluation of patch-grating response
	  kd=kd_grid(ikd);
	  tic
	  DOG_response=fun_DOG_patch_series_dvary([para_DOG kd nmax],d_grid);
	  timetook = toc;
	  fprintf('\nValue of kd: %i took %g seconds to process\n',ikd,timetook)
	  figure;
	  plot(d_grid,DOG_response,'k-o');
	  title(sprintf('KD = %.4g | NMAX = %i | Time = %.3g secs', kd, nmax, timetook));
	end
	if weOpenPool == true; matlabpool close; end
catch ME
	if weOpenPool == true; matlabpool close; end
	rethrow ME
end


%%%%%%%%%%%%%%%%%
% fun_DOG_patch_series_dvary.m
%%%%%%%%%%%%%%%%%
% Requires:
%  'fun_X_series_dvary.m'
%%%%%
% fun_DOG_patch_series_dvary evaluates the DOG-model response  
% for a set of circular grating patch of diameter d using the SERIES expansion
% x(1): A1
% x(2): aa1
% x(3): A2
% x(4): aa2
% x(5): kd
% x(6): nmax
% Note that x-coordinate is patch diameter d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function y=fun_DOG_patch_series_dvary(x,xdata)
xe(1)=x(2); xe(2)=x(5); xe(3)=x(6);
xi(1)=x(4); xi(2)=x(5); xi(3)=x(6);
y = x(1)*fun_X_series_dvary(xe,xdata)-x(3)*fun_X_series_dvary(xi,xdata);


%%%%%%%%%%%%%%%%%
% fun_X_series_dvary.m 
%%%%%%%%%%%%%%%%%
% fun_X_series_dvary evaluates the X-function needed to calculate the
% DOG-response to patch gratings as a function of d values using a series
% expression
% x(1): a
% x(2): kd
% x(3): nmax, number of terms summed over
% xdata: points on the d-axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function y = fun_X_series_dvary(x,xdata)
[~, ndmax]=size(xdata);
if x(1) <= 0 || isnan(x(1))
	y=zeros(1,ndmax);
	return;
end
yp=zeros(1,ndmax);
yp=x(1)./xdata;
zp=x(1)*x(2);
nmax=x(3);
y=zeros(1,ndmax);
if matlabpool('size') > 0
	fprintf('--> Computing CHF in parallel: ');fprintf('%.4g ',x);
	for nd=1:ndmax
		parfor n=0:nmax
		  yy(n+1) = exp(-zp^2/4)/(4*yp(nd)^2)/factorial(n)*(1/4)^n*zp^(2*n)*double(mfun('Hypergeom',[n+1],[2],-1/(4*(yp(nd)^2))));
		end
		y(nd) = sum(yy);
	end
else
	fprintf('--> Computing CHF serially: ');fprintf('%.4g ',x);
	for nd=1:ndmax
		for n=0:nmax
			y(nd) = y(nd) + exp(-zp^2/4)/(4*yp(nd)^2)/factorial(n)*(1/4)^n*zp^(2*n)*double(mfun('Hypergeom',[n+1],[2],-1/(4*(yp(nd)^2))));
		end
	end
end