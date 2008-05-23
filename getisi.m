function [isi, c_v]=getisi(cellin, window, fromtime, totime,wrapped)
%--------------------------------------------------------------------------
%
% Returns the ISIs 
%
% -------------------------------------------------------------------------

if ~exist('wrapped','var');
	wrapped=1;
end

if ~exist('totime','var');
	totime=Inf;
end

if ~exist('fromtime','var');
	fromtime=0;
end

totime=totime*10; %convert into 1/10th of millisecond
fromtime=fromtime*10; %convert into 1/10th of millisecond

if ~exist('window','var');
	window=100;
end

if wrapped == 0
	isi=cell(cellin.numtrials,1);
	for i=1:cellin.numtrials
		a=cat(1,cellin.trial(i).mod{1:end});
		a=a(a<totime);
		a=a(a>fromtime);
		if length(a)>1
			isi{i}=a(2:end)-a(1:end-1);
		else
			isi{i}=nan;	
		end
	end
else
	z=1;
	for i=1:cellin.numtrials
		for j=1:cellin.nummods
			a=cellin.trial(i).mod{j};
			a=a(a<totime);
			a=a(a>fromtime);
			if length(a)>1
				isi{z}=a(2:end)-a(1:end-1);
			else
				isi{z}=nan;	
			end
			z=z+1;
		end
	end
end

isi=cat(1,isi{1:end});
isi=isi(isfinite(isi)); %remove NaNs
if ~isempty(isi)
	isi=isi/10; %back to ms	
	c_v = std(isi)/mean(isi);
	isi=isi(isi<window);
else
	c_v = 0;
end

%figure;
%hist(isi,window);


	

