classdef fanoPlotter < handle
	%FANOPLOT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		times
		data
		fanoParams
		plotFanoParams
		select = 1
		result
		maxTime
		shiftTime = 25
		boxWidth = 50
		alignTime = 100
		bins
		spikeData
	end
	
	methods
		function obj = fanoPlotter(args)
			
		end
		
		function convertSpikesFormat(obj)
			obj.fanoParams.alignTime = obj.alignTime;
			obj.fanoParams.boxWidth = obj.boxWidth;
			obj.plotFanoParams.plotRawF = 1;
			obj.maxTime = ceil(obj.data.modtime/10);
			obj.times = 0:obj.shiftTime:obj.maxTime;
			obj.times = obj.times(3:end-1);
			in = obj.data.raw{obj.select};
			a = 1;
			for i = 1:in.numtrials
				for j = 1:in.nummods
					spikes = in.trial(i).mod{j} / 10;
					obj.bins(a,:) = hist(spikes, obj.maxTime);
					a=a+1;
				end
			end
			obj.bins = logical(obj.bins);
			obj.spikeData.spikes = obj.bins;
		end
		
		function compute(obj)
			obj.result = VarVsMean(obj.spikeData, obj.times, obj.fanoParams);
		end
		
		function plot(obj)
			plotFano(obj.result,obj.plotFanoParams);
		end
	end
	
end

