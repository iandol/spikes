out='';
currdir=pwd;
cd('c:\');
files=dir('c:\c*.txt');
name=0;
ii=1;
for i=1:1:size(files,1)
	
	fid=fopen(files(i).name);
	file=textscan(fid,'%f %f %f %f', 'headerlines', 4);
	fclose(fid);
	
	[a b c d e f]=regexpi(files(i).name,'c(\d\d)(\d)');
	
	out.meta{i}.raw=file;
	out.meta{i}.name=files(i).name;
	out.meta{i}.run=e{1}(1);
	out.meta{i}.cell=e{1}(2);
	
	[out.data(i),out.error(i)]=stderr(file{3});
	
	if name==0
		out.count=1;
		name=str2num(out.meta{i}.run{1});
		eval(['out.run' num2str(name) '(ii) = out.data(i)']);
		eval(['out.run' num2str(name) 'error(ii) = out.error(i)']);
		ii=ii+1;
	elseif name==str2num(out.meta{i}.run{1})
		eval(['out.run' num2str(name) '(ii) = out.data(i)']);
		eval(['out.run' num2str(name) 'error(ii) = out.error(i)']);
		ii=ii+1;
	else
		ii=1;
		out.count=out.count+1;
		name=str2num(out.meta{i}.run{1});
		eval(['out.run' num2str(name) '(ii) = out.data(i)']);
		eval(['out.run' num2str(name) 'error(ii) = out.error(i)']);
		ii=ii+1;
	end		
end
errorbar(out.data,out.error);
out