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
		pathfilter = '.*'
		sourcedir
		userroot
		verbose = true
		%> do we overwrite zips or skip to next file?
		overwriteZips = false
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
		%> @brief generate
		%>
		%> actually create the zips
		% ===================================================================
		function generate(obj,~)
			
			if ismac
				error('You can only generate zip files on PC');
			end
			obj.sourcedir = uigetdir;
			if obj.sourcedir == 0
				disp('No directory selected')
				return
			end
			cd(obj.sourcedir)
			d=dir;
			for i = 1:length(d)
				name=d(i).name;
				if d(i).isdir && ~isempty(regexpi(name, obj.pathfilter)) && ~strcmp(name,'.') && ~strcmp(name,'..')
					cd(name)
					dd=dir;
					for j = 1:length(dd)
						name2 = dd(j).name;
						if regexpi(name2,'smr$')
							makeZip(name2)
						end
					end
					cd(obj.sourcedir)
				elseif regexpi(name,'smr$')
					makeZip(name)
				end
			end
			
			function makeZip(name)
				doMake = true;
				tmpname=[pwd filesep name];
				fileinf = dir(name);
				if fileinf.bytes == 0
					obj.salutation(['Skipping ' name ' as SMR is empty...']);
				else
					[p,f,e]=fileparts(tmpname);
					if isdir([p filesep f]) %stops annoying "directory alread exists" messages
						disp('Deleting existing directory...');
						rmdir([p filesep f],'s');
					end
					if exist([f '.zip'],'file')
						if obj.overwriteZips == true
							delete([f '.zip']);
						else
							doMake = false; %zip exists and we don't want to remake it
							obj.salutation(['Skipping ' p filesep f ' as zip already exists...']);
						end
					end
					if doMake == true
						[s,w]=dos(['"' obj.userroot 'various\vsx\vsx.exe" "' tmpname '"']);
						if s>0; error(w); end
						zip([pwd filesep f '.zip'], {[f '.smr'],f});
						rmdir([p filesep f],'s');
						obj.salutation(['Zipfile: ' p filesep f '.zip generated']);
					end
				end
			end
		end
		
		% ===================================================================
		%> @brief Find protocol, change name to append it
		%>
		%> medify names
		% ===================================================================
		function modifyNames(obj,dummyRun)
			meta = [];
			if ~exist('dummyRun','var')
				dummyRun = false;
			end
			olddir = pwd;
			obj.sourcedir = uigetdir;
			if obj.sourcedir == 0
				disp('No directory selected')
				return
			end
			cd(obj.sourcedir)
			fid1 = fopen('protocols.txt','w');
			d=dir;
			for i = 1:length(d)
				name=d(i).name;
				if d(i).isdir && ~isempty(regexpi(name, obj.pathfilter)) && ~strcmp(name,'.') && ~strcmp(name,'..')
					cd(name)
					fid2 = fopen('protocols.txt','w');
					dd=dir;
					for j = 1:length(dd)
						name2 = dd(j).name;
						if regexpi(name2,'zip$')
							doMove(name2,dummyRun,fid2,fid1,name);
						end
					end
					fclose(fid2);
					cd(obj.sourcedir)
				elseif regexpi(name,'zip$')
					doMove(name,dummyRun,fid1,[],obj.sourcedir);
				end
				meta = [];
			end
			fclose(fid1);
			cd(olddir);
			
			function doMove(name,dummyRun,fida,fidb,dirname)
				if ~exist('fidb','var')
					fidb = [];
				end
				if ~exist('dirname','var')
					dirname = '';
				end
				[meta,~,~] = obj.readarchive(name, false);
				if ~isempty(meta) && isfield(meta,'protocol')
					[p,f,e]=fileparts(name);
					if isempty(regexpi(f,' -- ','once'));
						newname = [f ' - ' meta.protocol];
						printname = newname;
						newname = [p filesep newname e];
						if dummyRun == false
							obj.salutation(['Renamed: ' newname],name);
							fprintf(fida, [dirname printname '\n']);
							if ~isempty(fidb)
								fprintf(fidb, [dirname printname '\n']);
							end
							movefile(name2,newname);
						else
							obj.salutation(['Dummy Renamed: ' newname],name);
							fprintf(fida, [dirname printname '\n']);
							if ~isempty(fidb)
								fprintf(fidb, [dirname printname '\n']);
							end
						end
					else
						obj.salutation([' Not Renamed: ' name]);
					end
				end
			end
			
		end
		
		% ===================================================================
		%> @brief Read a zip into spikes formatted data
		%>
		%> Class method to read a Zipped spikes file and get out the data to pass to spikes
		% ===================================================================
		function [meta,txtcomment,txtprotocol] = readarchive(obj,myfile,correctValues)
			
			meta = [];
			txtcomment = [];
			txtprotocol = [];
			
			if ~exist('correctValues','var')
				correctValues = true;
			end
			
			if ~exist('myfile','var')
				myfile = obj.sourcepath;
			end
			
			if ~exist(obj.tmppath,'dir')
				[status,values]=system([obj.mkdirCommand ' ' obj.tmppath]);
				if status ~= 0;obj.salutation(['Couldn''t make temp install directory! - ' values]);end
			end
			
			[p,f,e]=fileparts(myfile);
			
			try
				switch lower(e)
					case '.zip'
						unzip(myfile,obj.tmppath);
					case '.gz'
						gunzip(myfile,obj.tmppath);
					otherwise
						return
				end
			catch ME
				disp(getReport(ME))
			end
			
			f = regexprep(f, '\s--\s.*$','');%we need to remove the appended protocol string
			
			if exist(strcat(obj.tmppath,filesep,f,filesep,f,'.txt'),'file')
				try
					meta=loadvstext(strcat(obj.tmppath,filesep,f,filesep,f,'.txt'), correctValues);
					txtcomment=textread(strcat(obj.tmppath,filesep,f,filesep,f,'.cmt'),'%s','delimiter','\n','whitespace','');
					txtprotocol=textread(strcat(obj.tmppath,filesep,f,filesep,f,'.prt'),'%s','delimiter','\n','whitespace','');
				catch ME
					disp(getReport(ME))
				end
			end
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
				if ~exist('message','var')
					message = '';
				end
				in = regexprep(in,'\','/');
				message = regexprep(message,'\','/');
				if isempty(message)
					fprintf(['---> Zipspikes: ' in '\n']);
				else
					fprintf(['---> Zipspikes: ' message ' | ' in '\n']);
				end
			end
		end
	end%---END PRIVATE METHODS---%
end