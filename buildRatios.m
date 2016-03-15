classdef buildRatios < handle
	%Burst tonic analysis
	properties
		data
		comment = ''
	end
	
	properties (SetAccess = private, GetAccess = public, Dependent = true)
		runs = 0
	end
	properties (SetAccess = private, GetAccess = public)
		varNames = {'id','Cell_Name','Spikes_Name','Raw_Values','Mean','Median', 'Condition', 'X_Y','ON_OFF','Effect','rowN','Comments'}
	end
	
	methods
		% ===================================================================
		%> @brief Constructor
		%>
		%> @param varargin
		%> @return
		% ===================================================================
		function me = buildRatios(varargin)
			
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param varargin
		%> @return
		% ===================================================================
		function addRow(me, input, id, cellName, Condition, XorY, ONorOFF,Effect,Comments)
			if iscell(input) && length(input) == 2
				if ~exist('id','var') || isempty(id)
					id = NaN;
				end
				if ~exist('cellName','var') || isempty(cellName)
					cellName = 'unknown';
				end
				if ~exist('Condition','var') || isempty(Condition)
					Condition = 'control';
				end
				if ~exist('XorY','var') || isempty(XorY)
					XorY = 'unknown';
				end
				if ~exist('ONorOFF','var') || isempty(ONorOFF)
					ONorOFF = 'unknown';
				end
				if ~exist('Effect','var') || isempty(Effect)
					Effect = 'n';
				end
				rowN = me.runs+1;
				if ~exist('Comments','var') || isempty(Comments)
					Comments = '';
				end
				mn = mean(input{2});
				md = median(input{2});
				in = {id cellName input{1} input{2} mn md Condition XorY ONorOFF Effect rowN Comments};
				if isempty(me.data)
					me.data = cell2table(in,'VariableNames',me.varNames);
					me.data.Condition = categorical(me.data.Condition);
					me.data.X_Y = categorical(me.data.X_Y);
					me.data.ON_OFF = categorical(me.data.ON_OFF);
					me.data.Effect = categorical(me.data.Effect);
				else
					t = cell2table(in,'VariableNames',me.varNames);
					me.data = [me.data;t];
				end
			end
			tail(me);
		end
	
		% ===================================================================
		%> @brief 
		%>
		%> @param varargin
		%> @return
		% ===================================================================
		function modifyRow(me, rowNin, rawData, id, cellName, Condition, XorY, ONorOFF, Effect, Comments)
			if nargin < 2; disp('===>>> Input: rowNs, rawData, id, cellName, Condition, XorY, ONorOFF, Effect, Comments');return;end
			if max(rowNin) > me.runs
				disp('===>>> No such data row exists!');
				return;
			end
			for rowN = rowNin
				if exist('rawData','var') && ~isempty(rawData) && iscell(rawData) 
					mn = mean(rawData{2});
					md = median(rawData{2});
					me.data{rowN,'Spikes_Name'} = rawData(1);
					me.data{rowN,'Raw_Values'} = rawData{2};
					me.data{rowN,'Mean'} = mn;
					me.data{rowN,'Median'} = md;
				end
				if exist('id','var') && ~isempty(id) && isnumeric(id)
					me.data{rowN,'id'} = id;
				end
				if exist('cellName','var') && ~isempty(cellName)
					me.data{rowN,'Cell_Name'} = {cellName};
				end
				if exist('Condition','var') && ~isempty(Condition)
					if ischar(Condition);Condition={Condition};end
					me.data{rowN,'Condition'} = Condition;
				end
				if exist('XorY','var') && ~isempty(XorY)
					if ischar(XorY);XorY={XorY};end
					me.data{rowN,'X_Y'} = XorY;
				end
				if exist('ONorOFF','var') && ~isempty(ONorOFF)
					if ischar(ONorOFF);ONorOFF={ONorOFF};end
					me.data{rowN,'ON_OFF'} = ONorOFF;
				end
				if exist('Comments','var') && ~isempty(Comments)
					if ischar(Comments);Comments={Comments};end
					me.data{rowN,'Comments'} = Comments;
				end
				if exist('Effect','var') && ~isempty(Effect)
					if ischar(Effect);Effect={Effect};end
					me.data{rowN,'Effect'} = Effect;
				end
			end
			tail(me);
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param varargin
		%> @return
		% ===================================================================
		function summary(me)
			format compact
			summary(me.data)			
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param varargin
		%> @return
		% ===================================================================
		function tail(me)
			format compact;
			me.data(end-6:end,:)	
		end
		% ===================================================================
		%> @brief 
		%>
		%> @param varargin
		%> @return
		% ===================================================================
		function runs = get.runs(me)
			runs = height(me.data);
		end
		
	end
end