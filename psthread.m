function psthread(action)

% PSTHRead() GUI PSTH plotting Program
%
%

global pdata;
global header;
global tmp;
global part;
global data sv;

%%%%%Check whether we are starting for the first time%%%
if nargin<1,
   action='Initialize';
end

%%%%%%%%%%%%%%See what MetAnal needs to do%%%%%%%%%%%%%
switch(action)
	
%%%%%%%%%%%%%%When run for the first time%%%%%%%%%%%%%%%%   
case 'Initialize'
   psthread_UI;
   header='';
   pdata=[];
   x=0;
   version='PSTH Phase Plotter V1.2b';
   set(gcf,'Name', version); %Sets Version data
   set(gcf,'DefaultLineLineWidth', 1.25);
   
case 'Load'
	pdata=[];
	set(gh('EditSelectBox'),'String','0'); 
	set(gh('EditPhaseBox'),'String','180');
	set(gh('EditPhaseBox2'),'String','180');
	set(gh('EditStrength'),'String','0.5');   
	set(gh('PHEditScale'),'String','0');
	set(gh('PHEditScale'),'Enable','on');
	set(gcbf, 'UserData', '');
	
	if sv.ylock==0
		for i=1:length(data.yvalueso)
			pdata.psth{i}(:,1)=1:length(data.psth{i,sv.xval,sv.zval});
			pdata.psth{i}(:,2)=data.time{i,sv.xval,sv.zval}/1000;
			pdata.psth{i}(:,3)=data.psth{i,sv.xval,sv.zval};
			pdata.max(i)=max(data.psth{i,sv.xval,sv.zval});
			pdata.psth{i}(:,4)=zeros(length(pdata.psth{i}),1);
			tp=sort(pdata.psth{i}(:,3));
			pdata.pscale(i)=mean(tp(end-2:end));
		end
		pdata.num=length(data.yvalueso);  %how many psths were loaded
		pdata.values=data.yvalueso;
		pdata.title=data.matrixtitle;
	elseif sv.ylock==1
		for i=1:length(data.xvalueso)
			pdata.psth{i}(:,1)=1:length(data.psth{sv.yval,i,sv.zval});
			pdata.psth{i}(:,2)=data.time{sv.yval,i,sv.zval}/1000;
			pdata.psth{i}(:,3)=data.psth{sv.yval,i,sv.zval};
			pdata.max(i)=max(pdata.psth{i}(:,3));
			pdata.psth{i}(:,4)=zeros(length(pdata.psth{i}),1);
			tp=sort(pdata.psth{i}(:,3));
			pdata.pscale(i)=mean(tp(end-2:end));
		end
		pdata.num=length(data.xvalueso);  %how many psths were loaded
		pdata.values=data.xvalueso;
		pdata.title=data.matrixtitle;
	end
   
   %------------set up the data structure----------

	pdata.numberOfModulations=data.raw{1}.nummods;
   pdata.inner=cell(size(pdata.psth));
   pdata.interaction=cell(size(pdata.psth));
   pdata.maxtime=max(pdata.psth{1}(:,2));
   pdata.piphase=0;
   pdata.piphase2=0;
   pdata.currentplot='psth';
	
	pdata.modtime=pdata.maxtime/pdata.numberOfModulations;
	idx=[];
	idx=find(pdata.psth{1}(:,2)<pdata.modtime, 1, 'last'); %find our first modulation time
	if isempty(idx);
		idx=25;
	end
	pdata.firstModIndex=idx;

   % -------- get scale to plot all psths-----------
   pdata.yscale=max(pdata.max);

   %-----------This scales the transient to the same as the peak and calculates mean peak
