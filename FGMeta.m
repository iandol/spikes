classdef FGMeta < handle
	
	properties
		verbose	= true
	end
	
	properties (SetAccess = private, GetAccess = public)
		cells@cell
		list@cell
		mint@double
		maxt@double
		version@double = 1.01
		mtime@double
		mpsth@double
		merror@double
		
	end
	
	properties (SetAccess = protected, GetAccess = public, Transient = true)
		%> handles for the GUI
		handles@struct
		openUI@logical = false
	end
	
	properties (Dependent = true, SetAccess = private, GetAccess = public)
		nCells
	end
	
	properties (SetAccess = private, GetAccess = private)
		oldDir@char
	end
	
	%=======================================================================
	methods %------------------PUBLIC METHODS
	%=======================================================================

		% ===================================================================
		%> @brief Constructor
		%>
		%> @param varargin
		%> @return
		% ===================================================================
		function obj=FGMeta(varargin)
			makeUI(obj);
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function load(obj,varargin)
			reset(obj);
			
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function save(obj,varargin)
			[file,path] = uiputfile('*.mat','Save Meta Analysis:');
			obj.oldDir = pwd;
			cd(path);
			fgmet = obj;
			save(file,fgmet);
			clear fgmet;
			cd(obj.oldPath);
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function add(obj,varargin)
			[file,path]=uigetfile('*.mat','Meta-Analysis:Choose OPro source File');
			if ~file
				errordlg('No File Specified', 'Meta-Analysis Error')
			end
			tic
			cd(path);
			load(file);
			
			idx = obj.nCells+1;
			
			for i = 1:2
				obj.cells{idx,i}.name = o.(['cell' num2str(i) 'names']){1};
				obj.cells{idx,i}.time = o.(['cell' num2str(i) 'time']){1};
				obj.cells{idx,i}.psth = o.(['cell' num2str(i) 'psth']){1};
				obj.cells{idx,i}.mean_fine = o.(['bars' num2str(i)]){1}.mean_fine;
				obj.cells{idx,i}.time_fine = o.(['bars' num2str(i)]){1}.time_fine;
			end
			
			lst = {'psth';'mean_fine'};
			for i = 1:length(lst)
				max1 = max(obj.cells{idx,1}.(lst{i}));
				max2 = max(obj.cells{idx,2}.(lst{i}));
				maxx = max([max1 max2]);

				obj.cells{idx,1}.(lst{i}) = obj.cells{idx,1}.(lst{i}) / maxx;
				obj.cells{idx,2}.(lst{i}) = obj.cells{idx,2}.(lst{i}) / maxx;
			end
			obj.mint = [obj.mint obj.cells{idx,1}.time(1)];
			obj.maxt = [obj.maxt obj.cells{idx,1}.time(end)];
			
			t = [obj.cells{idx,1}.name '>>>' obj.cells{idx,2}.name];
			t = regexprep(t,'[\|\s][\d\-\.]+','');
			t = [file ':' t];
			obj.list{idx} = t;
			
			set(obj.handles.list,'String',obj.list);
			
			fprintf('Cell loading took %.2g seconds\n',toc)
			
			set(obj.handles.list,'Value',obj.nCells)
			
			replot(obj);
			
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function reset(obj,varargin)
			set(obj.handles.list,'Value',1);
			set(obj.handles.list,'String',{''});
			obj.handles.axistabs.SelectedChild=1;
			axes(obj.handles.axis1);
			cla
			axes(obj.handles.axis2);
			cla
			obj.cells = cell(1);
			obj.list = cell(1);
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function replot(obj,varargin)
			sel = get(obj.handles.list,'Value');
			obj.handles.axistabs.SelectedChild=1;
			axes(obj.handles.axis1);
			cla
			plot(obj.cells{sel,1}.time,obj.cells{sel,1}.psth,'k-o');
			hold on
			plot(obj.cells{sel,2}.time,obj.cells{sel,2}.psth,'r-o');
			hold off
			title('Selected Cell')
			xlabel('Time (ms)')
			ylabel('Firing Rate')
			
			computeAverage(obj);
			
			%obj.handles.axistabs.SelectedChild=2;
			
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function spawn(obj,varargin)
			
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function value = get.nCells(obj)
			value = length(obj.list);
			if isempty(value)
				value = 0;
				return
			elseif value == 1 && iscell(obj.list) && isempty(obj.list{1})
				value = 0;
			end
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function quit(obj,varargin)
			reset(obj)
			closeUI(obj);
		end
		
	end%-------------------------END PUBLIC METHODS--------------------------------%
	
	%=======================================================================
	methods (Access = private) %------------------PRIVATE METHODS
	%=======================================================================
	
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function computeAverage(obj)
			
		end
	
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function makeUI(obj)
			if ~isempty(obj.handles) && isfield(obj.handles,'root') && isa(obj.handles.root,'uiextras.BoxPanel')
				fprintf('---> UI already open!\n');
				return
			end

			if ~exist('parent','var')
				parent = figure('Tag','FGMeta',...
					'Name', ['Figure Ground Meta Analysis V' num2str(obj.version)], ...
					'MenuBar', 'none', ...
					'CloseRequestFcn', @obj.quit,...
					'NumberTitle', 'off');
				figpos(1,[1000 600])
			end

			bgcolor = [0.85 0.85 0.85];
			bgcoloredit = [0.87 0.87 0.87];

			handles.parent = parent;
			handles.root = uiextras.BoxPanel('Parent',parent,...
				'Title',['Figure Ground Meta Analysis V' num2str(obj.version)],...
				'FontName','Helvetica',...
				'FontSize',11,...
				'FontWeight','normal',...
				'Padding',0,...
				'TitleColor',[0.8 0.78 0.76],...
				'BackgroundColor',bgcolor);

			handles.hbox = uiextras.HBoxFlex('Parent', handles.root,'Padding',0,'Spacing',0,'BackgroundColor',bgcolor);
			handles.axistabs = uiextras.TabPanel('Parent', handles.hbox,'Padding',0,'BackgroundColor',bgcolor,'TabSize',100);
			handles.axisall = uiextras.Panel('Parent', handles.axistabs,'Padding',0,'BackgroundColor',bgcolor);
			handles.axisind = uiextras.Panel('Parent', handles.axistabs,'Padding',0,'BackgroundColor',bgcolor);
			handles.axistabs.TabNames = {'Individual Plots','Population Plot'};
			handles.axis1= axes('Parent',handles.axisall,'Tag','FGMetaAxis');
			handles.axis2= axes('Parent',handles.axisind,'Tag','FGMetaAxis');

			handles.controls = uiextras.VBox('Parent', handles.hbox,'Padding',0,'Spacing',0,'BackgroundColor',bgcolor);
			handles.controls1 = uiextras.Grid('Parent', handles.controls,'Padding',5,'Spacing',0,'BackgroundColor',bgcolor);
			handles.controls2 = uiextras.Grid('Parent', handles.controls,'Padding',5,'Spacing',0,'BackgroundColor',bgcolor);
			handles.controls3 = uiextras.Grid('Parent', handles.controls,'Padding',5,'Spacing',0,'BackgroundColor',bgcolor);
			handles.loadbutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGloadbutton',...
				'Callback',@obj.load,...
				'String','Load');
			handles.savebutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGsavebutton',...
				'Callback',@obj.save,...
				'String','Save');
			handles.addbutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGaddbutton',...
				'Callback',@obj.add,...
				'String','Add Data');
			handles.spawnbutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGspawnbutton',...
				'Callback',@obj.spawn,...
				'String','Spawn');
			handles.list = uicontrol('Style','listbox',...
				'Parent',handles.controls2,...
				'Tag','FGlistbox',...
				'Callback',@obj.replot,...
				'Max',100,...
				'FontSize',13,...
				'String',{});

			set(handles.hbox,'Sizes', [-2 -1]);
			set(handles.controls,'Sizes', [30 -10 -1]);

			obj.handles = handles;
			obj.openUI = true;
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function closeUI(obj)
			try; delete(obj.handles.parent); end
			obj.handles = struct();
			obj.openUI = false;
		end
		
	end	
end