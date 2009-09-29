classdef dataConnection < handle
	%dataConnection Allows send/recieve over Ethernet
	%   This uses the TCP/UDP library to manage connections between servers
	%   and clients in Matlab
	
	properties
		type = 'Client'
		port = '5555'
	end
	
	properties (SetAccess = private, GetAccess = private)
		conn = []
	end
	
	methods
		function obj = dataConnection(args)
			
		end
	end
	
end

