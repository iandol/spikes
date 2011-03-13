classdef zipspikes < handle
% Spikes data ZIP read/write class

	properties
		name='Zipspike file'
		action='check'
		hash=0
		sourcepath=''
		destpath=''
		tmppath=''
		tmp=''
		filetype=''
		sourcedir
		userroot
	end
	
	properties (SetAccess = private, GetAccess = private)
		arch = 'OSX'
		allowedProperties = '(action|tmp|sourcepath)'
	end

	methods
		function obj=zipspikes(args) %CONSTRUCTOR

			if regexp(computer,'(MACI|MACI64)')
				obj.arch='OSX';
			else
				obj.arch='WIN';
			end
			
			obj.tmppath = tempname;
						
			if obj.hash==0 %make a random hash with which to create a directory
				obj.hash=num2str(round(rand*1000000));
			end
			
			%start to build our parameters
			if exist('args','var') && isstruct(args)
				fnames = fieldnames(args); %find our argument names
				for i=1:length(fnames);
					if regexp(fnames{i},obj.allowedProperties) %only set if allowed property
						obj.salutation(['Adding ' fnames{i} '|' args.(fnames{i}) ' command...']);
						obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
					end
				end
			end
				
			 obj.userroot = fileparts(mfilename('fullpath'));
			 p=regexp(obj.userroot,['(?<path>^.+\' filesep 'spikes\' filesep ')'],'names');
			 obj.userroot = p.path;
			
			if isempty(obj.sourcepath)
				[f,p]=uigetfile({'*.zip;*.gz','Archives (*.zip;*.gz)';'*.smr','SMR Files (*.smr)';'*.*',  'All Files (*.*)'},'Please select a compressed archive:');
				[obj.sourcedir,~,obj.filetype]=fileparts([p,f]);
				obj.sourcepath=[p,f];
			end
			
			obj.salutation('Finished running zipspikes...');
		end
		
		function generate(obj,~)
			if ismac
				error('You can only generate zip files on PC');
			end
			
			if strcmpi(obj.filetype,'.smr')
				cd(obj.sourcedir)
				d=dir;
				for i = 1:length(d)
					if regexpi(d(i).name,'smr')
						tmpname=[obj.sourcedir filesep d(i).name];
						[p,f,e]=fileparts(tmpname);
						if isdir([p filesep f]) %stops annoying "directory alread exists" messages
							disp('Deleting existing directory...');
							rmdir([p filesep f],'s');
						end
						if exist([f '.zip'],'file')
							delete([f '.zip']);
						end
						[s,w]=dos(['"' obj.userroot 'various\vsx\vsx.exe" "' tmpname '"']);
						if s>0; error(w); end
						zip([obj.sourcedir filesep f '.zip'], {[f '.smr'],f});
						rmdir([p filesep f],'s');
					end
				end
			end
		end

		function readarchive(obj,~)
			%Class method to read a Zipped spikes file and get out the data to pass to
			%spikes
			olddir=pwd;
			[p,f,e]=fileparts(obj.sourcepath);
			cd(obj.tmppath);
			switch e
				case '.zip'
					unzip(obj.sourcepath);
				case '.gz'
					gunzip(obj.sourcepath);			
				otherwise
			end
			cd(olddir)
		end
		
		%%%Check if things are installed or not%%%
		function check(obj,~)
			obj.salutation('Check completed!');
		end
		
		function clearthiscache(obj,~)
			[s,m]=rmdir(obj.destpath,'s')
			if s==1
				obj.salutation('All zipspike temp files cleared!');
			else
				obj.salutation(['Couldn''t clear ' obj.destpath ' | Reason: ' m]);
			end
		end
		
		function clearcache(obj,~)
			[s,m]=rmdir(obj.tmp,'s')
			if s==1
				obj.salutation('All zipspike temp files cleared!');
			else
				obj.salutation(['Couldn''t clear ' obj.tmp ' | Reason: ' m]);
			end
		end
		
% 		function display(obj)
% 			% generic display function
% 			disp('---------------');
% 			disp('ZipSpike Object');
% 			disp('---------------');
% 			disp([inputname(1),' = '])
% 			disp(' ');
% 			disp(['Name: ' obj.name])
% 			disp(['Source Path: ' obj.sourcepath])
% 			disp(['Destination Path: ' obj.destpath])
% 			disp(['Temp Path: ' obj.tmp])
% 			disp(' ');
% 		end
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