
% This function produces a simulated population of neural responses. This population is then
% analyzed using 'VarVsMean' and the results (mean rate, Fano Factor, etc) are plotted.
%
% usage (simplest case):    Demo;
% usage (full featured):    [SimData, Result, trueVar] = Demo(params);
% use your own fano params: [SimData, Result, trueVar] = Demo(params, fanoP);
%
% 'params' in an optional input with one or more of the following fields:
%    process        spiking process. Default is 'poisson'. Other options are 'gamma' and 'refractory'
%    noiseLevel 	degree of across-trial variability (within a neuron/condition). Default=1, set to 0 for none.
%    decayRate      rate at which that noise decays (time constant, in ms). Default = 200;
%    decayStart     time at which the decay starts. Default = 400 = time that mean simulated rates start changing.
%    numTrials      # of trials per simulated neuron/condition. Default=50;
%    numConds       # of neuron/conditions. Default = 2000. (think of this as 200 neurons with 10 conds each).
%    baselineRateRange   Range of baseline firing rates (each neuron/cond is different). Default=[0 35];
%    finalRateRange      Range of 'post-stimulus' firing rates. Default=[0 50];
%    initRand       Set to 1 if you want the same results each time. Default=1.
%    overrideUFR    A matrix of underlying firing rates to override default simulation. Set to 0 to use default.
%    makePlot       Set to 1 to plot results. Default=1.
%
% You will be informed, on the command line, of the values for all the above parameters.
%
% OUTPUTS:
%    'SimData' is the data in the usual format (i.e. can be fed right into 'VarVsMean' if you like).
%    'Result' is the output of VarVsMean when fed 'SimData'.
%    'trueVar' is the across-trial variance of the simulated underlying rate (measured empirically, avgd across all conditions) 
%
% Usually you DON'T NEED any of these outputs, as a plot based on 'Result' will be produced.
% 
% Also produced is a plot of the simulated mean rate, single-trial rates, and spike trains.
% Tis is for the LAST simulated condition only.  Note that every simulated condition is different.
% To see a range of simulated responses, set initRand = 0 and run Demo multiple times.
%
function [SimData, Result, trueVar] = Demo(varargin)


% PARSE INPUTS
process = 'poisson'; % other options are 'gamma' and 'refractory'
noiseLevel = 1;
decayRate = 200;
decayStart = 400;
numTrials = 50;
numConds = 2000;
baselineRateRange = [0 35];
finalRateRange = [0 50];
initRand = 1;
overrideUFR = 0;
makePlot = 1;

Pfields = {'process', 'noiseLevel', 'decayRate', 'decayStart', 'numTrials', 'numConds', 'baselineRateRange', 'finalRateRange', 'initRand', 'overrideUFR', 'makePlot'};
for i = 1:length(Pfields) % if a params structure was provided as an input, change the requested fields  
    if ~isempty(varargin)&&isfield(varargin{1}, Pfields{i}), eval(sprintf('%s = varargin{1}.(Pfields{%d});', Pfields{i}, i)); end
end
disp(sprintf('%s = %s (can be: poisson, gamma, refractory)', Pfields{1}, eval(Pfields{1}) ));
for i = 2:length(Pfields)
    if length(eval(Pfields{i})) == 1, disp(sprintf('%s = %g', Pfields{i}, eval(Pfields{i}) ));
    else disp(sprintf('%s = %g  %g', Pfields{i}, eval(Pfields{i}) )); end
end
if initRand, rand('state',0); end  % initialize random number generator (done by default, can be overridden)
if ~isempty(varargin)  % warn if there is an unrecognized field in the input parameter structure
    fnames = fieldnames(varargin{1});
    for i = 1:length(fnames)
        recognized = max(strcmp(fnames{i},Pfields));
        if recognized == 0, fprintf('POSSIBLE ERROR: fieldname %s not recognized\n',fnames{i}); end
    end
end
disp(' ');
% DONE PARSING INPUTS


