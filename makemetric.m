function out=makemetric(data,sv)
%
% makemetric takes Spikes data structures data and sv and makes a Metric space
% analysis structure. This pulls in variables selected in spikes 
% (subselections and whether First or Second variable is held)  so you can
% select them easily. It will also wrap or not the data depending on Spikes
% settings
%

if isempty(data.yvalues) || sv.xlock==0  %first variable selected
	useFirstVariable=true;
else
	useFirstVariable=false;
end

if useFirstVariable==true 
	out.M=int32(data.xrange);
else
	out.M=int32(data.yrange);
end
out.N=int32(1);
out.sites.label = {data.matrixtitle};
out.sites.recording_tag = {'episodic'};
out.sites.time_scale = 1;
out.sites.time_resolution = 0.0001;
out.sites.si_unit = 'none';
out.sites.si_prefix = 1;

if ~exist('mintrial','var')
	mintrial=1;
end
if ~exist('maxtrial','var')
	maxtrial=data.raw{1}.numtrials;
end
if ~exist('minmod','var')
	minmod=sv.StartMod;
end
if ~exist('maxmod','var') || sv.EndMod>data.raw{1}.nummods
	maxmod=data.raw{1}.nummods;
end
if ~exist('wrapped','var')
	wrapped=data.wrapped;
end

spiketimes=[];

if useFirstVariable==true
	m=zeros(data.xrange,1);
	for i=1:data.xrange
		m(i)=[data.raw{sv.yval,data.xindex(i),sv.zval}.numtrials];
	end
else
	m=zeros(data.yrange,1);
	for i=1:data.yrange
		m(i)=[data.raw{data.yindex(i),sv.xval,sv.zval}.numtrials];
	end
end
m=min(m); % we want to insure we have the same number of trials so set this to the smallest maxtrial found

if maxtrial>m
	maxtrial=m;
end
if mintrial>=maxtrial || mintrial < 1
	mintrial=mintrial-1;
end

for vari=1:out.M %for each x variable
	if useFirstVariable==true
		xdata=data.raw{sv.yval,data.xindex(vari),sv.zval};
		out.categories(vari,1).label={[data.xtitle ':' num2str(data.xvalues(vari))]};
	else
		xdata=data.raw{data.yindex(vari),sv.xval,sv.zval};
		out.categories(vari,1).label={[data.ytitle ':' num2str(data.yvalues(vari))]};
	end
	switch wrapped
	case 1
		out.categories(vari,1).P=int32((maxtrial-mintrial+1)*(maxmod-minmod+1));
		outtrial=1;
		for trial = mintrial:maxtrial % for each trial
			for k=minmod:maxmod
				s=xdata.trial(trial).mod{k}-xdata.trial(trial).modtimes(k);   %because it is wrapped
				spiketimes=unique(sort(s*0.0001))';
				out.categories(vari,1).trials(outtrial,1).Q=int32(length(spiketimes));
				out.categories(vari,1).trials(outtrial,1).list=spiketimes;
				out.categories(vari,1).trials(outtrial,1).start_time=0;
				out.categories(vari,1).trials(outtrial,1).end_time=data.modtime*0.0001;
				spiketimes=[];%reset the container
				outtrial=outtrial+1;
			end
		end		
	otherwise
		out.categories(vari,1).P=int32(maxtrial-mintrial+1);
		for trial = mintrial:maxtrial
			out.categories(vari,1).trials(trial,1).start_time=0;
			out.categories(vari,1).trials(trial,1).end_time=xdata.maxtime*0.0001;
			for k=minmod:maxmod
				s=xdata.trial(trial).mod{k};   %because it is not wrapped
				spiketimes=[spiketimes;s];
			end
			out.categories(vari,1).trials(trial,1).QQ=int32(length(spiketimes)); %confirm if any spikes were unique
			spiketimes=unique(sort(spiketimes*0.0001))';
			out.categories(vari,1).trials(trial,1).Q=int32(length(spiketimes));
			out.categories(vari,1).trials(trial,1).list=spiketimes;
			spiketimes=[];%reset the container	
		end
	end
end