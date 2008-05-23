function [m,e]=makemean(file,err)
% makes the mean and error, either SE SD 2SD 3SD 2SE for text file, tab delimited

dlmread(file,'\t');
o=ans(:,1);
mm=ans(:,2);
p=ans(:,3);
%mp=ans(:,4);
[m(1),e(1)]=stderr(o,err);
[m(2),e(2)]=stderr(mm,err);
[m(3),e(3)]=stderr(p,err);
%[m(4),e(4)]=stderr(mp,err);

m=m';
e=e';