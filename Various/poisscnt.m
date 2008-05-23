function [cnt, pd] = poisscnt(mrate,interval,maxcount)
% poisscnt: function which returns the probability density for the
% distribution of the spike count of a Poisson process in a fixed time
% interval. If called without output arguments, the probability
% distribution is plotted.
%
%       [cnt, pd] = poisscnt(mrate,interval,maxcount)
%
%       where
%         mrate = mean rate of the Poisson process [Hz]
%         interval = the length of the interval (in msec)
%         maxcount = maximal count taken into account
%
% The return parameters are:
%       cnt = vector of spike counts.
%       pd = corresponding probability distribution.
%
% For an I&F neuron with exponentially distributed threshold under
% constant current injection, the mean rate is given by I/CVthres.
%
%

if ( nargin ~= 3 )
  disp(' ');
  disp('usage: poisscnt(mrate,interval,maxcount) ');
  disp('       for more information type "help poisscnt" in the main');
  disp('       matlab window');
  disp(' ');
  return;
end;

%initializes the various variables
lambda = mrate*interval*1e-3;

cnt = (0:1:maxcount)';
pd = zeros(maxcount+1,1);

pd(1) = exp(-lambda);
for k = 2:maxcount+1
    pd(k) = lambda/cnt(k)*pd(k-1);
end;

if ( nargout == 0 )
%looks for the figure 'countprob', otherwise creates it
%and sets it to current
  fig_name = 'countprob';
  Figures = get(0,'Chil');
  new_fig = 1;
  for i=1:length(Figures)
    if strcmp(get(Figures(i),'Type'),'figure')
      if strcmp(get(Figures(i),'Name'),fig_name)
        new_fig = 0;
        h_fig = Figures(i);
        set(0,'CurrentFigure',h_fig);
      end;
    end;
  end;
  if (new_fig == 1)
    h_fig = figure('Name',fig_name);
  end;

%sets decorations and plots the isi distribution
  plot(cnt,pd,'g--');
  titt = sprintf('Spike count distribution for an interval of %g
[msec]',...
          interval);
  title(titt);
  xlabel('spike count');
  ylabel('probability');
  clear cnt, pd;
end;


