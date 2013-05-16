function opro(action)

%***************************************************************
%
%  Orban PRO, Works out statistics for receptive field changes
%
%     Completely GUI, not run-line commands needed
%
% [ian] 1.01 use paired t-test instead of independant samples
% [ian] 1.5 Updated for Matlab 9
% [ian] 1.6 big changes for bootstrap
%
%***************************************************************

global o

if nargin<1;
	action='Initialize';
end
%===============================Start Here=====================================
switch(action)    %As we use the GUI this switch allows us to respond to the user input

	%-----------------------------------------------------------------------------------------
case 'Initialize'
	%-----------------------------------------------------------------------------------------
	
	set(0,'DefaultTextFontSize',7);
	set(0,'DefaultAxesLayer','top');
	set(0,'DefaultAxesTickDir','out');
	set(0,'DefaultAxesTickDirMode','manual');
	h=opro_UI; %this is the GUI figure
	set(h,'Name', 'Orban-Pro Spike Statistics V1.80');
	set(gh('OPStatsMenu'),'String',{'1D Gaussian';'2D Gaussian';'Vector';'---------';'M: Dot Product';'M: Spearman Correlation';'M: Pearsons Correlation';'M: 1-Way Anova';'M: Paired T-test';'M: Kolmogorov-Smirnof Distribution Test';'M: Ansari-Bradley Variance';'M: Fano T-test';'M: Fano Wilcoxon';'M: Fano Paired Wilcoxon';'M: Fano Spearman';'---------';'Column: Spontaneous';'---------';'I: Paired T-test';'I: Paired Sign Test';'I: Wilcoxon Rank Sum';'I: Wilcoxon Paired Test';'I: Spearman Correlation';'I: Pearsons Correlation';'I: 1-Way Anova';'I: Kolmogorov-Smirnof Distribution Test'});
	set(gh('NormaliseMenu'),'String',{'none';'% of Max';'% of 3 Bin Max';'Z-Score'});
	set(gh('OPPlotMenu'),'String',{'p-value';'Hypothesis Test';'r correlation';'r2 correlation';'1-r correlation'});
	set(gh('AlphaEdit'),'String','0.05');
	o=[];
	o.text=[];
	o.ax1pos=get(gh('Cell1Axis'),'Position');
	o.ax2pos=get(gh('Cell2Axis'),'Position');
	o.ax3pos=get(gh('OutputAxis'),'Position');
	
	%-----------------------------------------------------------------------------------------