% MAKE PROTO RATE
% make prototypical mean underlying firing rate 
% (jumps from 0 to 1 at 400 ms with a little overshoot; 1001 long)
temp = [0 0 0 0 0 0 0 0 2 10 15 11.5 10 10 10 10 10 10 10 10 10]/10;
protoUFR = interp1(1:length(temp),temp,1:0.02:length(temp),'spline');

% UNDERLYING FIRING RATES
% create a different underlying firing rate (UFR) for each neuron/condition
if overrideUFR == 0
    UFR = zeros(numConds, length(protoUFR)); % initialize to right size
    for cond = 1:numConds
        baseline = baselineRateRange(1) + rand*diff(baselineRateRange); % default varies from 0 to 35
        finalFR = finalRateRange(1) + rand*diff(finalRateRange); % default varies from 0 to 50 (a tendency for rates to go up, but they can go down)
        UFR(cond,:) = baseline + (finalFR-baseline) * protoUFR; % neg FR may occur during overshoot and is OK
    end
else
    UFR = overrideUFR;
    if size(UFR,1) ~= numConds, disp('ERROR, length of overrideUFR does not match number of conditions'); end
end

% ADD TRIAL-BY-TRIAL DISTURBANCES AND GETS SPIKES
% parameters to be passed to SimNeuron
params.numTrials = numTrials;
params.noiseLevel = noiseLevel; 
params.decayRate = decayRate; 
params.decayStart = decayStart;
params.initRand = initRand;
params.makePlot = makePlot;
params.process = process;
[SimData, trueVar] = SimNeuron(UFR, params); % 'trueVar' is the envelope of the disturbances

% COMPUTE FANO FACTOR ETC
times = 200:25:950;
fanoP.boxWidth = 50; fanoP.matchReps = 25; fanoP.alignTime = 400;
if length(varargin) == 2;  % if we are overriding fanoP 
    fnms = fieldnames(varargin{2});             % override only those fields that are specified
    for i = 1:length(fnms)
        fanoP.(fnms{i}) = varargin{2}.(fnms{i});
    end
end
Result = VarVsMean(SimData, times, fanoP);

% PLOT RESULTS
if makePlot == 1
    % put a title on the firing rate simulation plot
    titleString = sprintf('Noise = %1.1f,  Tdecay = %d,  %s', noiseLevel, decayRate, params.process);
    text(500,120, titleString, 'horiz', 'center');
    
    plotP.plotRawF = 1;
    plotP = plotFano(Result, plotP); % plots everything but the red line for the decay
    
    % red line for decay
    trueVarSameTimes = trueVar(times);
    if range(trueVarSameTimes) > 15 % so long as there are meaningful values, normalize and scale appropriately
        if isfield(Result, 'FanoFactor')  % possible this may be absent if matchReps was 0
            shouldStart = mean(Result.FanoFactor(1:4));  % scale to same scale as Fano Factor
            shouldEnd = mean(Result.FanoFactor(end-4:end));
        else
            shouldStart = mean(Result.FanoFactorAll(1:4));  % scale to same scale as Fano Factor
            shouldEnd = mean(Result.FanoFactorAll(end-4:end));
        end
        trueVarSameTimes = trueVarSameTimes - trueVarSameTimes(end-2); % offset based on value near the very end
        trueVarSameTimes = trueVarSameTimes/abs(trueVarSameTimes(1) - trueVarSameTimes(end-2)); % normalize
        trueVarSameTimes = shouldEnd + (shouldStart - shouldEnd) * trueVarSameTimes;
        plot(Result.times, plotP.FFoffset + plotP.FFscale*trueVarSameTimes, 'r', 'linewidth', 1.5);
    else % if essentially no variability, don't try and normalize
        shouldStart = mean(Result.FanoFactor(1:3));
        trueVarSameTimes = shouldStart + trueVarSameTimes;
        plot(Result.times, plotP.FFoffset + plotP.FFscale*trueVarSameTimes, 'r', 'linewidth', 1.5);
    end

     % TITLE
    text(mean(Result.times),1.1, titleString, 'horiz', 'center');
end


