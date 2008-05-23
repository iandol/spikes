% Detection and Removal of Outliers in Data Sets
% ( Rosner's many-outlier test)
%
% index = outlier( y, crit, k )
%
% where index = indices of outliers in the data
% y = data set (should be stationary)
% crit = detection criterion (default 2)
% k = number of outliers to be detected
%
% Originally written by Bob Newell, February 1996
% Modified by Jaco de Groot, May 2006
% Bob Newell used a fixed value for lambda. This script calculates the
% critical values for lambda based on the equations in
% "Quality control of semi-continuous mobility size-fractionated particle 
% number concentration data", Atmospheric Environment 38 (2004) 3341?3348,
% Rong Chun Yu,*, Hee Wen Teh, Peter A. Jaques, Constantinos Sioutas,
% John R. Froines)
%-----------------------------------------------------
%
function index = outlier( y, alpha, k)
%
y = y(:);
n = length( y );
if nargin < 2; alpha = 0.05; end
if nargin < 3; k = 1; end
R = zeros( k+1, 1 );
% sort deviations from the mean
ybar = mean( y );
[ ys, is ] = sort( abs( y - ybar ));
% calculate statistics for up to k outliers
for i = 0:k,
yy = ys(1:n-i);
R(i+1) = abs( yy(n-i) - mean(yy) ) / std(yy);
end; 
% statistical test to find outliers
index1 = [];
imax=0;
for i = 1:k
%
pcrit=1-(alpha/((2*(n-i+1))));
t=tinv(pcrit, n-i-1);
lambda(i)=(n-i)*t./sqrt(((n-i-1+t^2)*(n-i+1)));
%
if R(i) > lambda
index=is(n-i+1:end); 
index1 = [ index1 is(n-i+1) ];
end 
end
% report results
if exist('index', 'var')
disp(' '), disp( [ 'Outliers detected = ' num2str( length( index ) ) ] )
disp(' '), disp( 'Outlier indices are:' )
disp( index )
else
disp(' '), disp( 'No outlier is detected!' ), disp(' ')
end
%-----------------------------------------------------
% the end