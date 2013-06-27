function [mint,maxt]=measureq(time,psth,binwidth,psth2,name)

% This helper function is called via Spikes to get a time window
% for further analysis, this one is simpler than measure.

if ~exist('name','var')
	name='Please Select the Area of PSTH for Analysis:';
end

hf=figure;
figpos(1,[1200 1200]);
t=0;

set(gcf,'Name',name,'NumberTitle','off');

if nargin==3
   h = bar(time,psth,1,'k');
elseif size(psth,1)<size(psth,2)
   time=time';
   psth=psth';
   psth2=psth2';
   p(:,1)=psth;
   p(:,2)=psth2;
   h = bar(time,p,1.2);
   legend('Control RF','Drug RF');
else
   p(:,1)=psth;
   p(:,2)=psth2;
   h = bar(time,p,1.2);
   legend('Control RF','Drug RF');
end

if length(h) > 1
	set(h(1),'FaceColor',[0 0 0],'EdgeColor',[0 0 0])
	set(h(2),'FaceColor',[1 0 0],'EdgeColor',[1 0 0])
end
   
title(name)
axis tight;
xlabel('Time (ms)');
ylabel('Total Count in Spikes/Bin');
[x,y]=ginput(2);

if x(1)<=0; x(1)=0.0001; end
if x(2)>max(time);x(2)=max(time)+0.0001;end

mint=time(ceil(x(1)/binwidth));
maxt=time(ceil(x(2)/binwidth));

pause(0.1);
close(hf);