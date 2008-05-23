function [c_v,ISI] = coef_var(spike_train,bin_length)

% Computes the coefficient of variation of the interspike intervals of a spike train

spike_times = find(spike_train);            % spike times in bin units
spike_times = spike_times*bin_length;       % spike times in seconds

ISI = diff(spike_times);        % interspike intervals
c_v = std(ISI)/mean(ISI);       % coefficient of variation of ISI

