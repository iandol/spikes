fid=fopen('c:\spikes.txt');
tline={''};
out={''};
a=1;
while 1
    tline{a} = fgetl(fid);
    if ~ischar(tline{a}), break, end
    a=a+1;
end
fclose(fid);

a=1;
for i=1:size(tline,2)
    if ischar(tline{i})
        if regexp(tline{i}, '^(Indep|Var|Repeats|Cycles|Mod|Trial|Protocol).+')
            tline{i};
            out{a}=tline{i};
            a=a+1;
        end
    end
end

fid2=fopen('c:\out.txt','w+');
for i=1:size(out,2)
    fprintf(fid2,'%s\n',out{i});
end