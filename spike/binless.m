function [out,opts_used]=binless(X,opts)
%BINLESS Binless method analysis.
%   Y = BINLESS(X,OPTS) performs a binless method to find the amount
%   of information conveyed by the spike trains in X about their
%   category membership. The results are stored in the structure
%   Y.
%
%   The members of Y are:
%      Y.times: A cell array of spike trains. See BINLESSOPEN
%         for details.
%      Y.counts: A cell array of spike counts. See BINLESSOPEN
%         for details.
%      Y.categories: A vector of the categories of the spike
%         trains. SEE BINLESSOPEN for details.
%      Y.warped: A warped version of the spike trains. See
%         BINLESSWARP for details.
%      Y.embedded: An embedded version of the spike trains. See
%         BINLESSEMBED for details.
%      Y.I_part: The information conveyed by zero-distance spike
%         trains and singletons. See BINLESSINFO for details.  
%      Y.I_cont: The continuous component of the information
%         which describes the separability of the embedded spike
%         trains.See BINLESSINFO for details. 
%      Y.I_count: The information conveyed by the number of
%         spikes in the spike trains. See BINLESSINFO for details. 
%      Y.I_total: The sum of all of the information
%         components. See BINLESSINFO for details. 
%
%   The options and parameters for this function are:
%      OPTS.start_time: The start time of the analysis window. The
%         default is the maximum of all of the start times in X. 
%      OPTS.end_time: The end time of the analysis window. The
%         default is the minimum of all of the end times in X.
%      OPTS.start_warp: The lower limit of the warping. The default
%         is -1.  
%      OPTS.end_warp: The upper limit of the warping. The
%         default is 1. 
%      OPTS.warping_strategy: The strategy for warping. 
%         OPTS.warping_strategy=0 means the spike times in X are
%            linearly scaled to fall between OPTS.start_warp and
%            opts.end_warp.  
%         OPTS.warping_strategy=1 means the spike times are
%            uniformly spaced between OPTS.start_warp and
%            opts.end_warp.  
%         The default value is 1.
%      OPTS.min_embed_dim: The minimal embedding dimension. The
%         default is 1.  
%      OPTS.max_embed_dim: The maximal embedding dimension. The
%         default is 2.  
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
%   Y = BINLESS(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = BINLESS(X) or [Y,OPTS_USED] = BINLESS(X,OPTS)
%   additionally return the options used. 
%
%   See also BINLESSOPEN, BINLESSWARP, BINLESSEMBED, BINLESSINFO,
%   BINLESS_SHUF, BINLESS_JACK.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
if(nargin<2)
  opts=[];
end

% Parameter checking necessary to avoid nonsensical options
if(isfield(opts,'entropy_estimation_method') && ~isempty(strmatch('bub',opts.entropy_estimation_method,'exact')))
  if(isfield(opts,'possible_words'))
    if(strcmpi(opts.possible_words,'total') || strcmpi(opts.possible_words,'possible') || strcmpi(opts.possible_words,'min_tot_pos') || strcmpi(opts.possible_words,'min_lim_tot_pos'))
      error('STAToolkit:binless:invalidArg',['opts.possible_words=''' opts.possible_words ''' should not be used with the binless method.']);
    end
  elseif(isfield(opts,'bub_possible_words_strategy') && (opts.bub_possible_words_strategy~=0))
    error('STAToolkit:binless:invalidArg','Only opts.bub_possible_words_strategy=0 should be used with the binless method.');
  end
end
if(isfield(opts,'entropy_estimation_method') && ~isempty(strmatch('tpmc',opts.entropy_estimation_method,'exact')))
  if(isfield(opts,'possible_words'))
    if(strcmpi(opts.possible_words,'total') || strcmpi(opts.possible_words,'possible') || strcmpi(opts.possible_words,'min_tot_pos') || strcmpi(opts.possible_words,'min_lim_tot_pos'))
      error('STAToolkit:binless:invalidArg',['opts.possible_words=''' opts.possible_words ''' should not be used with the binless method.']);
    end
  elseif(isfield(opts,'tpmc_possible_words_strategy') && (opts.tpmc_possible_words_strategy~=0))
    error('STAToolkit:binless:invalidArg','Only opts.tpmc_possible_words_strategy=0 should be used with the binless method.');
  end
end
if(isfield(opts,'entropy_estimation_method') && ~isempty(strmatch('ww',opts.entropy_estimation_method,'exact')))
  if(isfield(opts,'possible_words'))
    if(strcmpi(opts.possible_words,'total') || strcmpi(opts.possible_words,'possible') || strcmpi(opts.possible_words,'min_tot_pos') || strcmpi(opts.possible_words,'min_lim_tot_pos'))
      error('STAToolkit:binless:invalidArg',['opts.possible_words=''' opts.possible_words ''' should not be used with the binless method.']);
    end
  elseif(isfield(opts,'ww_possible_words_strategy') && (opts.ww_possible_words_strategy~=0))
    error('STAToolkit:binless:invalidArg','Only opts.ww_possible_words_strategy=0 should be used with the binless method.');
  end
end

[out.times,out.counts,out.categories,opts] = binlessopen(X,opts);
[out.warped,opts] = binlesswarp(out.times,opts);
[out.embedded,opts] = binlessembed(out.warped,opts);
[out.I_part,out.I_cont,out.I_count,out.I_total,opts] = ...
  binlessinfo(out.embedded,out.counts,out.categories,X.M,opts);
opts_used = opts;
