classdef manageSpikes < handle
	properties
		action='check'
		branch='main'
		installLocation='/Users/Shared/Code/'
		directoryName='spikes'
		update='yes'
		checkoutCommand='branch'
		bzrLocation='/usr/local/bin/'
		codeSource='http://144.82.131.18/user'
	end
	properties (SetAccess = private, GetAccess = private)
		hasBzr = 0;
		isInstalled = 0
		arch = 'OSX'
		allowedProperties = '(action|branch|installLocation|checkoutCommand|update|directoryName|bzrLocation|codeSource)'
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
					obj.installLocation='/Users/Shared/Code/';
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
				cd(obj.installLocation);
				[status,values]=system([obj.bzrLocation 'bzr log -r -1']);
			end
			if obj.hasBzr==1 && obj.isInstalled==1
				obj.salutation('We have found an installed Spikes and you have Bzr able to update this install...');
			elseif obj.hasBzr==1 && obj.isInstalled~=1
				if regexp(obj.action,'install');obj.salutation('Spikes directory hasn''t been found. Run manageSpikes(''Install'') to install Spikes into Matlab.');end;
			elseif obj.hasBzr~=1 && obj.isInstalled==1
				obj.salutation('Couldn''t find BZR, please install it first!!!');
			else
				obj.salutation('Couldn''t find anything!!!');
			end
		end

		function install(obj,~)
			obj.check;
			if obj.hasBzr && obj.isInstalled %%% We need to upgrade
				out=input('Do you want to delete the previous install?','s');
				if regexpi(out,'(yes|y)') %%% Clean install
					cd(obj.installLocation);
					[status,values]=system(['rm -rf ' obj.directoryName]);
					if status ~= 0;obj.salutation(['Argh, couldn''t delete old install! - ' values]);end
					[status,values]=system(['mkdir -p ' obj.installLocation]);
					if status ~= 0;obj.salutation(['Argh, couldn''t make install directory! - ' values]);end
					[status,values]=system([obj.bzrLocation 'bzr ' obj.checkoutCommand ' ' obj.codeSource ' ' obj.installLocation obj.directoryName]);
					if status ~= 0;obj.salutation(['Argh, couldn''t branch! - ' values]);end
				else
					cd(obj.installLocation);
					cd(obj.directoryName);
					[status,values]=system([obj.bzrLocation 'bzr pull']);
					if status ~= 0;obj.salutation(['Couldn''t update directory! - ' values]);end
					obj.salutation(values);
				end
			elseif obj.hasBzr==1 && obj.isInstalled==0
				[status,values]=system(['mkdir -p ' obj.installLocation]);
				if status ~= 0;obj.salutation(['Argh, couldn''t make install directory! - ' values]);end
				[status,values]=system([obj.bzrLocation 'bzr ' obj.checkoutCommand ' ' obj.codeSource ' ' obj.installLocation obj.directoryName]);
				obj.salutation(values)
			end
		end
	end
	
	methods ( Access = private )
		%%%Salutation%%%
		function salutation(obj,in)
			if ~exist('in','var')
				
			else
				disp(sprintf('---> %s',in));
			end
		end
	end
end