classdef gratingStimulus < baseStimulus
%ANNULUSSTIMULUS Summary of this class goes here
%   Detailed explanation goes here
   properties
		method='procedural'
		sf=1
		tf=2
		angle=0
		rotationMethod=1
		phase=0
		contrast=0.75
		texid=[]
		mask=1
		gabor=0
	end
	properties (SetAccess = private, GetAccess = private)
		allowedProperties='^(sf|tf|method|angle|phase|rotationMethod|contrast|texid|mask)$';
	end
   methods
		function obj = gratingStimulus(args) %%%CONSTRUCTOR%%%
			%Initialise for superclass, stops a noargs error
			if nargin == 0
				args.family = 'grating';
			end
			obj=obj@baseStimulus(args); %we call the superclass constructor first
			%check we are a grating
			if ~strcmp(obj.family,'grating')
				error('Sorry, you are trying to call a gratingStimulus with a family other than grating');
			end
			%start to build our parameters
			if nargin>0 && isstruct(args)
				fnames = fieldnames(args); %find our argument names
				for i=1:length(fnames);
					if regexp(fnames{i},obj.allowedProperties) %only set if allowed property
						obj.salutation(fnames{i},'Configuring setting in gratingStimulus constructor');
						obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
					end
				end
			end
			obj.salutation('constructor','Grating Stimulus initialisation complete');
		end
		function set.sf(obj,value)
			if ~(value > 0)
				value = 0.01;
			end
			obj.sf = value;
			obj.salutation(['set sf: ' num2str(value)],'Custom set method')
		end
% 		function value = get.sf(obj)
% 			obj.salutation(['get sf: ' num2str(obj.sf)],'yay')
% 		end
	end
end