function tickdir(in)

if strcmp(in,'in')
    set(gca,'TickDir','in')
elseif strcmp(in,'out')
    set(gca,'TickDir','out')
else
    errordlg('You need to specify ''in'' or ''out'' for the tick direction')
    error('Input error')
end