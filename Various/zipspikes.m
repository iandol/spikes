% ========================================================================
%> @brief Zipspikes loads VS smr data from, and to, ZIP files
%> ZIPSPIKES
%>   
% ========================================================================
classdef zipspikes < handle
	
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
		verbose = true
	end
	
	properties (SetAccess = private, GetAccess = private)
		rmCommand = 'rm -rf'
		mkdirCommand = 'mkdir -p'
		arch = 'OSX'
		allowedProperties = '(action|sourcepath|destpath)'
	end
	
	%=======================================================================
	methods %------------------PUBLIC METHODS
	%=======================================================================
	
		% ===================================================================
		%> @brief Class constructor
		%>
		%> More detailed description of what the constructor does.
		%>
		%> @param args are passed as a structure of properties which is
		%> parsed.
		%> @return instance of the class.
		% ===================================================================
		function obj=zipspikes(args) %CONSTRUCTOR
			
			if ispc
				obj.rmCommand = 'rmdir /s /q';
				obj.mkdirCommand = 'mkdir';
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
			
			if isempty(obj.tmppath)
				obj.tmppath = tempname;
			end

			obj.userroot = fileparts(mfilename('fullpath'));
			p=regexp(obj.userroot,['(?<path>^.+\' filesep 'spikes\' filesep ')'],'names');
			obj.userroot = p.path;
			
		end
		
		% ===================================================================
		%> @brief Do the randomisation
		%>
		%> Do the randomisation
		% ===================================================================
		function generate(obj,~)
			
% 			if ismac
% 				error('You can only generate zip files on PC');
% 			end
			
			obj.sourcedir = uigetdir;

			cd(obj.sourcedir)
			d=dir;
			for i = 1:length(d)
				if d(i).isdir && ~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..')
					cd(d(i).name)
					dd=dir;
					for j = 1:length(dd)
						if regexpi(dd(j).name,'smr')
							makeZip(dd(j).name)
						end
					end
					cd(obj.sourcedir)
				elseif regexpi(d(i).name,'smr')
					makeZip(d(i).name)
				end
			end
			
			function makeZip(name)
				tmpname=[obj.sourcedir filesep name];
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
		
		% ===================================================================
		%> @brief Do the randomisation
		%>
		%> Do the randomisation
		% ===================================================================
		function [meta,txtcomment,txtprotocol] = readarchive(obj,~)
			%Class method to read a Zipped spikes file and get out the data to pass to
			%spikes
			olddir=pwd;
			
			if ~exist(obj.tmppath,'dir')
				[status,values]=system([obj.mkdirCommand ' ' obj.tmppath]);
				if status ~= 0;obj.salutation(['Couldn''t make temp install directory! - ' values]);end
			end
			
			[p,f,e]=fileparts(obj.sourcepath);
			
			switch e
				case '.zip'
					unzip(obj.sourcepath,obj.tmppath);
				case '.gz'
					gunzip(obj.sourcepath,obj.tmppath);
				otherwise
			end
			
			meta=loadvstext(strcat(obj.tmppath,filesep,f,filesep,f,'.txt'));
			txtcomment=textread(strcat(obj.tmppath,filesep,f,filesep,f,'.cmt'),'%s','delimiter','\n','whitespace','');
			txtprotocol=textread(strcat(obj.tmppath,filesep,f,filesep,f,'.prt'),'%s','delimiter','\n','whitespace','');
			
		end
	end %---END PUBLIC METHODS---%
	
	%=======================================================================
	methods ( Access = private ) %-------PRIVATE METHODS-----%
	%=======================================================================
		% ===================================================================
		%> @brief Prints messages dependent on verbosity
		%>
		%> Prints messages dependent on verbosity
		%> @param in the calling function
		%> @param message the message that needs printing to command window
		% ===================================================================
		function salutation(obj,in,message)
			if obj.verbose==true
				if ~exist('in','var')
					in = 'undefined';
				end
				if exist('message','var')
					fprintf([message ' | ' in '\n']);
				else
					fprintf(['Zipspikes: ' in '\n']);
				end
			end
		end
	end%---END PRIVATE METHODS---%
end