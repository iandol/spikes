function qplot()

% quickly loads dogfit data and does a percent suppression calculation 

[fn,pn]=uigetfile({'*.mat','Mat File (MAT)'},'Select File Type to Load:');
if isequal(fn,0)|isequal(pn,0);errordlg('No File Selected or Found!');error('File not selected');end
cd(pn);
in=load(fn);
in=in.fd;

x=in.x;
y=in.y;
if isfield(in,'e')
    e=in.e;
else
    e=zeros(size(x));
end

if x(1)==0
    s=y(1);
    y=y-s;
else
    errordlg('sorry, no 0 diameter, please calculate manually')
    s=0;
end
m=max(y);
f=find(y==max(y));
d=x(f);
yy=100-((y/m)*100);
ee=(e/m)*100;

h=figure;
areabar(x,yy,ee,[.7 .7 .7],'k-');
set(gca,'YDir','reverse');
title(in.title);
ylabel('Percentage Suppression');
xlabel('Diameter');

[a,b]=ginput(2);
b=mean(b);

o=[s,d,b]; %spontaneous - diameter - percent suppression

title([in.title ' ' num2str(o)])

s=[sprintf('%s\t',in.title),sprintf('%0.6g\t',o)];
clipboard('Copy',s);



