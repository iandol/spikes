classdef manageSpikes < handle
	properties %------------------PUBLIC PROPERTIES--------------%
		action='check'
		branch='main'
		installLocation='/Users/Shared/Code/'
		directoryName='spikes'
		checkoutCommand='branch'
		bzrLocation='/usr/local/bin/'
		codeSource='http://144.82.131.18/spikes'
		revNo=0
		verbose=1
		bzrVersion=''
		revInfo=''
		repInfo=''
		bzrInfo=''
		path=''
	end
	properties (SetAccess = private, GetAccess = private) %---PRIVATE PROPERTIES---%
		hasBzr = 0
		isInstalled = 0
		arch = 'OSX'
		allowedProperties = '(action|branch|installLocation|checkoutCommand|directoryName|bzrLocation|codeSource|verbose)'
	end
	methods %------------------PUBLIC METHODS--------------%
		
		%==============CONSTRUCTOR============%
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
					obj.installLocation='c:\Code\';
					obj.bzrLocation='c:\bzr\';
			end
			%Initialise for superclass, stops a noargs error
			if nargin == 0
				args.action = 'check';
			end
			%start to build our parameters
			if isstruct(args)
				fnames = fieldnames(args); %find our argument names
				for i=1:length(fnames); %this loops checks it is a valid fieldname then sets it via a tight loop
					if regexp(fnames{i},obj.allowedProperties) %only set if allowed property
						if obj.verbose==1;obj.salutation(['Adding ' fnames{i} '|' args.(fnames{i}) ' command...']);end
						obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
					end
				end
				switch obj.action
					case 'install'
						obj.install('callfromstructure')
					case 'update'
						obj.update('callfromstructure')
					case 'check'
						obj.check('callfromstructure')
					case 'info'
						obj.info('callfromstructure')
				end
			elseif ischar(args)
				obj.action = args;
				switch args
					case 'install'
						obj.install('callfromchar')
					case 'update'
						obj.update('callfromchar')
					case 'check'
						obj.check('callfromchar')
					case 'info'
						obj.info('callfromchar')
					case 'help'
						obj.help('callfromchar')
				end
			end
			obj.salutation('Finished running manageSpikes...');
		end

		%====Check if things are installed or not====%
		function check(obj,~) 
			[status,obj.bzrInfo]=system([obj.bzrLocation filesep 'bzr version']); 
			if status == 0
				version=regexp(obj.bzrInfo,'^Bazaar \(bzr\) (\d+\.\d+\.\d+)','tokens');
				obj.bzrVersion=version{1}{1};
				obj.hasBzr = 1;
			end
			if exist(obj.installLocation,'dir')
				cd([obj.installLocation obj.directoryName]);
				[status,obj.revInfo]=system([obj.bzrLocation 'bzr log -r -1']);
				if status ~= 0
					obj.salutation(['Bzr can''t find a managed source -- ' values]);
					obj.isInstalled=0;
				else
					obj.isInstalled = 1;
					revNo=regexp(obj.revInfo,'revno: (\d)+','tokens'); %Get revision number 
					obj.revNo=revNo{1}{1};
					[~,obj.repInfo]=system([obj.bzrLocation 'bzr info -v']);
					if obj.verbose == 1
						obj.salutation
						obj.salutation(obj.revInfo);
						obj.salutation(obj.repInfo);
					else
						obj.salutation(['Current installed revision is: ' obj.revNo])
					end
				end
			end
			if obj.hasBzr==1 && obj.isInstalled==1 && obj.verbose==1
				obj.salutation(['We have found an installed Spikes Revision: ' obj.revNo ' and you have Bzr able to update this install...']);
			elseif obj.hasBzr==1 && obj.isInstalled~=1
				if regexp(obj.action,'install');
					obj.salutation(['We will need to install a fresh copy into ' obj.installLocation obj.directoryName '.']);
				else
					obj.salutation('Spikes directory hasn''t been found. Run manageSpikes(''install'') if you wish to install Spikes into Matlab.');
				end;
			elseif obj.hasBzr~=1 && obj.isInstalled==1
				obj.salutation('Couldn''t find Bzr, please install it first!!!');
			else
				obj.salutation('Couldn''t find Bzr or any installed spikes toolbox!!!');
			end
		end

		%========Install spikes toolbox=======%
		function install(obj,~)
			obj.check;
			if obj.hasBzr && obj.isInstalled %%% We need to upgrade
				obj.update(obj.installLocation);
			elseif obj.hasBzr==1 && obj.isInstalled==0
				[status,values]=system(['mkdir -p ' obj.installLocation]);
				if status ~= 0;obj.salutation(['Argh, couldn''t make install directory! - ' values]);end
				[~,values]=system([obj.bzrLocation 'bzr ' obj.checkoutCommand ' ' obj.codeSource ' ' obj.installLocation obj.directoryName]);
				obj.salutation(values)
			end
		end
		
		%=====Update toolbox======%		
		function update(obj,~)
			out=input('---> Do you want to delete the previous install? -- ','s');
			if regexpi(out,'(yes|y)') %%% Clean install
				cd(obj.installLocation);
				[status,values]=system(['rm -rf ' obj.directoryName]);
				if status ~= 0;obj.salutation(['Argh, couldn''t delete old install! - ' values]);end
				[status,values]=system(['mkdir -p ' obj.installLocation]);
				if status ~= 0;obj.salutation(['Argh, couldn''t make install directory! - ' values]);end
				[status,values]=system([obj.bzrLocation 'bzr ' obj.checkoutCommand ' ' obj.codeSource ' ' obj.installLocation obj.directoryName]);
				if status ~= 0;obj.salutation(['Argh, couldn''t branch! - ' values]);else obj.salutation(['Success: ' values]);end
			else
				cd(obj.installLocation);
				cd(obj.directoryName);
				[status,values]=system([obj.bzrLocation 'bzr pull ' obj.codeSource]);
				if status ~= 0;obj.salutation(['Couldn''t update directory! - ' values]);end
				if regexpi(values,'These branches have diverged')
					obj.salutation('You will need to manually merge this local and remote tree''s, please ask Ian for more information!')
				end
				%obj.salutation(values);
			end
			%obj.verbose=0;
			obj.check('afterupdate')
		end
		
		%=====Info======%		
		function info(obj,~) %just a wrapper to a verbose check
			obj.verbose=1;
			obj.check('callfromchar')
			obj.path=obj.genpath(fullfile(obj.installLocation,obj.directoryName));
		end
		
		function help(obj,~)
			
		end
	end %---END PUBLIC METHODS---%
	
	methods ( Access = private ) %----------PRIVATE METHODS---------%
		%===========Salutation==========%
		function salutation(obj,in)
			if ~exist('in','var')
				fprintf('\n');
			else
				fprintf('---> %s\n',in);
			end
		end
		
		function addpath(obj)
			addpath(obj.path,'-begin');
			savepath;
		end
		
		function removepath(obj)
			rmpath(obj.path);
			savepath;
		end
		
		function checkpath(obj)
			
		end
		
		function p=genpath(obj,d) %modified to allow exclusion of 
			exclstart = '^(\.|\.\.|@|+|\.bzr|\.svn|\.git)';
			exclpath = '(VSX|VSS|c_sources|licence|private)';
			p = '';

			% Generate path based on given root directory
			files = dir(d);
			if isempty(files)
			  return
			end

			% Add d to the path even if it is empty.
			p = [p d pathsep];

			% set logical vector for subdirectory entries in d
			isdir = logical(cat(1,files.isdir));
		
			dirs = files(isdir); % select only directory entries from the current listing

			for i=1:length(dirs)
				dirname = dirs(i).name;
				if isempty(regexpi(dirname,exclstart)) && isempty(regexpi(dirname, exclpath))
					p = [p obj.genpath(fullfile(d,dirname))]; % recursive calling of this function.
				end
			end
		end
	end %---END PRIVATE METHODS---%
end