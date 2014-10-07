function crosscor(action)

%*********************************************************************
% Ian's Surface Plots for XCor Raw Data sets
%
% This reads SMR / TXT files containing spike times, computes
% the cross-correlogram for many variables, and can generate surface
% plots of a defined portion of the cross-correlogram function
%
%*********************************************************************

global TimeInterval

global PlotType CMap ShadingType
global Lighting LightAdd
global SmoothType SmoothValue

global xdata xv

global george
global loop
global corrline
global datatype
global slope
global rerun

global hw

if nargin<1;
   action='Initialize';
end

switch(action)
    %-------------------------------------------------------------------
case 'Initialize'   %assuming we have just started
    %-------------------------------------------------------------------
	crosscorfig  %load our GUI
	xv.matlabroot=regexprep(matlabroot,'Program files','Progra~1','ignorecase');
	version='Cross Correlation Analysis: V3.1a';
	if exist('c:\xdata.mat','file'); delete('c:\xdata.mat'); end
	if exist('c:\crosstemp','file');delete('c:\crosstemp'); end
	figpos(2);	%position the figure
	set(gcf,'Name', version)
	set(gh('RatioValue'),'String',{'Don''t Use';'25ms Ratio';'50ms Ratio';'100ms Ratio'});
	set(gh('IntBox'),'String',nums2strs(0.1:0.05:1));
	set(gh('IntBox'),'Value',4)
	set(gh('ShuffleNumber'),'String','trials-1');

	xv.StartBin=-5;		xv.EndBin=5;
	xv.BinWidth=4;		xv.Window=200;
	xv.FromTime=0;		xv.ToTime=Inf;
	xv.StartTrial=1;		xv.EndTrial=inf;
	xv.firstunit=1;		xv.secondunit=2;
	xv.HeldVariable=3;	xv.HeldValue=1;
	xv.Shuffles=0;		xv.pValue=0.05;
	TimeInterval=500;
	george=1;

	PlotType='CheckerBoard';
	ShadingType='interp';
	Lighting='phong';
	SmoothType='none';
	SmoothValue=5;
	CMap='jet';
	datatype='';

	slope=0;
	hw=0;

	xdata=[];

	rerun='no';
	set(gcf,'DefaultLineLineWidth',1.5);
	set(gcf,'DefaultAxesLineWidth',1.5);
	set(gca,'Layer','top');	%ticks go over data
	set(gcf,'DefaultAxesTickDir','out');  %get ticks going out
	set(0,'defaultaxesfontname','Georgia');
	set(0,'defaulttextfontname','Georgia');
	set(0,'defaulttextfontsize',8);

    %-------------------------------------------------------------------