%    for i=1:pdata.num
% 		steps=(50/data.binwidth)+1; %limit to first 50ms
% 		pst=pdata.psth{i}(:,3);
% 		m1=max(pst(1:steps));
% 		m2=max(pst(steps+1:end));
% 		if m1>m2
% 			pst(1:steps)=pst(1:steps)*(m2/m1);
% 			pdata.psth{i}(:,3)=pst;
% 		end
% 		pst2=sort(pst);
% 		pdata.pscale(i)=mean(pst2(end-5:end));		
%    end 
   
   %-----------------Run the plotting and generate a global phase--------
   pdata.select=0;
   psthread('Phase');
   
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
   phase=str2num(get(gh('EditPhaseBox'),'String'));   
   phase2=str2num(get(gh('EditPhaseBox2'),'String'));   
   select=str2num(get(gh('EditSelectBox'),'String')); 
   pdata.scale=str2num(get(gh('PHEditScale'),'String'));
   if select==0;   %psths shown for all variables   
      if phase==0 && phase2==0
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
   cutoff=get(gh('EditRatio'),'String');   
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
   select=get(gh('EditSelectBox'),'String');
   select=str2num(select);
   choose=get(gh('MinimiseMenu'),'Value');
   
   if strcmp(pdata.currentplot,'fft');
      set(gh('RectifyBox'),'Value',1);
      set(gh('EditPhaseBox'),'String',pdata.optphase);
      set(gh('EditPhaseBox2'),'String',pdata.optphase);
      percent=pdata.optphase/360;
      pdata.piphase=(2*pi)*percent;
      pdata.pihase2=pdata.piphase;
      rec=-1:0.1:0.9;
      a=1;
      
      for i=-1:0.1:0.9       %rectification level
         set(gh('EditLevel'),'String',num2str(i));
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
      set(gh('EditLevel'),'String',pdata.bestfft);
      pdata.currentplot='fft';
      psthread('FFT');
      
   elseif select>0
      set(gh('RectifyBox'),'Value',1);
      
		a=1;
      for i=0:0.2:1.9       %rectification level
			rec(a)=i;
         set(gh('EditLevel'),'String',num2str(i));
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
      set(gh('EditLevel'),'String',pdata.bestpsth);
      pdata.currentplot='psth';
      psthread('Phase');
      
   else
      set(gh('EditSelectBox'),'String','0');   
      set(gh('RectifyBox'),'Value',1);
      %set(gh('EditLevel'),'String','-0.9');
      set(gh('EditPhaseBox'),'String','0');
      set(gh('EditPhaseBox2'),'String','0');
      pdata.inner=[];
      pdata.interaction=[];
		pdata.outer=[];
      pdata.phase=[];
      pdata.phase2=[];
      psthread('Phase'); 
      
		a=1;      
      for i=0:20:350    %phase 
         set(gh('EditPhaseBox'),'String',num2str(i));
			set(gh('EditPhaseBox2'),'String',num2str(i));
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
         a=a+1;
      end
      
      i=0:20:350;
      [g,indx]=max(pdata.phase); %find the closest fit
      x=i(indx);
      x=median(x);
      set(gh('EditPhaseBox'),'String',x);
      set(gh('EditPhaseBox2'),'String',x);
      pdata.currentplot='psth';
      psthread('Phase');
		
   end
   
%-----------------------choose a PSTH to plot------------------   
case 'Select'
   select=get(gh('EditSelectBox'),'String');
   select=str2num(select);
   pdata.select=select;
   if select==0
      set(gh('MinimiseMenu'),'Value',1);
      pdata.currentplot='psth';
      Plotpsth(pdata.yscale);
   else
      set(gh('MinimiseMenu'),'Value',2);
      pdata.currentplot='psth';
      Plotsingle(pdata.select);
   end
   
%-----------------------do a smart model fit-------------------   
   
case 'Simplex'
	if pdata.select==0
		errordlg('Sorry,you need to select a PSTH First')
		error;
	else	
		disp='iter';
		ls='off';
		options = optimset('Display',disp,'LargeScale',ls);
		
		y=pdata.psth{pdata.select}(:,3);
		
		rlevel=str2num(get(gh('EditLevel'),'String'));
		rlevel2=str2num(get(gh('EditLevel2'),'String'));
		strength=str2num(get(gh('EditStrength'),'String'));
		piphase=str2num(get(gh('EditPhaseBox'),'String'));
		piphase2=str2num(get(gh('EditPhaseBox2'),'String'));
		compat=get(gh('PHCompatMode'),'Value');
		
		if pdata.scale==0
			scale=pdata.pscale(pdata.select);
		else
			scale=pdata.scale;
		end
		
		p=[rlevel rlevel2 strength piphase piphase2 scale];
		lb=[0 0 0 0 0 round(scale/2)];
		ub=[2 2 1 359 359 round(scale*2)];
		
		cutfirstmod=get(gh('PHExcludeMod'),'Value');
		if cutfirstmod==1
			idx=pdata.firstModIndex;
		else
			idx=1;
		end
		
		[p]=fmincon(@dophase,p,[],[],[],[],lb,ub,[],options,y,pdata.values(pdata.select),pdata.numberOfModulations,compat,idx);
	
		set(gh('EditLevel'),'String',num2str(p(1),'%.2f'))
		set(gh('EditLevel2'),'String',num2str(p(2),'%.2f'))
		set(gh('EditStrength'),'String',num2str(p(3),'%.2f'))
		set(gh('EditPhaseBox'),'String',num2str(p(4),'%.1f'))
		set(gh('EditPhaseBox2'),'String',num2str(p(5),'%.1f'))
		set(gh('PHEditScale'),'String',num2str(0,'%.1f'));
		pdata.p=p;
		pdata.piphase=p(4);
		pdata.piphase2=p(5);
		pdata.optphase=rad2ang(p(4));
		pdata.optphase2=rad2ang(p(5));
		pdata.pscale(pdata.select)=p(6);
		pdata.scale=0;
		Plotsingle(pdata.select);
	end		
   
