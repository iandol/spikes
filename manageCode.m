% ========================================================================
%> @brief MANAGECODE INTERFACES TO CHECK SPIKES AND OPTICKA ARE UP-TO-DATE
%>
%> manageCode probes the system for installed versions of opticka and
%> spikes, and allows updating and path management.
%>
% ========================================================================
classdef manageCode < handle
	properties %------------------PUBLIC PROPERTIES--------------%
		action='check'
		branch='main'
		installLocation='~/Code/'
		spikesName='spikes'
		optickaName = 'opticka'
		checkoutCommand='branch'
		updateCommand = 'pull --overwrite'
		rmCommand = 'rm -rf'
		mkdirCommand = 'mkdir -p'
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
		srcSpikesInfo = ''
		srcSpikesRevNo = 0
		srcOptickaInfo = ''
		srcOptickaRevNo = 0
		bzrInfo = ''
	end
	properties (SetAccess = private, GetAccess = private) %---PRIVATE PROPERTIES---%
		hasBzr = 0
		uihandle = []
		h = []
		isSpikes = 0
		isOpticka = 0
		arch = 'OSX'
		allowedProperties = '(action|branch|installLocation|checkoutCommand|spikesName|optickaName|bzrLocation|spikesSource|optickaSource|verbose)'
	end
	methods %------------------PUBLIC METHODS--------------%
		
		% ===================================================================
		%> @brief Class constructor
		%>
		%> More detailed description of what the constructor does.
		%>
		%> @param args are passed as a structure of properties which is
		%> parsed.
		%> @return instance of labJack class.
		% ===================================================================
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
					obj.installLocation='C:\MatlabFiles\Code\';
					obj.bzrLocation='bzr.exe';
					obj.rmCommand = 'rmdir /s /q';
					obj.mkdirCommand = 'mkdir';
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
			obj.initialiseUI;
		end

		%====Check if things are installed or not====%
		function check(obj,~)
			obj.hasBzr = 0;
			obj.isSpikes = 0;
			obj.isOpticka = 0;
			
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
            
			%work out what our remote versions are
			obj.salutation('Am now going to see what the latest versions are on the server...');
			[status,obj.srcSpikesInfo]=system([obj.bzrLocation ' log -r -1 ' obj.spikesSource]);
			if status ~= 0
				obj.salutation(['Bzr can''t find remote spikes source']);
			else
				srcSpikesRevNo=regexp(obj.srcSpikesInfo,'revno: (\d)+','tokens'); %Get revision number
				obj.srcSpikesRevNo=srcSpikesRevNo{1}{1};
				if obj.verbose == 1
					obj.salutation
					obj.salutation('REMOTE Spikes Info:');
					obj.salutation(obj.srcSpikesInfo);
				else
					obj.salutation(['Remote Spikes version is: ' obj.srcSpikesRevNo])
				end
			end
			[status,obj.srcOptickaInfo]=system([obj.bzrLocation ' log -r -1 ' obj.optickaSource]);
			if status ~= 0
				obj.salutation(['Bzr can''t find remote opticka source']);
			else
				srcOptickaRevNo=regexp(obj.srcOptickaInfo,'revno: (\d)+','tokens'); %Get revision number
				obj.srcOptickaRevNo=srcOptickaRevNo{1}{1};
				if obj.verbose == 1
					obj.salutation
					obj.salutation('REMOTE Opticka Info:');
					obj.salutation(obj.srcOptickaInfo);
				else
					obj.salutation(['Remote Spikes version is: ' obj.srcOptickaRevNo])
				end
			end
			
			
			%Now lets see if we have a newer version to tell the user
		end

		%========Install spikes toolbox=======%
		function install(obj,version)
			switch version
				case 'spikes'
					if obj.hasBzr && obj.isSpikes %%% We need to upgrade
						obj.update('spikes');
					elseif obj.hasBzr==1 && obj.isSpikes==0
						if ~exist(obj.installLocation,'dir')
							[status,values]=system([obj.mkdirCommand ' ' obj.installLocation]);
							if status ~= 0;obj.salutation(['Couldn''t make root install directory! - ' values]);end
						end
						if ~exist([obj.installLocation obj.spikesName],'dir')
							[status,values]=system([obj.mkdirCommand ' ' [obj.installLocation obj.spikesName]]);
							if status ~= 0;obj.salutation(['Couldn''t make install directory! - ' values]);end
						else
							out=input('---> Spikes directory exists but there is no proper install, delte it? -- ','s');
							if regexpi(out,'(yes|y)') %%% Clean install
								[status,values]=system([obj.rmCommand ' ' [obj.installLocation obj.spikesName]]);
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
							[status,values]=system([obj.mkdirCommand ' ' obj.installLocation]);
							if status ~= 0;obj.salutation(['Couldn''t make root install directory! - ' values]);end
						end
						if ~exist([obj.installLocation obj.optickaName],'dir')
							[status,values]=system([obj.mkdirCommand ' ' [obj.installLocation obj.optickaName]]);
							if status ~= 0;obj.salutation(['Couldn''t make opticka install directory! - ' values]);end
						else
							out=input('---> Opticka directory exists but there is no proper install, delte it? -- ','s');
							if regexpi(out,'(yes|y)') %%% Clean install
								[status,values]=system([obj.rmCommand ' ' [obj.installLocation obj.optickaName]]);
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
		
		%=====Purge path======%
		function purge(obj,version,automatic) %#ok<INUSD>
			if exist('automatic','var')
				obj.purgepath(version)
			else
				out=input('---> Do you want to purge the path? -- ','s');
				if regexpi(out,'(yes|y)') %%% Clean install
					obj.purgepath(version)
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
		
		%===================
		function initialiseUI(obj)
			obj.uihandle = manageCode_ui;
			obj.h=guidata(obj.uihandle);
			obj.refreshUI;
		end
		
		function refreshUI(obj)
			v=get(obj.h.mCCodebase,'Value');
			s=get(obj.h.mCCodebase,'String');
			s=s{v};
			switch s
				case 'spikes'
					set(obj.h.mCLocalVersion,'String',num2str(obj.revNoSpikes))
					set(obj.h.mCRemoteVersion,'String',num2str(obj.srcSpikesRevNo))
				case 'opticka'
					set(obj.h.mCLocalVersion,'String',num2str(obj.revNoOpticka))
					set(obj.h.mCRemoteVersion,'String',num2str(obj.srcOptickaRevNo))
			end
		end
		
		%=====Update toolbox======%		
		function update(obj,version)
			out=input('---> Do you want to delete the previous install? -- ','s');
			if regexpi(out,'(yes|y)') % -- Clean install
				cd(obj.installLocation);
				switch version
					case 'spikes'
						[status,values]=system([obj.rmCommand ' ' obj.spikesName]);
						if status ~= 0;obj.salutation(['Argh, couldn''t delete old install! - ' values]);end
						[status,values]=system([obj.mkdirCommand ' ' obj.installLocation]);
						if status ~= 0;obj.salutation(['Couldn''t make install directory! - ' values]);end
						[status,values]=system([obj.bzrLocation ' ' obj.checkoutCommand ' ' obj.spikesSource ' ' obj.installLocation obj.spikesName]);
						if status ~= 0;obj.salutation(['Couldn''t branch spikes! - ' values]);else obj.salutation(['Success: ' values]);end
						obj.addToPath(version);
					case 'opticka'
						[status,values]=system([obj.rmCommand ' ' obj.optickaName]);
						if status ~= 0;obj.salutation(['Argh, couldn''t delete old install! - ' values]);end
						[status,values]=system([obj.mkdirCommand ' ' obj.installLocation]);
						if status ~= 0;obj.salutation(['Argh, couldn''t make install directory! - ' values]);end
						[status,values]=system([obj.bzrLocation ' ' obj.checkoutCommand ' ' obj.optickaSource ' ' obj.installLocation obj.optickaName]);
						if status ~= 0;obj.salutation(['Argh, couldn''t branch opticka! - ' values]);else obj.salutation(['Success: ' values]);end
						obj.addToPath(version);
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
						obj.addToPath(version);
					case 'opticka'
						cd(obj.optickaName);
						[status,values]=system([obj.bzrLocation ' pull ' obj.optickaSource]);
						if status ~= 0;obj.salutation(['Couldn''t update opticka directory! - ' values]);end
						obj.salutation(values);
						if regexpi(values,'These branches may have diverged')
							obj.salutation('You will need to manually merge this local and remote trees, please ask Ian for more information!')
							system([obj.bzrLocation ' explorer ']);
						end
						obj.addToPath(version);
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
				switch d
					case 'spikes'
						addpath(obj.spikesPath,'-begin');
					case 'opticka'
						addpath(obj.optickaPath,'-begin');
				end
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
					fragment = regexp(p,['(?<spath>[^' pathsep ']*Code' filesep 'spikes[^' pathsep ']*' pathsep ')'],'names');
				case 'opticka'
					fragment = regexp(p,['(?<spath>[^' pathsep ']*Code' filesep 'opticka[^' pathsep ']*' pathsep ')'],'names');
			end
			rmpth='';
			if ~isempty(fragment)
				for i=1:length(fragment)
					rmpth=strcat(rmpth,fragment(i).spath);
				end
			end
			
			%now clean-up CVS junk
			fragment = '';
			fragment = regexp(p,['(?<spath>[^' pathsep ']*\.(svn|git|bzr|xcodeproj)[^' pathsep ']*' pathsep ')'],'names');
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
			exclpath = '(VSX|VSS|c_sources|licence|private|photodiode)';
			p = '';
			
			if ~exist('d','var')
				addtospikepath=1;
				d = [obj.installLocation obj.spikesName];
			end
			
			switch d
				case 'spikes'
					d = [obj.installLocation obj.spikesName];
					update='spikes';
				case 'opticka'
					d = [obj.installLocation obj.optickaName];
					update='opticka';
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
			if exist('update','var')
				switch update
					case 'spikes'
						obj.spikesPath = p;
					case 'opticka'
						obj.optickaPath = p;
				end
			end
		end
	end %---END PRIVATE METHODS---%
end