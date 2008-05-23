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
	otherwise
end

cd(olddir)


