function [x,timebase]=icorr(a,b,binwidth,window,from,to)
%
%Windowing cross-correlation routine
%
%[x, timebase]=icorr(cell1,cell2,binwidth,window,from,to)
%
%    'cell1' & 'cell2' must be in the Carlos sparse matrix format
%
%    'binwidth' & 'window' are given in MILLISECONDS
%
%    'from' & 'to' are the times between which spikes will be selected
%                  given in MILLISECONDS
%
%

if to==-Inf
   to=max([maxtime(a), maxtime(b)]);
end;

window=round(window/binwidth);  %convert window time into number of bins

if rem(window,2)<1  %make sure that window is odd i.e. will be symmetrical around zero
   window=window+1;
end


%this sets up the timebase for the bins
time=-(((binwidth*window)-binwidth)/2):binwidth:(((binwidth*window)-binwidth)/2);
corr=zeros(1,size(time,2));
x=corr;
wwidth=time(end)+(binwidth/2); 
trials=size(a,1);

if to<=wwidth*3
   errordlg('Your binwidth/window parameters are too big for the length of the PSTH');
   break
elseif to<=wwidth*4
   h=errordlg('Your binwidth/window parameters are losing half or more of the data: CAUTION');
   pause(2)
   close(h)
elseif to<=wwidth*6
   h=errordlg('Your binwidth/window parameters are losing 1/3 or more of the data: CAUTION');
   pause(2)
   close(h)
end


for i=1:trials; %run through each trial
   spikes=a(i,1);
   for j=2:spikes+1; %run through each spike in a trial
      if a(i,j)>(from+wwidth) & a(i,j)<(to-wwidth); %checks to see if spike is in window
         for k=1:size(time,2); %for each time bin
            mint=a(i,j)+time(k)-(binwidth/2); %get the mintime for this bin
            maxt=a(i,j)+time(k)+(binwidth/2); %get the maxtime for this bin
            m=find(b(i,2:end)>=mint & b(i,2:end)<maxt);
            corr(k)=size(m,2);
         end 
         x=x+corr;
      end      
   end
end

timebase=time;
