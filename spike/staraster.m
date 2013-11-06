function staraster(X,range,n)
%STARASTER Raster plot of an input data structure.
%   STARASTER(X) makes a raster plot of an input data
%   structure X. The horizontal range is set to include all of the
%   data in X. If X contains a multisite data structure, the raster
%   for each site is plotted in a separate figure window.
%
%   STARASTER(X,RANGE) enables the user to set the range. RANGE
%   must be in seconds.
%
%   STARASTER(X,RANGE,N) plots a raster for only the Nth site in
%   the current figure window.
%
%   See also STAREAD.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
if(nargin<2 | isempty(range))
  idx=1;
  for m=1:X.M
    for p = 1:X.categories(m).P
      for n = 1:X.N
        mins(idx) = X.categories(m).trials(p,n).start_time;
        maxes(idx) = X.categories(m).trials(p,n).end_time;
      end
    end
  end
  range(1) = min(mins);
  range(2) = max(maxes);
  range = X.sites(n).time_scale*range;
end

if(nargin<3 && X.N>1)
  for n=1:X.N
    figure;
    plot_raster(X,range,n)
  end
elseif (nargin<3 && X.N==1)
  plot_raster(X,range,1);
else
  plot_raster(X,range,n);
end

function plot_raster(X,range,n)
shuffledraw = false;
%%% Now make the plot
idx=1;
cla;
hold on;
colororder = get(gca,'colororder');
num_colors = size(colororder,1);
for m=1:X.M
  cur_color = colororder(mod(m-1,num_colors)+1,:);
  cur_start = idx;
  p = 1:X.categories(m).P;
  shufp = Shuffle(p);
  for p = 1:X.categories(m).P;
	  if shuffledraw == false;
		  list = X.sites(n).time_scale*X.categories(m).trials(p,n).list; 
		  h = plot(list,idx*ones(size(list)),'.','Color',cur_color,'MarkerSize',9);
		  idx=idx+1;
	  else
		  list = X.sites(n).time_scale*X.categories(m).trials(shufp(p),n).list; 
		  h = plot(list,idx*ones(size(list)),'.','Color',cur_color,'MarkerSize',9);
		  idx=idx+1;
	  end
  end
  cur_end = idx;
  h = text(((range(2)-range(1))/4)+range(1),(cur_start+cur_end)/2,X.categories(m).label);
  set(h,'verticalalignment','middle','horizontalalignment','center');
  set(h,'FontName','Georgia','FontSize',11);
end
hold off;
set(gcf,'Renderer','painters')
box on;
xlabel('Time (sec)');
ylabel('Trial');
title(strrep(X.sites(n).label,'_','\_'));
set(gca,'ylim',[0 idx]);
set(gca,'ydir','rev');
set(gca,'xlim',[range(1) range(2)]);
set(gca,'xtick',unique([get(gca,'xtick') range]));
