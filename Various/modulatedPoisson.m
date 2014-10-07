function  spikeTimes=modulatedPoisson
% modulatedPoisson
% generates multiple trials of a sine-modulated inhomogeneous Poisson process
% saves the data as spike times (in sec)

% BN168  Spring 2006

%clear               % clears the workspace
%close all           % closes all figures

dt = .001;          % time step (sec)
T = 2;              % epoch length (sec)
f = 2;              % modulation frequency (Hz)
minRate = 0;       % min firing rate  (Hz, i.e., spikes/sec)
maxRate = 80;       % max firing rate (Hz, i.e., spikes/sec)
nTrials = 20;      % number of trials

timeAxis = 0:dt:T;
N = length(timeAxis);

modulation = .5*(maxRate+minRate) + .5*(maxRate-minRate)*sin(2*pi*f*timeAxis);

%modulation=modulation-(max(modulation)/2);
%modulation(modulation<0)=0;
%modulation=modulation*2;

figure                  % creates a new figure
subplot(4,1,1)
plot(timeAxis,modulation)
ylabel('modulation (Hz)','fontsize',15)

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

subplot(4,1,2)
h = stem(timeAxis,rho(1,:));
set(h,'Marker','none','LineWidth',1)
axis([0 T -1 2])
ylabel('spikes','fontsize',15)

timess=[];
for i=1:nTrials
	ind=find(rho(i,:)>0);
	timess=[timess timeAxis(ind)];
end

timess=timess/max(timess)
timess=timess*(2*pi);
[p,r]=rayleigh(timess');

script_r = mean(rho)/dt;           % "time-dependent firing rate"
%   NOTE: this is the "time-dependent firing rate" script_r(t) of the
%   book (D&A eq. 1.5)

subplot(4,1,3);
plot(timeAxis,script_r);
ylabel('firing rate (Hz)','fontsize',15);

subplot(4,1,4);
hist(timess,0:0.1:2*pi);
ylabel('period response','fontsize',15);
axis tight;

xlabel(['time  (sec) r=' num2str(r) ' p=' num2str(p)],'fontsize',15);

% Now we smooth the time-dependent firing rate:

figure;                  % creates a new figure

kernel_width = .05;                  % width of kernel (sec)
kernel_length = kernel_width/dt;     % width of kernel (bins)
kernel = ones(1,kernel_length)/kernel_length;

r_approx_1 = conv2(script_r,kernel,'same');
%   (NOTE the syntax here: symmetric kernel)

subplot(3,1,1)
plot(timeAxis,r_approx_1)
% axis([0 T minRate maxRate])
ylabel('square','fontsize',10)
title ('smoothed firing rate','fontsize',15)

kernel_width = .15;                  % width of kernel (sec)
kernel_length = kernel_width/dt;     % width of kernel (bins)
kernel = normpdf(-kernel_length/2:kernel_length/2,0,kernel_length/6);

r_approx_2 = conv2(script_r,kernel,'same');
%   (NOTE the syntax here: symmetric kernel)

subplot(3,1,2)
plot(timeAxis,r_approx_2)
% axis([0 T minRate maxRate])
ylabel('gaussian','fontsize',10)

kernel_width = .15;                  % width of kernel (sec)
kernel_length = kernel_width/dt;     % width of kernel (bins)
kernel = exppdf(0:kernel_length,kernel_length/4);

r_approx_3 = conv(script_r,kernel);
%   (NOTE the syntax here: asymmetric kernel)

subplot(3,1,3)
plot(timeAxis,r_approx_3(1:N))      % (NOTE syntax here)
% axis([0 T minRate maxRate])
ylabel('exponential','fontsize',10)

xlabel('time  (sec)','fontsize',15)

%save data spikeTimes T nTrials nSpikesInTrial

figure;
for i=1:10
	subplot(10,1,i)
	h = stem(timeAxis,rho(i,:));
	set(h,'Marker','none','LineWidth',1)
	axis([0 T -1 2])
end
