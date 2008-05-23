function [interaction,inner,outer]=sinmodel(modvals,X,freq,nmods,compat)

% y=sinmodel(modvals,x,frequency)
%

if ~exist('nmods','var')
	nmods=5;
end
if ~exist('freq','var')
	freq=2;
end
if ~exist('compat','var');
	compat=false;
end

if length(modvals)==6
	rlevelinner=modvals(1)-1;      %convert from 0 to 2 to -1 to 1
	rlevelouter=modvals(1)-1;      %convert from 0 to 2 to -1 to 1
else
	rlevelinner=modvals(1)-1;      %convert from 0 to 2 to -1 to 1
	rlevelouter=modvals(7)-1;      %convert from 0 to 2 to -1 to 1
end
rlevelmodel=modvals(2)-1;		%convert from 0 to 2 to -1 to 1
strength=modvals(3);
piphase=ang2rad(modvals(4));
piphase2=ang2rad(modvals(5));
scale=modvals(6); %scale model to data;

%-------------------------------------------------------------
% We will recompute to same number of bins as the real data
% to use them for fitting, no plots.
%-------------------------------------------------------------
resolution=length(X); %find out how long the raw psth is

p=freq*(nmods);  % we want 5 modulations of the centre,so multiply by 5 to get outer mods 

o=linspace(0, p*pi, resolution);
outer=sin(o-piphase2); %work out outer with phase shift
x=find(outer<=rlevelouter);
outer(x)=rlevelouter;
outer=outer-rlevelouter;
if max(outer)>0
	outer=outer/max(outer);
end
outer=outer*strength;    % scales the outer by strength

i=linspace(0, (nmods*2)*pi, resolution);  %2pi * 5 modulations
inner=sin(i-piphase); %work out inner with phase shift
x=find(inner<=rlevelinner);
inner(x)=rlevelinner;
inner=inner-rlevelinner;  %rectify so above 0
if max(inner)>0
	inner=inner/max(inner);   %normalise to 1
end

interaction=inner-outer; 
if max(interaction)>0; interaction= interaction / max(interaction); end%normalized to 1
x=find(interaction<=rlevelmodel);
interaction(x)=rlevelmodel;
if compat==true; interaction=interaction-rlevelmodel; end     %rectify so above 0, this is the old way
if max(interaction)>0
	interaction=interaction/max(interaction); 
end   %normalise to 1

interaction=interaction'*scale;
inner=inner'*scale;
outer=outer'*scale;
