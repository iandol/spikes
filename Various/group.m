function [out,out2,out3,uni]=group(x,y,z,strings)

if size(x,2)>1
	x=x';
end
if size(y,2)>1
	y=y';
end
if nargin>2 && iscell(z)
	strings=z;
	z=[];
end
if size(z,2)>1
	z=z';
end

if nargin>2 && (length(strings)==2 || length(strings)==3)
	[out2{1:length(x)}]=deal(strings{1});
	[out2{length(x)+1:length([x;y])}]=deal(strings{2});
	out=vertcat(x,y);
	if ~isempty(z)
		[out2{length([x;y])+1:length([x;y;z])}]=deal(strings{3});
		out=vertcat(out,z);
	end
	out2=out2';
else
	if ~iscell(y)
		y=cellstr(y);
	end
	uni=unique(y);
	if length(uni)>1
		idx1=find(strcmp(y,uni(1)));
		idx2=find(strcmp(y,uni(2)));
		out=x(idx1);
		out2=x(idx2);
		if length(uni)==3
			idx3=find(strcmp(y,uni(3)));
			out3=x(idx3);
		else
			out3=[];
		end
	else
		error('sorry, only 2/3 groups currently supported');
	end
end
	
	

