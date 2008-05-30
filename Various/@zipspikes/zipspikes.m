classdef zipspikes
% Spikes data ZIP read/write class

properties
	name='Zipspike file';
	path=uigetfile;
end

methods
	function data = readfile(zs)
		%Class method to read a Zipped spikes file and get out the data to pass to
		%spikes

		%set up OS parameters
		if strcmp(getenv('OSTYPE'),'darwin8.0')
			OS='mac';
			tmp='/private/tmp/matlab/';
		else
			OS='win';
			tmp=getenv('temp');
		end

		olddir=pwd;
		[p,f,e]=fileparts(zs.path);
		switch e
			case '.zip'
				cd(tmp);
				mkdir(f);
				cd(f);
				unzip(zs.path);
			case '.smr'
				
			case '.txt.'
				
			otherwise
		end

		cd(olddir)
	end
	function display(zs)
		% COLOUR/DISPLAY
		disp('ZipSpike Object');
		disp(' ');
		disp([inputname(1),' = '])
		disp(' ');
		disp(['Name: ' zs.name ' | Path: ' zs.path])
		disp(' ');
	end
end

end