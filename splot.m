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

if nargin<1;
	action='Initialize';
end

switch(action)	%As we use the GUI this switch allows us to respond to the user input
	
	%---------------------------------------------------------------------------------
case 'Initialize'
	%---------------------------------------------------------------------------------
	
	version=['Single PSTH Plot: V1.0.3 | Started - ',datestr(now)];
	splotfig;			%our GUI file
	set(gcf,'Name', version);
	spdata.spont=[]; %initialise spontaneous measurement
	spdata.latency=0;
	spdata.linfo=[];
	spdata.changetitle=0;
	
	if ~exist('data','var')
		errordlg('Sorry, cannot find data. You need to call this after you have loaded data using Spikes');
		return
	end
	
	if data.numvars > 1
		set(gh('XBox'),'String',{num2str(data.xvalues')});
		set(gh('XBox'),'Value',ceil(data.xrange/2));
		set(gh('YBox'),'String',{num2str(data.yvalues')});
		set(gh('YBox'),'Value',ceil(data.yrange/2));
	elseif data.numvars > 0
		set(gh('XBox'),'String',{num2str(data.xvalues')});
		set(gh('XBox'),'Value',ceil(data.xrange/2));
		set(gh('YBox'),'Enable','off');
		set(gh('YBox'),'String',{'1'});
	else
		set(gh('YBox'),'Enable','off');
		set(gh('YBox'),'String',{'1'});
		set(gh('XBox'),'Enable','off');
		set(gh('XBox'),'String',{'1'});
	end
	
	set(gh('SmoothEdit'),'String',num2str(data.binwidth*2));
	
	set(gh('DataBox'),'String',{'All Spikes';'Burst Spikes';'Both Types'});
	set(gh('DataBox'),'Value',3);
	set(gh('TypeBox'),'String',{'Bar Plot';'Area Plot';'Gaussian Smooth';'Loess Curve'});
	set(gh('SPAnalMenu'),'String',{'None';'FFT Power Spectrum';'Linearity Test';'Get Spontaneous';'Latency Analysis'}); %;'Latency Analysis';'Ratio of Bursts'});
	splot('Plot') %actually plot what we have
	
	%---------------------------------------------------------------------------------
case 'Reload'  %simply reinitialise if we've loaded new stuff in spikes
	%---------------------------------------------------------------------------------
	
	if ~exist('data','var')
		errordlg('Sorry, cannot find data. You need to call this after you have loaded data using Spikes');
		return
	end
	
	if data.numvars > 1
		set(gh('XBox'),'String',{num2str(data.xvalues')});
		set(gh('XBox'),'Value',ceil(data.xrange/2));
		set(gh('YBox'),'String',{num2str(data.yvalues')});
		set(gh('YBox'),'Value',ceil(data.yrange/2));
	elseif data.numvars > 0
		set(gh('XBox'),'String',{num2str(data.xvalues')});
		set(gh('XBox'),'Value',ceil(data.xrange/2));
		set(gh('YBox'),'Enable','off');
		set(gh('YBox'),'String',{'1'});
	else
		set(gh('YBox'),'Enable','off');
		set(gh('YBox'),'String',{'1'});
		set(gh('XBox'),'Enable','off');
		set(gh('XBox'),'String',{'1'});
	end
	
	set(gh('DataBox'),'String',{'All Spikes';'Burst Spikes';'Both Types'});
	set(gh('DataBox'),'Value',3);
	set(gh('TypeBox'),'String',{'Bar Plot';'Stair Plot';'Gaussian Smooth';'Loess Curve'});
	set(gh('SPAnalMenu'),'String',{'None';'FFT Power Spectrum';'Linearity Test';'Get Spontaneous';'Latency Analysis'}); %;'Latency Analysis';'Ratio of Bursts'});
	splot('Plot') %actually plot what we have
	spdata.linfo=[];
	
	%---------------------------------------------------------------------------------
case 'Plot' %do da stuff
	%---------------------------------------------------------------------------------
	
    cla
    
	x=get(gh('XBox'),'Value');
	y=get(gh('YBox'),'Value');
	z=sv.zval;
	
	time=data.time{y,x,z};
	psth=data.psth{y,x,z};
	bpsth=data.bpsth{y,x,z};
	
	datatype=get(gh('DataBox'),'Value');
	plottype=get(gh('TypeBox'),'Value');
	
	m=max(psth);%--------------------------works out firing rate
	m=(m/data.binwidth)*1000;
	if data.wrapped==0
		m=m/data.raw{y,x,z}.numtrials;
	else
		m=m/(data.raw{y,x,z}.numtrials*data.raw{y,x,z}.nummods);
	end
	mb=max(bpsth);
	mb=(mb/data.binwidth)*1000;
	if data.wrapped==0
		mb=mb/data.raw{y,x,z}.numtrials;
	else
		mb=mb/(data.raw{y,x,z}.numtrials*data.raw{y,x,z}.nummods);
	end %---------------------------------------------------------
	
	switch(datatype)
		
	case 1 %all spikes
		
		switch(plottype)
			
		case 1 %barplot
			bar(time,psth,1,'k');
			axis tight;
			ylabel(['Spikes / Bin (Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.raw{1}.numtrials) ' Mods:' num2str(data.raw{1}.nummods) ')' ]);
			ww=[time',psth'];
			save c:\psth.txt  ww -ascii
		case 2 % area
			h=area(time,psth);
			set(h,'FaceColor',[0 0 0]);
			axis tight;
			ylabel(['Spikes / Bin (Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.raw{1}.numtrials) ' Mods:' num2str(data.raw{1}.nummods) ')' ]);
			ww=[time',psth'];
			save c:\psth.txt  ww -ascii
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
			save c:\psth.txt  ww -ascii
		case 4 %loess
			if max(psth)>0;psth=(psth/max(psth))*m;end
			lss=str2num(get(gh('LoessEdit'),'String'));
			resolution=length(psth)*2;
			spdata.times=linspace(min(time),max(time),resolution);
			spdata.psths=loess(time,psth,spdata.times,lss,1);
			if max(spdata.psths)==0 & max(psth)>0	 %says that loess has smoothed to 0
				errordlg(['You may need to increase the Loess smoothing parameter from:' lss])
				error('Loess value too small')
			end
			h=area(spdata.times,spdata.psths);
			set(h,'FaceColor',[0 0 0]);
			axis tight;
			ylabel('Instantaneous Firing Rate (Hz)')
			ww=[spdata.times',spdata.psths'];
			save c:\psth.txt  ww -ascii
		end
		
	case 2 % burst spikes
		
		switch(plottype)
			
		case 1 %bar
			bar(time,bpsth,1,'k');
			axis tight;
			ylabel(['Spikes / Bin (Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.raw{1}.numtrials) ' Mods:' num2str(data.raw{1}.nummods) ')' ]);
			ww=[time',bpsth'];
			save c:\burstpsth.txt  ww -ascii
		case 2 %area
			h=area(time,bpsth);
			set(h,'FaceColor',[0 0 0]);
			axis tight;
			ylabel(['Spikes / Bin (Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.raw{1}.numtrials) ' Mods:' num2str(data.raw{1}.nummods) ')' ]);
			ww=[time',bpsth'];
			save c:\burstpsth.txt  ww -ascii
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
			save c:\burstpsth.txt  ww -ascii
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
			save c:\burstpsth.txt  ww -ascii
		end
		
	case 3 %both spikes
		
		switch(plottype)
			
		case 1 %bar
			bar(time,psth,1,'k');
			hold on
			bar(time,bpsth,1,'r');
			hold off
			legend('All Spikes','Burst Spikes',0)
			axis tight
			ylabel(['Spikes / Bin (Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.raw{1}.numtrials) ' Mods:' num2str(data.raw{1}.nummods) ')' ]);
			ww=[time',psth'];
			www=[time',bpsth'];
			save c:\psth.txt  ww -ascii
			save c:\burstpsth.txt  www -ascii
		case 2 %area
			h=area(time,psth);
			set(h,'FaceColor',[0 0 0]);
			hold on
			h=area(time,bpsth);
			set(h,'FaceColor',[1 0 0]);
			hold off
			legend('All Spikes','Burst Spikes',0)
			axis tight
			ylabel(['Spikes / Bin (Binwidth:' num2str(data.binwidth) 'ms Trials:' num2str(data.raw{1}.numtrials) ' Mods:' num2str(data.raw{1}.nummods) ')' ]);
			ww=[time',psth'];
			www=[time',bpsth'];
			save c:\psth.txt  ww -ascii
			save c:\burstpsth.txt  www -ascii
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
			save c:\psth.txt  ww -ascii
			save c:\burstpsth.txt  www -ascii
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
			save c:\psth.txt  ww -ascii
			save c:\burstpsth.txt  www -ascii
		end
	end
	
	String=get(gh('XBox'),'String');
	x=String{x};
	String=get(gh('YBox'),'String');
	y=String{y};
	xt=data.xtitle;
	if data.numvars > 1;
		yt=data.ytitle;
	else
		yt='';
	end
	String=get(gh('DataBox'),'String');
	dt=String{datatype};
	
	o=[data.runname '[ ' xt ':' x ' / ' yt ':' y ' ] ' dt];
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
	
	%------------------------------------------------------------------------------------------
case 'None' %null entry in menu
	%------------------------------------------------------------------------------------------
	
	
	%------------------------------------------------------------------------------------------
case 'Get Spontaneous'
	%------------------------------------------------------------------------------------------
	
	spdata.spont=[];
	data.spontaneous=[];
	
	x=get(gh('XBox'),'Value');
	y=get(gh('YBox'),'Value');
	z=sv.zval;
	datatype=get(gh('DataBox'),'Value');
	plottype=get(gh('TypeBox'),'Value');
	
	[mint,maxt]=measure(data,x,y);
	%this if loop selects where are data is (depends on whether it was smoothed etc)	
	if datatype==2 %bursts
		if plottype==1 | plottype==2 %no smoothing so just raw psths
			time=data.time{y,x,z};
			psth=data.psth{y,x,z};
		elseif plottype==3
			time=data.time{y,x,z};
			psth=spdata.psths;
		elseif plottype==4
			time=spdata.times;
			psth=spdata.psths;
		end
	else %all spikes
		if plottype==1 | plottype==2 %no smoothing so just raw psths
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
	
	mini=find(time==mint);
    maxi=find(time==maxt);
    
    psth=psth(mini:maxi);
    
    [spdata.spont.mean,spdata.spont.sd]=stderr(psth,'SD'); %get mean and s.d.
	[tmean,spdata.spont.se]=stderr(psth); %get mean and s.e.	
    
    %------this block gets confidence intervals from a poisson distribution	
    [spdata.spont.ci05]=poissinv([0.025 0.975],spdata.spont.mean);		%p=0.05
    [spdata.spont.ci025]=poissinv([0.0125 0.9875],spdata.spont.mean);	%p=0.025
    [spdata.spont.ci01]=poissinv([0.005 0.995],spdata.spont.mean);		%p=0.01
    [spdata.spont.ci005]=poissinv([0.0025 0.9975],spdata.spont.mean);	%p=0.005
    [spdata.spont.ci001]=poissinv([0.0005 0.9995],spdata.spont.mean);	%p=0.001
    spdata.spont.bin1=spdata.spont.ci01(2); %sets defaults to p=0.01
    spdata.spont.bin2=spdata.spont.ci01(2);
    spdata.spont.bin3=spdata.spont.ci05(2);
    %--------------------------------------------------------------
    
    t1=['Spontaneous is: ' num2str(spdata.spont.mean) '+-' num2str(spdata.spont.sd) 'S.D. spikes/bin'];
    t2=['2*S.D. Significance Limit: ' num2str(spdata.spont.mean+(2*spdata.spont.sd)) ' spikes/bin'];
    cil=num2str(spdata.spont.ci01(1));
    ciu=num2str(spdata.spont.ci01(2));
    t3=['0.01 Confidence Interval from a Poisson: ' cil '-' ciu ' spikes/bin'];
    t4=['These Values has been stored in the data structure, and can automatically be used with the latency analysis'];
    t={t1;t2;t3;t4};
	
	data.spontaneous.mean=spdata.spont.mean;
	data.spontaneous.sd=spdata.spont.sd;
	data.spontaneous.se=spdata.spont.se;
	data.spontaneous.limit=spdata.spont.mean+(2*spdata.spont.sd);
	data.spontaneous.limitse=spdata.spont.mean+(2*spdata.spont.se);
	data.spontaneous.poisson=spdata.spont.ci01(2);
	
	data.spontaneous.meant=converttotime(spdata.spont.mean);
	data.spontaneous.sdt=converttotime(spdata.spont.sd);
	data.spontaneous.sdt=converttotime(spdata.spont.se);
	data.spontaneous.limitt=converttotime(spdata.spont.mean+(2*spdata.spont.sd));
	data.spontaneous.limitset=converttotime(spdata.spont.mean+(2*spdata.spont.se));
	data.spontaneous.poissont=converttotime(spdata.spont.ci01(2));
    
    helpdlg(t,'Spontaneous Values');
    
    %------------------------------------------------------------------------------------------
case 'Latency Analysis'
    %------------------------------------------------------------------------------------------
	
	laoptions;	%our GUI to select options etc. - puts its values in spdata
		
	x=get(gh('XBox'),'Value');
	y=get(gh('YBox'),'Value');
	z=sv.zval;
	datatype=get(gh('DataBox'),'Value');
	plottype=get(gh('TypeBox'),'Value');
	
	%this if loop selects where are data is (depends on whether it was smoothed etc)	
	if datatype==2 %bursts
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
	
	switch spdata.method
		
	case '2 STDDEVS'
		spdata.sigpoint=spdata.spont.mean+(2*spdata.spont.sd);
		a=find(psth>spdata.sigpoint);        
		sigbin=0;
		for i=1:length(a) %for each bin over the significance point, if checks that 2 subs bins also significant
			if psth(a(i))>spdata.sigpoint & psth(a(i)+1)>spdata.sigpoint & psth(a(i)+2)>spdata.sigpoint
				sigbin=a(i);
				return
			end			
		end
		if sigbin==0; %checks whether any significant points were found
			spdata.latency=[];
			errordlg('No significant response found, thus no latency value could be determined')
		else
			spdata.latency=time(sigbin);
			hold on
			line([spdata.latency spdata.latency],[min(psth) max(psth)],'LineWidth',2);
			text(min((time)+(max(time)/20)),(max(psth)-(max(psth)/20)),['Latency=' num2str(spdata.latency)]);
			hold off
		end
		
	case '3 STDDEVS'
        spdata.sigpoint=spdata.spont.mean+(3*spdata.spont.sd);
		a=find(psth>spdata.sigpoint);
		sigbin=0;
		for i=1:length(a) %for each bin over the significance point, if checks that 2 subs bins also significant
			if psth(a(i))>spdata.sigpoint & psth(a(i)+1)>spdata.sigpoint & psth(a(i)+2)>spdata.sigpoint
				sigbin=a(i);
				return
			end			
		end
		if sigbin==0; %checks whether any significant points were found
			spdata.latency=[];
			errordlg('No significant response found, thus no latency value could be determined')
		else
			spdata.latency=time(sigbin);
			hold on
			line([spdata.latency spdata.latency],[min(psth) max(psth)],'LineWidth',2);
			text(min((time)+(max(time)/20)),(max(psth)-(max(psth)/20)),['Latency=' num2str(spdata.latency)]);
			hold off
		end
		
    otherwise % we are using the poisson, thus laoptions has given us our values already        
		a=find(psth>spdata.spont.bin1);      
		sigbin=0;
		for i=1:length(a)
			if psth(a(i))>spdata.spont.bin1 & psth(a(i)+1)>spdata.spont.bin2 & psth(a(i)+2)>spdata.spont.bin3
				sigbin=a(i);
				return
			end			
		end
        if sigbin==0; %checks whether any significant points were found
			spdata.latency=[];
			errordlg('No significant response found, thus no latency value could be determined')
		else
			spdata.latency=time(sigbin);
			hold on
			line([spdata.latency spdata.latency],[min(psth) max(psth)],'LineWidth',2);
			text(min((time)+(max(time)/20)),(max(psth)-(max(psth)/20)),['Latency=' num2str(spdata.latency)]);
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
	
	x=get(gh('XBox'),'Value');
	y=get(gh('YBox'),'Value');
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
	x=get(gh('XBox'),'Value');
	y=get(gh('YBox'),'Value');
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
	String=get(gh('XBox'),'String');
	x=String{x};
	String=get(gh('YBox'),'String');
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
	if spdata.latency>0
		hold on;
		line([spdata.latency spdata.latency],[a(3) a(4)],'LineWidth',2);
		text((a(1)+(a(2)/20)),(a(4)-(a(4)/20)),['Latency=' num2str(spdata.latency)]);
		hold off;
	end
	
case 'Exit'
	
	close(gcf)
	
end  %----------------------------end of the main switch-----------------------------------



%##################################################################
% Additional Helper Functions
%##################################################################

function out=converttotime(in)
	global data
	if data.wrapped==1 %wrapped
		in=in/(data.raw{1}.numtrials*data.raw{1}.nummods); %we have to get the values for an individual trial
	elseif data.wrapped==2
		in=in/(data.raw{1}.numtrials);
	end
	
	out=(in/data.binwidth)*1000;







