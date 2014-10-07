function outs = getdensity(x,y,inopts)
%GETDENSITY computes bootstrapped density estimates and full stats for two
%groups. You can pass a set of cases to the function and it will compute
%statistics automagically for all cases as well. There are numerous
%settings:
% nboot - number of bootstrap iterations default: 1000
% fhandle - function handle to bootstrap default: @mean
% alpha - P value to use for all statistics
% legendtxt - A cell list of the main X and Y data, i.e. {'Control','Drug'}
% dogauss - Add gaussian fits to the histograms? default: true
% columnlabels - if X/Y have more than 1 column, you can detail column names here
% dooutlier - remove outliers using 'grubb', 'rosner', 3SD' or 'none'
% addjitter - add jitter to scatterplot? 'x', 'y', 'both', 'equal', 'none'
% cases - a celllist of case names the same length as X/Y
% jitterfactor - how much to scale the jitter, larger values = less jitter
% showoriginalscatter - show unjittered data too?

if nargin == 0
	disp('You need to enter in x data at the minimum, use help for more info...')
	return;
end

if exist('x','var') && isstruct(x) %first input is actually inopts!
	inopts = x;
end

if ~exist('inopts','var') || ~isstruct(inopts) %lets initialise
	inopts = struct();
end

bartype='grouped';
barwidth=1.25;

outs = struct();

if isfield(inopts,'x')
	x=inopts.x;
end
if ~exist('y','var') || isempty(y)
	y=zeros(size(x));
end
if isfield(inopts,'y')
	y=inopts.y;
end
if ~isfield(inopts,'nboot')
	inopts.nboot=1000;
end
if ~isfield(inopts,'fhandle')
	inopts.fhandle=@mean;
end
if ~isfield(inopts,'alpha')
	inopts.alpha=0.05;
end
if ~isfield(inopts,'legendtxt')
	inopts.legendtxt={'Group 1','Group 2'};
end
if ~isfield(inopts,'dogauss')
	inopts.dogauss=1;
end
if ~isfield(inopts,'columnlabels')
	inopts.columnlabels={'Set 1'};
end
if ~isfield(inopts,'dooutlier')
	inopts.dooutlier='none';
end
if ~isfield(inopts,'addjitter')
	inopts.addjitter = 'none';
end
if ~isfield(inopts,'cases')
	inopts.cases = [];
	uniquecases = [];
end
if ~isfield(inopts,'nominalcases')
	inopts.nominalcases = true;
end
if ~isfield(inopts,'rosnern')
	inopts.rosnern=2; %rosner outlier number of outliers
end
if ~isfield(inopts,'outlierp')
	inopts.outlierp = 0.001; %p to use for outlier removal for rosner and grubb
end
if ~isfield(inopts,'jitterfactor')
	inopts.jitterfactor = 100; %scalefactor for jitter of scatter plot
end
if ~isfield(inopts,'singleplots')
	inopts.singleplots = false;
end
if ~isfield(inopts,'showoriginalscatter')
	inopts.showoriginalscatter = false;
end

if size(x,1)==1
	x=x';
	y=y';
end

if size(x,2)~=size(y,2)
	x=x(:,1);
	y=y(:,1);
end

if length(x(:,1))~=length(y(:,1))
	suba=3;
	subb=1;
else
	suba=2;
	subb=2;
end

if size(x,2) > length(inopts.columnlabels)
	for i = length(inopts.columnlabels)+1 : size(x,2)
		inopts.columnlabels{i} = ['Set_' num2str(i)];
	end
end

if ~isempty(inopts.cases)
	if inopts.nominalcases == true
		inopts.cases = nominal(inopts.cases);
	else
		inopts.cases = ordinal(inopts.cases);
	end
	uniquecases = getlabels(inopts.cases);
end

outs.x = x;
outs.y = y;
outs.columnlabels = inopts.columnlabels;
outs.inopts = inopts;

