classdef FGMeta < handle
	
	properties
		verbose	= true
	end
	
	properties (SetAccess = private, GetAccess = public)
		cells@cell
		list@cell
		mint@double
		maxt@double
		deltat@double
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
		function add(obj,varargin)
			[file,path]=uigetfile('*.mat','Meta-Analysis:Choose OPro source File','Multiselect','on');
			if ~exist('file','var')
				errordlg('No File Specified', 'Meta-Analysis Error')
			end
	
			cd(path);
			if ischar(file)
				file = {file};
			end
			
			tic
			for ll = 1:length(file)
			
				load(file{ll});
			
				idx = obj.nCells+1;

				for i = 1:2
					obj.cells{idx,i}.name = o.(['cell' num2str(i) 'names']){1};
					obj.cells{idx,i}.time = o.(['cell' num2str(i) 'time']){1};
					obj.cells{idx,i}.psth = o.(['cell' num2str(i) 'psth']){1};
					obj.cells{idx,i}.mean_fine = o.(['bars' num2str(i)]){1}.mean_fine;
					obj.cells{idx,i}.time_fine = o.(['bars' num2str(i)]){1}.time_fine;
				end

				obj.mint = [obj.mint obj.cells{idx,1}.time(1)];
				obj.maxt = [obj.maxt obj.cells{idx,1}.time(end)];
				obj.deltat = [obj.deltat max(diff(obj.cells{idx,1}.time(1)))];

				t = [obj.cells{idx,1}.name '>>>' obj.cells{idx,2}.name];
				t = regexprep(t,'[\|\s][\d\-\.]+','');
				t = [file{ll} ':' t];
				obj.list{idx} = t;

				set(obj.handles.list,'String',obj.list);

				set(obj.handles.list,'Value',obj.nCells);

				replot(obj);

				clear o
			
			end
			
			fprintf('Cell loading took %.5g seconds\n',toc)
			
		end
		
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function replot(obj,varargin)
			if obj.nCells > 0
				
				
				sel = get(obj.handles.list,'Value');
				axes(obj.handles.axis1);
				cla
				plot(obj.cells{sel,1}.time,obj.cells{sel,1}.psth,'k-o');
				hold on
				plot(obj.cells{sel,2}.time,obj.cells{sel,2}.psth,'r-o');
				hold off
				title('Selected Cell')
				xlabel('Time (ms)')
				ylabel('Firing Rate (Hz)')

				[psth1,psth2,time]=computeAverage(obj);
				p1out = mean(psth1);
				p2out = mean(psth2);
				p1err = stderr(p1out,'SE',true);
				p2err = stderr(p2out,'SE',true);
				axes(obj.handles.axis2);
				cla
				areabar(time,p1out,p1err,[0.7 0.7 0.7],'k-o','MarkerFaceColor',[0 0 0]);
				hold on
				areabar(time,p2out,p2err,[1 0.7 0.7],'r-o','MarkerFaceColor',[1 0 0]);
				title('Population PSTH')
				xlabel('Time (ms)')
				ylabel('Firing Rate (normalised)')
			
			end
			
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function load(obj,varargin)
			
			[file,path]=uigetfile('*.mat','Meta-Analysis:Choose MetaAnalysis');
			if ~ischar(file)
				errordlg('No File Specified', 'Meta-Analysis Error');
			end
			
			cd(path);
			load(file);
			if exist('fgmet','var') && isa(fgmet,'FGMeta')
				reset(obj);
				obj.cells = fgmet.cells;
				obj.list = fgmet.list;
				obj.mint = fgmet.mint;
				obj.maxt = fgmet.maxt;
				obj.deltat = fgmet.deltat;
				set(obj.handles.list,'String',obj.list);
				set(obj.handles.list,'Value',obj.nCells);
				replot(obj);
			end
			
			clear fgmet
			
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
		function remove(obj,varargin)
			
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function save(obj,varargin)
			[file,path] = uiputfile('*.mat','Save Meta Analysis:');
			if ~ischar(file)
				errordlg('No file selected...')
			end
			obj.oldDir = pwd;
			cd(path);
			fgmet = obj;
			save(file,'fgmet');
			clear fgmet;
			cd(obj.oldDir);
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function spawn(obj,varargin)
			h = figure;
			figpos(1,[1000 800]);
			set(h,'Color',[1 1 1]);
			hh = copyobj(obj.handles.axis2,h);
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
			reset(obj);
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
		function [psth1,psth2,time]=computeAverage(obj)
			
			time = [];
			psth1 = [];
			psth2 = [];
			
			mint = min(obj.mint);
			maxt = min(obj.maxt);
			
			
			for idx = 1:obj.nCells
				time = obj.cells{idx,1}.time;
				
				tidx = find(time == maxt);
				time = time(1:tidx);
				
				lst = {'psth'};
				for i = 1:length(lst)
					max1 = max(obj.cells{idx,1}.(lst{i}));
					max2 = max(obj.cells{idx,2}.(lst{i}));
					if get(obj.handles.normalisecells,'Value') == 0
						maxx = max([max1 max2]);
						psth1tmp = obj.cells{idx,1}.(lst{i}) / maxx;
						psth2tmp = obj.cells{idx,2}.(lst{i}) / maxx;
					else
						psth1tmp = obj.cells{idx,1}.(lst{i}) / max1;
						psth2tmp = obj.cells{idx,2}.(lst{i}) / max2;
					end
				end
				
				psth1tmp = psth1tmp(1:tidx);
				psth2tmp = psth2tmp(1:tidx);
				
				if isempty(psth1)
					psth1 = psth1tmp;
					psth2 = psth2tmp;
				else
					psth1 = [psth1;psth1tmp];
					psth2 = [psth2;psth2tmp];
				end
				
			end
			
			time = time - 200;
			
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
			handles.controls1.RowSizes = [-1 -1];
			handles.controls2 = uiextras.Grid('Parent', handles.controls,'Padding',5,'Spacing',0,'BackgroundColor',bgcolor);
			handles.controls3 = uiextras.Grid('Parent', handles.controls,'Padding',5,'Spacing',0,'BackgroundColor',bgcolor);
			handles.controls3.RowSizes = [-1 -1];
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
			handles.removebutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGremovebutton',...
				'Callback',@obj.remove,...
				'String','Remove');
			handles.replotbutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGreplotbutton',...
				'Callback',@obj.replot,...
				'String','Replot');
			handles.resetbutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGreplotbutton',...
				'Callback',@obj.reset,...
				'String','Reset');
			handles.list = uicontrol('Style','listbox',...
				'Parent',handles.controls2,...
				'Tag','FGlistbox',...
				'Callback',@obj.replot,...
				'Max',100,...
				'FontSize',13,...
				'String',{});
			handles.normalisecells = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGnormalisecells',...
				'String','Independent Norm?');

			set(handles.hbox,'Sizes', [-2 -1]);
			set(handles.controls,'Sizes', [50 -10 -1]);

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