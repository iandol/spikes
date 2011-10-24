function varargout=notBoxPlot(y,x,jitter,style,colour,options)
% notBoxPlot - Doesn't plot box plots!
%
% function notBoxPlot(y,x,jitter,style)
%
% Purpose
% An alternative to a box plot, where the focus is on showing raw
% data. Plots columns of y as different groups located at points
% along the x axis defined by the optional vector x. Points are
% layed over a 1.96 SEM (95% confidence interval) in red and a 1 SD
% in blue. The user has the option of plotting the SEM and SD as a
% line rather than area. Raw data are jittered along x for clarity.
%
% Inputs
% y - each column of y is one variable/group. If x is missing or empty
%     then each column is plotted in a different x position.
% x - optional, x axis points at which y columns should be
%     plotted. This allows more than one set of y values to appear
%     at one x location. Such instances are coloured differently.
% jitter - how much to jitter the data for visualization (optional).
% style - a string defining plot style. 'patch' by default. 'line' will
% create a plot where the SD and SEM are constructed from lines. 'sdline'
% will replace only the SD with a line.
%
% Outputs
% H - structure of handles for plot objects.
%
%
% Example 1 - simple example
% clf
% subplot(2,1,1)
% notBoxPlot(randn(20,5));
% subplot(2,1,2)
% h=notBoxPlot(randn(10,40));
% d=[h.data];
% set(d(1:4:end),'markerfacecolor',[0.4,1,0.4],'color',[0,0.4,0])
%
% Example 2 - overlaying with areas
% clf
% x=[1,2,3,4,5,5];
% y=randn(20,length(x));
% y(:,end)=y(:,end)+3;
% y(:,end-1)=y(:,end-1)-1;
% notBoxPlot(y,x);
%
% Example 3 - lines
% clf
% H=notBoxPlot(randn(20,5),[],[],'line');
% set([H.data],'markersize',10)
%
% Example 4 - mix lines and areas [note that the we this function
% sets the x axis limits can cause problems when combining plots
% this way]
%
% clf
% h=notBoxPlot(randn(10,1)+4,5,[],'line');
% set(h.data,'color','m')
% h=notBoxPlot(randn(50,10));
% set(h(5).data,'color','m')
%
% Rob Campbell - January 2010
%
% also see: boxplot


% Check input arguments
error(nargchk(1,6,nargin))

if nargin<2 || isempty(x)
	if isvector(y), y=y(:); end
	x=1:size(y,2);
end

if length(x) ~= size(y,2)
	error('length of x doesn''t match the number of columns in y')
end

if nargin<3 || isempty(jitter)
	jitter=0.5;
end

if nargin<4 || isempty(style)
	style='patch'; %Can also be 'line' or 'sdline'
end
style=lower(style);

if nargin<5 || isempty(colour)
	colour=[0 0 0]; %Can also be 'line' or 'sdline'
end

if nargin < 6 || ~iscell(options)
	options = [];
end

if iscell(options) || length(options) == 1
	options = options{1};
end

edgepos = 0.3;


%We're going to render points with the same x value in different
%colors so we loop through all unique x values and do the plotting
%with nested functions. We don't clf in order to give the user more
%flexibility in combining plot elements.
hold on
[uX,a,b]=unique(x);

h=[];
for ii=1:length(uX)
	f=find(b==ii);
	h=[h,myPlotter(x(f),y(:,f))];
end

hold off

%Tidy up plot - make it look pretty, although this may cause
%problems when combining multiple plots on one axis.
set(gca,'XTick',unique(x))
xlim([min(x)-1,max(x)+1])

if nargout==1
	varargout{1}=h;
end



