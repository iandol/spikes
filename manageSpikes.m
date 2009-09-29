classdef manageSpikes < handle
	properties
		action='check'
		branch='main'
		installLocation='/Users/Shard/Code/spikes'
		bzrLocation='/usr/local/bin'
	end
	properties (SetAccess = private, GetAccess = private)
		hasBzr = 0;
		isInstalled = 0
		arch = 'MACI'
		allowedProperties = '(action|branch|installLocation|bzrLocation)'
	end
	methods
		%%%CONSTRUCTOR%%%
		function obj = manageSpikes(args)
			%Initialise for superclass, stops a noargs error
			if nargin == 0
				args.action = 'check';
			end
			%start to build our parameters
			if isstruct(args)
				fnames = fieldnames(args); %find our argument names
				for i=1:length(fnames);
					if regexp(fnames{i},obj.allowedProperties) %only set if allowed property
						obj.salutation(fnames{i});
						obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
					end
				end
			elseif ischar(args)
				switch args
					case 'install'
						obj.install('installLocation')
					case 'check'
						obj.check('Hello')
					case 'info'
				end
			end
			switch obj.action
				case 'install'
					obj.install('installLocation')
				case 'check'
					obj.check('Hello')
				case 'info'
			end
			obj.salutation('startup');
		end
		
		%%%Check if things are installed or not%%%
		function check(obj,~)
			if regexp(computer,'(MACI|MACI64)')
				obj.arch='OSX';
			else
				obj.arch='WIN';
			end
			switch obj.arch
				case 'OSX'
					obj.installLocation='/Users/Shared/Code/spikes';
					obj.bzrLocation='/usr/local/bin/';
					
				case 'WIN'
					obj.installLocation='c:\Code\spikes\';
					obj.bzrLocation='c:\bzr\';
			end
			
			[status,~]=unix([obj.bzrLocation filesep 'bzr']);
			if status == 0
				obj.hasBzr = 1;
			end
			
			if exist(obj.installLocation,'dir')
				obj.isInstalled = 1;
			end
			
			if obj.hasBzr && obj.isInstalled
				sprintf('\n\nWe have found an installed Spikes and you have Bzr able to update this install...\n')
			elseif obj.hasBzr
				sprintf('\n\nCouldn''t find install dir!!!\n')
			elseif obj.isInstalled
				sprintf('\n\nCouldn''t find BZR, please install it!!!\n')
			else
				sprintf('\n\nCouldn''t find anything!!!\n')
			end
			
			
		end
		
		%%%Salutation%%%
		function salutation(obj,in)
			if ~exist('in','var')
				in = 'random user';
			end
			fprintf(['\nHello from ' in '\n\n']);
		end
	end
end