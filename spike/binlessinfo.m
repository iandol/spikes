%BINLESSINFO Compute information components using binless method. 
%   [I_PART,I_CONT,I_COUNT,I_TOTAL] =
%   BINLESSINFO(X,COUNTS,CATEGORIES,M,OPTS) computes the various
%   components of information in the matrix of embedded data X. COUNTS
%   is a vector of the number of points in the data from which X is
%   derived (e.g., spike counts), and CATEGORIES is a vector of
%   category indices, as obtained from BINLESSOPEN. M is the number of
%   categories.
%
%   I_PART is the information conveyed by zero-distance data and
%   singletons. I_CONT is the continuous component of the information
%   which describes the separability of the embedded data. I_PART and
%   I_CONT sum to give the "timing" component of the information.
%   I_COUNT is the information conveyed by the number of points in the
%   data. I_TOTAL is the sum of all of the components. While I_CONT is
%   a scalar, I_PART, I_COUNT, and I_TOTAL are structures of type
%   ESTIMATE.
%
%      OPTS.min_embed_dim: The minimal embedding dimension for
%         episodic data. The default is 1. (Related option
%         OPTS.max_embed_dim is used by BINLESSEMBED.)
%      OPTS.cont_min_embed_dim: The minimal embedding dimension for
%         continuous data. The default is 0. (Related option
%         OPTS.cont_max_embed_dim is used by BINLESSEMBED.)
%      OPTS.stratification_strategy: The strategy for stratifying data
%         by the number of points.
%         OPTS.stratification_strategy=0 puts all data in a single
%            stratum. 
%         OPTS.stratification_strategy=1 stratifies data by the number
%            of points. For continuous data in which the number of
%            samples on each trial is the same (as is typical), this
%            is equivalent to OPTS.stratification_strategy=0. For
%            episodic data, each spike count gets its own stratum. 
%         OPTS.stratification_strategy=2 is similar to option 1
%            except that all data with more than
%            OPTS.embed_dim_max-OPTS.embed_dim_min points go into a
%            single stratum.
%         The default value is 2 for episodic data and 0 for
%         continuous data.
%      OPTS.singleton_strategy: The strategy for handling
%         singletons.
%         OPTS.singleton_strategy=0 means that singletons are
%            considered uninformative and are ignored. 
%         OPTS.singleton_strategy=1 means that singletons are
%            considered maximally informative and are included.
%         The default value is 0.
%
%   [I_PART,I_CONT,I_COUNT,I_TOTAL] =
%   BINLESSINFO(X,COUNTS,CATEGORIES,M) uses the default options and
%   parameters.
%
%   [I_PART,I_CONT,I_COUNT,I_TOTAL,OPTS_USED] =
%   BINLESSINFO(X,COUNTS,CATEGORIES,M) or
%   [I_PART,I_CONT,I_COUNT,I_TOTAL,OPTS_USED] =
%   BINLESSINFO(X,COUNTS,CATEGORIES,M,OPTS) additionally return the
%   options used.
% 
%   See also BINLESSOPEN, BINLESSEMBED, BINLESSWARP.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
