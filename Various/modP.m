function  [r,m]=modP(input)
% generates a vector sum for a sample modulation of a poisson spike train

dt = .001;          % time step (sec)
T = 0.5;              % epoch length (sec)
f = 2;              % modulation frequency (Hz)
minRate = 0;       % min firing rate  (Hz, i.e., spikes/sec)
maxRate = 20;       % max firing rate (Hz, i.e., spikes/sec)
nTrials = 50;      % number of trials

timeAxis = 0:dt:T;
N = length(timeAxis);

modulation = .5*(maxRate+minRate) + .5*(maxRate-minRate)*sin(2*pi*f*timeAxis);

%modulation=modulation-(max(modulation)/2);
%modulation(modulation<0)=0;
%modulation=modulation*2;

rho = zeros(nTrials,N);
r = zeros(1,nTrials);
startTrials = (0:nTrials-1)*T;      % start of trials (sec)

spikeTimes = [];                    % here we will store the spike times (sec)

for trial = 1:nTrials
    randomNumbers = rand(1,N);
    spikes = randomNumbers < modulation*dt;
    %   NOTE: modulation*dt = P(spike in interval [t,t+dt])
    rho(trial,:) = spikes;
    %   NOTE: rho is the "neural response function" rho(t) (D&A eq. 1.1)
    nSpikesInTrial(trial) = sum(spikes);    % number of spikes in trial 
    r(trial) = nSpikesInTrial(trial)/T;     % spike-count rate (D&A eq. 1.4)
    newSpikeTimes = find(spikes)*dt + startTrials(trial);
    spikeTimes = [spikeTimes newSpikeTimes];
end

timess=[];
for i=1:nTrials
	ind=find(rho(i,:)>0);
	timess=[timess timeAxis(ind)];
end

psth = mean(rho)/dt;
m=mean(psth);

timess=timess/max(timess);
timess=timess*(2*pi);
[p,r]=rayleigh(timess');
