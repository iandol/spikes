%modgam3.m; 28 MAY 01; 09 JUN 01
function [outt] = modgam3(mo,mr,ns);
% mo,mr are the modulated order and rate functions; assume 1KHz sampling rate
% length should be at least (ns/mean(mr))+20%.
dt = .001;	% bin time in seconds
sr2 = 1000;	% 1KHz sampling rate for modulations
M = zeros(1,ns);
T = 1/mean(mr);	%initial moment to select modulation values; based on mean interval
for j=1:ns   
   tt = cumsum(M);
   momrx = ceil(tt(j) + T)*sr2;
   moa(j) = mo(momrx);
   mra(j) = mr(momrx);
   M(j)= gamrnd(moa(j),1/(moa(j)*mra(j)));
end
outt = tt;
%
edges = [0:1:500]*dt;	% 1ms bins; change to [0:5:500] for 5ms bins
[N,bindx] = hist(M,edges);
figure;
subplot(2,2,1);
%bar(edges,N,'histc');
stairs(edges,N);
axis([-1*dt 200*dt 0 max(N)+5]);
cb = num2str(edges(2)-edges(1));
re = 1/mean(M);
cre = num2str(re);
title(['interval histogram; bin=',cb,'s; mean spk rate= ',cre])
xlabel('seconds');
ylabel('events per bin');
%
%figure(2)
subplot(4,2,2);
%dt2 = tt(end)/length(M);
dt2 = 1/mean(mra);
t2 = dt2:dt2:ns*dt2;
plot(t2,M);
axis([0 t2(end) 0 .35]);
%xlabel('seconds');
ylabel('interval length');
%
%figure(3)
subplot(4,2,4);
v=(M-mean(M)).^2;
plot(t2,v);
axis([0 t2(end) 0 1.1*max(v)]);
%xlabel('seconds');
ylabel('(int-mean(int))^2');
%
%figure(4)
subplot(2,2,3);
sl = (tt(end)-tt(1))/length(tt);
tta = 1:length(tt);
tta = sl*tta;
plot(t2,tt-tta);
axis([0 t2(end) 1.1*min(tt-tta) 1.1*max(tt-tta)]);
xlabel('seconds');
ylabel('spike time - uniform rate time');
%
tm = 1/sr2:1/sr2:tt(end);
subplot(4,2,6);
plot(tm,mo(1:length(tm)));
axis([0 t2(end) 0 15]);
%if max(mo)==min(mo)
%   axis([0 t2(end) 0.9*min(mo) 1.1*max(mo)]);
%else   
%   axis([0 t2(end) 1.1*min(mo) 1.1*max(mo)]);
%end
ylabel('order mod');
%
subplot(4,2,8);
plot(tm,mr(1:length(tm)));
axis([0 t2(end) 0 60]);
%if max(mr)==min(mr)
%   axis([0 t2(end) 0.9*min(mr) 1.1*max(mr)]);
%else   
%   axis([0 t2(end) 1.1*min(mr) 1.1*max(mr)]);
%end
xlabel('seconds');
ylabel('rate mod');%
%
