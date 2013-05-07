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
	[file path]=uigetfile('*.*','Load 1st Processed Matrix:');
	if file==0; error('1st File appears empty.'); end;
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
	
	updategui();
	

	%-----------------------------------------------------------------------------------------
case 'Reparse'
	%-----------------------------------------------------------------------------------------
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
	
	for i = 1:2
		if isfield(o,['cell' num2str(i) 'bak']);
			c = o.(['cell' num2str(i) 'bak']);
		else
			c = o.(['cell' num2str(i)]);
		end
		vars = sort( map{i} );
		raw = c.raw{vars(1)};
		for j = 2:length(vars)
			raw.name = [raw.name '|' c.raw{vars(j)}.name];
			raw.totaltrials = raw.totaltrials + c.raw{vars(j)}.totaltrials;
			raw.numtrials = raw.numtrials + c.raw{vars(j)}.numtrials;
			raw.endtrial = raw.numtrials;
			raw.trial = [raw.trial, c.raw{vars(j)}.trial];
			raw.maxtime = max([raw.maxtime, c.raw{vars(j)}.maxtime]);
			raw.tDelta = [raw.tDelta; c.raw{vars(j)}.tDelta];
			raw.btrial = [raw.btrial, c.raw{vars(j)}.btrial];
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
	
	
	o.fano1 = fanoPlotter;
	o.fano2 = fanoPlotter;
	
	o.fano1.convertSpikesFormat(o.cell1, map{1});
	o.fano2.convertSpikesFormat(o.cell2, map{2});
	
	set(gh('WrappedBox'), 'Value', 0);
	set(gh('OPAllTrials'), 'Value', 1);
	updategui()
	
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
	
	o.cell1spike=cell(o.cell1.yrange,o.cell1.xrange);  %set up our spike holding matrices
	o.cell2spike=cell(o.cell2.yrange,o.cell2.xrange);
	o.cell1time=cell(o.cell1.yrange,o.cell1.xrange);
	o.cell2time=cell(o.cell1.yrange,o.cell1.xrange);
	o.cell1raws=cell(o.cell1.yrange,o.cell1.xrange);
	o.cell2raws=cell(o.cell1.yrange,o.cell1.xrange);
	o.cell1raw=cell(o.cell1.yrange,o.cell1.xrange);
	o.cell2raw=cell(o.cell1.yrange,o.cell1.xrange);
	o.cell1mat=zeros(o.cell1.yrange,o.cell1.xrange);
	o.cell2mat=zeros(o.cell2.yrange,o.cell2.xrange);
	o.position1=ones(o.cell1.yrange,o.cell1.xrange);
	o.position2=ones(o.cell2.yrange,o.cell2.xrange);
	
	m=1;
	mm=1;
	m2=1;
	mm2=1;
	%lets get our spikes	
	for i=1:o.cell1.xrange
		for j=1:o.cell1.yrange			
			raw1=o.cell1.raw{o.cell1.yindex(j),o.cell1.xindex(i)};
			raw2=o.cell2.raw{o.cell2.yindex(j),o.cell2.xindex(i)};
			if get(gh('BurstBox'),'Value')==0
				[time,psth,rawl,sm,raws]=binit(raw1,binwidth*10,1,inf,starttrial,endtrial,wrapped);
				[time2,psth2,rawl2,sm2,raws2]=binit(raw2,binwidth*10,1,inf,starttrial,endtrial,wrapped);
				e1=finderror(raw1,'Fano Factor',mint,maxt+binwidth,wrapped,0);
				e2=finderror(raw2,'Fano Factor',mint,maxt+binwidth,wrapped,0);
			else
				[time,psth,rawl,sm,raws]=binitb(raw1,binwidth*10,1,inf,starttrial,endtrial,wrapped);
				[time2,psth2,rawl2,sm2,raws2]=binitb(raw2,binwidth*10,1,inf,starttrial,endtrial,wrapped);
				e1=finderror(raw1,'Fano Factor',mint,maxt+binwidth,wrapped,1);
				e2=finderror(raw2,'Fano Factor',mint,maxt+binwidth,wrapped,1);
			end			
			psth=psth(find(time>=mint&time<=maxt));
			psth2=psth2(find(time2>=mint&time2<=maxt));
			time=time(find(time>=mint&time<=maxt));
			time2=time2(find(time2>=mint&time2<=maxt));
			rawl=rawl(find(rawl>=mint&rawl<=maxt));
			rawl2=rawl2(find(rawl2>=mint&rawl2<=maxt));
			for k=1:length(raws)
				raws(k).trial=raws(k).trial(find(raws(k).trial>=mint&raws(k).trial<=maxt));
				sm(k)=length(raws(k).trial);
			end
			for k=1:length(raws2)
				raws2(k).trial=raws2(k).trial(find(raws2(k).trial>=mint&raws2(k).trial<=maxt));
				sm2(k)=length(raws2(k).trial);
			end
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
			o.cell1error{j,i}=e1;
			o.cell2error{j,i}=e2;
			
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
					o.cell1mat(j,i)=length(o.cell1spike{j,i});
					o.cell2mat(j,i)=length(o.cell2spike{j,i});
					set(gh('StatsText'),'String','Plotting the number of spikes per variable');
				case 2 %psth
					[o.cell1spike{j,i},o.cell1mat(j,i)]=normaliseit(o.cell1spike{j,i},Normalise,m,mm,raw1.numtrials,raw1.nummods,maxt-mint,wrapped);
					[o.cell2spike{j,i},o.cell2mat(j,i)]=normaliseit(o.cell2spike{j,i},Normalise,m2,mm2,raw2.numtrials,raw2.nummods,maxt-mint,wrapped);					
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
	if wrapped==1
		o.cell1.matrix=o.cell1mat/length(o.cell1sums{1});
		o.cell1.matrix=o.cell1.matrix*(1000/(o.cell1.modtime/10));
		o.cell2.matrix=o.cell2mat/length(o.cell2sums{1});
		o.cell2.matrix=o.cell2.matrix*(1000/(o.cell2.modtime/10));
	else
		o.cell1.matrix=o.cell1mat/length(o.cell1sums{1});
		o.cell1.matrix=o.cell1.matrix*(1000/(o.cell1.trialtime/10));
		o.cell2.matrix=o.cell2mat/length(o.cell2sums{1});
		o.cell2.matrix=o.cell2.matrix*(1000/(o.cell2.trialtime/10));
	end
		
	axes(gh('Cell1Axis'))
	imagesc(o.cell1.xvalues,o.cell1.yvalues,o.cell1.matrix);
	set(gca,'Tag','Cell1Axis');
	%if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
	%if o.cell1.yvalues(1) > o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
	set(gca,'YDir','normal')
	colormap(hot);
	%axis square
	colorbar('peer',gh('Cell1Axis'),'FontSize',7);	
	xlabel(o.cell1.xtitle);
	ylabel(o.cell1.ytitle);
	set(gca,'Position',o.ax1pos);
   set(gca,'Tag','Cell1Axis');
	
	axes(gh('Cell2Axis'));
	imagesc(o.cell2.xvalues,o.cell2.yvalues,o.cell2.matrix);
	set(gca,'Tag','Cell2Axis');
	%if o.cell2.xvalues(1) > o.cell2.xvalues(end);set(gca,'XDir','reverse');end
	%if o.cell2.yvalues(1) > o.cell2.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
	set(gca,'YDir','normal')
	colormap(hot);
	colorbar('peer',gh('Cell2Axis'),'FontSize',7);	
	%axis square
	xlabel(o.cell2.xtitle);
	ylabel(o.cell2.ytitle);
	set(gca,'Position',o.ax2pos);
	set(gca,'Tag','Cell2Axis');	
	
	axes(gh('OutputAxis'));
	plot(0,0);
	set(gca,'Tag','OutputAxis');
	set(gh('OutputAxis'),'Position',o.ax3pos);	
	
	%---Now we are going to plot out both spike trains for visual comparison.
	
	if get(gh('OPShowPlots'),'Value')==1 %plot histograms
		set(gh('StatsText'),'String','Please wait, plotting additional info for each matrix point...');
		figure;
		set(gcf,'Position',[150 10 700 650]);
		set(gcf,'Name','PSTH/ISI Plots for Control (black) and Drug (Red) Receptive Fields','NumberTitle','off');
		x=1:(o.cell1.yrange*o.cell1.xrange);
		y=reshape(x,o.cell1.yrange,o.cell1.xrange);
		y=y'; %order it so we can load our data to look like the surface plots
		m=max([o.peak o.peak2]);
		for i=1:o.cell1.xrange*o.cell1.yrange
			subplot(o.cell1.yrange,o.cell1.xrange,i);
			plot(o.cell1time{i},o.cell1psth{i},'k-',o.cell2time{i},o.cell2psth{i},'r-');
			set(gca,'FontSize',5);
			axis tight;
			if strcmp(o.spiketype,'psth') && (Normalise==2 || Normalise==3)
				axis([-inf inf 0 1]);
			elseif strcmp(o.spiketype,'psth') && Normalise==1
				axis([-inf inf 0 m]);
			end
		end
		figure;
		set(gcf,'Position',[150 10 700 650]);
		set(gcf,'Name','CDF Plots for Control (Black) and Drug (Red) Receptive Fields','NumberTitle','off')
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
			title('');
			xlabel('');
			ylabel('');
			set(gca,'FontSize',4);			
		end
		figure;
		set(gcf,'Position',[100 10 700 650]);
		set(gcf,'Name','Spikes (y) per Trial (x) Plots for Control (Black) and Drug (Red) Receptive Fields','NumberTitle','off')
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
			set(gca,'FontSize',4.5);
		end
		%jointfig(h,o.cell1.yrange,o.cell1.xrange)
	end	
	set(gh('StatsText'),'String','Data has been measured.');
	
	
	%-----------------------------------------------------------------------------------------
