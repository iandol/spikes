function zs = zipspikes(varargin)
% Spikes data ZIP read/write class
switch nargin
case 0
  % No argument
  zs.name='Zipspike file';
  zs.path=uigetfile;
  zs = class(zs,'zipspikes');
case 1
	if (isa(varargin{1},'zipspikes'))
		display(varargin{1});
	else
		zs.name='Zipspike file';
		zs.path=varargin{1};
		zs = class(zs,'zipspikes');
	end 
case 2
	zs.path=varargin{1};
	zs.name=varargin{2};
	zs = class(zs,'zipspikes');
otherwise
   error('Wrong number of input arguments')
end