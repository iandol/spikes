classdef fanoPlotter < handle
	%FANOPLOT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		times
		data
		sv
		fanoParams
		plotFanoParams
		select = 1
		result
		maxTime
		shiftTime = 25
		boxWidth = 50
		alignTime = 0
		matchReps = 0
		plotRawF = 1
		lengthOfTimeCal = 100
		bins
		spikeData
	end
	
	methods
		function obj = fanoPlotter(args)
			
		end
		
		function convertSpikesFormat(obj,data,sv)
			obj.data = data;
			obj.sv = sv;
			obj.maxTime = ceil(obj.data.modtime/10);
			obj.times = 0:obj.shiftTime:obj.maxTime;
			obj.times = obj.times(2:end-1);
			for loop = 1:obj.data.xrange
				obj.bins = [];
				in = obj.data.raw{obj.sv.yval,loop,obj.sv.zval};
				a = 1;
				for i = 1:in.numtrials
					for j = 1:in.nummods
						spikes = in.trial(i).mod{j} / 10;
						obj.bins(a,:) = hist(spikes, obj.maxTime);
						a=a+1;
					end
				end
				obj.bins = logical(obj.bins);
				obj.spikeData(loop).spikes = obj.bins;
			end
		end
		
		function compute(obj)
			obj.fanoParams.alignTime = obj.alignTime;
			obj.fanoParams.boxWidth = obj.boxWidth;
			obj.fanoParams.matchReps = obj.matchReps;
			obj.plotFanoParams.plotRawF = obj.plotRawF;
			obj.plotFanoParams.lengthOfTimeCal = obj.lengthOfTimeCal;
			obj.result = VarVsMean(obj.spikeData, obj.times, obj.fanoParams);
		end
		
		function plot(obj)
			plotFano(obj.result,obj.plotFanoParams);
		end
		
		function movie(obj)
			ScatterMovie(obj.result)
		end
	end
	
end

