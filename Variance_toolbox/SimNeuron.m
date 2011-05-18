% This function takes in an underlying firing rate, or a series of underlying firing rates (one per imagninary neuron/condition)
% This underlying rate is corrupted with trial-to-trial variability, and spikes are then produced via a Poisson process.
%
% usage: [SimData, trueVar] = SimNeuron(UFR, params)
%
% 'UFR' A matrix of underlying firing rates with time running horizontally and one row per simulated neuron/condition.
%       Can be just one row if you just want to simulate one UFR.
% 'params' needs to have fields:
%        numTrials      number of simulated trials per neuron/condition.
%        noiseLevel     set to 1 for full noise (added to the underlying rate on each trial).
%        decayRate      time constant for the decay of the underlying rate to a consistent mean.
%        decayStart     time that the noise starts decaying.
%        initRand       set to 1 if you wish to get the same result each time.
%        makePlot       set to 1 to plot.  If UFR has more than one row, just done for the last.
%        process     	'poisson', 'gamma', or 'refractory'. ('poisson' has an effective refractoriness of 1 ms,
%                           due to the time resolution of the data format. 'gamma' is gamma order 2.
%                           'refractory' is poisson but with a 2 ms refractory period. The implementation of 
%                           the 2 ms refractory period is fast but not quite perfect (a few spikes may leak through)
%                   
% 'SimData' A structure with one element per row of UFR (i.e. one per neuron/condition)
%           Each element contains a matrix with the spikes.
%           This is the same format accepted by 'VarVsMean'
%
% 'trueVar' The average measured variance of the UFRs.

function [SimData, trueVar] = SimNeuron(UFR, params)

if params.initRand, rand('state',0); randn('state',0); end
if strcmp(params.process, 'gamma')
    rateMult = 2; % for gamma, produce 2x as many spikes as needed and then remove every second spike
else
    rateMult = 1; % for poisson or refractory, just use normal rate
end

% TRIAL BY TRIAL DEVIATIONS FROM THE MEAN RATE
noiseMag1 = 9 * params.noiseLevel;
noiseMag2 = 0.8 * params.noiseLevel;
decayStart = params.decayStart; 
decay(1:decayStart) = 1;
decay(decayStart+1:size(UFR,2)) = exp( -(1:(size(UFR,2)-decayStart))/params.decayRate );
% create 100 possible time-varying disturbances (saves time to just make 100, will be recombined randomly)
numPosDisturbances = 100;
possDist = zeros(numPosDisturbances, size(UFR,2)); % initialize to right size to save time allocating memory
ts = 2*pi*(1:size(UFR,2))/1000;
if params.noiseLevel ~= 0
    for n = 1:numPosDisturbances, possDist(n,:) = noiseMag2*cos( ts*(7*rand) + ts(end)*rand ); end
end
decayMatrix = repmat(decay, params.numTrials, 1);

% FOR EACH COND, PRODUCE SPIKES FOR 'params.numTrials' TRIALS
[SimData(1:size(UFR,1)).spikes] = deal( false(params.numTrials, size(UFR,2)) ); % initialize for speed
trueVar = 0;
for cond = 1:size(UFR,1)  % for each neuron/condition
    if params.noiseLevel ~= 0 % in the interest of speed, don't do this if we don't have to
        % Each trial's disturbance is a DC offset (unique) plus a random combination of the pre-made time-varying disturbances
        Disturbance = repmat(noiseMag1*randn(params.numTrials,1),1,size(UFR,2)) + randn(params.numTrials,numPosDisturbances) * possDist;
        % Each firing rate is a sum of the underlying firing rate (UFR) plus the decaying disturbance
        TrueFR = repmat(UFR(cond,:),params.numTrials,1) + decayMatrix .* Disturbance;
    else
        TrueFR = repmat(UFR(cond,:),params.numTrials,1); % if no noise
    end
    TrueFR = (TrueFR + abs(TrueFR) )/2;
    trueVar = trueVar + var(TrueFR);
    SimData(cond).spikes = rateMult*TrueFR/1000 > rand(size(TrueFR)); % make logical matrix with spikes = 1
end
%if max(trueVar)>0, trueVar = trueVar/mean(trueVar(1:100)); end
trueVar = trueVar/cond;

% NOW, MAKE NON-POISSON IF 'gamma' OR 'refractory' WAS REQUESTED
% for gamma, remove every second spike
if strcmp(params.process, 'gamma')
	for cond = 1:length(SimData)
        xeven = mod(cumsum(single(SimData(cond).spikes),2),2)==0; 
        SimData(cond).spikes(xeven) = 0;
    end
end
% For refractory, remove spikes that follow a spike
% Note: this is only an approximation of a hard 2 ms refractory period. It works better than just removing
% all spikes that follow a spike. For example, 0 1 1 1 0 --> 0 1 0 1 0, rather than 0 1 0 0 0.
% But it isn't perfect. Bursts of four spikes or more will have some refractory violations.
% e.g. 0 1 1 1 1 0 --> 0 1 0 1 1 0;
% Still, this should happen rarely, and for present purposes the algorithm is sufficient, and
% has the desired effect of making spiking more regular.
if strcmp(params.process, 'refractory')
	for cond = 1:length(SimData)
        xdiff = diff(SimData(cond).spikes,1,2)==1; 
        xdiff = [false(size(xdiff,1),2), xdiff(:,1:end-1)];
        SimData(cond).spikes(xdiff) = 0;
    end
end
% DONE CREATING DATA


% IF ASKED TO PLOT (if more than one UFR was supplied, this plots the sim just the very last UFR)
if params.makePlot   
    lastUFR = UFR(end,:);
    
    blankFigure([-100 size(lastUFR,2)+100 -100 150]);
    
    vloc = -3;  % plot rasters
    rasterSep = 1.2;
    for i = 1:min(100, size(TrueFR,1))
        h = plot(TrueFR(i,:), 'k');
        hold on;
        set(h, 'color', 0.83*[1 1 1]);
        
        sTs = find(SimData(cond).spikes(i,:) == 1);
        if ~isempty(sTs)
            h = plot( sTs, vloc, 'k.' );
            set(h,'markersize',4);
        end
        vloc = vloc - rasterSep;
    end
    
    h = plot(lastUFR, 'k');  % plot underlying firing rate
    set(h, 'color', 0.6*[1 1 1], 'linewidth', 3);    
    
    % plot time calibration
    h = plot( decayStart + [0 200], -80+[0 0], 'k' );
    set(h,'linewidth',4);  
    h = text(decayStart + 100, -83, '200 ms'); set(h,'verticala','top','horizontala', 'center');
    
    % plot vertical calibration
    start = 0;
    fin = 100;
    axP.axisLabel = 'spikes/s';
    axP.axisOrientation = 'v';
    axP.axisOffset = -50;
    AxisMMC(start, fin, axP);
end
