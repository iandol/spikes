function sd=lsd2(file,cell,starttrial,endtrial,trialtime,modtime,cuttime,startmod,endmod)

% LSD2 - Load Spike Data (adapted for VSX data structure):
% This function generates a matlab structure from the text files of spikes times.
% The hope is to get the spikes sitting within trial and modulation structures. 
% The trials are part of the structure. The  modulations are stored under 
% the trial substructure as a cell array, use {} to access.
%
% Structure:
%
%   sd.name=name of file
%   sd.raw=the raw spike times
%   sd.totaltrials=the total number of trials
%   sd.numtrials=the number of trials
%   sd.nummods=the number of modulations
%   sd.trial(x).basetime=the basetime of each trial
%   sd.trial(x).modtimes=the starttimes of each modulation relative to basetime
%   sd.trial(x).mod{x}=the actual spike times of each modulation relative to trial start
% 
% Format for Use:
% sd=lsd(file,cell,starttrial,endtrial,trialtime,modtime,cuttime) - where file is the text file of 
% spike times, and cell is the channel of interest. Also enter the starttrial and endtrial, 
% the total trial time and modulation time. cuttime chops the first
% modulation's transient reponse if greater than 0.

%----------------------------Set up and Load Data------------------------------%

if nargin<7
	cuttime=0;
end

if nargin<8
	startmod=1;
	endmod=inf;
end

sd.name=file;
sd.raw=load(file); % load the file

trials=find(sd.raw(:,1)==100); %this finds the trial markers and indexes them
sd.raw=[sd.raw;100,sd.raw(trials(end),2)+trialtime]; % add an artificial trial time (end of data collection)
trials=[trials;length(sd.raw)]; %add the position of the artificial trial
mods=find(sd.raw(:,1)==10); %does the same for modulations
sd.totaltrials=length(trials)-1;
sd.nummods=length(mods)/sd.totaltrials;

sd.error=[];

if starttrial<1
	starttrial=1;
end
if endtrial>sd.totaltrials || endtrial < starttrial% they have entered more than they should
    endtrial=sd.totaltrials;   
end

if startmod<1
	startmod=1;
end
if endmod>sd.nummods || endmod < startmod% they have entered more than they should
	endmod=sd.nummods;   
end

sd.numtrials=(endtrial-starttrial)+1;
sd.starttrial=starttrial;
sd.endtrial=endtrial;
sd.startmod = startmod;
sd.endmod = endmod;

if mod(sd.nummods,1) %checks to see if there are the same num mods for each trial by determining if there is a remainder in the division
	if length(find(sd.raw(trials(end-1):trials(end),1)==10)) > length(find(sd.raw(trials(1):trials(2),1)==10)) %sometimes a rogue modulation is present in the last trial
		lasttrial=[sd.raw(trials(end-1):mods(end)-1,:);sd.raw(end,:)]; %we surgically remove the last rogue modulation
		sd.raw=[sd.raw(1:trials(end-1)-1,:); lasttrial]; %we replace the lasttrial with our altered one
		trials=find(sd.raw(:,1)==100); %reindex out trials
		mods=mods(1:end-1); %and cut our last our mod time which we cut from the raw data
		sd.nummods=length(mods)/sd.totaltrials;
		if isempty(sd.error)
			sd.error={['WARNING: unequal modulations in: ' sd.name '; I removed the incomplete modulation in the last trial.']};
		else
			sd.error=cat(1,sd.error,['WARNING: unequal modulations in: ' sd.name '; I removed the incomplete modulation in the last trial.']);
		end
		if mod(sd.nummods,1)
			errordlg('Beware there are still not an equal number of modulations for each trial, is the data corrupt?');
			error('Sorry there are not an equal number of modulations for each trial, is the data corrupt?');
		end
	end
end

%This checks to see if the very last trial contains spikes with times that occur before the
%trial started, this deals with the anachronistic "filling in" of incomplete modulations by VSX
%hence, it now ignores the last trial if that is the case. [Rowland, July 2001]
if endtrial==sd.totaltrials
    for check=trials(end-1)+1:trials(end)-1
        if sd.raw(check,2)<sd.raw(trials(end-1),2) 	 %is spike time before the trial started? if so...
            endtrial=sd.totaltrials-1;						  %last trial is now penultimate one
			if starttrial>endtrial; starttrial=endtrial;	end % make sure we don't misselect start trial
            sd.numtrials=(endtrial-starttrial)+1;		%numtrials adjusted accordingly
			sd.totaltrials=sd.totaltrials-1;
			sd.endtrial=sd.endtrial-1;
			disp(['WARNING: Last Trial removed for ' sd.name]);
			if isempty(sd.error)
				sd.error={['WARNING: Last Trial removed for ' sd.name]};
			else
				sd.error=cat(1,sd.error,['WARNING: Last Trial removed for ' sd.name]);
			end
            break
        end
    end
end

%-----------------This is the actual routine for spike extraction----------------%

a=1;
for i=starttrial:endtrial %run through each trial
    sd.trial(a).basetime=sd.raw(trials(i),2);
    lmods=mods(find(mods>trials(i) & mods<trials(i+1))); %this finds the mod markers between each trial
    sd.trial(a).modtimes=sd.raw(lmods,2)-sd.trial(a).basetime; %the relative modulation times
    lmods=[lmods;trials(i+1)]; %the last mod marker is actually the total trial time
    for j=1:sd.nummods
        x=find(sd.raw(lmods(j)+1:lmods(j+1)-1,1)==cell+10)+lmods(j); %this finds the lines for the specified cell for the specific modulation
        n{j}=sd.raw(x,2)-sd.trial(a).basetime; %assigns it as a cell matrix with time relative to trial start  
		if j==1 && cuttime(1)>0
			if length(cuttime) == 1
				n{j}=n{j}(n{j}>cuttime);
			else
				c1=n{j}(n{j}<cuttime(1));
				c2=n{j}(n{j}>cuttime(2));
				n{j}=[c1;c2];
			end
		end			
    end
    sd.trial(a).mod=n; 
    a=a+1;
end   

sd.maxtime=trialtime;


