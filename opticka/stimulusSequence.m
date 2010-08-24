classdef stimulusSequence < dynamicprops
	properties
		randomise = 1
		nVars = 0
		nVar
		nTrials = 5
		nTrial
		nSegments = 1
		nSegment
		isTime = 1 %inter stimulus time
		isStimulus %what do we show in the blank?
		verbose = 1
		randomSeed
		randomGenerator='mt19937ar' %mersenne twister default
	end
	
	properties (SetAccess = private, GetAccess = public)
		oldStream
		taskStream
		minTrials
		currentState
		outValues
		outVars
	end
	
	properties (SetAccess = private, GetAccess = private)
		allowedPropertiesBase='^(randomMode|numOfVariables|numOfTrials|blankTime)$'
	end
	
	methods
		%-------------------CONSTRUCTOR----------------------%
		function obj = stimulusSequence(args) 
			if nargin>0 && isstruct(args)
				%if isfield(args,'family');obj.family=args.family;end
				if nargin>0 && isstruct(args)
					fnames = fieldnames(args); %find our argument names
					for i=1:length(fnames);
						if regexp(fnames{i},obj.allowedPropertiesBase) %only set if allowed property
							obj.salutation(fnames{i});
							obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
						end
					end
				end
			end
			obj.initialiseRandom();
		end
		
		%-------------------set up the random number generator------------
		function initialiseRandom(obj)
			if isempty(obj.randomSeed)
				obj.randomSeed=GetSecs;
			end
			obj.oldStream = RandStream.getDefaultStream;
			obj.taskStream = RandStream.create(obj.randomGenerator,'Seed',obj.randomSeed);
			RandStream.setDefaultStream(obj.taskStream);
		end
		
		%------------------reset the random number generator-------------
		function resetRandom(obj)
			RandStream.setDefaultStream(obj.oldStream);
		end
		
		%-------------------Do the randomisation-------------------------
		function randomiseStimuli(obj)
			
			obj.nVars=length(obj.nVar);
			
			obj.currentState=obj.taskStream.State;
			
			nLevels = zeros(obj.nVars, 1);
			for f = 1:obj.nVars
				nLevels(f) = length(obj.nVar(f).values);
			end
			obj.minTrials = prod(nLevels);

			% initialize cell array that will hold balanced variables
			obj.outVars = cell(obj.nTrials, obj.nVars);
			obj.outValues = [];

			% the following initializes and runs the main loop in the function, which
			% generates enough repetitions of each factor, ensuring a balanced design,
			% and randomizes them
			offset=0;
			for i = 1:obj.nTrials
				len1 = obj.minTrials;
				len2 = 1;
				[~, index] = sort(rand(obj.minTrials, 1));
				for f = 1:obj.nVars
					len1 = len1 / nLevels(f);
					if size(obj.nVar(f).values, 1) ~= 1
						% ensure that factor levels are arranged in one row
						obj.nVar(f).values = reshape(obj.nVar(f).values, 1, numel(obj.nVar(1).values));
					end
					% this is the critical line: it ensures there are enough repetitions
					% of the current factor in the correct order
					obj.outVars{i,f} = repmat(reshape(repmat(obj.nVar(f).values, len1, len2), obj.minTrials, 1), obj.nVars, 1);
					if obj.randomise
						obj.outVars{i,f} = obj.outVars{i,f}(index);
					end
					len2 = len2 * nLevels(f);
					mn=offset+1;
					mx=i*obj.minTrials;
					obj.outValues(mn:mx,f)=obj.outVars{i,f};
				end
				offset=offset+obj.minTrials;
			end
		end
		
		%-------------------blah blah blah-----------------------------------
		function salutation(obj,in,message)
			if obj.verbose==1
				if ~exist('in','var')
					in = 'random user';
				end
				if exist('message','var')
					fprintf([message ' | ' in '\n']);
				else
					fprintf(['\nHello from randomise, ' in '\n\n']);
				end
			end
		end
	end
end