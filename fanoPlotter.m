classdef fanoPlotter < handle
	%FANOPLOT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		times
		data
		fanoParams
		plotFanoParams
		scatterParams
		select = 1
		result
		maxTime
		shiftTime = 25
		boxWidth = 100
		alignTime = 200
		matchReps = 10
		binSpacing = 0.25
		plotRawF = 1
		lengthOfTimeCal = 100
		scatterTimes =[]
		bins
		spikeData
		loop
	end
	
	methods
		function obj = fanoPlotter(args)
			qs = {'Box Width?','Align Time?','Shift Time?','Match Reps?'};
			tit = 'Mean Matcher Fano Options';
			def = {num2str(obj.boxWidth), num2str(obj.alignTime), num2str(obj.shiftTime), num2str(obj.matchReps)};
			ans = inputdlg(qs,tit,1,def);
			obj.boxWidth = str2num(ans{1});
			obj.alignTime = str2num(ans{2});
			obj.shiftTime = str2num(ans{3});
			obj.matchReps = str2num(ans{4});
		end
		
		function convertSpikesFormat(obj,data,select)
			obj.data = data;
			obj.maxTime = floor(obj.data.modtime/10);
			obj.times = 0:obj.shiftTime:(obj.maxTime-obj.boxWidth);
			obj.times = obj.times(2:end-1);
			
			if ~exist('select','var')
				if isempty(obj.loop)
					obj.loop = 1:obj.data.xrange * obj.data.yrange;
				end
			else
				obj.loop = select;
			end
			lin=1;
			for l = obj.loop
				obj.bins = [];
				in = obj.data.raw{l};
				a = 1;
				for i = 1:in.numtrials
					for j = 1:in.nummods
						spikes = in.trial(i).mod{j} / 10;
						obj.bins(a,:) = hist(spikes, obj.maxTime);
						a=a+1;
					end
				end
				obj.bins = logical(obj.bins);
				obj.spikeData(lin).spikes = obj.bins;
				lin = lin + 1;
			end
		end
		
		function compute(obj)
			obj.fanoParams.alignTime = obj.alignTime;
			obj.fanoParams.boxWidth = obj.boxWidth;
			obj.fanoParams.matchReps = obj.matchReps;
			obj.fanoParams.binSpacing = obj.binSpacing;
			obj.plotFanoParams.plotRawF = obj.plotRawF;
			obj.plotFanoParams.lengthOfTimeCal = obj.lengthOfTimeCal;
			obj.scatterParams.axLim = 'auto';
			if isempty(obj.scatterTimes)
				obj.scatterTimes = [0 obj.maxTime/2];
			end
			obj.result = VarVsMean(obj.spikeData, obj.times, obj.fanoParams);
		end
		
		function plot(obj)
			plotFano(obj.result,obj.plotFanoParams);
			for i = 1:length(obj.scatterTimes)
				plotScatter(obj.result, obj.scatterTimes(i), obj.scatterParams)
			end
		end
		
		function movie(obj)
			ScatterMovie(obj.result)
		end
	end
	
end