case 'Load'
	%-----------------------------------------------------------------------------------------
	
	[file path]=uigetfile('*.*','Load 1st Processed Matrix:');
	if file==0; error('1st File appears empty.'); end;
	ax1=o.ax1pos;
	ax2=o.ax2pos;
	ax3=o.ax3pos;
	o=[];
	o.ax1pos=ax1;
	o.ax2pos=ax2;
	o.ax3pos=ax3;
	o.text=[];
	o.cell1=[];
	o.cell2=[];
	o.spontaneous=0;
	set(gh('StatsText'),'String','Statistical Results:');
	cd(path);
	op=pwd;
	[poo,poo2,ext]=fileparts(file);
	if regexpi(ext,'.txt')
		dos(['"C:\Program Files\Frogbit\frogbitrun.exe" "C:\Program Files\Frogbit\ostrip.FB" "' [path file] '"'])
		cd('c:\');   %where frogbit saves the temporary info file
		[header,var]=hdload('otemp');  % Loads the frogbit data file
		cd(op);
		o.filetype='text';
		o.spiketype='none';
		set(gh('InfoText'),'String','Text File Loading');
		o.cell1.matrix=var(2:end,2:end);
		o.cell1.max=max(max(o.cell1.matrix));
		o.cell1.filename=header(1:(find(header==':')+1));
		o.cell1.xvalues=var(1,2:end);     %here are the tags
		a=find(o.cell1.xvalues < 0.001 & o.cell1.xvalues>-0.001);
		o.cell1.xvalues(a)=0;
		o.cell1.yvalues=var(2:end,1)';
		a=find(o.cell1.xvalues < 0.001 & o.cell1.xvalues>-0.001);
		o.cell1.yvalues(a)=0;
		o.cell1.xrange=length(o.cell1.xvalues);
		o.cell1.yrange=length(o.cell1.yvalues);
	elseif regexpi(ext,'.mat')
		set(findobj('UserData','PSTH'),'Enable','On');
		o.filetype='mat';
		o.spiketype='none';
		set(gh('InfoText'),'String','Spike Data Loading');
		s1=load(file);
		t=find(s1.data.filename=='/');
		s1.data.filename=[s1.data.filename((t(end-2))+1:t(end)) ':' num2str(s1.data.cell)];
		o.cell1=s1.data;
		clear s1
	else
		error('Strange File type tried')
		errordlg('Strange File Type, you can only load .txt files from VS or .mat file from Spikes');
	end
	
	[file path]=uigetfile('*.*','Load 2nd Processed Matrix:');
	if file==0; error('2nd File appears empty.'); end;
	cd(path);
	[poo,poo2,ext]=fileparts(file);
	if regexpi(ext,'.txt')
		dos(['"C:\Program Files\Frogbit\frogbitrun.exe" "C:\Program Files\Frogbit\ostrip.FB" "' [path file] '"'])
		cd('c:\');   %where frogbit saves the temporary info file
		[header,var]=hdload('otemp');  % Loads the frogbit data file
		cd(op)
		if strcmp(o.filetype,'mat');errordlg('Cannot Load Text and Mat together');error('Cannot Load Text and Mat together');end;
		o.cell2.filename=header(1:(find(header==':')+1));
		o.cell2.matrix=var(2:end,2:end);
		o.cell2.max=max(max(o.cell2.matrix));
		o.normalise=0;
		o.cell2.xvalues=var(1,2:end);     %here are the tags
		a=find(o.cell2.xvalues < 0.001 & o.cell2.xvalues>-0.001);
		o.cell2.xvalues(a)=0;
		o.cell2.yvalues=var(2:end,1)';
		a=find(o.cell2.xvalues < 0.001 & o.cell2.xvalues>-0.001);
		o.cell2.yvalues(a)=0;
		o.cell2.xrange=length(o.cell2.xvalues);
		o.cell2.yrange=length(o.cell2.yvalues);
	elseif regexpi(ext,'.mat')
		set(findobj('UserData','PSTH'),'Enable','On');
		if strcmp(o.filetype,'text');errordlg('Cannot Load Text and Mat together');error('Cannot Load Text and Mat together');end;
		s2=load(file);
		t=find(s2.data.filename=='/');
		s2.data.filename=[s2.data.filename((t(end-2))+1:t(end)) ':' num2str(s2.data.cell)];
		o.cell2=s2.data;
		clear s2;
	else
		error('Strange File type tried')
		errordlg('Strange File Type, you can only load .txt files from VS or .mat file from Spikes');
	end
	
	if o.cell1.xvalues~=o.cell2.xvalues
		errordlg('Sorry,the two cells seem to have different Variables');
		error('Mismatch between cells');
	end
	
	if o.cell1.yvalues~=o.cell2.yvalues
			errordlg('Sorry,the two cells seem to have different Variables');
			error('Mismatch between cells');
	end
	
	if ~isfield(o.cell1,'xindex')
		o.cell1.xindex=[1:o.cell1.xrange];
	end
	if ~isfield(o.cell2,'xindex')
		o.cell2.xindex=[1:o.cell2.xrange];
	end
	if ~isfield(o.cell1,'yindex')
		o.cell1.yindex=1:o.cell1.yrange;	
	end
	if ~isfield(o.cell2,'yindex')
		o.cell2.yindex=1:o.cell2.yrange;
	end
	if ~isfield(o.cell1,'zindex')
		o.cell1.zindex=1:o.cell1.zrange;	
	end
	if ~isfield(o.cell2,'zindex')
		o.cell2.zindex=1:o.cell2.zrange;
	end
	
	updategui();

	%-----------------------------------------------------------------------------------------
case 'Reparse'
	%-----------------------------------------------------------------------------------------
	starttrial=get(gh('StartTrialMenu'),'Value');
	endtrial=get(gh('EndTrialMenu'),'Value');
	binwidth=str2num(get(gh('BinWidthEdit'),'String'));
	options.Resize='on';
	options.WindowStyle='normal';
	options.Interpreter='tex';
	prompt = {'Choose Cell 1 variables to merge (ground):','Choose Cell 2 variables to merge (figure):','Sigma'};
	dlg_title = 'REPARSE DATA VARIABLES';
	num_lines = [1 100];
	if isfield(o,'map')
		def = {num2str(o.map{1}), num2str(o.map{2}), '0'};
	else
		def = {'1 2','7 8','0'};
	end
	answer = inputdlg(prompt,dlg_title,num_lines,def,options);
	groundmap = str2num(answer{1});
	figuremap = str2num(answer{2});
	sigma = str2num(answer{3});
	
	map{1}=groundmap;
	map{2}=figuremap;
	o.map = map;
	
	if isfield(o,'cell1bak');
		o.cell1 = o.cell1bak; o = rmfield(o,'cell1bak');
	end
	if isfield(o,'cell2bak');
		o.cell2 = o.cell2bak; o = rmfield(o,'cell2bak');
	end
	
	o.fano1 = [];
	o.fano2 = [];
	
	o.fano1 = fanoPlotter;
	o.fano2 = fanoPlotter;
	
	o.fano1.convertSpikesFormat(o.cell1, map{1});
	o.fano2.convertSpikesFormat(o.cell2, map{2});
	
	for i = 1:2
		c = o.(['cell' num2str(i)]);
		vars = sort( map{i} );
		raw = c.raw{vars(1)};
		if get(gh('OPAllTrials'), 'Value') < 1
			raw.totaltrials = (endtrial-starttrial)+1;
			raw.numtrials = raw.totaltrials;
			raw.starttrial = 1;
			raw.endtrial = raw.numtrials;
			raw.trial = raw.trial(starttrial:endtrial);
			raw.btrial = raw.btrial(starttrial:endtrial);
			raw.tDelta = raw.tDelta(starttrial:endtrial);
		end
		for j = 2:length(vars)
			rawn = c.raw{vars(j)};
			if get(gh('OPAllTrials'), 'Value') < 1
				rawn.totaltrials = (endtrial-starttrial)+1;
				rawn.numtrials = rawn.totaltrials;
				rawn.starttrial = 1;
				rawn.endtrial = rawn.numtrials;
				rawn.trial = rawn.trial(starttrial:endtrial);
				rawn.btrial = rawn.btrial(starttrial:endtrial);
				rawn.tDelta = rawn.tDelta(starttrial:endtrial);
			end
			raw.name = [raw.name '|' rawn.name];
			raw.totaltrials = raw.totaltrials + rawn.totaltrials;
			raw.numtrials = raw.numtrials + rawn.numtrials;
			raw.endtrial = raw.numtrials;
			raw.trial = [raw.trial, rawn.trial];
			raw.maxtime = max([raw.maxtime, c.raw{vars(j)}.maxtime]);
			raw.tDelta = [raw.tDelta; rawn.tDelta];
			raw.btrial = [raw.btrial, rawn.btrial];
		end
			
		c.raw = {};
		c.raw{1} = raw;
		c.xrange = 1;
		c.xtitle = 'Meta1';
		c.xvalues = [5];
		c.xvalueso = c.xvalues;
		c.xindex = c.xrange; 		
		c.yrange = 1;
		c.ytitle = 'Meta2';
		c.yvalues = [5];
		c.yvalueso = c.yvalues;
		c.yindex = c.yrange;

		[time,psth,rawspikes,sums]=binit(raw,binwidth*10, raw.startmod, raw.endmod, raw.starttrial, raw.endtrial, 0);
		[time2,bpsth]=binitb(raw,binwidth*10, raw.startmod, raw.endmod, raw.starttrial, raw.endtrial, 0);
		if sigma > 0
			psth=gausssmooth(time,psth,sigma);
			bpsth=gausssmooth(time2,bpsth,sigma);
		end
		
		c.matrix = mean(psth);
		c.errormat = std(psth);
		
		c.bpsth = {};
		c.bpsth{1}=bpsth;
		c.psth = {};
		c.psth{1}=psth;
		c.time = {};
		c.time{1}=time;
		c.rawspikes = {};
		c.rawspikes{1}=rawspikes;
		c.sums = {};
		c.sums{1}=sums;
		c.names = {};
		c.numtrials = c.raw{1}.numtrials;
		c.names{1} = raw.name;
		if ~isfield(o,['cell' num2str(i) 'bak']);
			o.(['cell' num2str(i) 'bak']) = o.(['cell' num2str(i)]);
		end
		o.(['cell' num2str(i)]) = c;
	end
	
	set(gh('WrappedBox'), 'Value', 0);
	set(gh('OPAllTrials'), 'Value', 1);
	set(gh('OPShowPlots'), 'Value', 1);
	set(gh('OPMeasureMenu'), 'Value', 2);
	o.spiketype = 'psth';
	
	opro('Spontaneous')
	opro('Measure')
	updategui()
	
	o.fano1.analyse
	set(gcf,'Name','FanoM CELL 1')
	o.fano2.analyse
	set(gcf,'Name','FanoM CELL 2')
	
	%-----------------------------------------------------------------------------------------
case 'Normalise'
	%-----------------------------------------------------------------------------------------
	
	if strcmp(o.filetype,'text')
		if o.normalise==0
			o.cell1.matrix=(o.cell1.matrix/o.cell1.max)*100;
			o.cell2.matrix=(o.cell2.matrix/o.cell2.max)*100;
			o.normalise=1;
		else
			o.cell1.matrix=(o.cell1.matrix/100)*o.cell1.max;
			o.cell2.matrix=(o.cell2.matrix/100)*o.cell2.max;
			o.normalise=0;
		end
		m=max(max(max(o.cell1.matrix)),max(max(o.cell2.matrix)));
		axes(gh('Cell1Axis'));
		imagesc(o.cell1.xvalues,o.cell1.yvalues,o.cell1.matrix);
		if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
		if o.cell1.yvalues(1) < o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
		colormap(hot);
		set(gca,'Tag','Cell1Axis');
		colorbar('peer',gh('Cell1Axis'),'FontSize',7);	
		axes(gh('Cell2Axis'));
		imagesc(o.cell2.xvalues,o.cell2.yvalues,o.cell2.matrix);
		if o.cell2.xvalues(1) > o.cell2.xvalues(end);set(gca,'XDir','reverse');end
		if o.cell2.yvalues(1) < o.cell2.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
		colormap(hot);
		set(gca,'Tag','Cell2Axis');
		colorbar('peer',gh('Cell2Axis'),'FontSize',7);	
		axes(gh('OutputAxis'));
		plot(0,0);
		set(gca,'Tag','OutputAxis');
		set(gh('OutputAxis'),'Position',o.ax3pos);	
	end
		
	
	%-----------------------------------------------------------------------------------------
case 'Measure'
	%-----------------------------------------------------------------------------------------
	
	set(gh('StatsText'),'String','');
	if isempty(o)
		errordlg('Sorry, you have not loaded any data yet!')
		error('MeasureError')
	end
	if strcmp(o.filetype,'text')
		errordlg('Sorry, you cannot measure PSTH on a text file!')
		error('MeasureError')
	end
	
	%-----set up some run variables
	o.cell1spike=[];
	o.cell2spike=[];
	o.cell1time=[];
	o.cell2time=[];
	o.hmatrix=[];
	o.pmatrix=[];
	o.rmatrix=[];
	o.r2matrix=[];
	o.rimatrix=[];
	set(gh('SP1Edit'),'String','-1');
	set(gh('SP2Edit'),'String','-1');
	xhold=get(gh('OPHoldX'),'Value');
	yhold=get(gh('OPHoldY'),'Value');
	zhold=get(gh('OPHoldZ'),'Value');
	binwidth=str2num(get(gh('BinWidthEdit'),'String'));
	wrapped=get(gh('WrappedBox'),'Value');
	ccell=get(gh('OPCellMenu'),'Value');
	sigma = str2num(get(gh('OPSigma'),'String'));
	Normalise=get(gh('NormaliseMenu'),'Value');
	starttrial=get(gh('StartTrialMenu'),'Value');
	endtrial=get(gh('EndTrialMenu'),'Value');
	if get(gh('OPAllTrials'),'Value') > 0
		starttrial = 1;
		endtrial = inf;
	end
	
	if ccell==1 %choose our cell
		sd=o.cell1.raw{o.cell1.yindex(yhold),o.cell1.xindex(xhold)};
	else
		sd=o.cell2.raw{o.cell2.yindex(yhold),o.cell2.xindex(xhold)};
	end
	
	if binwidth==0;
		[time,psth]=binit(sd,5*10,1,inf,starttrial,endtrial,wrapped); %use 5ms bin just to define area
		[mint,maxt]=measureq(time,psth,5);
	else
		[time,psth]=binit(sd,binwidth*10,1,inf,starttrial,endtrial,wrapped);
		[mint,maxt]=measureq(time,psth,binwidth);
	end
	set(gh('OPmint'),'String',num2str(mint));
	set(gh('OPmaxt'),'String',num2str(maxt));
	
	o.mint = mint; o.maxt = maxt;
	o.cell1spike=cell(o.cell1.yrange,o.cell1.xrange);  %set up our spike holding matrices
	o.cell2spike = o.cell1spike;
	o.cell1time = o.cell1spike;
	o.cell2time = o.cell1spike;
	o.cell1raws = o.cell1spike;
	o.cell2raws = o.cell1spike;
	o.cell1raw = o.cell1spike;
	o.cell2raw = o.cell1spike;
	o.cell1mat = zeros(o.cell1.yrange,o.cell1.xrange);
	o.cell2mat = zeros(o.cell1.yrange,o.cell1.xrange);
	o.position1 = o.cell1spike;
	o.position2 = o.cell1spike;
	o.cell1psth = o.cell1spike;
	o.cell2psth = o.cell1spike;
	o.cell1bpsth = o.cell1spike;
	o.cell2bpsth = o.cell1spike;
	o.cell1time = o.cell1spike;
	o.cell2time = o.cell1spike;
	o.cell1btime = o.cell1spike;
	o.cell2btime = o.cell1spike;
	o.cell1raw = o.cell1spike;
	o.cell2raw = o.cell1spike;
	o.cell1braw = o.cell1spike;
	o.cell2braw = o.cell1spike;
	o.cell1raws = o.cell1spike;
	o.cell2raws = o.cell1spike;
	o.cell1braws = o.cell1spike;
	o.cell2braws = o.cell1spike;
	o.cell1sums = o.cell1spike;
	o.cell2sums = o.cell1spike;
	o.cell1bsums = o.cell1spike;
	o.cell2bsums = o.cell1spike;
	o.cell1error = o.cell1spike;
	o.cell2error = o.cell1spike;
	o.cell1names = o.cell1spike;
	o.cell2names = o.cell1spike;
	o.cell1bratio = o.cell1spike;
	o.cell2bratio = o.cell1spike;
	
	m=1;
	mm=1;
	m2=1;
	mm2=1;
	%lets get our spikes	
	for i=1:o.cell1.xrange
		for j=1:o.cell1.yrange			
			raw1=o.cell1.raw{o.cell1.yindex(j),o.cell1.xindex(i)};
			raw2=o.cell2.raw{o.cell2.yindex(j),o.cell2.xindex(i)};
			
			[time,psth,rawl,sm,raws]=binit(raw1,binwidth*10,1,inf,starttrial,endtrial,wrapped);
			[time2,psth2,rawl2,sm2,raws2]=binit(raw2,binwidth*10,1,inf,starttrial,endtrial,wrapped);
			if sigma > 0
				psth=gausssmooth(time,psth,sigma);
				psth2=gausssmooth(time2,psth2,sigma);
			end
			e1=finderror(raw1,'Fano Factor',mint,maxt+binwidth,wrapped,0);
			e2=finderror(raw2,'Fano Factor',mint,maxt+binwidth,wrapped,0);
			
			psth = converttotime(psth, binwidth, raw1.numtrials, raw1.nummods, wrapped);
			psth2 = converttotime(psth2, binwidth, raw2.numtrials, raw2.nummods, wrapped);
			
			[btime,bpsth,brawl,bsm,braws]=binitb(raw1,binwidth*10,1,inf,starttrial,endtrial,wrapped);
			[btime2,bpsth2,brawl2,bsm2,braws2]=binitb(raw2,binwidth*10,1,inf,starttrial,endtrial,wrapped);
			if sigma > 0
				bpsth=gausssmooth(btime,bpsth,sigma);
				bpsth2=gausssmooth(btime2,bpsth2,sigma);
			end
			bpsth = converttotime(bpsth, binwidth, raw1.numtrials, raw1.nummods, wrapped);
			bpsth2 = converttotime(bpsth2, binwidth, raw2.numtrials, raw2.nummods, wrapped);
				
			psth=psth(time>=mint&time<=maxt);
			psth2=psth2(time2>=mint&time2<=maxt);
			time=time(time>=mint&time<=maxt);
			time2=time2(time2>=mint&time2<=maxt);
			rawl=rawl(rawl>=mint&rawl<=maxt);
			rawl2=rawl2(rawl2>=mint&rawl2<=maxt);
			bpsth=bpsth(time>=mint&time<=maxt);
			bpsth2=bpsth2(time2>=mint&time2<=maxt);
			btime=btime(time>=mint&time<=maxt);
			btime2=btime2(time2>=mint&time2<=maxt);
			brawl=brawl(brawl>=mint&brawl<=maxt);
			brawl2=brawl2(brawl2>=mint&brawl2<=maxt);
			
			for k=1:length(raws)
				raws(k).trial=raws(k).trial(find(raws(k).trial>=mint&raws(k).trial<=maxt));
				sm(k)=length(raws(k).trial);
				braws(k).trial=braws(k).trial(find(braws(k).trial>=mint&braws(k).trial<=maxt));
				bsm(k)=length(braws(k).trial);
			end
			for k=1:length(raws2)
				raws2(k).trial=raws2(k).trial(find(raws2(k).trial>=mint&raws2(k).trial<=maxt));
				sm2(k)=length(raws2(k).trial);
				braws2(k).trial=braws2(k).trial(find(braws2(k).trial>=mint&braws2(k).trial<=maxt));
				bsm2(k)=length(braws2(k).trial);
			end
			
			sm = (sm / (maxt-mint)) * 1000; %convert spikes/trial to Hz
			sm2 = (sm2 / (maxt-mint)) * 1000;
			bsm = (bsm / (maxt-mint)) * 1000; %convert spikes/trial to Hz
			bsm2 = (bsm2 / (maxt-mint)) * 1000;
			
			o.cell1psth{j,i}=psth;
			o.cell2psth{j,i}=psth2;
			o.cell1time{j,i}=time;
			o.cell2time{j,i}=time2;
			o.cell1raw{j,i}=rawl;
			o.cell2raw{j,i}=rawl2;
			o.cell1raws{j,i}=raws;
			o.cell2raws{j,i}=raws2;
			o.cell1sums{j,i}=sm;
			o.cell2sums{j,i}=sm2;
			o.cell1bpsth{j,i}=bpsth;
			o.cell2bpsth{j,i}=bpsth2;
			o.cell1btime{j,i}=btime;
			o.cell2btime{j,i}=btime2;
			o.cell1braw{j,i}=brawl;
			o.cell2braw{j,i}=brawl2;
			o.cell1braws{j,i}=braws;
			o.cell2braws{j,i}=braws2;
			o.cell1bsums{j,i}=bsm;
			o.cell2bsums{j,i}=bsm2;
			o.cell1error{j,i}=e1;
			o.cell2error{j,i}=e2;
			o.cell1bratio{j,i} = length(brawl) / length(rawl);
			o.cell2bratio{j,i} = length(brawl2) / length(rawl2);
			o.cell1names{j,i} = raw1.name;
			o.cell2names{j,i} = raw2.name;
			
			switch(get(gh('OPMeasureMenu'),'Value'))
				case 1 %raw spikes
					set(gh('InfoText'),'String','Mode: Raw Spike Times');
					o.spiketype='raw';
					o.cell1spike{j,i}=o.cell1raw{j,i};
					o.cell2spike{j,i}=o.cell2raw{j,i};

				case 2 %PSTH
					set(gh('InfoText'),'String','Mode: PSTH');
					o.spiketype='psth';
					o.cell1spike{j,i}=o.cell1psth{j,i};
					o.cell2spike{j,i}=o.cell2psth{j,i};
					[m,mm]=findmax(psth,m,mm);
					[m2,mm2]=findmax(psth2,m2,mm2);

				case 3 %raw ISI
					set(gh('InfoText'),'String','Mode: Raw ISI Times');
					o.spiketype='isiraw';
					o.cell1spike{j,i}=diff(rawl);
					o.cell2spike{j,i}=diff(rawl2);

				case 4 %ISIH
					set(gh('InfoText'),'String','Mode: ISI Histograms');
					o.spiketype='isih';
					bins=0:1:50;
					isi1=hist(diff(rawl),bins);
					isi2=hist(diff(rawl2),bins);
					[m,mm]=findmax(isi1,m,mm);
					[m2,mm2]=findmax(isi2,m2,mm2);
					o.cell1spike{j,i}=isi1;
					o.cell2spike{j,i}=isi2;
					o.cell1time{j,i}=bins;
					o.cell2time{j,i}=bins;
			end
		end
	end	
	o.peak=m;
	o.peak2=m2;
	o.max=mm;
	o.max2=mm2;
	%now rerun to normalise and generate matrix	
	for i=1:o.cell1.xrange
		for j=1:o.cell1.yrange		
% 			if get(gh('SpontaneousBox'),'Value')==1
% 				if o.position1(j,i)<1
% 					o.cell1spike{j,i}=[];
% 				elseif o.position2(j,i)<1
% 					o.cell2spike{j,i}=[];
% 				end
% 			end
			switch(get(gh('OPMeasureMenu'),'Value'))
				case 1 %raw spikes						
					o.cell1mat(j,i)=length(o.cell1spike{j,i}) / length(o.cell1sums{j,i});
					o.cell2mat(j,i)=length(o.cell2spike{j,i}) / length(o.cell2sums{j,i});
					set(gh('StatsText'),'String','Plotting the number of spikes/trials per variable');
				case 2 %psth
					if Normalise > 1
						[o.cell1spike{j,i},o.cell1mat(j,i)]=normaliseit(o.cell1spike{j,i},Normalise,m,mm,raw1.numtrials,raw1.nummods,maxt-mint,wrapped);
						[o.cell2spike{j,i},o.cell2mat(j,i)]=normaliseit(o.cell2spike{j,i},Normalise,m2,mm2,raw2.numtrials,raw2.nummods,maxt-mint,wrapped);					
					else
						o.cell1mat(j,i)=mean(o.cell1spike{j,i});
						o.cell2mat(j,i)=mean(o.cell2spike{j,i});
					end
					set(gh('StatsText'),'String','Plotting the mean response, possibly normalised');
				case 3 %isi
					o.cell1mat(j,i)=mean(o.cell1spike{j,i});
					o.cell2mat(j,i)=mean(o.cell2spike{j,i});
					set(gh('StatsText'),'String','Plotting the mean ISI time');
				case 4 %isih				
					o.cell1mat(j,i)=mean(o.cell1spike{j,i});
					o.cell2mat(j,i)=mean(o.cell2spike{j,i});
					set(gh('StatsText'),'String','Plotting the mean number of spikes per ISI histogram bin');
			end
		end
	end
		
	o.cell1.max=max(max(o.cell1mat));
	o.cell2.max=max(max(o.cell2mat));
	if get(gh('MatrixBox'),'Value')==1
		o.cell1mat=(o.cell1mat/o.cell1.max)*100;
		o.cell2mat=(o.cell2mat/o.cell2.max)*100;
	end

	o.cell1.matrixold=o.cell1.matrix;
	o.cell2.matrixold=o.cell2.matrix;
	o.cell1.matrix = o.cell1mat;
	o.cell2.matrix = o.cell2mat;
% 	if wrapped==1
% 		o.cell1.matrix=o.cell1mat/length(o.cell1sums{1});
% 		o.cell1.matrix=o.cell1.matrix*(1000/(o.cell1.modtime/10));
% 		o.cell2.matrix=o.cell2mat/length(o.cell2sums{1});
% 		o.cell2.matrix=o.cell2.matrix*(1000/(o.cell2.modtime/10));
% 	else
% 		o.cell1.matrix=o.cell1mat/length(o.cell1sums{1});
% 		o.cell1.matrix=o.cell1.matrix*(1000/(o.cell1.trialtime/10));
% 		o.cell2.matrix=o.cell2mat/length(o.cell2sums{1});
% 		o.cell2.matrix=o.cell2.matrix*(1000/(o.cell2.trialtime/10));
% 	end
		
	updategui();
	
	%---Now we are going to plot out both spike trains for visual comparison.
	
	if get(gh('OPShowPlots'),'Value')==1 %plot histograms
		set(gh('StatsText'),'String','Please wait, plotting additional info for each matrix point...');
		figure;
		figpos(1,[1000 1000])
		set(gcf,'Name','PSTH/ISI Plots for Control (black) and Test (Red) Receptive Fields','NumberTitle','off');
		x=1:(o.cell1.yrange*o.cell1.xrange);
		y=reshape(x,o.cell1.yrange,o.cell1.xrange);
		y=y'; %order it so we can load our data to look like the surface plots
		m=max([o.peak o.peak2]);
		for i=1:o.cell1.xrange*o.cell1.yrange
			subplot(o.cell1.yrange,o.cell1.xrange,i);
			plot(o.cell1time{i},o.cell1psth{i},'k-',o.cell2time{i},o.cell2psth{i},'r-');
			if isfield(o,'spontaneous1') && o.spontaneous1 > -1
				hold on
				line([o.cell1time{i}(1) o.cell1time{i}(end)],[o.spontaneous1 o.spontaneous1],'Color',[0 0 0]);
				line([o.cell1time{i}(1) o.cell1time{i}(end)],[o.spontaneous2 o.spontaneous2],'Color',[1 0 0]);
				line([o.cell1time{i}(1) o.cell1time{i}(end)],[o.spontaneous1ci(1) o.spontaneous1ci(1)],'Color',[0 0 0],'LineStyle','--');
				line([o.cell1time{i}(1) o.cell1time{i}(end)],[o.spontaneous2ci(1) o.spontaneous2ci(1)],'Color',[1 0 0],'LineStyle','--');
				line([o.cell1time{i}(1) o.cell1time{i}(end)],[o.spontaneous1ci(2) o.spontaneous1ci(2)],'Color',[0 0 0],'LineStyle','--');
				line([o.cell1time{i}(1) o.cell1time{i}(end)],[o.spontaneous2ci(2) o.spontaneous2ci(2)],'Color',[1 0 0],'LineStyle','--');
				hold off
			end
			title([o.cell1names{i} ' \newline ' o.cell2names{i}])
			xlabel('Time(s)')
			ylabel('Firing Rate (Hz)')
			%set(gca,'FontSize',5);
			axis tight;
			if strcmp(o.spiketype,'psth') && (Normalise==2 || Normalise==3)
				axis([-inf inf 0 1]);
			elseif strcmp(o.spiketype,'psth') && Normalise==1
				axis([-inf inf 0 m]);
			end
			v = axis;
			t{1} = sprintf('Cell 1 Burst Ratio = %g', o.cell1bratio{i});
			t{2} = sprintf('Cell 2 Burst Ratio = %g', o.cell2bratio{i});
			t{3} = sprintf('Cell 1 Mean = %g', o.cell1mat(i));
			t{4} = sprintf('Cell 2 Mean = %g', o.cell2mat(i));
			text(o.cell1time{i}(1),v(4)-(v(4)/10),t,'FontSize',12);
		end
		figure;
		figpos(1,[1000 1000])
		set(gcf,'Name','CDF Plots for Control (Black) and Test (Red) Receptive Fields','NumberTitle','off')
		x=1:(o.cell1.yrange*o.cell1.xrange);
		y=reshape(x,o.cell1.yrange,o.cell1.xrange);
		y=y'; %order it so we can load our data to look like the surface plots
		for i=1:o.cell1.xrange*o.cell1.yrange
			subplot(o.cell1.yrange,o.cell1.xrange,i)
			if ~isempty(o.cell1raw{y(i)})
				hh=cdfplot(o.cell1raw{y(i)});
				set(hh,'Color',[0 0 0]);
			end
			if ~isempty(o.cell2raw{y(i)})
				hold on
				hh=cdfplot(o.cell2spike{y(i)});
				set(hh,'Color',[1 0 0]);				
				hold off
			end
			%grid off
			title([o.cell1names{i} ' | ' o.cell2names{i}])
			xlabel('');
			ylabel('');
			%set(gca,'FontSize',4);			
		end
		figure;
		figpos(1,[1000 1000])
		set(gcf,'Name','Spikes (y) per Trial (x) Plots for Control (Black) and Test (Red) Receptive Fields','NumberTitle','off')
		x=1:(o.cell1.yrange*o.cell1.xrange);
		y=reshape(x,o.cell1.yrange,o.cell1.xrange);
		y=y'; %order it so we can load our data to look like the surface plots
		for i=1:o.cell1.xrange*o.cell1.yrange
			subplot(o.cell1.yrange,o.cell1.xrange,i)
			if ~isempty(o.cell1sums{y(i)})
				plot(o.cell1sums{y(i)},'k-');
			end
			if ~isempty(o.cell2sums{y(i)})
				hold on
				plot(o.cell2sums{y(i)},'r-');			
				hold off
			end
			grid off
			axis tight
			title([o.cell1names{i} ' | ' o.cell2names{i}])
			%set(gca,'FontSize',4.5);
		end
		%jointfig(h,o.cell1.yrange,o.cell1.xrange)
		
		figure
		figpos(1,[1000 1000])
		window=str2num(get(gh('OPWindow'),'String'));
		shift=str2num(get(gh('OPShift'),'String'));
		maxt=o.maxt;
		for i=1:o.cell1.xrange*o.cell1.yrange
			subplot(o.cell1.yrange,o.cell1.xrange,i)
			[ff,cv,af,time,position]=fanogram(o.cell1.raw{i},window,shift,wrapped);
			[ff2,cv2,af2,time2,position]=fanogram(o.cell2.raw{i},window,shift,wrapped);
			if position == 3
				tpos = 'end';
			elseif position == 2
				tpos = 'middle';
			else
				tpos = 'start';
			end
			plot(time,ff,'k-',time2,ff2,'r-','LineWidth',2);
			hold on;
			plot(time,cv,'k--',time2,cv2,'r--');
			plot(time,af,'k-.',time2,af2,'r-.');
			
			p = o.cell1psth{i};
			p2 = o.cell2psth{i};
			
			m1 = max(p);
			m2 = max(p2);
			
			m = max([m1 m2]);
			
			t = o.cell1time{i};
			t2 = o.cell2time{i};
			p = (p / m) * max(ff);
			p2 = (p2 / m) * max(ff);
			
			plot(t,p,'ko-',t2,p2,'ro-');
			
			hold off;
			axis tight;
			if maxt > max(time)-window
				maxt = max(time)-window;
			end
			axis([window maxt -inf inf]);
			legend('Control FF', 'Test FF','Control CV','Test CV','Control Allan Factor','Test Allan Factor','PSTH1','PSTH2');
			title([o.cell1names{i} ' | ' o.cell2names{i}])
			xlabel('Time (ms)');
			ylabel(['FF / C_V / AF - window:' num2str(window) ' shift: ' num2str(shift) ' position: ' tpos]);
			set(gcf,'Name','Fanogram for Control and Test Cells')
		end
		try
			opro('PlotAll');
		catch
			fprintf('Raw plots failed...\n')
		end
	end	
	set(gh('StatsText'),'String','Data has been measured.');
	
	
	%-----------------------------------------------------------------------------------------
case 'Spontaneous'
	%-----------------------------------------------------------------------------------------
	
% 	if strcmp(o.spiketype,'none')
% 		errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
% 		error('need to measure psth');
% 	end
	o.spontaneous1ci = 0;
	o.spontaneous2ci = 0;
	o.spontaneous1 = 0;
	o.spontaneous1error = 0;
	o.spontaneous2 = 0;
	o.spontaneous2error = 0;
	if (strcmp(o.spiketype,'isiraw') | strcmp(o.spiketype,'isih'))
		errordlg('Sorry, you can only do Spontaneous Calculation on Binned Spikes, not ISIs')
		error('Incorrect data for spontaneous measurement')
	end
	o.position=[];
	sp1=str2num(get(gh('SP1Edit'),'String'));
	sp2=str2num(get(gh('SP2Edit'),'String'));
	xhold=get(gh('OPHoldX'),'Value');
	yhold=get(gh('OPHoldY'),'Value');
	binwidth=str2num(get(gh('BinWidthEdit'),'String'));
	wrapped=get(gh('WrappedBox'),'Value');
	Normalise=get(gh('NormaliseMenu'),'Value');
	starttrial=get(gh('StartTrialMenu'),'Value');
	endtrial=get(gh('EndTrialMenu'),'Value');
	
	if xhold > o.cell1.xrange; xhold = o.cell1.xindex(1); end
	if yhold > o.cell1.yrange; yhold = o.cell1.yindex(1); end
	
	raw1 = o.cell1.raw{o.cell1.yindex(yhold),o.cell1.xindex(xhold)};
	raw2 = o.cell2.raw{o.cell1.yindex(yhold),o.cell1.xindex(xhold)};
	
	if (sp1==-1 || sp2==-1)
		t={'Will Measure Spontaneous at the location indicated by the Held X / Y Variable Position';'';'';'You Chose';['X = ' num2str(o.cell1.xvalues(xhold))];['Y = ' num2str(o.cell1.yvalues(yhold))]};
		[t1,psth]=binit(raw1,binwidth*10,1,inf,starttrial,endtrial,wrapped);
		[t2,psth2]=binit(raw2,binwidth*10,1,inf,starttrial,endtrial,wrapped);
		
		psth = converttotime(psth, binwidth, o.cell1.raw{o.cell1.yindex(yhold),o.cell1.xindex(xhold)}.numtrials, o.cell1.raw{o.cell1.yindex(yhold),o.cell1.xindex(xhold)}.nummods, wrapped);
		psth2 = converttotime(psth2, binwidth, o.cell2.raw{o.cell2.yindex(yhold),o.cell2.xindex(xhold)}.numtrials, o.cell2.raw{o.cell2.yindex(yhold),o.cell2.xindex(xhold)}.nummods, wrapped);
		
		[mint,maxt]=measureq(t1,psth,binwidth,psth2);
	end
	
	if (sp1==-1 || sp2==-1) %only if nothing input
		switch o.spiketype
			case 'raw'
				spikes1=o.cell1sums{yhold,xhold};
				spikes2=o.cell2sums{yhold,xhold};
				o.spontaneous1=mean(spikes1)+(2*std(spikes1));
				o.spontaneous2=mean(spikes2)+(2*std(spikes2));
			case 'psth'
				[time,psth,rawl,sm,raws]=binit(raw1,binwidth*10,1,inf,starttrial,endtrial,wrapped);
				[time2,psth2,rawl2,sm2,raws2]=binit(raw2,binwidth*10,1,inf,starttrial,endtrial,wrapped);
				
				psth = converttotime(psth, binwidth, raw1.numtrials, raw1.nummods, wrapped);
				psth2 = converttotime(psth2, binwidth, raw2.numtrials, raw2.nummods, wrapped);
				
				psth=psth(time>=mint&time<=maxt);
				psth2=psth2(time2>=mint&time2<=maxt);
				time=time(time>=mint&time<=maxt);
				time2=time2(time2>=mint&time2<=maxt);
				rawl=rawl(rawl>=mint&rawl<=maxt);
				rawl2=rawl2(rawl2>=mint&rawl2<=maxt);

				for k=1:length(raws)
					raws(k).trial=raws(k).trial(find(raws(k).trial>=mint&raws(k).trial<=maxt));
					sm(k)=length(raws(k).trial);					
				end
				for k=1:length(raws2)
					raws2(k).trial=raws2(k).trial(find(raws2(k).trial>=mint&raws2(k).trial<=maxt));
					sm2(k)=length(raws2(k).trial);
				end
				
				sm = (sm / (maxt-mint)) * 1000; %convert spikes/trial to Hz
				sm2 = (sm2 / (maxt-mint)) * 1000;
				
				switch Normalise

				case 1 %no normalisation

				case 2 % use % of peak single bin
					psth=psth/o.peak;
					psth2=psth2/o.peak2;
				case 3  % use % of max bin +- a bin
					psth=psth/o.max;
					psth2=psth2/o.max2;
				case 4 % z-score
					psth=zscore(psth);
					psth2=zscore(psth2);
				end
				
				o.spontaneous1ci = bootci(1000,@mean,sm);
				o.spontaneous2ci = bootci(1000,@mean,sm2);
				o.g = [];
				o.g = getDensity('x',sm,'y',sm2,'autorun',true,'columnlabels',{'Spontaneous'},'legendtxt',{'Control','Test'});
				
				[o.spontaneous1, o.spontaneous1error] = stderr(sm);
				[o.spontaneous2, o.spontaneous2error] = stderr(sm2);
				
				set(gh('SP1Edit'),'String',num2str(o.spontaneous1));
				set(gh('SP2Edit'),'String',num2str(o.spontaneous2));
		end
	else
		o.spontaneous1=sp1;
		o.spontaneous2=sp2;
	end

% 	for i=1:o.cell1.xrange*o.cell1.yrange
% 		switch o.spiketype
% 			case 'raw'
% 				testvalue1=mean(o.cell1sums{i});
% 				testvalue2=mean(o.cell2sums{i});
% 				if testvalue1<=o.spontaneous1
% 					o.cell1spike{i}=[];
% 					o.position1(i)=0;
% 				end
% 				if testvalue2<=o.spontaneous2
% 					o.cell2spike{i}=[];zeros(size(o.cell2spike{i}));
% 					o.position2(i)=0;
% 				end
% 				o.cell1mat(i)=length(o.cell1spike{i});
% 				o.cell2mat(i)=length(o.cell2spike{i});
% 			case 'psth'
% 				testvalue1=mean(o.cell1spike{i});
% 				testvalue2=mean(o.cell2spike{i});
% 				if testvalue1<=o.spontaneous1
% 					o.cell1spike{i}=zeros(size(o.cell1spike{i}));
% 					o.position1(i)=0;
% 				end
% 				if testvalue2<=o.spontaneous2
% 					o.cell2spike{i}=zeros(size(o.cell2spike{i}));
% 					o.position2(i)=0;
% 				end
% 				o.cell1mat(i)=mean(o.cell1spike{i});
% 				o.cell2mat(i)=mean(o.cell2spike{i});
% 		end
% 	end
	
% 	o.cell1.matrix=o.cell1mat;
% 	o.cell2.matrix=o.cell2mat;
	
	updategui();	
	
	o.spontaneous=1;
	
% 	h=figure;
% 	set(gcf,'Position',[150 10 700 650]);
% 	set(gcf,'Name','PSTH - Spontaneous Plots for Control (black) and Drug (Red) Receptive Fields','NumberTitle','off')
% 	x=1:(o.cell1.yrange*o.cell1.xrange);
% 	y=reshape(x,o.cell1.yrange,o.cell1.xrange);
% 	y=y'; %order it so we can load our data to look like the surface plots
% 	m=max([o.peak o.peak2]);
% 	for i=1:o.cell1.xrange*o.cell1.yrange
% 		subplot(o.cell1.yrange,o.cell1.xrange,i)
% 		switch o.spiketype
% 			case 'raw'
% 				plot(o.cell1spike{y(i)},'k-',o.cell2spike{y(i)},'r-');
% 			case 'psth'
% 				plot(o.cell1time{y(i)},o.cell1spike{y(i)},'k-',o.cell2time{y(i)},o.cell2spike{y(i)},'r-');
% 		end				
% 		set(gca,'FontSize',5);
% 		axis tight;
% 		if (Normalise==2 | Normalise==3)
% 			axis([-inf inf 0 1]);
% 		elseif Normalise==1
% 			axis([-inf inf 0 m]);
% 		end
% 	end	
% 	jointfig(h,o.cell1.yrange,o.cell1.xrange)
	
	
	%-----------------------------------------------------------------------------------------
case 'OrbanizeIt'
	%-----------------------------------------------------------------------------------------
	
	set(gh('StatsText'),'String','Starting calculations...');
	s=get(gh('OPStatsMenu'),'String');
	v=get(gh('OPStatsMenu'),'Value');
	plottype=get(gh('OPPlotMenu'),'Value');
	drawnow;
	if strcmp(o.filetype,'mat') && (strcmp(o.spiketype,'psth') || strcmp(o.spiketype,'isih'))
		if length(o.cell1spike{1})<10
			h=helpdlg('Beware, you have less than 10 bins for each location, be aware you are working with a small sample. Try to increase the binwidth for more sample points.');
			pause(1);
			close(h);
		end
	end
	
	switch(s{v})
		
		%-----------------------------------------------------------------------------------------
	case '1D Gaussian'
		%-----------------------------------------------------------------------------------------

		o.xhold=get(gh('OPHoldX'),'Value');
		o.yhold=get(gh('OPHoldY'),'Value');
		
		x=o.xhold-ceil(o.cell1.xrange/2);
		y=o.yhold-ceil(o.cell1.yrange/2);
		
% 		if x>1 | x<-1
% 			errordlg('Sorry,you need to select a point within the central 9 squares')
% 			error('select eror')
% 		end
% 		if y>1 | y<-1
% 			errordlg('Sorry,you need to select a point within the central 9 squares')
% 			error('select eror')
% 		end
		
		gaussfit1D;		
		
		
		%-----------------------------------------------------------------------------------------
	case '2D Gaussian'
		%-----------------------------------------------------------------------------------------

		o.xhold=get(gh('OPHoldX'),'Value');
		o.yhold=get(gh('OPHoldY'),'Value');
		
		gaussfit2D
		
		%-----------------------------------------------------------------------------------------
	case 'Vector'
		%-----------------------------------------------------------------------------------------
		
		m1=o.cell1.matrix;
		m2=o.cell2.matrix;
		[y1,x1]=find(m1==max(max(m1)));
		[y2,x2]=find(m2==max(max(m2)));
		
		xx1=o.cell1.xvalues(x1);
		yy1=o.cell1.yvalues(y1);
		xx2=o.cell2.xvalues(x2);
		yy2=o.cell2.yvalues(y2);
		
		vy=yy2-yy1;
		vx=xx2-xx1;
		
		[theta,rho]=cart2pol(vx,vy);
		
		axes(gh('OutputAxis'));
		compass(vx,vy);
		set(gca,'Tag','OutputAxis');
				
		t=['Angle: ' num2str(rad2ang(theta,0,1)) '\circ | Distance: ' num2str(rho) '\circ'];
		title(t);
		o.text=t;
		set(gh('StatsText'),'String',['Angle: ' num2str(rad2ang(theta,0,1)) ' | Distance: ' num2str(rho)]);	

		%-----------------------------------------------------------------------------------------
	case 'M: Dot Product'
		%-----------------------------------------------------------------------------------------
			
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=reshape(o.cell1.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
			d2=reshape(o.cell2.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 | o.position2(i)>0
					d1(a)=o.cell1.matrix(i);
					d2(a)=o.cell2.matrix(i);
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=zeros(o.cell1.xrange*o.cell1.yrange,1);
			d2=d1;
			d1(1:end)=o.cell1.matrix(1:end);
			d2(1:end)=o.cell2.matrix(1:end);
		end
		
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		axes(gh('OutputAxis'));
		plot(d1,d2,'ko','MarkerSize',5,'MarkerFaceColor',[0 0 0]);
		if get(gh('LogBox'),'Value')==0
			lsqline
		else
			set(gca,'XScale','Log');
			set(gca,'YScale','Log');
		end
		set(gca,'Tag','OutputAxis');
		box on;
		xlabel('Cell 1');
		ylabel('Cell 2');
		[norm,rawdp]=dotproduct(d1,d2);
		
		dp=rawdp/norm;
		
		t=['Dot Product: ' num2str(dp)];
		o.text=t;
		set(gh('StatsText'),'String',t);
		
		%-----------------------------------------------------------------------------------------
	case 'M: Spearman Correlation'
		%-----------------------------------------------------------------------------------------
		
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=reshape(o.cell1.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
			d2=reshape(o.cell2.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 | o.position2(i)>0
					d1(a)=o.cell1.matrix(i);
					d2(a)=o.cell2.matrix(i);
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=zeros(o.cell1.xrange*o.cell1.yrange,1);
			d2=d1;
			d1(1:end)=o.cell1.matrix(1:end);
			d2(1:end)=o.cell2.matrix(1:end);
		end
		
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		axes(gh('OutputAxis'));
		plot(d1,d2,'ko','MarkerSize',5,'MarkerFaceColor',[0 0 0]);
		if get(gh('LogBox'),'Value')==0
			lsqline
		else
			set(gca,'XScale','Log');
			set(gca,'YScale','Log');
		end
		set(gca,'Tag','OutputAxis');
		box on;
		xlabel('Cell 1');
		ylabel('Cell 2');
		[rs,p,lb,ub]=corrc(d1,d2,1);
		r2=abs(rs).^2;
		if p<=alpha;
			pp='YES';
		elseif p>alpha;
			pp='NO';
		end
		if get(gh('CentredBox'),'Value')==1
			t1=['Spearman Correlation centred on X=' num2str(o.cell1.xvalues(xhold)) ' Y=' num2str(o.cell1.yvalues(yhold)) ': '];
		elseif o.spontaneous==1
			t1=['Spearman Correlation on the significant (after spontaneous +2SD subtraction) positions: '];
		else
			t1=['Spearman Correlation using the whole M (n=' num2str(length(d1)) '): '];
		end
		t2=['Control: ' o.cell1.filename];
		t3=['Drug: ' o.cell2.filename];
		t4='';
		t5=['rs (r2) = ' num2str(rs) ' (' num2str(r2) ')'];
		t6=['95% Confidence Intervals = ' num2str(lb) ' | ' num2str(ub)];
		t7=['Significance: p = ' num2str(p)];
		t8=['Can we reject the null hypothesis?: ' pp];
		t=[{t1};{t2};{t3};{t4};{t5};{t6};{t7};{t8}];
		o.text=t;
		set(gh('StatsText'),'String',t);
		
		%-----------------------------------------------------------------------------------------
	case 'M: 1-Way Anova'
		%-----------------------------------------------------------------------------------------
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=reshape(o.cell1.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
			d2=reshape(o.cell2.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 | o.position2(i)>0
					d1(a)=o.cell1.matrix(i);
					d2(a)=o.cell2.matrix(i);
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=zeros(o.cell1.xrange*o.cell1.yrange,1);
			d2=d1;
			d1(1:end)=o.cell1.matrix(1:end);
			d2(1:end)=o.cell2.matrix(1:end);
		end
		axes(gh('OutputAxis'));
		boxplot([d1,d2],1);
		set(gca,'Tag','OutputAxis');
		box on;
		xlabel('Cells');
		ylabel('Mean');
		x(1:length(d1),1)=d1;
		x(length(d1)+1:length(d1)*2,1)=d2;
		y(1:length(d1),1)=1;
		y(length(d1)+1:length(d1)*2,1)=2;
		[p,f]=anova1(x,y);
		if p<=alpha;
			pp='YES';
		elseif p>alpha;
			pp='NO';
		end
		if get(gh('CentredBox'),'Value')==1
			t1=['1 way Anova centred on X=' num2str(o.cell1.xvalues(xhold)) ' Y=' num2str(o.cell1.yvalues(yhold)) ': '];
		elseif o.spontaneous==1
			t1=['1 way Anova using the significant (after spontaneous +2SD subtraction) positions: '];
		else
			t1=['1 way Anova using the whole M (n=' num2str(length(d1)) '): '];
		end
		[meanv,stderror]=stderr(d1,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t2=['Control: ' o.cell1.filename ' (mean:' meanv '±' stderror ')'];
		[meanv,stderror]=stderr(d2,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t3=['Drug: ' o.cell2.filename ' (mean:' meanv '±' stderror ')'];
		t4='';
		t5=['Significance: p = ' sprintf('%0.4f',p)];
		if exist('pp','var')
			t6=['Can we reject the null hypothesis?: ' pp];
		else
			t6=[''];
		end
		t=[{t1};{t2};{t3};{t4};{t5};{t6}];
		o.text=t;
		set(gh('StatsText'),'String',t);
			
		%-----------------------------------------------------------------------------------------
	case 'M: Paired T-test'
		%-----------------------------------------------------------------------------------------
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=reshape(o.cell1.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
			d2=reshape(o.cell2.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 || o.position2(i)>0
					d1(a)=o.cell1.matrix(i);
					d2(a)=o.cell2.matrix(i);
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=zeros(o.cell1.xrange*o.cell1.yrange,1);
			d2=d1;
			d1(1:end)=o.cell1.matrix(1:end);
			d2(1:end)=o.cell2.matrix(1:end);
		end
		axes(gh('OutputAxis'));
		boxplot([d1,d2],1);
		set(gca,'Tag','OutputAxis');
		box on;
		xlabel('Cells');
		ylabel('Median');
		o.d1=d1;
		o.d2=d2;
		[pp,p]=ttest((d1-d2),0,alpha);
		if p<=alpha;
			pp='YES';
		elseif p>alpha;
			pp='NO';
		end
		if get(gh('CentredBox'),'Value')==1
			t1=['Paired T-test centred on X=' num2str(o.cell1.xvalues(xhold)) ' Y=' num2str(o.cell1.yvalues(yhold)) ': '];
		elseif o.spontaneous==1
			t1=['Paired T-test using the significant (after spontaneous +2SD subtraction) positions: '];
		else
			t1=['Paired T-test using the whole M (n=' num2str(length(d1)) '): '];
		end
		[meanv,stderror]=stderr(d1,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t2=['Control: ' o.cell1.filename ' (mean:' meanv '±' stderror ')'];
		[meanv,stderror]=stderr(d2,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t3=['Drug: ' o.cell2.filename ' (mean:' meanv '±' stderror ')'];
		t4='';
		t5=['Significance: p = ' sprintf('%0.4f',p)];
		t6=['Can we reject the null hypothesis?: ' pp];
		t=[{t1};{t2};{t3};{t4};{t5};{t6}];
		o.text=t;
		set(gh('StatsText'),'String',t);
		
		%-----------------------------------------------------------------------------------------
	case 'M: Fano T-test'
		%-----------------------------------------------------------------------------------------
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=cat(1,o.cell1error{yhold-1:yhold+1,xhold-1:xhold+1});
			d2=cat(1,o.cell2error{yhold-1:yhold+1,xhold-1:xhold+1});
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 | o.position2(i)>0
					d1(a)=o.cell1error{i};
					d2(a)=o.cell2error{i};
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=cat(1,o.cell1error{1:end});
			d2=cat(1,o.cell2error{1:end});
		end
		axes(gh('OutputAxis'));
		boxplot([d1,d2],1);
		set(gca,'Tag','OutputAxis');
		box on;
		xlabel('Cells');
		ylabel('Median');
		o.d1=d1;
		o.d2=d2;
		[pp,p]=ttest((d1-d2),0,alpha);
		if p<=alpha;
			pp='YES';
		elseif p>alpha;
			pp='NO';
		end
		if get(gh('CentredBox'),'Value')==1
			t1=['Paired Fano T-test centred on X=' num2str(o.cell1.xvalues(xhold)) ' Y=' num2str(o.cell1.yvalues(yhold)) ': '];
		elseif o.spontaneous==1
			t1=['Paired Fano T-test using the significant (after spontaneous +2SD subtraction) positions: '];
		else
			t1=['Paired Fano T-test using the whole M (n=' num2str(length(d1)) '): '];
		end
		[meanv,stderror]=stderr(d1,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t2=['Control: ' o.cell1.filename ' (mean:' meanv '±' stderror ')'];
		[meanv,stderror]=stderr(d2,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t3=['Drug: ' o.cell2.filename ' (mean:' meanv '±' stderror ')'];
		t4='';
		t5=['Significance: p = ' sprintf('%0.4f',p)];
		t6=['Can we reject the null hypothesis?: ' pp];
		t=[{t1};{t2};{t3};{t4};{t5};{t6}];
		o.text=t;
		set(gh('StatsText'),'String',t);
		
		%-----------------------------------------------------------------------------------------
	case 'M: Fano Wilcoxon'
		%-----------------------------------------------------------------------------------------
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=cat(1,o.cell1error{yhold-1:yhold+1,xhold-1:xhold+1});
			d2=cat(1,o.cell2error{yhold-1:yhold+1,xhold-1:xhold+1});
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 | o.position2(i)>0
					d1(a)=o.cell1error{i};
					d2(a)=o.cell2error{i};
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=cat(1,o.cell1error{1:end});
			d2=cat(1,o.cell2error{1:end});
		end
		axes(gh('OutputAxis'));
		boxplot([d1,d2],1);
		set(gca,'Tag','OutputAxis');
		box on;
		xlabel('Cells');
		ylabel('Median');
		o.d1=d1;
		o.d2=d2;
		[p,h]=ranksum(d1,d2,'alpha',alpha);
		if h==1;
			pp='YES';
		else
			pp='NO';
		end
		if get(gh('CentredBox'),'Value')==1
			t1=['Fano Wilcoxon centred on X=' num2str(o.cell1.xvalues(xhold)) ' Y=' num2str(o.cell1.yvalues(yhold)) ': '];
		elseif o.spontaneous==1
			t1=['Fano Wilcoxon using the significant (after spontaneous +2SD subtraction) positions: '];
		else
			t1=['Fano Wilcoxon using the whole Matrix (n=' num2str(length(d1)) '): '];
		end
		[meanv,stderror]=stderr(d1,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t2=['Control: ' o.cell1.filename ' (mean:' meanv '±' stderror ')'];
		[meanv,stderror]=stderr(d2,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t3=['Drug: ' o.cell2.filename ' (mean:' meanv '±' stderror ')'];
		t4='';
		t5=['Significance: p = ' sprintf('%0.4f',p)];
		t6=['Can we reject the null hypothesis?: ' pp];
		t=[{t1};{t2};{t3};{t4};{t5};{t6}];
		o.text=t;
		set(gh('StatsText'),'String',t);
		
		%-----------------------------------------------------------------------------------------
	case 'M: Fano Paired Wilcoxon'
		%-----------------------------------------------------------------------------------------
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=cat(1,o.cell1error{yhold-1:yhold+1,xhold-1:xhold+1});
			d2=cat(1,o.cell2error{yhold-1:yhold+1,xhold-1:xhold+1});
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 | o.position2(i)>0
					d1(a)=o.cell1error{i};
					d2(a)=o.cell2error{i};
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=cat(1,o.cell1error{1:end});
			d2=cat(1,o.cell2error{1:end});
		end
		axes(gh('OutputAxis'));
		boxplot([d1,d2],1);
		set(gca,'Tag','OutputAxis');
		box on;
		xlabel('Cells');
		ylabel('Median');
		o.d1=d1;
		o.d2=d2;
		[p,h]=signrank(d1,d2,'alpha',alpha);
		if h==1;
			pp='YES';
		else
			pp='NO';
		end
		if get(gh('CentredBox'),'Value')==1
			t1=['Paired Fano Wilcoxon centred on X=' num2str(o.cell1.xvalues(xhold)) ' Y=' num2str(o.cell1.yvalues(yhold)) ': '];
		elseif o.spontaneous==1
			t1=['Paired Fano Wilcoxon using the significant (after spontaneous +2SD subtraction) positions: '];
		else
			t1=['Paired Fano Wilcoxon using the whole Matrix (n=' num2str(length(d1)) '): '];
		end
		[meanv,stderror]=stderr(d1,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t2=['Control: ' o.cell1.filename ' (mean:' meanv '±' stderror ')'];
		[meanv,stderror]=stderr(d2,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t3=['Drug: ' o.cell2.filename ' (mean:' meanv '±' stderror ')'];
		t4='';
		t5=['Significance: p = ' sprintf('%0.4f',p)];
		t6=['Can we reject the null hypothesis?: ' pp];
		t=[{t1};{t2};{t3};{t4};{t5};{t6}];
		o.text=t;
		set(gh('StatsText'),'String',t);
		
		%-----------------------------------------------------------------------------------------
	case 'M: Fano Spearman'
		%-----------------------------------------------------------------------------------------
		
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=cat(1,o.cell1error{yhold-1:yhold+1,xhold-1:xhold+1});
			d2=cat(1,o.cell2error{yhold-1:yhold+1,xhold-1:xhold+1});
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 | o.position2(i)>0
					d1(a)=o.cell1error{i};
					d2(a)=o.cell2error{i};
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=cat(1,o.cell1error{1:end});
			d2=cat(1,o.cell2error{1:end});
		end
		
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		axes(gh('OutputAxis'));
		plot(d1,d2,'ko','MarkerSize',5,'MarkerFaceColor',[0 0 0]);
		if get(gh('LogBox'),'Value')==0
			lsqline
		else
			set(gca,'XScale','Log');
			set(gca,'YScale','Log');
		end
		set(gca,'Tag','OutputAxis');
		box on;
		xlabel('Cell 1');
		ylabel('Cell 2');
		[rs,p,lb,ub]=corrc(d1,d2,1);
		r2=abs(rs).^2;
		if p<=alpha;
			pp='YES';
		elseif p>alpha;
			pp='NO';
		end
		if get(gh('CentredBox'),'Value')==1
			t1=[' Fano Spearman centred on X=' num2str(o.cell1.xvalues(xhold)) ' Y=' num2str(o.cell1.yvalues(yhold)) ': '];
		elseif o.spontaneous==1
			t1=['Fano Spearman on the significant (after spontaneous +2SD subtraction) positions: '];
		else
			t1=['Fano Spearman using the whole Matrix (n=' num2str(length(d1)) '): '];
		end
		t2=['Control: ' o.cell1.filename];
		t3=['Drug: ' o.cell2.filename];
		t4='';
		t5=['rs (r2) = ' num2str(rs) ' (' num2str(r2) ')'];
		t6=['95% Confidence Intervals = ' num2str(lb) ' | ' num2str(ub)];
		t7=['Significance: p = ' num2str(p)];
		t8=['Can we reject the null hypothesis?: ' pp];
		t=[{t1};{t2};{t3};{t4};{t5};{t6};{t7};{t8}];
		o.text=t;
		set(gh('StatsText'),'String',t);
		
		%-----------------------------------------------------------------------------------------
	case 'M: Ansari-Bradley Variance'
		%-----------------------------------------------------------------------------------------
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=reshape(o.cell1.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
			d2=reshape(o.cell2.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 | o.position2(i)>0
					d1(a)=o.cell1.matrix(i);
					d2(a)=o.cell2.matrix(i);
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=zeros(o.cell1.xrange*o.cell1.yrange,1);
			d2=d1;
			d1(1:end)=o.cell1.matrix(1:end);
			d2(1:end)=o.cell2.matrix(1:end);
		end
		axes(gh('OutputAxis'));
		boxplot([d1,d2],1);
		set(gca,'Tag','OutputAxis');
		box on;
		xlabel('Cells');
		ylabel('Median');
		o.d1=d1;
		o.d2=d2;
		[h,p]=ansaribradley(d1,d2,alpha);
		if p<=alpha;
			pp='YES';
		elseif p>alpha;
			pp='NO';
		end
		if get(gh('CentredBox'),'Value')==1
			t1=['Ansari-Bradley Variance Test for X=' num2str(o.cell1.xvalues(xhold)) ' Y=' num2str(o.cell1.yvalues(yhold)) ': '];
		elseif o.spontaneous==1
			t1=['Ansari-Bradley Variance Test using the significant (after spontaneous +2SD subtraction) positions: '];
		else
			t1=['Ansari-Bradley Variance Test using the whole M (n=' num2str(length(d1)) '): '];
		end
		[meanv,stderror]=stderr(d1,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t2=['Control: ' o.cell1.filename ' (mean:' meanv '±' stderror ')'];
		[meanv,stderror]=stderr(d2,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t3=['Drug: ' o.cell2.filename ' (mean:' meanv '±' stderror ')'];
		t4='';
		t5=['Significance: p = ' sprintf('%0.4f',p)];
		t6=['Can we reject the null hypothesis?: ' pp];
		t=[{t1};{t2};{t3};{t4};{t5};{t6}];
		o.text=t;
		set(gh('StatsText'),'String',t);
		
		%-----------------------------------------------------------------------------------------
	case 'M: Kolmogorov-Smirnof Distribution Test'
		%-----------------------------------------------------------------------------------------
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=reshape(o.cell1.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
			d2=reshape(o.cell2.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 | o.position2(i)>0
					d1(a)=o.cell1.matrix(i);
					d2(a)=o.cell2.matrix(i);
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=zeros(o.cell1.xrange*o.cell1.yrange,1);
			d2=d1;
			d1(1:end)=o.cell1.matrix(1:end);
			d2(1:end)=o.cell2.matrix(1:end);
		end
		axes(gh('OutputAxis'));
		boxplot([d1,d2],1);
		set(gca,'Tag','OutputAxis');
		box on;
		xlabel('Cells');
		ylabel('Median');
		[pp,p]=kstest2(d1,d2,alpha);
		if p<=alpha;
			pp='YES';
		elseif p>alpha;
			pp='NO';
		end
		if get(gh('CentredBox'),'Value')==1
			t1=['Kolmogorov-Smirnof centred on X=' num2str(o.cell1.xvalues(xhold)) ' Y=' num2str(o.cell1.yvalues(yhold)) ': '];
		elseif o.spontaneous==1
			t1=['Kolmogorov-Smirnof using the significant (after spontaneous +2SD subtraction) positions: '];
		else
			t1=['Kolmogorov-Smirnof using the whole M (n=' num2str(length(d1)) '): '];
		end
		[meanv,stderror]=stderr(d1,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t2=['Control: ' o.cell1.filename ' (mean:' meanv '±' stderror ')'];
		[meanv,stderror]=stderr(d2,'SE');
		meanv=sprintf('%0.3f',meanv);
		stderror=sprintf('%0.2f',stderror);
		t3=['Drug: ' o.cell2.filename ' (mean:' meanv '±' stderror ')'];
		t4='';
		t5=['Significance: p = ' sprintf('%0.4f',p)];
		t6=['Can we reject the null hypothesis?: ' pp];
		t=[{t1};{t2};{t3};{t4};{t5};{t6}];
		o.text=t;
		set(gh('StatsText'),'String',t);
		
		%-----------------------------------------------------------------------------------------
	case 'M: Pearsons Correlation'
		%-----------------------------------------------------------------------------------------
		
		if get(gh('CentredBox'),'Value')==1
			xhold=get(gh('OPHoldX'),'Value');
			yhold=get(gh('OPHoldY'),'Value');
			d1=reshape(o.cell1.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
			d2=reshape(o.cell2.matrix(yhold-1:yhold+1,xhold-1:xhold+1),9,1);
		elseif o.spontaneous==1;
			a=1;
			for i=1:o.cell1.xrange*o.cell1.yrange
				if o.position1(i)>0 | o.position2(i)>0
					d1(a)=o.cell1.matrix(i);
					d2(a)=o.cell2.matrix(i);
					a=a+1;
				end
			end
			d1=d1';
			d2=d2';
		else
			d1=zeros(o.cell1.xrange*o.cell1.yrange,1);
			d2=d1;
			d1(1:end)=o.cell1.matrix(1:end);
			d2(1:end)=o.cell2.matrix(1:end);
		end
		
		axes(gh('OutputAxis'));
		plot(d1,d2,'ko','MarkerSize',5,'MarkerFaceColor',[0 0 0]);
		set(gca,'Tag','OutputAxis');
		if get(gh('LogBox'),'Value')==0
			lsqline
		else
			set(gca,'XScale','Log');
			set(gca,'YScale','Log');
		end
		box on;
		xlabel('Cell 1');
		ylabel('Cell 2');
		[rs,p,lb,ub]=corrc(d1,d2);
		r2=abs(rs).^2;
		if p<=0.05
			pp='YES';
		elseif p>0.05
			pp='NO';
		end
		if get(gh('CentredBox'),'Value')==1
			t1=['Pearsons Correlation centred on X=' num2str(o.cell1.xvalues(xhold)) ' Y=' num2str(o.cell1.yvalues(yhold)) ': '];
		elseif o.spontaneous==1
			t1=['Pearsons Correlation on the significant (after spontaneous +2SD subtraction) positions: '];
		else
			t1=['Pearsons Correlation using the whole M (n=' num2str(length(d1)) '): '];
		end
		t2=['Control: ' o.cell1.filename];
		t3=['Drug: ' o.cell2.filename];
		t4='';
		t5=['r (r2) = ' num2str(rs) ' (' num2str(r2) ')'];
		t6=['95% Confidence Intervals = ' num2str(lb) ' | ' num2str(ub)];
		t7=['Significance: p = ' num2str(p)];
		t8=['Can we reject the null hypothesis?: ' pp];
		t=[{t1};{t2};{t3};{t4};{t5};{t6};{t7};{t8}];
		o.text=t;
		set(gh('StatsText'),'String',t);
		
		%-----------------------------------------------------------------------------------------
	case 'Column: Spontaneous'
		%-----------------------------------------------------------------------------------------
		
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		
		inp=input('Select which axes you want to measure (l,r,t,b,lr,lt,lb,tb,rt,rb):','s');
		
		switch inp
			
		case 'l'
			
			l=length(o.cell1.matrix);
			x=o.cell1.matrix(1:l,1);
			y=o.cell2.matrix(1:l,1);
			
		case 'r'
			
			l=length(o.cell1.matrix);
			x=o.cell1.matrix(1:l,end);
			y=o.cell2.matrix(1:l,end);
			
		case 't'
			
			l=length(o.cell1.matrix);
			x=o.cell1.matrix(1,1:l)';
			y=o.cell2.matrix(1,1:l)';
			
		case 'b'
			
			l=length(o.cell1.matrix);
			x=o.cell1.matrix(end,1:l)';
			y=o.cell2.matrix(end,1:l)';
			
		case 'lr'
			
			l=length(o.cell1.matrix);
			x1=o.cell1.matrix(1:l,1);
			y1=o.cell2.matrix(1:l,1);
			x2=o.cell1.matrix(1:l,end);
			y2=o.cell2.matrix(1:l,end);
			x(1:l)=x1;
			x(l+1:l*2)=x2;
			y(1:l)=y1;
			y(l+1:l*2)=y2;
			x=x';
			y=y';
			
		case 'lt'
			
			l=length(o.cell1.matrix);
			x1=o.cell1.matrix(1:l,1);
			y1=o.cell2.matrix(1:l,1);
			x2=o.cell1.matrix(1,1:l)';
			y2=o.cell2.matrix(1,1:l)';
			x(1:l)=x1;
			x(l+1:l*2)=x2;
			y(1:l)=y1;
			y(l+1:l*2)=y2;
			x=x';
			y=y';
			
		case 'lb'
			
			l=length(o.cell1.matrix);
			x1=o.cell1.matrix(1:l,1);
			y1=o.cell2.matrix(1:l,1);
			x2=o.cell1.matrix(end,1:l)';
			y2=o.cell2.matrix(end,1:l)';
			x(1:l)=x1;
			x(l+1:l*2)=x2;
			y(1:l)=y1;
			y(l+1:l*2)=y2;
			x=x';
			y=y';
			
		case 'tb'
			
			l=length(o.cell1.matrix);
			x1=o.cell1.matrix(1,1:l)';
			y1=o.cell2.matrix(1,1:l)';
			x2=o.cell1.matrix(end,1:l)';
			y2=o.cell2.matrix(end,1:l)';
			x(1:l)=x1;
			x(l+1:l*2)=x2;
			y(1:l)=y1;
			y(l+1:l*2)=y2;
			x=x';
			y=y';
			
		case 'tr'
			
			l=length(o.cell1.matrix);
			x1=o.cell1.matrix(1,1:l)';
			y1=o.cell2.matrix(1,1:l)';
			x2=o.cell1.matrix(1:l,end);
			y2=o.cell2.matrix(1:l,end);
			x(1:l)=x1;
			x(l+1:l*2)=x2;
			y(1:l)=y1;
			y(l+1:l*2)=y2;
			x=x';
			y=y';
			
		case 'br'
			
			l=length(o.cell1.matrix);
			x1=o.cell1.matrix(end,1:l)';
			y1=o.cell2.matrix(end,1:l)';
			x2=o.cell1.matrix(1:l,end);
			y2=o.cell2.matrix(1:l,end);
			x(1:l)=x1;
			x(l+1:l*2)=x2;
			y(1:l)=y1;
			y(l+1:l*2)=y2;
			x=x';
			y=y';
			
		otherwise
			
			errordlg('Sorry, unrecognised input');
			error('Sorry, unrecognised input!');
			
		end
		[p]=signtest(x,y);
		[p2]=signrank(x,y);
		[h,p3]=ttest(x,y);
		mx=mean(x);
		my=mean(y);	
		axes(gh('OutputAxis'));
		boxplot([x,y],1);
		set(gca,'Tag','OutputAxis');
		
		if p<=alpha;
			pp='YES';
		elseif p>alpha;
			pp='NO';
		end
		
		t=['Spontaneous tests computed for the ' inp ' column. The p-value(signtest/wilcoxon/paired t) is: ' num2str(p) ' / ' num2str(p2) ' / ' num2str(p3) '. Can we reject the null hypothesis: ' pp '. Cell 1 Mean = ' num2str(mx) ' Cell 2 Mean = ' num2str(my)];
		set(gh('StatsText'),'String',t);		
		
				%-----------------------------------------------------------------------------------------
	case 'I: 1-Way Anova'
		%-----------------------------------------------------------------------------------------
		
		if strcmp(o.spiketype,'none')
			errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
			error('need to measure psth');
		end
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		o.hmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.pmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		for i=1:o.cell1.xrange*o.cell1.yrange
			if o.position1(i)>0 | o.position2(i)>0
				x=[o.cell1spike{i}';o.cell2spike{i}'];
				y(1:length(o.cell1spike{i}),1)=0;
				y([length(o.cell1spike{i})+1]:length(o.cell1spike{i})*2,1)=1;
				[p]=anova1(x,y,'off');
				if p<alpha
					h=1;
				else
					h=0;
				end
				o.hmatrix(i)=h;
				o.pmatrix(i)=p;
			else
				if p<alpha
					h=1;
				else
					h=0;
				end
				o.hmatrix(i)=0;
				o.pmatrix(i)=1;
			end
		end
		
		axes(gh('OutputAxis'));
		if plottype==1
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gh('StatsText'),'String',['';'';'';'Individual 1-way Anova performed for each matrix location, plotting the p-value probability']);
			colormap(hot);
			set(gca,'Tag','OutputAxis');
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
		elseif plottype==2
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.hmatrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gh('StatsText'),'String',['';'';'';'Individual 1-way Anova performed for each matrix location, plotting the Hypthesis Result']);
		colormap(hot);
		set(gca,'Tag','OutputAxis');
		colorbar('peer',gh('OutputAxis'),'FontSize',7);
		else
			h=errordlg('You can only plot p-values or Hypothesis Test, switching to p-values')
			pause(1)
			close(h)
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gh('StatsText'),'String',['';'';'';'Individual 1-way Anova performed for each matrix location, plotting the p-value probability']);
			colormap(hot);
			set(gca,'Tag','OutputAxis');
		colorbar('peer',gh('OutputAxis'),'FontSize',7);
		end
		
		%-----------------------------------------------------------------------------------------
	case 'I: Spearman Correlation'
		%-----------------------------------------------------------------------------------------
		
		if strcmp(o.spiketype,'none')
			errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
			error('need to measure psth');
		end
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		o.hmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.pmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.rmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.r2matrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.rimatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		for i=1:o.cell1.xrange*o.cell1.yrange
			if o.position1(i)>0 | o.position2(i)>0
				switch o.spiketype
					case 'raw'
						[r,p]=corr(o.cell1sums{i},o.cell2sums{i},'type','spearman');
					case 'psth'
						[r,p]=corr(o.cell1spike{i},o.cell2spike{i},'type','spearman');
					case 'isi'
						[r,p]=corr(o.cell1sums{i},o.cell2sums{i},'type','spearman');
					case 'isih'
						[r,p]=corr(o.cell1spike{i},o.cell2spike{i},'type','spearman');
				end
				if isnan(r);r=0;end;
				if p>1;p=1;end;
				if p<=alpha
					h=1;
				else
					h=0;
				end
				o.hmatrix(i)=h;
				o.pmatrix(i)=p;
				o.rmatrix(i)=r;
				r2=abs(r^2);
				ri=1-r2;
				o.r2matrix(i)=r2;
				o.rimatrix(i)=ri;
			else
				o.hmatrix(i)=0;
				o.pmatrix(i)=1;
				o.rmatrix(i)=0;
				o.r2matrix(i)=0;
				o.rimatrix(i)=0;
			end
		end
		
		axes(gh('OutputAxis'));
		if plottype==1
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);					
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0.001 0.05]);
			%colormap([1 1 1;0.5 0.5 0.5;0 0 0]);
			set(gh('StatsText'),'String',['';'';'';'Significance (p-value) of Spearman Correlation for individual spatial locations']);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==2
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.hmatrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gca,'Tag','OutputAxis');
			set(gh('StatsText'),'String',['';'';'';'Hypothesis Result (1=yes) of whether to reject the null hypothesis (no correlation) for individual spatial locations']);
			caxis([0 1]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==3
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.rmatrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gca,'Tag','OutputAxis');
			set(gh('StatsText'),'String',['';'';'';'r Correlation Coefficient (-1 to 1) of Spearman Correlation for individual spatial locations']);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==4
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.r2matrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gca,'Tag','OutputAxis');
			set(gh('StatsText'),'String',['';'';'';'r squared Correlation Coefficient (0 to 1) of Spearman Correlation for individual spatial locations']);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==5
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.rimatrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gca,'Tag','OutputAxis');
			set(gh('StatsText'),'String',['';'';'';'1-r squared Correlation Coefficient (0 to 1) of Spearman Correlation for individual spatial locations']);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		end
		
		
		
		%-----------------------------------------------------------------------------------------
	case 'I: Pearsons Correlation'
		%-----------------------------------------------------------------------------------------
		
		if strcmp(o.spiketype,'none')
			errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
			error('need to measure psth');
		end
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		o.hmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.pmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.rmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.r2matrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.rimatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		for i=1:o.cell1.xrange*o.cell1.yrange
			if o.position1(i)>0 | o.position2(i)>0
				switch o.spiketype
					case 'raw'
						[r,p]=corr(o.cell1sums{i},o.cell2sums{i},'type','pearson');
					case 'psth'
						[r,p]=corr(o.cell1spike{i},o.cell2spike{i},'type','pearson');
					case 'isi'
						[r,p]=corr(o.cell1sums{i},o.cell2sums{i},'type','pearson');
					case 'isih'
						[r,p]=corr(o.cell1spike{i},o.cell2spike{i},'type','pearson');
				end
				if isnan(r);r=0;end;
				if p>1;p=1;end;
				if p<=alpha
					h=1;
				else
					h=0;
				end
				o.hmatrix(i)=h;
				o.pmatrix(i)=p;
				o.rmatrix(i)=r;
				r2=abs(r^2);
				ri=1-r2;
				o.r2matrix(i)=r2;
				o.rimatrix(i)=ri;
			else
				o.hmatrix(i)=0;
				o.pmatrix(i)=1;
				o.rmatrix(i)=0;
				o.r2matrix(i)=0;
				o.rimatrix(i)=0;
			end
		end
		
		axes(gh('OutputAxis'));
		if plottype==1
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);					
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			set(gca,'Tag','OutputAxis');
			caxis(gh('OutputAxis'),[0.001 0.05]);
			%colormap([1 1 1;0.5 0.5 0.5;0 0 0]);
			set(gh('StatsText'),'String',['';'';'';'Significance (p-value) of Pearson Correlation for individual spatial locations']);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==2
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.hmatrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gca,'Tag','OutputAxis');
			set(gh('StatsText'),'String',['';'';'';'Hypothesis Result (1=yes) of whether to reject the null hypothesis (no correlation) for individual spatial locations']);
			caxis([0 1]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==3
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.rmatrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gca,'Tag','OutputAxis');
			set(gh('StatsText'),'String',['';'';'';'r Correlation Coefficient (-1 to 1) of Pearson Correlation for individual spatial locations']);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==4
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.r2matrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gca,'Tag','OutputAxis');
			set(gh('StatsText'),'String',['';'';'';'r squared Correlation Coefficient (0 to 1) of Pearson Correlation for individual spatial locations']);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==5
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.rimatrix);
			if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
			if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
			set(gca,'Tag','OutputAxis');
			set(gh('StatsText'),'String',['';'';'';'1-r squared Correlation Coefficient (0 to 1) of Pearson Correlation for individual spatial locations']);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		end
		
		%-----------------------------------------------------------------------------------------
	case 'I: Wilcoxon Paired Test'
		%-----------------------------------------------------------------------------------------
		
		if strcmp(o.spiketype,'none')
			errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
			error('need to measure psth');
		end
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		o.hmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.pmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.n=length(o.cell1sums{1});
		for i=1:o.cell1.xrange*o.cell1.yrange
			if o.position1(i)>0 | o.position2(i)>0
				switch o.spiketype
					case 'raw'
						[p,h]=signrank(o.cell1sums{i},o.cell2sums{i},'alpha',alpha);						
					case 'psth'
						[p,h]=signrank(o.cell1spike{i},o.cell2spike{i},'alpha',alpha);
					case 'isi'
						[p,h]=signrank(o.cell1sums{i},o.cell2sums{i},'alpha',alpha);
					case 'isih'
						[p,h]=signrank(o.cell1spike{i},o.cell2spike{i},'alpha',alpha);
				end				
				o.hmatrix(i)=h;
				o.pmatrix(i)=p;
			else
				o.hmatrix(i)=0;
				o.pmatrix=1;
			end
		end
		
		axes(gh('OutputAxis'));
		if plottype==1
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis([0.001 0.05]);
			set(gh('StatsText'),'String',['Wilcoxon Matched Pairs Test performed on the PSTH for each matrix location, plotting the p-value probability. n = ' num2str(o.n)]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==2
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.hmatrix);
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			set(gca,'Tag','OutputAxis');
			set(gh('StatsText'),'String',['Wilcoxon Matched Pairs Test performed on the PSTH for each matrix location, plotting the Null-Test Hypothesis Result. A value of 1 signifies that we can reject the null hypothesis that the two samples come fromthe same distribution. n = ' num2str(o.n)]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		else
			h=errordlg('You can only plot p-values or Hypothesis Test, switching to p-values.')
			pause(1)
			close(h)
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis([0.001 0.05]);
			set(gh('StatsText'),'String',['Wilcoxon Matched Pairs Test performed on the PSTH for each matrix location, plotting the p-value probability. n = ' num2str(o.n)]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		end
		
		
		%-----------------------------------------------------------------------------------------
	case 'I: Wilcoxon Rank Sum'
		%-----------------------------------------------------------------------------------------
		
		if strcmp(o.spiketype,'none')
			errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
			error('need to measure psth');
		end
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		o.hmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.pmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		for i=1:o.cell1.xrange*o.cell1.yrange
			if o.position1(i)>0 | o.position2(i)>0
				switch o.spiketype
					case 'raw'
						[p,h]=ranksum(o.cell1sums{i},o.cell2sums{i},'alpha',alpha);
						o.n=length(o.cell1sums{1});
					case 'psth'
						[p,h]=ranksum(o.cell1spike{i},o.cell2spike{i},'alpha',alpha);
						o.n=length(o.cell1spike{1});
					case 'isi'
						[p,h]=ranksum(o.cell1sums{i},o.cell2sums{i},'alpha',alpha);
						o.n=length(o.cell1sums{1});
					case 'isih'
						[p,h]=ranksum(o.cell1spike{i},o.cell2spike{i},'alpha',alpha);
						o.n=length(o.cell1spike{1});
				end				
				o.hmatrix(i)=h;
				o.pmatrix(i)=p;
			else
				o.hmatrix(i)=0;
				o.pmatrix=1;
			end
		end
		
		axes(gh('OutputAxis'));
		if plottype==1
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis([0.001 0.05]);
			set(gh('StatsText'),'String',['Wilcoxon Rank Sum performed on the PSTH for each matrix location, plotting the p-value probability. n = ' num2str(o.n)]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==2
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.hmatrix);
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			set(gca,'Tag','OutputAxis');
			set(gh('StatsText'),'String',['Wilcoxon Rank Sum performed on the PSTH for each matrix location, plotting the Null-Test Hypothesis Result. A value of 1 signifies that we can reject the null hypothesis that the two samples come fromthe same distribution. n = ' num2str(o.n)]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		else
			h=errordlg('You can only plot p-values or Hypothesis Test, switching to p-values')
			pause(1)
			close(h)
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis([0.001 0.05]);
			set(gh('StatsText'),'String',['Wilcoxon Rank Sum performed on the PSTH for each matrix location, plotting the p-value probability. n = ' num2str(o.n)]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		end
		%-----------------------------------------------------------------------------------------
	case 'I: Paired T-test'
		%-----------------------------------------------------------------------------------------
		
		if strcmp(o.spiketype,'none')
			errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
			error('need to measure psth');
		end
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		o.hmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.pmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		for i=1:o.cell1.xrange*o.cell1.yrange
			if o.position1(i)>0 | o.position2(i)>0
				switch o.spiketype
					case 'raw'
						[h,p]=ttest(o.cell1sums{i},o.cell2sums{i},alpha);
						o.n=length(o.cell1sums{1});
					case 'psth'
						[p,h]=ttest(o.cell1spike{i},o.cell2spike{i},alpha);
						o.n=length(o.cell1spike{1});
					case 'isi'
						[h,p]=ttest(o.cell1sums{i},o.cell2sums{i},alpha);
						o.n=length(o.cell1sums{1});
					case 'isih'
						[h,p]=ttest(o.cell1spike{i},o.cell2spike{i},alpha);
						o.n=length(o.cell1spike{1});
				end	
				o.hmatrix(i)=h;
				o.pmatrix(i)=p;
			else
				o.hmatrix(i)=0;
				o.pmatrix(i)=1;
			end
		end
		
		axes(gh('OutputAxis'));
		if plottype==1
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0.001 0.05]);
			set(gh('StatsText'),'String',['Student T Test performed on the PSTH for each matrix location, plotting the p-value probability. n = ' num2str(o.n)]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==2
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.hmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0 1]);
			set(gh('StatsText'),'String',['Student T Test performed on the PSTH for each matrix location, plotting the Null-Test Hypothesis Result. A value of 1 signifies that we can reject the null hypothesis that the two samples come fromthe same distribution. n = ' num2str(o.n)]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		else
			h=errordlg('You can only plot p-values or Hypothesis Test, switching to p-values');
			pause(1);
			close(h);
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);			
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			set(gca,'Tag','OutputAxis');
			caxis(gh('OutputAxis'),[0.001 0.05]);
			set(gh('StatsText'),'String',['Student T Test performed on the PSTH for each matrix location, plotting the p-value probability. n = ' num2str(o.n)]);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		end		
		
		%-----------------------------------------------------------------------------------------
	case 'I: Paired Sign Test'
		%-----------------------------------------------------------------------------------------
		
		if strcmp(o.spiketype,'none')
			errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
			error('need to measure psth');
		end
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		o.hmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.pmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		for i=1:o.cell1.xrange*o.cell1.yrange
			if o.position1(i)>0 | o.position2(i)>0
				switch o.spiketype
					case 'raw'
						[p,h]=signtest(o.cell1sums{i},o.cell2sums{i},alpha);
					case 'psth'
						[p,h]=signtest(o.cell1spike{i},o.cell2spike{i},alpha);
					case 'isi'
						[p,h]=signtest(o.cell1sums{i},o.cell2sums{i},alpha);
					case 'isih'
						[p,h]=signtest(o.cell1spike{i},o.cell2spike{i},alpha);
				end					
				o.hmatrix(i)=h;
				o.pmatrix(i)=p;
			else
				o.hmatrix(i)=0;
				o.pmatrix(i)=1;
			end
		end
		
		axes(gh('OutputAxis'));
		if plottype==1
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0.001 0.05]);
			set(gh('StatsText'),'String',['';'';'';'Paired Sign Test performed on the PSTH for each matrix location, plotting the p-value probability']);
			colormap(hot);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==2
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.hmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0 1]);
			set(gh('StatsText'),'String',['';'';'';'Paired Sign Test performed on the PSTH for each matrix location, plotting the Null-Test Hypothesis Result. A value of 1 signifies that we can reject the null hypothesis that the two samples come fromthe same distribution']);
			colormap(hot);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		else
			h=errordlg('You can only plot p-values or Hypothesis Test, switching to p-values')
			pause(1)
			close(h)
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0.001 0.05]);
			set(gh('StatsText'),'String',['';'';'';'Paired Sign Test performed on the PSTH for each matrix location, plotting the p-value probability']);
			colormap(hot);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		end
		
		%-----------------------------------------------------------------------------------------
	case 'I: Kolmogorov-Smirnof Distribution Test'
		%-----------------------------------------------------------------------------------------
		
		if strcmp(o.spiketype,'none')
			errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
			error('need to measure psth');
		end
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		o.hmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.pmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		for i=1:o.cell1.xrange*o.cell1.yrange
			if (o.position1(i)==1 && o.position2(i)==1) 
				switch o.spiketype
					case 'raw'
						if length(o.cell1spike{i})>0 && length(o.cell2spike{i})>0
							[h,p]=kstest2(o.cell1spike{i},o.cell2spike{i},alpha);
						else
							h=0;
							p=1;
						end
					case 'psth'
						if length(o.cell1spike{i})>0 && length(o.cell2spike{i})>0
							[h,p]=kstest2(o.cell1spike{i},o.cell2spike{i},alpha);
						else
							h=0;
							p=1;
						end
					case 'isi'
						if length(o.cell1spike{i})>1 && length(o.cell2spike{i})>1
							[h,p]=kstest2(o.cell1spike{i},o.cell2spike{i},alpha);
						else
							h=0;
							p=1;
						end
					case 'isih'
						if length(o.cell1spike{i})>1 && length(o.cell2spike{i})>1
							[h,p]=kstest2(o.cell1spike{i},o.cell2spike{i},alpha);
						else
							h=0;
							p=1;
						end
				end		
				o.hmatrix(i)=h;
				o.pmatrix(i)=p;
			elseif o.position1(i)==1 | o.position2(i)==1
				o.hmatrix(i)=1;
				o.pmatrix(i)=0.00001;
			elseif o.position1(i)==0 & o.position2(i)==0
				o.hmatrix(i)=0;
				o.pmatrix(i)=1;
			end
		end
				
		axes(gh('OutputAxis'));		
		if plottype==1
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0.001 0.05]);
			set(gh('StatsText'),'String',['';'';'';'Kolmogorov-Smirnov Distribution Test performed on the PSTH for each matrix location, plotting the p-value probability']);
			colormap(hot);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==2
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.hmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0 1]);
			set(gh('StatsText'),'String',['';'';'';'Kolmogorov-Smirnov Distribution Test performed on the PSTH for each matrix location, plotting the Null-Test Hypothesis Result. 1 signifies that we can reject the null hypothesis that the two samples come fromthe same distribution']);
			colormap(hot);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		else
			errordlg('You can only plot p-values or Hypothesis Test, switching to p-values')
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0.001 0.05]);
			set(gh('StatsText'),'String',['';'';'';'Kolmogorov-Smirnov Distribution Test performed on the PSTH for each matrix location, plotting the p-value probability']);
			colormap(hot);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		end
		
		%-----------------------------------------------------------------------------------------
	case 'I: Bootstrap'
		%-----------------------------------------------------------------------------------------
		
		if strcmp(o.spiketype,'none')
			errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
			error('need to measure psth');
		end
		alpha=str2num(get(gh('AlphaEdit'),'String'));
		nboot=str2num(get(gh('OPNBootstraps'),'String'));
		boottype=get(gh('OPBootstrapFun'),'Value');
		o.hmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.pmatrix=zeros(o.cell1.yrange,o.cell1.xrange);
		o.n=length(o.cell1sums{1});
		for i=1:o.cell1.xrange*o.cell1.yrange
			if o.position1(i)==1 & o.position2(i)==1
				switch o.spiketype
					case 'raw'						
						[c1,c2]=doboot(boottype,nboot,alpha,o.cell1sums{i},o.cell2sums{i});
						if (c1(2)<c2(1) || c2(2)<c1(1))
							h=1;
							p=0.04;
						else
							h=0;
							p=1;
						end						
					case 'psth'
						[c1,c2]=doboot(boottype,nboot,alpha,o.cell1spike{i},o.cell2spike{i});
						if (c1(2)<c2(1) || c2(2)<c1(1))
							h=1;
							p=0.04;
						else
							h=0;
							p=1;
						end	
					case 'isi'
						[c1,c2]=doboot(boottype,nboot,alpha,o.cell1sums{i},o.cell2sums{i})
						if (c1(2)<c2(1) || c2(2)<c1(1))
							h=1;
							p=0.04;
						else
							h=0;
							p=1;
						end	
					case 'isih'
						[c1,c2]=doboot(boottype,nboot,alpha,o.cell1spike{i},o.cell2spike{i})
						if (c1(2)<c2(1) || c2(2)<c1(1))
							h=1;
							p=0.04;
						else
							h=0;
							p=1;
						end	
				end		
				o.hmatrix(i)=h;
				o.pmatrix(i)=p;
			elseif o.position1(i)==1 | o.position2(i)==1
				o.hmatrix(i)=1;
				o.pmatrix(i)=0.049;
			elseif o.position1(i)==0 & o.position2(i)==0
				o.hmatrix(i)=0;
				o.pmatrix(i)=1;
			end
		end
				
		axes(gh('OutputAxis'));		
		if plottype==1
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0.001 0.05]);
			set(gh('StatsText'),'String',['BootStrap performed on the Spikes for each matrix location, plotting the p-value probability. n = ' num2str(o.n)]);
			colormap(hot);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		elseif plottype==2
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.hmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0 1]);
			set(gh('StatsText'),'String',['Bootstrap performed on the PSTH for each matrix location, plotting the Null-Test Hypothesis Result. 1 signifies that we can reject the null hypothesis that the two samples come fromthe same distribution. n = ' num2str(o.n)]);
			colormap(hot);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		else
			errordlg('You can only plot p-values or Hypothesis Test, switching to p-values')
			imagesc(o.cell1.xvalues,o.cell1.yvalues,o.pmatrix);
			set(gca,'Tag','OutputAxis');
			set(gca,'YDir','normal');set(gca,'Units','Pixels');
			caxis(gh('OutputAxis'),[0.001 0.05]);
			set(gh('StatsText'),'String',['Bootstrap performed on the PSTH for each matrix location, plotting the p-value probability. n = ' num2str(o.n)]);
			colormap(hot);
			colorbar('peer',gh('OutputAxis'),'FontSize',7);
			set(gh('OutputAxis'),'Position',o.ax3pos);	
		end
		
		%end of the Orbanise loop
	end
	
	%-----------------------------------------------------------------------------------------
