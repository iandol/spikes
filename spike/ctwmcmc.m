function [Y, opts_used] = ctwmcmc(X_stream,X_replica,opts)
%CTWMCMC Context-tree weighted method analysis to estimate information.
%   Y = CTWMCMC(X_STREAM,X_REPLICA,OPTS) uses the context-tree weighted
%   (CTW) method paired with Markov chain Monte Carlo (MCMC) Bayesian
%   techniques to estimate the amount of information conveyed by the spike
%   train in X_STREAM (the "signal" entropy) when accounting for the
%   variance of the spike responses in X_REPLICA (the "noise" entropy). The
%   results are stored in the structure Y.
%
%   The members of Y are:
%      Y.stream_binned: Binned versions of the spike trains in X_STREAM.
%         See DIRECTBIN for details.
%      Y.replica_binned: Binned versions of the spike trains in X_REPLICA.
%         See DIRECTBIN for details.
%      Y.stream_tree: A CTW tree graph of the data in X_STREAM. See
%         CTWMCMCTREE for details.
%      Y.replica_tree: The CTW tree graphs of the data in X_REPLICA. See
%         CTWMCMCTREE for details.
%      Y.estimates: A structure with "signal" and "noise" entropy estimates
%         derived from X_STREAM and X_REPLICA, respectively, as well as
%         estimates of information and its confidence intervals. See
%         CTWMCMCSAMPLE and CTWMCMCINFO for details.
%
%   The options and parameters for this function are:
%      OPTS.start_time: The start time of the analysis window. The
%         default is the maximum of all of the start times in X. It is
%         typically best not to specify this value, as the start times for
%         X_STREAM and X_REPLICA may be different.
%      OPTS.end_time: The end time of the analysis window. The
%         default is the minimum of all of the end times in X. It is
%         typically best not to specify this value, as the end times for
%         X_STREAM and X_REPLICA may be different.
%      OPTS.counting_bin_size: The size of the counting bins in
%         seconds. The default is OPTS.end_time-OPTS.start_time.
%      OPTS.letter_cap: Places a cap on the maximum number of spikes
%         to be counted in a bin. The default value is Inf.
%      OPTS.beta: Krischevsky-Trofimov ballast parameter used in the
%         calculation of local codelength, Le, which also serves as the
%         Dirichlet prior parameter in subsequent Markov chain Monte Carlo
%         (MCMC) tree sampling. Its value should be greater than 0. The
%         default is 1/A, where A is the largest value in the input data X
%         plus one.
%      OPTS.gamma: The weighting between tree node and its children, used
%         when calculating the weighted codelength, Lw. Its value should
%         lie between 0 and 1, non-inclusive. The default is 0.5.
%      OPTS.max_tree_depth: The maximum tree depth (may be used to conserve
%         memory). Its value must be greater than 0. The default is 1000.
%      OPTS.h_zero: Flag to indicate use of the H_zero estimator for
%         deterministic nodes, that is such nodes will not be weighted when
%         true. The default is 1 (true).
%      OPTS.tree_format: The format for the output tree graph(s), if
%         requested. Its value may be the string 'none', 'cell', or
%         'struct', which is a trade-off between memory consumption and
%         clarity. Data output in cell format consume less memory, but are
%         not easy to decipher, whereas data output in struct format are
%         memory-intensive, but readily human-readable. The default is
%         'none', which does not export any tree graphs.
%      OPTS.memory_expansion: The ratio by which tree memory is expanded
%         when reallocation become necessary during tree building. Its
%         value must be greater than or equal to 1. The default is 1.61.
%      OPTS.nmc: The number of MCMC samples to make. Its value must be
%         greater than 0, and should be at least 100. The default is 199.
%      OPTS.entropy_estimation_method: A cell array of entropy estimation
%         methods. Please see the Spike Train Analysis Toolkit
%         documentation for more information, and corresponding entropy
%         options. The default is {'plugin'}.
%      OPTS.variance_estimation_method: A cell array of variance
%         estimation methods. Please see the Spike Train Analysis Toolkit
%         documentation for more information, and corresponding variance
%         options (listed with entropy options). The default is not to
%         perform any variance estimation.
%      OPTS.mcmc_iterations: The absolute number of iterations to run the
%         Markov chain Monte Carlo simulation (for each OPTS.nmc sample).
%         If OPTS.mcmc_min_acceptances probability vectors have been
%         accepted, this is also the minimum number of iterations. The
%         default is 100.
%      OPTS.mcmc_max_iterations: The maximum number of Markov chain Monte
%         Carlo iterations. The simulation runs OPTS.mcmc_iterations sized
%         batches of iterations until OPTS.mcmc_min_acceptances probability
%         vectors are accepted, or this number is reached. The default is
%         10000.
%      OPTS.mcmc_min_acceptances: The minimum number of Markov chain Monte
%         Carlo acceptances, that is the number of acceptable probability
%         vectors. The default is 20.
%
%   Y = CTWMCMC(X_STREAM,X_REPLICA) uses default options and parameters.
%
%   [Y,OPTS_USED] = CTWMCMC(X_STREAM,X_REPLICA) or [Y,OPTS_USED] =
%   CTWMCMC(X_STREAM,X_REPLICA,OPTS) additionally return the options used.
%
%   See also DIRECTBIN, CTWMCMCTREE, CTWMCMCSAMPLE, CTWMCMCINFO.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
if nargin<3
    opts = [];
end

warn_state = warning('off','STAToolkit:ReadOptionsTimeRange:missingParameter'); %ignore warning to fit time range to data
if isfield(opts,'words_per_train') && (opts.words_per_train~=1)
    warning('STAToolkit:ctwmcmc:invalidValue','Option words_per_train must equal 1 for CTWMCMC analysis.');
end
opts.words_per_train = 1; %no other value makes sense
opts.legacy_binning = 0; %ctwmcmc methods not in legacy toolkit
[Y.stream_binned opts_stream] = directbin(X_stream,opts);
[Y.replica_binned opts_replica] = directbin(X_replica,opts);
if ~isfield(opts,'start_time') %handle missing start_time
    opts.start_time_stream = opts_stream.start_time;
    opts.start_time_replica = opts_replica.start_time;
end
if ~isfield(opts,'end_time') %handle missing end_time
    opts.end_time_stream = opts_stream.end_time;
    opts.end_time_replica = opts_replica.end_time;
end

if ~isfield(opts,'tree_format') || strcmpi(opts.tree_format,'none')
    [Y.estimates.signal opts] = ctwmcmcbridge(Y.stream_binned,opts);
    [Y.estimates.noise opts] = ctwmcmcbridge(Y.replica_binned,opts);
else
    [Y.stream_tree opts] = ctwmcmctree(Y.stream_binned,opts);
    [Y.replica_tree opts] = ctwmcmctree(Y.replica_binned,opts);

    [Y.estimates.signal opts] = ctwmcmcsample(Y.stream_tree,opts);
    [Y.estimates.noise opts] = ctwmcmcsample(Y.replica_tree,opts);
end

[Y.estimates opts] = ctwmcmcinfo(Y.estimates,Y.replica_binned,opts);

opts_used = opts;
warning(warn_state); %reset warning state
