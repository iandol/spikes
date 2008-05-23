function [amp,ph,dc] = scaledFFT(y);
%[amp,ph,dc] = scaledFFT(y)
%
%Returns the amplitude, phase and dc of input signal y.
%amp and dc are scaled to return the actual
%values in the signal.  Phase is cosine phase.
%
%if y is a vector, scaledFFT returns the columnwise fft.
%7/25/00 gmb wrote it somewhere over Norway.
%turn y into a column vector if it's a row vector
  
if size(y,1) ==1
    y = y';
end
%number of frequency samples: number of time samples  / 2
nSamps = ceil(size(y,1)/2);
%take the Fourier Transform
ffty = fft(y);
%pull out the dc, with appropriate scaling
dc = ffty(1,:)/length(y);
%pull out the amplitude, with appropriate scaling
amp = 2*abs(ffty(2:nSamps,:))/length(y);
%pull out the phase
ph = angle(ffty(2:nSamps,:));