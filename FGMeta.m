classdef FGMeta < handle
	
	properties
		verbose	= true
		offset@double = 200
		smoothstep@double = 1
		gaussstep@double = 20
		trimpercent@double = 10
		bp@struct
		symmetricgaussian@logical = false
		useMilliseconds@logical = false
		%> default range to plot
		plotRange@double = [-0.2 0.3]
		%> ± time window for baseline estimation/removal
		baselineWindow@double = [-0.2 0]
		%> cell data
		cells@cell
	end
	
	properties (SetAccess = private, GetAccess = public)
		isSpikeAnalysis = false
		list@cell
		mint@double
		maxt@double
		deltat@double
		groups@double = [1 2]
	end
	
	properties (Hidden = true, SetAccess = private, GetAccess = public)
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
		version@double = 1.4
	end
	
	properties (Dependent = true, SetAccess = private, GetAccess = public)
		%> number of loaded units
		nSites
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
			[file,path]=uigetfile('*.mat','Meta-Analysis:Choose OPro/spikeAnalysis source File','Multiselect','on');
			if ~iscell(file) && ~ischar(file)
				warning('Meta-Analysis Error: No File Specified')
				return
			end
	
			cd(path);
			if ischar(file)
				file = {file};
			end
			
			addtic = tic;
			l = length(file);
			for ll = 1:length(file)
				load(file{ll});
				if exist('spike','var') && isa(spike,'spikeAnalysis')
					set(obj.handles.root,'Title',sprintf('Loading %g of %g Units...',ll,l));
					if obj.nSites==0 
						obj.offset = 0;
						set(obj.handles.offset,'String','0');
						obj.useMilliseconds = false;
						obj.isSpikeAnalysis = true;
					end
					idx = obj.nSites+1;
					spike.optimiseSize();
					spike.doPlots = false;
					spike.select();
					spike.density();
					spike.PSTH();
					obj.stash(1).raw{idx} = spike;
					for i = 1:spike.nSelection
						obj.cells{idx,i}.filename = file;
						obj.cells{idx,i}.path = path;
						obj.cells{idx,i}.name = [spike.results.psth{i}.label{1} '_' spike.selectedTrials{i}.name];
						obj.cells{idx,i}.time = spike.results.psth{i}.time;
						obj.cells{idx,i}.psth = spike.results.psth{i}.avg;
						obj.cells{idx,i}.err = spike.var2SE(spike.results.psth{i}.var,spike.results.psth{i}.dof);
						obj.cells{idx,i}.mean_fine = spike.results.sd{i}.avg;
						obj.cells{idx,i}.time_fine = spike.results.sd{i}.time;
						obj.cells{idx,i}.err_fine = spike.results.sd{i}.stderr;
						if obj.useMilliseconds == true
							obj.cells{idx,i}.time = obj.cells{idx,i}.time.*1e3;
							obj.cells{idx,i}.time_fine = obj.cells{idx,i}.time_fine .* 1e3;
						end
						obj.cells{idx,i}.maxT = spike.measureRange(2);
						obj.cells{idx,i}.weight = 1;
						obj.cells{idx,i}.type = 'spikeAnalysis';
					end
					obj.mint = [obj.mint obj.cells{idx,1}.time(1)];
					obj.maxt = [obj.maxt obj.cells{idx,1}.maxT];
					obj.deltat = [obj.deltat max(diff(obj.cells{idx,1}.time(1:10)))];
					clear spike
				elseif exist('o','var')
					if obj.isSpikeAnalysis; error('You are trying to load opro file into spikeAnalysis data set'); end
					if obj.nSites==0
						obj.offset = 200;
						set(obj.handles.offset,'String','200');
						obj.useMilliseconds = true;
						obj.isSpikeAnalysis = false;
					end
					idx = obj.nSites+1;
					for i = 1:2
						obj.cells{idx,i}.name = o.(['cell' num2str(i) 'names']){1};
						obj.cells{idx,i}.time = o.(['cell' num2str(i) 'time']){1};
						if obj.useMilliseconds == false
							obj.cells{idx,i}.time = obj.cells{idx,i}.time.*1e3;
						end
						obj.cells{idx,i}.psth = o.(['cell' num2str(i) 'psth']){1};
						obj.cells{idx,i}.mean_fine = o.(['bars' num2str(i)]){1}.mean_fine;
						obj.cells{idx,i}.time_fine = o.(['bars' num2str(i)]){1}.time_fine;
						obj.cells{idx,i}.spontaneous = o.(['spontaneous' num2str(i)]);
						obj.cells{idx,i}.spontaneousci = o.(['spontaneous' num2str(i) 'ci']);
						obj.cells{idx,i}.spontaneouserror = o.(['spontaneous' num2str(i) 'error']);
						obj.cells{idx,i}.weight = 1;
						obj.cells{idx,i}.type = 'oPro';
					end
					obj.mint = [obj.mint obj.cells{idx,1}.time(1)];
					obj.maxt = [obj.maxt obj.cells{idx,1}.time(end)];
					obj.deltat = [obj.deltat max(diff(obj.cells{idx,1}.time(1:10)))];
					clear o
				else
					warndlg('This file wasn''t an spikeAnalysis or OPro MAT file...')
					return
				end

				if obj.isSpikeAnalysis
					t = sprintf('%s [%g]', file{ll}, obj.cells{idx,i}.maxT);
				else
					t = [obj.cells{idx,1}.name '>>>' obj.cells{idx,2}.name];
					t = regexprep(t,'[\|\s][\d\-\.]+','');
					t = [file{ll} ':' t];
				end
				obj.list{idx} = t;

				set(obj.handles.list,'String',obj.list);
				set(obj.handles.list,'Value',obj.nSites);
			
			end
			fprintf('Cell loading took %.5g seconds\n',toc(addtic))
			replot(obj);
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function replot(obj,varargin)
			if obj.nSites > 0
				set(obj.handles.root,'Title','Replotting...');
				drawnow;
				obj.smoothstep = str2double(get(obj.handles.smoothstep,'String'));
				obj.gaussstep = str2double(get(obj.handles.gaussstep,'String'));
				obj.offset = str2double(get(obj.handles.offset,'String'));
				obj.groups = str2num(get(obj.handles.groupselect,'String'));
				obj.symmetricgaussian = logical(get(obj.handles.symmetricgaussian,'Value'));
				sel = get(obj.handles.list,'Value');
				if isempty(sel); sel = 1; end
				grp = obj.groups;
				if isfield(obj.cells{sel,grp(1)},'weight')
					w = obj.cells{sel,grp(1)}.weight;
				end
				if length(w) > 1; w = 1; end
				set(obj.handles.weight,'String',num2str(w));
				
				if isfield(obj.cells{sel,1},'max')
					set(obj.handles.max,'String',num2str(obj.cells{sel,1}.max));
				else
					set(obj.handles.max,'String','0');
				end
				
				if obj.handles.axistabs.Selection == 1
					%============================plot individual========
					if obj.isSpikeAnalysis
						maxt = obj.cells{sel,grp(1)}.maxT - obj.offset;
					else
						maxt = obj.maxt(sel) - obj.offset;
					end
					err1 = []; err2 = [];
					if get(obj.handles.selectbars,'Value') == 1
						time = obj.cells{sel,grp(1)}.time_fine - obj.offset;
						psth1 = obj.cells{sel,grp(1)}.mean_fine;
						psth2 = obj.cells{sel,grp(2)}.mean_fine;
						if isfield(obj.cells{sel,1},'err_fine')
							err1 = obj.cells{sel,grp(1)}.err_fine;
							err2 = obj.cells{sel,grp(2)}.err_fine;
						end
						psth1(psth1 > 500) = 500;
						psth2(psth2 > 500) = 500;
					else
						time = obj.cells{sel,grp(1)}.time - obj.offset;
						psth1 = obj.cells{sel,grp(1)}.psth;
						psth2 = obj.cells{sel,2}.psth;
						if isfield(obj.cells{sel,1},'err')
							err1 = obj.cells{sel,grp(1)}.err;
							err2 = obj.cells{sel,grp(2)}.err;
						end
					end
					name1 = obj.cells{sel,grp(1)}.name;
					name2 = obj.cells{sel,grp(2)}.name;

					%make sure our psth is column format
					if size(psth1,1) > size(psth1,2)
						psth1 = psth1';
					end
					if size(psth2,1) > size(psth2,2)
						psth2 = psth2';
					end

					if str2double(get(obj.handles.gaussstep,'String')) > 0
						if obj.useMilliseconds == false;	gs = obj.gaussstep ./ 1e3; else gs = obj.gaussstep; end
						psth1 = gausssmooth(time,psth1,gs,obj.symmetricgaussian);
						psth2 = gausssmooth(time,psth2,gs,obj.symmetricgaussian);
					end

					if get(obj.handles.smooth,'Value') == 1
						[time, psth1, psth2] = obj.smoothdata(time,psth1,psth2);
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

					delete(obj.handles.ind.Children);
					obj.handles.axisind = axes('Parent',obj.handles.ind);
					hold on
					if ~isempty(err1)
						areabar(time, psth1, err1, [0.5 0.5 0.5], 0.2, 'k-','Color',[0 0 0],'LineWidth',1);
						areabar(time, psth2, err2, [0.7 0.5 0.5], 0.2, 'r-','Color',[1 0 0],'LineWidth',1);
						legend({name1,name2});
					else
						plot(time,psth1,'ko-','MarkerFaceColor',[0 0 0]);
						plot(time,psth2,'ro-','MarkerFaceColor',[1 0 0]);
					end
					a=axis;
					line([maxt maxt],[0 a(4)]);
					hold off
					grid on
					box on
					xlim(obj.plotRange);
					title(sprintf('Selected Cell: %s %s %s',obj.list{sel},name1,name2));
					xlabel('Time')
					ylabel('Firing Rate (s/s)')
				else
					%============================plot population========
					clear psth1 psth2 time
					[psth1,psth2,time]=computeAverage(obj);
					if size(time,1) > 1; time = time(1,:); end
					if obj.isSpikeAnalysis == false
						nn = find(isnan(nanmean(psth1)));
						time(nn) = [];
						psth1(:,nn) = [];
						psth2(:,nn) = [];
					end

					[~,p1err] = stderr(psth1,'SE');
					[~,p2err] = stderr(psth2,'SE');

					try
						for ii = 1:length(time)
							[p(ii), h(ii)] = ranksum(psth1(:,ii),psth2(:,ii),'alpha',0.01,'tail','left');
						end
					catch
						p=ones(size(time));
						h=zeros(size(time));
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
					if exist('h','var')
						h = h * mm; %h is for plotting sig points
					else
						h = nan(size(time));
					end

					delete(obj.handles.all.Children);
					obj.handles.axisall = axes('Parent',obj.handles.all);
					hold on

					if obj.useMilliseconds == true
						spontt = find(time < -20 & time > -50);
					else
						spontt = find(time < obj.baselineWindow(2) & time > obj.baselineWindow(1));
					end

					cimethod = get(obj.handles.spontmethod,'Value');
					sp1 = p1out(:,spontt); sp2 = p2out(:,spontt);
					sp1 = sp1(:); sp2 = sp2(:);
					sp1(isnan(sp1)) = []; sp2(isnan(sp2)) = [];
					switch cimethod
						case 1 %SD
							[sp1mean,sp1std] = normfit(sp1);
							[sp2mean,sp2std] = normfit(sp2);
							ci1(1) = sp1mean-(sp1std*2.33); ci1(2) = sp1mean+(sp1std*2.33);
							ci2(1) = sp2mean-(sp2std*2.33); ci2(2) = sp2mean+(sp2std*2.33);
						case 2 %CI
							[~,~,ci1] = normfit(sp1,0.01);
							[~,~,ci2] = normfit(sp2,0.01);
						case 3 % bootstrap
							ci1 = bootci(1000,{@nanmean,sp1},'alpha',0.01);
							ci2 = bootci(1000,{@nanmean,sp2},'alpha',0.01);
					end
					try %lets plot
						xp = [time(1) time(end) time(end) time(1)];
						yp = [ci1(1) ci1(1) ci1(2) ci1(2)];
						me1 = patch(xp,yp,[0.7 0.7 0.7],'FaceAlpha',0.2,'EdgeColor','none');
						set(get(get(me1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
						yp = [ci2(1) ci2(1) ci2(2) ci2(2)];
						me2 = patch(xp,yp,[1 0.5 0.5],'FaceAlpha',0.2,'EdgeColor','none');
						set(get(get(me2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
					end

					areabar(time,p1out,p1err,[0.7 0.7 0.7],0.35,'k-');
					hold on
					areabar(time,p2out,p2err,[1 0.7 0.7],0.35,'r-');
					hold on
					h(h==0) = NaN;
					if any(~isnan(h)); plot(time,h,'kx'); end
					if get(obj.handles.newbars,'Value') == 1
						bars1 = barsP(p1out,[time(1)+obj.offset time(end)+obj.offset],obj.bp.trials,obj.bp);
						bars2 = barsP(p2out,[time(1)+obj.offset time(end)+obj.offset],10,obj.bp);
						hold on
						plot(time,bars1.mean,'k-.',time,bars1.mode,'k:')
						plot(time,bars2.mean,'r-.',time,bars2.mode,'r:')
					end
					set(obj.handles.newbars,'Value',0)

					title(['Population (' s ') PSTH: ' num2str(obj.nSites) ' cells'])
					grid on
					box on
					axis tight
					xlabel('Time')
					xlim(obj.plotRange);
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
				set(obj.handles.root,'Title',['Number of Cells Loaded: ' num2str(obj.nSites)]);
			end
		end
		
		% ===================================================================
		%> @brief 
		%>
		%> @param
		%> @return
		% ===================================================================
		function reparse(obj,varargin)
			if obj.nSites > 0
				sel = get(obj.handles.list,'Value');
				spike = obj.stash.raw{sel};
				spike.select();
				spike.doPlots = false;
				spike.density();
				spike.PSTH();
				for i = 1:spike.nSelection
					obj.cells{sel,i}.time = spike.results.psth{i}.time;
					obj.cells{sel,i}.psth = spike.results.psth{i}.avg;
					obj.cells{sel,i}.err = spike.var2SE(spike.results.psth{i}.var,spike.results.psth{i}.dof);
					obj.cells{sel,i}.mean_fine = spike.results.sd{i}.avg;
					obj.cells{sel,i}.time_fine = spike.results.sd{i}.time;
					obj.cells{sel,i}.err_fine = spike.results.sd{i}.stderr;
					if obj.useMilliseconds == true
						obj.cells{sel,i}.time = obj.cells{idx,i}.time.*1e3;
						obj.cells{sel,i}.time_fine = obj.cells{idx,i}.time_fine .* 1e3;
					end
					obj.cells{sel,i}.maxT = spike.measureRange(2);
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
		function remove(obj,varargin)
			if obj.nSites > 0
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
			if obj.nSites > 0
				set(obj.handles.root,'Title','Saving...');
				drawnow;
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
				replot(obj);
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
			set(obj.handles.root,'Title','Loading...');
			drawnow;
			load(file);
			if exist('fgmet','var') && isa(fgmet,'FGMeta')
				reset(obj);
				obj.cells = fgmet.cells;
				obj.list = fgmet.list;
				obj.mint = fgmet.mint;
				obj.maxt = fgmet.maxt;
				obj.offset = fgmet.offset;
				set(obj.handles.offset,'String',num2str(obj.offset));
				if obj.maxt > 100
					obj.useMilliseconds = true;
					obj.plotRange = [0-obj.offset max(obj.maxt)];
				else
					obj.useMilliseconds = false;
					obj.plotRange = [-0.2 0.3];
				end
				obj.deltat = fgmet.deltat;
				set(obj.handles.list,'String',obj.list);
				set(obj.handles.list,'Value',obj.nSites);
				replot(obj);
				clear fgmet
			else
				set(obj.handles.root,'Title','Wasn''t valid FGMeta object...');
				drawnow;
			end
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
			if obj.handles.axistabs.Selection == 1
				hh = copyobj(obj.handles.axisind, h, 'legacy');
			else
				hh = copyobj(obj.handles.axisall, h, 'legacy');
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
		function value = get.nSites(obj)
			value = length(obj.list);
			if isempty(value)
				value = 0;
				return
			elseif value == 1 && iscell(obj.list) && isempty(obj.list{1})
				value = 0;
			end
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
			if obj.nSites > 0
				try
					grps = size(obj.cells(1,:),2);
				catch
					grps = 2;
				end
				sel = get(obj.handles.list,'Value');
				w = str2num(get(obj.handles.weight,'String'));
				if w < 0 || w > 1; w = 1; end
				for i = 1:grps
					obj.cells{sel,i}.weight = w;
				end
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
			if obj.nSites > 0
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
			obj.cells = cell(1);
			obj.list = cell(1);
			obj.mint = [];
			obj.maxt = [];
			obj.deltat = [];
			if isfield(obj.handles,'list')
				set(obj.handles.list,'Value',1);
				set(obj.handles.list,'String',{''});
			end
			if isfield(obj.stash,'raw')
				obj.stash.raw = {};
			end
			if isfield(obj.handles,'ind')
				delete(obj.handles.ind.Children)
				delete(obj.handles.all.Children) 
				obj.handles.axistabs.Selection=1;
				set(obj.handles.root,'Title',['Number of Cells Loaded: ' num2str(obj.nSites)]);
			end
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
		function [psth1, psth2, time]=computeAverage(obj)
			
			time = [];
			psth1 = [];
			psth2 = [];
			grp = obj.groups;
			
			mint = min(obj.mint)-obj.offset;
			maxt = max(obj.maxt)-obj.offset;
			
			for idx = 1:obj.nSites
				thisT=[];
				if isfield(obj.cells{idx,grp(1)},'maxT')
					thisT = obj.cells{idx,grp(1)}.maxT;
				end
				if get(obj.handles.selectbars,'Value') > 0
					psth1tmp = obj.cells{idx,grp(1)}.mean_fine;
					psth2tmp = obj.cells{idx,grp(2)}.mean_fine;
					timetmp = obj.cells{idx,grp(1)}.time_fine-obj.offset;
				else
					psth1tmp = obj.cells{idx,grp(1)}.psth;
					psth2tmp = obj.cells{idx,grp(2)}.psth;
					timetmp = obj.cells{idx,grp(1)}.time-obj.offset;
				end
				
				w = 1;
				if isfield(obj.cells{idx,grp(1)},'weight')
					w = obj.cells{idx,grp(1)}.weight;
					if w < 0 || w > 1; w = 1; end
				end
				
				%make sure our psth is column format
				if size(psth1tmp,1) > size(psth1tmp,2)
					psth1tmp = psth1tmp';
				end
				if size(psth2tmp,1) > size(psth2tmp,2)
					psth2tmp = psth2tmp';
				end
				
				if obj.gaussstep > 0
					if obj.useMilliseconds == false;	gs = obj.gaussstep ./ 1e3; else gs = obj.gaussstep; end
					psth1tmp = gausssmooth(time,psth1tmp,gs,obj.symmetricgaussian);
					psth2tmp = gausssmooth(time,psth2tmp,gs,obj.symmetricgaussian);
				end

				if obj.isSpikeAnalysis
					timenan = timetmp;
					timenan(timenan > thisT) = NaN;
					psth1tmp(isnan(timenan)) = NaN;
					psth2tmp(isnan(timenan)) = NaN;
				else
					if max(timetmp) < maxt
						dt = max(obj.deltat);
						if isempty(dt); dt = 10; end
						tt = max(timetmp)+dt:dt:maxt;
						timetmp = [timetmp tt];

						pp = nan(size(tt));
						psth1tmp = [psth1tmp pp];
						psth2tmp = [psth2tmp pp];
					end
				end
				
				if get(obj.handles.smooth,'Value') == 1
					[timetmp, psth1tmp, psth2tmp] = obj.smoothdata(timetmp,psth1tmp,psth2tmp);
				end
				
				%do we have a max override?
				if isfield(obj.cells{idx,1},'max')
					gmax = obj.cells{idx,1}.max;
					if gmax == 0;gmax = []; end
				else
					gmax = [];
				end
				[psth1tmp,psth2tmp] = obj.normalise(timetmp,psth1tmp,psth2tmp,gmax);
				
				if get(obj.handles.useweights,'Value') == 1
					psth1tmp = psth1tmp * w;
					psth2tmp = psth2tmp * w;
				end
				
				if isempty(psth1)
					psth1 = psth1tmp;
					psth2 = psth2tmp;
					time = timetmp;
				else
					psth1 = [psth1;psth1tmp];
					psth2 = [psth2;psth2tmp];
					time = [time;timetmp];
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
			if obj.useMilliseconds == true
				spontt = find(time < 0 & time > -200);
			else
				spontt = find(time < obj.baselineWindow(2) & time > obj.baselineWindow(1));
			end
			sp1 = nanmean(psth1(spontt));
			sp2 = nanmean(psth2(spontt));
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
					sp = nanmean([sp1 sp2]);if isnan(sp);sp=0;end
					psth1 = psth1 - sp;
					psth2 = psth2 - sp;
					psth1 = psth1 / (maxx-sp);
					psth2 = psth2 / (maxx-sp);
				case 6 %max-spontaneous
					if isnan(sp1);sp1=0;end
					if isnan(sp2);sp2=0;end
					psth1 = psth1 - sp1;
					psth2 = psth2 - sp1;
					psth1 = psth1 / (max1-sp1);
					psth2 = psth2 / (max2-sp2);
				case 7 %zscore
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
		function [time,psth1,psth2] = smoothdata(obj,time,psth1,psth2)
			if obj.useMilliseconds
				sstep = obj.smoothstep;
			else
				sstep = obj.smoothstep./1e3;
			end
			maxtall = max(obj.maxt) - obj.offset;
			s=get(obj.handles.smoothmethod,'String');
			v=get(obj.handles.smoothmethod,'Value');
			s=s{v};
			F1 = griddedInterpolant(time,psth1,s);
			F2 = griddedInterpolant(time,psth2,s);
			time = min(time):sstep:maxtall;
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
			obj.handles(1).parent = parent;
			%make context menu
			hcmenu = uicontextmenu;
			uimenu(hcmenu,'Label','Reparse (select)','Callback',@obj.reparse,'Accelerator','e');
			uimenu(hcmenu,'Label','Remove (select)','Callback',@obj.remove,'Accelerator','r');
			uimenu(hcmenu,'Label','Plot (select)','Callback',@obj.replot,'Accelerator','p','Separator','on');
			uimenu(hcmenu,'Label','Reset (all)','Callback',@obj.reset);
 			fs = 10;
% 			if ismac
% 				[s,c]=system('system_profiler SPDisplaysDataType'); v = version('-java');
% 				if s == 0; 
% 					if ~isempty(regexpi(c,'Retina LCD')) && ~isempty(regexpi(v,'Java 1.8'))
% 						fs = 7; 
% 					end 
% 				end
% 				clear s c v
% 			end	

			bgcolor = [0.85 0.85 0.85];
			bgcoloredit = [0.87 0.87 0.87];

			handles.parent = obj.handles.parent; %#ok<*PROP>
			handles.root = uix.BoxPanel('Parent',parent,...
				'Title',['Figure Ground Meta Analysis V' num2str(obj.version)],...
				'FontName','Helvetica',...
				'FontSize',fs+1,...
				'FontWeight','bold',...
				'Padding',0,...
				'TitleColor',[0.6 0.58 0.56],...
				'BackgroundColor',bgcolor);

			handles.hbox = uix.HBoxFlex('Parent', handles.root,'Padding',0,...
				'Spacing', 5, 'BackgroundColor', bgcolor);
			handles.axistabs = uix.TabPanel('Parent', handles.hbox,'Padding',0,...
				'BackgroundColor',bgcolor,'TabWidth',120,'SelectionChangedCallback',@obj.replot);
			handles.axisind = uix.Panel('Parent', handles.axistabs,'Padding',0,...
				'BackgroundColor',bgcolor,'FontSize',fs);
			handles.axisall = uix.Panel('Parent', handles.axistabs,'Padding',0,...
				'BackgroundColor',bgcolor,'FontSize',fs);
			handles.axistabs.TabTitles = {'Individual','Population'};
			handles.axistabs.TabWidth = 120;
			handles.ind = uipanel('Parent',handles.axisind,'units', 'normalized',...
				'position', [0 0 1 1],'FontSize',fs,'BorderType','none','BackgroundColor',bgcolor);
			handles.all = uipanel('Parent',handles.axisall,'units', 'normalized',...
				'position', [0 0 1 1],'FontSize',fs,'BorderType','none','BackgroundColor',bgcolor);
			handles.controls = uix.VBox('Parent', handles.hbox,'Padding',0,'Spacing',0,'BackgroundColor',bgcolor);
			handles.controls1 = uix.Grid('Parent', handles.controls,'Padding',5,'Spacing',5,...
				'BackgroundColor',bgcolor);
			handles.controls2 = uix.Grid('Parent', handles.controls,'Padding',5,'Spacing',0,'BackgroundColor',bgcolor);
			handles.controls3 = uix.Grid('Parent', handles.controls,'Padding',5,'Spacing',3,...
				'BackgroundColor',bgcolor);
			
			handles.loadbutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGloadbutton',...
				'FontSize', fs,...
				'Callback',@obj.load,...
				'Tooltip','Load a previous meta-analysis',...
				'String','Load');
			handles.savebutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGsavebutton',...
				'FontSize', fs,...
				'Callback',@obj.save,...
				'Tooltip','Save this  meta-analysis',...
				'String','Save');
			handles.addbutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGaddbutton',...
				'FontSize', fs,...
				'Callback',@obj.add,...
				'Tooltip','Add an individual dataset',...
				'String','Add Data');
			handles.spawnbutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGspawnbutton',...
				'FontSize', fs,...
				'Callback',@obj.spawn,...
				'Tooltip','Spawn the image to a new figure for export',...
				'String','Spawn');
			handles.removebutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGremovebutton',...
				'FontSize', fs,...
				'Callback',@obj.remove,...
				'Tooltip','Remove an individual dataset',...
				'String','Remove');
			handles.resetbutton = uicontrol('Style','pushbutton',...
				'Parent',handles.controls1,...
				'Tag','FGreplotbutton',...
				'FontSize', fs,...
				'Callback',@obj.reset,...
				'Tooltip','Clear all datasets',...
				'String','Reset');
% 			handles.replotbutton = uicontrol('Style','pushbutton',...
% 				'Parent',handles.controls1,...
% 				'Tag','FGreplotbutton',...
% 				'FontSize', fs,...
%				'Callback',@obj.replot,...
% 				'String','Replot');
			handles.max = uicontrol('Style','edit',...
				'Parent',handles.controls1,...
				'Tag','FGweight',...
				'Tooltip','Cell Max Override',...
				'FontSize', fs,...
				'Callback',@obj.editmax,...
				'String','0');
			handles.weight = uicontrol('Style','edit',...
				'Parent',handles.controls1,...
				'Tag','FGweight',...
				'FontSize', fs,...
				'Tooltip','Cell Weight',...
				'Callback',@obj.editweight,...
				'String','1');
			
			handles.list = uicontrol('Style','listbox',...
				'Parent',handles.controls2,...
				'Tag','FGlistbox',...
				'FontSize',fs-1,...
				'FontName',MonoFont,...
				'Callback',@obj.replot,...
				'Min',1,...
				'Max',1,...
				'uicontextmenu',hcmenu,...
				'String',{''});
			
			handles.selectbars = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGselectbars',...
				'FontSize', fs,...
				'Callback',@obj.replot,...
				'BackgroundColor',bgcolor,...
				'String','Density/Bars?');
			handles.newbars = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGnewbars',...
				'FontSize', fs,...
				'Callback',@obj.replot,...
				'BackgroundColor',bgcolor,...
				'String','Population BARS?');
			handles.smooth = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGsmoothcells',...
				'FontSize', fs,...
				'Callback',@obj.replot,...
				'BackgroundColor',bgcolor,...
				'String','Resmooth?');
			handles.shownorm = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGshownorm',...
				'FontSize', fs,...
				'Callback',@obj.replot,...
				'BackgroundColor',bgcolor,...
				'Tooltip','Try to show effects of normalisation on single units?',...
				'String','Show Norm?');
			handles.useweights = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','FGuseweights',...
				'Value',1,...
				'FontSize', fs,...
				'Callback',@obj.replot,...
				'BackgroundColor',bgcolor,...
				'String','Use Weights?');
			handles.symmetricgaussian = uicontrol('Style','checkbox',...
				'Parent',handles.controls3,...
				'Tag','symmetricgaussian',...
				'Value',1,...
				'FontSize', fs,...
				'Callback',@obj.replot,...
				'Tooltip','Use a symmetric gaussian for smoothing?',...
				'BackgroundColor',bgcolor,...
				'String','Symmetric Gauss?');
			%uiextras.Empty('Parent',handles.controls3,'BackgroundColor',bgcolor)
			handles.smoothstep = uicontrol('Style','edit',...
				'Parent',handles.controls3,...
				'Tag','FGsmoothstep',...
				'FontSize', fs,...
				'Tooltip','Smoothing step in ms',...
				'Callback',@obj.replot,...
				'String','1');
			handles.gaussstep = uicontrol('Style','edit',...
				'Parent',handles.controls3,...
				'Tag','FGgaussstep',...
				'FontSize', fs,...
				'Tooltip','Gaussian Smoothing step in ms',...
				'Callback',@obj.replot,...
				'String','0');
			handles.offset = uicontrol('Style','edit',...
				'Parent',handles.controls3,...
				'Tag','FGoffset',...
				'FontSize', fs,...
				'Tooltip','Time offset (ms)',...
				'Callback',@obj.replot,...
				'String','200');
			handles.groupselect = uicontrol('Style','edit',...
				'Parent',handles.controls3,...
				'Tag','FGgroupselect',...
				'FontSize', fs,...
				'Tooltip','Select Groups',...
				'Callback',@obj.replot,...
				'String','1 2');
			handles.normalisecells = uicontrol('Style','popupmenu',...
				'Parent',handles.controls3,...
				'Tag','FGnormalisecells',...
				'FontSize', fs,...
				'Callback',@obj.replot,...
				'String',{'Max-only','Max-only (Ind)','Min-Max','Min-Max (Ind)','Max-Spontaneous','Max-Spontaneous (Ind)','ZScore','None'});
			handles.smoothmethod = uicontrol('Style','popupmenu',...
				'Parent',handles.controls3,...
				'Tag','FGsmoothmethod',...
				'FontSize', fs,...
				'Callback',@obj.replot,...
				'String',{'pchip','linear','nearest','spline','cubic'});
			handles.meanmethod = uicontrol('Style','popupmenu',...
				'Parent',handles.controls3,...
				'Tag','FGmeanmethod',...
				'FontSize', fs,...
				'Callback',@obj.replot,...
				'String',{'mean','median','trimmean','geomean','harmmean','bootstrapmean','bootstrapmedian'});
			handles.spontmethod = uicontrol('Style','popupmenu',...
				'Parent',handles.controls3,...
				'Tag','FGspontmethod',...
				'FontSize', fs,...
				'Callback',@obj.replot,...
				'String',{'99% SD','99% CI','99% Bootstrap'});
			
			set(handles.hbox,'Widths', [-2 -1]);
			set(handles.controls,'Heights', [30 -1 95]);
			set(handles.controls3,'Widths', [-1 -1 -1], 'Heights', [-1 -1 -1 -1])

			obj.handles = handles;
			obj.openUI = true;
		end
	end	
end