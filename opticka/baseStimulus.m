classdef baseStimulus < handle
	%BASESTIMULUS Summary of this class goes here
	%   Detailed explanation goes here
	properties
		family='grating'
		type='sinusoid'
		xPosition=0
		yPosition=0
		size=200
		windowed='none'
	end
	properties (SetAccess = private, GetAccess = private)
		display=0
		texid
		allowedPropertiesBase='^(family|type|xPosition|yPosition|size|windowed)$'
	end
	methods
		function obj = baseStimulus(args)
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
				obj.type=args{1};
				obj.size=args{2};
				obj.xPosition=args{3};
				obj.yPosition=args{4};
			end
		end
		function salutation(obj,in)
			if ~exist('in','var')
				in = 'random user';
			end
			fprintf(['\nHello from ' obj.family ' stimulus, ' in '\n\n']);
		end
	end
end