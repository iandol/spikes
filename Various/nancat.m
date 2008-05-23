function out=nancat(x,y)

%concatenate into columns adding NANs if needed

if length(x) == length(y)
	out=horzcat(x,y);
elseif length(x) > length(y)
	y(length(y)+1:length(x))=nan;
	out=horzcat(x,y);
else
	x(length(x)+1:length(y))=nan;
	out=horzcat(x,y);
end
