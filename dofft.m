function dofft(data)

nyquist=max(size(data))/2

a=fft(data);

N=length(a);
a(1)=[];
power=abs(a(1:N/2)).^2;
freq=(1:N/2)/(N/2)*nyquist;
plot(freq,power)

