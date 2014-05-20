classdef FGMeta < handle
	
	properties
		verbose	= true
		offset@double = 200
		smoothstep@double = 1
		gaussstep@double = 20
		trimpercent@double = 10
		bp@struct
		symmetricgaussian = false
	end
	
	properties (SetAccess = private, GetAccess = public)
		cells@cell
		list@cell
		mint@double
		maxt@double
		deltat@double
	end
	
	properties (Hidden = false, SetAccess = private, GetAccess = public)
		ptime@double
		ppsth1@double
		ppout1@double
		perror1@double
		ppsth2@double
		ppout2@double
		perror2@double
		stash@struct
	end
	
	properties (SetAccess = protected, GetAccess = public, Transient = true)
		%> handles for the GUI
		handles@struct
		openUI@logical = false
		version@double = 1.15
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
			obj.bp = defaultParams();
			obj.bp.use_logspline = false;
			obj.bp.burn_iter = 100;
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
				return
			end
	
			cd(path);
			if ischar(file)
				file = {file};
			end
			
			tic
			l = length(file);
			for ll = 1:length(file)
				load(file{ll});
				
				if exist('spike','var') && isa(spike,'spikeAnalysis')
					idx = obj.nCells+1;
					spike.doPlots = false;
					spike.density();
					spike.PSTH();
					for i = 1:2
						obj.cells{idx,i}.name = spike.selectedTrials{i}.name;
						obj.cells{idx,i}.time = spike.results.psth{i}.time;
						obj.cells{idx,i}.psth = spike.results.psth{i}.avg;
						obj.cells{idx,i}.mean_fine = spike.results.sd{i}.avg;
						obj.cells{idx,i}.time_fine = spike.results.sd{i}.time;
						obj.cells{idx,i}.weight = 1;
					end
				elseif exist('o','var')
					idx = obj.nCells+1;
					for i = 1:2
						obj.cells{idx,i}.name = o.(['cell' num2str(i) 'names']){1};
						obj.cells{idx,i}.time = o.(['cell' num2str(i) 'time']){1};
						obj.cells{idx,i}.psth = o.(['cell' num2str(i) 'psth']){1};
						obj.cells{idx,i}.mean_fine = o.(['bars' num2str(i)]){1}.mean_fine;
						obj.cells{idx,i}.time_fine = o.(['bars' num2str(i)]){1}.time_fine;
						obj.cells{idx,i}.spontaneous = o.(['spontaneous' num2str(i)]);
						obj.cells{idx,i}.spontaneousci = o.(['spontaneous' num2str(i) 'ci']);
						obj.cells{idx,i}.spontaneouserror = o.(['spontaneous' num2str(i) 'error']);
						obj.cells{idx,i}.weight = 1;
					end
				else
					warndlg('This file wasn''t an spikeAnalysis or OPro MAT file...')
					return
				end

				obj.mint = [obj.mint obj.cells{idx,1}.time(1)];
				obj.maxt = [obj.maxt obj.cells{idx,1}.time(end)];
				obj.deltat = [obj.deltat max(diff(obj.cells{idx,1}.time(1:10)))];

				t = [obj.cells{idx,1}.name '>>>' obj.cells{idx,2}.name];
				t = regexprep(t,'[\|\s][\d\-\.]+','');
				t = [file{ll} ':' t];
				obj.list{idx} = t;

				set(obj.handles.list,'String',obj.list);
				set(obj.handles.list,'Value',obj.nCells);

				replot(obj);
				set(obj.handles.root,'Title',sprintf('Loading %g of %g Cells...',ll,l));
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
				obj.gaussstep = str2double(get(obj.handles.gaussstep,'String'));
				obj.offset = str2double(get(obj.handles.offset,'String'));
				obj.symmetricgaussian = logical(get(obj.handles.symmetricgaussian,'Value'));
				sel = get(obj.handles.list,'Value');
				w=[1 1];
				if isfield(obj.cells{sel,1},'weight')
					w(1) = obj.cells{sel,1}.weight;
				end
				if isfield(obj.cells{sel,2},'weight')
					w(2) = obj.cells{sel,2}.weight;
				end
				if length(w) == 2
					set(obj.handles.weight,'String',num2str(w));
				end
				if isfield(obj.cells{sel,1},'max')
					set(obj.handles.max,'String',num2str(obj.cells{sel,1}.max));
				else
					set(obj.handles.max,'String','0');
				end
					
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
				
				if str2double(get(obj.handles.gaussstep,'String')) > 0
					psth1 = gausssmooth(time,psth1,obj.gaussstep,obj.symmetricgaussian);
					psth2 = gausssmooth(time,psth2,obj.gaussstep,obj.symmetricgaussian);
				end
				
				if get(obj.handles.smooth,'Value') == 1
					[psth1, psth2] = obj.smoothdata(time,psth1,psth2);
				end
				
				name = '';
				if get(obj.handles.shownorm,'Value') == 1
					%do we have a max override?
					if isfield(obj.cells{sel,1},'max')
						gmax = obj.cells{sel,1}.max;
						if gmax == 0;gmax = []; end
					else
						gmax = [];
					end
					[psth1,psth2,name] = obj.normalise(time,psth1,psth2,gmax);
				end
				
				axes(obj.handles.axis1); cla
				plot(time,psth1,'ko-','MarkerFaceColor',[0 0 0]);
				hold on
				plot(time,psth2,'ro-','MarkerFaceColor',[1 0 0]);
				a=axis;
				line([maxt maxt],[0 a(4)]);
				hold off
				grid on
				box on
				title(sprintf('Selected Cell: %s',obj.list{sel}));
				xlabel('Time (ms)')
				ylabel('Firing Rate (Hz)')

				%----------------POPULATION-------------------------------
				[psth1,psth2,time]=computeAverage(obj);
				nn = find(isnan(nanmean(psth1)));
				time(nn) = [];
				psth1(:,nn) = [];
				psth2(:,nn) = [];
				
				[~,p1err] = stderr(psth1,'SE');
				[~,p2err] = stderr(psth2,'SE');
				
				for ii = 1:length(time)
					[p(ii), h(ii)] = ranksum(psth1(:,ii),psth2(:,ii),'alpha',0.01,'tail','left');
				end
				
				s = get(obj.handles.meanmethod,'String');
				v = get(obj.handles.meanmethod,'Value');
				s = s{v};
				try
					switch s
						case 'mean'
							p1out = nanmean(psth1);
							p2out = nanmean(psth2);
						case 'median'
							p1out = nanmedian(psth1);
							p2out = nanmedian(psth2);
						case 'trimmean'
							p1out = trimmean(psth1,obj.trimpercent);
							p2out = trimmean(psth2,obj.trimpercent);
						case 'geomean'
							p1out = geomean(psth1);
							p2out = geomean(psth2);
						case 'harmmean'
							p1out = harmmean(psth1);
							p2out = harmmean(psth2);
						case 'bootstrapmean'
							[p1out,p1err] = stderr(psth1,'CIMEAN');
							[p2out,p2err] = stderr(psth2,'CIMEAN');
							p1err(isnan(p1err))=0;
							p2err(isnan(p2err))=0;
						case 'bootstrapmedian'
							[p1out,p1err] = stderr(psth1,'CIMEDIAN');
							[p2out,p2err] = stderr(psth2,'CIMEDIAN');
							p1err(isnan(p1err))=0;
							p2err(isnan(p2err))=0;
					end
				catch
					p1out = nanmean(psth1);
					p2out = nanmean(psth2);
				end
				
				mm=max([max(p1out) max(p2out)]);
				mi=max([max(p1out) max(p2out)]);
				h = h * mm;
				
				axes(obj.handles.axis2); cla
				areabar(time,p1out,p1err,[0.7 0.7 0.7],0.35,'k.-','MarkerSize',8,'MarkerFaceColor',[0 0 0]);
				hold on
				areabar(time,p2out,p2err,[1 0.7 0.7],0.35,'r.-','MarkerSize',8,'MarkerFaceColor',[1 0 0]);
				hold on
				plot(time,h,'k*');
				if get(obj.handles.newbars,'Value') == 1
					bars1 = barsP(p1out,[time(1)+obj.offset time(end)+obj.offset],obj.bp.trials,obj.bp);
					bars2 = barsP(p2out,[time(1)+obj.offset time(end)+obj.offset],10,obj.bp);
					hold on
					plot(time,bars1.mean,'k-.',time,bars1.mode,'k:')
					plot(time,bars2.mean,'r-.',time,bars2.mode,'r:')
				end
				set(obj.handles.newbars,'Value',0)
				
				spontt = find(time < -20 & time > -50);
				sp1 = psth1(:,spontt);
				sp2 = psth2(:,spontt);
				sp1 = reshape(sp1,1,numel(sp1));
				sp2 = reshape(sp2,1,numel(sp2));
				ci1 = bootci(1000,{@nanmean,sp1},'alpha',0.01);
				ci2 = bootci(1000,{@nanmean,sp2},'alpha',0.01);
				
				hold on
				line([time(1) time(end)],[ci1(1) ci1(1)],'Color',[0 0 0],'LineStyle','--');
				line([time(1) time(end)],[ci1(2) ci1(2)],'Color',[0 0 0],'LineStyle','--');
				line([time(1) time(end)],[ci2(1) ci2(1)],'Color',[1 0 0],'LineStyle','--');
				line([time(1) time(end)],[ci2(2) ci2(2)],'Color',[1 0 0],'LineStyle','--');
				
				title(['Population (' s ') PSTH: ' num2str(obj.nCells) ' cells'])
				grid on
				box on
				axis tight
				xlabel('Time (ms)')
				name = get(obj.handles.normalisecells,'String');
				v = get(obj.handles.normalisecells,'Value');
				name = name{v};
				ylabel(['Firing Rate Normalised: ' name]);
				
				obj.ptime = time;
				obj.ppsth1 = psth1;
				obj.ppout1 = p1out;
				obj.ppsth2 = psth2;
				obj.ppout2 = p2out;
				obj.perror1 = p1err;
				obj.perror2 = p2err;
				
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
				return
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
		function remove(obj,varargin)
			if obj.nCells > 0
				sel = get(obj.handles.list,'Value');
				obj.cells(sel,:) = [];
				obj.list(sel) = [];
				obj.mint(sel) = [];
				obj.maxt(sel) = [];
				if sel > 1
					set(obj.handles.list,'Value',sel-1);
				end
				set(obj.handles.list,'String',obj.list);
			end
			replot(obj);
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
				return 
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
		
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function stashdata(obj)
			obj.stash(1).time = obj.ptime;
			obj.stash.psth1 = obj.ppsth1;
			obj.stash.ppout1 = obj.ppout1;
			obj.stash.psth2 = obj.ppsth2;
			obj.stash.ppout2 = obj.ppout2;
		end
		
		
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function comparestash(obj)
			time1 = obj.ptime;
			psth1 = obj.ppsth2;
			time2 = obj.stash.time;
			psth2 = obj.stash.psth2;
			
			mn = min([length(time1) length(time2)]);
			time1=time1(1:mn);
			time2=time2(1:mn);
			psth1=psth1(:,1:mn);
			psth2=psth2(:,1:mn);
			
			[~,p1err] = stderr(psth1,'SE');
			[~,p2err] = stderr(psth2,'SE');

			for ii = 1:length(time1)
				[p(ii), h(ii)] = ranksum(psth1(:,ii),psth2(:,ii),'alpha',0.01,'tail','left');
			end

			s = get(obj.handles.meanmethod,'String');
			v = get(obj.handles.meanmethod,'Value');
			s = s{v};
			try
				switch s
					case 'mean'
						p1out = nanmean(psth1);
						p2out = nanmean(psth2);
					case 'median'
						p1out = nanmedian(psth1);
						p2out = nanmedian(psth2);
					case 'trimmean'
						p1out = trimmean(psth1,obj.trimpercent);
						p2out = trimmean(psth2,obj.trimpercent);
					case 'geomean'
						p1out = geomean(psth1);
						p2out = geomean(psth2);
					case 'harmmean'
						p1out = harmmean(psth1);
						p2out = harmmean(psth2);
					case 'bootstrapmean'
						[p1out,p1err] = stderr(psth1,'CIMEAN');
						[p2out,p2err] = stderr(psth2,'CIMEAN');
						p1err(isnan(p1err))=0;
						p2err(isnan(p2err))=0;
					case 'bootstrapmedian'
						[p1out,p1err] = stderr(psth1,'CIMEDIAN');
						[p2out,p2err] = stderr(psth2,'CIMEDIAN');
						p1err(isnan(p1err))=0;
						p2err(isnan(p2err))=0;
				end
			catch
				p1out = nanmean(psth1);
				p2out = nanmean(psth2);
			end

			mm=max([max(p1out) max(p2out)]);
			mi=max([max(p1out) max(p2out)]);
			h = h * mm;

			figure;
			figpos(1,[1000 1000]);
			areabar(time1,p1out,p1err,[0.7 0.7 0.7],0.35,'k.-','MarkerSize',8,'MarkerFaceColor',[0 0 0]);
			hold on
			areabar(time2,p2out,p2err,[1 0.7 0.7],0.35,'r.-','MarkerSize',8,'MarkerFaceColor',[1 0 0]);
			hold on
			plot(time1,h,'k*');
		end
		
	end%-------------------------END PUBLIC METHODS--------------------------------%
	
	%=======================================================================
	methods (Hidden = true) %------------------Hidden METHODS
	%=======================================================================
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function editweight(obj,varargin)
			if obj.nCells > 0
				sel = get(obj.handles.list,'Value');
				w = str2num(get(obj.handles.weight,'String'));
				if length(w) == 2;
					obj.cells{sel,1}.weight = w(1);
					obj.cells{sel,2}.weight = w(2);
					if min(w) == 0
						s = obj.list{sel};
						s = regexprep(s,'^\*+','');
						s = ['**' s];
						obj.list{sel} = s;
						set(obj.handles.list,'String',obj.list);
					elseif min(w) < 1
						s = obj.list{sel};
						s = regexprep(s,'^\*+','');
						s = ['*' s];
						obj.list{sel} = s;
						set(obj.handles.list,'String',obj.list);
					else
						s = obj.list{sel};
						s = regexprep(s,'^\*+','');
						obj.list{sel} = s;
						set(obj.handles.list,'String',obj.list);
					end
				end
				replot(obj);
			end
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function editmax(obj,varargin)
			if obj.nCells > 0
				sel = get(obj.handles.list,'Value');
				m = str2num(get(obj.handles.max,'String'));
				if m >= 0
					obj.cells{sel,1}.max = m;
					obj.cells{sel,2}.max = m;
				end
				replot(obj);
			end
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
			obj.mint = [];
			obj.maxt = [];
			obj.deltat = [];
			set(obj.handles.root,'Title',['Number of Cells Loaded: ' num2str(obj.nCells)]);
		end
		
	end%-------------------------END HIDDEN METHODS--------------------------------%
	
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
			maxt = max(obj.maxt)-obj.offset;
			
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
				
				if isfield(obj.cells{idx,1},'weight')
					w1 = obj.cells{idx,1}.weight;
					if w1 < 0 || w1 > 1; w1 = 1; end
				else
					w1 = 1;
				end
				if isfield(obj.cells{idx,2},'weight')
					w2 = obj.cells{idx,2}.weight;
					if w2 < 0 || w2 > 1; w2 = 1; end
				else
					w2 = 1;
				end
				
				%make sure our psth is column format
				if size(psth1tmp,1) > size(psth1tmp,2)
					psth1tmp = psth1tmp';
				end
				if size(psth2tmp,1) > size(psth2tmp,2)
					psth2tmp = psth2tmp';
				end
				
				if obj.gaussstep > 0
					psth1tmp = gausssmooth(time,psth1tmp,obj.gaussstep,obj.symmetricgaussian);
					psth2tmp = gausssmooth(time,psth2tmp,obj.gaussstep,obj.symmetricgaussian);
				end
							
				if max(time) < maxt
					dt = max(obj.deltat);
					if isempty(dt); dt = 10; end
					tt = max(time)+dt:dt:maxt;
					time = [time tt];
					pp = 1:length(tt);
					pp(:) = NaN;
					psth1tmp = [psth1tmp pp];
					psth2tmp = [psth2tmp pp];
				end
				%tidx = find(time >= maxt);
				%tidx = tidx(1);
				%time = time(1:tidx);
				%psth1tmp = psth1tmp(1:tidx);
				%psth2tmp = psth2tmp(1:tidx);
				
				if get(obj.handles.smooth,'Value') == 1
					[psth1tmp, psth2tmp] = obj.smoothdata(time,psth1tmp,psth2tmp);
				end
				
				%do we have a max override?
				if isfield(obj.cells{idx,1},'max')
					gmax = obj.cells{idx,1}.max;
					if gmax == 0;gmax = []; end
				else
					gmax = [];
				end
				[psth1tmp,psth2tmp] = obj.normalise(time,psth1tmp,psth2tmp,gmax);
				
				if get(obj.handles.useweights,'Value') == 1
					psth1tmp = psth1tmp * w1;
					psth2tmp = psth2tmp * w2;
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
		function [psth1,psth2,name] = normalise(obj,time,psth1,psth2,gmax)
			if ~exist('gmax','var')
				gmax = [];
			end
			name = get(obj.handles.normalisecells,'String');
			v = get(obj.handles.normalisecells,'Value');
			name = name{v};
			max1 = max(psth1);
			max2 = max(psth2);
			min1 = min(psth1);
			min2 = min(psth2);
			maxx = max([max1 max2]);
			minn = min([min1 min2]);
			if ~isempty(gmax) && gmax > 0
				maxx = gmax;
			end
			switch v
				case 1 %shared max
					psth1 = psth1 / maxx;
					psth2 = psth2 / maxx;
				case 2 %indep max
					psth1 = psth1 / max1;
					psth2 = psth2 / max2;
				case 3 %minmax
					psth1 = psth1 - minn;
					psth2 = psth2 - minn;
					psth1 = psth1 / (maxx-minn);
					psth2 = psth2 / (maxx-minn);
				case 4 %minmax ind
					psth1 = psth1 - min1;
					psth2 = psth2 - min2;
					psth1 = psth1 / (max1-min1);
					psth2 = psth2 / (max2-min2);
				case 5 %max-spontaneous
					tidx = find(time < 0);
					sp1 = mean(psth1(tidx));
					sp2 = mean(psth2(tidx));
					sp = mean([sp1 sp2]);
					psth1 = psth1 - sp;
					psth2 = psth2 - sp;
					psth1 = psth1 / (maxx-sp);
					psth2 = psth2 / (maxx-sp);
				case 6 %zscore
					psth1 = zscore(psth1);
					psth2 = zscore(psth2);
				otherwise
					%fprintf('No normalisation!\n');
			end
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param
		%> @return
		% ===================================================================
		function [psth1,psth2] = smoothdata(obj,time,psth1,psth2)
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
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function closeUI(obj)
			try delete(obj.handles.parent); end %#ok<TRYNC>
			obj.handles = struct();
			obj.openUI = false;
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
				figpos(1,[1200 700])
			end

			bgcolor = [0.85 0.85 0.85];
			bgcoloredit = [0.87 0.87 0.87];

			handles.parent = parent; %#ok<*PROP>
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
			handles.controls3 = uiextras.Grid('Parent', handles.controls,'Padding',5,'Spacing',2,'BackgroundColor',bgcolor);
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
			handles.resetbutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGreplotbutton',...
				'Callback',@obj.reset,...
				'String','Reset');