%Nested functions follow


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function h=myPlotter(X,Y)
		
		%Require the stats toolbox
		
		if isempty(options)
			SEM = SEM_calc(Y);
			SD=nanstd(Y);
		elseif iscell(options)
			SEM = bootCI_calc(Y,options{1},options{2},options{3});
			SD=nanstd(Y);
			%SD = bootCI_calc(Y,options{1},options{2},0.0001);
		end
		
		mu=nanmean(Y);
		
		%The plot colors to use for multiple sets of points on the same x
		%location
		cols=hsv(length(X)+1)*0.5;
		cols(1,:)=0;
		for k=1:length(X)
			thisY=Y(:,k);
			thisY=thisY(~isnan(thisY));
			thisX=repmat(X(k),1,length(thisY));
			
			if strcmp(style,'patch')
				h(k).sdPtch=patchMaker(SD(k),[0.85,0.85,0.85]);
			end
			
			if strcmp(style,'patch') || strcmp(style,'sdline')
				
				h(k).semPtch=patchMaker(SEM(k),[0.9,0.7,0.7]);
				h(k).mu=plot([X(k)-edgepos,X(k)+edgepos],[mu(k),mu(k)],'-r',...
					'linewidth',2);
			end
			
			%Plot jittered raw data
			C=cols(k,:);
			J=(rand(size(thisX))-0.5)*jitter;
			h(k).data=plot(thisX+J,thisY,'o',...
				'color',C,...
				'markerfacecolor',C+(1-C)*0.8);
		end
		
		if strcmp(style,'line') || strcmp(style,'sdline')
			for k=1:length(X)
				%Plot SD
				h(k).sd=plot([X(k),X(k)],[mu(k)-SD(k),mu(k)+SD(k)],...
					'-','color',[0.2,0.2,1],'linewidth',2);
				set(h(k).sd,'ZData',[1,1]*-1)
			end
		end
		
		if strcmp(style,'line')
			for k=1:length(X)
				%Plot mean and SEM
				h(k).mu=plot(X(k),mu(k),'o','color','r',...
					'markerfacecolor','r',...
					'markersize',10);
				
				h(k).sem=plot([X(k),X(k)],[mu(k)-SEM(k),mu(k)+SEM(k)],'-r',...
					'linewidth',2);
				h(k).xAxisLocation=x(k);
			end
		end
		
		function ci = bootCI_calc(vect, nboot, fhandle, alpha)
			mm = fhandle(vect);
			xci = bootci(nboot,{fhandle,vect},'alpha',alpha);
			ci = xci;
			ci = [xci(1) mm xci(2)];
			ci = diff(ci);
			ci = max(ci);			
		end
		
		function ptch=patchMaker(thisInterval,color)
			if length(thisInterval) == 1
				l=mu(k)-thisInterval;
				u=mu(k)+thisInterval;
			else
				l=mu(k)-thisInterval(1);
				u=mu(k)+thisInterval(2);
			end
			ptch=patch([X(k)-edgepos, X(k)+edgepos, X(k)+edgepos, X(k)-edgepos],...
				[l,l,u,u], 0);
			set(ptch,'edgecolor','none','facecolor',color)
		end
		
		function sem=SEM_calc(vect, CI)
			% SEM_calc - standard error of the mean, confidence interval
			%
			% function sem=SEM_calc(vect, CI)
			%
			% Purpose
			% Calculate the standard error the mean to a given confidence
			% interval (CI). Note that nans do not contribute to the
			% calculation of the sample size and are ignored for the SD
			% calculation. Output of this function has been checked against
			% known working code written in R.
			%
			% Inputs
			% - vect: A vector upon which the SEM will be calculated. Note that
			%         if vect is a matrix then we calculate one SEM for each
			%         column.
			%
			% - CI [optional]: a p value for a different 2-tailed interval. e.g. 0.01
			%   This is a 2-tailed interval.
			%
			% Outputs
			% sem - the standard error of the mean. So to plot the interval it's mu-sem
			% to mu+sem.
			%
			% Example - plot a 1% interval [rather than the default %5]
			% r=randn(1,30);
			% S=SEM_calc(r,0.01);
			% hist(r)
			% hold on
			% plot(mean(r), mean(ylim),'r*')
			% plot([mean(r)-S,mean(r)+S], [mean(ylim),mean(ylim)],'r-')
			% hold off
			%
			% Rob Campbell
			%
			% Also see - tInterval_Calc, norminv
			
			error(nargchk(1,2,nargin))
			
			if isvector(vect)
				vect=vect(:);
			end
			
			
			if nargin==1
				stdCI = 1.96 ;
			elseif nargin==2
				CI = CI/2 ; %Convert to 2-tail
				stdCI = abs(norminv(CI,0,1)) ;
			end
			
			sem = ( (nanstd(vect)) ./ sqrt(sum(~isnan(vect))) ) * stdCI ;
		end
			
	end %function myPlotter
		
end %function notBoxPlot
