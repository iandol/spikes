function sd=burst(sd,silence_before_burst,first_isi,subsequent_isi,number_burst)

% Burst Counter
% =============
% Does a Sherman Style Burst Analysis, called from spikes
% creates a burst structure in the spikedata variable (made by lsd)
% which is identical tothe spike data, e.g. segmented into trials and
% modulations.
%
% Output is all of the spikes contained in the burst (mod), the
% tagged first spike of each burst (first) and a count of the number
% of spikes in each burst. The structure is contained in sd.btrial.
%
% sd=burst(sd,silence_before_burst,first_isi,subsequent_isi,number_burst)
%
% sd                   =  Spike Data structure created by lsd
% silence_before_burst =  required silence before a burst
% first_isi            =  maximum first isi in burst
% subsequent_isi       =  maximum subsequent isi to stay in burst
% number_burst         =  minimum number of spikes to consider a burst


for i=1:sd.numtrials
	
	b.burst = [];
	b.count = [];
	b.spike = {};
	d = [];
	n=0;
	maxn=n;
	
	x=sd.trial(i).modtimes(1);  % start from 0 (the first modtime)
	
	for a=1:sd.nummods;       % we add together all the spikes so we can also count bursts which sit at the modulation border
		x=[x ; sd.trial(i).mod{a}];
	end
	
	if length(x) < 3
		sd.btrial(i).mod = cell(1,sd.nummods);
		sd.btrial(i).first = cell(1,sd.nummods);
		sd.btrial(i).count = cell(1,sd.nummods);
	else
		x=[x ; 0 ; 0];            %load the mod to analyse, add mod start time at beginning and pad 0's at end to stop matrix index errors
		isi=diff(x);                             %workout the ISI's
		a=find(isi >= silence_before_burst);     %get those bigger than refractory period
		m=1;
		for k=1:length(a)                        %for each potential burst

			if isi(a(k)+1) <= first_isi && isi(a(k)+1) > 0   %look at the next spike, see if we have a burst!

				n=2;
				while isi(a(k)+n) < subsequent_isi && isi(a(k)+n) > 0
					n=n+1;
				end
				if n >= number_burst                     %see if we've reached minimum number of spikes
					b.count(m) = n;                       %add a counter to say how many spikes are inthe burst
					b.burst(m) = x(a(k)+1);               %add the spike time of the first spike of the burst
					b.spike{m} = x((a(k)+1):(a(k)+n));    %add the spike times of all spikes in burst
					m=m+1;
					maxn(m)=n;
				end

			end
		end

		if ~isempty(b.count) && max(maxn) >= number_burst              %Convert the Cell array into vector of all spikes from all bursts
			%d=zeros(length(b.spike),1);
			for a=1:length(b.spike);
				d=[d ; b.spike{a}];
			end 
			b.spike=d;
			if iscell(b.spike); b.spike=b.spike{1}; end
		end

		% we now need to put the spikes/bursts back into the modulation structure

		t=[sd.trial(i).modtimes ; sd.maxtime]; %the times within which to seperate the spikes

		if ~isempty(b.count)
			for a=1:sd.nummods

				bur=find(b.burst >= t(a) & b.burst < t(a+1));   % find the burst within this modulation
				spi=find(b.spike >= t(a) & b.spike < t(a+1));   % find the spikes within this modulation
				sd.btrial(i).mod{a}=b.spike(spi);
				sd.btrial(i).first{a}=b.burst(bur);
				sd.btrial(i).count{a}=b.count(bur);            %b.burst and b.count have the same structure

			end
		else
			sd.btrial(i).mod = cell(1,sd.nummods);
			sd.btrial(i).first = cell(1,sd.nummods);
			sd.btrial(i).count = cell(1,sd.nummods);
		end
	end
	
end