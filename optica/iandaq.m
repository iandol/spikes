function times=iandaq

duration = 4; % X second acquisition

%analog input
ai = analoginput('nidaq','Dev1');
set(ai,'InputType','Differential');
set(ai,'TriggerType','Immediate');
set(ai,'SampleRate',2000);
ActualRate = get(ai,'SampleRate');
set(ai,'SamplesPerTrigger',ActualRate*duration);
chans = addchannel(ai,0:1);

%digital output
dio = digitalio('nidaq','Dev1');
hwlines = addline(dio,0:7,'out');
dio.Line(1).LineName = 'TrigLine';

loopt=2010;
times=zeros(loopt,1);
i=1;

preview = duration*ActualRate/200;
figure;
subplot(221);
set(gcf,'doublebuffer','on');
P = plot(zeros(preview,2)); grid on
title('Preview Data');
xlabel('Samples');
ylabel('Signal Level (Volts)');
drawnow

try
	start(ai)
	while(i<loopt)
		tstamp=GetSecs;
		if getvalue(dio.Line(1))==0
			putvalue(dio.Line(1),1);
		else
			putvalue(dio.Line(1),0);
		end
		times(i)=GetSecs-tstamp;
		i=i+1;
		if ai.SamplesAcquired > preview && ai.samplesAcquired < duration*ActualRate
			data = peekdata(ai,preview);
			for j=1:length(P)
				set(P(j),'ydata',data(:,j)');
			end
			drawnow;
		end
 	end
	%stop(ai);
	%wait(ai,duration+1);
	data=getdata(ai);

	subplot(222);
	plot(data);
	times=times(11:2010);
	subplot(223);
	plot(times,'k.');
	subplot(224);
	histfit(times);
	title(num2str(mean(times)));

	delete(ai);
	clear ai;

	putvalue(dio,[0 0 0 0 0 0 0 0]);
	delete(dio);
	clear dio;
catch ME
	delete(ai);
	clear ai;

	putvalue(dio,[0 0 0 0 0 0 0 0]);
	delete(dio);
	clear dio;
	
	rethrow(ME);
end