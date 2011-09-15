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
tic
matlabpool
fprintf('matlabpool took: %g seconds to initialize\n',toc)
% Example DOG parameters
A1=10; A2=8; aa1=0.3; aa2=0.6;    
para_DOG=[A1 aa1 A2 aa2];
% Example grid of patch-grating diameters 
d_grid=[0 0.5 1 2 4 8];
% Example grid of kd - note kd=2*pi*nud where nud is the spatial frequency of the grating
kd_grid=[0 pi 2*pi];
% Value of nmax, that is the highest value of n in the series summation of X 
nmax=16; 
try
	for ikd=1:size(kd_grid,2)
	  %Evaluation of patch-grating response
	  kd=kd_grid(ikd);
	  tic
	  DOG_response=fun_DOG_patch_series_dvary([para_DOG kd nmax],d_grid);
	  fprintf('kd_grid %i took: %g seconds to initialize\n',ikd,toc)
	  figure;
	  plot(d_grid,DOG_response,'k-o');
	  title(['KMAX = ' num2str(kd)]);
	end
matlabpool close
catch ME
	matlabpool close
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
yp=zeros(1,ndmax);
yp=x(1)./xdata;
zp=x(1)*x(2);
nmax=x(3);
y=zeros(ndmax);
if matlabpool('size') > 0
	for nd=1:ndmax
	  parfor n=0:nmax
		  yy(n+1) = exp(-zp^2/4)/(4*yp(nd)^2)/factorial(n)*(1/4)^n*zp^(2*n)*double(mfun('Hypergeom',[n+1],[2],-1/(4*(yp(nd)^2))));
	  end
	  y(nd) = sum(yy);
	end
else
	for nd=1:ndmax
	  for n=0:nmax
	      y(nd) = y(nd) + exp(-zp^2/4)/(4*yp(nd)^2)/factorial(n)*(1/4)^n*zp^(2*n)*double(mfun('Hypergeom',[n+1],[2],-1/(4*(yp(nd)^2))));
	  end
	end
end