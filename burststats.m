function burststats(sdata);

% This function calculates basic burst statistics from raw spike trains
% the sdata is in a cell matrix of lsd files (basically data.raw from 
% the spikes program). Output is visual.

global data
global sv

homedir = sv.historypath;

stats.raw=cell(size(sdata,1),size(sdata,2));
stats.info=cell(size(sdata,1),size(sdata,2));

tic;
fprintf('==============PLEASE WAIT!!!===============');

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
   
   stats.raw{i}=s;
   
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
      
      burstn=[burstn;max(size(stats.raw{i}(j).burst))-2];
      spiken=[spiken;max(size(stats.raw{i}(j).spike))-2]; 
      isi=diff(stats.raw{i}(j).spike);

      %Finds indexes of bursts in the vectors of spikes
      tmp1=stats.raw{i}(j).spike;
      tmp2=stats.raw{i}(j).burst;
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
      count=[count;stats.raw{i}(j).count];
      
   end

   stats.info{i}.nspike=sum(spiken);
   stats.info{i}.nburst=sum(burstn);
   if stats.info{i}.nspike>1
      stats.info{i}.ratio=stats.info{i}.nburst/ stats.info{i}.nspike;
   else
      stats.info{i}.ratio=0;
   end   
   stats.info{i}.isibefore=isibefore/10;   %convert into ms
   stats.info{i}.isiafter=isiafter/10;
   stats.info{i}.bisibefore=bisibefore/10;
   stats.info{i}.bisiafter=bisiafter/10;
   stats.info{i}.count=count;   
   
   %figure(histh);
   set(0,'CurrentFigure',histh);
   subplot(size(sdata,2),size(sdata,1),y(i));
   hist(stats.info{i}.count,[2 3 4 5 6 7 8 9 10]);
   colormap([0 0 0]);
   title(stats.raw{i}(1).name,'FontSize',5);
   set(gca,'FontSize',4);
   set(gcf,'NumberTitle','off','Name','Histograms of Burst Size for Each Variable');
   
   %figure(scatterh);
   set(0,'CurrentFigure',scatterh);
   subplot(size(sdata,2),size(sdata,1),y(i));
   isiplot(stats.info{i}.isibefore,stats.info{i}.isiafter,stats.raw{i}(1).spike(end)/10,1);
   title(['Ratio = ' num2str(stats.info{i}.ratio)],'FontSize',6);
   xlabel('');
   ylabel('');
   set(gca,'FontSize',3);
   set(gcf,'NumberTitle','off','Name','ISIPlots for Each Variable Position');
   
   %plot with bursts in red
   %figure(bscatterh);
   set(0,'CurrentFigure',bscatterh);
   subplot(size(sdata,2),size(sdata,1),y(i));
   isiplot(stats.info{i}.isibefore,stats.info{i}.isiafter,stats.raw{i}(1).spike(end)/10,0, ...
           stats.info{i}.bisibefore,stats.info{i}.bisiafter);
   title(['Ratio = ' num2str(stats.info{i}.ratio)],'FontSize',6);
   xlabel('');
   ylabel('');
   set(gca,'FontSize',3);
   set(gcf,'NumberTitle','off','Name','ISIPlots for each Variable (Burst spikes in RED)');
   
   ballbefore=[ballbefore;stats.info{i}.bisibefore]; %burst isibefore
   ballafter=[ballafter;stats.info{i}.bisiafter];    %burst isafter
   
   if length(stats.info{i}.isibefore)>=3;
      allbefore=[allbefore;stats.info{i}.isibefore(2:end-1)];
      allafter=[allafter;stats.info{i}.isiafter(2:end-1)];
      alltbefore=[alltbefore;[stats.info{i}.isibefore(1);stats.info{i}.isibefore(end)]]; %NB corrected missing 't' here
      alltafter=[alltafter;[stats.info{i}.isiafter(1);stats.info{i}.isiafter(end)]];     % there was 'allafter'
   elseif length(stats.info{i}.isibefore)>=2;                                            % where i *think* there should
      alltbefore=[alltbefore;[stats.info{i}.isibefore(1);stats.info{i}.isibefore(end)]]; % have been 'alltafter' 
      alltafter=[alltafter;[stats.info{i}.isiafter(1);stats.info{i}.isiafter(end)]];
   end
   allcount=[allcount;stats.info{i}.count];
   allspike=[allspike;stats.info{i}.nspike];
   allburst=[allburst;stats.info{i}.nburst];
   allratio=[allratio;stats.info{i}.ratio];
end

if min(size(sdata))==1
   jointfig(histh,size(sdata,2),size(sdata,1));
   jointfig(scatterh,size(sdata,2),size(sdata,1));
end

allratio=mean(allratio);
allspike=sum(allspike);
allburst=sum(allburst)
size(ballbefore)
figure;
hist(allcount,[2 3 4 5 6 7 8 9 10]);
colormap([0 0 0]);
xlabel('Number of Spikes in Burst');
ylabel('Number of Bursts');
set(gcf,'NumberTitle','off','Name','Histogram of Burst Size for All Variables')

figure;
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
size(alltbefore)
size(alltafter)
isiplot([allbefore;alltbefore],[allafter;alltafter],x.maxtime/10,0,ballbefore,ballafter);
set(gcf,'NumberTitle','off','Name','ISIPlot for all Spikes in all Variables (Burst spikes in RED)');
title(['Ratio of Burst / Non-Burst Spikes = ' num2str(allratio) ' (' num2str(allburst) '/' num2str(allspike) ' spikes)'],'FontSize',12.5);
hold off;
axis square;

save([homedir 'isibefore.txt'], allbefore, '-ascii');
save([homedir 'isiafter.txt'], allafter, '-ascii');
x=alltbefore(odd);
save([homedir 'isistart1.txt'], x, '-ascii');
x=alltafter(odd);
save([homedir 'isistart2.txt'], x, '-ascii');
x=alltbefore(even);
save([homedir 'isiend1.txt'], x, '-ascii');
x=alltafter(even);
save([homedir 'isiend1.txt'],  x, '-ascii');

ratio=zeros(size(sdata,1),size(sdata,2));
for i=1:size(sdata,1)*size(sdata,2);
     ratio(i)=stats.info{i}.ratio;   
end

figure
if data.numvars==1
	plot(data.xvalues,ratio,'ko-')
	ylabel('Ratio of Burst:All Spikes')
	xlabel(data.xtitle')
	title(['Ratio Plot for:' data.matrixtitle])
else
	pcolor(data.xvalues,data.yvalues,ratio);
	shading interp
	colormap(hot)
	caxis([0 1])
	xlabel(data.xtitle);
	ylabel(data.ytitle);
	title(['Ratio Plot for:' data.matrixtitle])
	set(gca,'Tag','');
	colorbar
end
set(gcf,'NumberTitle','off','Name','Ratio Plot for All Variables');

fprintf('===>Finished in %.4g seconds',toc);


ratio;
data.ratioall=ratio;
save([homedir 'ratioall.txt'], ratio, '-ascii');


















         