case 'Save Text'
	%-----------------------------------------------------------------------------------------
	
	if ~isempty(o.text)
		[f,p]=uiputfile({'*.txt','Text Files';'*.*','All Files'},'Save Information to:');
		cd(p)
		fid=fopen([p,f],'wt+');
		for i=1:length(o.text)
			fprintf(fid,'%s\n',o.text{i});
		end
		fclose(fid);
	else
		
	end
	
	
	%-----------------------------------------------------------------------------------------
case 'Spawn'
	%-----------------------------------------------------------------------------------------
	
	figure
	imagesc(o.cell1.xvalues,o.cell1.yvalues,o.cell1mat);
	if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
	if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
	colormap(hot);
	colorbar('vert');
	xlabel('X Values')
	ylabel('Y Values')
	title('Control Receptive Field')
	set(gca,'Tag','Cell1AxisSpawn');
	axis square
	
	figure
	imagesc(o.cell2.xvalues,o.cell2.yvalues,o.cell2mat);
	if o.cell2.xvalues(1) > o.cell2.xvalues(end);set(gca,'XDir','reverse');end
	if o.cell2.yvalues(1) > o.cell2.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
	colormap(hot);
	colorbar('vert');
	xlabel('X Values')
	ylabel('Y Values')
	title('Drug Receptive Field')
	set(gca,'Tag','Cell2AxisSpawn');
	axis square
	a=get(gca,'Position');
	
	axes(gh('OutputAxis'));
	h=gca;
	childfigure=figure;
	copyobj(h,childfigure)
	set(gca,'Units','Normalized');
	set(gca,'Position',[0.1300    0.1100    0.6626    0.8150]);
	colorbar
	title('Statistical Result')
    set(gca,'Tag','OutputAxisSpawn');
	axis square
	
	%-----------------------------------------------------------------------------------------
