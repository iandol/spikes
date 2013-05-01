function splot(action,varargin)

%--------------------------------------------------------------------------
%
%  Plots a Single PSTH for Further Analysis, needs to be called from Spikes
%  as it uses spikes data structure
%
% [ian - JULY 2002 V1.0.1] Added spontaneous measurement and latency measurement. Latency uses both SD or poisson distribution.
% [ian - NOV 2005 V1.0.3] Updated for 0 variable data
% -------------------------------------------------------------------------

global data		%global data structure from spikes
global sv		%spikes ui structure
global spdata 	%global structure to hold any splot specific data

spdata.version = 1.22;

if nargin<1;
	action='Initialize';
end

switch(action)	%As we use the GUI this switch allows us to respond to the user input
	
	%---------------------------------------------------------------------------------
	case 'Initialize'
		%---------------------------------------------------------------------------------
		v = spdata.version;
		spdata = [];
		spdata.version = v;
		version=['Single PSTH Plot: V' num2str(spdata.version) ' | Started - ',datestr(now)];
		spdata.guihandle = splotfig;			%our GUI file
		figpos(1);
		set(spdata.guihandle,'Name', version);
		spdata.spont=[]; %initialise spontaneous measurement
		spdata.latency=0;
		spdata.linfo=[];
		spdata.changetitle=0;
		spdata.bars = [];
		
		if ~exist('data','var') || isempty(data)
			errordlg('Sorry, cannot find data. You need to call this after you have loaded data using Spikes');
			return
		end
		
		if ismac || isunix
			if ~exist(['~' filesep 'MatlabFiles' filesep],'dir')
				mkdir(['~' filesep 'MatlabFiles' filesep]);
			end
			spdata.savepath = ['~' filesep 'MatlabFiles' filesep];
			spdata.matlabroot=matlabroot;
			spdata.temppath=tempdir;
		elseif ispc
			if ~exist(['c:' filesep 'MatlabFiles' filesep],'dir')
				mkdir(['c:' filesep 'MatlabFiles' filesep])
			end
			spdata.savepath = ['c:' filesep 'MatlabFiles' filesep];
			spdata.matlabroot=regexprep(matlabroot,'Program files','Progra~1','ignorecase');
			spdata.temppath=tempdir;
		end
		
		if data.numvars > 1
			set(gh('SPXBox'),'String',{num2str(data.xvalues')});
			set(gh('SPXBox'),'Value',ceil(data.xrange/2));
			set(gh('SPYBox'),'String',{num2str(data.yvalues')});
			set(gh('SPYBox'),'Value',ceil(data.yrange/2));
		elseif data.numvars > 0
			set(gh('SPXBox'),'String',{num2str(data.xvalues')});
			set(gh('SPXBox'),'Value',ceil(data.xrange/2));
			set(gh('SPYBox'),'Enable','off');
			set(gh('SPYBox'),'String',{'1'});
		else
			set(gh('SPYBox'),'Enable','off');
			set(gh('SPYBox'),'String',{'1'});
			set(gh('SPXBox'),'Enable','off');
			set(gh('SPXBox'),'String',{'1'});
		end
		
		set(gh('SmoothEdit'),'String',num2str(data.binwidth*2));
		
		set(gh('DataBox'),'String',{'All Spikes';'Burst Spikes';'Tonic Spikes';'Both Types'});
		set(gh('DataBox'),'Value',4);
		set(gh('TypeBox'),'String',{'Bar Plot';'Area Plot';'Gaussian Smooth';'Loess Curve'});
		set(gh('SPAnalMenu'),'String',{'None';'FFT Power Spectrum';'Linearity Test';'Get Spontaneous';'Latency Analysis';'Calculate BARS'}); %;'Latency Analysis';'Ratio of Bursts'});
		splot('Plot') %actually plot what we have
		
		%---------------------------------------------------------------------------------
	case 'Reload'  %simply reinitialise if we've loaded new stuff in spikes
		%---------------------------------------------------------------------------------
		
		if ~exist('data','var')
			errordlg('Sorry, cannot find data. You need to call this after you have loaded data using Spikes');
			return
		end
		
		if data.numvars > 1
			set(gh('SPXBox'),'String',{num2str(data.xvalues')});
			set(gh('SPXBox'),'Value',ceil(data.xrange/2));
			set(gh('SPYBox'),'String',{num2str(data.yvalues')});
			set(gh('SPYBox'),'Value',ceil(data.yrange/2));
		elseif data.numvars > 0
			set(gh('SPXBox'),'String',{num2str(data.xvalues')});
			set(gh('SPXBox'),'Value',ceil(data.xrange/2));
			set(gh('SPYBox'),'Enable','off');
			set(gh('SPYBox'),'String',{'1'});
		else
			set(gh('SPYBox'),'Enable','off');
			set(gh('SPYBox'),'String',{'1'});
			set(gh('SPXBox'),'Enable','off');
			set(gh('SPXBox'),'String',{'1'});
		end
		
		spdata.bars = [];
		spdata.latency = [];
		spdata.spont = [];
		spdata.linfo = [];
		
		set(gh('DataBox'),'String',{'All Spikes';'Burst Spikes';'Tonic Spikes';'Both Types'});
		set(gh('DataBox'),'Value',4);
		set(gh('TypeBox'),'String',{'Bar Plot';'Area Plot';'Gaussian Smooth';'Loess Curve'});
		set(gh('SPAnalMenu'),'String',{'None';'FFT Power Spectrum';'Linearity Test';'Get Spontaneous';'Latency Analysis';'Calculate BARS'}); %;'Latency Analysis';'Ratio of Bursts'});
		splot('Plot') %actually plot what we have
		
		%---------------------------------------------------------------------------------
	case 'Plot' %do da stuff
		%---------------------------------------------------------------------------------
		
		figure(spdata.guihandle);
		cla;
		set(gca,'Tag','SPAxis');
		
		x=get(gh('SPXBox'),'Value');
		y=get(gh('SPYBox'),'Value');
		z=sv.zval;
		
		[time,psth,bpsth,tpsth]=selectPSTH(x,y,z);
		
		datatype=get(gh('DataBox'),'Value');
		plottype=get(gh('TypeBox'),'Value');
		
		m=max(psth);
		m=converttotime(m);
		
		mb=max(bpsth);
		mb=converttotime(mb);
		
		mt=max(tpsth);
		mt=converttotime(mt);
		
		switch(datatype)
			
			case 1 %all spikes
				
				switch(plottype)
					
					case 1 %barplot
						if max(psth)>0;psth=(psth/max(psth))*m;end
						bar(time,psth,1,'k');
						hold on
						if isfield(spdata.bars,'mean') && logical(spdata.bars.x == x)
							plot(time,spdata.bars.mean,'r-')
							plot(time,spdata.bars.confBands(:,1),'r:')
							plot(time,spdata.bars.confBands(:,2),'r:')
						end
						hold off
						axis tight;
						ylabel(['Spikes / Bin (Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.numtrials) ' Mods:' num2str(data.nummods) ')' ]);
						ww=[time',psth'];
						%save c:\psth.txt  ww -ascii
					case 2 % area
						if max(psth)>0;psth=(psth/max(psth))*m;end
						h=area(time,psth);
						set(h,'FaceColor',[0 0 0]);
						hold on
						if isfield(spdata.bars,'mean') && logical(spdata.bars.x == x)
							plot(time,spdata.bars.mean,'r-')
							plot(time,spdata.bars.confBands(:,1),'r:')
							plot(time,spdata.bars.confBands(:,2),'r:')
						end
						hold off
						axis tight;
						ylabel(['Spikes / Bin (Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.numtrials) ' Mods:' num2str(data.nummods) ')' ]);
						ww=[time',psth'];
						%save c:\psth.txt  ww -ascii
					case 3 %smooth
						if max(psth)>0;psth=(psth/max(psth))*m;end	%scale to firing rate
						ss=str2num(get(gh('SmoothEdit'),'String'));
						spdata.psths=gausssmooth(time,psth,ss);
						if isnan(spdata.psths);errordlg('Sorry, increase smooth parameter - may not work at all for very low firing rate');error('Smoothing parameter too low.');end;
						h=area(time,spdata.psths);
						set(h,'FaceColor',[0 0 0]);
						axis tight;
						ylabel('Instantaneous Firing Rate (Hz)')
						ww=[time',spdata.psths'];
						%save c:\psth.txt  ww -ascii
					case 4 %loess
						if max(psth)>0;psth=(psth/max(psth))*m;end
						lss=str2num(get(gh('LoessEdit'),'String'));
						resolution=length(psth)*2;
						spdata.times=linspace(min(time),max(time),resolution);
						spdata.psths=loess(time,psth,spdata.times,lss,1);
						if max(spdata.psths)==0 && max(psth)>0	 %says that loess has smoothed to 0
							errordlg(['You may need to increase the Loess smoothing parameter from:' lss])
							error('Loess value too small')
						end
						h=area(spdata.times,spdata.psths);
						set(h,'FaceColor',[0 0 0]);
						axis tight;
						ylabel('Instantaneous Firing Rate (Hz)')
						ww=[spdata.times',spdata.psths'];
						%save c:\psth.txt  ww -ascii
					case 5
						
				end
				
			case 2 % burst spikes
				
				switch(plottype)
					
					case 1 %bar
						if max(bpsth)>0;bpsth=(bpsth/max(bpsth))*mb;end
						bar(time,bpsth,1,'k');
						hold on
						if isfield(spdata.bars,'mean') && logical(spdata.bars.x == x)
							plot(time,spdata.bars.mean,'r-')
							plot(time,spdata.bars.confBands(:,1),'r:')
							plot(time,spdata.bars.confBands(:,2),'r:')
						end
						hold off
						axis tight;
						ylabel(['Firing Rate (Hz, Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.numtrials) ' Mods:' num2str(data.nummods) ')' ]);
						ww=[time',bpsth'];
						%save c:\burstpsth.txt  ww -ascii
					case 2 %area
						if max(bpsth)>0;bpsth=(bpsth/max(bpsth))*mb;end
						h=area(time,bpsth);
						set(h,'FaceColor',[0 0 0]);
						hold on
						if isfield(spdata.bars,'mean') && logical(spdata.bars.x == x)
							plot(time,spdata.bars.mean,'r-')
							plot(time,spdata.bars.confBands(:,1),'r:')
							plot(time,spdata.bars.confBands(:,2),'r:')
						end
						hold off
						axis tight;
						ylabel(['Firing Rate (Hz, Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.numtrials) ' Mods:' num2str(data.nummods) ')' ]);
						ww=[time',bpsth'];
						%save c:\burstpsth.txt  ww -ascii
					case 3 %smooth
						if max(bpsth)>0;bpsth=(bpsth/max(bpsth))*mb;end
						ss=str2num(get(gh('SmoothEdit'),'String'));
						spdata.bpsths=gausssmooth(time,bpsth,ss);
						if isnan(spdata.bpsths);errordlg('Sorry, increase smooth parameter - may not work at all for very low firing rate');error('Smoothing parameter too low.');end;
						h=area(time,spdata.bpsths);
						set(h,'FaceColor',[0 0 0]);
						axis tight;
						ylabel('Instantaneous Firing Rate (Hz)')
						ww=[time',spdata.bpsths'];
						%save c:\burstpsth.txt  ww -ascii
					case 4 %loess
						if max(bpsth)>0;bpsth=(bpsth/max(bpsth))*mb;end
						lss=str2num(get(gh('LoessEdit'),'String'));
						resolution=length(bpsth)*2;
						spdata.times=linspace(min(time),max(time),resolution);
						spdata.bpsths=loess(time,bpsth,spdata.times,lss,1);
						if max(spdata.bpsths)==0 && max(bpsth)>0	 %says that loess has smoothed to 0
							errordlg(['You may need to increase the Loess smoothing parameter from:' lss])
							error('Loess value too small')
						end
						h=area(spdata.times,spdata.bpsths);
						set(h,'FaceColor',[0 0 0]);
						axis tight;
						ylabel('Instantaneous Firing Rate (Hz)')
						ww=[spdata.times',spdata.bpsths'];
						%save c:\burstpsth.txt  ww -ascii
				end
				
				case 3 % tonic spikes
				
				switch(plottype)
					
					case 1 %bar
						if max(tpsth)>0;tpsth=(tpsth/max(tpsth))*mt;end
						bar(time,tpsth,1,'k');
						hold on
						if isfield(spdata.bars,'mean') && logical(spdata.bars.x == x)
							plot(time,spdata.bars.mean,'r-')
							plot(time,spdata.bars.confBands(:,1),'r:')
							plot(time,spdata.bars.confBands(:,2),'r:')
						end
						hold off
						axis tight;
						ylabel(['Firing Rate (Hz, Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.numtrials) ' Mods:' num2str(data.nummods) ')' ]);
						ww=[time',tpsth'];
					case 2 %area
						if max(tpsth)>0;tpsth=(tpsth/max(tpsth))*mt;end
						h=area(time,tpsth);
						set(h,'FaceColor',[0 0 0]);
						hold on
						if isfield(spdata.bars,'mean') && logical(spdata.bars.x == x)
							plot(time,spdata.bars.mean,'r-')
							plot(time,spdata.bars.confBands(:,1),'r:')
							plot(time,spdata.bars.confBands(:,2),'r:')
						end
						hold off
						axis tight;
						ylabel(['Firing Rate (Hz, Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.numtrials) ' Mods:' num2str(data.nummods) ')' ]);
					case 3 %smooth
						if max(tpsth)>0;tpsth=(tpsth/max(tpsth))*mt;end
						ss=str2num(get(gh('SmoothEdit'),'String'));
						spdata.tpsths=gausssmooth(time,tpsth,ss);
						if isnan(spdata.tpsths);errordlg('Sorry, increase smooth parameter - may not work at all for very low firing rate');error('Smoothing parameter too low.');end;
						h=area(time,spdata.tpsths);
						set(h,'FaceColor',[0 0 0]);
						axis tight;
						ylabel('Instantaneous Firing Rate (Hz)')
					case 4 %loess
						if max(tpsth)>0;tpsth=(tpsth/max(tpsth))*mt;end
						lss=str2num(get(gh('LoessEdit'),'String'));
						resolution=length(tpsth)*2;
						spdata.times=linspace(min(time),max(time),resolution);
						spdata.tpsths=loess(time,tpsth,spdata.times,lss,1);
						if max(spdata.tpsths)==0 && max(tpsth)>0	 %says that loess has smoothed to 0
							errordlg(['You may need to increase the Loess smoothing parameter from:' lss])
							error('Loess value too small')
						end
						h=area(spdata.times,spdata.tpsths);
						set(h,'FaceColor',[0 0 0]);
						axis tight;
						ylabel('Instantaneous Firing Rate (Hz)')
				end
				
			case 4 %both spikes
				
				switch(plottype)
					
					case 1 %bar
						if max(psth)>0;psth=(psth/max(psth))*m;end
						if max(bpsth)>0;bpsth=(bpsth/max(bpsth))*mb;end
						bar(time,psth,1,'k');
						hold on
						bar(time,bpsth,1,'r');
						if isfield(spdata.bars,'mean') && logical(spdata.bars.x == x)
							plot(time,spdata.bars.mean,'r-')
							plot(time,spdata.bars.confBands(:,1),'r:')
							plot(time,spdata.bars.confBands(:,2),'r:')
						end
						hold off
						legend('All Spikes','Burst Spikes',0)
						axis tight
						ylabel(['Firing Rate (Hz, Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.numtrials) ' Mods:' num2str(data.nummods) ')' ]);
						ww=[time',psth'];
						www=[time',bpsth'];
						%save c:\psth.txt  ww -ascii
						%save c:\burstpsth.txt  www -ascii
					case 2 %area
						if max(psth)>0;psth=(psth/max(psth))*m;end
						if max(bpsth)>0;bpsth=(bpsth/max(bpsth))*mb;end
						h=area(time,psth);
						set(h,'FaceColor',[0 0 0]);
						hold on
						h=area(time,bpsth);
						set(h,'FaceColor',[1 0 0]);
						if isfield(spdata.bars,'mean') && logical(spdata.bars.x == x)
							plot(time,spdata.bars.mean,'r-')
							plot(time,spdata.bars.confBands(:,1),'r:')
							plot(time,spdata.bars.confBands(:,2),'r:')
						end
						hold off
						legend('All Spikes','Burst Spikes',0)
						axis tight
						ylabel(['Firing Rate (Hz, Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.numtrials) ' Mods:' num2str(data.nummods) ')' ]);
						ww=[time',psth'];
						www=[time',bpsth'];
						%save c:\psth.txt  ww -ascii
						%save c:\burstpsth.txt  www -ascii
					case 3 %smooth
						if max(psth)>0;psth=(psth/max(psth))*m;end
						if max(bpsth)>0;bpsth=(bpsth/max(bpsth))*mb;end
						ss=str2num(get(gh('SmoothEdit'),'String'));
						spdata.psths=gausssmooth(time,psth,ss);
						spdata.bpsths=gausssmooth(time,bpsth,ss);
						if isnan(spdata.psths) | isnan(spdata.bpsths);errordlg('Sorry, increase smooth parameter - may not work at all for very low firing rate');error('Smoothing parameter too low.');end;
						h=area(time,spdata.psths);
						set(h,'FaceColor',[0 0 0])
						hold on
						h2=area(time,spdata.bpsths);
						set(h2,'FaceColor',[1 0 0])
						hold off
						legend('All Spikes','Burst Spikes',0)
						axis tight
						ylabel('Instantaneous Firing Rate (Hz)')
						ww=[time',spdata.psths'];
						www=[time',spdata.bpsths'];
						%save c:\psth.txt  ww -ascii
						%save c:\burstpsth.txt  www -ascii
					case 4 %loess
						if max(psth)>0;psth=(psth/max(psth))*m;end
						if max(bpsth)>0;bpsth=(bpsth/max(bpsth))*mb;end
						lss=str2num(get(gh('LoessEdit'),'String'));
						resolution=length(psth)*2;
						spdata.times=linspace(min(time),max(time),resolution);
						spdata.psths=loess(time,psth,spdata.times,lss,1);
						spdata.bpsths=loess(time,bpsth,spdata.times,lss,1);
						if (max(spdata.psths)==0 && max(psth)>0) || (max(spdata.psths)==0 && max(psth)>0)	 %says that loess has smoothed to 0
							errordlg(['You may need to increase the Loess smoothing parameter from:' lss])
							error('Loess value too small')
						end
						h=area(spdata.times,spdata.psths);
						set(h,'FaceColor',[0 0 0])
						hold on
						h2=area(spdata.times,spdata.bpsths);
						set(h2,'FaceColor',[1 0 0])
						hold off
						legend('All Spikes','Burst Spikes',0)
						axis tight
						ylabel('Instantaneous Firing Rate (Hz)')
						ww=[spdata.times',spdata.psths'];
						www=[spdata.times',spdata.bpsths'];
						%save c:\psth.txt  ww -ascii
						%save c:\burstpsth.txt  www -ascii
				end
		end
		
		if ~isempty(spdata.latency) && spdata.latency > 0
			line([spdata.latency spdata.latency],[0 m],'LineWidth',1);
			text(spdata.latency+(spdata.latency/2),(m-(m/20)),['Latency=' num2str(spdata.latency)],'FontSize',16,'Color',[1 0 0]);
		end
		
		String=get(gh('SPXBox'),'String');
		xs=String{x};
		String=get(gh('SPYBox'),'String');
		ys=String{y};
		xt=data.xtitle;
		if data.numvars > 1;
			yt=data.ytitle;
		else
			yt='';
		end
		String=get(gh('DataBox'),'String');
		dt=String{datatype};
		
		o=[data.runname '[ ' xt ':' xs ' / ' yt ':' ys ' ] ' dt];
		if spdata.changetitle==1
			o=[o '\newline' spdata.linfo];
		end
		title(o);
		
		xlabel('Time (ms)');
		
		if get(gh('AxCheck'),'Value')==0
			xv=str2num(get(gh('XEd'),'String'));
			yv=str2num(get(gh('YEd'),'String'));
			axis([xv yv])
		end
		
		set(gca,'Tag','SPAxis');
		
		if isfield(spdata.bars,'mean') && spdata.bars.x == x
			hh = figure;
			try
				
				mm=max(spdata.bars.mean_fine);

				hold on
				h=area(spdata.bars.time_fine,spdata.bars.confBands_fine(:,2));
				set(h,'FaceColor',[0.6 0.6 0.6]);
				set(h,'EdgeColor','none');

				h=area(spdata.bars.time_fine,spdata.bars.mean_fine);
				set(h,'FaceColor',[0.6 0.6 0.6]);

				h=area(spdata.bars.time_fine,spdata.bars.confBands_fine(:,1));
				set(h,'FaceColor',[1 1 1]);
				set(h,'EdgeColor','none');

				p = find(spdata.bars.mean_fine == mm);
				plot(spdata.bars.time_fine(p),mm,'ro');
				plot(spdata.bars.time_fine, repmat(mm/10,length(spdata.bars.mean_fine),1),'b:');

				if ~isempty(spdata.latency) && spdata.latency > 0
					line([spdata.latency spdata.latency],[0 mm],'LineWidth',1);
					text(spdata.latency+(spdata.latency/2),(mm-(mm/20)),['Latency=' num2str(spdata.latency)],'FontSize',12);
				end

				set(gcf,'Renderer','painters')
				set(gca,'Layer','top')
				axis tight
				box on
				%line([time2(1) time2(end)],[m/10 m/10]);

				t1 = ['Prior: ' spdata.bars.bp.prior_id ' | dparams: ' num2str(spdata.bars.bp.dparams) ' | burn: ' num2str(spdata.bars.bp.burn_iter)];

				xlabel('Time (ms)')
				ylabel('Firing Rate (Hz)')
				title(['BARS Fit:' o t1])
				hold off
				
			catch ME
				close(hh)
				rethrow ME
			end
		end
		
		%------------------------------------------------------------------------------------------
	case 'None' %null entry in menu
		%------------------------------------------------------------------------------------------
		
		%------------------------------------------------------------------------------------------
	case 'Calculate BARS'
		%------------------------------------------------------------------------------------------
		oldtext = get(gh('SPPanel'),'Title');
		set(gh('SPPanel'),'Title','Please wait...');
		drawnow
		
		try
			spdata.bars = [];
			spdata.latency = [];
			x=get(gh('SPXBox'),'Value');
			y=get(gh('SPYBox'),'Value');
			z=sv.zval;
			
			[time,psth,bpsth,tpsth]=selectPSTH(x,y,z);

			datatype=get(gh('DataBox'),'Value');
			if datatype == 2
				psth = bpsth;
			elseif datatype == 3
				psth = tpsth;
			end

			m=max(psth);
			[m,trials]=converttotime(m);

			if max(psth)>0;psth=(psth/max(psth))*m;end
			
			psth(psth < 1) = 0;

			bp = defaultParams;

			v=get(gh('SPBARSpriorid'),'Value');
			s=get(gh('SPBARSpriorid'),'String');
			bp.prior_id = s{v};
			bp.dparams=str2num(get(gh('SPBARSdparams'),'String'));
			bp.burn_iter=str2num(get(gh('SPBARSburniter'),'String'));
			bp.conf_level=str2num(get(gh('SPBARSconflevel'),'String'));
			
			spdata.bars = barsP(psth,[time(1) time(end)],trials,bp);
			spdata.bars.psth = psth;
			spdata.bars.time = time;
			
			t1=spdata.bars.time(1);
			t2=spdata.bars.time(end);
			
			spdata.bars.time_fine = linspace(t1,t2,length(spdata.bars.mean_fine));

			spdata.bars.x = x;
			spdata.bars.bp = bp;
			set(gh('SPPanel'),'Title',oldtext);
		catch ME
			spdata.bars = [];
			set(gh('SPPanel'),'Title',oldtext);
			rethrow(ME)
		end
		splot('Plot') %actually plot what we have
		
		%------------------------------------------------------------------------------------------
	case 'Get Spontaneous'
		%------------------------------------------------------------------------------------------
		
		spdata.spont=[];
		data.spontaneous=[];
		
		x=get(gh('SPXBox'),'Value');
		y=get(gh('SPYBox'),'Value');
		z=sv.zval;
		datatype=get(gh('DataBox'),'Value');
		plottype=get(gh('TypeBox'),'Value');
		
		psthtype = datatype;
		if psthtype == 4; %in the menu 1 and 4 are all spikes 
			psthtype = 1;
		end
		[mint,maxt]=measure(data,x,y,z,psthtype);
		%this if loop selects where are data is (depends on whether it was smoothed etc)
		sppos = str2num(get(gh('SPSpPos'),'String'));
		if isempty(sppos)
			sppos = [y,x,z];
			loop = 1;
		else
			sppos = sppos';
			loop = length(sppos);
		end
		for i = 1:loop
			if datatype==2 %bursts
				if plottype==1 || plottype==2 %no smoothing so just raw psths
					time=data.time{sppos(i,1),sppos(i,2),sppos(i,3)};
					psth=data.bpsth{sppos(i,1),sppos(i,2),sppos(i,3)};
				elseif plottype==3
					time=data.time{sppos(i,1),sppos(i,2),sppos(i,3)};
					psth=spdata.bpsths;
				elseif plottype==4
					time=spdata.times;
					psth=spdata.bpsths;
				end
			elseif datatype == 3
				if plottype==1 || plottype==2 %no smoothing so just raw psths
					time=data.time{sppos(i,1),sppos(i,2),sppos(i,3)};
					psth = data.psth{sppos(i,1),sppos(i,2),sppos(i,3)} - data.bpsth{sppos(i,1),sppos(i,2),sppos(i,3)};
				elseif plottype==3
					time=data.time{sppos(i,1),sppos(i,2),sppos(i,3)};
					psth=spdata.tpsths;
				elseif plottype==4
					time=spdata.times;
					psth=spdata.tpsths;
				end
			else %all spikes
				if plottype==1 || plottype==2 %no smoothing so just raw psths
					time=data.time{sppos(i,1),sppos(i,2),sppos(i,3)};
					psth=data.psth{sppos(i,1),sppos(i,2),sppos(i,3)};
				elseif plottype==3
					time=data.time{sppos(i,1),sppos(i,2),sppos(i,3)};
					psth=spdata.psths;
				elseif plottype==4
					time=spdata.times;
					psth=spdata.psths;
				end
			end
		end
		
		sp = calculatespontaneous(psth,time,mint,maxt);
		
		spdata.spont = sp;
		
		data.spontaneous.mean=spdata.spont.meano;
		data.spontaneous.sd=spdata.spont.sdo;
		data.spontaneous.se=spdata.spont.seo;
		data.spontaneous.limit=spdata.spont.meano+(2*spdata.spont.sdo);
		data.spontaneous.limitse=spdata.spont.meano+(2*spdata.spont.seo);
		data.spontaneous.poisson=spdata.spont.ci01o(2);

		data.spontaneous.meant=spdata.spont.mean;
		data.spontaneous.sdt=spdata.spont.sd;
		data.spontaneous.sdt=spdata.spont.se;
		data.spontaneous.limitt=spdata.spont.mean+(2*spdata.spont.sd);
		data.spontaneous.limitset=spdata.spont.mean+(2*spdata.spont.se);
		data.spontaneous.poissont=spdata.spont.ci01(2);
		
		if datatype == 1 || datatype == 4
			t = 'All Spikes ';
		elseif datatype == 2
			t = 'Burst Spikes ';
		elseif datatype == 3
			t = 'Tonic Spikes ';
		end
		spdata.spont.type = t;
		data.spontaneous.type = spdata.spont.type;
		
		t1=[t 'Spontaneous is: ' num2str(spdata.spont.mean) '+-' num2str(spdata.spont.sd) 'S.D. Hz'];
		t2=['2*S.D. Limit: ' num2str(data.spontaneous.limitt) ' Hz (' num2str(data.spontaneous.limit) 'sp/bin)'];
		t3=['2*S.E. Limit: ' num2str(data.spontaneous.limitset) ' Hz (' num2str(data.spontaneous.limitse) 'sp/bin)'];
		cil=num2str(spdata.spont.ci01(1));
		ciu=num2str(spdata.spont.ci01(2));
		t4=['0.01 Confidence Interval from a Poisson: ' cil '-' ciu ' Hz'];
		cil=num2str(spdata.spont.ci05(1));
		ciu=num2str(spdata.spont.ci05(2));
		t5=['0.05 Confidence Interval from a Poisson: ' cil '-' ciu ' Hz'];
		t6=['These Values has been stored in the data structure, and can automatically be used with the latency analysis'];
		t={t1;t2;t3;t4;t5;t6};
		
		spdata.latency = [];
		
		helpdlg(t,'Spontaneous Values');
		
		%------------------------------------------------------------------------------------------
	case 'Latency Analysis'
		%------------------------------------------------------------------------------------------
		
		laoptions;	%our GUI to select options etc. - puts its values in spdata
		
		x=get(gh('SPXBox'),'Value');
		y=get(gh('SPYBox'),'Value');
		z=sv.zval;
		datatype=get(gh('DataBox'),'Value');
		plottype=get(gh('TypeBox'),'Value');
		
		%this if loop selects where are data is (depends on whether it was smoothed etc)
		if datatype==2 %bursts
			if plottype==1 || plottype==2 %no smoothing so just raw psths
				time=data.time{y,x,z};
				psth=data.bpsth{y,x,z};
			elseif plottype==3
				time=data.time{y,x,z};
				psth=spdata.bpsths;
			elseif plottype==4
				time=spdata.times;
				psth=spdata.bpsths;
			end
		elseif datatype == 3
			if plottype==1 || plottype==2 %no smoothing so just raw psths
				time=data.time{y,x,z};
				psth = data.psth{y,x,z} - data.bpsth{y,x,z};
			elseif plottype==3
				time=data.time{y,x,z};
				psth=spdata.tpsths;
			elseif plottype==4
				time=spdata.times;
				psth=spdata.tpsths;
			end
		else %all spikes
			if plottype==1 || plottype==2 %no smoothing so just raw psths
				time=data.time{y,x,z};
				psth=data.psth{y,x,z};
			elseif plottype==3
				time=data.time{y,x,z};
				psth=spdata.psths;
			elseif plottype==4
				time=spdata.times;
				psth=spdata.psths;
			end
		end
		
		m=max(psth);
		m=converttotime(m);
		if max(psth)>0;psth=(psth/max(psth))*m;end
		
		switch spdata.method
			
			case 'BARS'
				if isfield(spdata,'bars') && isfield(spdata.bars,'mean')
					
					psth = spdata.bars.mean';
					time = spdata.bars.time;
					
					mi = max(psth);
					
					[xi,yi]=ginput(1);
					[x1, y1] = local_nearest(xi(1),time,yi(1),psth);
					
					yi = find(psth == y1);
					yi = yi(1);
					
					psth = psth(1:yi);
					time = time(1:yi);
					
					t2 = linspace(time(1),time(end),200);
					
					psth = interp1(time,psth,t2);
					time = t2;
					
					if spdata.spont.baseline == 1
						psth = (psth/max(psth))*100;
					else
						psth = psth - psth(1);
						psth = (psth/max(psth))*100;
					end
					
					ii = find(psth >= spdata.spont.percent);
					if isempty(ii);
						ii = 1;
					end
					ii = ii(1);
					spdata.latency = time(ii);
					
					hold on
					line([spdata.latency spdata.latency],[0 m],'LineWidth',2);
					yy = ylim;
					text(mi,spdata.latency,['Latency=' num2str(spdata.latency) 'ms'],'FontSize',16,'FontWeight','bold','Color',[1 0 0]);
					hold off
					
				else
					helpdlg('You must first calculate the BARS curve...')
					return
				end
			
			case '2 STDDEVS'
				spdata.sigpoint=spdata.spont.mean+(2*spdata.spont.sd);
				a=find(psth>spdata.sigpoint);
				sigbin=0;
				for i=1:length(a) %for each bin over the significance point, if checks that 2 subs bins also significant
					if psth(a(i))>spdata.sigpoint & psth(a(i)+1)>spdata.sigpoint & psth(a(i)+2)>spdata.sigpoint
						sigbin=a(i);
						break
					end
				end
				if sigbin==0; %checks whether any significant points were found
					spdata.latency=[];
					errordlg('No significant response found, thus no latency value could be determined')
				else
					spdata.latency=time(sigbin);
					hold on
					line([spdata.latency spdata.latency],[min(psth) max(psth)],'LineWidth',2);
					text(min((time)+(max(time)/20)),(max(psth)-(max(psth)/20)),['Latency=' num2str(spdata.latency)],'FontSize',14);
					hold off
				end
				
			case '3 STDDEVS'
				spdata.sigpoint=spdata.spont.mean+(3*spdata.spont.sd);
				a=find(psth>spdata.sigpoint);
				sigbin=0;
				for i=1:length(a) %for each bin over the significance point, if checks that 2 subs bins also significant
					if psth(a(i))>spdata.sigpoint & psth(a(i)+1)>spdata.sigpoint & psth(a(i)+2)>spdata.sigpoint
						sigbin=a(i);
						break
					end
				end
				if sigbin==0; %checks whether any significant points were found
					spdata.latency=[];
					errordlg('No significant response found, thus no latency value could be determined')
				else
					spdata.latency=time(sigbin);
					hold on
					line([spdata.latency spdata.latency],[min(psth) max(psth)],'LineWidth',2);
					text(min((time)+(max(time)/20)),(max(psth)-(max(psth)/20)),['Latency=' num2str(spdata.latency)],'FontSize',14);
					hold off
				end
				
			otherwise % we are using the poisson, thus laoptions has given us our values already
				a=find(psth>spdata.spont.bin1);
				sigbin=0;
				for i=1:length(a)
					if psth(a(i))>spdata.spont.bin1 & psth(a(i)+1)>spdata.spont.bin2 & psth(a(i)+2)>spdata.spont.bin3
						sigbin=a(i);
						break
					end
				end
				if sigbin==0; %checks whether any significant points were found
					spdata.latency=[];
					errordlg('No significant response found, thus no latency value could be determined')
				else
					spdata.latency=time(sigbin);
					hold on
					line([spdata.latency spdata.latency],[min(psth) max(psth)],'LineWidth',1);
					text(min((time)+(max(time)/20)),(max(psth)-(max(psth)/20)),['Latency=' num2str(spdata.latency)],'FontSize',12);
					hold off
				end
		end
		
		%------------------------------------------------------------------------------------------
	case 'Linearity Test'
		%------------------------------------------------------------------------------------------
		
		if data.wrapped==0 || isempty(data.tempfreq)
			errordlg('Sorry, data needs to be wrapped with a known temporal frequency to perform this analysis')
			return
		end
		
		x=get(gh('SPXBox'),'Value');
		y=get(gh('SPYBox'),'Value');
		z=sv.zval;
		
		rawspikes=data.rawspikes{y,x,z}/1000; %get raw spikes in seconds
		spikesInStim=length(rawspikes);
		
		VS = (sqrt((sum(sin(2*pi*data.tempfreq*rawspikes)))^2 + (sum(cos(2*pi*data.tempfreq*rawspikes)))^2))/spikesInStim;
		Z = spikesInStim*(VS^2);                                     % Rayleigh Statistic
		
		modtime=data.modtime/10000; %convert our modtime to seconds
		pspikes=rawspikes/modtime; %convert our spikes into modulation time
		pspikes=pspikes*(2*pi); %convert into radians
		
		[t,r,d]=circmean(pspikes);
		[p,rr]=rayleigh(pspikes);
		
		spdata.linfo=['Vector Sum:' num2str(VS) ' : ' num2str(r) ' R: ' num2str(Z) ' : ' num2str(p) ' (#:' num2str(spikesInStim) ')'];
		spdata.changetitle=1;
		splot('Plot')
		
		%------------------------------------------------------------------------------------------
	case 'FFT Power Spectrum'
		%------------------------------------------------------------------------------------------
		
		figure
		x=get(gh('SPXBox'),'Value');
		y=get(gh('SPYBox'),'Value');
		z=sv.zval;
		maxtime=(max(data.time{1})+data.binwidth)/1000;
		numtrials=data.raw{y,x,z}.numtrials;
		nummods=data.raw{y,x,z}.nummods;
		binwidth=data.binwidth;
		if data.wrapped==1
			trialmod=numtrials*nummods;
		else
			trialmod=numtrials;
		end
		if data.numvars > 1;
			time=(max(data.time{y,x,z})+data.binwidth)/1000;  %convert into seconds
			psth=data.psth{y,x,z};
		else
			time=(max(data.time{x})+data.binwidth)/1000;  %convert into seconds
			psth=data.psth{x};
		end
		
		[a,f,p,d]=fftplot2(psth,time);
		a=a/trialmod;
		a=(a/binwidth)*1000;
		area(f,a,'FaceColor',[1 0 0],'EdgeColor',[1 0 0]);
		ratio='';
		if isfield(data,'tempfreq')
			ind=find(round(f)==data.tempfreq);
			if ind~=0
				ratio=[' - f0/f1=' num2str(a(1)/a(ind))];
				clipboard('copy',sprintf('%2.3f',a(1)/a(ind)));
			end
		end
		String=get(gh('SPXBox'),'String');
		x=String{x};
		String=get(gh('SPYBox'),'String');
		y=String{y};
		xt=data.xtitle;
		if data.numvars > 1;
			yt=data.ytitle;
		else
			yt='';
		end
		String=get(gh('DataBox'),'String');
		dt=String{1};
		o=[data.runname '[ ' xt ':' x ' / ' yt ':' y ' ] ' dt ratio];
		title(o);
		
		%------------------------------------------------------------------------------------------
	case 'Spawn'
		%------------------------------------------------------------------------------------------
		
		figure;
		splot('Plot');
		figpos(1,[700 600]);
		set(gcf,'Color',[1 1 1]);
		a=axis;
		
	case 'Exit'
		
		clear spdata
		close(gcf)
		
end  %----------------------------end of the main switch-----------------------------------



%##################################################################
% Additional Helper Functions
%##################################################################

	function [time,psth,bpsth,tpsth] = selectPSTH(x,y,z)
		time=data.time{y,x,z};
		psth=data.psth{y,x,z};
		bpsth=data.bpsth{y,x,z};
		tpsth = psth - bpsth;
		
		mini = find(time == sv.mint);
		maxi = find(time == sv.maxt);
		
		time = time(mini:maxi);
		psth = psth(mini:maxi);
		bpsth = bpsth(mini:maxi);
		tpsth = tpsth(mini:maxi);
	end

end