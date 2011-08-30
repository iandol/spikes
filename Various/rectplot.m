function rectplot(xvals,yvals,datamat,errormat)

global sv;

if nargin == 1 %maybe just the matrix
	datamat=xvals;
	xvals=1:size(datamat,2);
	yvals=1:size(datamat,1);
end

if nargin<4
	errormat=[];
end

errorDisplay = 'center';

m=max(datamat(:));
sv.rectanglemax=m;
if m>0 datamat=datamat/m; errormat=errormat/m; end

seed=10;
axis equal;
axis([0 seed*length(xvals) 0 seed*length(yvals)]);

xticks=seed/2:seed:(length(xvals)*10)-seed/2;
yticks=seed/2:seed:(length(yvals)*10)-seed/2;

set(gca,'XTick',xticks);
set(gca,'YTick',yticks);

set(gca,'XTickLabel',num2str(xvals'));
set(gca,'YTickLabel',num2str(yvals'));

for i=1:length(xvals)
	for j=1:length(yvals)
		xroot=i-1;
		yroot=j-1;
		scale=(1-datamat(j,i))*(seed/2);
		
		x=(xroot*seed)+scale;
		xx=((xroot+1)*seed)-scale;
		y=(yroot*seed)+scale;
		yy=((yroot+1)*seed)-scale;
		if ~isempty(errormat)
			err=(1-errormat(j,i))*(seed/2);
			xe=(xroot*seed)+err;
			xxe=((xroot+1)*seed)-err;
			ye=(yroot*seed)+err;
			yye=((yroot+1)*seed)-err;
		end
		
		alphaval=datamat(j,i);
		alphaval=alphaval+0.1;
		alphaval(alphaval>1) = 1;
		colorval = repmat((1-alphaval),1,3);
		if max(colorval) <= 0.5
			colorvalerr = colorval + 0.1;
		else
			colorvalerr = colorval - 0.1;
		end
		patch([x xx xx x],[y y yy yy],colorval,'EdgeColor','none');
		patch([xe xxe xxe xe],[ye ye yye yye],colorvalerr,'EdgeColor',[1 0.5 0],'EdgeAlpha',0.1);
	end
end


