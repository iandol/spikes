function getdensity(x,y,nboot,fhandle,alpha,legendtxt,dogauss,columnlabels,dooutlier)

%getdensity computes bootstrapped density estimates
%getdensity(x,y,nboot,fhandle,alpha,legend,gauss,columnlabel,dooutlier)

bartype='grouped';
barwidth=1.25;
xouttext='';
youttext='';
rosnern=2; %rosner outlier number of outliers

if ~exist('nboot','var') || isempty(nboot)
	nboot=1000;
end
if ~exist('fhandle','var') || isempty(fhandle)
	fhandle=@mean;
end
if ~exist('alpha','var') || isempty(alpha)
	alpha=0.05;
end
if ~exist('legendtxt','var') || isempty(legendtxt)
	legendtxt={'Group 1','Group 2'};
end
if ~exist('dogauss','var') || isempty(dogauss)
	dogauss=1;
end
if ~exist('columnlabels','var') || isempty(columnlabels)
	columnlabels='';
end
if ~exist('dooutlier','var') || isempty(dooutlier)
	dooutlier='none';
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
	suba=1;
	subb=2;
else
	suba=2;
	subb=2;
end

for i=1:size(x,2) %iterate through columns
	
	xcol=x(:,i);
	ycol=y(:,i);
	
	xmean=nanmean(xcol); %initial values before outlier removal
	ymean=nanmean(ycol);
	xstd=nanstd(xcol);
	ystd=nanstd(ycol);
	
	switch dooutlier
		case 'none'
		case 'quantiles'
			idx1=qoutliers(xcol);
			idx2=qoutliers(ycol);			
			if suba>1
				idx=idx1+idx2;
				xouttext=sprintf('%0.3g ',xcol(idx>0)');
				youttext=sprintf('%0.3g ',ycol(idx>0)');
				xcol(idx>0)=[];
				ycol(idx>0)=[];
			else
				xouttext=sprintf('%0.3g ',xcol(idx1>0)');
				youttext=sprintf('%0.3g ',ycol(idx2>0)');
				xcol(idx1>0)=[];
				ycol(idx2>0)=[];
			end
		case 'rosner'
			idx1=outlier(xcol,0.05,rosnern);
			idx2=outlier(ycol,0.05,rosnern);			
			if suba>1
				idx=unique([idx1;idx2]);
				xouttext=sprintf('%0.3g ',xcol(idx)');
				youttext=sprintf('%0.3g ',ycol(idx)');
				xcol(idx)=[];
				ycol(idx)=[];
				
			else
				xouttext=sprintf('%0.3g ',xcol(idx1)');
				youttext=sprintf('%0.3g ',ycol(idx2)');
				xcol(idx1)=[];
				ycol(idx2)=[];
			end
		case 'grubb'
			[out,idx1]=deleteoutliers(xcol,0.05);
			[out,idx2]=deleteoutliers(ycol,0.05);
			if suba>1
				idx=unique([idx1;idx2]);
				xouttext=sprintf('%0.3g ',xcol(idx)');
				youttext=sprintf('%0.3g ',ycol(idx)');
				xcol(idx)=[];
				ycol(idx)=[];
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
			if suba>1
				idx=idx1+idx2;
				xouttext=sprintf('%0.3g ',xcol(idx>0)');
				youttext=sprintf('%0.3g ',ycol(idx>0)');
				xcol(idx>0)=[];
				ycol(idx>0)=[];
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
			if suba>1
				idx=idx1+idx2;
				xouttext=sprintf('%0.3g ',xcol(idx>0));
				youttext=sprintf('%0.3g ',ycol(idx>0));
				xcol(idx>0)=[];
				ycol(idx>0)=[];
			else
				xouttext=sprintf('%0.3g ',xcol(idx1>0));
				youttext=sprintf('%0.3g ',ycol(idx2>0));
				xcol(idx1>0)=[];
				ycol(idx2>0)=[];
			end
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
	
	figure;
	set(gcf,'Color',[1 1 1])
	
	if suba == 1
		figpos(1,[900,400]);
	else
		figpos(1,[900,700]);
	end
	
	subplot(suba,subb,1)
	
	h=bar([hbins',hbins'],[xn',yn'],barwidth,bartype);
	set(h(1),'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
	set(h(2),'FaceColor',[0.7 0 0],'EdgeColor',[0.7 0 0]);
	ylabel('Number of Cells');
	if ~strcmp(columnlabels,''); xlabel(columnlabels{i}); end
	axis tight;
	lim=ylim;	
	text(xmean,lim(2),'\downarrow','Color',[0 0 0],'HorizontalAlignment','center','VerticalAlignment','bottom');
	text(ymean,lim(2),'\downarrow','Color',[0.8 0 0],'HorizontalAlignment','center','VerticalAlignment','bottom');
	text(xmedian,lim(2),'\nabla','Color',[0 0 0],'HorizontalAlignment','center','VerticalAlignment','bottom');
	text(ymedian,lim(2),'\nabla','Color',[0.8 0 0],'HorizontalAlignment','center','VerticalAlignment','bottom');
	box off;
	
	if dogauss>0
		hold on
		if length(find(xn>0))>1
			try
				f1=fit(hbins',xn','gauss1');
				plot(f1,'k');
			catch
			end
		end
		if length(find(yn>0))>1
			try
				f2=fit(hbins',yn','gauss1');
				plot(f2,'r');
			catch
			end
		end
		legend off
		hold off
	end
	
	if suba>1
	subplot(suba,subb,2)
	boxplot([xcol,ycol],'notch',1,'whisker',1,'labels',legendtxt,'colors','k')
	subplot(suba,subb,3)
	[r,p]=corr(xcol,ycol);
	[r2,p2]=corr(xcol,ycol,'type','spearman');
	plot(xcol,ycol,'r.','MarkerSize',15);
	title(['Prson:' sprintf('%0.2g',r) '(p=' sprintf('%0.4g',p) ') | Spman:' sprintf('%0.2g',r2) '(p=' sprintf('%0.4g',p2) ')']);
	axis equal
	try
		lsline
	catch
	end
	end

	t=['Mn/Mdn: ' sprintf('%0.3g', xmean) '\pm' sprintf('%0.3g', xstderr) '/' sprintf('%0.3g', xmedian) ' | ' sprintf('%0.3g', ymean) '\pm' sprintf('%0.3g', ystderr) ' / ' sprintf('%0.3g', ymedian)];

	[h,p1]=ttest2(xcol,ycol,alpha);
	[p2,h]=ranksum(xcol,ycol,'alpha',alpha);
	if length(xcol)==length(ycol)
		[h,p3]=ttest(xcol,ycol,alpha);
		[p4,h]=signrank(xcol,ycol,'alpha',alpha);
		[p5,h]=signtest(xcol,ycol,'alpha',alpha);
	end
	[h,p6]=jbtest(xcol,alpha);
	[h,p7]=jbtest(ycol,alpha);
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
	[h,p10]=kstest2(xcol,ycol,alpha);
	
	t=[t '\newlineT-test: ' sprintf('%0.3g', p1) '\newline'];
	t=[t 'Wilcox: ' sprintf('%0.3g', p2) '\newline'];
	if exist('p3','var')
		t=[t 'Pair ttest: ' sprintf('%0.3g', p3) '\newline'];
		t=[t 'Pair wilcox: ' sprintf('%0.3g', p4) '\newline'];
		t=[t 'Pair sign: ' sprintf('%0.3g', p5) '\newline'];
	end
	t=[t 'Jarque-Bera: ' sprintf('%0.3g', p6) ' / ' sprintf('%0.3g', p7) '\newline'];
	t=[t 'Lilliefors: ' sprintf('%0.3g', p8) ' / ' sprintf('%0.3g', p9) '\newline'];
	t=[t 'KSTest: ' sprintf('%0.3g', p10) '\newline'];
	
	[xci,xmean,xpop]=bootci(nboot,{fhandle,xcol},'alpha',alpha);
	[yci,ymean,ypop]=bootci(nboot,{fhandle,ycol},'alpha',alpha);
	
	t=[t 'BootStrap: ' sprintf('%0.2g', xci(1)) ' < ' sprintf('%0.2g', xmean) ' > ' sprintf('%0.2g', xci(2)) ' | ' sprintf('%0.2g', yci(1)) ' < ' sprintf('%0.2g', ymean) ' > ' sprintf('%0.2g', yci(2))];

	[fx,xax]=ksdensity(xpop);
	[fy,yax]=ksdensity(ypop);

% 	[h,p1]=ttest2(xpop,ypop,alpha);
% 	[p2,h]=ranksum(xpop,ypop,'alpha',alpha);
% 	t=[t 'BS T: ' num2str(p1) '\newline'];
% 	t=[t 'BS Rank: ' num2str(p2)];
	
	if suba>1
		subplot(2,2,4);
	else
		subplot(1,2,2);
	end
	plot(xax,fx,'k-','linewidth',1.5);
	hold on
	plot(yax,fy,'r-','linewidth',1.5);
	hold off
	axis tight
	box off
	
	if size(x,2)>1; 
		if ~isempty(columnlabels)
			supt=['Column: ' columnlabels{i} ' | n = ' num2str(length(xcol)) '[' num2str(length(x(:,i))) '] & ' num2str(length(ycol)) '[' num2str(length(y(:,i))) ']'];
		else
			supt=['Column: ' num2str(i) ' | n = ' num2str(length(xcol)) '[' num2str(length(x(:,i))) '] & ' num2str(length(ycol)) '[' num2str(length(y(:,i))) ']'];
		end
	else
		supt=['# = ' num2str(length(xcol)) '[' num2str(length(x(:,i))) '] & ' num2str(length(ycol)) '[' num2str(length(y(:,i))) ']'];
	end
	
	if ~isempty(xouttext) && ~strcmp(xouttext,' ') && length(xouttext)<25
		supt=[supt ' | ' dooutlier ': 1 = ' xouttext];
	end
	if ~isempty(youttext) && ~strcmp(youttext,' ') && length(xouttext)<25
		supt=[supt ' | 2 = ' youttext];
	end
	
	suptitle(supt)

	xl=xlim;
	yl=ylim;

	xfrag=(xl(2)-xl(1))/40;
	yfrag=(yl(2)-yl(1))/40;

	h=line([xci(1),xmean,xci(2);xci(1),xmean,xci(2);],[yl(1),yl(1),yl(1);yl(2),yl(2),yl(2)]);
	set(h,'Color',[0.5 0.5 0.5],'LineStyle','--');

	h=line([yci(1),ymean,yci(2);yci(1),ymean,yci(2);],[yl(1),yl(1),yl(1);yl(2),yl(2),yl(2)]);
	set(h,'Color',[1 0.5 0.5],'LineStyle',':');

	text(xl(1)+xfrag,yl(2)-yfrag,t,'FontSize',8,'FontName','arial','FontWeight','bold','VerticalAlignment','top');
	%legend(legendtxt);
end;
end