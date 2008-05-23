function drawphase(action)

%   Function DrawPhase: draws phase interactions for different frequencies
%
%

global version;
global piphase;
global piphase2
global resolution;
global rectify;

%%%%%Check whether we are starting for the first time%%%
if nargin<1,
   action='Initialize';
   piphase=0;       %initial phase value
   piphase2=0;
   strength=1;
   resolution=800;  %resolution (number of points) of the curves
   rectify=1;
end
 
%%%%%%%%%%%%%%Switch for the GUI%%%%%%%%%%%%%
switch(action)
    
%%%%%%%%%%%%%%When run for the first time%%%%%%%%%%%%%%   
case 'Initialize'  
   drawphasefig; 
   version='Draw-Phase V1.2a';
   set(gcf,'Name', version); %Sets Version data
   set(gcf,'DefaultLineLineWidth', 2);
   box on
   
%%%%%%%%%%%%%%%%Calculate the Curves%%%%%%%%%%%%%%%%%%
case 'Frequency'
   
   resolution=800;  %resolution (number of points) on the curves

   rectify=get(findobj('Tag','RectifyBox'),'Value');
   rlevel=str2num(get(findobj('Tag','EditLevel'),'String'));
   rlevel2=str2num(get(findobj('Tag','EditLevel2'),'String'));
   strength=str2num(get(findobj('Tag','EditStrength'),'String'));
   
   freq=get(findobj('Tag','EditFrequency'),'String');
   freq=str2num(freq);
   
   p=freq*5;  % we want 5 modulations of the centre,so multiply by 5 to get outer mods 
      
   time=linspace(0, 2.5, resolution);   
   
   o=linspace(0, p*pi, resolution);
   outer=sin(o-piphase2); %work out outer with phase shift
   if rectify==1
      a=find(outer<=rlevel);
      outer(a)=rlevel;
      outer=outer-rlevel;
      outer=outer/max(outer);
   end
   outer=outer*strength; %scales the outer strength
   
   i=linspace(0, 10*pi, resolution);  %2pi * 5 modulations
   inner=sin(i-piphase); %work out inner with phase shift
   if rectify==1
      a=find(inner<=rlevel);
      inner(a)=rlevel;
      inner=inner-rlevel;  %rectify so above 0
      inner=inner/max(inner);   %normalise to 1
   end   
   
   interaction=inner-outer; 
   if max(interaction)>0; interaction= interaction / max(interaction); end %normalized to 1
   if rectify==1
      x=find(interaction<=rlevel2);
      interaction(x)=rlevel2;
      interaction=interaction-rlevel2;       %rectify so above 0
      if max(interaction)>0; interaction= interaction / max(interaction); end   %normalise to 1
   end 
   
   plot(time,inner,'b--',time,outer,'k:',time,interaction,'r-')
   
   axis([-0.05 2.55 0 1.05])
   
   xlabel('Time (Seconds)')
   ylabel('Normalized Model Response')
   
   legend('Centre','Surround','Interaction')    
   
case 'Phase' %Change Phase
   phase=str2num(get(findobj('Tag','EditPhase'),'String'));  
   phase2=str2num(get(findobj('Tag','EditPhase2'),'String'));
   if phase==0 & phase2==0
      piphase=0
      piphase2=0
      drawphase('Frequency');
   else
      percent=phase/360;
      piphase=(2*pi)*percent
      percent2=phase2/360;
      piphase2=(2*pi)*percent2
      drawphase('Frequency');
   end
   
case 'Loop'
   
   resolution=400;
   rectify=get(findobj('Tag','RectifyBox'),'Value');
   rlevel=str2num(get(findobj('Tag','EditLevel'),'String'));
   rlevel2=str2num(get(findobj('Tag','EditLevel2'),'String'));
   strength=str2num(get(findobj('Tag','EditStrength'),'String'));
   freq=get(findobj('Tag','EditFrequency'),'String');
   freq=str2num(freq(1));
   p=freq*5;
   time=linspace(0, 2.5, resolution/2);
   o=linspace(0, p*pi, resolution/2);
   i=linspace(0, 10*pi, resolution/2);  %2pi * 5 modulation
   
   for l=0:5:360;      
      percent=l/360;
      piphase=(2*pi)*percent; 
      piphase2=piphase
      
      outer=sin(o-piphase2); %work out outer with phase shift
      if rectify==1
         a=find(outer<=rlevel);
         outer(a)=rlevel;
         outer=outer-rlevel;
         outer=outer/max(outer);
      end
      outer=outer*strength; %scales the outer strength
      
      inner=sin(i-piphase); %work out inner with phase shift
      if rectify==1
         a=find(inner<=rlevel);
         inner(a)=rlevel;
         inner=inner-rlevel;  %rectify so above 0
         inner=inner/max(inner);   %normalise to 1
      end   
      
      interaction=inner-outer; 
      if max(interaction)>0; interaction= interaction / max(interaction); end %normalized to 1
      if rectify==1
         x=find(interaction<=rlevel2);
         interaction(x)=rlevel2;
         interaction=interaction-rlevel2;       %rectify so above 0
         if max(interaction)>0; interaction= interaction / max(interaction); end   %normalise to 1
      end 
      
      plot(time,inner,'b--',time,outer,'k:',time,interaction,'r-')
      axis([-Inf Inf 0 1]);
      axis off;
      text(0,0.95,strcat('Phase=',num2str(l)),'FontSize',14);
      pause(0.001)
   end
   
case 'Spawn'
   figure
   set(gcf,'DefaultLineLineWidth', 2);
   box on
   drawphase('Phase') %get the phase and then run calculation

   
end %End of Main Switch