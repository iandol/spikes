classdef getDensity < handle
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
	
	properties
		x = []
		y = []
		%> number of bootstrap iterations default: 1000
		nboot = 1000
		%> function handle to bootstrap default: @mean
		fhandle = @mean
		%> P value to use for all statistics
		alpha = 0.05
		%> A cell list of the main X and Y data, i.e. {'Control','Drug'}
		legendtxt = {'Group 1','Group 2'}
		%> Add gaussian fits to the histograms? default: true
		dogauss = true
		%> if X/Y have more than 1 column, you can detail column names here
		columnlabels = {'Data Set 1'}
		%> remove outliers using 'grubb', 'rosner', 3SD' or 'none'
		dooutlier = 'none'
		%> add jitter to scatterplot? 'x', 'y', 'both', 'equal', 'none'
		addjitter = 'none'
		%>  celllist of case names the same length as X/Y
		cases = []
		%> are our cases nominal or ordinal?
		nominalcases = true
		rownames = []
		%> rosner outlier number of outliers
		rosnern = 2 
		%> p to use for outlier removal for rosner and grubb
		outlierp = 0.001 
		%> scalefactor for jitter of scatter plot
		jitterfactor = 100 
		%> do we spit out each plot in its own figure for easy export?
		singleplots = false
		%> do we show the original points in the scatter before scattering them?
		showoriginalscatter = false
		autorun = false
		bartype = 'grouped'
		barwidth = 1.25
		verbose = true
		comment = ''
		%> do we scale the axes to be equal for the scatterplots
		scaleaxes = true
		%> do we show the unity line for the scatterplot?
		showunityline = true
	end
	
	properties (Dependent = true, SetAccess = private, GetAccess = public)
		isDataEqualLength = true;
		nColumns = []
		plotX = 2 %the layout when plotting mutliple plots
		plotY = 2 % layout when plotting mutliple plots
		uniquecases = []
	end
	
	properties (SetAccess = private, GetAccess = public)
		runStructure
		h
		pn
	end
	
	properties (SetAccess = private, GetAccess = private)
		allowedProperties = []
		ignoreProperties = '(isDataEqualLength|nColumns|uniquecases|runStructure|h|pn|plotX|plotY)';
	end
	
	events (Hidden = false, ListenAccess = private, NotifyAccess = private)
		checkData %trigger this event to perform checks on data and cases etc.
	end
	
	%=======================================================================
	methods %------------------PUBLIC METHODS
	%=======================================================================
		
		% ===================================================================
		%> @brief Class constructor
		%>
		%> More detailed description of what the constructor does.
		%>
		%> @param args are passed as a structure of properties which is
		%> parsed.
		%> @return instance of class.
		% ===================================================================
		function obj = getDensity(varargin)
			if nargin>0
				obj.parseArgs(varargin, obj.allowedProperties);
			end
			
			addlistener(obj,'checkData',@obj.doCheckData); %use an event to keep data accurate
			
			if obj.autorun == true && obj.haveData == true
				obj.run;
			end
		end
		
		% ===================================================================
		%> @brief Our main RUN method
		%>
		%> This performs the analysis and plots the results for the stored data.
		%>
		%> @param obj the class object automatically passed in
		%> @return outs a structure with the analysis results if needed.
		% ===================================================================
		function outs = run(obj)
			if isempty(obj.x)
				error('You haven''t supplied any data yet!')
			end
			for i = 1: obj.nColumns
				tic
				xcol=obj.x(:,i);
				ycol=obj.y(:,i);
				cases = obj.cases;
				uniquecases = obj.uniquecases;
				
				outs.x = obj.x;
				outs.y = obj.y;
				outs.cases = cases;
				
				xouttext='';
				youttext='';
				
				fieldn = obj.columnlabels{i};
				fieldn = regexprep(fieldn,'\s+','_');
				
				h=figure;
				outs.(fieldn).h = h;
				set(h,'Color',[0.9 0.9 0.9])
				
				if obj.isDataEqualLength == false
					figpos(3,[600 1200]);
				else
					figpos(1,[1200,1000]);
				end
				
				pn = panel();
				pn.pack(obj.plotY,obj.plotX);
				
				if max(isnan(xcol)) == 1 %remove any nans
					xcol = xcol(isnan(xcol)==[]);
				end
				if max(isnan(ycol)) == 1
					ycol = ycol(isnan(ycol)==0);
				end
				
				xmean=nanmean(xcol); %initial values before outlier removal
				ymean=nanmean(ycol);
				xstd=nanstd(xcol);
				ystd=nanstd(ycol);
				
				switch obj.dooutlier
					case 'quantiles'
						idx1=qoutliers(xcol);
						idx2=qoutliers(ycol);
						if length(xcol)==length(ycol)
							idx=idx1+idx2;
							xouttext=sprintf('%0.3g ',xcol(idx>0)');
							youttext=sprintf('%0.3g ',ycol(idx>0)');
							xcol(idx>0)=[];
							ycol(idx>0)=[];
							cases(idx>0)=[];
						else
							xouttext=sprintf('%0.3g ',xcol(idx1>0)');
							youttext=sprintf('%0.3g ',ycol(idx2>0)');
							xcol(idx1>0)=[];
							ycol(idx2>0)=[];
						end
					case 'rosner'
						idx1=outlier(xcol,obj.outlierp,obj.rosnern);
						idx2=outlier(ycol,obj.outlierp,obj.rosnern);
						if ~isempty(idx1) || ~isempty(idx2)
							if length(xcol)==length(ycol)
								idx=unique([idx1;idx2]);
								xouttext=sprintf('%0.3g ',xcol(idx)');
								youttext=sprintf('%0.3g ',ycol(idx)');
								xcol(idx)=[];
								ycol(idx)=[];
								if ~isempty(cases); cases(idx)=[]; end
							else
								xouttext=sprintf('%0.3g ',xcol(idx1)');
								youttext=sprintf('%0.3g ',ycol(idx2)');
								xcol(idx1)=[];
								ycol(idx2)=[];
							end
						end
					case 'grubb'
						[~,idx1]=deleteoutliers(xcol,obj.outlierp);
						[~,idx2]=deleteoutliers(ycol,obj.outlierp);
						if length(xcol)==length(ycol)
							idx=unique([idx1;idx2]);
							xouttext=sprintf('%0.3g ',xcol(idx)');
							youttext=sprintf('%0.3g ',ycol(idx)');
							xcol(idx)=[];
							ycol(idx)=[];
							if ~isempty(cases); cases(idx)=[]; end
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
							if ~isempty(cases); cases(idx>0)=[]; end
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
							if ~isempty(cases); cases(idx>0)=[]; end
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
				pn(1,1).select();
				
				if ystd > 0
					h=bar([hbins',hbins'],[xn',yn'],obj.barwidth,obj.bartype);
					set(h(1),'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
					set(h(2),'FaceColor',[0.7 0 0],'EdgeColor',[0.7 0 0]);
				else
					h=bar([hbins'],[xn'],obj.barwidth,obj.bartype);
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
				if obj.dogauss == true
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
				
				pn(1,1).xlabel(obj.columnlabels{i});
				pn(1,1).ylabel('Number of cells');
				
				if obj.isDataEqualLength && exist('distributionPlot','file')
					pn(1,2).select()
					hold on
					distributionPlot({xcol,ycol},0.3);
					pn(1,2).ylabel(obj.columnlabels{i});
				elseif obj.isDataEqualLength==false && exist('distributionPlot','file')
					pn(2,1).select()
					hold on
					distributionPlot({xcol,ycol},0.3);
					pn(2,1).ylabel(obj.columnlabels{i});
				end
				if obj.isDataEqualLength
					boxplot([xcol,ycol],'notch',1,'whisker',1,'labels',obj.legendtxt,'colors','k')
				end
				title('Box / Density Plots')
				hold off
				box on
				
				xcolout = xcol;
				ycolout = ycol;
				
				if ystd > 0 && obj.isDataEqualLength
					pn(2,1).select()
					[r,p]=corr(xcol,ycol);
					[r2,p2]=corr(xcol,ycol,'type','spearman');
					xrange = max(xcol) - min(xcol);
					yrange = max(ycol) - min(ycol);
					range = max(xrange,yrange);
					xjitter = (randn(length(xcol),1))*(xrange/obj.jitterfactor);
					yjitter = (randn(length(ycol),1))*(yrange/obj.jitterfactor);
					bothjitter = (randn(length(xcol),1))*(max(xrange,yrange)/obj.jitterfactor);
					if obj.addjitter == true
						obj.addjitter = 'both';
					end
					switch obj.addjitter
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
					
					if obj.scaleaxes == true
						axrange = [(mn - (mn/20)) (mx + (mx/20)) (mn - (mn/20)) (mx + (mx/20))];
					else
						axrange = [min(xcol) min(xcol)+range min(ycol) min(ycol)+range];
					end
					
					if ~isempty(cases)
						t = 'Group: ';
						for jj = 1:length(uniquecases)
							t = [t num2str(jj) '=' uniquecases{jj} ' '];
						end
					else
						colours = [0 0 0];
						t = '';
					end
					
					hold on
					if ~isempty(cases)
						gscatter(xcolout,ycolout,cases,'krbgmyc','o');
					else
						scatter(xcolout,ycolout,repmat(80,length(xcol),1),[0 0 0]);
					end
					try %#ok<TRYNC>
						h = lsline;
						set(h,'LineStyle','--','LineWidth',2)
						if obj.showunityline == true
							if abs(r2) < 0.1
								h = line([mn mx],[mn mx]);
								set(h,'Color',[0.7 0.7 0.7],'LineStyle','-.','LineWidth',2)
								h = line([mx mn],[mn mx]);
								set(h,'Color',[0.7 0.7 0.7],'LineStyle','-.','LineWidth',2)
							elseif r2 >= 0
								h = line([mn mx],[mn mx]);
								set(h,'Color',[0.7 0.7 0.7],'LineStyle','-.','LineWidth',2)
							else
								h = line([mx mn],[mn mx]);
								set(h,'Color',[0.7 0.7 0.7],'LineStyle','-.','LineWidth',2)
							end
						end
					end
					if sc == true && obj.showoriginalscatter == true
						scatter(xcol,ycol,repmat(80,length(xcol),1),'ko','MarkerEdgeColor',[0.7 0.7 0.7]);
					end
					axis square
					axis(axrange);
					if obj.scaleaxes == true
						set(gca,'XTick',get(gca,'YTick'),'XTickLabel',get(gca,'YTickLabel'));
					end
					pn(2,1).xlabel(obj.legendtxt{1})
					pn(2,1).ylabel(obj.legendtxt{2})
					pn(2,1).title(['Prson:' sprintf('%0.2g',r) '(p=' sprintf('%0.4g',p) ') | Spman:' sprintf('%0.2g',r2) '(p=' sprintf('%0.4g',p2) ') ' t]);
					hold off
					grid on
					box on
					set(gca,'Layer','top');
				end
				
				%============================Lets measure statistics
				
				t=['Mn/Mdn: ' sprintf('%0.3g', xmean) '\pm' sprintf('%0.3g', xstderr) '/' sprintf('%0.3g', xmedian) ' | ' sprintf('%0.3g', ymean) '\pm' sprintf('%0.3g', ystderr) ' / ' sprintf('%0.3g', ymedian)];
				
				if ystd > 0
					if length(xcol) == length(ycol)
						[h,p1]=ttest2(xcol,ycol,obj.alpha);
					else
						[h,p1]=ttest2(xcol,ycol,obj.alpha);
					end
					[p2,h]=ranksum(xcol,ycol,'alpha',obj.alpha);
					if obj.isDataEqualLength
						[h,p3]=ttest(xcol,ycol,obj.alpha);
						[p4,h]=signrank(xcol,ycol,'alpha',obj.alpha);
						[p5,h]=signtest(xcol,ycol,'alpha',obj.alpha);
					else
						p3 = [];
						p4 = [];
						p5 = [];
					end
					[h,p6]=jbtest(xcol,obj.alpha);
					[h,p7]=jbtest(ycol,obj.alpha);
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
					[h,p10]=kstest2(xcol,ycol,obj.alpha);
				else
					[h,p1]=ttest(xcol,obj.alpha);
					[p2,h]=signrank(xcol,0,'alpha',obj.alpha);
					p3=[];
					p4=[];
					[p5,h]=signtest(xcol,0,'alpha',obj.alpha);
					[h,p6]=jbtest(xcol,obj.alpha);
					p7=0;
					if length(xcol)>4
						[h,p8]=lillietest(xcol);
					else
						p8=NaN;
					end
					p9=[];
					p10=kstest(xcol);
				end
				
				outs.(fieldn).ttest = p1;
				outs.(fieldn).ranksum = p2;
				outs.(fieldn).ttest2 = p3;
				outs.(fieldn).signrank = p4;
				outs.(fieldn).signtest = p5;
				outs.(fieldn).jbtestx = p6;
				outs.(fieldn).jbtesty = p7;
				outs.(fieldn).lillietestx = p8;
				outs.(fieldn).lillietesty = p9;
				outs.(fieldn).kstest = p10;
				
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
				
				[xci,xmean,xpop]=bootci(obj.nboot,{obj.fhandle,xcol},'alpha',obj.alpha);
				[yci,ymean,ypop]=bootci(obj.nboot,{obj.fhandle,ycol},'alpha',obj.alpha);
				
				t=[t 'BootStrap: ' sprintf('%0.2g', xci(1)) ' < ' sprintf('%0.2g', xmean) ' > ' sprintf('%0.2g', xci(2)) ' | ' sprintf('%0.2g', yci(1)) ' < ' sprintf('%0.2g', ymean) ' > ' sprintf('%0.2g', yci(2))];
				
				[fx,xax]=ksdensity(xpop);
				[fy,yax]=ksdensity(ypop);
				
				if obj.isDataEqualLength
					pn(2,2).select();
				else
					pn(3,1).select();
				end
				
				plot(xax,fx,'k-','linewidth',1.5);
				if ystd > 0
					hold on
					plot(yax,fy,'r-','linewidth',1.5);
					hold off
				end
				axis tight
				title(['BootStrap Density Plots; using: ' func2str(obj.fhandle)]);
				box on
				set(gca,'Layer','top');
				
				supt=[obj.columnlabels{i} ' # = ' num2str(length(xcol)) '[' num2str(length(obj.x(:,i))) '] & ' num2str(length(ycol)) '[' num2str(length(obj.y(:,i))) ']'];
				
				if ~isempty(xouttext) && ~strcmp(xouttext,' ') && length(xouttext)<25
					supt=[supt ' | ' obj.dooutlier ': 1 = ' xouttext];
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
				%legend(obj.legendtxt);
				
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
				
				set(gcf,'Renderer','zbuffer');
				
				fprintf('\n---> getDensity Computation time took: %d seconds\n',toc);
				
				if obj.singleplots == true
					obj.doSinglePlots(pn);
				end
				
				if ~isempty(uniquecases) && ~isempty(cases)
					for jj = 1:length(uniquecases)
						caseidx = ismember(cases,uniquecases{jj});
						xtmp = xcol(caseidx);
						ytmp = ycol(caseidx);
						name = ['Case_' uniquecases{jj}];
						otmp = obj.toStructure();
						otmp.x = xtmp;
						otmp.y = ytmp;
						otmp.cases = cell(0,0);
						otmp.columnlabels{1} = [otmp.columnlabels{i} ' ' name];
						otmp.autorun = false;
						otmp.verbose = false;
						gdtmp = getDensity(otmp);
						outtmp = gdtmp.run;
						outs.(fieldn).(name)=outtmp;
					end
					figure(outs.(fieldn).h);
				end
			end
			obj.runStructure = outs;
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param obj this instance object
		% ===================================================================
		function value = get.nColumns(obj)
			value = size(obj.x,2);
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param obj this instance object
		% ===================================================================
		function value = get.isDataEqualLength(obj)
			if size(obj.x,1) == size(obj.y,1)
				value = true;
			else
				value = false;
			end
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param obj this instance object
		% ===================================================================
		function value = get.plotX(obj)
			if obj.isDataEqualLength
				value = 2;
			else
				value = 1;
			end
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param obj this instance object
		% ===================================================================
		function value = get.plotY(obj)
			if obj.isDataEqualLength
				value = 2;
			else
				value = 3;
			end
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param obj this instance object
		% ===================================================================
		function value = get.uniquecases(obj)
			if ~isempty(obj.cases)
				value = getlabels(obj.cases);
			else
				value = [];
			end
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param obj this instance object
		% ===================================================================
		function set.x(obj,value)
			if size(value,1)==1
				value=value';
			end
			
			obj.x = value;
			
			notify(obj,'checkData');
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param obj this instance object
		% ===================================================================
		function set.y(obj,value)
			if size(value,1)==1
				value=value';
			end
			
			obj.y = value;
			
			notify(obj,'checkData');
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param obj this instance object
		% ===================================================================
		function set.cases(obj,value)
			if length(value) ~= length(obj.x(:,1))
				obj.cases = [];
			else
				if size(value,2) > size(value,1)
					value = value';
				end
				for ii = 1:length(value)
					value{ii}=regexprep(value{ii},'^\?$','Unknown');
					value{ii}=regexprep(value{ii},'\W','_');
				end
				if obj.nominalcases == true
					obj.cases = nominal(value);
				else
					obj.cases = ordinal(value);
				end
			end
			notify(obj,'checkData');
		end
		
		% ===================================================================
		%> @brief
		%>
		%> @param obj this instance object
		% ===================================================================
		function ret = haveData(obj)
			if isempty(obj.x)
				ret = false;
			else
				ret = true;
			end
		end
	end
	
	%=======================================================================
	methods ( Access = private ) %-------PRIVATE (protected) METHODS-----%
	%=======================================================================
		
		function doSinglePlots(obj,pn)
			if obj.isDataEqualLength;
				h = figure;
				figpos(1,[800 640]);
				set(h,'Color',[0.9 0.9 0.9])
				p = copyobj(pn(1,1).axis,h);
				set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
				set(gcf,'Renderer','zbuffer');
				h = figure;
				figpos(1,[800 640]);
				set(h,'Color',[0.9 0.9 0.9])
				p = copyobj(pn(1,2).axis,h);
				set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
				set(gcf,'Renderer','zbuffer');
				h = figure;
				figpos(1,[800 640]);
				set(h,'Color',[0.9 0.9 0.9])
				p = copyobj(pn(2,1).axis,h);
				set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
				set(gcf,'Renderer','zbuffer');
				h=figure;
				figpos(1,[800 640]);
				set(h,'Color',[0.9 0.9 0.9])
				p = copyobj(pn(2,2).axis,h);
				set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
				set(gcf,'Renderer','zbuffer');
			else
				h = figure;
				figpos(1,[800 640]);
				set(h,'Color',[0.9 0.9 0.9])
				p = copyobj(pn(1,1).axis,h);
				set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
				set(gcf,'Renderer','zbuffer');
				h = figure;
				figpos(1,[800 640]);
				set(h,'Color',[0.9 0.9 0.9])
				p = copyobj(pn(2,1).axis,h);
				set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
				set(gcf,'Renderer','zbuffer');
				h = figure;
				figpos(1,[800 640]);
				set(h,'Color',[0.9 0.9 0.9])
				p = copyobj(pn(3,1).axis,h);
				set(p,'Units','Normalized','OuterPosition',[0.01 0.01 0.9 0.9]);
				set(gcf,'Renderer','zbuffer');
			end
		end
		
		% ===================================================================
		%> @brief Function that runs after the checkData event fires
		%>
		%> @param obj this instance object
		% ===================================================================
		function doCheckData(obj, src, evnt)
			obj.salutation([evnt.EventName ' event'],'Event is running...');
			if isempty(obj.y)
				obj.y = zeros(size(obj.x));
			end
			if size(obj.x,2) > length(obj.columnlabels)
				for i = length(obj.columnlabels)+1 : size(obj.x,2)
					obj.columnlabels{i} = ['DataSet_' num2str(i)];
				end
			end
			if isempty(obj.cases) && ~isempty(obj.uniquecases)
				obj.uniquecases = [];
			end
		end
		
		% ===================================================================
		%> @brief Converts properties to a structure
		%>
		%>
		%> @param obj this instance object
		%> @return out the structure
		% ===================================================================
		function out=toStructure(obj)
			out = struct();
			fn = fieldnames(obj);
			for j=1:length(fn)
				out.(fn{j}) = obj.(fn{j});
			end
		end
		
		% ===================================================================
		%> @brief Prints messages dependent on verbosity
		%>
		%> Prints messages dependent on verbosity
		%> @param obj this instance object
		%> @param in the calling function
		%> @param message the message that needs printing to command window
		% ===================================================================
		function salutation(obj,in,message)
			if obj.verbose==true
				if ~exist('in','var')
					in = 'undefined';
				end
				if exist('message','var')
					fprintf(['---> getDensity: ' message ' | ' in '\n']);
				else
					fprintf(['---> getDensity: ' in '\n']);
				end
			end
		end
		
		% ===================================================================
		%> @brief Sets properties from a structure or normal arguments,
		%> ignores invalid properties
		%>
		%> @param args input structure
		%> @param allowedProperties properties possible to set on construction
		% ===================================================================
		function parseArgs(obj, args, allowedProperties)
			
			%lets make allowedProperties from the class properties
			if ~exist('allowedProperties','var') || isempty(allowedProperties)
				ptmp = properties(mfilename);
				otmp = '';
				for i = 1:length(ptmp)
					if isempty(regexpi(ptmp{i},obj.ignoreProperties))
						if i == 1
							otmp = ptmp{i};
						else
							otmp = [otmp '|' ptmp{i}];
						end
					end
				end
				allowedProperties = otmp;
			end
			
			allowedProperties = ['^(' allowedProperties ')$'];
			
			while iscell(args) && length(args) == 1
				args = args{1};
			end
			
			if iscell(args)
				if mod(length(args),2) == 1 % odd
					args = args(1:end-1); %remove last arg
				end
				odd = logical(mod(1:length(args),2));
				even = logical(abs(odd-1));
				args = cell2struct(args(even),args(odd),2);
			end
			
			if isstruct(args)
				fnames = fieldnames(args); %find our argument names
				for i=1:length(fnames);
					if ~isempty(regexp(fnames{i},allowedProperties, 'once')) && isempty(regexp(fnames{i},obj.ignoreProperties, 'once')) %only set if allowed property
						obj.salutation(fnames{i},'Configuring setting in constructor');
						obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
					end
				end
			end
			
		end
		
	end
	
end

