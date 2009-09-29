classdef stimulusSequence < handle
	properties
		randomMode = 'normal'
		numOfVariables = 1
	end
	properties (SetAccess = private, GetAccess = private)
		
	end
	methods
		function obj = stimulusSequence(args) % Constructor merhod
			
		end
		function salutation(obj,in)
			fprintf(['\nHello from ' obj.type ' stimulus ' in '\n\n']);
		end
	end
end