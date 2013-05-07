function [out,trials]=converttotime(in,binwidth,trials,mods,wrapped)
	global data
	if ~exist('mods','var') || isempty(mods)
		mods = data.nummods;
	end
	if ~exist('trials','var') || isempty(trials)
		trials = data.numtrials;
	end
	if ~exist('binwidth','var') || isempty(binwidth)
		binwidth = data.binwidth;
	end
	if ~exist('wrapped','var') || isempty(wrapped)
		wrapped = data.wrapped;
	end
	
	in = (in/binwidth)*1000;
	if wrapped==1 %wrapped
		trials = trials*mods;
		in=in/trials; %we have to get the values for an individual trial
	else
		in=in/trials;
	end
	out = in;
end