% 			handles.replotbutton = uicontrol('Style','pushbutton',...
% 				'Parent',handles.controls1,...
% 				'Tag','FGreplotbutton',...
% 				'Callback',@obj.replot,...
% 				'String','Replot');
			handles.max = uicontrol('Style','edit',...
				'Parent',handles.controls1,...
				'Tag','FGweight',...
				'Tooltip','Cell Max Override',...
				'Callback',@obj.editmax,...
				'String','0');
			handles.weight = uicontrol('Style','edit',...
				'Parent',handles.controls1,...
				'Tag','FGweight',...
				'Tooltip','Cell Weight',...
				'Callback',@obj.editweight,...
				'String','1 1');
			
			handles.list = uicontrol('Style','listbox',...
				'Parent',handles.controls2,...
				'Tag','FGlistbox',...
				'Callback',@obj.replot,...
				'Min',1,...
				'Max',1,...
				'FontSize',13,...
				'String',{''});
			
			handles.selectbars = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGselectbars',...
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
			handles.shownorm = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGshownorm',...
				'Callback',@obj.replot,...
				'String','Show Normalisation?');
			handles.useweights = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGuseweights',...
				'Value',1,...
				'Callback',@obj.replot,...
				'String','Use Weights?');
			handles.symmetricgaussian = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','symmetricgaussian',...
				'Value',1,...
				'Callback',@obj.replot,...
				'String','Symmetric Gaussian?');
			%uiextras.Empty('Parent',handles.controls3,'BackgroundColor',bgcolor)
			handles.smoothstep = uicontrol('Style','edit',...
				'Parent',handles.controls3,...
				'Tag','FGsmoothstep',...
				'Tooltip','Smoothing step in ms',...
				'Callback',@obj.replot,...
				'String','1');
			handles.gaussstep = uicontrol('Style','edit',...
				'Parent',handles.controls3,...
				'Tag','FGgaussstep',...
				'Tooltip','Gaussian Smoothing step in ms',...
				'Callback',@obj.replot,...
				'String','0');
			handles.offset = uicontrol('Style','edit',...
				'Parent',handles.controls3,...
				'Tag','FGoffset',...
				'Tooltip','Time offset (ms)',...
				'Callback',@obj.replot,...
				'String','200');
			handles.normalisecells = uicontrol('Style','popupmenu',...
				'Parent',handles.controls3,...
				'Tag','FGnormalisecells',...
				'Callback',@obj.replot,...
				'String',{'Max-only','Max-only (ind)','Min-Max','Min-Max (ind)','Max-Spontaneous','ZScore','None'});
			handles.smoothmethod = uicontrol('Style','popupmenu',...
				'Parent',handles.controls3,...
				'Tag','FGsmoothmethod',...
				'Callback',@obj.replot,...
				'String',{'pchip','linear','nearest','spline','cubic'});
			handles.meanmethod = uicontrol('Style','popupmenu',...
				'Parent',handles.controls3,...
				'Tag','FGmeanmethod',...
				'Callback',@obj.replot,...
				'String',{'mean','median','trimmean','geomean','harmmean','bootstrapmean','bootstrapmedian'});

			set(handles.hbox,'Sizes', [-1.5 -1]);
			set(handles.controls,'Sizes', [55 -1 70]);

			obj.handles = handles;
			obj.openUI = true;
		end
	end	
end