%BINLESSINFO Compute information components using binless method. 
%   [I_PART,I_CONT,I_COUNT,I_TOTAL] =
%   BINLESSINFO(X,COUNTS,CATEGORIES,M,OPTS) computes the various
%   components of information in the matrix of embedded spike trains
%   X. COUNTS is a vector of the spike counts in the spike trains from
%   which X is derived. CATEGORIES is a vector of category indices. M
%   is the number of categories.
%
%   I_PART is the information conveyed by zero-distance spike
%   trains and singletons. I_CONT is the continuous component of the
%   information which describes the separability of the embedded
%   spike trains. I_PART and I_CONT sum to give the "timing"
%   component of the information. I_COUNT is the information
%   conveyed by the number of spikes in the spike trains. I_TOTAL
%   is the sum of all of the components. While I_CONT is a scalar,
%   I_PART, I_COUNT, and I_TOTAL are structures of type ESTIMATE.
%
%      OPTS.stratification_strategy: The strategy for stratifying
%         spike trains by spike count. 
%         OPTS.stratification_strategy=0 puts all spike trains
%            in a single stratum. 
%         OPTS.stratification_strategy=1 stratifies spike trains
%            by spike count. Each spike count gets its own
%            stratum. 
%         OPTS.stratification_strategy=2 is similar to option 1
%            except that all spike trains with more than
%            OPTS.embed_dim_max-OPTS.embed_dim_min spikes go into a
%            single stratum. 
%         The default value is 2.
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
