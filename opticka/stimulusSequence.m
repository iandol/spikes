classdef stimulusSequence < handle
	properties
		randomMode = 'normal'
		numOfVariables = 1
		numOfTrials = 5
		blankTime = 1
	end
	properties (SetAccess = private, GetAccess = private)
		allowedPropertiesBase='^(randomMode|numOfVariables|numOfTrials|blankTime)$'
	end
	methods
		function obj = stimulusSequence(args) % Constructor merhod
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
			elseif nargin>0 && iscell(args)
				obj.randomMode=args{1};
				obj.numOfVariables=args{2};
				obj.numOfTrials=args{3};
				obj.yPosition=args{4};
			end
		end
		function salutation(obj,in)
			fprintf(['\nHello from ' obj.type ' stimulus ' in '\n\n']);
		end
	end
end