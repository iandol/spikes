function [time,psth,rawspikes,sums,rawstruct]=binitb(sd,binwidth,startmod,endmod,starttrial,endtrial,wrapped,cor)

% This function will take an lsd structure file and construct a
% timebase and psth at a given binwidth, wrapped or unwrapped.
% binwidth needs to be called *10 as data here is in 10th's ms
% The binning algorithm is taken from the VS manual
%
% [time,psth]=binitb(file,binwidth,startmod,endmod,wrapped);
% where wrapped is 1 (yes) or 0(no)
%
% THIS IS MODIFIED TO BIN BURST ANALYSIS OUTPUT

global data

rawspikes=[];
sums=[];
rawstruct=[];
xcinuse=0;

if endmod>sd.nummods || endmod<1
   endmod=sd.nummods;
end

if endtrial>sd.totaltrials || endtrial<1
   endtrial=sd.totaltrials;
end

if startmod<1 || startmod>endmod
  startmod=1;
end

if starttrial<1 || starttrial>endtrial
  startmod=1;
end

if exist('cor','var')
	xcinuse=1;
end

if (xcinuse==1)
	global xdata
    if isfield(xdata,'modtime')
        modtime=xdata.modtime;
    else
        modtime=round(sd.maxtime/sd.nummods);
    end
else
    if isfield(data,'modtime')
        modtime=data.modtime;
    else
        modtime=round(sd.maxtime/sd.nummods);
    end
end

if wrapped==1 % Wrapped is ON
   time=0:binwidth:modtime;
   psth=zeros(1,size(time,2));
	a=1; %we use this because lsd2 has already removed the trials, so we reset the index
	sloop=1;
	for i=starttrial:endtrial
		for j=startmod:endmod
			reftime=sd.trial(a).modtimes(j); % The reference time is each modtime
			x=sd.btrial(a).mod{j};
			sums=[sums;length(x)];
			rawspikes=[rawspikes;x-reftime];
			rawstruct(sloop).trial=(x-reftime)/10;
			x=(x-reftime)/binwidth;
			x=floor(x);
			x=x+1; % We need to do this because binning starts from 0, but the index starts from 1
			%add the spikes into the accumulation buffer
			for k=1:size(x,1)
				psth(x(k))=psth(x(k))+1; % Add the spikes into the accumulation buffer
			end
			sloop=sloop+1;
		end
		a=a+1;
   end
else  % Wrapped is OFF, we thus don't care about mod selection
   time=0:binwidth:sd.maxtime;
   psth=zeros(1,size(time,2));
   a=1;
   for i=starttrial:endtrial
		sumst=[];
		rawtemp=[];
      for j=1:sd.nummods
         reftime=sd.trial(a).modtimes(1); % The reference time is the 1st modtime
         x=sd.btrial(a).mod{j};
			sumst=[sumst;length(x)];
			rawspikes=[rawspikes;x-reftime];	
			rawtemp=[rawtemp;x-reftime];
         x=(x-reftime)/binwidth;
         x=floor(x);
         x=x+1; % We need to do this because binning starts from 0, but the index starts from 1
		 x(x>length(psth)) = [];
         for k=1:size(x,1)
            psth(x(k))=psth(x(k))+1;
         end
      end
		sums=[sums;sum(sumst)];
		rawstruct(a).trial=rawtemp/10;
      a=a+1;
   end
end
rawspikes=sort(rawspikes/10);
time=time/10; %convert back to ms