function [data,sv]=spikescache(spikesfile,save)

global spikecache
global data
global sv

if isempty(data) | isempty(sv)
	return;
end

if ~isfield(spikecache,'size')
	spikecache.size=0;
	spikecache.index=0;
end

for i=1:spikecache.size
	fname=[spikecache.cell(i).data.filename ' | Cell ' num2str spikecache.cell(i).data.cell];
	if strcmp(fname,spikesfile)
		if exist('save','var') %we want to save
			spikecache.size=spikecache.size+1;
			spikecache.index=spikecache.index+1;
			spikecache.cell(spikecache.size).data=data;
			spikecache.cell(spikecache.size).sv=sv;
		else
			data=spikecache.cell(i).data;
			sv=spikecache.cell(i).sv;
			return;
		end
	end
end