classdef zipspikes
% Spikes data ZIP read/write class

properties
	name='Zipspike file';
	sourcepath;
	destpath;
	OS='win';
	tmp;
end

methods
	function zs=zipspikes(varargin) %CONSTRUCTOR
		switch nargin
			case 0
				
			case 1
				zs.name=varargin{1};
				[f,p]=uigetfile;
				zs.sourcepath=[p,f];
			case 2
				zs.name=varargin{1};
				zs.sourcepath=varargin{2};
			case 3
				zs.name=varargin{1};
				zs.sourcepath=varargin{2};
				zs.destpath=varargin{3};
		end
		
		%set up OS parameters
		if strcmp(getenv('OSTYPE'),'darwin8.0')
			zs.OS='mac';
			zs.tmp='/private/tmp/matlab/';
		else
			zs.OS='win';
			zs.tmp=getenv('temp');
		end
	end
	
	function readfile(zs)
		%Class method to read a Zipped spikes file and get out the data to pass to
		%spikes
		olddir=pwd;
		[p,f,e]=fileparts(zs.sourcepath);
		switch e
			case '.zip'
				cd(zs.tmp);
				mkdir(f);
				cd(f);
				unzip(zs.sourcepath);
				zs.destpath = [zs.tmp filesep f];
			case '.gz'
				cd(zs.tmp);
				mkdir(f);
				cd(f);
				gunzip(zs.sourcepath);
				zs.destpath = [zs.tmp filesep f];				
			otherwise
		end
		cd(olddir)
	end
	function display(zs)
		% generic display function
		disp('ZipSpike Object');
		disp(' ');
		disp([inputname(1),' = '])
		disp(' ');
		disp(['Name: ' zs.name])
		disp(['Source Path: ' zs.sourcepath])
		disp(['Destination Path: ' zs.destpath])
		disp(['Temp Path: ' zs.tmp])
		disp(' ');
	end
end

end