function varargout=fftplot(data,model,maxtime,doplot,hlimit)

% Function fftplot(data,model,time,doplot,hlimit) takes data and computes power spectrum
%
% data = the time signal (PSTH) for analysis
% model = model time signal (PSTH) or at leave 0 if you want to ignore it
% time = the maximum time of the data
% doplot = if you want to see a plot: 1 == yes
% hlimit = the maximum harmonics you want to see, inf to see all

if max(model)>0
   normalise=1;
else
   normalise=0;
end

if size(data,1) ==1
    data = data';
end
nSteps=length(data);
ffty=fft(data);
ffty = ffty(1:ceil(nSteps/2));
ffty = 2*ffty/nSteps; %now the amplitudes are correct.
power = abs(ffty);
power(1) = power(1)/2;
freq=(0:length(ffty)-1)/maxtime;

if normalise==1
    power=power/max(power);    %normalise response
end

if doplot==1
   plot(freq,power,'k');
   xlabel('Fourier Harmonics (Hz)');
   ylabel('Normalised FFT Power');
   axis([0 hlimit -Inf Inf]);
end

if max(model)>0   
   if size(model,1) ==1
      model = model';
   end
   
   nSteps=length(model);
   ffty=fft(model);
   ffty = ffty(1:ceil(nSteps/2));
   ffty = 2*ffty/nSteps; %now the amplitudes are correct.
   powerm = abs(ffty);
   powerm(1) = powerm(1)/2;
   freqm=(0:length(ffty)-1)/maxtime;   
   
   if normalise==1
      powerm=powerm/max(powerm);    %normalise response
   end
   
   g=goodness(power,powerm);
   
   if doplot==1
      hold on
      plot(freqm,powerm,'r:');
      hold off
      legend('Data','Model');      
      t=['Explained Variance = ' num2str(g) '%'];
      text(7,0.8,t)
		clipboard('Copy',sprintf('%.5g',g));
   end
   
end

if exist('g','var')
   varargout{1}=g;
end


% --------   Check other harmonics   ---------
%if quadruple>triple
%   triple=quadruple;
%end

%if triple>double
%   double=triple;
%end

%double=double+triple+quadruple;

% --------   Work out Ratio    ----------
%if single>double    
%   ratio=(double/single)/2
%   if single <5000
%      msgbox('Warning: Low Power, maybe not enough spikes','Caution','help')
%   end 
%elseif single<double
%   ratio=1-((single/double)/2)
%   if double <5000
%      msgbox('Warning: Low Power, maybe not enough spikes','Caution','help')
%   end 
%elseif single==double
%   ratio=0.5;
%end

%tit=strcat('Ratio:     ', num2str(ratio));
%text(2,single,num2str(single));
%text(4,double,num2str(double));
%title(tit);
 



