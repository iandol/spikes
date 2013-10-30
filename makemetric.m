function out=makemetric(data,sv,mintrial,maxtrial)
%
% makemetric takes Spikes data structures data and sv and makes a Metric space
% analysis structure. This pulls in variables selected in spikes 
% (subselections and whether First or Second variable is held)  so you can
% select them easily. It will also wrap or not the data depending on Spikes
% settings
isOpro = false;
timeModifier = 1e-4; %vs traditionally used 0.1ms timebase
%check if were getting an opro structure or a spikes one. If it is opro we
%are going to be loading the reparsed structure (i.e. figure vs ground with variables collated into two groups)
%which means that we have to create a pseudo data structure
if isfield(data, 'cell1raws') && ~isfield(data,'zipload')
	isOpro = true;
	o = data;
	sv.StartMod = 1;
	sv.EndMod = 1;
	sv.xval = 1;
	sv.yval = 1;
	sv.zval = 1;
	
	data = o.cell1;
	data2 = o.cell2;
	data.numvars = 1;
	data.xrange = 2;
	data.xvalues = [1 2];
	data.xindex = [1 2];
	data.xvalueso = data.xvalues;
	data.xtitle = 'oproReparse';
	data.yrange = 1;
	data.yindex=1;
	data.raw{2} = data2.raw{1};
	data.rawspikes{2} = data2.rawspikes{1};
	data.names{2} = data2.names{1};
end

if data.numvars<2 || isempty(data.yvalues) || sv.xlock==0  %first variable selected
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
out.sites.recording_tag = {'episodic'}; %Can be either continuous or episodic
out.sites.time_scale = 1; %The scale factor required to convert the time mesurements in seconds
out.sites.time_resolution = timeModifier; %The temporal resolution of the recording (prior to scaling by time_scale)
out.sites.si_unit = 'none'; %The pluralized international system of units (SI) base or derived unit of the sampled data
out.sites.si_prefix = 1; %The international system of units (SI) prefix (a power of ten)

if ~exist('mintrial','var')
	mintrial=1;
end
if ~exist('maxtrial','var') || maxtrial == Inf
	maxtrial=data.numtrials;
end
if maxtrial < 0
	maxtrial=data.numtrials-maxtrial;
end
if maxtrial == mintrial
	maxtrial=data.numtrials;
end
if ~exist('minmod','var')
	minmod=sv.StartMod;
end
if ~exist('maxmod','var') || sv.EndMod>data.nummods
	maxmod=data.nummods;
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
minm=min(m); % we want to insure we have the same number of trials so set this to the smallest maxtrial found

for vari=1:out.M %for each x variable
	if isOpro
		maxtrial = m(vari);
	else
		if maxtrial>minm
			maxtrial=minm;
		end
	end
	if mintrial>=maxtrial || mintrial < 1
		mintrial=mintrial-1;
	end
	if useFirstVariable==true
		xdata=data.raw{sv.yval,data.xindex(vari),sv.zval};
		if data.numvars == 0
			out.categories(vari,1).label={[data.meta.protocol]};
		else
			out.categories(vari,1).label={[data.xtitle ':' num2str(data.xvalues(vari))]};
		end
	else
		xdata=data.raw{data.yindex(vari),sv.xval,sv.zval};
		if data.numvars == 0
			out.categories(vari,1).label={[data.meta.protocol]};
		else
			out.categories(vari,1).label={[data.ytitle ':' num2str(data.yvalues(vari))]};
		end
	end
	switch wrapped
	case 1
		out.categories(vari,1).P=int32((maxtrial-mintrial+1)*(maxmod-minmod+1));
		outtrial=1;
		for trial = mintrial:maxtrial % for each trial
			for k=minmod:maxmod
				s=xdata.trial(trial).mod{k}-xdata.trial(trial).modtimes(k);   %because it is wrapped
				spiketimes=unique(sort(s*timeModifier))';
				out.categories(vari,1).trials(outtrial,1).Q=int32(length(spiketimes));
				out.categories(vari,1).trials(outtrial,1).list=spiketimes;
				out.categories(vari,1).trials(outtrial,1).start_time=0;
				out.categories(vari,1).trials(outtrial,1).end_time=data.modtime*timeModifier;
				spiketimes=[];%reset the container
				outtrial=outtrial+1;
			end
		end		
	otherwise
		out.categories(vari,1).P=int32(maxtrial-mintrial+1);
		for trial = mintrial:maxtrial
			out.categories(vari,1).trials(trial,1).start_time=0;
			out.categories(vari,1).trials(trial,1).end_time=xdata.maxtime*timeModifier;
			for k=minmod:maxmod
				s=xdata.trial(trial).mod{k};   %because it is not wrapped
				spiketimes=[spiketimes;s];
			end
			out.categories(vari,1).trials(trial,1).QQ=int32(length(spiketimes)); %confirm if any spikes were unique
			spiketimes=unique(sort(spiketimes*timeModifier))';
			out.categories(vari,1).trials(trial,1).Q=int32(length(spiketimes));
			out.categories(vari,1).trials(trial,1).list=spiketimes;
			spiketimes=[];%reset the container	
		end
	end
end