for i=1:size(x,2) %iterate through columns
	
	xcol=x(:,i);
	ycol=y(:,i);
	
	xouttext='';
	youttext='';

	fieldn = inopts.columnlabels{i};
	fieldn = regexprep(fieldn,'\s+','_');
	
	h=figure;
	outs.(fieldn).h = h;
	set(h,'Color',[0.9 0.9 0.9])
	
	if suba == 3
		figpos(3,[600 1200]);
	else
		figpos(1,[1200,1000]);
	end
	
	pn = panel();
	pn.pack(suba,subb);
	
	if max(isnan(xcol)) == 1 %remove any nans
		xcol = xcol(isnan(xcol)==[]);
	end
	if max(isnan(y)) == 1
		y = y(isnan(y)==0);
	end
	
	xmean=nanmean(xcol); %initial values before outlier removal
	ymean=nanmean(ycol);
	xstd=nanstd(xcol);
	ystd=nanstd(ycol);
	
	switch inopts.dooutlier
		case 'quantiles'
			idx1=qoutliers(xcol);
			idx2=qoutliers(ycol);
			if length(xcol)==length(ycol)
				idx=idx1+idx2;
				xouttext=sprintf('%0.3g ',xcol(idx>0)');
				youttext=sprintf('%0.3g ',ycol(idx>0)');
				xcol(idx>0)=[];
				ycol(idx>0)=[];
				inopts.cases(idx>0)=[];
			else
				xouttext=sprintf('%0.3g ',xcol(idx1>0)');
				youttext=sprintf('%0.3g ',ycol(idx2>0)');
				xcol(idx1>0)=[];
				ycol(idx2>0)=[];
			end
		case 'rosner'
			idx1=outlier(xcol,inopts.outlierp,inopts.rosnern);
			idx2=outlier(ycol,inopts.outlierp,inopts.rosnern);
			if ~isempty(idx1) || ~isempty(idx2)
				if length(xcol)==length(ycol)
					idx=unique([idx1;idx2]);
					xouttext=sprintf('%0.3g ',xcol(idx)');
					youttext=sprintf('%0.3g ',ycol(idx)');
					xcol(idx)=[];
					ycol(idx)=[];
					inopts.cases(idx>0)=[];
				else
					xouttext=sprintf('%0.3g ',xcol(idx1)');
					youttext=sprintf('%0.3g ',ycol(idx2)');
					xcol(idx1)=[];
					ycol(idx2)=[];
				end
			end
		case 'grubb'
			[~,idx1]=deleteoutliers(xcol,inopts.outlierp);
			[~,idx2]=deleteoutliers(ycol,inopts.outlierp);
			if length(xcol)==length(ycol)
				idx=unique([idx1;idx2]);
				xouttext=sprintf('%0.3g ',xcol(idx)');
				youttext=sprintf('%0.3g ',ycol(idx)');
				xcol(idx)=[];
				ycol(idx)=[];
				inopts.cases(idx>0)=[];
			else
				xouttext=sprintf('%0.3g ',xcol(idx1)');
				youttext=sprintf('%0.3g ',ycol(idx2)');
				xcol(idx1)=[];
				ycol(idx2)=[];
			end
		case '2SD'
			mtmp=repmat(xmean,length(xcol),1);
			stmp=repmat(xstd,length(xcol),1);
			idx1=abs(xcol-mtmp)>2*stmp;
			
			mtmp=repmat(ymean,length(ycol),1);
			stmp=repmat(ystd,length(ycol),1);
			idx2=abs(ycol-mtmp)>2*stmp;
			if length(xcol)==length(ycol)
				idx=idx1+idx2;
				xouttext=sprintf('%0.3g ',xcol(idx>0)');
				youttext=sprintf('%0.3g ',ycol(idx>0)');
				xcol(idx>0)=[];
				ycol(idx>0)=[];
				inopts.cases(idx>0)=[];
			else
				xouttext=sprintf('%0.3g ',xcol(idx1>0)');
				youttext=sprintf('%0.3g ',ycol(idx2>0)');
				xcol(idx1>0)=[];
				ycol(idx2>0)=[];
			end
		case '3SD'
			mtmp=repmat(xmean,length(xcol),1);
			stmp=repmat(xstd,length(xcol),1);
			idx1=abs(xcol-mtmp)>3*stmp;
			
			mtmp=repmat(ymean,length(ycol),1);
			stmp=repmat(ystd,length(ycol),1);
			idx2=abs(ycol-mtmp)>3*stmp;
			if length(xcol)==length(ycol)
				idx=idx1+idx2;
				xouttext=sprintf('%0.3g ',xcol(idx>0));
				youttext=sprintf('%0.3g ',ycol(idx>0));
				xcol(idx>0)=[];
				ycol(idx>0)=[];
				inopts.cases(idx>0)=[];
			else
				xouttext=sprintf('%0.3g ',xcol(idx1>0));
				youttext=sprintf('%0.3g ',ycol(idx2>0));
				xcol(idx1>0)=[];
				ycol(idx2>0)=[];
			end
		otherwise
			
	end
	
	xmean=nanmean(xcol);
	xmedian=nanmedian(xcol);
	ymean=nanmean(ycol);
	ymedian=nanmedian(ycol);
	xstd=nanstd(xcol);
	ystd=nanstd(ycol);
	xstderr=stderr(xcol,'SE',1);
	ystderr=stderr(ycol,'SE',1);
	
	dmin=min([xcol;ycol]); %get the min
	dmax=max([xcol;ycol]); %get the max
	
	histax=floor(dmin):(ceil(dmax)-floor(dmin))/10:ceil(dmax);
	
	[xn,hbins]=hist(xcol,histax);
	yn=hist(ycol,histax);
	
	%subplot_tight(suba,subb,1,margin)
	pn(1,1).select();
	
	if ystd > 0
		h=bar([hbins',hbins'],[xn',yn'],barwidth,bartype);
		set(h(1),'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
		set(h(2),'FaceColor',[0.7 0 0],'EdgeColor',[0.7 0 0]);
	else
		h=bar([hbins'],[xn'],barwidth,bartype);
		set(h(1),'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
	end
	
	axis tight;
	lim=ylim;
	text(xmean,lim(2),'\downarrow','Color',[0 0 0],'HorizontalAlignment','center',...
		'VerticalAlignment','bottom','FontSize',15,'FontWeight','bold');
	text(xmedian,lim(2),'\nabla','Color',[0 0 0],'HorizontalAlignment','center',...
		'VerticalAlignment','bottom','FontSize',15,'FontWeight','bold');
	if ystd > 0
		text(ymean,lim(2),'\downarrow','Color',[0.8 0 0],'HorizontalAlignment','center',...
			'VerticalAlignment','bottom','FontSize',15,'FontWeight','bold');
		text(ymedian,lim(2),'\nabla','Color',[0.8 0 0],'HorizontalAlignment','center',...
			'VerticalAlignment','bottom','FontSize',15,'FontWeight','bold');
	end
	
	if inopts.dogauss == true
		hold on
		if length(find(xn>0))>1
			try
				f1=fit(hbins',xn','gauss1');
				plot(f1,'k');
			catch
			end
		end
		if ystd > 0 && length(find(yn>0))>1
			try
				f2=fit(hbins',yn','gauss1');
				plot(f2,'r');
			catch
			end
		end
		legend off
		hold off
	end
	
	pn(1,1).xlabel(inopts.columnlabels{i});
	pn(1,1).ylabel('Number of cells');
	
	if suba>1
		%subplot_tight(suba,subb,2,margin)
		if suba == 3; pn(2,1).select();end
		if suba == 2; pn(1,2).select();end
		if exist('distributionPlot','file')
			hold on
			distributionPlot({xcol,ycol},0.3);
		end
		if length(xcol)==length(ycol)
			boxplot([xcol,ycol],'notch',1,'whisker',1,'labels',inopts.legendtxt,'colors','k')
		end
		hold off
		box on
	end
	
	xcolout = xcol;
	ycolout = ycol;
	
	if ystd > 0 && length(xcol)==length(ycol)
		%subplot_tight(suba,subb,3,margin)
		pn(2,1).select()
		[r,p]=corr(xcol,ycol);
		[r2,p2]=corr(xcol,ycol,'type','spearman');
		xrange = max(xcol) - min(xcol);
		yrange = max(ycol) - min(ycol);
		xjitter = (randn(length(xcol),1))*(xrange/inopts.jitterfactor);
		yjitter = (randn(length(ycol),1))*(yrange/inopts.jitterfactor);
		bothjitter = (randn(length(xcol),1))*(max(xrange,yrange)/inopts.jitterfactor);
		switch inopts.addjitter
			case 'x'
				sc = true;
				xcolout = xcol + xjitter;
				ycolout = ycol;
			case 'y'
				sc = true;
				xcolout = xcol;
				ycolout = ycol + yjitter;
			case 'equal'
				sc = true;
				xcolout = xcol + bothjitter;
				ycolout = ycol + bothjitter;
			case 'both'
				sc = true;
				xcolout = xcol + xjitter;
				ycolout = ycol + yjitter;
			otherwise
				sc = false;
				xcolout = xcol;
				ycolout = ycol;
		end
		
		mn = min(min(xcol),min(ycol));
		mx = max(max(xcol),max(ycol));
		axrange = [(mn - (mn/10)) (mx + (mx/10))];
		
		if ~isempty(inopts.cases)
			t = 'Group: ';
			for jj = 1:length(uniquecases)
				caseidx{jj} = ismember(inopts.cases,uniquecases{jj});
				colours(caseidx{jj},1) = jj;
				t = [t num2str(jj) '=' uniquecases{jj} ' '];
			end
		else
			colours = [0 0 0];
			t = '';
		end
		
		hold on
		if ~isempty(inopts.cases)
			h = gscatter(xcolout,ycolout,inopts.cases,'krbgmyc','o');
		else
			h = scatter(xcolout,ycolout,repmat(80,length(xcol),1),[0 0 0]);
		end
		axis([axrange axrange])
		axis square
		%ch = get(h,'Children');
		%set(ch,'FaceAlpha',0.1,'EdgeAlpha',1);
		try %#ok<TRYNC>
			h = lsline;
			set(h,'LineStyle','--','LineWidth',2)
			if r2 >= 0
				h = line([mn mx],[mn mx]);
				set(h,'Color',[0.7 0.7 0.7],'LineStyle','-.','LineWidth',2)
			else
				h = line([mx mn],[mn mx]);
				set(h,'Color',[0.7 0.7 0.7],'LineStyle','-.','LineWidth',2)
			end
		end
		if sc == true && inopts.showoriginalscatter == true
			scatter(xcol,ycol,repmat(80,length(xcol),1),'ko','MarkerEdgeColor',[0.9 0.9 0.9]);
		end
		pn(2,1).xlabel(inopts.legendtxt{1})
		pn(2,1).ylabel(inopts.legendtxt{2})
		pn(2,1).title(['Prson:' sprintf('%0.2g',r) '(p=' sprintf('%0.4g',p) ') | Spman:' sprintf('%0.2g',r2) '(p=' sprintf('%0.4g',p2) ') ' t]);
		hold off
		box on
		set(gca,'Layer','top');
	end
	
	t=['Mn/Mdn: ' sprintf('%0.3g', xmean) '\pm' sprintf('%0.3g', xstderr) '/' sprintf('%0.3g', xmedian) ' | ' sprintf('%0.3g', ymean) '\pm' sprintf('%0.3g', ystderr) ' / ' sprintf('%0.3g', ymedian)];
	
	warning('off')
	if ystd > 0
		if length(xcol) == length(ycol)
			[h,p1]=ttest2(xcol,ycol,inopts.alpha);
		else
			[h,p1]=ttest2(xcol,ycol,inopts.alpha);
		end
		[p2,h]=ranksum(xcol,ycol,'alpha',inopts.alpha);
		if length(xcol) == length(ycol)
			[h,p3]=ttest(xcol,ycol,inopts.alpha);
			[p4,h]=signrank(xcol,ycol,'alpha',inopts.alpha);
			[p5,h]=signtest(xcol,ycol,'alpha',inopts.alpha);
		end
		[h,p6]=jbtest(xcol,inopts.alpha);
		[h,p7]=jbtest(ycol,inopts.alpha);
		if length(xcol)>4
			[h,p8]=lillietest(xcol);
		else
			p8=NaN;
		end
		if length(ycol)>4
			[h,p9]=lillietest(ycol);
		else
			p9=NaN;
		end
		[h,p10]=kstest2(xcol,ycol,inopts.alpha);
	else
		[h,p1]=ttest(xcol,inopts.alpha);
		[p2,h]=signrank(xcol,0,'alpha',inopts.alpha);
		p3=0;
		p4=0;
		[p5,h]=signtest(xcol,0,'alpha',inopts.alpha);
		[h,p6]=jbtest(xcol,inopts.alpha);
		p7=0;
		if length(xcol)>4
			[h,p8]=lillietest(xcol);
		else
			p8=NaN;
		end
		p9=0;
		p10=kstest(xcol);
	end
	warning('on')
	
	t=[t '\newlineT-test: ' sprintf('%0.3g', p1) '\newline'];
	t=[t 'Wilcox: ' sprintf('%0.3g', p2) '\newline'];
	if exist('p3','var') && ystd > 0
		t=[t 'Pair ttest: ' sprintf('%0.3g', p3) '\newline'];
		t=[t 'Pair wilcox: ' sprintf('%0.3g', p4) '\newline'];
		t=[t 'Pair sign: ' sprintf('%0.3g', p5) '\newline'];
	elseif exist('p5','var')
		t=[t 'Sign: ' sprintf('%0.3g', p5) '\newline'];
	end
	t=[t 'Jarque-Bera: ' sprintf('%0.3g', p6) ' / ' sprintf('%0.3g', p7) '\newline'];
	t=[t 'Lilliefors: ' sprintf('%0.3g', p8) ' / ' sprintf('%0.3g', p9) '\newline'];
	t=[t 'KSTest: ' sprintf('%0.3g', p10) '\newline'];
	
	[xci,xmean,xpop]=bootci(inopts.nboot,{inopts.fhandle,xcol},'alpha',inopts.alpha);
	[yci,ymean,ypop]=bootci(inopts.nboot,{inopts.fhandle,ycol},'alpha',inopts.alpha);
	
	t=[t 'BootStrap: ' sprintf('%0.2g', xci(1)) ' < ' sprintf('%0.2g', xmean) ' > ' sprintf('%0.2g', xci(2)) ' | ' sprintf('%0.2g', yci(1)) ' < ' sprintf('%0.2g', ymean) ' > ' sprintf('%0.2g', yci(2))];
	
	[fx,xax]=ksdensity(xpop);
	[fy,yax]=ksdensity(ypop);
	
	% 	[h,p1]=ttest2(xpop,ypop,alpha);
	% 	[p2,h]=ranksum(xpop,ypop,'alpha',alpha);
	% 	t=[t 'BS T: ' num2str(p1) '\newline'];
	% 	t=[t 'BS Rank: ' num2str(p2)];
	
	if suba == 2;	pn(2,2).select();	end
	if suba == 3;	pn(3,1).select();	end
	
	plot(xax,fx,'k-','linewidth',1.5);
	if ystd > 0
		hold on
		plot(yax,fy,'r-','linewidth',1.5);
		hold off
	end
	set(gca,'Layer','top');
	axis tight
	title(['BootStrap Density Plots; using: ' func2str(inopts.fhandle)]);
	box on
	
	if size(x,2)>1;
		if ~isempty(inopts.columnlabels)
			supt=['Column: ' inopts.columnlabels{i} ' | n = ' num2str(length(xcol)) '[' num2str(length(x(:,i))) '] & ' num2str(length(ycol)) '[' num2str(length(y(:,i))) ']'];
		else
			supt=['Column: ' num2str(i) ' | n = ' num2str(length(xcol)) '[' num2str(length(x(:,i))) '] & ' num2str(length(ycol)) '[' num2str(length(y(:,i))) ']'];
		end
	else
		supt=[inopts.columnlabels{i} ' # = ' num2str(length(xcol)) '[' num2str(length(x(:,i))) '] & ' num2str(length(ycol)) '[' num2str(length(y(:,i))) ']'];
	end
	
	if ~isempty(xouttext) && ~strcmp(xouttext,' ') && length(xouttext)<25
		supt=[supt ' | ' dooutlier ': 1 = ' xouttext];
	end
	if ~isempty(youttext) && ~strcmp(youttext,' ') && length(xouttext)<25
		supt=[supt ' | 2 = ' youttext];
	end
	
	h = suptitle(supt);
	set(h,'FontName','Consolas','FontSize',16,'FontWeight','bold')
	
	xl=xlim;
	yl=ylim;
	
	xfrag=(xl(2)-xl(1))/40;
	yfrag=(yl(2)-yl(1))/40;
	
	h=line([xci(1),xmean,xci(2);xci(1),xmean,xci(2);],[yl(1),yl(1),yl(1);yl(2),yl(2),yl(2)]);
	set(h,'Color',[0.5 0.5 0.5],'LineStyle','--');
	
	h=line([yci(1),ymean,yci(2);yci(1),ymean,yci(2);],[yl(1),yl(1),yl(1);yl(2),yl(2),yl(2)]);
	set(h,'Color',[1 0.5 0.5],'LineStyle',':');
	
	text(xl(1)+xfrag,yl(2)-yfrag,t,'FontSize',13,'FontName','Consolas','FontWeight','bold','VerticalAlignment','top');
	%legend(inopts.legendtxt);
	
	pn.select('all')
	pn.fontname = 'Helvetica';
	pn.fontsize = 12;
	pn.margin = 20;
	
	outs.(fieldn).pn = pn;
	outs.(fieldn).xcol = xcol;
	outs.(fieldn).ycol = ycol;
	outs.(fieldn).xmean = xmean;
	outs.(fieldn).xmedian = xmedian;
	outs.(fieldn).ymean = ymean;
	outs.(fieldn).ymedian = ymedian;
	outs.(fieldn).xcolout = xcolout;
	outs.(fieldn).ycolout = ycolout;
	outs.(fieldn).text = t;
	
	if inopts.singleplots == true
		if suba == 2;
			h = figure;
			p = copyobj(pn(1,1).axis,h, 'legacy');
			set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
			h = figure;
			p = copyobj(pn(1,2).axis,h, 'legacy');
			set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
			h = figure;
			p = copyobj(pn(2,1).axis,h, 'legacy');
			set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
			h=figure;
			p = copyobj(pn(2,2).axis,h, 'legacy');
			set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
		elseif suba == 3;
			h = figure;
			p = copyobj(pn(1,1).axis,h, 'legacy');
			set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
			h = figure;
			p = copyobj(pn(2,1).axis,h, 'legacy');
			set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
			h = figure;
			p = copyobj(pn(3,1).axis,h, 'legacy');
			set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
		end
	end
	
	if ~isempty(uniquecases)
		for jj = 1:length(uniquecases)
			xtmp = xcol(caseidx{jj});
			ytmp = ycol(caseidx{jj});
			name = ['Case_' uniquecases{jj}];
			inoptstmp = inopts;
			inoptstmp = rmfield(inoptstmp,'x');
			inoptstmp = rmfield(inoptstmp,'y');
			inoptstmp = rmfield(inoptstmp,'cases');
			inoptstmp.columnlabels{1} = [inoptstmp.columnlabels{i} ' ' name];
			outtmp = getdensity(xtmp,ytmp,inoptstmp);
			outs.(fieldn).(name)=outtmp;
		end
		figure(outs.(fieldn).h);
	end
end
end