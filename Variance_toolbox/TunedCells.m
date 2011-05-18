
%   Takes an input structure of the form: neuron(n).condition(c).spikesm, finds
% the neurons with tuning, and returns a structure of form Data(neurons/conditions).spikes
% which can be fed to 'VarVsMean'.
%
%   For each neuron, two measurements of tuning are computed: the 'response index' and the 'tuning range'.
%   The response index measures the degree to which firing rates change from baseline, regardless of
% whether those responses are tuned.  It is the mean absolute rate change, normalized by that expected due
% to sampling error (computed via bootstrap).
%   The tuning range measures whether stimulus-interval firing rates are different across conditions. 
% It is just the max firing rate (across conditions) minus the minimum firing rate, corrected for 
% sampling error by subtracting off a bootstrapped value.
%   A neuron is passed if both the response index and the tuning range exceed their respective thresholds.
%
% usage: [goodData, goodCells, cellSummary] = TunedCells(nStruct, baselineInt, stimulusInt)
%
% (Optional arguments are 'minResponseIndex' and 'minTuningRange'.  If not supplied, defaults are 2 and 5).
%
% INPUTS:
% Each element of 'nStruct' is data from one neuron. For each neuron, there should be a field that 
% indexes across conditions/stimuli.  e.g. neuron(1).condition(3).spikes or cell(1).target(1).spikes.
% The 'spikes' field should be of the same format expected by 'VarVsMean':
% one row per trial, time flowing horizontally, logical 1's and 0's for spike vs no spike.
% The 'spikes' field MUST be named 'spikes'.
% 
% 'baselineInt' and 'stimulusInt' are each 2-element vectors of the times for which the baseline and
% stimulus-driven firing rates will be measured.  For example, [0 100] and [300 400];
% Ideally these are of similar length (the bootstrap won't be quite right otherwise).
% That said, it should be fine if the stimulus interval is longer than the basline interval.
% The bootstrap will just overcorrect slightly, and the result will be conservative.
%
% The optional arguments, 'minResponseIndex' and 'minTuningRange', can override the threshold 
% values for the minimum response index and the minimum tuning range.
%
% OUTPUTS:
% 'goodData' can be fed straight into 'VarVsMean'.  It has one element per neuron/condition
% it contains only data from the cells that passed.
%
% 'goodCells' is a list of the cells that passed.
% 
% 'cellSummary' gives some summary statistics for each cell (including the response index and tuning range)

function [goodData, goodCells, cellSummary] = TunedCells(nStruct, baselineInt, stimulusInt, varargin)

rand('state',0);

% parse inputs
if length(varargin)>=1, minResponseIndex = varargin{1}; else minResponseIndex = 2; end
if length(varargin)==2, minTuningRange = varargin{2}; else minTuningRange = 5; end
fNames = fieldnames(nStruct);
fieldToUse = fNames{1}; % The first field is assumed to contain data for the different conditions
if range(baselineInt) - range(stimulusInt) > 10
    disp('baseline interval > stimulus interval: the responseIndex bootstrap may under-correct');
end
if range(baselineInt) - range(stimulusInt) < -10
    disp('stimulus interval > baseline interval, the responseIndex bootstrap may be overly conservative');
    disp('you may or may not mind');
end

goodData = [];
goodCells = [];
gi = 1; % will grow as we add cells that pass the criteria
for n = 1:length(nStruct)  % cycle through neurons
    bootData = [];
    numconds = length(nStruct(n).(fieldToUse));
    for c = 1:numconds  % cycle through conditions/targets/stimuli/whatever we are supposed to be tuned for
        cellSummary(n).baselineRate(c) = 1000 * mean(mean(nStruct(n).(fieldToUse)(c).spikes(:,baselineInt(1):baselineInt(2))));
        cellSummary(n).stimulusRate(c) = 1000 * mean(mean(nStruct(n).(fieldToUse)(c).spikes(:,stimulusInt(1):stimulusInt(2))));
        bootData = [bootData; 1000 * mean(nStruct(n).(fieldToUse)(c).spikes(:,stimulusInt(1):stimulusInt(2)),2)];
    end
    
    
    % do bootstrap for response index 
    % (what would it be, due to sampling error, if rates didn't really change, but stayed at baseline)
    absDeltaFRs = abs( cellSummary(n).stimulusRate - cellSummary(n).baselineRate );
    for bootReps = 1:20
        bootRates = cellSummary(n).baselineRate( randperm(numconds) );
        absDeltaFRs_boot(bootReps,:) = abs( bootRates - cellSummary(n).baselineRate );
    end
    absDeltaFRs_boot = mean(absDeltaFRs_boot);
    
    % now compute the response index (FIRST OF THE TWO KEY CRITERIA)
    cellSummary(n).responseIndex = mean(absDeltaFRs) / (mean(absDeltaFRs_boot)+1); % +1 to keep from dividing by a very small number
    
    % do bootstrap for tuning range (shuffle trials and computing range of tuning during stimulus interval)
    % this computes the tuning range expected just due to sampling error
    for bootReps = 1:20
        bootData = bootData(randperm(length(bootData)));
        bi = 1;
        for c = 1:numconds
            endi = bi+size( nStruct(n).(fieldToUse)(c).spikes, 1 )-1;
            bootSummary(n).stimulusRate(c) = mean( bootData(bi:endi) );
            bi = endi+1;
        end
        bootRange(bootReps) = range(bootSummary(n).stimulusRate);  % range expected by chance
    end
    bootRange = mean(bootRange);
    
    % now compute the tuning range (SECOND OF THE TWO KEY CRITERIA)
    % max - min FR across conditions, corrected for bootstrap
    cellSummary(n).tuningRange = range(cellSummary(n).stimulusRate) - bootRange;
    
    

    
    if cellSummary(n).responseIndex >= minResponseIndex && cellSummary(n).tuningRange >= minTuningRange
        goodCells = [goodCells, n];
        for c = 1:length(nStruct(n).(fieldToUse)) 
            goodData(gi).spikes = nStruct(n).(fieldToUse)(c).spikes; 
            gi = gi+1;
        end
        cellSummary(n).passed = 1;
    else
        cellSummary(n).passed = 0;
    end
end

fprintf('%d of %d neurons passed\n', length(goodCells), length(nStruct));
fprintf('mean responseIndex = %1.1f   [%1.1f to %1.1f]\n', mean([cellSummary(goodCells).responseIndex]), min([cellSummary(goodCells).responseIndex]), max([cellSummary(goodCells).responseIndex]));
fprintf('mean tuningRange = %1.1f   [%1.1f to %1.1f]\n', mean([cellSummary(goodCells).tuningRange]), min([cellSummary(goodCells).tuningRange]), max([cellSummary(goodCells).tuningRange]) );

        
    