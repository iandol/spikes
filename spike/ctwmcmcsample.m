%CTWMCMCSAMPLE Perform MCMC sampling of entropy on CTW tree graph(s).
%   Y = CTWMCMCSAMPLE(X,OPTS) returns both the analytic (or weighted)
%   entropy estimation on the input context-tree weighted (CTW) graph(s),
%   and numerous Markov chain Monte Carlo (MCMC) Bayesian samples derived
%   from the CTW tree graph(s). The type of analytic entropy calculated
%   depends on the options, as does the number of MCMC sample to return.
%   The input X is a representation of CTW tree graph(s), as either a cell
%   array or structure, as obtained from CTWMCMCTREE. The output Y is a
%   structure containing both analytic and MCMC entropy estimates.
%
%   The options and parameters for this function are:
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
%      OPTS.memory_expansion: The ratio by which tree memory is expanded
%         when reallocation become necessary during tree building. Its
%         value must be greater than or equal to 1. The default is 1.61.
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
%   Y = CTWMCMCSAMPLE(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = CTWMCMCSAMPLE(X) or [Y,OPTS_USED] =
%   CTWMCMCSAMPLE(X,OPTS) additionally return the options used.
%
%   See also DIRECTBIN, CTWMCMC, CTWMCMCTREE, CTWMCMCINFO.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
