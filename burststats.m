function burststats(sdata)

% This function calculates basic burst statistics from raw spike trains
% the sdata is in a cell matrix of lsd files (basically data.raw from 
% the spikes program). Output is visual.

global data
global sv
global bstats

data.bstats = [];
bstats = [];

homedir = sv.historypath;

if sv.zlock == 1;
	z = sv.zval;
else 
	z = 1;
end

sdata = sdata(:,:,z);

bstats.raw=cell(size(sdata,1),size(sdata,2));
bstats.info=cell(size(sdata,1),size(sdata,2));

tic;
hwait=waitbar(0,'Calculating burst spikes...');
pos=get(hwait,'Position');
set(hwait,'Position',[0 0 pos(3) pos(4)]);

for i=1:size(sdata,1)*size(sdata,2)   %for each variable lsd file
   
   s=[];   
   x=sdata{i};
   s.name=x.name;
   
   for j=1:x.numtrials
      
      s(j).spike=0;    %add the trial start time
      s(j).burst=0;
      s(j).count=[];
      
      for k=1:x.nummods       %this breaks down the modulation structure
         s(j).spike=[s(j).spike;x.trial(j).mod{k}];
         s(j).burst=[s(j).burst;x.btrial(j).mod{k}];
         s(j).count=[s(j).count;x.btrial(j).count{k}'];
      end
      
      s(j).spike=[s(j).spike;x.maxtime]; %add the trial end time
      s(j).burst=[s(j).burst;x.maxtime];
               
   end
   
   bstats.raw{i}=s;
   
end

a=1:(size(sdata,1)*size(sdata,2));
y=reshape(a,size(sdata,1),size(sdata,2));
y=y'; %order it so we can load our data
scatterh=figure;
figpos(0,[800 800]);
bscatterh=figure;
figpos(0,[800 800]);
histh=figure;
figpos(0,[800 800]);
allbefore=[];
allafter=[];
ballbefore=[];
ballafter=[];
allburst=[];
allspike=[];
allcount=[];
allratio=[];
alltbefore=[];
alltafter=[];

ratio=zeros(size(sdata,1),size(sdata,2));
tratio=zeros(size(sdata,1),size(sdata,2));

waitbar(0.3,hwait,'Plotting Each Variable ISIs etc...');

for i=1:size(sdata,1)*size(sdata,2)   %for each spike train
   
   burstn=[];
   spiken=[];
   isibefore=[];
   isiafter=[];
   bisibefore=[]; %for bursts
   bisiafter=[];   %for bursts
   count=[];
   isi=[];
   
   for j=1:sdata{i}.numtrials
      
      burstn=[burstn;max(size(bstats.raw{i}(j).burst))-2];
      spiken=[spiken;max(size(bstats.raw{i}(j).spike))-2]; 
      isi=diff(bstats.raw{i}(j).spike);

      %Finds indexes of bursts in the vectors of spikes
      tmp1=bstats.raw{i}(j).spike;
      tmp2=bstats.raw{i}(j).burst;
      tmp3=find(ismember(tmp1,tmp2)==1);
      %Now uses them to find isi's for burst spikes
      if max(size(tmp3))>2 %if there are any real spikes
          burstindexes=tmp3(2:end-1); 
          bisibefore=[bisibefore;isi(burstindexes-1)];
          bisiafter=[bisiafter;isi(burstindexes)];
      end
      
     
      if isi >= x.maxtime-2 | isi > x.maxtime | (isi==x.maxtime-1 | isi==x.maxtime+1)
         isi=[];
      end
      
      if ~isempty(isi)
         isibefore=[isibefore;isi(1:end-1)]; 
         isiafter=[isiafter;isi(2:end)];
      end        
      count=[count;bstats.raw{i}(j).count];
      
   end

   bstats.info{i}.nspike=sum(spiken);
   bstats.info{i}.nburst=sum(burstn);
   bstats.info{i}.ntonic=bstats.info{i}.nspike-bstats.info{i}.nburst;
   if bstats.info{i}.nspike>1
      bstats.info{i}.ratio=bstats.info{i}.nburst / bstats.info{i}.nspike;
	  ratio(i) = bstats.info{i}.ratio;
	  bstats.info{i}.tratio=bstats.info{i}.ntonic / bstats.info{i}.nspike;
	  tratio(i) = bstats.info{i}.tratio;
   else
      bstats.info{i}.ratio = 0;
	  bstats.info{i}.tratio = 0;
	  ratio(i) = 0;
	  tratio(i) = 0;
   end   
   bstats.info{i}.isibefore=isibefore/10;   %convert into ms
   bstats.info{i}.isiafter=isiafter/10;
   bstats.info{i}.bisibefore=bisibefore/10;
   bstats.info{i}.bisiafter=bisiafter/10;
   bstats.info{i}.count=count;   
   
   
   
   %figure(histh);
   set(0,'CurrentFigure',histh);
   subplot(size(sdata,2),size(sdata,1),y(i));
   hist(bstats.info{i}.count,[2 3 4 5 6 7 8 9 10]);
   colormap([0 0 0]);
   title(bstats.raw{i}(1).name,'FontSize',5);
   set(gca,'FontSize',4);
   
   
   %figure(scatterh);
   set(0,'CurrentFigure',scatterh);
   subplot(size(sdata,2),size(sdata,1),y(i));
   isiplot(bstats.info{i}.isibefore,bstats.info{i}.isiafter,bstats.raw{i}(1).spike(end)/10,1);
   title(['Ratio = ' num2str(bstats.info{i}.ratio)],'FontSize',6);
   xlabel('');
   ylabel('');
   set(gca,'FontSize',3);
   
   
   %plot with bursts in red
   %figure(bscatterh);
   set(0,'CurrentFigure',bscatterh);
   subplot(size(sdata,2),size(sdata,1),y(i));
   isiplot(bstats.info{i}.isibefore,bstats.info{i}.isiafter,bstats.raw{i}(1).spike(end)/10,0, ...
           bstats.info{i}.bisibefore,bstats.info{i}.bisiafter);
   title(['Ratio = ' num2str(bstats.info{i}.ratio)],'FontSize',6);
   xlabel('');
   ylabel('');
   set(gca,'FontSize',3);

   ballbefore=[ballbefore;bstats.info{i}.bisibefore]; %burst isibefore
   ballafter=[ballafter;bstats.info{i}.bisiafter];    %burst isafter
   
   if length(bstats.info{i}.isibefore)>=3;
      allbefore=[allbefore;bstats.info{i}.isibefore(2:end-1)];
      allafter=[allafter;bstats.info{i}.isiafter(2:end-1)];
      alltbefore=[alltbefore;[bstats.info{i}.isibefore(1);bstats.info{i}.isibefore(end)]]; %NB corrected missing 't' here
      alltafter=[alltafter;[bstats.info{i}.isiafter(1);bstats.info{i}.isiafter(end)]];     % there was 'allafter'
   elseif length(bstats.info{i}.isibefore)>=2;                                            % where i *think* there should
      alltbefore=[alltbefore;[bstats.info{i}.isibefore(1);bstats.info{i}.isibefore(end)]]; % have been 'alltafter' 
      alltafter=[alltafter;[bstats.info{i}.isiafter(1);bstats.info{i}.isiafter(end)]];
   end
   allcount=[allcount;bstats.info{i}.count];
   allspike=[allspike;bstats.info{i}.nspike];
   allburst=[allburst;bstats.info{i}.nburst];
   allratio=[allratio;bstats.info{i}.ratio];
end

set(histh,'NumberTitle','off','Name','Histograms of Burst Size for Each Variable');
set(scatterh,'NumberTitle','off','Name','ISIPlots for Each Variable Position (Burst spikes in RED)');
set(bscatterh,'NumberTitle','off','Name','ISIPlots for each Variable (Showing start and end spikes)');

waitbar(0.7,hwait,'Summary Plots...');

if min(size(sdata))==1
   jointfig(histh,size(sdata,2),size(sdata,1));
   jointfig(scatterh,size(sdata,2),size(sdata,1));
end

bstats.ratio = ratio;
bstats.tratio = tratio;
bstats.allratio = allratio;
bstats.allspike = allspike;
bstats.allburst = allburst;
bstats.allcount = allcount;

allratio=mean(allratio);
allspike=sum(allspike);
allburst=sum(allburst);

figure;
figpos(0,[800 800]);
hist(allcount,[2 3 4 5 6 7 8 9 10]);
colormap([0 0 0]);
xlabel('Number of Spikes in Burst');
ylabel('Number of Bursts');
set(gcf,'NumberTitle','off','Name','Histogram of Burst Size for All Variables')

figure;
figpos(0,[800 800]);
isiplot(allbefore,allafter,x.maxtime/10,0);
hold on;
isisize=length(alltbefore);
odd=1:2:isisize-1;
even=2:2:isisize;
scatter(alltbefore(odd),alltafter(odd),15,[1 0 0],'filled');
scatter(alltbefore(even),alltafter(even),15,[0 0 .7],'filled');
set(gcf,'NumberTitle','off','Name','ISIPlot for all Spikes in all Variables (Showing start and end spikes)');
axis square;
allratio=allburst/allspike;
%t=['Ratio of Burst / Non-Burst Spikes = ' num2str(allratio) ' (' num2str(allburst) '/' num2str(allspike) ' spikes)','FontSize',13];
title(['Ratio of Burst / Non-Burst Spikes = ' num2str(allratio) ' (' num2str(allburst) '/' num2str(allspike) ' spikes)'],'FontSize',12.5);
hold off;

%plots a scatter for all variables with bursts in red
figure;
figpos(0,[800 800]);
size(alltbefore)
size(alltafter)
isiplot([allbefore;alltbefore],[allafter;alltafter],x.maxtime/10,0,ballbefore,ballafter);
set(gcf,'NumberTitle','off','Name','ISIPlot for all Spikes in all Variables (Burst spikes in RED)');
title(['Ratio of Burst / Non-Burst Spikes = ' num2str(allratio) ' (' num2str(allburst) '/' num2str(allspike) ' spikes)'],'FontSize',12.5);
hold off;
axis square;

xx=linspace(min(data.xvalues),max(data.xvalues),(length(data.xvalues)*5));
yy=linspace(min(data.yvalues),max(data.yvalues),(length(data.yvalues)*5));
[xx,yy]=meshgrid(xx,yy);
[xo,yo]=meshgrid(data.xvalues,data.yvalues);

if data.numvars==1
	figure;
	figpos(0,[800 800]);
	plot(data.xvalues,bstats.ratio,'ko-')
	ylabel('Ratio of Burst:All Spikes')
	xlabel(data.xtitle')
	title(['Ratio Plot for:' data.matrixtitle])
else
	figure
	figpos(0,[800 800]);
	dd=interp2(xo,yo,bstats.ratio,xx,yy,'linear');
	pcolor(xx, yy,dd);
	shading interp
	colormap(hot)
	caxis([0 1])
	xlabel(data.xtitle);
	ylabel(data.ytitle);
	title(['Ratio Plot for:' data.matrixtitle])
	set(gca,'Tag','');
	colorbar
	set(gcf,'NumberTitle','off','Name','Ratio Plot for All Variables');
	
	figure
	figpos(0,[800 800]);
	dd=interp2(xo,yo,bstats.ratio,xx,yy,'linear');
	dd2=interp2(xo,yo,bstats.tratio,xx,yy,'linear');
	pcolor(xx, yy, dd - dd2);
	shading interp
	cm = rbmap;
	colormap(cm)
	caxis([-1 1])
	xlabel(data.xtitle);
	ylabel(data.ytitle);
	title(['Burst - Tonic Ratio Plot for:' data.matrixtitle])
	set(gca,'Tag','');
	colorbar
	set(gcf,'NumberTitle','off','Name','Burst - Tonic Ratio Plot for All Variables');
	
	figure
	figpos(0,[800 800]);
	bt = bstats.ratio ./ max(bstats.ratio(:));
	tt = bstats.tratio ./ max(bstats.tratio(:));
	dd=interp2(xo,yo,bt,xx,yy,'linear');
	dd2=interp2(xo,yo,tt,xx,yy,'linear');
	pcolor(xx, yy, dd - dd2);
	shading interp
	cm = rbmap;
	colormap(cm)
	caxis([-1 1])
	xlabel(data.xtitle);
	ylabel(data.ytitle);
	title(['Burst - Tonic Ratio Plot for:' data.matrixtitle])
	set(gca,'Tag','');
	colorbar
	set(gcf,'NumberTitle','off','Name','Burst - Tonic Difference Plot for All Variables');
	
end

waitbar(0.9,hwait,'Saving...');

save([homedir 'isibefore.txt'], 'allbefore', '-ascii');
save([homedir 'isiafter.txt'], 'allafter', '-ascii');
x=alltbefore(odd);
save([homedir 'isistart1.txt'], 'x', '-ascii');
x=alltafter(odd);
save([homedir 'isistart2.txt'], 'x', '-ascii');
x=alltbefore(even);
save([homedir 'isiend1.txt'], 'x', '-ascii');
x=alltafter(even);
save([homedir 'isiend2.txt'],  'x', '-ascii');
data.ratioall=bstats.ratio;
save([homedir 'ratioall.txt'], 'ratio', '-ascii');
data.bstats = bstats;

close(hwait)

fprintf('\n===>Finished in %.4g seconds\n',toc);





















         


