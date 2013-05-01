function [out,trials]=converttotime(in)
	global data
	in = (in/data.binwidth)*1000;
	if data.wrapped==1 %wrapped
		trials = data.numtrials*data.nummods;
		in=in/trials; %we have to get the values for an individual trial
	else
		trials = data.numtrials;
		in=in/trials;
	end
	out = in;
end