%-------------Do FFT analysis------------------------   
case 'FFT'
   select=get(gh('EditSelectBox'),'String');   
   select=str2num(select);
   if strcmp(pdata.currentplot,'fft')
      psthread('Phase')
   end
   if select==0
      msgbox('Please Select a Variable first...');
	else
		cutfirstmod=get(gh('PHExcludeMod'),'Value');
		if cutfirstmod==1
			idx=pdata.firstModIndex;
			pdata.currentplot='fft';
			fftplot(pdata.psth{select}(idx:end,3),pdata.interaction{select}(idx:end),(pdata.maxtime-pdata.modtime),1,16)
		else
			idx=1;
			fftplot(pdata.psth{select}(:,3),pdata.interaction{select},pdata.maxtime,1,16)
		end
      %fitphase(select,pdata.pscale(select),0);
      title(pdata.title)
   end      
   
case 'Exit'
   close(gcf)
   
end %end of main switch


%-------------------------------------------------------------------------

function Plotpsth(scale)

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
title(pdata.title,'FontSize',7);


%end of plotting function
%---------------------------------------------------------------------------

function Plotsingle(index)


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
idx=pdata.firstModIndex;
g=goodness(y,pdata.interaction{index});
g2=goodness(y(1:idx), pdata.interaction{index}(1:idx));
g3=goodness(y(idx+1:end), pdata.interaction{index}(idx+1:end));
g4=g2/g3*100;
t=['Explained Variance (exclude 1^{st} mod) = ' num2str(g3) '% ' ' (' num2str(g4) ' [' num2str(g2) '/' num2str(g3) '] % mod difference)'];
text(0.05,(pdata.yscale-(pdata.yscale/60)),t)
set(gca,'LineWidth', 2);
axis([0,xscale,0,pdata.yscale+1]);
legend('Data','Model','Inner','Outer');
ylabel('Spikes/Bin','FontSize', 9);
title(pdata.title,'FontSize',9);

if isfield(pdata,'p')
	clipboard('Copy',sprintf('%.5g\t',[pdata.p g3]));
end

% End of Single Plot Function
%-----------------------------------------------------------------------------

function fitphase(a,pscale,doplot)

global pdata;

rectify=get(gh('RectifyBox'),'Value');
rlevel=str2num(get(gh('EditLevel'),'String'));
rlevel2=str2num(get(gh('EditLevel2'),'String'));
strength=str2num(get(gh('EditStrength'),'String'));
piphase=str2num(get(gh('EditPhaseBox'),'String'));
piphase2=str2num(get(gh('EditPhaseBox2'),'String'));
pdata.scale=str2num(get(gh('PHEditScale'),'String'));
compat=get(gh('PHCompatMode'),'Value');

if pdata.scale==0
	scale=pdata.pscale(a);
else
	scale=pdata.scale;
end

if rectify==0
	rlevel=1;
	rlevel2=1;
end

freq=pdata.values(a);
x=pdata.psth{a}(:,2);
y=pdata.psth{a}(:,3);

[interaction,inner,outer]=sinmodel([rlevel,rlevel2,strength,piphase,piphase2,scale],y,freq,pdata.numberOfModulations,compat);
   
if doplot==1;
   
   hold on
   plot(x,interaction,'r-',x,inner,'g--',x,outer,'b--');
   xlabel(num2str(freq));
   hold off
   
else
   
   pdata.interaction{a}=interaction;
   pdata.inner{a}=inner;
	pdata.outer{a}=outer;
   
end

function out=dophase(p,y,frequency,nmods,compat,idx)
%gives us a sinmodel then least squares it...

yy=sinmodel(p,y,frequency,nmods,compat);

out=sum(sum((y(idx:end)-yy(idx:end)).^2));




