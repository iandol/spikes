function h = lsqline
% LSLINE Add least-squares fit line to scatter plot.

lh = findobj(get(gca,'Children'),'Type','line');
if nargout == 1, 
   h = [];
end
count = 0;
for k = 1:length(lh)
    xdat = get(lh(k),'Xdata');
    ydat = get(lh(k),'Ydata');
    datacolor = get(lh(k),'Color');
    style = get(lh(k),'LineStyle');
    if ~strcmp(style,'-') & ~strcmp(style,'--') & ~strcmp(style,'-.')
       count = count + 1;
       beta = polyfit(xdat,ydat,1);
       newline = refline(beta);
       set(newline,'Color',datacolor);
       if nargout == 1
           h(count) = newline;    
       end
   end
end
if count == 0
   disp('No allowed line types found. Nothing done.');
end
