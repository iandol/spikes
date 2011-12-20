global data

maxtime=(max(data.time{1})+data.binwidth)/1000;
numtrials=data.numtrials;
nummods=data.nummods;
binwidth=data.binwidth;

if data.wrapped==1
   trialmod=numtrials*nummods;
else
   trialmod=numtrials;
end


for i=1:data.xrange
   [amp,freq,ph,dc]=fftplot2(data.psth{i},maxtime);
   fft0(i)=amp(1);
   a=find((freq-1).^2==min((freq-1).^2));
   fft1(i)=amp(a);
   a=find((freq-2).^2==min((freq-2).^2));
   fft2(i)=amp(a);
end


fft0=fft0/trialmod;
fft0=(fft0/binwidth)*1000;
fft1=fft1/trialmod;
fft1=(fft1/binwidth)*1000;
fft2=fft2/trialmod;
fft2=(fft2/binwidth)*1000;

fft0
fft1
fft2
figure
plot(data.xvalues,fft0,data.xvalues,fft1,data.xvalues,fft2)
legend('FFT0','FFT1','FFT2')
xlabel('X Variable')
ylabel('Firing Rate (Hz)')
