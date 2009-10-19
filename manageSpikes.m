classdef manageSpikes < handle
	properties
		action='check'
		branch='main'
		installLocation='/Users/Shared/Code/spikes/'
		bzrLocation='/usr/local/bin/'
	end
	properties (SetAccess = private, GetAccess = private)
		hasBzr = 0;
		isInstalled = 0
		arch = 'OSX'
		allowedProperties = '(action|branch|installLocation|bzrLocation)'
	end
	methods
		%%%CONSTRUCTOR%%%
		function obj = manageSpikes(args)
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
			%Initialise for superclass, stops a noargs error
			if nargin == 0
				args.action = 'check';
			end
			%start to build our parameters
			if isstruct(args)
				fnames = fieldnames(args); %find our argument names
				for i=1:length(fnames);
					if regexp(fnames{i},obj.allowedProperties) %only set if allowed property
						obj.salutation(['Adding ' fnames{i} '|' args.(fnames{i}) ' command...']);
						obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
					end
				end
			elseif ischar(args)
				obj.action = args;
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
			obj.salutation('Finished running manageSpikes...');
		end

		%%%Check if things are installed or not%%%
		function check(obj,~)
			[status,~]=system([obj.bzrLocation filesep 'bzr']);
			if status == 0
				obj.hasBzr = 1;
			end
			if exist(obj.installLocation,'dir')
				obj.isInstalled = 1;
			end
			if obj.hasBzr && obj.isInstalled
				obj.salutation('We have found an installed Spikes and you have Bzr able to update this install...');
			elseif obj.hasBzr
				obj.salutation('Spikes directory hasn''t been found. Run manageSpikes(''Install'') to install Spikes into Matlab.');
			elseif obj.isInstalled
				obj.salutation('Couldn''t find BZR, please install it!!!');
			else
				obj.salutation('Couldn''t find anything!!!');
			end
		end

		function install(obj,~)
			obj.check();
			if obj.hasBzr && obj.isInstalled %%%We need to upgrade
				cd(obj.installLocation);
				[status,values]=system([obj.bzrLocation 'bzr log -r -1']);
				obj.salutation(values);
			elseif obj.hasBzr
				[status,values]=system([obj.bzrLocation 'bzr branch sftp://amscode@144.82.131.18/Code/user ' obj.installLocation]);
				obj.salutation(values)
			end
		end
		
		%%%Salutation%%%
		function salutation(obj,in)
			if ~exist('in','var')
				
			else
				disp(sprintf('---> %s',in));
			end
		end
	end
end