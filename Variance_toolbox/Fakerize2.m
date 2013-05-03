% This function takes data and removes all across-trial variability in underlying firing rate.
% Use it to test whether effects you are seeing might be artifacts of the analysis, and in
% particular of non-poisson spiking statistics.
%
% Differs in a subtle but critical way from 'Fakerize'.
%
% Goes through and figures out the rate, in 1 ms bins.
% Instead of perfectly preserving the rate, we redraw new spikes according to that rate.
% Thus, the rate is preserved only on average.
% Critically, this means that the measured rate can differ from the actual rate.
%
%
% usage: FakeData = Fakerize2(Data);
%
% 'Data' is data in the same format used by 'VarVsMean' when computing the Fano Factor.
%
% 'process' is no longer an argument (we assume Poisson).
%
function data = Fakerize2(data, varargin)


for cond = 1:length(data)
    szSpks = size(data(cond).spikes);
    meanSpikes = mean(data(cond).spikes);
    
    newSpikes = rand(szSpks) < repmat(meanSpikes,szSpks(1),1);

    data(cond).spikes = newSpikes;     
end



    