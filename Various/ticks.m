function ticks(direc)

if nargin<1
	direc='out';
end

switch direc
	case 'in'
		set(gca,'TickDir','in');
	case 'out'
		set(gca,'TickDir','out');
end