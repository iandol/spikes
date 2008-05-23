function [y,g]=sinmodelf(modvals,X,Y,a)

% y=sinmodel(modvals,x,frequency)
%

 rlevel=(modvals(1));%-0.5)*2;      %convert from 0 to 1 to -1 to 1
 rlevel2=(modvals(2));%-0.5)*2;		%convert from 0 to 1 to -1 to 1
 strength=modvals(3);
 piphase=modvals(4);%*(2*pi);		%convert from 0 to 1 to radians
 piphase2=modvals(5);%*(2*pi);		%convert from 0 to 1 to radians


if a==1
	freq=0.5;
elseif a==2
	freq=1;
elseif a==3
	freq=1.5;
elseif a==4
	freq=2;
elseif a==5
	freq=3;
elseif a==6
	freq=4;
elseif a==7
	freq=6;
elseif a==8
	freq=8;
elseif a>8
	freq=2;
end


%-------------------------------------------------------------
% We will recompute to same number of bins as the real data
% to use them for fitting, no plots.
%-------------------------------------------------------------
resolution=length(X); %find out how long the raw psth is

p=freq*5;  % we want 5 modulations of the centre,so multiply by 5 to get outer mods 

o=linspace(0, p*pi, resolution);
outer=sin(o-piphase2); %work out outer with phase shift
x=find(outer<=rlevel);
outer(x)=rlevel;
outer=outer-rlevel;
outer=outer/max(outer);   
outer=outer*strength;    % scales the outer strength

i=linspace(0, 10*pi, resolution);  %2pi * 5 modulations
inner=sin(i-piphase); %work out inner with phase shift
x=find(inner<=rlevel);
inner(x)=rlevel;
inner=inner-rlevel;  %rectify so above 0
inner=inner/max(inner);   %normalise to 1

interaction=inner-outer; 
if max(interaction)>0; interaction= interaction / max(interaction); end%normalized to 1
x=find(interaction<=rlevel2);
interaction(x)=rlevel2;
interaction=interaction-rlevel2;       %rectify so above 0
if max(interaction)>0; interaction= interaction / max(interaction); end   %normalise to 1

y=interaction';

y=abs((Y\y)-1)   %this gives a least squared estimate of the data Y

if nargout > 1   %used for simps
	g=[];
end
