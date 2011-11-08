function [out,trials]=converttotime(in)
	global data
	in = (in/data.binwidth)*1000;
	if data.wrapped==1 %wrapped
		trials = data.raw{1}.numtrials*data.raw{1}.nummods;
		in=in/trials; %we have to get the values for an individual trial
	elseif data.wrapped==2
		trials = data.raw{1}.numtrials;
		in=in/trials;
	end
	out = in;
end