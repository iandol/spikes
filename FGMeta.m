classdef FGMeta < handle
	
	properties
		verbose	= true
		offset@double = 200
		smoothstep@double = 1
	end
	
	properties (SetAccess = private, GetAccess = public)
		cells@cell
		list@cell
		mint@double
		maxt@double
		deltat@double
		version@double = 1.05
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
				
				if ~exist('o','var')
					errordlg('This file wasn''t an OPro MAT file...')
				end
			
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
				
				set(obj.handles.root,'Title',['Number of Cells Loaded: ' num2str(obj.nCells)]);
				obj.smoothstep = str2double(get(obj.handles.smoothstep,'String'));
				sel = get(obj.handles.list,'Value');
				maxt = obj.maxt(sel) - obj.offset;
				
				if get(obj.handles.selectbars,'Value') == 1
					time = obj.cells{sel,1}.time_fine - obj.offset;
					psth1 = obj.cells{sel,1}.mean_fine;
					psth2 = obj.cells{sel,2}.mean_fine;
					psth1(psth1 > 500) = 500;
					psth2(psth2 > 500) = 500;
				else
					time = obj.cells{sel,1}.time - obj.offset;
					psth1 = obj.cells{sel,1}.psth;
					psth2 = obj.cells{sel,2}.psth;
				end
				
				%make sure our psth is column format
				if size(psth1,1) > size(psth1,2)
					psth1 = psth1';
				end
				if size(psth2,1) > size(psth2,2)
					psth2 = psth2';
				end
				
				if get(obj.handles.smooth,'Value') == 1
					maxtall = max(obj.maxt) - obj.offset;
					s=get(obj.handles.smoothmethod,'String');
					v=get(obj.handles.smoothmethod,'Value');
					s=s{v};
					F1 = griddedInterpolant(time,psth1,s);
					F2 = griddedInterpolant(time,psth2,s);
					time = min(time):obj.smoothstep:maxtall;
					psth1=F1(time);
					psth2=F2(time);
					psth1(psth1 < 0) = 0;
					psth2(psth2 < 0) = 0;
					clear F1 F2;
				end
				
				axes(obj.handles.axis1); cla
				plot(time,psth1,'ko-','MarkerFaceColor',[0 0 0]);
				hold on
				plot(time,psth2,'ro-','MarkerFaceColor',[1 0 0]);
				a=axis;
				line([maxt maxt],[0 a(4)]);
				hold off
				title('Selected Cell')
				xlabel('Time (ms)')
				ylabel('Firing Rate (Hz)')

				[psth1,psth2,time]=computeAverage(obj);
				[~,p1err] = stderr(psth1,'SE');
				[~,p2err] = stderr(psth2,'SE');
				
				s = get(obj.handles.meanmethod,'String');
				v = get(obj.handles.meanmethod,'Value');
				s = s{v};
				switch s
					case 'mean'
						p1out = mean(psth1);
						p2out = mean(psth2);
					case 'median'
						p1out = median(psth1);
						p2out = median(psth2);
					case 'trimmean'
						p1out = trimmean(psth1,10);
						p2out = trimmean(psth2,10);
					case 'geomean'
						p1out = geomean(psth1);
						p2out = geomean(psth2);
					case 'harmmean'
						p1out = harmmean(psth1);
						p2out = harmmean(psth2);
				end
				
				axes(obj.handles.axis2); cla
				areabar(time,p1out,p1err,[0.7 0.7 0.7],0.35,'k-','MarkerFaceColor',[0 0 0]);
				hold on
				areabar(time,p2out,p2err,[1 0.7 0.7],0.35,'r-','MarkerFaceColor',[1 0 0]);
				
				if get(obj.handles.newbars,'Value') == 1
					bp = defaultParams();
					bp.use_logspline = false;
					bp.burn_iter = 100;
					bars1 = barsP(p1out,[time(1)+obj.offset time(end)+obj.offset],10,bp);
					bars2 = barsP(p2out,[time(1)+obj.offset time(end)+obj.offset],10,bp);
					hold on
					plot(time,bars1.mean,'k-.',time,bars1.mode,'k:')
					plot(time,bars2.mean,'r-.',time,bars2.mode,'r:')
				end
				set(obj.handles.newbars,'Value',0)
				
				spontt = find(time<0);
				sp1 = psth1(:,spontt);
				sp2 = psth2(:,spontt);
				sp1 = reshape(sp1,1,numel(sp1));
				sp2 = reshape(sp2,1,numel(sp2));
				ci1 = bootci(1000,{@mean,sp1},'alpha',0.001,'type','per');
				ci2 = bootci(1000,{@mean,sp2},'alpha',0.001,'type','per');
				
				hold on
				line([time(1) time(end)],[ci1(1) ci1(1)],'Color',[0 0 0],'LineStyle','--');
				line([time(1) time(end)],[ci1(2) ci1(2)],'Color',[0 0 0],'LineStyle','--');
				line([time(1) time(end)],[ci2(1) ci2(1)],'Color',[1 0 0],'LineStyle','--');
				line([time(1) time(end)],[ci2(2) ci2(2)],'Color',[1 0 0],'LineStyle','--');
				
				title('Population PSTH')
				grid on
				box on
				axis tight
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
			if obj.nCells > 0
				sel = get(obj.handles.list,'Value');
				
			end
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
			fgmet = obj; %#ok<NASGU>
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
			
			mint = min(obj.mint)-obj.offset;
			maxt = min(obj.maxt)-obj.offset;
			
			for idx = 1:obj.nCells
				
				if get(obj.handles.selectbars,'Value') == 2
					psth1tmp = obj.cells{idx,1}.mean_fine;
					psth2tmp = obj.cells{idx,2}.mean_fine;
					time = obj.cells{idx,1}.time_fine-obj.offset;
				else
					psth1tmp = obj.cells{idx,1}.psth;
					psth2tmp = obj.cells{idx,2}.psth;
					time = obj.cells{idx,1}.time-obj.offset;
				end
				
				%make sure our psth is column format
				if size(psth1tmp,1) > size(psth1tmp,2)
					psth1tmp = psth1tmp';
				end
				if size(psth2tmp,1) > size(psth2tmp,2)
					psth2tmp = psth2tmp';
				end
				
				tidx = find(time >= maxt);
				tidx = tidx(1);
				time = time(1:tidx);
				psth1tmp = psth1tmp(1:tidx);
				psth2tmp = psth2tmp(1:tidx);
				
				if get(obj.handles.smooth,'Value') == 1
					maxtall = max(obj.maxt) - obj.offset;
					s=get(obj.handles.smoothmethod,'String');
					v=get(obj.handles.smoothmethod,'Value');
					s=s{v};
					F1 = griddedInterpolant(time,psth1tmp,s);
					F2 = griddedInterpolant(time,psth2tmp,s);
					time = min(time):obj.smoothstep:maxt;
					psth1tmp=F1(time);
					psth2tmp=F2(time);
					psth1tmp(psth1tmp < 0) = 0;
					psth2tmp(psth2tmp < 0) = 0;
					clear F1 F2;
				end
				
				max1 = max(psth1tmp);
				max2 = max(psth2tmp);
				if get(obj.handles.normalisecells,'Value') == 0
					maxx = max([max1 max2]);
					psth1tmp = psth1tmp / maxx;
					psth2tmp = psth2tmp / maxx;
				else
					psth1tmp = psth1tmp / max1;
					psth2tmp = psth2tmp / max2;
				end
				
				if isempty(psth1)
					psth1 = psth1tmp;
					psth2 = psth2tmp;
				else
					psth1 = [psth1;psth1tmp];
					psth2 = [psth2;psth2tmp];
				end
				
			end
			
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
				'FontSize',12,...
				'FontWeight','normal',...
				'Padding',0,...
				'TitleColor',[0.8 0.78 0.76],...
				'BackgroundColor',bgcolor);

			handles.hbox = uiextras.HBoxFlex('Parent', handles.root,'Padding',0,'Spacing',0,'BackgroundColor',bgcolor);
			handles.axistabs = uiextras.TabPanel('Parent', handles.hbox,'Padding',0,'BackgroundColor',bgcolor,'TabSize',100);
			handles.axisall = uiextras.Panel('Parent', handles.axistabs,'Padding',0,'BackgroundColor',bgcolor);
			handles.axisind = uiextras.Panel('Parent', handles.axistabs,'Padding',0,'BackgroundColor',bgcolor);
			handles.axistabs.TabNames = {'Individual Plots','Population Plot'};
			handles.axis1= axes('Parent',handles.axisall,'Tag','FGMetaAxis','Box','on');
			handles.axis2= axes('Parent',handles.axisind,'Tag','FGMetaAxis','Box','on');

			handles.controls = uiextras.VBox('Parent', handles.hbox,'Padding',0,'Spacing',0,'BackgroundColor',bgcolor);
			handles.controls1 = uiextras.Grid('Parent', handles.controls,'Padding',5,'Spacing',5,'BackgroundColor',bgcolor);
			handles.controls1.RowSizes = [-1 -1];
			handles.controls2 = uiextras.Grid('Parent', handles.controls,'Padding',5,'Spacing',0,'BackgroundColor',bgcolor);
			handles.controls3 = uiextras.Grid('Parent', handles.controls,'Padding',5,'Spacing',0,'BackgroundColor',bgcolor);
			handles.controls3.RowSizes = [-1 -1 -1];
			
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
				'Min',1,...
				'Max',1,...
				'FontSize',13,...
				'String',{''});
			
			handles.normalisecells = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGnormalisecells',...
				'Callback',@obj.replot,...
				'String','Independent Norm?');
			handles.selectbars = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGnormalisecells',...
				'Callback',@obj.replot,...
				'String','Show OPro BARS?');
			handles.newbars = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGnewbars',...
				'Callback',@obj.replot,...
				'String','Population BARS?');
			handles.smooth = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGsmoothcells',...
				'Callback',@obj.replot,...
				'String','Resmooth?');
			handles.smoothmethod = uicontrol('Style','popupmenu',...
				'Parent',handles.controls3,...
				'Tag','FGsmoothmethod',...
				'Callback',@obj.replot,...
				'String',{'pchip','linear','nearest','spline','cubic'});
			handles.smoothstep = uicontrol('Style','edit',...
				'Parent',handles.controls3,...
				'Tag','FGsmoothstep',...
				'Tooltip','Smoothing step in ms',...
				'Callback',@obj.replot,...
				'String','1');
			handles.meanmethod = uicontrol('Style','popupmenu',...
				'Parent',handles.controls3,...
				'Tag','FGmeanmethod',...
				'Callback',@obj.replot,...
				'String',{'mean','median','trimmean','geomean','harmmean'});

			set(handles.hbox,'Sizes', [-2 -1]);
			set(handles.controls,'Sizes', [40 -1 60]);

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