case 'Load'
    %-------------------------------------------------------------------

   set(gh('RatioValue'),'Value',1);
   cla;
	set(gca,'Tag','XCorAxis');
   if strcmp(rerun,'yes')								%see if we have to reload the data or not
		%--Initial Parameters
		hw=0;
		slope=0;
		file=xdata.filename;
		xdata=[];
		[p,basefilename,e]=fileparts(file);
		%--Reloads from temporary file
		rerun='no';
		xdata.filetype = 'txt';
		xdata.meta=loadvstext(file);
		txtcomment=textread(strcat(p,'\',basefilename,'.cmt'),'%s','delimiter','\n','whitespace','');
		txtprotocol=textread(strcat(p,'\',basefilename,'.prt'),'%s','delimiter','\n','whitespace','');
   else
       %--Initial Parameters
       xdata=[];
%        xv.StartTrial=1;
%        xv.EndTrial=inf;
%        set(gh('StartTrial'),'String','1');
%        set(gh('EndTrial'),'String','inf');
       hw=0;
       slope=0;
       %--Get filename and run appropriate frogbit script
       [fn,pn]=uigetfile({'*.smr;*.txt;*.doc','All Spikes Filetypes (*.smr *.txt *.doc)';'*.smr','VS RAW DATA File (SMR)';'*.txt','VSX Output File (TXT)';'*.doc','XCor Output File (DOC)'},'Select File Typeto Load:');
       if isequal(fn,0)|isequal(pn,0);set(gh('LoadText'),'String','No Data Loaded');errordlg('No File Selected or Found!');error('File not selected');end
       [p,basefilename,e]=fileparts([pn fn]);
	   if regexpi(e,'\.smr')
			if isdir([p '\' basefilename])
				cd('c:\');
				disp('Deleted existing directory...');
				rmdir([p '\' basefilename],'s');
				cd(p);
			end
			s=dos([xv.matlabroot,'\user\various\vsx\vsx.exe ',pn,fn]);
			pn2 = fn(1:find(fn(:)=='.')-1);
			s=dos(['dir ',pn,pn2]);
			if s~=0; error('Sorry VSX cannot load the data!!! Make sure files do not have the read-only attribute set...'); end
			xdata.filetype = 'smr';
			xdata.meta=loadvstext([pn basefilename '\' basefilename '.txt']);
			txtcomment=textread(strcat(pn,basefilename,'\',basefilename,'.cmt'),'%s','delimiter','\n','whitespace','');
			txtprotocol=textread(strcat(pn,basefilename,'\',basefilename,'.prt'),'%s','delimiter','\n','whitespace','');
		elseif strcmpi(e,'.txt')
			xdata.filetype = 'txt';
			xdata.meta=loadvstext([pn,fn]);
			[p,basefilename,e]=fileparts([pn fn]);
			txtcomment=textread(strcat(p,'\',basefilename,'.cmt'),'%s','delimiter','\n','whitespace','');
			txtprotocol=textread(strcat(p,'\',basefilename,'.prt'),'%s','delimiter','\n','whitespace','');
       elseif strcmpi(e,'.doc')
		   	errordlg('Sorry, .doc files are an old format not safe to use, please use the .SMR!');
			error('Sorry, .doc files are an old format not safe to use, please use the .SMR!');
       else
           errordlg('Sorry, unsupported file type loaded!')
           error('File selection error')
	   end
   end

	[p,basefilename,e]=fileparts(xdata.meta.filename);	%seperate out the file from the path
	xdata.info=['===============PROTOCOL================';txtprotocol(2:end);'===============COMMENTS================';txtcomment(2:end)];
	cd(p);												%change to the directory where all the spike time files live
	xdata.meta.filename(xdata.meta.filename=='\')='/';	%stops annoying TeX interpertation errors
	t=find(xdata.meta.filename=='/');
	xdata.runname=xdata.meta.filename((t(end-2))+1:t(end)); %we make a pretty name for titles

	xdata.numvars=xdata.meta.numvars;
	xdata.protocol.name=xdata.meta.protocol;
	xdata.protocol.desc=xdata.meta.description;
	xdata.protocol.filecomm=xdata.meta.comments;
	xdata.protocol.date=xdata.meta.date;
	xdata.repeats=xdata.meta.repeats;

	if strcmp(xdata.filetype,'smr') || strcmp(xdata.filetype,'txt')
		xdata.cycles=xdata.meta.cycles;
		xdata.trialtime=xdata.meta.trialtime;
		xdata.modtime=xdata.meta.modtime;
		if isfield(xdata.meta,'tempfreq')
			xdata.tempfreq=xdata.meta.tempfreq;
		else
			xdata.tempfreq=[];
		end
	end

   %-Info from GUI
   xdata.cellone=xv.firstunit;
   xdata.celltwo=xv.secondunit;

   %-Initialise File indexes
   firstnumber=0; lastnumber=1;
	switch xdata.numvars
	case 0   %this means we have no variables
	   %--This section extracts variable info and sets up the data structure
	   firstnumber=min(xdata.meta.matrix(:,1));   %tells us the first and last file to load
	   lastnumber=max(xdata.meta.matrix(:,1));
	   %--Set Up the Struct Matrix to hold all the cross correlograms and header data
	   clear slope;
		xdata.filename=xdata.meta.filename;
		xdata.xtitle='';
		xdata.xvalues=[];
		xdata.xrange=1;
		xdata.ytitle='';
		xdata.yvalues=[];
		xdata.yrange=1;
		xdata.ztitle='';
		xdata.zvalues=[];
		xdata.zrange=1;
		xdata.matrix=[];
		xdata.xcorindex=0;
		xdata.xcor.values=0;
		xdata.xcor.time=0;

	case 1
		firstnumber=min(xdata.meta.matrix(:,1));   %tells us the first and last file to load
		lastnumber=max(xdata.meta.matrix(:,1));
		% This section extracts variable info and sets up the data structure
		xdata.filename=xdata.meta.filename;
		xdata.xtitle=regexprep(xdata.meta.var{1}.title,'w\\o','with O');
		xdata.xrange=xdata.meta.var{1}.range;
		xdata.xvalues=xdata.meta.var{1}.values;

		xdata.ytitle='';
		xdata.yvalues=[];
		xdata.yrange=1;

		xdata.ztitle='';
		xdata.zvalues=[];
		xdata.zrange=1;

		xdata.matrix=[xdata.xrange];
		xdata.xcorindex=0;
		xdata.xcor.values=0;
		xdata.xcor.time=0;


	case 2 %2 variables
		set(gh('SmoothingMenu'),'String',{'none';'cubic';'v4';'linear';'nearest'});
		firstnumber=min(xdata.meta.matrix(:,1));   %tells us the first and last file to load
		lastnumber=max(xdata.meta.matrix(:,1));

		%--Set Up the Struct Matrix to hold all the cross correlograms and header data
		xdata.filename=xdata.meta.filename;
		xdata.xtitle=regexprep(xdata.meta.var{1}.title,'w\\ o','with O');
		xdata.xrange=xdata.meta.var{1}.range;
		xdata.xvalues=xdata.meta.var{1}.values;

		xdata.ytitle=xdata.meta.var{2}.title;
		xdata.yrange=xdata.meta.var{2}.range;
		xdata.yvalues=xdata.meta.var{2}.values;

		xdata.ztitle='';
		xdata.zvalues=[];
		xdata.zrange=1;

		xdata.matrix=zeros(xdata.yrange,xdata.xrange);
		xdata.xcorindex=0;
		xdata.xcor.values=0;
		xdata.xcor.time=0;

	case 3
	  set(gh('SmoothingMenu'),'String',{'none';'cubic';'v4';'linear';'nearest'});

	  % this section juggles all the variables around for selection
	  x=header(3,find(header(3,:) == ':')+1:end);
	  xv.heldvar(1).name=x(find(x(1,:)~=' ')); %this strips spaces
	  x=str2num(header(4,find(header(4,:) == ':')+1:end));
	  xv.heldvar(1).range=x;
	  x=str2num(header(5,find(header(5,:) == ':')+1:end));
	  xv.heldvar(1).values=x;
	  x=header(6,find(header(6,:) == ':')+1:end);
	  xv.heldvar(2).name=x(find(x(1,:)~=' '));
	  x=str2num(header(7,find(header(7,:) == ':')+1:end));
	  xv.heldvar(2).range=x;
	  x=str2num(header(8,find(header(8,:) == ':')+1:end));
	  xv.heldvar(2).values=x;
	  x=header(9,find(header(9,:) == ':')+1:end);
	  xv.heldvar(3).name=x(find(x(1,:)~=' '));
	  x=str2num(header(10,find(header(10,:) == ':')+1:end));
	  xv.heldvar(3).range=x;
	  x=str2num(header(11,find(header(11,:) == ':')+1:end));
	  xv.heldvar(3).values=x;
	  xv.vars={xv.heldvar(1).name;xv.heldvar(2).name;xv.heldvar(3).name};

	  xv.inuse=1;
	  crossvar %our little variable selector GUI
	  pause(0.1)
	  xv.inuse=0;

	  xyh = [2 3 1;1 3 2;1 2 3]; 	%lookup table of variable combinations
	  h=xv.HeldVariable;					%index of variable held
	  % now we pick out which our X and Y variables actually are from text
	  a=find(header(1,:)=='/');
	  x=header(1,a(end-2):end);
	  xdata.filename=x(find(x(1,:)~=' ')); %this strips spaces
	  xdata.filename=[xdata.filename ':' num2str(xv.BinWidth) 'ms BW ' ' {' num2str(xdata.cellone) '/' num2str(xdata.celltwo) '}' '  Method=' num2str(george) ];
	  xdata.xtitle=xv.heldvar(xyh(h,1)).name;
	  xdata.xtitle=xdata.xtitle(find(xdata.xtitle(1,:)~=' '));
	  xdata.xrange=xv.heldvar(xyh(h,1)).range;
	  xdata.xvalues=xv.heldvar(xyh(h,1)).values;
	  xdata.ytitle=xv.heldvar(xyh(h,2)).name;
	  xdata.ytitle=xdata.ytitle(find(xdata.ytitle(1,:)~=' '));
	  xdata.yrange=xv.heldvar(xyh(h,2)).range;
	  xdata.yvalues=xv.heldvar(xyh(h,2)).values;
	  xdata.heldvar=xv.heldvar(xyh(h,3)).name;
	  xdata.heldvar=xdata.heldvar(find(xdata.heldvar(1,:)~=' '));
	  xdata.heldvalue=xv.heldvar(xyh(h,3)).values;
	  xdata.heldvalue=xdata.heldvalue(xv.HeldValue);
	  xdata.matrix=zeros(xdata.yrange,xdata.xrange);
	  xdata.xcorindex=0;
	  xdata.xcor.values=0;
	  xdata.xcor.time=0;
	  %--For filename indexing
	  firstnumber=1;
	  lastnumber=xdata.xrange*xdata.yrange;
	end

  %-Bar to show progress
  h = waitbar(0,'Loading Raw Data and Computing Cross-Correlograms...');

  %-Loads spike data for all variable values
  for i=firstnumber:lastnumber
      %--Filename to be loaded
      filename = [basefilename '.' int2str(i)];
      xdata.xcor(i).name=filename;
      %--Load spike data for the 2 cells
      switch xdata.filetype
      case 'doc'
          c1=lsd(filename,xdata.cellone,xv.StartTrial,xv.EndTrial);
          c2=lsd(filename,xdata.celltwo,xv.StartTrial,xv.EndTrial);
      otherwise
          c1=lsd2(filename,xdata.cellone,xv.StartTrial,xv.EndTrial,xdata.trialtime,xdata.modtime);
          c2=lsd2(filename,xdata.celltwo,xv.StartTrial,xv.EndTrial,xdata.trialtime,xdata.modtime);
      end
      xdata.raw{i}.cellone=c1;
      xdata.raw{i}.celltwo=c2;

      if ((xv.EndTrial==inf) && (i==1)) %i==1 so we only do this once!
          xv.EndTrial=xdata.raw{i}.cellone.numtrials;
          set(gh('EndTrial'),'String',num2str(xdata.raw{i}.cellone.numtrials));
          set(gh('ShuffleNumber'),'String',nums2strs(1:(xdata.raw{i}.cellone.numtrials-1)));
          set(gh('ShuffleNumber'),'value',xdata.raw{i}.cellone.numtrials-1);
      end

      if (get(gh('Shuffle'),'value')>1)
          xv.shuffles=get(gh('ShuffleNumber'),'value');
      else
          xv.shuffles=0;
      end

      %--Get Crosscorrelation values and store them
      [x,timebase,ci]=icorrx(xdata.raw{i},xv.BinWidth,xv.Window,xv.FromTime,xv.ToTime,xv.shuffles,get(gh('Shuffle'),'value'),xv.pValue);
      xdata.xcor(i).values=round(x);
      xdata.xcor(i).time=timebase;
      if ~isempty(ci)
          xdata.xcor(i).lcl=ci(1,:); %lower limits
          xdata.xcor(i).ucl=ci(2,:); %upper limits
      end
      %--Update waitbar
      waitbar(i/((lastnumber+1)-firstnumber),h);
  end
  close(h)

	xdata.xcorindex=round(size(xdata.xcor(1).time,2)/2);  %finds index into the 0 position
	if strcmp(xdata.filetype,'txt') || strcmp(xdata.filetype,'smr')
		datainfobox;
		set(gh('TextDisplay'),'String',xdata.info);
		axes(gh('XCorAxis'));
	end
  
	switch xdata.numvars
		case 0
			bar(xdata.xcor(i).time,xdata.xcor(i).values,1,'k');
			title([xdata.runname ' - ' num2str(xdata.cellone) '&' num2str(xdata.celltwo) ' [' num2str(xv.BinWidth) 'ms BW|Trials:' num2str(xv.StartTrial) '-' num2str(xv.EndTrial) ']' ]);
		case 1
		  xdata.ytitle='XCor Time (ms)';
		  if xdata.xcor(1).time(end)*2<=500
			  xdata.yvalues=xdata.xcor(1).time;
			  xdata.yrange=size(xdata.xcor(1).values,2);
			  xdata.matrix=zeros(xdata.yrange,xdata.xrange);
			  for i=1:xdata.xrange
				  xdata.matrix(:,i)=xdata.xcor(i).values;
			  end
		  else
			  index=round(500/xv.BinWidth);
			  indexnum=index*2+1;
			  xdata.yvalues=xdata.xcor(i).time(xdata.xcorindex-index:xdata.xcorindex+index);
			  xdata.yrange=length(xdata.yvalues);
			  xdata.matrix=zeros(indexnum,xdata.xrange);
			  for i=1:xdata.xrange
				  xdata.matrix(:,i)=xdata.xcor(i).values(xdata.xcorindex-index:xdata.xcorindex+index)';
			  end
		  end
		  xdata.xcorindex=round(size(xdata.xcor(1).time,2)/2);  %finds index into the 0 position
		  set(gh('CCStartBin'),'String',cellstr(num2str(xdata.xcor(1).time')));
		  set(gh('CCEndBin'),'String',cellstr(num2str(xdata.xcor(1).time')));
		  % Set Up default Binning Parameters, assuming nearest to +-10msec
		  set(gh('CCStartBin'),'Value',xdata.xcorindex);
		  set(gh('CCEndBin'),'Value',xdata.xcorindex);
		  
		  set(gh('CCHold1'),'String',cellstr(num2str(xdata.xvalues')));
		  set(gh('CCHold1'),'Value',1);
		  set(gh('CCHold2'),'String',cellstr(num2str(xdata.xvalues')));
		  set(gh('CCHold2'),'Value',length(xdata.xvalues));
		  
		  xcormatrix;
		  fixfig;
		case 2
			%errordlg('Cross Cor had a problem loading 2 variables');
			%error('Cross Cor had a problem loading 2 variables');
		  xdata.xcorindex=round(xdata.yrange/2);

		  % Set Up default Binning Parameters, assuming nearest to +-10msec
		  default=round(10/xv.BinWidth);

		  set(gh('CCStartBin'),'Value',xdata.xcorindex);
		  set(gh('CCEndBin'),'Value',xdata.xcorindex);

		  xdata.xcorindex=round(size(xdata.xcor(1).time,2)/2);  %finds index into the 0 position

		  set(gh('CCStartBin'),'String',cellstr(num2str(xdata.xcor(1).time')));
		  set(gh('CCEndBin'),'String',cellstr(num2str(xdata.xcor(1).time')));

		  default=round(10/xv.BinWidth);
		  % Set Up default Binning Parameters, assuming nearest to +-10msec
		  set(gh('CCStartBin'),'Value',xdata.xcorindex);
		  set(gh('CCEndBin'),'Value',xdata.xcorindex);

		  xv.StartBin=xdata.xcorindex;%-default;
		  xv.EndBin=xdata.xcorindex;%+default;

		  for i=1:xdata.xrange*xdata.yrange   %actually extract out our values into the matrix
			  xsum=sum(xdata.xcor(i).values(1,xv.StartBin:xv.EndBin));
			  xdata.matrix(i)=xsum;
		  end		  
		  xcormatrix;
		otherwise
			errordlg('Sorry, Cross Cor does not deal yet with 3 variables');
			error('Sorry, Cross Cor does not deal yet with 3 variables');			
	end

    %-------------------------------------------------------------------
case 'ReRun'
    %-------------------------------------------------------------------
    rerun='yes';
    crosscor('Load');

    %-------------------------------------------------------------------
case 'Load Matrix'
    %-------------------------------------------------------------------
    %clear xdata slope xv
	origpath=pwd;
	cd('c:\');
    [file path]=uigetfile('*.mat','Load Processed Matrix');
    if isempty(file), return, end;
    filepath=[path '\' file];
	cd(path);
    load(filepath);
    save 'c:\xdata' xdata
	binvals=cellstr(num2str(xdata.yvalues'));
	set(gh('CCStartBin'),'Value',1);
	set(gh('CCEndBin'),'Value',1);
    set(gh('CCStartBin'),'String',binvals);
    set(gh('CCEndBin'),'String',binvals);
	set(gh('CCBinWidth'),'String',num2str(xv.BinWidth));
	set(gh('CCWindow'),'String',num2str(xv.Window));
	set(gh('CCFromTime'),'String',num2str(xv.FromTime));
	set(gh('CCToTime'),'String',num2str(xv.ToTime));
	set(gh('CCStartTrial'),'String',num2str(xv.StartTrial));
	set(gh('CCEndTrial'),'String',num2str(xv.EndTrial));
	set(gh('CCFirstCell'),'Value',xv.firstunit);
	set(gh('CCSecondCell'),'Value',xv.secondunit);
    % Set Up default Binning Parameters, assuming nearest to +-10msec
    default=round(10/xv.BinWidth);

    set(gh('CCStartBin'),'Value',round(length(binvals)/2));
    set(gh('CCEndBin'),'Value',round(length(binvals)/2));

    %xv.StartBin=xdata.xcorindex;%-default;
    %xv.EndBin=xdata.xcorindex;%+default;

%     if xdata.ytitle=='XCor Time (ms)'
%       xdata.numvars=1;
%    end

   xcormatrix;

    %-------------------------------------------------------------------
case 'PlotMatrix'
    %-------------------------------------------------------------------
   xcormatrix;

    %-------------------------------------------------------------------
case 'Save Model'
    %-------------------------------------------------------------------
   if exist('c:\temp.mat','file'); delete('c:\temp.mat'); end
   crossmodelsave
   b=xdata.xvalues';
   a=cell(size(b));
   for i=1:max(size(a))
      a{i}=b(i)
   end
   set(gh('Angle'),'String',a);
   loop=0;
   while loop<1
      pause(1)
   end
   loop=0;

   model.sep=str2num(get(gh('Sep'),'String'));
   model.size1=str2num(get(gh('Size1'),'String'));
   model.size2=str2num(get(gh('Size2'),'String'));
   String=get(gh('Type1'),'String');
   Value=get(gh('Type1'),'Value');
   model.type1=String{Value};
   String=get(gh('Type2'),'String');
   Value=get(gh('Type2'),'Value');
   model.type2=String{Value};
   model.optimum=get(gh('Angle'),'Value');
   model.binwidth=xdata.xcor(1).time(2)-xdata.xcor(1).time(1);
   model.window=abs(xdata.xcor(1).time(1))+abs(xdata.xcor(1).time(end));
   close;

   maxvalue=0;
   for i=1:xdata.xrange
      if max(xdata.xcor(i).values)>maxvalue
         maxvalue=max(xdata.xcor(i).values);
      end
   end
   if maxvalue==0
      maxvalue=maxvalue+1;
   end

   model.maxvalue=maxvalue; %this is the maximum number of correlated events
   data=xdata;
   data.model=model;
   [file path]=uiputfile('*.mat','Save Model Matrix')
   if isempty(file), return, end;
   cd(path)
   x='data';
   save(file,x);



    %-------------------------------------------------------------------
case 'Save Matrix'
    %-------------------------------------------------------------------
   if ~isempty(xdata);
	  origpath=pwd;
	  cd('c:\');
      [file path]=uiputfile('*.mat','Save Processed Matrix');
      if isempty(file), return, end;
      filepath=[path '\' file];
      save(filepath,'xdata','xv');
	  cd(origpath);
   else
      errordlg('No Data has been Processed...');
   end

    %-------------------------------------------------------------------
case 'Save Text'
    %-------------------------------------------------------------------
   if ~isempty(xdata);
      [file path]=uiputfile('*.wk1','Save Processed Matrix as WK1 file');
      if isempty(file), return, end;
      cd(path);
      xmat=rot90(xdata.matrix);
      xmat=flipud(xmat);
      wk1write(file,xmat);
      %dlmwrite('text.txt',xdata.matrix,'\t')
   else
      errordlg('No Data has been Processed...');
   end

    %-------------------------------------------------------------------
case 'Preview'
    %-------------------------------------------------------------------
   SpawnPlot(gca);
   set(gca,'FontSize',6);

    %-------------------------------------------------------------------
case 'Axis'
    %-------------------------------------------------------------------
   val=get(gh('Axeschk'), 'Value');
   if val == 1
      axis auto
      set(findobj('UserData','AxesValues'),'Enable', 'off')
   else
      xmin=str2num(get(gh('CCXmintext'),'String'));
      xmax=str2num(get(gh('CCXmaxtext'),'String'));
      ymin=str2num(get(gh('CCYmintext'),'String'));
      ymax=str2num(get(gh('CCYmaxtext'),'String'));
      axis([xmin xmax ymin ymax]);
      set(findobj('UserData','AxesValues'),'Enable', 'on');
   end

    %-------------------------------------------------------------------
case 'See Rasters'  %look at Raster plots for both cells
    %-------------------------------------------------------------------
	xv.inuse=1;
	if xdata.numvars<2
		figure;
		set(gcf,'Tag','ccrasterplotfig');
		figpos(1,[900 700]);
		set(gcf,'Color',[1 1 1]);
		maxvalue=0;
		firstnumber=get(gh('CCHold1'),'Value');
		lastnumber=get(gh('CCHold2'),'Value');
		range=lastnumber-firstnumber+1;
		if xdata.numvars==0
		  range=1;
		  firstnumber=1;
		  lastnumber=1;
	  end
		if range<=4
			y=1;
			x=range;
		elseif range <=15
			y=3;
			x=ceil(range/3);
		elseif range <=20
			y=4;
			x=ceil(range/4);
		else
			y=6;
			x=ceil(range/6);
		end
		a=1;
		for i=firstnumber:lastnumber
			subaxis(y,x,a,'S',0.05,'P',0,'M',0.1);
			plotraster(xdata.raw{i}.cellone, xdata.raw{i}.celltwo);
			a=a+1;
			box on
			set(gca,'Layer','top');
			set(gca,'TickDir','out');  %get ticks going out
			xlabel([num2str(xdata.xvalues(i)) ' | Time (s)'],'FontSize',7)
		end
		suplabel([xdata.runname ' | Cells ' num2str(xdata.cellone) ' & ' num2str(xdata.celltwo)], 't');
	end

    %-------------------------------------------------------------------
case 'See PSTH'  %look at PSTH plots for both cells
    %-------------------------------------------------------------------
   xv.inuse=1;
   if xdata.numvars<2
      figure;
	  set(gcf,'Tag','ccpsthplotfig');
	  figpos(1,[900 700]);
	  set(gcf,'Color',[1 1 1]);
      maxvalue=0;
	  firstnumber=get(gh('CCHold1'),'Value');
	  lastnumber=get(gh('CCHold2'),'Value');
	  wrap=get(gh('CCWrapPSTH'),'Value');
	  range=lastnumber-firstnumber+1;
	  if xdata.numvars==0
		  range=1;
		  firstnumber=1;
		  lastnumber=1;
	  end
	  if range<=4
			y=1;
			x=range;
		elseif range <=15
			y=3;
			x=ceil(range/3);
		elseif range <=20
			y=4;
			x=ceil(range/4);
		else
			y=5;
			x=ceil(range/5);
		end
	  binwidth=10; %ms
	  a=1;
      for i=firstnumber:lastnumber
		 if wrap==0
			[var(a).t1,var(a).a1]=binit(xdata.raw{i}.cellone,binwidth*10,0,inf,xv.StartTrial,xv.EndTrial,0,'cor');
			[var(a).t2,var(a).a2]=binit(xdata.raw{i}.celltwo,binwidth*10,0,inf,xv.StartTrial,xv.EndTrial,0,'cor');
			var(a).a1= (var(a).a1/(binwidth*xdata.raw{i}.cellone.numtrials))*1000;
			var(a).a2= (var(a).a2/(binwidth*xdata.raw{i}.cellone.numtrials))*1000;
		else
			[var(a).t1,var(a).a1]=binit(xdata.raw{i}.cellone,binwidth*10,0,inf,xv.StartTrial,xv.EndTrial,1,'cor');
			[var(a).t2,var(a).a2]=binit(xdata.raw{i}.celltwo,binwidth*10,0,inf,xv.StartTrial,xv.EndTrial,1,'cor');
			var(a).a1= (var(a).a1/(binwidth*xdata.raw{i}.cellone.numtrials*xdata.raw{i}.cellone.nummods))*1000;
			var(a).a2= (var(a).a2/(binwidth*xdata.raw{i}.cellone.numtrials*xdata.raw{i}.cellone.nummods))*1000;
		 end
         if max([var(a).a1 var(a).a2])>maxvalue
            maxvalue=max([var(a).a1 var(a).a2]);
         end
		 a=a+1;
	  end
	  a=1;
      for i=firstnumber:lastnumber
         subaxis(y,x,a,'M',0.1,'S',0.05);
         h=plot(var(a).t1,var(a).a1,'k',var(a).t2,var(a).a2,'r');
		 set(h,'LineWidth',1.5);
         xlabel(num2str(xdata.xvalues(i)),'FontSize',7)
         axis tight;
         set(gca,'FontSize',4);
         axis([-inf inf 0 maxvalue+(maxvalue/10)]);
		 a=a+1;
		 set(gca,'Layer','top');
		 set(gca,'TickDir','out');  %get ticks going out
      end

   else
      figure
      maxvalue=0;
      for i=1:xdata.xrange*xdata.yrange
         subplot(xdata.yrange,xdata.xrange,i);
         [t1,a1]=binit(xdata.raw{i}.cellone,250,0,inf,xv.StartTrial,xv.EndTrial,0);
         [t2,a2]=binit(xdata.raw{i}.celltwo,250,0,inf,xv.StartTrial,xv.EndTrial,0);
         if max([a1*100 a2*100])>maxvalue
            maxvalue=max([a1*100 a2*100]);
         end
         plot(t1,a1*100,'b',t2,a2*100,'r');
         %axis tight
         set(gca,'FontSize',4);
         %ylabel(xdata.xcor(i).name,'FontSize',5)
      end
      for i=1:xdata.xrange*xdata.yrange
         subplot(xdata.yrange,xdata.xrange,i);
         axis tight;
         yaxis(0,maxvalue);
		set(gca,'Layer','top');
		set(gca,'TickDir','out');  %get ticks going out
      end
      set(gcf,'Color',[1 1 1]);
   end
   xv.inuse=0;

  suplabel([xdata.runname ' Cells:' num2str(xdata.cellone) '&' num2str(xdata.celltwo)] ,'t');

    %-------------------------------------------------------------------
case 'See XCor' %see Xcorrelograms
    %-------------------------------------------------------------------
	if xdata.numvars>=1
		maxvalue=0;
		x=ceil(xdata.xrange/3);
		for i=1:xdata.xrange
		 if max(xdata.xcor(i).values)>maxvalue
			maxvalue=max(xdata.xcor(i).values);
		 end
		end

		if maxvalue==0
		 maxvalue=maxvalue+1;
		end

		figure;
		set(gcf,'Tag','cccorrplotfig');
		figpos(1,[900 700]);
		set(gcf,'Color',[1 1 1]);

		firstnumber=get(gh('CCHold1'),'Value');
		lastnumber=get(gh('CCHold2'),'Value');
		range=lastnumber-firstnumber+1;
		if xdata.numvars==0
		  range=1;
		  firstnumber=1;
		  lastnumber=1;
	  end
		if range<=4
			y=1;
			x=range;
		elseif range <=15
			y=3;
			x=ceil(range/3);
		elseif range <=20
			y=4;
			x=ceil(range/4);
		else
			y=5;
			x=ceil(range/5);
		end
		a=1;
		for i=firstnumber:lastnumber
			 subaxis(y,x,a,'M',0.05,'S',0.05);
			 set(gca,'nextplot','add')
			 bar(xdata.xcor(i).time,xdata.xcor(i).values,1,'k')
			 if isfield(xdata.xcor(1),'lcl')
				plot(xdata.xcor(i).time,xdata.xcor(i).lcl,'r-');
				plot(xdata.xcor(i).time,xdata.xcor(i).ucl,'r-');
			 end
			 axis tight
			 set(gca,'FontSize',4)
			 xlabel(num2str(xdata.xvalues(i)),'FontSize',6)
			 axis([-inf inf 0 maxvalue]);
			 set(gca,'Layer','top');
			 set(gca,'TickDir','out');  %get ticks going out
			 a=a+1;
		end
	else
	maxvalue=0;
	for i=1:xdata.xrange*xdata.yrange
	 if max(xdata.xcor(i).values)>maxvalue
		maxvalue=max(xdata.xcor(i).values);
	 end
	end

      if maxvalue==0
         maxvalue=maxvalue+1;
      end

      figure
	   set(gcf,'Color',[1 1 1]);
      for i=1:xdata.xrange*xdata.yrange
         subplot(xdata.xrange,xdata.yrange,i)
         bar(xdata.xcor(i).time,xdata.xcor(i).values,1,'k')
         axis tight
         set(gca,'FontSize',4);
			set(gca,'Layer','top');
			set(gca,'TickDir','out');  %get ticks going out
         %ylabel(xdata.xcor(i).name,'FontSize',5)
         axis([-inf inf 0 maxvalue]);
      end

   end

    %-------------------------------------------------------------------
case 'See Tuning'
    %-------------------------------------------------------------------
   if xdata.numvars==1

      datatype='Tune';
      cla;
			  
	  x=xdata.xvalues;
      corrline=[];

      s=get(gh('CCStartBin'),'Value');
      f=get(gh('CCEndBin'),'Value');

      stext=get(gh('CCStartBin'),'String');
      ftext=get(gh('CCEndBin'),'String');
      stext=stext{s};
      ftext=ftext{f};

      for i=1:xdata.xrange
         xsum=sum(xdata.matrix(s:f,i));
         corrline(i)=xsum;
         e=xdata.matrix(s:f,i);
         err(i)=std(e);
	  end
	  
	  [e,a]=max(corrline);
	  angle=x(a);
	  set(gh('CCGauss1'),'String',num2str(max(corrline)));
	  set(gh('CCGauss2'),'String',num2str(5));
	  set(gh('CCGauss3'),'String',num2str(min(corrline)));
	  set(gh('CCGauss4'),'String',num2str(angle));

      if max(err)==0
         if size(corrline,1)>size(corrline,2)
            corrline=corrline';
         end
         %corrline=(corrline/max(corrline))*100;
         xdata.corrline=corrline;
         plot(x,corrline,'k.-','MarkerSize',15);
         t=[xdata.filename '  (Zero Bin)'];
         title(t)
         %pause(0.7);
         %[file,path]=uiputfile('*.txt','Save Tuning Curve as:');
         %if ~file
         %   h=helpdlg('No File Specified');
         %   pause(0.6);
         %   close(h);
         %else
         %   cd(path);
         %   x=xdata.xvalues;
         %   save(file, 'x','corrline', '-ascii', '-tabs');
         %end

      else
         err=err';
         err=sqrt((err.^2/(f-s)));
         xval=xdata.xvalues';
         corrline=corrline';
         %err=(err/max(corrline))*100;
         %corrline=(corrline/max(corrline))*100;
         areabar(xval,corrline,err,[.7 .7 .7],'k.-','MarkerSize',15);
         xdata.corrline=corrline;
         xdata.errorline=err;
         t=[xdata.filename '(Bins: ' stext '   :' ftext ')'];
         title(t,'FontSize',8)
         %pause(0.7);
         %[file,path]=uiputfile('*.txt','Save Tuning Curve as:');
         %if ~file
         %   h=helpdlg('No File Specified');
         %   pause(0.7);
         %   close(h);
         %else
         %   cd(path);
         %   x=xdata.xvalues;
         %   corrline=corrline';
         %   error=error';
         %   save(file, 'x','corrline', 'error', '-ascii', '-tabs');
         %end
	  end
	  axis tight;
	 xlabel('Orientation (deg)');
	 ylabel('Correlated Events');
	 val=get(gh('Axeschk'), 'Value');
	 if val == 1
		axis([-inf inf -inf inf]);
	 else
		xmin=str2num(get(gh('CCXmintext'),'String'));
		xmax=str2num(get(gh('CCXmaxtext'),'String'));
		ymin=str2num(get(gh('CCYmintext'),'String'));
		ymax=str2num(get(gh('CCYmaxtext'),'String'));
		axis([xmin xmax ymin ymax]);
	 end
   else
      errordlg('Sorry, this function is for 1 variable data only')
   end

    %-------------------------------------------------------------------
case 'Fit Gaussian'
    %-------------------------------------------------------------------
   if datatype=='Tune';

		cline=xdata.corrline;
		x=xdata.xvalues;

		s=get(gh('CCStartBin'),'Value');
		f=get(gh('CCEndBin'),'Value');

		stext=get(gh('CCStartBin'),'String');
		ftext=get(gh('CCEndBin'),'String');
		stext=stext{s};
		ftext=ftext{f};

		val=get(gh('Axeschk'), 'Value');
		if val == 1
			axis([-inf inf -inf inf]);
		else
			xmin=str2num(get(gh('CCXmintext'),'String'));
			xmax=str2num(get(gh('CCXmaxtext'),'String'));
			ymin=str2num(get(gh('CCYmintext'),'String'));
			ymax=str2num(get(gh('CCYmaxtext'),'String'));
			axis([xmin xmax ymin ymax]);
		end

		axval=axis;
		a=find(x>=axval(1) & x<=axval(2));
		x=x(a);
		y=cline(a);

		%this allows one to select interpolated or raw data to fit
		%comment it out to use raw data...
		xx=linspace(min(x),max(x),length(x)*20);
		yy=interp1(x,y,xx,'linear');
		x=xx;
		y=yy;
		%---------------------------------------------------------

		lb=[10 1 0 -360];
		ub=[1000 50 200 360];
		g(1)=str2num(get(gh('CCGauss1'),'String'));
		g(2)=str2num(get(gh('CCGauss2'),'String'));
		if get(gh('CCGauss3Lock'),'Value')==1
			g(3)=0;
		else
			g(3)=str2num(get(gh('CCGauss3'),'String'));
		end		
		g(4)=str2num(get(gh('CCGauss4'),'String'));
		
		options = optimset('Display','iter');

		[g,f,exit,output]=fmincon(@fitgaussian,g,[],[],[],[],lb,ub,[],options,x,y);

		gline=fitgaussian2(g,x);
		
		if max(gline)-min(gline)<2.5
			errordlg('Gaussian didn''t fit data, please try other parameters');
			error('Gaussian didn''t fit data, please try other parameters');
		elseif exit<=0
			errordlg('Gaussian didn''t converge, please try other parameters');
			error('Gaussian didn''t converge, please try other parameters');
		end

		hold on
		plot(x,gline,'r');
		axval=axis;
		
		if axval==inf | axval==-inf
			axval(1)=min(x);
			axval(2)=max(x);
			axval(3)=min(y);
			axval(4)=max(y);
		end			

		[n,j]=max(gline);
		[nn,jj]=min(gline);
		half=((n-nn)/2)+nn;
		line([axval(1) axval(2)],[half half],'Color', [1 0 0],'LineStyle',':');
		line([x(j) x(j)],[axval(3) axval(4)],'Color', [1 0 0],'LineStyle',':');

		[o,p]=ginput(2)
		[m,i]=max(gline);
		n=x(j);
		ap=n-o(1);
		bp=o(2)-n;
		hwp=(ap+bp)/2;
		[o,p]=ginput(1);
		t=['Gaussian HwHH = ' num2str(hwp) '|' num2str(g)];
		text(o,p,t);

		hold off
   end

    %-------------------------------------------------------------------
case 'Half Width'
    %-------------------------------------------------------------------
   if datatype=='Tune';

      cline=[];

      s=get(gh('CCStartBin'),'Value');
      f=get(gh('CCEndBin'),'Value');

      stext=get(gh('CCStartBin'),'String');
      ftext=get(gh('CCEndBin'),'String');
      stext=stext{s};
      ftext=ftext{f};

      for i=1:xdata.xrange
         xsum=sum(xdata.matrix(s:f,i));
         cline(i)=xsum;
      end

      if size(cline,1)>size(cline,2)
         cline=cline';
      end
      %cline=(cline/max(cline))*100;
      string=get(gh('CCPolyBox'),'String');
      value=get(gh('CCPolyBox'),'Value');
      pnum=str2num(string{value});
      string=get(gh('CCIntBox'),'String');
      value=get(gh('CCIntBox'),'Value');
      inttype=str2num(string{value});
      xval=xdata.xvalues;
      axval=axis;
      a=find(xval>=axval(1) &xval<=axval(2));
      x=xval(a);
      y=cline(a);
      p=polyfit(x,y,pnum);
      pp=polyval(p,x);
%       xx=linspace(min(x),max(x),(size(x,2)*20));
%       yy=loess(x,y,xx,0.5,2);
      hold on
%       plot(xx,yy,'g');
	  plot(x,pp,'r');
      hold off
      axis(axval);
%       [m,i]=max(yy);
      [n,j]=max(pp);
	  line([axval(1) axval(2)],[n/2 n/2],'Color', [1 0 0],'LineStyle',':');
%       line([axval(1) axval(2)],[m/2 m/2],'Color', [0 1 0],'LineStyle',':');
%       line([xx(i) xx(i)],[axval(3) axval(4)],'Color', [0 1 0],'LineStyle',':');
      line([x(j) x(j)],[axval(3) axval(4)],'Color', [1 0 0],'LineStyle',':');
      %line([axval(1) axval(2)],[max(pp)/2 max(pp)/2],'Color', [0 1 0]);
      %ahalf=yy(1:i);
      %ax=xx(1:i);
      %bhalf=yy(i:end);
      %bx=xx(i:end);
      %a=find(ahalf>((m/2)-m/30) & ahalf<((m/2)+m/30));
      %ahalfvalue=ax(a(end));
      %b=find(bhalf>((m/2)-m/30) & bhalf<((m/2)+m/30));
      %bhalfvalue=bx(b(1));
      %ah=xx(i)-ahalfvalue;
      %bh=bhalfvalue-xx(i);
      %hw=(ah+bh)/2;
      %[o,p]=ginput(1);
      %t=['Cubic HW=' num2str(hw) 'deg']
      %text(o,p,t)
      [o,p]=ginput(2);
      [m,i]=max(pp);
      %m=xx(i);
      n=x(j);
      %ah=m-o(1);
      ap=n-o(1);
      %bh=o(2)-m;
      bp=o(2)-n;
      %hw=(ah+bh)/2;
      hwp=(ap+bp)/2;
      [o,p]=ginput(1);
      t=['Poly HwHH = ' num2str(hwp)];
      text(o,p,t);
   else
      errordlg('Sorry, this function is for tuning curves for 1 variable data only')
   end

    %-------------------------------------------------------------------
case 'Get Slope'
    %-------------------------------------------------------------------
   if xdata.numvars>=1
      [x,y]=ginput(3);
      xrange=(x(1)-x(2));
      yrange=(y(1)-y(2));
      slope=abs(yrange/xrange);
	  line([x(1);x(2)],[y(1);y(2)]);
      text(x(3),y(3),[num2str(slope) ' ms/deg'],'FontSize',11,'Color',[1 1 1]);
   else
      errordlg('Sorry, this function is for 1 variable data only')
   end

    %-------------------------------------------------------------------
case 'See Values'
    %-------------------------------------------------------------------
   if xdata.numvars==1
      errordlg('Sorry, this function is meant for 2 or more variable data')
   else
      x=xdata.matrix;
      x=rot90(x);
      x=flipud(x);
      y=num2str(x);
      x=questdlg(y);
   end




end  %end of main switch



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function xcormatrix

% Used to generate the matrix from binned cross-correlograms

global CMap;
global xdata;
global StartBin;
global EndBin;
global xv;
global ShadingType;
global PlotType;
global Lighting;
global SmoothValue;
global SmoothType;
global LightAdd;
global datatype;

%axes(gh('XCorAxis'));

grid off;
LightAdd='';

[a,b]=view;

val=get(gh('Axeschk'), 'Value');
if val == 1
   axval=[-inf inf -inf inf];
else
   xmin=str2num(get(gh('CCXmintext'),'String'));
   xmax=str2num(get(gh('CCXmaxtext'),'String'));
   ymin=str2num(get(gh('CCYmintext'),'String'));
   ymax=str2num(get(gh('CCYmaxtext'),'String'));
   axval=[xmin xmax ymin ymax];
end


if isempty(SmoothType);
   SmoothType='none'
end;
if isempty(SmoothValue);
   SmoothValue='5'
end;
if isempty(ShadingType);
   ShadingType='interp'
end;
if isempty(Lighting);
   Lighting='phong'
end;
if isempty(PlotType);
   PlotType='Surface'
end;


if xdata.numvars==1

switch(SmoothType)
case 'none'
   xx=xdata.xvalues;
   yy=xdata.yvalues;
   dd=xdata.matrix;
   %dd=dd/max(max(dd));
case 'cubic'
   xx=linspace(min(xdata.xvalues),max(xdata.xvalues),(size(xdata.xvalues,1)*SmoothValue));
   yy=linspace(min(xdata.yvalues),max(xdata.yvalues),(size(xdata.yvalues,2)*SmoothValue));
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(xdata.xvalues,xdata.yvalues);
   dd=interp2(x,y,xdata.matrix,xx,yy,'cubic');
case 'linear'
   xx=linspace(min(xdata.xvalues),max(xdata.xvalues),(size(xdata.xvalues,1)*SmoothValue));
   yy=linspace(min(xdata.yvalues),max(xdata.yvalues),(size(xdata.yvalues,2)*SmoothValue));
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(xdata.xvalues,xdata.yvalues);
   dd=interp2(x,y,xdata.matrix,xx,yy,'linear');
case 'nearest'
   xx=linspace(min(xdata.xvalues),max(xdata.xvalues),(size(xdata.xvalues,1)*SmoothValue));
   yy=linspace(min(xdata.yvalues),max(xdata.yvalues),(size(xdata.yvalues,2)*SmoothValue));
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(xdata.xvalues,xdata.yvalues);
   dd=interp2(x,y,xdata.matrix,xx,yy,'nearest');
case 'spline'
   xx=linspace(min(xdata.xvalues),max(xdata.xvalues),(size(xdata.xvalues,1)*SmoothValue));
   yy=linspace(min(xdata.yvalues),max(xdata.yvalues),(size(xdata.yvalues,2)*SmoothValue));
   [xx,yy]=meshgrid(xx,yy);
   [x,y]=meshgrid(xdata.xvalues,xdata.yvalues);
   dd=interp2(x,y,xdata.matrix,xx,yy,'spline');
end


   datatype='';
   switch(PlotType)    %For different plots
   case 'Raw Data'
      x=1:max(size(xdata.xvalues));
      imagesc(x,xdata.yvalues,xdata.matrix);
      set(gca,'XTick',x);
      set(gca,'XTickLabel',xdata.xvalues);
      set(gca,'FontSize',7)
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      set(gca,'YDir','normal');
      grid on

   case 'Mesh'
      mesh(xx,yy,dd)
      shading(ShadingType);
      grid off;
      axis vis3d;
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      if a==0
         if b==90
            view([-45 45])
         end
      else
         view(a,b);
      end
      axis(axval)

   case 'CheckerBoard'
      pcolor(xx,yy,dd);
      shading interp;
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      axis(axval)

   case 'CheckerBoard+Contour'
      pcolor(xx,yy,dd);
      shading interp;
      hold on;
      [c,h] = contour(xx,yy,dd,'k'); clabel(c,h);
      hold off;
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      axis(axval)

   case 'Surface'
      surf(xx,yy,dd,'FaceColor','interp','EdgeColor','none','FaceLighting',Lighting);
      material shiny;
      shading(ShadingType);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      grid off;
      axis vis3d;
      axis tight;
      camlight left;
      if a==0
         if b==90
            view([-45 45])
         end
      else
         view(a,b);
      end
      axis(axval)

   case 'Lighted Surface'
      surfl(xx,yy,dd);
      shading(ShadingType);
      material metal;
      colormap(bone);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      grid off;
      axis vis3d;
      axis tight;
      if a==0
         if b==90
            view([-45 45])
         end
      else
         view(a,b);
      end
      axis(axval)


   case 'Surface+Contour'
      surfc(xx,yy,dd);
      shading(ShadingType);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      grid off;
      axis vis3d;
      if a==0
         if b==90
            view([-45 45])
         end
      else
         view(a,b);
      end
      axis(axval)

   case 'Contour'
      [c,h] = contour(xx,yy,dd); clabel(c,h);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      axis(axval)

   case 'Filled Contour'
      [c,h] = contourf(xx,yy,dd,20); %clabel(c,h);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      axis(axval)

   case 'Waterfall'
      waterfall(xx,yy,dd);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      grid off;
      axis vis3d;
      if a==0
         if b==90
            view([-45 45])
         end
      else
         view(a,b);
      end
      axis(axval)


   end

   title(xdata.runname);



else  %for 2 variable plots

   xv.StartBin=num2str(get(gh('CCStartBin'),'Value'));
   xv.EndBin=num2str(get(gh('CCEndBin'),'Value'));

   x=get(gh('RatioValue'),'Value');
   switch x  %do we do a ratio?????

   case 1 %don't use ratio
      for i=1:xdata.xrange*xdata.yrange
         xsum=sum(xdata.xcor(i).values(1,xv.StartBin:xv.EndBin));
         xdata.matrix(i)=xsum;
      end
   case 2 %25ms ratio
      for i=1:xdata.xrange*xdata.yrange
         x=round(25/xv.BinWidth);
         xsum=sum(xdata.xcor(i).values(1,xv.StartBin:xv.EndBin));
         xsum2=sum(xdata.xcor(i).values(1,xv.StartBin-x:xv.EndBin-x));
         if any(xsum) % is the bin 0
            ratio=(xsum/xsum2);
            xdata.matrix(i)=ratio;
         else
            xdata.matrix(i)=xsum2;
         end
      end
   case 3 %50ms ratio
      for i=1:xdata.xrange*xdata.yrange
         x=round(50/xv.BinWidth);
         xsum=sum(xdata.xcor(i).values(1,xv.StartBin:xv.EndBin));
         xsum2=sum(xdata.xcor(i).values(1,xv.StartBin-x:xv.EndBin-x));
         if any(xsum) % is the bin 0
            ratio=(xsum/xsum2);
            xdata.matrix(i)=ratio;
         else
            xdata.matrix(i)=xsum2;
         end
      end
   case 4 %100ms ratio
      for i=1:xdata.xrange*xdata.yrange
         x=round(100/xv.BinWidth);
         xsum=sum(xdata.xcor(i).values(1,xv.StartBin:xv.EndBin));
         xsum2=sum(xdata.xcor(i).values(1,xv.StartBin-x:xv.EndBin-x));
         if any(xsum) % is the bin 0
            ratio=(xsum/xsum2);
            xdata.matrix(i)=ratio;
         else
            xdata.matrix(i)=xsum2;
         end
      end
   end

   xlinear=1:xdata.xrange;
   ylinear=1:xdata.yrange;

   switch(SmoothType)
   case 'none'
      xx=xlinear;
      yy=ylinear';
      dd=xdata.matrix;
   case 'cubic'
      xx=1:(size(xlinear,2)/SmoothValue)/size(xlinear,2):size(xlinear,2);
      yy=1:(size(ylinear,2)/SmoothValue)/size(ylinear,2):size(ylinear,2);
      yy=yy';
      dd=griddata(xlinear,ylinear',xdata.matrix,xx,yy,'cubic');
   case 'linear'
      xx=1:(size(xlinear,2)/SmoothValue)/size(xlinear,2):size(xlinear,2);
      yy=1:(size(ylinear,2)/SmoothValue)/size(ylinear,2):size(ylinear,2);
      yy=yy';
      dd=griddata(xlinear,ylinear',xdata.matrix,xx,yy,'linear');
   case 'nearest'
      xx=1:(size(xlinear,2)/SmoothValue)/size(xlinear,2):size(xlinear,2);
      yy=1:(size(ylinear,2)/SmoothValue)/size(ylinear,2):size(ylinear,2);
      yy=yy';
      dd=griddata(xlinear,ylinear',xdata.matrix,xx,yy,'nearest');
   case 'v4'
      xx=1:(size(xlinear,2)/SmoothValue)/size(xlinear,2):size(xlinear,2);
      yy=1:(size(ylinear,2)/SmoothValue)/size(ylinear,2):size(ylinear,2);
      yy=yy';
      dd=griddata(xlinear,ylinear',xdata.matrix,xx,yy,'v4');
   end


   switch(PlotType)    %For different plots
   case 'Raw Data'
      imagesc(xlinear,ylinear,xdata.matrix);
      set(gca,'XTick',xlinear);
      set(gca,'YTick',ylinear);
      set(gca,'XTickLabel',xdata.xvalues);
      set(gca,'YTickLabel',xdata.yvalues);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      set(gca,'YDir','normal');

   case 'Mesh'
      mesh(xx,yy,dd)
      set(gca,'XTick',xlinear)
      set(gca,'YTick',ylinear)
      set(gca,'XTickLabel',xdata.xvalues)
      set(gca,'YTickLabel',xdata.yvalues)
      shading(ShadingType);
      grid off;
      axis vis3d;
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      if a==0
         if b==90
            view([-45 45])
         end
      else
         view(a,b);
      end


   case 'CheckerBoard'
      pcolor(xx,yy,dd);
      set(gca,'XTick',xlinear);
      set(gca,'YTick',ylinear);
      set(gca,'XTickLabel',xdata.xvalues);
      set(gca,'YTickLabel',xdata.yvalues);
      shading interp;
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);

   case 'CheckerBoard+Contour'
      pcolor(xx,yy,dd);
      set(gca,'XTick',xlinear);
      set(gca,'YTick',ylinear);
      set(gca,'XTickLabel',xdata.xvalues);
      set(gca,'YTickLabel',xdata.yvalues);
      shading interp;
      hold on;
      [c,h] = contour(xx,yy,dd,'k'); clabel(c,h);
      hold off;
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);

   case 'Surface'
      surf(xx,yy,dd,'FaceColor','interp','EdgeColor','none','FaceLighting',Lighting);
      material shiny;
      shading(ShadingType);
      set(gca,'XTick',xlinear);
      set(gca,'YTick',ylinear);
      set(gca,'XTickLabel',xdata.xvalues);
      set(gca,'YTickLabel',xdata.yvalues);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      grid off;
      axis vis3d;
      axis tight;
      camlight left;
      if a==0
         if b==90
            view([-45 45])
         end
      else
         view(a,b);
      end

   case 'Lighted Surface'
      surfl(xx,yy,dd);
      shading(ShadingType);
      material metal;
      colormap(bone);
      set(gca,'XTick',xlinear);
      set(gca,'YTick',ylinear);
      set(gca,'XTickLabel',xdata.xvalues);
      set(gca,'YTickLabel',xdata.yvalues);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      grid off;
      axis vis3d;
      axis tight;
      if a==0
         if b==90
            view([-45 45])
         end
      else
         view(a,b);
      end

   case 'Surface+Contour'
      surfc(xx,yy,dd);
      shading(ShadingType);
      set(gca,'XTick',xlinear);
      set(gca,'YTick',ylinear);
      set(gca,'XTickLabel',xdata.xvalues);
      set(gca,'YTickLabel',xdata.yvalues);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      grid off;
      axis vis3d;
      if a==0
         if b==90
            view([-45 45])
         end
      else
         view(a,b);
      end

   case 'Contour'
      [c,h] = contour(xx,yy,dd); clabel(c,h);
      set(gca,'XTick',xlinear);
      set(gca,'YTick',ylinear);
      set(gca,'XTickLabel',xdata.xvalues);
      set(gca,'YTickLabel',xdata.yvalues);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);

   case 'Filled Contour'
      [c,h] = contourf(xx,yy,dd); clabel(c,h);
      set(gca,'XTick',xlinear);
      set(gca,'YTick',ylinear);
      set(gca,'XTickLabel',xdata.xvalues);
      set(gca,'YTickLabel',xdata.yvalues);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);

   case 'Waterfall'
      waterfall(xx,yy,dd);
      set(gca,'XTick',xlinear);
      set(gca,'YTick',ylinear);
      set(gca,'XTickLabel',xdata.xvalues);
      set(gca,'YTickLabel',xdata.yvalues);
      xlabel(xdata.xtitle);
      ylabel(xdata.ytitle);
      grid off;
      axis vis3d;
      if a==0
         if b==90
            view([-45 45])
         end
      else
         view(a,b);
      end
   end
   
end
title([xdata.runname ' - ' num2str(xdata.cellone) '&' num2str(xdata.celltwo) ' [' num2str(xv.BinWidth) 'ms BW|Trials:' num2str(xv.StartTrial) '-' num2str(xv.EndTrial) ']' ]);
%set(gca,'Tag','XCorAxis');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Ians cross-correlation routine, uses a sliding window method
%
%[x, timebase]=icorrx(xdata.raw{i},binwidth,window,from,to)
%
%Now uses a non-sparse "tree-style" structure for spike data [Rowland]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x,timebase,ci]=icorrx(raw,binwidth,window,from,to,shuffles,type,p)

global xv

cellone=raw.cellone;
celltwo=raw.celltwo;

if to==Inf
   to=max([cellone.maxtime, celltwo.maxtime]);
end;

window=round(window/binwidth);  %convert into a number of bins

if rem(window,2)<1  %make sure that window is odd i.e. will be symmetrical around zero
   window=window+1;
end


%this sets up the timebase for the bins
time=-(((binwidth*window)-binwidth)/2):binwidth:(((binwidth*window)-binwidth)/2);
corr=zeros(1,size(time,2));
x=corr;
wwidth=time(end)+(binwidth/2);

%number of trials we're dealing with
trials=cellone.numtrials;


if to<=wwidth*3
   errordlg('Your binwidth/window parameters are too big for the length of the PSTH');
   return
elseif to<=wwidth*4
   h=errordlg('Your binwidth/window parameters are losing half or more of the data: CAUTION');
   pause(2)
   close(h)
elseif to<=wwidth*6
   h=errordlg('Your binwidth/window parameters are losing 1/3 or more of the data: CAUTION');
   pause(2)
   close(h)
end

%Make a table to do non shuffled correlation
trialcombs=[1:trials;1:trials];

%If we're using shuffle correction
if (type>1)
    %-Add shuffle combinations to the standard table
    for s=1:shuffles
        trialcombs=[trialcombs [1:trials;[(1+s):trials 1:s]]];
    end
end

unshuffled=[];
%Run through table
for i=1:size(trialcombs,2)
    %-Get spike times from xdata
    spktrain1=[];
    spktrain2=[];
    for m=1:cellone.nummods
        spktrain1=[spktrain1; cellone.trial(trialcombs(1,i)).mod{m}];
        spktrain2=[spktrain2; celltwo.trial(trialcombs(2,i)).mod{m}];
    end
    spktrain1=round(spktrain1/10);
    spktrain2=round(spktrain2/10);

    %-run through each spike in a trial
    for j=1:size(spktrain1,1)
        %--If its in the window...
        if spktrain1(j)>(from+wwidth) & spktrain1(j)<(to-wwidth);
            %---For each bin get find number of spikes from other cell
            for k=1:size(time,2);
                mint=spktrain1(j)+time(k)-(binwidth/2); %get the mintime for this bin
                maxt=spktrain1(j)+time(k)+(binwidth/2); %get the maxtime for this bin
                m=find(spktrain2>=mint & spktrain2<maxt);
                corr(k)=length(m); %tells us how many spikes were at this bin
            end
            x=x+corr;
        end
    end
    if (i==trials)
        unshuffled=x;              %Save unshuffled correlations
        x=zeros(1,size(x,2));   %Clear x to hold only shuffled data
    end
end

%if we've shuffled
if type>1
    x=x./(shuffles);
    %-if we're subtracting shuffled from unshuffled
    if type==3
        x=unshuffled-x;
    end
%if we're not shuffling
else
    x=unshuffled;
end

%Confidence Intervals
if type==2
    ci=zeros(2,size(x,2));
    for n=1:size(x,2)
        lmts=poissinv([p/2 (1-(p/2))],x(n));
        ci(1,n)=lmts(1);
        ci(2,n)=lmts(2);
    end
else
    ci=[];
end

timebase=time;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function SpawnPlot(handle)

%To plot current info on new object

global LightAdd;
global datatype
global slope
global xdata
global hw

if isempty(datatype)
	x=axis;
	cmap=get(gcf,'ColorMap');
	[a,b]=view;
	figure;
	set(gcf,'Renderer','zbuffer');
	xcormatrix;
	colormap(cmap);
	view(a,b);
	set(gcf,'Color',[1 1 1]);
	axis(x);
	if ~isempty(LightAdd)
	  camlight(LightAdd);
	end;
	colorbar;
	%    if xdata.numvars==1
	%       [x,y]=ginput(1);
	%       text(x,y,[num2str(slope) ' ms/deg'],'FontSize',11,'Color',[1 1 1]);
	%    end
	%print -dbitmap
else
	%x=axis;
	%figure;
	%crosscor('See Tuning');
	%axis(x);
	%[o,p]=ginput(1);
	%t=['Half Width = ' num2str(hw) 'deg'];
	%text(o,p,t);
	h=gca;
	cf=figure;
	set(gcf,'Renderer','zbuffer');
	copyobj(h,cf, 'legacy')
	set(gca,'Position',[109 39 370 358])
	pause(0.5); 
	set(gcf,'Color',[1 1 1]);
   %print -dbitmap;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Converts array of numbers to a cell array of strings
function [cellout]=nums2strs(arrayin)
   if (length(arrayin)>1)
       for n=1:length(arrayin)
           cellout{n}=num2str(arrayin(n));
       end
   else
       cellout=num2str(arrayin);
   end
%End of function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y=fitgaussian(g,xdata,data)

% This generates a gaussian fit
% compatible with the optimisation toolbox.
%
% g= the set of 3 parameters for the gaussian
%
% g(1) = centre amplitude
% g(2) = centre size
% g(3) = DC level
% g(4) = Position on the X axis
%
% xdata = the x-axis values of the summation curve to model
% data = the real tuning curve data
%
% it will output a mean squared estimate of the residuals between model and data

for a=1:length(xdata);
    f(a,:)=(g(3)+(g(1)*exp(-((xdata(a)-g(4))^2)/g(2)^2)));  %halfmatrixhalfloop
end

y=sum((data-f').^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%FUNCTION DEFINITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y=fitgaussian2(g,xdata)

% This generates a gaussian fit.
%
% g= the set of 3 parameters for the gaussian
%
% g(1) = centre amplitude
% g(2) = centre size
% g(3) = DC level
% g(4) = Position on the X axis
%
% xdata = the x-axis values of the summation curve to model

for a=1:length(xdata);
    f(a,:)=(g(3)+(g(1)*exp(-((xdata(a)-g(4))^2)/g(2)^2)));  %halfmatrixhalfloop
end

y=f';