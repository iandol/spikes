classdef gratingStimulus < baseStimulus
   properties
		sf=0.01
		tf=0.01
		method='procedural'
		angle=0;
		phase=0;
		contrast=10;
		texid=[];
	end
	properties (SetAccess = private, GetAccess = private)
		allowedProperties='(sf|tf|method|angle|phase|contrast|texid)';
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
						obj.salutation(fnames{i});
						obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
					end
					i=i+1;
				end
				%if isfield(args,'sf');obj.sf=args.sf;end
				%if isfield(args,'tf');obj.tf=args.tf;end
				%if isfield(args,'angle');obj.angle=args.angle;end
				%if isfield(args,'phase');obj.phase=args.phase;end
				%if isfield(args,'contrast');obj.contrast=args.contrast;end
			end
			obj.salutation('happy grating stimulus user');
		end
% 		function obj = set.sf(obj,value)
% 			if ~(value > 0)
% 				value = 0.01;
% 			end
% 			obj.sf = value;
% 			obj.salutation(['set.sf: ' num2str(value)])
% 		end
% 		function value = get.sf(obj)
% 			obj.salutation(['get.sf: ' num2str(obj.sf)])
% 		end
	end
end