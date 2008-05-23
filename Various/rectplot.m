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

m=max(max(datamat));
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

if ~isempty(errormat)
	for i=1:length(xvals) %do our error patches first
		for j=1:length(yvals)
			xroot=i-1;
			yroot=j-1;
			scale=(1-datamat(j,i))*(seed/2);
			%error
			if ~isempty(errormat)
				err=errormat(j,i);
				xe=(xroot*seed)+scale-err;
				xxe=((xroot+1)*seed)-scale+err;
				ye=(yroot*seed)+scale-err;
				yye=((yroot+1)*seed)-scale+err;
				patch([xe xxe xxe xe],[ye ye yye yye],[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8],'LineWidth',0.5);
			end	
		end
	end
end

for i=1:length(xvals)
	for j=1:length(yvals)
		xroot=i-1;
		yroot=j-1;
		scale=(1-datamat(j,i))*(seed/2);
		
		x=(xroot*seed)+scale;
		xx=((xroot+1)*seed)-scale;
		y=(yroot*seed)+scale;
		yy=((yroot+1)*seed)-scale;
		
		alphaval=datamat(j,i);
		alphaval=alphaval+0.1;
		alphaval(alphaval>1)=1;

		patch([x xx xx x],[y y yy yy],[0 0 0],'FaceAlpha', alphaval,'EdgeColor','none');		
	end
end


