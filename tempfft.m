dos('"C:\Program Files\Frogbit\frogbitrun.exe" "C:\Program Files\Frogbit\psthstrip.FB"');
cd('c:\');   
[header,x]=hdload('frogtemp2');  % Loads file   
fft0=[];
fft1=[];
fft2=[];

%--This loop extracts the psth's for each independant variable---
numbins=size(unique(x(:,1)),1);
a=1;

for i=1:numbins:size(x,1)      
   pdata.psth{a}=x(i:(i+numbins-1),:);
   a=a+1;      
end

%------------set up the data structure----------
pdata.num=a-1;  %how many psths were loaded
pdata.title=header;
pdata.binwidth=(pdata.psth{1}(2,2)-pdata.psth{1}(1,2))*1000; %get the binwidth in milliseconds
pdata.maxtime=max(pdata.psth{1}(:,2))+(pdata.binwidth/1000);  %work out the maximum time
pdata.numbins=max(pdata.psth{1}(:,1));
pdata.numtrials=5;
pdata.nummods=5;

trialmod=pdata.numtrials*pdata.nummods;

for i=1:pdata.num
   [amp,freq,ph,dc]=fftplot2(pdata.psth{i}(:,3),pdata.maxtime);
   fft0(i)=amp(1);
   a=find(freq==1);
   fft1(i)=amp(a);
   a=find(freq==2);
   fft2(i)=amp(a);
end

fft0=fft0/trialmod;
fft0=(fft0/pdata.binwidth)*1000;
fft1=fft1/trialmod;
fft1=(fft1/pdata.binwidth)*1000;
fft2=fft2/trialmod;
fft2=(fft2/pdata.binwidth)*1000;

fft0
fft1
fft2
figure
plot(1:pdata.num,fft0,1:pdata.num,fft1,1:pdata.num,fft2)
legend('FFT0','FFT1','FFT2')
xlabel('X Variable')
ylabel('Firing Rate (Hz)')
