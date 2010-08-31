classdef dotsStimulus < baseStimulus
%DOTSSTIMULUS single coherent dots stimulus, inherits from baseStimulus
%   The current properties are:

	properties %--------------------PUBLIC PROPERTIES----------%
		family = 'dots'
		type = 'simple'
		dotSpeed = 5    % dot speed (deg/sec)
		nDots = 2000 % number of dots
		angle = 90
		maxDiameter = 10   % maximum radius of  annulus (degrees)
		minDiameter = 1  % minumum radius of  annulus (degrees)
		dotWidth       = 0.2  % width of dot (deg)
		coherence = 1;
		direction = 0
		kill      = 0.2 % fraction of dots to kill each frame  (limited lifetime)
		waitFrames = 5     % Show new dot-images at each waitframes'th  monitor refresh.
	end

	properties (SetAccess = private, GetAccess = private)
		dots
		allowedProperties='^(dotSpeed|nDots|maxDiameter|minDiameter|dotWidth|coherence|direction|kill|waitFrames)$';
	end
	
   methods %----------PUBLIC METHODS---------%
		%-------------------CONSTRUCTOR----------------------%
		function obj = dotsStimulus(args) 
			%Initialise for superclass, stops a noargs error
			if nargin == 0
				args.family = 'dots';
			end
			obj=obj@baseStimulus(args); %we call the superclass constructor first
			%check we are a grating
			if ~strcmp(obj.family,'dots')
				error('Sorry, you are trying to call a dotsStimulus with a family other than dots');
			end
			%start to build our parameters
			if nargin>0 && isstruct(args)
				fnames = fieldnames(args); %find our argument names
				for i=1:length(fnames);
					if regexp(fnames{i},obj.allowedProperties) %only set if allowed property
						obj.salutation(fnames{i},'Configuring setting in dotsStimulus constructor');
						obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
					end
				end
			end
			obj.salutation('constructor','Dots Stimulus initialisation complete');
		end
		
		function initialiseDots(obj)
			if strcmp(obj.type,'simple')
				obj.dots.allAngles=ones(obj.nDots,1).*(obj.angle*(pi/180));
				obj.dots.randDots=obj.nDots-floor(obj.nDots*(obj.coherence/100));
				if obj.dots.randDots>0
					obj.dots.allAngles(1:obj.dots.randDots)=(2*pi).*rand(1,obj.dots.randDots);
				end
				r = rmax * sqrt(rand(ndots,1)); % r
				r(r<rmin) = rmin;
				t = 2*pi*rand(ndots,1);                     % theta polar  coordinate
				cs = [cos(t), sin(t)];
				xy = [r r] .* cs;   % dot positions in Cartesian coordinates  (pixels from center)
				dr = pfs.*(cueSign.*ones(ndots, 1))          ;   % change in radius per  frame (pixels)
				dxdy= dr(1).*[cos(allAngles) sin(allAngles)];
			else
				
			end
		end
		
	end %---END PUBLIC METHODS---%
	
	methods ( Access = private ) %----------PRIVATE METHODS---------%
		
	end
end