function fitphase(a,pscale,doplot)

% Give it the frequency, the scale, and whether to plot or spit 
% out numbers, and it will do so.

global piphase;
global pdata;

%rectify=get(findobj('Tag','RectifyBox'),'Value');
%rlevel=get(findobj('Tag','EditLevel'),'String');
%rlevel=str2num(rlevel);

rectify=1;
rlevel=-0.9;

if ~piphase
   piphase=0;
end

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
end

if plot==1;
   
   resolution=500;
   
   p=freq*5;  % we want 5 modulations of the centre,so multiply by 5 to get outer mods 
   
   time=linspace(0, 2.5, resolution);   
   
   o=linspace(0, p*pi, resolution);
   outer=sin(o-piphase); %work out outer with phase shift
   if rectify==1
      x=find(outer<=rlevel);
      outer(x)=rlevel;
      outer=outer-rlevel;
      outer=outer/max(outer);
   end
   
   i=linspace(0, 10*pi, resolution);  %2pi * 5 modulations
   inner=sin(i-piphase); %work out inner with phase shift
   if rectify==1
      x=find(inner<=rlevel);
      inner(x)=rlevel;
      inner=inner-rlevel;       %rectify so above 0
      inner=inner/max(inner);   %normalise to 1
   end 
   
   interaction=inner-outer; 
   if max(interaction)>0; interaction= interaction / max(interaction); end %normalized to 1
   interaction=interaction*pscale;  %scale for the PSTH size
   inner=inner*pscale;
   %whos time inner interaction
   %hold on
   plot(time,inner,'g--',time,interaction,'r-');
   xlabel(num2str(freq));
   %hold off
   
else
   %-------------------------------------------------------------
   % We will now recompute to allow the PSTH ratio routine
   % to use them as an index
   %-------------------------------------------------------------
   resolution=length(pdata.psth{2}(:,3)); %find out how long the raw psth is
   
   p=freq*5;  % we want 5 modulations of the centre,so multiply by 5 to get outer mods 
   
   time=linspace(0, 2.5, resolution);   
   
   o=linspace(0, p*pi, resolution);
   outer=sin(o-piphase); %work out outer with phase shift
   x=find(outer<=rlevel);
   outer(x)=rlevel;
   outer=outer-rlevel;
   outer=outer/max(outer);
   
   i=linspace(0, 10*pi, resolution);  %2pi * 5 modulations
   inner=sin(i-piphase); %work out inner with phase shift
   x=find(inner<=rlevel);
   inner(x)=rlevel;
   inner=inner-rlevel;  %rectify so above 0
   inner=inner/max(inner);   %normalise to 1
   
   interaction=inner-outer; 
   if max(interaction)>0; interaction= interaction / max(interaction); end%normalized to 1
   interaction=interaction*pscale;  %scale for the PSTH size
   inner=inner*pscale;
   
   pdata.interaction{a}=interaction';
   pdata.inner{a}=inner';
   
end

