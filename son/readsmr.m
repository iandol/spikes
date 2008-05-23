fid=fopen('c:\temp\BBBBBB06.SMR');
l=SONChanList(fid);

for i=1:length(l)
	num(i)=l(i).number;
end

if num(end)==16
	num=num(1:end-1);
end

if num(end)==15
	num=num(1:end-1);
end

if num(end)==14
	num=num(1:end-1);
end

%data.timings

i=SONChannelInfo(fid,1);
ii=SONChannelInfo(fid,16);

[dataz{1},headerz{1}]=SONGetChannel(fid,1,'seconds');
[dataz{2},headerz{2}]=SONGetChannel(fid,2,'seconds');
[dataz{3},headerz{3}]=SONGetChannel(fid,3,'seconds');
[dataz{4},headerz{4}]=SONGetChannel(fid,15,'seconds');
[dataz{5},headerz{5}]=SONGetChannel(fid,16,'seconds');
f=SONFileHeader(fid);


fclose(fid);
disp('Done!')