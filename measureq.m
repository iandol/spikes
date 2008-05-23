function [mint,maxt]=measureq(time,psth,binwidth,psth2)

% This helper function is called via Spikes to get a time window
% for further analysis, this one is simpler than measure.

h=figure;
t=0;

set(gcf,'Name','Please Select the Area of PSTH for Analysis:','NumberTitle','off')

if nargin==3
   bar(time,psth,1,'k');
elseif size(psth,1)<size(psth,2)
   time=time';
   psth=psth';
   psth2=psth2';
   p(:,1)=psth;
   p(:,2)=psth2;
   bar(time,p,1);
   legend('Control RF','Drug RF');
else
   p(:,1)=psth;
   p(:,2)=psth2;
   bar(time,p,1);
   legend('Control RF','Drug RF');
end
   
set(gca,'FontSize',9);
axis tight;
xlabel('Time (ms)');
ylabel('Total Count in Spikes/Bin');
[x,y]=ginput(2);

if x(1)<=0; x(1)=0.0001; end
if x(2)>max(time);x(2)=max(time)+0.0001;end

mint=time(ceil(x(1)/binwidth));
maxt=time(ceil(x(2)/binwidth));

pause(0.2);
close(h);
