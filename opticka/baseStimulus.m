classdef baseStimulus < dynamicprops
	%BASESTIMULUS Superclass providing basic structure for all stimulus
	%classes
	%   Detailed explanation to come
	properties
		family='grating'
		type='sinusoid'
		xPosition=0
		yPosition=0
		size=2
		color=[0.5 0.5 0.5 0]
		verbose=0
	end
	properties (SetAccess = private, GetAccess = private)
		texid
		allowedPropertiesBase='^(family|type|xPosition|yPosition|size|color|verbose)$'
	end
	methods
		%-------------------CONSTRUCTOR----------------------%
		function obj = baseStimulus(args)
			if nargin>0 && isstruct(args)
				if nargin>0 && isstruct(args)
					fnames = fieldnames(args); %find our argument names
					for i=1:length(fnames);
						if regexp(fnames{i},obj.allowedPropertiesBase) %only set if allowed property
							obj.salutation(fnames{i},'Configuring setting in baseStimulus constructor');
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
		function salutation(obj,in,message)
			if obj.verbose==1
				if ~exist('in','var')
					in = 'random user';
				end
				if exist('message','var')
					fprintf([message ' | ' in '\n']);
				else
					fprintf(['\nHello from ' obj.family ' stimulus, ' in '\n\n']);
				end
			end
		end
	end
end