case 'PlotAll'
	%-----------------------------------------------------------------------------------------
	PlotAll(o.cell1)
	PlotAll(o.cell2)
	
	%-----------------------------------------------------------------------------------------
case 'Exit'
	%-----------------------------------------------------------------------------------------
	
	clear o;
	close(gcf);
	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [m,mm]=findmax(psth,m,mm)
	if m<=max(psth);                 %find max - simple peak algorithm
		m=max(psth);
	end
	n=find(psth>(max(psth)-(std(psth)))); %look for all bins within a std of the max - more intelligent.
	for pp=1:length(n)
		if n(pp)==1                 %make sure our maximum isn't at beginning or end of the data
			n(pp)=2;
		elseif n(pp)==length(psth)
			n(pp)=length(psth)-1;
		end
		nn=sum(psth(n(pp)-1:n(pp)+1))/3; %average over 3 bins
		if nn>mm  %check if this average is bigger than any others in data
			mm=nn;
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [spikes,mat]=normaliseit(spikes,Normalise,m,mm,numtrials,nummods,time,wrapped)
switch Normalise				
	case 1 %no normalisation
			if wrapped==1
				mat=((sum(spikes)/(numtrials*nummods))/time)*1000;		
				%spikes=smooth2(spikes,1); %apply a little smoothing
			else
				mat=((sum(spikes)/numtrials)/time)*1000;		
				%spikes=smooth2(spikes,1); %apply a little smoothing
			end	
	case 2 % use % of max single bin
			spikes=spikes/m;
			mat=mean(spikes);
			%spikes=smooth2(spikes,1); %apply a little smoothing
	case 3  % use % of max bin +- a bin
			spikes=spikes/mm;
			mat=mean(spikes);
			%spikes=smooth2(spikes,1); %apply a little smoothing
	case 4 % z-score
			spikes=zscore(spikes);
			mat=sum(spikes);
			%spikes=smooth2(spikes,1); %apply a little smoothing