case 'Spontaneous'
	%-----------------------------------------------------------------------------------------
	
	if strcmp(o.spiketype,'none')
		errordlg('Sorry, you need to measure the PSTH in OPRO first, set your parameters and click on the measure PSTH to do so...');
		error('need to measure psth');
	end
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
	
	if (sp1==-1 || sp2==-1)
		t={'Will Measure Spontaneous at the location indicated by the Held X / Y Variable Position';'';'';'You Chose';['X = ' num2str(o.cell1.xvalues(xhold))];['Y = ' num2str(o.cell1.yvalues(yhold))]};
		[t1,psth1]=binit(o.cell1.raw{o.cell1.yindex(yhold),o.cell1.xindex(xhold)},binwidth*10,1,inf,starttrial,endtrial,wrapped);
		[t2,psth2]=binit(o.cell2.raw{o.cell2.yindex(yhold),o.cell2.xindex(xhold)},binwidth*10,1,inf,starttrial,endtrial,wrapped);
		[mint,maxt]=measureq(t1,psth1,binwidth,psth2);
	end
	
	if (sp1==-1 && sp2==-1) %only if nothing input
		switch o.spiketype
			case 'raw'
				spikes1=o.cell1sums{yhold,xhold};
				spikes2=o.cell2sums{yhold,xhold};
				o.spontaneous1=mean(spikes1)+(2*std(spikes1));
				o.spontaneous2=mean(spikes2)+(2*std(spikes2));
			case 'psth'
				[time1,psth1]=binit(o.cell1.raw{yhold,xhold},binwidth*10,1,inf,starttrial,endtrial,wrapped);
				[time2,psth2]=binit(o.cell2.raw{yhold,xhold},binwidth*10,1,inf,starttrial,endtrial,wrapped);
				psth1=psth1;
				psth2=psth2;
				mini=find(time1==mint);
				maxi=find(time1==maxt);
				psth1=psth1(mini:maxi);
				psth2=psth2(mini:maxi);
				time1=time1(mini:maxi);
				time2=time2(mini:maxi);

				switch Normalise

				case 1 %no normalisation

				case 2 % use % of peak single bin
					psth1=psth1/o.peak;
					psth2=psth2/o.peak2;
				case 3  % use % of max bin +- a bin
					psth1=psth1/o.max;
					psth2=psth2/o.max2;
				case 4 % z-score
					psth1=zscore(psth1);
					psth2=zscore(psth2);
				end
				
				o.spontaneous1=mean(psth1)+(2*std(psth1));
				o.spontaneous2=mean(psth2)+(2*std(psth2));
				set(gh('SP1Edit'),'String',num2str(o.spontaneous1));
				set(gh('SP2Edit'),'String',num2str(o.spontaneous2));
		end
	else
		o.spontaneous1=sp1;
		o.spontaneous2=sp2;
	end

	for i=1:o.cell1.xrange*o.cell1.yrange
		switch o.spiketype
			case 'raw'
				testvalue1=mean(o.cell1sums{i});
				testvalue2=mean(o.cell2sums{i});
				if testvalue1<=o.spontaneous1
					o.cell1spike{i}=[];
					o.position1(i)=0;
				end
				if testvalue2<=o.spontaneous2
					o.cell2spike{i}=[];zeros(size(o.cell2spike{i}));
					o.position2(i)=0;
				end
				o.cell1mat(i)=length(o.cell1spike{i});
				o.cell2mat(i)=length(o.cell2spike{i});
			case 'psth'
				testvalue1=mean(o.cell1spike{i});
				testvalue2=mean(o.cell2spike{i});
				if testvalue1<=o.spontaneous1
					o.cell1spike{i}=zeros(size(o.cell1spike{i}));
					o.position1(i)=0;
				end
				if testvalue2<=o.spontaneous2
					o.cell2spike{i}=zeros(size(o.cell2spike{i}));
					o.position2(i)=0;
				end
				o.cell1mat(i)=mean(o.cell1spike{i});
				o.cell2mat(i)=mean(o.cell2spike{i});
		end
	end
	
	o.cell1.matrix=o.cell1mat;
	o.cell2.matrix=o.cell2mat;
	
	axes(gh('Cell1Axis'))
	imagesc(o.cell1.xvalues,o.cell1.yvalues,o.cell1mat);
	%if o.cell1.xvalues(1) > o.cell1.xvalues(end);set(gca,'XDir','reverse');end
	%if o.cell1.yvalues(1) < o.cell1.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
	set(gca,'YDir','normal')
	colormap(hot);
	set(gca,'Tag','Cell1Axis');	
	colorbar('peer',gh('Cell1Axis'),'FontSize',7);	
	set(gh('Cell1Axis'),'Position',o.ax1pos);
	
	axes(gh('Cell2Axis'));
	imagesc(o.cell2.xvalues,o.cell2.yvalues,o.cell2mat);
	%if o.cell2.xvalues(1) > o.cell2.xvalues(end);set(gca,'XDir','reverse');end
	%if o.cell2.yvalues(1) > o.cell2.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
	set(gca,'YDir','normal')
	colormap(hot);
	set(gca,'Tag','Cell2Axis');
	colorbar('peer',gh('Cell2Axis'),'FontSize',7);	
	set(gh('Cell2Axis'),'Position',o.ax2pos);	
	
	axes(gh('OutputAxis'));
	plot(0,0);
	set(gca,'Tag','OutputAxis');
	set(gh('OutputAxis'),'Position',o.ax3pos);	
	o.spontaneous=1
	
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
			if wrapped==0
				mat=((sum(spikes)/numtrials)/time)*1000;
				%spikes=smooth2(spikes,1); %apply a little smoothing
			elseif wrapped==1
				mat=((sum(spikes)/(numtrials*nummods))/time)*1000;				
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
set(gh('OPHoldX'),'Value',ceil(o.cell1.xrange/2));
set(gh('OPHoldY'),'Value',ceil(o.cell1.yrange/2));
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
colormap(hot);
set(gca,'Tag','Cell1Axis');	
colorbar('peer',gh('Cell1Axis'),'FontSize',7);	
set(gh('Cell1Axis'),'Position',o.ax1pos);

axes(gh('Cell2Axis'));
imagesc(o.cell2.xvalues,o.cell2.yvalues,o.cell2.matrix);
%if o.cell2.xvalues(1) > o.cell2.xvalues(end);set(gca,'XDir','reverse');end
%if o.cell2.yvalues(1) > o.cell2.yvalues(end);set(gca,'YDir','normal');set(gca,'Units','Pixels');end
set(gca,'YDir','normal')
colormap(hot);
set(gca,'Tag','Cell2Axis');
colorbar('peer',gh('Cell2Axis'),'FontSize',7);	
set(gh('Cell2Axis'),'Position',o.ax2pos);	

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