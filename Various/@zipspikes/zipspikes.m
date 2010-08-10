classdef zipspikes < handle
% Spikes data ZIP read/write class

	properties
		name='Zipspike file'
		action='check'
		hash=0
		sourcepath=''
		destpath=''
		tmp=''
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
						
			if obj.hash==0 %make a random hash with which to create a directory
				obj.hash=num2str(round(rand*1000000));
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
				obj.action='load';
				obj.sourcepath = args;
			end
			
			if isempty(obj.sourcepath)
				[f,p]=uigetfile({'*.zip;*.gz','Archives (*.zip;*.gz)';'*.*',  'All Files (*.*)'},'Please select a compressed archive:');
				obj.sourcepath=[p,f];
			end
			
			switch obj.arch
				case 'OSX'
					if isempty(obj.tmp) 
						obj.tmp=['/private/tmp/matlab/zipspike/'];
					end
					if ~exist([obj.tmp obj.hash],'dir')
						mkdir([obj.tmp obj.hash]);
					end
					obj.destpath = [obj.tmp obj.hash filesep];
				case 'WIN'
					obj.tmp=getenv('temp');
			end
				
			switch obj.action
				case 'load'
					obj.readarchive('callfromswitch')
				case 'check'
					obj.check('callfromswitch')
				case 'info'
					obj.check('callfromswitch')
				case 'clearcache'
					obj.clearcache
				otherwise
					obj.check('callfromswitch')
			end
			obj.salutation('Finished running zipspikes...');
		end

		function readarchive(obj,~)
			%Class method to read a Zipped spikes file and get out the data to pass to
			%spikes
			olddir=pwd;
			[p,f,e]=fileparts(obj.sourcepath);
			cd(obj.destpath);
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