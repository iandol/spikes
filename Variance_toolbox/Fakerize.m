
% This function takes data and removes all across-trial variability in underlying firing rate.
% Use it to test whether effects you are seeing might be artifacts of the analysis, and in
% particular of non-poisson spiking statistics.
%
% usage: FakeData = Fakerize(Data, process);
%
% 'Data' is data in the same format used by 'VarVsMean' when computing the Fano Factor.
%
% 'process' is an optional string input that determines the spiking statistics. It can
%  be: 'poisson' (default)
%      'refractory' (2 ms refractory period rather than 1)
%      'gamma' (gamma order 2).
%
% The result is 'fake' data whose basic properties (e.g. mean firing rate) are identical to the
% original data, but where very trial has the same underlying rate, and the only across-trial
% variability is due to spiking statistics. 
%
% Lets say you see some interesting changes in the Fano Factor when you run:
%                                           Result = VarVsMean(Data, 200:25:800, FanoParams);
% Typical usage would be to fakerize your data:
%                                           FakeData = Fakerize(Data, 'gamma').
% Then compute the Fano Factor:             FakeResult = VarVsMean(FakeData, 200:25:800, FanoParams);
% If the mean-matched Fano Factor shows similar effects for 'FakeResult' as for 'Result' then you should 
% distrust the original result.
%
% The function works by redistributing the spikes in a given ms across all trials for that
% neuron/condition.  Thus, any within-trial spiking autocorrelation is removed.  The result
% is poisson spiking statistics (within 1 ms resolution) with no change in the mean rate.
% If requested, spiking statistics are then altered to be either gamma or poisson with an extra 1 ms 
% refractory period (2 ms total, given that it was already impossible to spike twice in 1 ms due to 
% the data format).
%
% Using default Poisson statistics, the Fano factor for 'Fakerized' data should be very close to 1. 
% It will be slightly less due to the 1 ms refractory period imposed by the data format, and will 
% drop slightly if the firing rate rises.  However, when matching spike-count distributions 
% (using VarVsMean the latter effect should dissapear.  If the Fano Factor produced by VarVsMean does 
% NOT remain constant (probably near 0.95)when using Fakerized data (and when matching dists) then 
% there must be an artifact in the analysis.
%
% For refractory or gamma spiking statistics, you will likely see a clear drop in the raw Fano Factor
% (because distributions of mean counts are NOT matched) with rising rates. That artifact should dissappear 
% for the mean-matched Fano Factor.  This should reassure you that any effect you see in your real
% data is NOT due to an interaction of changing mean rates with non-Poisson spiking statistics.
% Of course, if you DO find that the Fakerized data shows changes in the mean-matched Fano Factor, then
% you should be seriously concerned that VarVsMean is not giving you interpretable results, and you
% should be highly skeptical of your original findings.

function data = Fakerize(data, varargin)

% can request 'refractory' or 'gamma' rather than poisson.
if ~isempty(varargin), process = varargin{1}; else process = 'poisson'; end

% for gamma, produce 2x as many spikes as needed and then remove every second spike
if strcmp(process, 'gamma'), rateMult = 2; else rateMult = 1; end % for poisson or refractory, just use normal rate


for cond = 1:length(data)
    numTrials = size(data(cond).spikes,1);
    sumSpikes = sum(data(cond).spikes);

    % for either poisson or refracoty, for each ms, shuffle spikes randomly across trials
    if strcmp(process, 'poisson') || strcmp(process, 'refractory')
        for t = find(sumSpikes > 0)        
            data(cond).spikes(:,t) = false(numTrials,1);
            sh = randperm(numTrials);
            data(cond).spikes(sh(1:sumSpikes(t)),t) = 1;
        end
    end
    
    % approximates a refractory period (not a perfect approximation, and produces slightly reduced firing rates)
    if strcmp(process, 'refractory') 
        xdiff = diff(data(cond).spikes,1,2)==1; 
        xdiff = [false(size(xdiff,1),2), xdiff(:,1:end-1)];
        data(cond).spikes(xdiff) = 0;
    end
    
    % for a gamma process
    if strcmp(process, 'gamma')
        for t = find(sumSpikes > 0)  % start by generating Poisson, but with double the rate      
            data(cond).spikes(:,t) = false(numTrials,1);
            sh = randperm(numTrials);
            numSpikes = min( numTrials, rateMult*sumSpikes(t) ); % make sure we don't have more spikes than trials (unlikely but possible)
            data(cond).spikes(sh(1:numSpikes),t) = 1;
        end
        xeven = mod(cumsum(single(data(cond).spikes),2),2)==0; 
        data(cond).spikes(xeven) = 0; % get rid of every second spike
    end        
        
end



    