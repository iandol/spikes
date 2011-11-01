function [cmap] = rbmap(minv, maxv, zerov)

% [cmap] = rbmap(min=0, max=1)
%
% Makes a red/blue colormap a la Alonso & Reid.
%
%

nentries = 256;
power = 0.5;

minus_saturation = 0.8;
minus_hue = 0.68; % 0.58;
 
plus_saturation = 0.8;
plus_hue = 0.98;

cmap = zeros(nentries,3);

if nargin<2  ||  ~exist('minv','var') || ~exist('maxv','var') || isempty(minv) || isempty(maxv) || maxv<=minv
   minv = -1;
   maxv = 1;
end

if nargin<3 || ~exist('zerov','var') || isempty(zerov)
	   zerov=0.5;
end

if zerov>1
	zerov=1;
end

%zeropoint = ceil(nentries*(0-minv)/(maxv-minv));
%if zeropoint < 1, zeropoint = 1; end;
zeropoint=ceil(nentries*zerov);

for i=1:(zeropoint-1),
   cmap(i,1) = minus_hue;
   cmap(i,2) = minus_saturation;
   cmap(i,3) = (zeropoint-i)/(zeropoint-1);
end;

for i=zeropoint:nentries,
   cmap(i,1) = plus_hue;
   cmap(i,2) = plus_saturation;
   cmap(i,3) = (i-zeropoint)/(nentries-zeropoint);
end;

cmap(:,3) = cmap(:,3).^power;

cmap = hsv2rgb(cmap);





