classdef manageCode < handle
	properties %------------------PUBLIC PROPERTIES--------------%
		action='check'
		branch='main'
		installLocation='~/Code/'
		spikesName='spikes'
		optickaName = 'opticka'
		checkoutCommand='branch'
		updateCommand = 'pull --overwrite'
		bzrLocation='/usr/local/bin/bzr'
		spikesSource='http://144.82.131.18/spikes'
		optickaSource='http://144.82.131.18/opticka'
		verbose=1
		spikesPath=''
		optickaPath='';
	end
	properties (SetAccess = private, GetAccess = public) %---PROTECTED PROPERTIES---%
		externalPath = ''
		bzrVersion = ''
		revNoSpikes = 0 
		revNoOpticka = 0
		revInfoSpikes = ''
		revInfoOpticka = ''
		repInfoSpikes = ''
		repInfoOpticka = ''
		bzrInfo = ''
	end
	properties (SetAccess = private, GetAccess = private) %---PRIVATE PROPERTIES---%
		hasBzr = 0
		isSpikes = 0
		isOpticka = 0
		arch = 'OSX'
		allowedProperties = '(action|branch|installLocation|checkoutCommand|spikesName|optickaName|bzrLocation|spikesSource|optickaSource|verbose)'
	end
	methods %------------------PUBLIC METHODS--------------%
		
		%==============CONSTRUCTOR============%
		function obj = manageCode(args) 
			if regexp(computer,'(MACI|MACI64)')
				obj.arch='OSX';
			else
				obj.arch='WIN';
			end
			switch obj.arch
				case 'OSX'
					%obj.installLocation='/Users/Shared/Code/';
					%obj.bzrLocation='/usr/local/bin/bzr';
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
			end
			obj.check;
			obj.salutation('Finished initialising manageSpikes...');
		end

		%====Check if things are installed or not====%
		function check(obj,~) 
			%grok bzr
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
			
			%grok spikes
			if exist([obj.installLocation obj.spikesName],'dir')
				cd([obj.installLocation obj.spikesName]);
				[status,obj.revInfoSpikes]=system([obj.bzrLocation ' log -r -1']);
				if status ~= 0
					obj.salutation(['Bzr can''t find a spikes managed source -- ' values]);
					obj.isSpikes=0;
				else
					obj.isSpikes = 1;
					revNoSpikes=regexp(obj.revInfoSpikes,'revno: (\d)+','tokens'); %Get revision number 
					obj.revNoSpikes=revNoSpikes{1}{1};
					[~,obj.repInfoSpikes]=system([obj.bzrLocation ' info -v']);
					if obj.verbose == 1
						obj.salutation
						obj.salutation(obj.revInfoSpikes);
						obj.salutation(obj.repInfoSpikes);
					else
						obj.salutation(['Current installed revision is: ' obj.revNoSpikes])
					end
					obj.spikesPath=obj.genpath(fullfile(obj.installLocation,obj.spikesName));
				end
			end
			
			%grok opticka
			if exist([obj.installLocation obj.optickaName],'dir')
				cd([obj.installLocation obj.optickaName]);
				[status,obj.revInfoOpticka]=system([obj.bzrLocation ' log -r -1']);
				if status ~= 0
					obj.salutation(['Bzr can''t find a managed opticka source -- ' values]);
					obj.isOpticka=0;
				else
					obj.isOpticka = 1;
					revNoOpticka=regexp(obj.revInfoOpticka,'revno: (\d)+','tokens'); %Get revision number 
					obj.revNoOpticka=revNoOpticka{1}{1};
					[~,obj.repInfoOpticka]=system([obj.bzrLocation ' info -v']);
					if obj.verbose == 1
						obj.salutation
						obj.salutation(obj.revInfoSpikes);
						obj.salutation(obj.repInfoSpikes);
					else
						obj.salutation(['Current installed opticka revision is: ' obj.revNoOpticka])
					end
					obj.optickaPath=obj.genpath(fullfile(obj.installLocation,obj.optickaName));
				end
			end
		end

		%========Install spikes toolbox=======%
		function install(obj,version)
			switch version
				case 'spikes'
					if obj.hasBzr && obj.isSpikes %%% We need to upgrade
						obj.update('spikes');
					elseif obj.hasBzr==1 && obj.isSpikes==0
						if ~exist(obj.installLocation,'dir')
							[status,values]=system(['mkdir -p ' obj.installLocation]);
							if status ~= 0;obj.salutation(['Couldn''t make root install directory! - ' values]);end
						end
						if ~exist([obj.installLocation obj.spikesName],'dir')
							[status,values]=system(['mkdir -p ' [obj.installLocation obj.spikesName]]);
							if status ~= 0;obj.salutation(['Couldn''t make install directory! - ' values]);end
						else
							out=input('---> Spikes directory exists but there is no proper install, delte it? -- ','s');
							if regexpi(out,'(yes|y)') %%% Clean install
								[status,values]=system(['rm -rf ' [obj.installLocation obj.spikesName]]);
								if status ~= 0;obj.salutation(['Couldn''t remove install directory! - ' values]);end
							end
						end
						[~,values]=system([obj.bzrLocation ' ' obj.checkoutCommand ' --use-existing-dir ' obj.spikesSource ' ' obj.installLocation obj.spikesName]);
						obj.salutation(values)
						obj.addToPath('spikes')
					end
				case 'opticka'
					if obj.hasBzr && obj.isOpticka %%% We need to upgrade
						obj.update('opticka');
					elseif obj.hasBzr==1 && obj.isOpticka==0
						if ~exist(obj.installLocation,'dir')
							[status,values]=system(['mkdir -p ' obj.installLocation]);
							if status ~= 0;obj.salutation(['Couldn''t make root install directory! - ' values]);end
						end
						if ~exist([obj.installLocation obj.optickaName],'dir')
							[status,values]=system(['mkdir -p ' [obj.installLocation obj.optickaName]]);
							if status ~= 0;obj.salutation(['Couldn''t make opticka install directory! - ' values]);end
						else
							out=input('---> Opticka directory exists but there is no proper install, delte it? -- ','s');
							if regexpi(out,'(yes|y)') %%% Clean install
								[status,values]=system(['rm -rf ' [obj.installLocation obj.optickaName]]);
								if status ~= 0;obj.salutation(['Couldn''t remove install directory! - ' values]);end
							end
						end
						[~,values]=system([obj.bzrLocation ' ' obj.checkoutCommand ' --use-existing-dir ' obj.optickaSource ' ' obj.installLocation obj.optickaName]);
						obj.salutation(values)
						obj.addToPath('opticka')
					end
			end
		end
		%========Just remake the path=======%
		function addToPath(obj,version)
			obj.purge(version,'auto');
			obj.genpath(version);
			obj.addpath(version);
		end
		
		%=====Update toolbox======%
		function purge(obj,version,automatic)
			if exist('automatic','var')
				switch version
					case 'spikes'
						obj.purgepath(version)
					case 'opticka'
						obj.purgepath(version)
				end
			else
				out=input('---> Do you want to purge the path? -- ','s');
				if regexpi(out,'(yes|y)') %%% Clean install
					switch version
						case 'spikes'
							obj.purgepath(version)
						case 'opticka'
							obj.purgepath(version)
					end
				end
			end
		end
		
		%========Add external=======%
		function addExternal(obj,d)
			obj.externalPath='';
			obj.externalPath=obj.genpath(d);
			obj.addpath(obj.externalPath)
		end
		
		%========Remove external=======%
		function removeExteral(obj,d)
			obj.externalPath='';
			obj.externalPath=obj.genpath(d);
			obj.removepath(obj.externalPath)
		end
		
		%========run GUI=======%
		function explore(obj,~)
			cd([obj.installLocation obj.spikesName]);
			[status,values]=system([obj.bzrLocation ' ' obj.spikesName]);
			if status ~= 0;obj.salutation(['Argh, could not explore']);end
		end
	end %---END PUBLIC METHODS---%
	
	methods ( Access = private ) %----------PRIVATE METHODS---------%
		%=====Update toolbox======%		
		function update(obj,version)
			out=input('---> Do you want to delete the previous install? -- ','s');
			if regexpi(out,'(yes|y)') %%% Clean install
				cd(obj.installLocation);
				switch version
					case 'spikes'
						[status,values]=system(['rm -rf ' obj.spikesName]);
						if status ~= 0;obj.salutation(['Argh, couldn''t delete old install! - ' values]);end
						[status,values]=system(['mkdir -p ' obj.installLocation]);
						if status ~= 0;obj.salutation(['Couldn''t make install directory! - ' values]);end
						[status,values]=system([obj.bzrLocation ' ' obj.checkoutCommand ' ' obj.spikesSource ' ' obj.installLocation obj.spikesName]);
						if status ~= 0;obj.salutation(['Couldn''t branch spikes! - ' values]);else obj.salutation(['Success: ' values]);end
						obj.addToPath(fullfile(obj.installLocation,obj.spikesName));
					case 'opticka'
						[status,values]=system(['rm -rf ' obj.optickaName]);
						if status ~= 0;obj.salutation(['Argh, couldn''t delete old install! - ' values]);end
						[status,values]=system(['mkdir -p ' obj.installLocation]);
						if status ~= 0;obj.salutation(['Argh, couldn''t make install directory! - ' values]);end
						[status,values]=system([obj.bzrLocation ' ' obj.checkoutCommand ' ' obj.optickaSource ' ' obj.installLocation obj.optickaName]);
						if status ~= 0;obj.salutation(['Argh, couldn''t branch opticka! - ' values]);else obj.salutation(['Success: ' values]);end
						obj.addToPath(fullfile(obj.installLocation,obj.optickaName));
				end
			else
				cd(obj.installLocation);
				switch version
					case 'spikes'
						cd(obj.spikesName);
						[status,values]=system([obj.bzrLocation ' pull ' obj.spikesSource]);
						if status ~= 0;obj.salutation(['Couldn''t update directory! - ' values]);end
						obj.salutation(values);
						if regexpi(values,'These branches have diverged')
							obj.salutation('You will need to manually merge this local and remote trees, please ask Ian for more information!')
							system([obj.bzrLocation ' explorer ']);
						end
						obj.addToPath(fullfile(obj.installLocation,obj.spikesName));
					case 'opticka'
						cd(obj.optickaName);
						[status,values]=system([obj.bzrLocation ' pull ' obj.optickaSource]);
						if status ~= 0;obj.salutation(['Couldn''t update opticka directory! - ' values]);end
						obj.salutation(values);
						if regexpi(values,'These branches may have diverged')
							obj.salutation('You will need to manually merge this local and remote trees, please ask Ian for more information!')
							system([obj.bzrLocation ' explorer ']);
						end
						obj.addToPath(fullfile(obj.installLocation,obj.optickaName));
				end
			end
		end
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
		
		function purgepath(obj,version) %this will strip out anything that matches spikes in its path.
			p = path;
			switch version
				case 'spikes'
					fragment = regexp(p,['(?<spath>/[^' filesep ']*spikes[^' pathsep ']*' filesep ')'],'names');
				case 'opticka'
					fragment = regexp(p,['(?<spath>/[^' filesep ']*opticka[^' pathsep ']*' filesep ')'],'names');
			end
			rmpth='';
			if ~isempty(fragment)
				for i=1:length(fragment)
					rmpth=strcat(rmpth,fragment(i).spath);
				end
			end
			if ~isempty(rmpth)
				rmpath(rmpth);
			end
		end
		
		function parsepath(obj) %
			oldpath = path;
			
		end
		
		function p=genpath(obj,d) %modified to allow exclusion of 
			addtospikepath=0;
			exclstart = '^(\.|\.\.|@|+|\.bzr|\.svn|\.git)';
			exclpath = '(VSX|VSS|c_sources|licence|private)';
			p = '';
			
			if ~exist('d','var')
				addtospikepath=1;
				d = [obj.installLocation obj.spikesName];
			end
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
			if addtospikepath==1
				obj.spikesPath = p;
			end
		end
	end %---END PRIVATE METHODS---%
end