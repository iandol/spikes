function psthread2(action)

% PSTHRead() GUI PSTH plotting Program
%
%

global pdata;
global header;
global tmp;
global part;


%%%%%Check whether we are starting for the first time%%%
if nargin<1,
   action='Initialize';
end

%%%%%%%%%%%%%%See what MetAnal needs to do%%%%%%%%%%%%%
switch(action)
   
   %%%%%%%%%%%%%%When run for the first time%%%%%%%%%%%%%   
case 'Initialize'  
   psthreadfig; 
   header='';
   pdata=[];
   x=0;
   version='PSTH-Read V1.1a';
   set(gcf,'Name', version); %Sets Version data
   set(gcf,'DefaultLineLineWidth', 1.5);
   
case 'Load'
   pdata=[];
   set(findobj('Tag','EditSelectBox'),'String','0'); 
   set(findobj('Tag','EditPhaseBox'),'String','0');
   set(findobj('Tag','EditPhaseBox2'),'String','0');
   set(findobj('Tag','EditStrength'),'String','1');   
   set(findobj('Tag','EditScale'),'String','0');
   set(findobj('Tag','EditScale'),'Enable','off');
   set(gcbf, 'UserData', '');
   dos('"C:\Program Files\Frogbit\frogbitrun.exe" "C:\Program Files\Frogbit\psthstrip.FB"');
   curr=pwd;
   cd('c:\');   
   [header,x]=hdload('frogtemp2');  % Loads file   
   cd(curr);
   
   %--This loop extracts the psth's for each independant variable---
   numbins=size(unique(x(:,1)),1);
   a=1;
   
   for i=1:numbins:size(x,1)      
      pdata.psth{a}=x(i:(i+numbins-1),:);
      pdata.psth{a}(1:5,3)=pdata.psth{a}(1:5,3)./5;   %scale transient response
      %pdata.psth{a}(:,3)=smooth(pdata.psth{a}(:,3),1);
      a=a+1;      
   end
   
   %------------set up the data structure----------
   pdata.num=a-1;  %how many psths were loaded
   pdata.title=header;
   pdata.inner=cell(pdata.num,1);
   pdata.interaction=cell(pdata.num,1);
   pdata.maxtime=max(pdata.psth{1}(:,2));
   pdata.piphase=0;
   pdata.piphase2=0;
   pdata.currentplot='psth';   

   % -------- get scale to plot all psths-----------
   l=length(pdata.psth{1}(:,3));
   m=0;
   n=0;
   for p=1:pdata.num       %go through each psth
      m=max(pdata.psth{p}(:,3));  %start at 5 to ignore any transient
      if m<n
         m=n;
      end
      n=m;
   end
   
   pdata.yscale=m;

%------We want each PSTH to have a scale for the model to be fit to-----
%------this extracts a mean peak for each modulation--------------------
   if pdata.maxtime>2         %we have 5 mods
      for p=1:pdata.num       %go through each psth for the local maximum
         pst=pdata.psth{p}(:,3);
         time=pdata.psth{p}(:,2);
         binw=time(2)-time(1);
         steps=0.5/binw;
         a=0.14;
         for i=1:5
            if i<5
               [v,indx1]=minim(time,a);
               indx2=indx1+steps;
               peak(i)=max(pst(indx1:indx2));
               a=time(indx2);
            else
               [v,indx1]=minim(time,a);
               peak(i)=max(pst(indx1:end));
            end         
         end
         pdata.pscale(p)=sum(peak)/5;                     
      end      
   else                     %we dont have 5 mods
      for p=1:pdata.num
         pst=pdata.psth{p}(:,3);
         %these 3 lines finds the max, the max+1 and the next peak for averaging
         [val, indx]=max(pst);
         peak2=max([max(pst(1:indx-1)), max(pst(indx+1:end))]);
         pdata.pscale(p)=sum([peak2, pst(indx), pst(indx+1)])/3; 
      end
   end
   
   %-----------This scales the transient to the same as the peak
   for a=1:pdata.num
      if max(pdata.psth{a}(1:5,3))>=pdata.pscale(a)
         fac=pdata.pscale(a)/max(pdata.psth{a}(1:5,3))
         pdata.psth{a}(1:5,3)=pdata.psth{a}(1:5,3).*fac;   %scale transient response
      end
   end
   
   %-----------------Run the plotting and generate a global phase--------
   pdata.select=0;
   psthread('Phase');
   psthread('Minimise');
   
%------------Spawn the Figure for exporting---------------------   
case 'Spawn'
   figure;
   set(gcf, 'Position', [5 60 1020 560]);
   set(gcf,'DefaultLineLineWidth', 2);
   
   if strcmp(pdata.currentplot,'fft');
      psthread('FFT');
   else
      psthread('Phase');
   end   
   
%--------Get parameters and plot the data------------------------------   
case 'Phase'   
   phase=str2num(get(findobj('Tag','EditPhaseBox'),'String'));   
   phase2=str2num(get(findobj('Tag','EditPhaseBox2'),'String'));   
   select=str2num(get(findobj('Tag','EditSelectBox'),'String')); 
   pdata.scale=str2num(get(findobj('Tag','EditScale'),'String'));
   if select==0;   %psths shown for all variables   
      if phase==0 & phase2==0
         pdata.optphase=phase;
         pdata.optphase2=phase2;
         pdata.piphase=0;
         pdata.piphase2=0;
         if strcmp(pdata.currentplot,'fft');
            pdata.currentplot='FFT';
            psthread('FFT');
         else
            Plotpsth(pdata.yscale);
         end         
      else
         pdata.optphase=phase;
         percent=phase/360;
         pdata.piphase=(2*pi)*percent;
         pdata.optphase2=phase2;
         percent=phase2/360;
         pdata.piphase2=(2*pi)*percent;
         if strcmp(pdata.currentplot,'fft');
            pdata.currentplot='FFT';
            psthread('FFT');
         else
            Plotpsth(pdata.yscale);
         end
      end
   else
      if phase==0 & phase2==0
         pdata.optphase=phase;
         pdata.optphase2=phase2;
         pdata.piphase=0;
         pdata.piphase2=0
         if strcmp(pdata.currentplot,'fft');
            pdata.currentplot='FFT';
            psthread('FFT');
         else
            Plotsingle(select);
         end         
      else
         pdata.optphase=phase;
         pdata.optphase2=phase2;
         percent=phase/360;
         pdata.piphase=(2*pi)*percent;         
         percent=phase2/360;
         pdata.piphase2=(2*pi)*percent;
         if strcmp(pdata.currentplot,'fft');
            pdata.currentplot='FFT';
            psthread('FFT');
         else
            Plotsingle(select);
         end
      end
   end
   
%----------------do PSTH ratio analysis-----------------------   
case 'Measure'
   cutoff=get(findobj('Tag','EditRatio'),'String');   
   cutoff=str2num(cutoff);
   peaks=find(inner>cutoff)
   inner(peaks)
   a=1;
   %figure
   subplot(2,4,3)
   if length(peaks)==5
      for m=2:5
         if peaks(m)<=119 %check if we are close to edge
            %subplot(2,3,a)
            centre=peaks(m);  %find the centre of the bin
            part=tmp.psth{3}(centre-6:centre+6,3);
            %plot(tmp{4}(centre-6:centre+6,2),part);
            %axis([-inf inf 0 yscale])
            avg(:,a)=sum(part)/length(part);
            a=a+1;
         else
            %subplot(2,3,a)
            centre=peaks(m);  %find the centre of the bin
            part=tmp.psth{3}(centre-6:125,3);
            %plot(tmp{4}(centre-6:125,2),part);
            %axis([-inf inf 0 yscale])
            avg(:,a)=sum(part)/length(part);
            a=a+1;
         end
      end
      percent(:,1)=(avg(4)/avg(1))*100;
      percent(:,2)=(avg(3)/avg(1))*100;
      percent(:,3)=(avg(4)/avg(2))*100;
      percent(:,4)=(avg(3)/avg(2))*100;
      text=('   4 to 1 ;    3 to 1 ;    4 to 2 ;    3 to 2')
      percent
   else
      msgbox('Sorry, need to adjust value')         
   end      
   
%---------Find the best phase / rectification using a fitting routine----   
case 'Minimise'    
   select=get(findobj('Tag','EditSelectBox'),'String');   
   select=str2num(select);  
   choose=get(findobj('Tag','MinimiseMenu'),'Value');
   
   if strcmp(pdata.currentplot,'fft');
      set(findobj('Tag','RectifyBox'),'Value',1);
      set(findobj('Tag','EditPhaseBox'),'String',pdata.optphase);
      set(findobj('Tag','EditPhaseBox2'),'String',pdata.optphase);
      percent=pdata.optphase/360;
      pdata.piphase=(2*pi)*percent;
      pdata.pihase2=pdata.piphase;
      rec=-1:0.1:0.9;
      a=1;
      
      for i=-1:0.1:0.9       %rectification level
         set(findobj('Tag','EditLevel'),'String',num2str(i));
         fitphase(select,pdata.pscale(select),0);
         if choose==2;
            g(a)=fftplot(pdata.psth{select}(:,3),pdata.interaction{select},pdata.maxtime,0);
            p(a)=goodness(pdata.psth{select}(:,3),pdata.interaction{select}); 
         elseif choose==1;
            g(a)=fftplot(pdata.psth{select}(:,3),pdata.inner{select},pdata.maxtime,0);
            p(a)=goodness(pdata.psth{select}(:,3),pdata.inner{select});
         end
         a=a+1;
      end
      
      [v,indx]=max(g);
      pdata.bestfft=rec(indx);
      [v,indx]=max(p);
      pdata.bestpsth=rec(indx);
      set(findobj('Tag','EditLevel'),'String',pdata.bestfft);
      pdata.currentplot='fft';
      psthread('FFT');
      
   elseif select>0
      set(findobj('Tag','RectifyBox'),'Value',1);
      set(findobj('Tag','EditPhaseBox'),'String',pdata.optphase);
      set(findobj('Tag','EditPhaseBox2'),'String',pdata.optphase);
      percent=pdata.optphase/360;
      pdata.piphase=(2*pi)*percent;
      pdata.piphase2=pdata.piphase;
      rec=-1:0.1:0.9;
      a=1;
      
      for i=-1:0.1:0.9       %rectification level
         set(findobj('Tag','EditLevel'),'String',num2str(i));
         fitphase(select,pdata.pscale(select),0);
         if choose==2;
            p(a)=goodness(pdata.psth{select}(:,3),pdata.interaction{select});  
         elseif choose==1
            p(a)=goodness(pdata.psth{select}(:,3),pdata.inner{select});
         end         
         a=a+1;
      end
      
      [v,indx]=max(p);
      pdata.bestpsth=rec(indx);
      pdata.bestpsth;
      set(findobj('Tag','EditLevel'),'String',pdata.bestpsth);
      pdata.currentplot='psth';
      psthread('Phase');
      
   else
      set(findobj('Tag','EditSelectBox'),'String','0');   
      set(findobj('Tag','RectifyBox'),'Value',1);
      %set(findobj('Tag','EditLevel'),'String','-0.9');
      set(findobj('Tag','EditPhaseBox'),'String','0');
      set(findobj('Tag','EditPhaseBox2'),'String','0');
      pdata.inner=[];
      pdata.interaction=[];
      pdata.phase=[];
      pdata.phase2=[];
      pdata.optphase=[];
      pdata.optphase2=[];
      psthread('Phase'); 
      a=1;
      
      for i=0:10:350    %phase 
         percent=i/360;
         pdata.piphase=(2*pi)*percent; 
         pdata.piphase2=pdata.piphase;
         for k=1:pdata.num     
            fitphase(k,pdata.pscale(k),0);
            if choose==1
               g(k)=goodness(pdata.psth{k}(:,3),pdata.inner{k});        %for the phase  
            elseif choose==2
               g(k)=goodness(pdata.psth{k}(:,3),pdata.inner{k});
            end            
         end         
         pdata.phase(a,:)=g;
         g=[];
         pdata.inner=[];
         a=a+1;
      end
      
      i=0:10:350;
      [g,indx]=max(pdata.phase); %find the closest fit
      x=i(indx)
      x=median(x)
      set(findobj('Tag','EditPhaseBox'),'String',x);
      set(findobj('Tag','EditPhaseBox2'),'String',x);
      pdata.optphase=x;
      pdata.piphase=(2*pi)*pdata.optphase; 
      pdata.piphase2=pdata.piphase;
      pdata.currentplot='psth';
      psthread('Phase');    
   end
   
%-----------------------choose a PSTH to plot------------------   
case 'Select'
   select=get(findobj('Tag','EditSelectBox'),'String');   
   select=str2num(select);
   pdata.select=select;
   if select==0
      set(findobj('Tag','MinimiseMenu'),'Value',1);
      pdata.currentplot='psth';
      Plotpsth(pdata.yscale);
   else
      set(findobj('Tag','MinimiseMenu'),'Value',2);
      pdata.currentplot='psth';
      Plotsingle(pdata.select)
   end
   
%-----------------------do a smart model fit-------------------   
   
case 'Simplex'
	if pdata.select==0
		errordlg('Sorry,you need to select a PSTH First')
		error;
	else	
		x=pdata.psth{pdata.select}(:,2);
		y=pdata.psth{pdata.select}(:,3);
		[xa,ya,y]=smooth(x,y,0.025);
		y=y/max(y);
		rlevel=str2num(get(findobj('Tag','EditLevel'),'String'));
		rlevel2=str2num(get(findobj('Tag','EditLevel2'),'String'));
		strength=str2num(get(findobj('Tag','EditStrength'),'String'));
		piphase=radians(str2num(get(findobj('Tag','EditPhaseBox'),'String')));
		piphase2=radians(str2num(get(findobj('Tag','EditPhaseBox2'),'String')));
		xo=[rlevel rlevel2 strength piphase piphase2]
		options=[ 0 1e-4 1e-4 10 12000 0 ];		
		[f,b]=fitit('sinmodel',y,[-1 -1 0 0 0],xo,[1 1 1 2*pi 2*pi],options,x,pdata.select);
		set(findobj('Tag','EditLevel'),'String',num2str(b(1)))
		set(findobj('Tag','EditLevel2'),'String',num2str(b(2)))
		set(findobj('Tag','EditStrength'),'String',num2str(b(3)))
		set(findobj('Tag','EditPhaseBox'),'String',num2str(degs(b(4))))
		set(findobj('Tag','EditPhaseBox2'),'String',num2str(degs(b(5))))
		pdata.piphase=b(4);
		pdata.piphase2=b(5);
		pdata.optphase=degs(b(4));
		pdata.optphase2=degs(b(5));
		Plotsingle(pdata.select)
	end		
   
%-------------Do FFT analysis------------------------   
case 'FFT'
   select=get(findobj('Tag','EditSelectBox'),'String');   
   select=str2num(select);
   if strcmp(pdata.currentplot,'fft')
      psthread('Phase')
   end
   if select==0
      msgbox('Please Select a Variable first...');
   else      
      pdata.currentplot='fft';
      fitphase(select,pdata.pscale(select),0);
      fftplot(pdata.psth{select}(:,3),pdata.interaction{select},pdata.maxtime,1,16)
      title(pdata.title)
   end      
   
case 'Exit'
   clear all
   close(gcf)
   vs
   
end %end of main switch


%-------------------------------------------------------------------------

function Plotpsth(scale)

global header
global pdata

if pdata.num<=6
   a=2;
   b=3;
elseif pdata.num<=8
   a=2;
   b=4;
elseif pdata.num<=9
   a=3;
   b=3;
elseif pdata.num<=10
   a=2;
   b=5;
end

subplot(1,1,1);

for i=1:pdata.num
   subplot(a,b,i);      
   x=pdata.psth{i}(:,2);
   y=pdata.psth{i}(:,3);
   %pdata.pscale(i)=max(y);
   bar(x,y,1,'k');
   set(gca,'LineWidth', 1);
   fitphase(i,pdata.pscale(i),1);   %actually plot the model
   xscale=max(pdata.psth{i}(:,2));
   axis([0,xscale,0,scale+1]);
   ylabel('Spikes/Bin','FontSize', 9)
end 
subplot(a,b,1)
title(header,'FontSize',7);


%end of plotting function
%---------------------------------------------------------------------------

function Plotsingle(index)

global header
global pdata

xscale=max(pdata.psth{index}(:,2));
subplot(1,1,1);
x=pdata.psth{index}(:,2);
y=pdata.psth{index}(:,3);
bar(x,y,1,'k');
set(gca,'LineWidth', 2);
if pdata.scale>0   %allow a custom scale for themodel
   fitphase(index,pdata.scale,1);
   fitphase(index,pdata.scale,0);   
else
   fitphase(index,pdata.pscale(index),1);
   fitphase(index,pdata.pscale(index),0);
end   
g=goodness(y,pdata.interaction{index});
g2=goodness(y(6:25), pdata.interaction{index}(6:25));
g3=goodness(y(26:end), pdata.interaction{index}(26:end));
g4=g2/g3*100
t=['Explained Variance = ' num2str(g) '% ' ' (' num2str(g4) ' [' num2str(g2) '/' num2str(g3) '] % mod difference)'];
text(0.05,(pdata.yscale-(pdata.yscale/60)),t)
set(gca,'LineWidth', 2);
axis([0,xscale,0,pdata.yscale+1]);
legend('Inner','Outer','Model');
ylabel('Spikes/Bin','FontSize', 9);
title(header,'FontSize',9);

% End of Single Plot Function
%-----------------------------------------------------------------------------


function fitphase(a,pscale,doplot)

global pdata;

rectify=get(findobj('Tag','RectifyBox'),'Value');
rlevel=str2num(get(findobj('Tag','EditLevel'),'String'));
rlevel2=str2num(get(findobj('Tag','EditLevel2'),'String'));
strength=str2num(get(findobj('Tag','EditStrength'),'String'));

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

if doplot==1;
   
   resolution=600;
   
   p=freq*5;  % we want 5 modulations of the centre,so multiply by 5 to get outer mods 
   
   time=linspace(0, 2.5, resolution);   
   
   o=linspace(0, p*pi, resolution);
   outer=sin(o-pdata.piphase2); %work out outer with phase shift
   if rectify==1
      x=find(outer<=rlevel);
      outer(x)=rlevel;
      outer=outer-rlevel;
      outer=outer/max(outer);
   end
   outer=outer*strength; %scales the outer strength
   
   i=linspace(0, 10*pi, resolution);  %2pi * 5 modulations
   inner=sin(i-pdata.piphase); %work out inner with phase shift
   if rectify==1
      x=find(inner<=rlevel);
      inner(x)=rlevel;
      inner=inner-rlevel;       %rectify so above 0
      inner=inner/max(inner);   %normalise to 1
   end 
   
   interaction=inner-outer; 
   if max(interaction)>0; interaction= interaction / max(interaction); end %normalized to 1
   
   rlevel=0;
   if rectify==1
      x=find(interaction<=rlevel2);
      interaction(x)=rlevel2;
      interaction=interaction-rlevel2;       %rectify so above 0
      if max(interaction)>0; interaction= interaction / max(interaction); end   %normalise to 1
   end 
   
   interaction=interaction*pscale;  %scale for the PSTH size
   inner=inner*pscale;
   outer=outer*pscale;
   hold on
   plot(time,inner,'g--',time,outer,'b--',time,interaction,'r-');
   xlabel(num2str(freq));
   hold off
   
else
   %-------------------------------------------------------------
   % We will recompute to same number of bins as the real data
   % to use them for fitting, no plots.
   %-------------------------------------------------------------
   resolution=length(pdata.psth{2}(:,3)); %find out how long the raw psth is
   
   p=freq*5;  % we want 5 modulations of the centre,so multiply by 5 to get outer mods 
   
   o=linspace(0, p*pi, resolution);
   outer=sin(o-pdata.piphase2); %work out outer with phase shift
   x=find(outer<=rlevel);
   outer(x)=rlevel;
   outer=outer-rlevel;
   outer=outer/max(outer);   
   outer=outer*strength;    % scales the outer strength
   
   i=linspace(0, 10*pi, resolution);  %2pi * 5 modulations
   inner=sin(i-pdata.piphase); %work out inner with phase shift
   x=find(inner<=rlevel);
   inner(x)=rlevel;
   inner=inner-rlevel;  %rectify so above 0
   inner=inner/max(inner);   %normalise to 1
   
   rlevel=0;
   interaction=inner-outer; 
   if max(interaction)>0; interaction= interaction / max(interaction); end%normalized to 1
   x=find(interaction<=rlevel2);
   interaction(x)=rlevel2;
   interaction=interaction-rlevel2;       %rectify so above 0
   if max(interaction)>0; interaction= interaction / max(interaction); end   %normalise to 1
   
   interaction=interaction*pscale;  %scale for the PSTH size
   inner=inner*pscale;
   
   pdata.interaction{a}=interaction';
   pdata.inner{a}=inner';
   
end


