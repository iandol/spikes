function staplot(X,window,n)
%STAPLOT Plot of a continuous signal input data structure.
%   STAPLOT(X) makes a plot of a continuous signal input data
%   structure X. The horizontal range is set to include all of the
%   data in X. If X contains a multisite data structure, the plot for
%   each site is plotted in a separate figure window.
%
%   STAPLOT(X,WINDOW) enables the user to set the range. WINDOW must
%   be in seconds.
%
%   STAPLOT(X,WINDOW,N) plots only the Nth site in the current figure
%   window.
%
%   See also STAREAD and STARASTER.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%

if nargin<2 || isempty(window)
    idx = 1;
	for m=1:X.M
        for p = 1:X.categories(m).P
            for n = 1:X.N
                mins(idx) = X.categories(m).trials(p,n).start_time;
                maxes(idx) = X.categories(m).trials(p,n).end_time;
                idx = idx + 1;
            end
        end
    end
	window(1) = min(mins);
	window(2) = max(maxes);
	window = X.sites(n).time_scale*window;
end

if nargin<3 && X.N>1
	for n=1:X.N
        figure('Name','STAPLOT');
        make_plot(X,window,n)
	end
elseif nargin<3 && X.N==1
	make_plot(X,window,1);
else
	make_plot(X,window,n);
end

function make_plot(X,window,n)

%%% Now make the plot
hold on;
colororder = get(gca,'colororder');
num_colors = size(colororder,1);
y_offset = 0;
for m=1:X.M
	cur_color = colororder(mod(m-1,num_colors)+1,:);
	cur_start = y_offset;
	for p=1:X.categories(m).P
        times = X.categories(m).trials(p,n).start_time:X.sites(n).time_resolution:X.categories(m).trials(p,n).end_time;
        list = X.categories(m).trials(p,n).list;
        plot(times,list+y_offset,'color',cur_color);
        y_offset = y_offset + 0.1*range(list);
    end
	cur_end = y_offset;
    h = text(((window(2)-window(1))/4)+window(1),cur_start+(cur_end-cur_start)/2,X.categories(m).label);
	set(h,'verticalalignment','middle','horizontalalignment','center','backgroundcolor',[1 1 1]);
end
box on;
xlabel('Time (sec)');
ylabel(num2str(X.sites(n).si_prefix,['%1.1e ' X.sites(n).si_unit]));
title(strrep(X.sites(n).label,'_','\_'));
axis tight;
set(gca,'xlim',window);
set(gca,'xtick',unique([get(gca,'xtick') window]));
set(gca,'yticklabel',[]);
