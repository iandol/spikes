function [out,trials]=converttotime(in,binwidth,trials,mods,wrapped)
	global data
	global sv
	if ~exist('mods','var') || isempty(mods)
		mods = data.raw{sv.yval,sv.xval,sv.zval}.nummods;
	end
	if ~exist('trials','var') || isempty(trials)
		trials = data.raw{sv.yval,sv.xval,sv.zval}.numtrials;
	end
	if ~exist('binwidth','var') || isempty(binwidth)
		binwidth = data.binwidth;
	end
	if ~exist('wrapped','var') || isempty(wrapped)
		wrapped = data.wrapped;
	end
	
	out = (in/binwidth)*1000;
	if wrapped==1 %wrapped
		trials = trials*mods;
		out=out/trials; %we have to get the values for an individual trial
	else
		out=out/trials;
	end
end