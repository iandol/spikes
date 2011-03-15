function [Y, opts_used] = ctwmcmcinfo(X,rep_binned,opts)
%CTWMCMCINFO Estimate information from CTW tree based entropy estimates.
%   Y = CTWMCMCINFO(X,REP_BINNED,OPTS) accepts a structure X containing the
%   fields 'signal' and 'noise' that hold entropy estimates derived via the
%   context-tree weighting (CTW) Markov chain Monte Carlo (MCMC) method, as
%   obtained from CTWMCMCSAMPLE. X is copied to the output Y, and the field
%   'information' is added that includes an estimate of the mutual
%   information between the signal and noise, and its confidence interval.
%   The additional required input REP_BINNED is the binned spike trains
%   from which 'noise' estimates were derived, as obtained with DIRECTBIN.
%
%   The options and parameters for this function are:
%      OPTS.match_rates: Flag to indicate whether resampled spike trains
%         should be adjusted based on the original spike rates. The default
%         is 1 (true).
%      OPTS.confidence_interval: The confidence interval (in percent). The
%         default is 95, indicating the 2.5 and 97.5 percentiles.
%
%   Y = CTWMCMCINFO(X,REP_BINNED) uses the default options and parameters.
%
%   [Y,OPTS_USED] = CTWMCMCINFO(X,REP_BINNED) or [Y,OPTS_USED] =
%   CTWMCMCINFO(X,REP_BINNED,OPTS) additionally return the options used.
%
%   See also DIRECTBIN, CTWMCMC, CTWMCMCSAMPLE.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%

Y = X;
Y.information = Y.signal.h_analytical;

%calculate analytical information estimates
for i=1:length(Y.information)
    for j=1:length(Y.noise)
        h_noise(j) = Y.noise(j).h_analytical(i).value;
    end
    Y.information(i).value = Y.signal.h_analytical(i).value - mean(h_noise);
end

%calculate mcmc information estimates
nmc = length(Y.signal.h_mcmc);
if nmc>0
    %get distribution of noise entropy
    if opts.match_rates
        spike_rate = mean(rep_binned{1},1);
        h_noise_dist = correlated_bootstrap(cat(1,Y.noise.h_mcmc)',nmc,spike_rate);
    else
        h_noise_dist = correlated_bootstrap(cat(1,Y.noise.h_mcmc)',nmc);
    end

    %calculate information
    info_extra.name = {'distribution'};
    info_extra.value = Y.signal.h_mcmc - h_noise_dist;
    [Y.information.extras] = deal(info_extra);
end

% calculate confidence intervals
ci = [50-opts.confidence_interval/2 50+opts.confidence_interval/2];
if nmc>0
    Y.signal.ci = prctile(Y.signal.h_mcmc,ci);
    [Y.noise.ci] = deal(prctile(h_noise_dist,ci));
    info_extra.name = {'confidence interval'};
    info_extra.value = prctile(Y.information(1).extras(1).value,ci);
    for i=1:length(Y.information)
        Y.information(i).extras(2) = info_extra;
    end
end

opts_used = opts;
