function isiplot(isib,isia,maxtime,trialplot,bisib,bisia)

% Plots out an ISI plot taking a vector of previous and subsequent ISI's
% for a spike train.

if size(isia)~=size(isib)
   errordlg('Sorry, you are trying to plot different ISI before and Afters')
   error('Input error')
end

if ~isempty(get(gh('silence'),'String'))
   before = str2num(get(gh('silence'),'String'));
   a      = str2num(get(gh('firstisi'),'String'));
   b      = str2num(get(gh('subsisi'),'String'));
   subs = max(a,b);
   zero = 0.5;
else
   before = 100;
   a      = 4;
   b      = 4;
   subs = max(a,b);
   zero = 0.5;
end

box on;
set(gca,'XScale','log');
set(gca,'YScale','log');
t=0.09;
hold on
axis([1 maxtime 1 maxtime]);
patch([before before maxtime maxtime],[t subs subs t], [1 0.9 0.7]);
patch([t t subs subs],[t subs subs t],[1 0.9 0.7]);

if trialplot==1
   if ~isempty(isia)
      scatter(isib(1),isia(1),15,[1 0 0],'filled');
      scatter(isib(2:end-1),isia(2:end-1),15,[0 0 0],'filled');
      scatter(isib(end),isia(end),15,[0 0 .7],'filled');
   end 
else
   scatter(isib,isia,15,[0 0 0],'filled');
   if nargin==6 & ~isempty(bisib)
      scatter(bisib,bisia,15,[1 0 0],'filled');    
   end
end
hold off

xlabel('Previous ISI (ms)');
ylabel('Subsequent ISI (ms)');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%GH Gets Handle From Tag
function [handle] = gh(tag)
	handle=findobj('Tag',tag);
%End of handle getting routine

