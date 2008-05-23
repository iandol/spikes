function [amp,freq,ph,dc] = FFTPlot2(y,maxtime);
%[amp,freq,ph,dc] = FFTPlot2(y,maxtime)
%
%Returns the amplitude, phase and dc of input signal y.
  
if size(y,1) ==1
    y = y';
end

%nyquist=(length(y)/2)/maxtime;
nSteps=length(y);

%Do the FFT

ffty=fft(y);

%Note, since ffty is complex, it has twice as many degrees of freedom
%(values) as the signal, s.  So there must be redundant information
%
%The second half of the FFT is redundant. It's just a mirror-reverse copy,
%with each entry the complex conjugate of the original.  So we can cut it out:

ffty = ffty(1:ceil(nSteps/2));

%Wait. the original amplitudes are different than the ones in the graph.
%That's because the returned values in the fft are different by a scale
%factor 1/(2*nSteps).  So to get the original amplitudes back, we must
%divide the fft by this factor.  The reasons why are known to hard core 
%engineers.

ffty = 2*ffty/nSteps; %now the amplitudes are correct.
amp = abs(ffty);
ph = angle(ffty);

%note that the signals are one-off on the x-axis. This is because the
%first frequency is not 1-cycle, but 0-cycles, DC, or mean value.
%It's also off by a different scale factor - it needs to be divided by
%two.  Again, don't ask why.

amp(1) = amp(1)/2;

dc=amp(1); %d.c. is the 0 harmonic

%freq=(0:length(ffty)-1)/length(ffty)*nyquist; %work out the frequency of each point.
freq=(0:length(ffty)-1)/maxtime;


