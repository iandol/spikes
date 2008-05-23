function [cmap] = gbmap(zerov)

% [cmap] = makerbcmap(zerov)
%
% Makes a grey/black colormap a la Alonso & Reid.
%
%

nentries = 256;
cmap=ones(nentries,3);

if zerov>1 || zerov< 0
	zerov=0.5;
end

zeropoint=ceil(nentries*zerov);

if zeropoint<11
	zeropoint=11;
elseif zeropoint>245
	zeropint=245;
end

for i=1:(zeropoint-10),
   cmap(i,1) = 0.7;
   cmap(i,2) = 0.7;
   cmap(i,3) = 0.7;
end;

for i=zeropoint+10:nentries,
   cmap(i,1) = 0;
   cmap(i,2) = 0;
   cmap(i,3) = 0;
end;







