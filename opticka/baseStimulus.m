classdef baseStimulus < handle
   properties
      type
		xPosition
		yPosition
		size
	end
	properties (SetAccess = private, GetAccess = private)
		display
	end
   methods
      function obj = baseStimulus(args)
			if nargin>0 && iscell(args)
				obj.type=args{1};
				obj.size=args{2};
				obj.xPosition=args{3};
				obj.yPosition=args{4};
			else
				obj.type='grating';
				obj.size=1;
				obj.xPosition=0;
				obj.yPosition=0;
			end
		end
		function blah(obj,in)
			x=['Hello ' in '!']
		end
   end
end