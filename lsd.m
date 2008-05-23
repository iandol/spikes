function sd=lsd(file,cell,starttrial,endtrial)

% LSD - Load Spike Data:
% This function generates a matlab structure from the text files of spikes times
% The hope is to get the spikes sitting within trial and modulation structures, without
% having to inject spikes for trial ends. The trials are part of the structure. The
% modulations are stored under a single structure as a cell array, use {} to access
% Structure:
%   sd.name=name of file
%   sd.raw=the raw spike times
%   sd.numtrials=the number of trials
%   sd.nummods=the number of modulations
%   sd.trial(x).basetime=the basetime of each trial
%   sd.trial(x).modtimes=the starttimes of each modulation relative to trial start
%   sd.trial(x).mod{x}=the actual spike times of each modulation relative to trial start
% 
% Format for Use:
% sd=lsd(file,cell,st,et) - where file is the text file of spike times, and cell is the channel
%                     of interest
%
% Changes:
% [Rowland] - Added support for VSX's slightly different output format, July 2001 

%----------------------------Set up and Load Data------------------------------%

tmark=0;
sd=struct;
mods=0;
sd.name=file;
sd.raw=load(file); % load the file
trials=find(sd.raw(:,1)==100); %this finds the trial markers and indexes them
mods=find(sd.raw(:,1)==10); %does the same for modulations
sd.totaltrials=length(trials);
sd.nummods=length(mods)/sd.totaltrials;
if endtrial==inf; %our user wants a max trial
   endtrial=sd.totaltrials;
end   
sd.numtrials=(endtrial-starttrial)+1;

if sd.nummods-round(sd.nummods)~=0 %checks to see if there are the same num mods for each trial by determining if there is a remainder in the division
   errordlg('There are not equal mods for each trial');
   sd.numtrials
   sd.totaltrials
   sd.nummods
   error('There are not equal mods for each trial');
end

if sd.nummods<2 %checks to see if there are enough modulations, as otherwise we can't know trial end
   errordlg('There needs to be at least 2 modulations');
   error('There needs to be at least 2 modulations');
end

if endtrial>sd.totaltrials % they have entered more than they should
   h=errordlg(['Sorry there are only ' num2str(sd.totaltrials) ' trials, using all of them']);
   endtrial=sd.totaltrials;
   close(h);
   tmark=0;
elseif endtrial<sd.totaltrials %set it to our user input
   tmark=1;
elseif endtrial==sd.totaltrials
   tmark=0;
end

%This checks to see if the very last trial contains spikes with times that occur before the
%trial started, this deals with the anachronistic "filling in" of incomplete modulations by VSX
%hence, it now ignores the last trial if that is the case. [Rowland, July 2001]
if tmark==0
    for check=(max(trials)+1):size(sd.raw,1)
        if sd.raw(check,2)<sd.raw(max(trials),2) 	%is spike time before the trial started? if so...
            tmark=1; 											%uses 2nd routine now 
            endtrial=sd.totaltrials-1;						%last trial is now penultimate one
            sd.numtrials=(endtrial-starttrial)+1;		%numtrials adjusted accordingly
            break
        end
    end
end

%-----------------This is the actual routine for spike extraction----------------%

if tmark==0
   a=1;
   for i=starttrial:sd.totaltrials-1 %run through each trial, except the last trial, which won't have a final marker, so needs to be treated differently   
      sd.trial(a).basetime=sd.raw(trials(i),2);
      lmods=mods(find(mods>trials(i) & mods<trials(i+1))); %this finds the mod markers between each trial
      sd.trial(a).modtimes=sd.raw(lmods,2)-sd.trial(a).basetime; %the relative modulation times
      lmods=[lmods;trials(i+1)]; %the last mod marker is actually a trial marker, only used for its position
      for j=1:sd.nummods
         x=find(sd.raw(lmods(j)+1:lmods(j+1)-1,1)==cell+10)+lmods(j); %this finds the lines for the specified cell within the specific modulation/trial
         n{j}=sd.raw(x,2)-sd.trial(a).basetime; %assigns it as a cell matrix with time relative to trial start  
      end
      sd.trial(a).mod=n; 
      a=a+1;
   end   
   %---------------------------------------------Last trial----------------------------------------------%
   % The last trial is a little different as it doesnt have any marker after the last spike,
   % so the last modulation of the last spike must be treated differently
   % i have decided to do this seperatly from the main loop as it speeds 
   % execution for the other trials   
   i=sd.totaltrials; %the last trial
   h=sd.numtrials;
   sd.trial(h).basetime=sd.raw(trials(i),2);
   lmods=mods(find(mods>trials(i))); %this finds the mod markers after the last trial marker
   sd.trial(h).modtimes=sd.raw(lmods,2)-sd.trial(h).basetime; %the relative modulation times
   lmods=[lmods;size(sd.raw,1)]; %the last mod here is actually the last spike
   for j=1:sd.nummods
      if j<sd.nummods
         x=find(sd.raw(lmods(j)+1:lmods(j+1)-1,1)==cell+10)+lmods(j); %this finds the lines for the specified cell for the specific modulation
         n{j}=sd.raw(x,2)-sd.trial(h).basetime; %assigns it as a cell matrix with time relative to trial start           
      else
         x=find(sd.raw(lmods(j)+1:lmods(j+1),1)==cell+10)+lmods(j); %just dont do the -1 bit here
         n{j}=sd.raw(x,2)-sd.trial(h).basetime; %assigns it as a cell matrix with time relative to trial start           
      end
   end
   sd.trial(h).mod=n;
else %we dont need to worry about the last modulation as the user chose a max trial less than maxtrials
   a=1;
   for i=starttrial:endtrial %run through each trial   
      sd.trial(a).basetime=sd.raw(trials(i),2);
      lmods=mods(find(mods>trials(i) & mods<trials(i+1))); %this finds the mod markers between each trial
      sd.trial(a).modtimes=sd.raw(lmods,2)-sd.trial(a).basetime; %the relative modulation times
      lmods=[lmods;trials(i+1)]; %the last mod marker is actually a trial marker, only used for its position
      for j=1:sd.nummods
         x=find(sd.raw(lmods(j)+1:lmods(j+1)-1,1)==cell+10)+lmods(j); %this finds the lines for the specified cell for the specific modulation
         n{j}=sd.raw(x,2)-sd.trial(a).basetime; %assigns it as a cell matrix with time relative to trial start  
      end
      sd.trial(a).mod=n;   
      a=a+1;
   end
end   
   
%----------We now want to determine what the trial end time will be------------------%

tmat=zeros(size(sd.trial(1).modtimes,1),sd.numtrials); %preallocate the matrix

for i=1:sd.numtrials %construct a matrix of all the modtimes
   tmat(:,i)=sd.trial(i).modtimes;
end

sd.maxtime=max(tmat(end,:)+tmat(2,:)); %I am finding the maximum possible,by adding the second mod time to the last.

   