end
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ci1,ci2]=doboot(boottype,nboot,alpha,data1,data2)
switch boottype
	case 1
		ci1=bootci(nboot,{@mean,data1},'alpha',alpha);
		ci2=bootci(nboot,{@mean,data2},'alpha',alpha);
	case 2
		ci1=bootci(nboot,{@median,data1},'alpha',alpha);
		ci2=bootci(nboot,{@median,data2},'alpha',alpha);
	case 3
		ci1=bootci(nboot,{@geomean,data1},'alpha',alpha);
		ci2=bootci(nboot,{@geomean,data2},'alpha',alpha);
	case 4
		ci1=bootci(nboot,{@trimmean,data1,5},'alpha',alpha);
		ci2=bootci(nboot,{@trimmean,data2,5},'alpha',alpha);
	case 5
		ci1=bootci(nboot,{@trimmean,data1,10},'alpha',alpha);
		ci2=bootci(nboot,{@trimmean,data2,10},'alpha',alpha);
	case 6
		ci1=bootci(nboot,{@std,data1},'alpha',alpha);
		ci2=bootci(nboot,{@std,data2},'alpha',alpha);
	case 7
		ci1=bootci(nboot,{@var,data1},'alpha',alpha);
		ci2=bootci(nboot,{@var,data2},'alpha',alpha);
	case 8
		ci1=bootci(nboot,{@stderr,data1,'F',1},'alpha',alpha);
		ci2=bootci(nboot,{@stderr,data2,'F',1},'alpha',alpha);
	case 8
		ci1=bootci(nboot,{@stderr,data1,'C',1},'alpha',alpha);
		ci2=bootci(nboot,{@stderr,data2,'C',1},'alpha',alpha);
	case 8
		ci1=bootci(nboot,{@stderr,data1,'A',1},'alpha',alpha);
		ci2=bootci(nboot,{@stderr,data2,'A',1},'alpha',alpha);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updategui()
