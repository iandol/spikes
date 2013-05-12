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
		resultV
		maxTime
		shiftTime = 25
			boxWidth = 100
		alignTime = 200
		matchReps = 2
		binSpacing = 0.25
		includeVarMinusMean = 1
		plotRawF = 0
		lengthOfTimeCal = 100
		scatterTimes =[]
		bins
		spikeData
		loop
	end
	
	methods
		function obj = fanoPlotter(args)
			qs = {'Box Width?','Align Time?','Shift Time?','Match Reps?','Bin Spacing?'};
			tit = 'Matched Fano Options:';
			def = {num2str(obj.boxWidth), num2str(obj.alignTime),...
				num2str(obj.shiftTime), num2str(obj.matchReps), num2str(obj.binSpacing)};
			ans = inputdlg(qs,tit,[1 100],def);
			obj.boxWidth = str2num(ans{1});
			obj.alignTime = str2num(ans{2});
			obj.shiftTime = str2num(ans{3});
			obj.matchReps = str2num(ans{4});
			obj.binSpacing = str2num(ans{5});
		end
		
		function convertSpikesFormat(obj,data,select)
			obj.data = data;
			obj.maxTime = floor(obj.data.modtime/10);
			obj.times = obj.boxWidth:obj.shiftTime:(obj.maxTime-obj.boxWidth);
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
		
		function analyse(obj)
			obj.result = [];
			obj.resultV = [];
			try
				obj.compute;
			catch ME
				fprintf('!!!Fano mean matching failed! Falling back to non-mean matched fano plot...\n');
				ple(ME)
				oldreps = obj.matchReps;
				try
					obj.matchReps = 0;
					obj.compute;
					obj.matchReps = oldreps;
				catch ME
					obj.matchReps = oldreps;
					%warndlg('Non-mean matched fano plot failed too...')
					fprintf('!!!Non-mean matched fano plot failed too...\n');
					ple(ME)
				end
			end
			try
				obj.computeV;
			catch ME
				fprintf('\nPlot VarCE mean matching failed! Falling back to non-mean matched fano plot...\n');
				ple(ME)
				oldreps = obj.matchReps;
				try
					obj.matchReps = 0;
					obj.computeV;
					obj.matchReps = oldreps;
				catch ME
					obj.matchReps = oldreps;
					%warndlg('Non-mean matched VarCE plot failed too...')
					fprintf('\nNon-mean matched VarCE plot failed too...\n');
					ple(ME)
				end
			end
			obj.plot();
			
		end
		
		function compute(obj)
			obj.fanoParams.alignTime = obj.alignTime;
			obj.fanoParams.boxWidth = obj.boxWidth;
			obj.fanoParams.matchReps = obj.matchReps;
			obj.fanoParams.binSpacing = obj.binSpacing;
			obj.fanoParams.includeVarMinusMean = obj.includeVarMinusMean;
			obj.result = VarVsMean(obj.spikeData, obj.times, obj.fanoParams);
			obj.resultV = compute_VarCE(obj.spikeData, obj.times, obj.fanoParams);
		end
		
		function computeV(obj)
			obj.fanoParams.alignTime = obj.alignTime;
			obj.fanoParams.boxWidth = obj.boxWidth;
			obj.fanoParams.matchReps = obj.matchReps;
			obj.fanoParams.binSpacing = obj.binSpacing;
			obj.fanoParams.includeVarMinusMean = obj.includeVarMinusMean;
			obj.resultV = compute_VarCE(obj.spikeData, obj.times, obj.fanoParams);
		end
		
		function plot(obj)
			obj.plotFanoParams.plotRawF = obj.plotRawF;
			obj.plotFanoParams.lengthOfTimeCal = obj.lengthOfTimeCal;
			obj.scatterParams.axLim = 'auto';
			if isempty(obj.scatterTimes)
				obj.scatterTimes = [0 obj.maxTime/2];
			end
			if ~isempty(obj.result)
				plotFano(obj.result,obj.plotFanoParams);
% 				for i = 1:length(obj.scatterTimes)
% 					plotScatter(obj.result, obj.scatterTimes(i), obj.scatterParams)
% 				end
			end
			if ~isempty(obj.resultV)
				plotFano(obj.resultV,obj.plotFanoParams);
% 				for i = 1:length(obj.scatterTimes)
% 					plotScatter(obj.resultV, obj.scatterTimes(i), obj.scatterParams)
% 				end
			end
		end
		
		function movie(obj)
			ScatterMovie(obj.result)
		end
		
		
		
	end
	
end

