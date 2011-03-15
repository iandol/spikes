%CTWMCMCTREE Build full CTW tree graph(s) from data.
%   Y = CTWMCMCTREE(X,OPTS) returns a cell array or structure Y, depending
%   on OPTS, that contains the context-tree weighted tree graph(s) derived
%   from the input data in X. X is a single element cell array, like that
%   obtained with DIRECTBIN, whose rows represent stimulus repeats and
%   whose columns represent time bins, that is a matrix of binned spike
%   trains. Y contains a single tree graph, from which one may derive
%   "signal" entropy (see CTWMCMCSAMPLE), when X contains a single binned
%   spike train. Y contains multiple tree graphs, from which one may derive
%   "noise" entropy (see CTWMCMCSAMPLE), when X contains multiple binned
%   spike trains.
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
%      OPTS.tree_format: The format for the output tree graph(s). Its value
%         may be the string 'cell' or 'struct', which is a trade-off
%         between memory consumption and clarity. Data output in cell
%         format (the default) consume less memory, but are not easy to
%         decipher, whereas data output in struct format are memory-
%         intensive, but readily human-readable.
%      OPTS.memory_expansion: The ratio by which tree memory is expanded
%         when reallocation become necessary during tree building. Its
%         value must be greater than or equal to 1. The default is 1.61.
%
%   Y = CTWMCMCTREE(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = CTWMCMCTREE(X) or [Y,OPTS_USED] = CTWMCMCTREE(X,OPTS)
%   additionally return the options used.
%
%   See also DIRECTBIN, CTWMCMC, CTWMCMCSAMPLE, CTWMCMCINFO.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