global o
set(gh('OPHoldX'),'String',{o.cell1.xvalues'});
set(gh('OPHoldY'),'String',{o.cell1.yvalues'});
set(gh('OPHoldZ'),'String',{o.cell1.zvalues'});
set(gh('OPHoldX'),'Value',ceil(o.cell1.xrange/2));
set(gh('OPHoldY'),'Value',ceil(o.cell1.yrange/2));
set(gh('OPHoldZ'),'Value',ceil(o.cell1.zrange/2));
set(gh('OPHoldZ'),'Enable','off');
	
set(gh('OPCellMenu'),'String',{'Cell 1';'Cell 2'});

if strcmp(o.filetype,'mat')
	set(findobj('UserData','PSTH'),'Enable','On');
	set(gh('BinWidthEdit'),'String',o.cell1.binwidth);
	if o.cell1.wrapped == 1; set(gh('WrappedBox'),'Value',1); else set(gh('WrappedBox'),'Value',0); end
	t=num2str((1:o.cell1.raw{1}.numtrials)');
	set(gh('StartTrialMenu'),'String',t);
	set(gh('StartTrialMenu'),'Value',1);
	set(gh('EndTrialMenu'),'String',t);
	set(gh('EndTrialMenu'),'Value',o.cell1.raw{1}.numtrials);
	set(gh('InfoText'),'String',['Spike Data Loaded:' o.cell1.matrixtitle '/' o.cell2.matrixtitle]);
	set(gh('OPStatsMenu'),'String',{'1D Gaussian';'2D Gaussian';'Vector';'---------';'M: Dot Product';'M: Spearman Correlation';'M: Pearsons Correlation';'M: 1-Way Anova';'M: Paired T-test';'M: Kolmogorov-Smirnof Distribution Test';'M: Ansari-Bradley Variance';'M: Fano T-test';'M: Fano Wilcoxon';'M: Fano Paired Wilcoxon';'M: Fano Spearman';'---------';'Column: Spontaneous';'---------';'I: Paired T-test';'I: Paired Sign Test';'I: Wilcoxon Rank Sum';'I: Wilcoxon Paired Test';'I: Bootstrap';'I: Spearman Correlation';'I: Pearsons Correlation';'I: 1-Way Anova';'I: Kolmogorov-Smirnof Distribution Test'});
	o.cell1.max=max(max(o.cell1.matrix));
	o.cell2.max=max(max(o.cell2.matrix));
	if get(gh('MatrixBox'),'Value')==1
		o.cell1.matrix=(o.cell1.matrix/o.cell1.max)*100;
		o.cell2.matrix=(o.cell2.matrix/o.cell2.max)*100;
	end
else
	set(findobj('UserData','PSTH'),'Enable','Off');
	set(gh('InfoText'),'String','Text Files Loaded');
	set(gh('NormaliseMenu'),'String',{'none';'% of Max'});
	set(gh('OPStatsMenu'),'String',{'1D Gaussian';'2D Gaussian';'Vector';'---------';'M: Dot Product';'M: Spearman Correlation';'M: Pearsons Correlation';'M: 1-Way Anova';'M: Paired T-test';'M: Kolmogorov-Smirnof Distribution Test';'M: Ansari-Bradley Variance'});
end

if get(gh('RatioBox'),'Value')==1
	o.cell1.temp=o.cell1.matrix;
	o.cell1.matrix=o.cell1.bmatrix./o.cell1.matrix;
	o.cell2.temp=o.cell2.matrix;
	o.cell2.matrix=o.cell2.bmatrix./o.cell2.matrix;
end

axes(gh('Cell1Axis'))
imagesc(o.cell1.xvalues,o.cell1.yvalues,o.cell1.matrix);
%if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
%if o.cell1.yvalues(1) < o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
set(gca,'YDir','normal')
%colormap(hot);
set(gca,'Tag','Cell1Axis');	
colorbar('peer',gh('Cell1Axis'),'FontSize',7);	
set(gh('Cell1Axis'),'Position',o.ax1pos);
if length(o.cell1.names) < 3
	title(o.cell1.names,'FontSize',10)
end
for i = 1:o.cell1.xrange
	for j = 1:o.cell1.yrange
		t = {num2str([o.cell1.xvalues(i) o.cell1.yvalues(j)])};
		t{1} = regexprep(t{1},'\s+',' ');
		t{2} = o.cell1.names{j,i};
		text(o.cell1.xvalues(i),o.cell1.yvalues(j), t, 'FontSize', 7, 'Color', [0 0.5 1]);
	end
end

axes(gh('Cell2Axis'));
imagesc(o.cell2.xvalues,o.cell2.yvalues,o.cell2.matrix);
%if o.cell2.xvalues(1) > o.cell2.xvalues(end);set(gca,'XDir','reverse');end
%if o.cell2.yvalues(1) > o.cell2.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
set(gca,'YDir','normal')
%colormap(hot);
set(gca,'Tag','Cell2Axis');
colorbar('peer',gh('Cell2Axis'),'FontSize',7);	
set(gh('Cell2Axis'),'Position',o.ax2pos);
if length(o.cell2.names) < 3
	title(o.cell2.names,'FontSize',10)
end
for i = 1:o.cell2.xrange
	for j = 1:o.cell2.yrange
		t = {num2str([o.cell2.xvalues(i) o.cell2.yvalues(j)])};
		t{1} = regexprep(t{1},'\s+',' ');
		t{2} = o.cell2.names{j,i};
		text(o.cell2.xvalues(i),o.cell2.yvalues(j), t, 'FontSize', 7, 'Color', [0 0.5 1]);
	end
end

axes(gh('OutputAxis'));
plot(0,0);
set(gca,'Tag','OutputAxis');
set(gh('OutputAxis'),'Position',o.ax3pos);	
% 	if strcmp(o.filetype,'mat')
% 		%helpdlg('Both cells have been loaded, select your analysis routine, and measure the PSTH for the statistics');
% 	else
% 		%helpdlg('You have loaded text files, select your analysis routine, and OrbanizeIT!');
% 	end
if get(gh('OPAutoMeasure'),'Value')==1
	opro('Measure');
end

%-----------------------------------------------------------------------------
%FUNCTION DEFINITION /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
%-----------------------------------------------------------------------------
%
% Plot PSTHs in a grid

function PlotAll(data)
global o

xhold=get(gh('OPHoldX'),'Value');
yhold=get(gh('OPHoldY'),'Value');
zhold=get(gh('OPHoldZ'),'Value');
binwidth=str2num(get(gh('BinWidthEdit'),'String'));
wrapped=get(gh('WrappedBox'),'Value');
ccell=get(gh('OPCellMenu'),'Value');
Normalise=get(gh('NormaliseMenu'),'Value');
starttrial=get(gh('StartTrialMenu'),'Value');
endtrial=get(gh('EndTrialMenu'),'Value');
if get(gh('OPAllTrials'),'Value') > 0
	starttrial = 1;
	endtrial = inf;
end
	
o.allhandle=figure;
set(gcf,'Tag','allplotfig');
figpos(3,[1000 1000]);
set(gcf,'Color',[1 1 1]);
mint = o.mint;
maxt = o.maxt;
mini=find(data.time{1}==mint);
maxi=find(data.time{1}==maxt);

switch data.numvars
		case 0
		
	case 1
		
	otherwise
		p = panel(o.allhandle);
		s = size(data.psth);
		xrange=s(2);
		yrange=s(1);
		if length(s) < 3
			zrange = 1;
		else
			zrange=s(3);
		end
		
		starti=1;
		endi=xrange*yrange*zrange;
		
		if data.numvars==3 %we need to correct the index for the third variable
			xmult = xrange*zrange;
		else
			xmult = xrange;
		end
		
		m=1; %this will find the max value out of all the PSTH's and scale by this
		for i=starti:endi
			maxm=max(data.psth{i}(mini:maxi));
			if m < maxm
				m = maxm;
			end
		end
		mm = converttotime(m,binwidth,data.numtrials,data.nummods,wrapped);
		xm=round(m+m/10);  %just to scale a bit bigger than the maximum value
		
		x = starti:endi;
		xx = reshape(x,yrange,xmult);
		a=1;
		p.pack(yrange,xmult);
		for i=1:length(x)
			[i1,i2] = ind2sub([yrange,xmult],xx(i));
			time = data.time{i}(mini:maxi);
			psth = data.psth{i}(mini:maxi);
			psth = (psth/m) * mm;
			bpsth = data.bpsth{i}(mini:maxi);
			p(i1,i2).pack('v',[2/3 -1]);
			p(i1,i2,1).select();
			h(1)=bar(time, psth , 1, 'k');
			p(i1,i2,1).hold('on')
			h(2)=bar(time, bpsth, 1, 'r');
			set(h,'BarWidth', 1,'EdgeColor','none', 'ShowBaseLine', 'off')
			if i <= yrange
				p(i1,i2,1).ylabel('Firing Rate (Hz)');
				set(gca,'TickLength',[0.01 0.01],'TickDir','in','XTickLabel',[],'XGrid','on','YGrid','on');
			else
				set(gca,'TickLength',[0.01 0.01],'TickDir','in','XTickLabel',[],'YTickLabel',[],'XGrid','on','YGrid','on');
			end
			axis([data.time{i}(mini) data.time{i}(maxi) 0 mm]);
			text(data.time{i}(mini), (mm-mm/20), data.names{i},'FontSize',12,'Color',[0.7 0.7 0.7]);
			p(i1,i2,1).hold('off')
			p(i1,i2,2).select();
			plotraster(data.raw{i});
			axis([data.time{i}(mini)/1000 data.time{i}(maxi)/1000 -inf inf]);
			if i <= yrange
				set(gca,'TickLength',[0.01 0.01],'TickDir','in');
			else
				p(i1,i2,2).ylabel('');
				set(gca,'TickLength',[0.01 0.01],'TickDir','in','YTickLabel',[]);
			end
			if ~mod(i,yrange) == 0
				set(gca, 'XTickLabel',[]);
			end
			a=a+1;
		end
		t=[data.runname ' Cell:'  ' [BW:' num2str(binwidth) 'ms Trials:' num2str(starttrial) '-' num2str(endtrial) '] max = ' num2str(mm) ' time = ' num2str(mint) '-' num2str(maxt) 'ms'];
		if data.numvars==3
			t=[t '\newline Z VALUES ' data.ztitle '=' num2str(data.zvalues)];
		end
		if isa(data.pR,'plxReader')
			t=[ t '\newline PLX Offset = ' num2str(data.pR.startOffset) ' | Cellmap = ' num2str(data.cell) '>' num2str(data.pR.cellmap(data.cell)) ' ' data.pR.tsList.names{data.pR.cellmap(data.cell)}];
		end
		p.xlabel([data.xtitle ' (' num2str(data.xvalues) ')']);
		p.ylabel([data.ytitle ' (' num2str(fliplr(data.yvalues)) ')']);
		p.title(t);
		p.de.margin = 0;
		p.margin = [15 15 5 15];
		p.fontsize = 12;
		p.de.fontsize = 10;
		%[ax,h1]=suplabel([data.xtitle ' (' num2str(data.xvalueso) ')'],'x');
		%[ax,h2]=suplabel([data.ytitle ' (' num2str(data.yvalueso) ')'],'y');
		%[ax,h3]=suplabel(t ,'t');
		%set(h1,'FontSize',12)
		% because we 'defer'red, we have to refresh.
		%p.refresh();
		
end
set(gcf,'Renderer','painters','ResizeFcn',[]);
