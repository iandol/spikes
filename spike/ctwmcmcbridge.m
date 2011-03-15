%CTWMCMCBRIDGE Build CTW tree graph(s) and make MCMC samples.
%   Y = CTWMCMCBRIDGE(X,OPTS) returns both the analytic (or weighted)
%   entropy estimation on the context-tree weighted (CTW) graph(s), and
%   numerous Markov chain Monte Carlo (MCMC) Bayesian samples of the CTW
%   tree graph(s), which are derived from the input data in X. The type of
%   analytic entropy calculated depends on the options, as does the number
%   of MCMC samples to return. X is a single element cell array, like that
%   obtained with DIRECTBIN, whose rows represent stimulus repeats and
%   whose columns represent time bins, that is a matrix of binned spike
%   trains. The output Y is a structure containing both analytic and MCMC
%   entropy estimates. This function bridges the functions CTWMCMCTREE and
%   CTWMCMCSAMPLE, without outputing the CTW tree graph(s).
%
%   The options and parameters for this function are:
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
%         memory). Its value must be greater than 0. The default is 100000.
%      OPTS.h_zero: Flag to indicate use of the H_zero estimator for
%         deterministic nodes, that is such nodes will not be weighted when
%         true. Note that this value is not used in tree building, per say,
%         but in subsequent MCMC sampling. The default is 1 (true).
%      OPTS.tree_format: The default and only allowable value is 'none'. To
%         output CTW tree graphs, please see CTWMCMCTREE.
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
%   Y = CTWMCMCBRIDGE(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = CTWMCMCBRIDGE(X) or [Y,OPTS_USED] =
%   CTWMCMCBRIDGE(X,OPTS) additionally return the options used.
%
%   See also DIRECTBIN, CTWMCMC, CTWMCMCTREE, CTWMCMCSAMPLE, CTWMCMCINFO.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
