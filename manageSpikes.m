classdef manageSpikes < handle
	properties %------------------PUBLIC PROPERTIES--------------%
		action='check'
		branch='main'
		installLocation='/Users/Shared/Code/'
		directoryName='spikes'
		checkoutCommand='branch'
		bzrLocation='/usr/local/bin/bzr'
		codeSource='http://144.82.131.18/spikes'
		revNo=0
		verbose=1
		bzrVersion=''
		revInfo=''
		repInfo=''
		bzrInfo=''
		spikesPath=''
		
	end
	properties (SetAccess = private, GetAccess = public) %---PROTECTED PROPERTIES---%
		externalPath=''
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
					obj.bzrLocation='/usr/local/bin/bzr';
				case 'WIN'
					obj.installLocation='C:\Users\Public\Code\';
					obj.bzrLocation='bzr.exe';
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
			obj.salutation('Finished initialising manageSpikes...');
		end

		%====Check if things are installed or not====%
		function check(obj,~) 
			[status,obj.bzrInfo]=system([obj.bzrLocation ' version']); 
			if status == 0
				version=regexp(obj.bzrInfo,'Bazaar \(bzr\) (?<value>[\d]\.[\d][\.\d\w]+)','names');
				if ~isempty(version)
					obj.bzrVersion=version.value;
				else
					obj.bzrVersion=['Couldn''t find version'];
				end
				obj.hasBzr = 1;
			end
			if exist([obj.installLocation obj.directoryName],'dir')
				cd([obj.installLocation obj.directoryName]);
				[status,obj.revInfo]=system([obj.bzrLocation ' log -r -1']);
				if status ~= 0
					obj.salutation(['Bzr can''t find a managed source -- ' values]);
					obj.isInstalled=0;
				else
					obj.isInstalled = 1;
					revNo=regexp(obj.revInfo,'revno: (\d)+','tokens'); %Get revision number 
					obj.revNo=revNo{1}{1};
					[~,obj.repInfo]=system([obj.bzrLocation ' info -v']);
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
                if regexp(obj.action,'install');
                    obj.salutation('We have both Bzr and a Spikes install, we will try to update it');
                else
                    obj.salutation(['We have found an installed Spikes Revision: ' obj.revNo ' and you have Bzr able to update this install...']);
                end
            elseif obj.hasBzr==1 && obj.isInstalled~=1
				if regexp(obj.action,'install');
					obj.salutation(['We will install the latest version of Spikes into ' obj.installLocation obj.directoryName '.']);
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
				[~,values]=system([obj.bzrLocation ' ' obj.checkoutCommand ' ' obj.codeSource ' ' obj.installLocation obj.directoryName]);
				obj.salutation(values)
				obj.purgepath;
				obj.genpath;
				obj.addpath;
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
				[status,values]=system([obj.bzrLocation ' ' obj.checkoutCommand ' ' obj.codeSource ' ' obj.installLocation obj.directoryName]);
				if status ~= 0;obj.salutation(['Argh, couldn''t branch! - ' values]);else obj.salutation(['Success: ' values]);end
				obj.purgepath;
				obj.genpath(fullfile(obj.installLocation,obj.directoryName));
				obj.addpath;
			else
				cd(obj.installLocation);
				cd(obj.directoryName);
				[status,values]=system([obj.bzrLocation ' pull ' obj.codeSource]);
				if status ~= 0;obj.salutation(['Couldn''t update directory! - ' values]);end
				obj.salutation(values);
				if regexpi(values,'These branches have diverged')
					obj.salutation('You will need to manually merge this local and remote trees, please ask Ian for more information!')
					system([obj.bzrLocation ' explorer ']);
				end
				obj.purgepath;
				obj.genpath(fullfile(obj.installLocation,obj.directoryName));
				obj.addpath;
			end
			
			%obj.verbose=0;
			obj.check('afterupdate')
		end
		
		%=====Info======%		
		function info(obj,~) %just a wrapper to a verbose check
			obj.verbose=1;
			obj.check('callfromchar')
			obj.spikesPath=obj.genpath(fullfile(obj.installLocation,obj.directoryName));
		end
		
		%=====Update toolbox======%		
		function purge(obj,automatic)
			if automatic
				obj.purgepath
			else
				out=input('---> Do you want to purge the path? -- ','s');
				if regexpi(out,'(yes|y)') %%% Clean install
					obj.purgepath
				end
			end
		end
		
		function addExternal(obj,d)
			obj.externalPath='';
			obj.externalPath=obj.genpath(d);
			obj.addpath(obj.externalPath)
		end
		
		function removeExteral(obj,d)
			obj.externalPath='';
			obj.externalPath=obj.genpath(d);
			obj.removepath(obj.externalPath)
		end
		
		function explore(obj,~)
			cd([obj.installLocation obj.directoryName]);
			[status,values]=system([obj.bzrLocation ' ' obj.directoryName]);
			if status ~= 0;obj.salutation(['Argh, could not explore']);end
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
		
		function addpath(obj,d)
			if ~exist('d','var')				
				addpath(obj.spikesPath,'-begin');
			else
				addpath(d,'-begin');
			end
			savepath;
		end
		
		function removepath(obj,d)
			if ~exist('d','var')
				rmpath(obj.spikesPath);
			else
				rmpath(d);
			end
			savepath;
		end
		
		function checkpath(obj)
			
		end
		
		function purgepath(obj) %this will strip out anything that matches spikes in its path.
			p = path;
			fragment = regexp(p,['(?<spath>/[^' pathsep ']*spikes[^' pathsep ']*' pathsep ')']);
			rmpth='';
			for i=1:length(fragment)
				rmpth=strcat(rmpth,fragment(i).spath);
			end
			if ~isempty(rmpth)
				rmpath(rmpth);
			end
		end
		
		function parsepath(obj) %
			oldpath = path;
			
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