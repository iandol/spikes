classdef baseStimulus < handle
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
	end
   methods
      function obj = baseStimulus(args)
			if nargin>0 && isstruct(args)
				if isfield(args,'family');obj.family=args.family;end
				if isfield(args,'type');obj.type=args.type;end
				if isfield(args,'size');obj.size=args.size;end
				if isfield(args,'xPosition');obj.xPosition=args.xPosition;end
				if isfield(args,'yPosition');obj.yPosition=args.yPosition;end
				if isfield(args,'windowed');obj.windowed=args.windowed;end
				if isfield(args,'display');obj.display=args.display;end
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
			fprintf(['\nHello from ' obj.type ' stimulus, ' in '\n\n']);
		end
   end
end