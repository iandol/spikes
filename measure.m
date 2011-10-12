function [mint,maxt] = measure(data,x,y,z,psthtype)

% This helper function is called via Spikes to get a time window
% for further analysis

if exist('x','var')
	xhold=x;
else
	xhold=1;
end
if exist('y','var')
	yhold=y;
else
	yhold=1;
end
if exist('z','var')
	zhold=z;
else
	zhold=1;
end
if ~exist('psthtype','var')
	psthtype = 1;
end

h=figure;
t=0;

time=data.time{yhold,xhold,zhold};
psth=data.psth{yhold,xhold,zhold};
bpsth=data.bpsth{yhold,xhold,zhold};
tpsth = psth - bpsth;

set(gcf,'Name','Please Select the Area of PSTH for Analysis:','NumberTitle','off')

colormap([0 0 0;1 0 0]);
if psthtype == 1
	bar(time,psth,1,'k');
	hold on
	bar(time,bpsth,1,'r');
	hold off
	t = 'ALL: ';
elseif psthtype == 2 %burst
	bar(time,bpsth,1,'r');
	t = 'BURST: ';
elseif psthtype == 3 %tonic
	bar(time,tpsth,1,'b');
	t = 'TONIC: ';
end

switch data.numvars
	case 3
		t=[t data.runname ': ' data.xtitle '=' num2str(data.xvalues(xhold)) ' | ' data.ytitle '='  num2str(data.yvalues(yhold)) ' | ' data.ztitle '='  num2str(data.zvalues(zhold))];
	case 2
		t=[t data.runname ': ' data.xtitle '=' num2str(data.xvalues(xhold)) ' | ' data.ytitle '='  num2str(data.yvalues(yhold))];
	case 1
		t=[t data.runname '='  data.xtitle '=' num2str(data.xvalues(xhold))];
	otherwise
		t='There are no independent variables';
end
title(t);
set(gca,'FontSize',9);
axis tight;
xlabel('Time (ms)');
ylabel(['Spikes / Bin ' ' (' num2str(data.binwidth) 'ms Binwidth)']);
[x,y]=ginput(2);

if x(1)<=0; x(1)=0.0001; end
if x(2)>max(time);x(2)=max(time)+0.0001;end

mint=time(ceil(x(1)/data.binwidth));
maxt=time(ceil(x(2)/data.binwidth));

pause(0.1);
close(h);
