function [out,opts_used]=metric(X,opts)
%METRIC Metric space analysis
%   Y = METRIC(X,OPTS) performs a metric space method to find the amount
%   of information conveyed by the spike trains in X about their
%   category membership. The results are stored in the structure
%   Y. If OPTS.shift_cost is a vector (see below), then Y will be a
%   vector of output structures.
%
%   The members of Y are:
%      Y.categories: A vector of the spike train category
%      indices. See METRICOPEN for details.
%      Y.d: The matrix of the distances between all possible spike
%         train pairs. See METRICDIST for details.
%      Y.cm: The confusion matrix resulting from clustering of the
%         distances. See METRICCLUST for details.
%      Y.table: A HIST2D structure version of the confusion
%         matrix. See MATRIX2HIST2D and INFO2D for details.
%
%   The options and parameters for this function are:
%      OPTS.start_time: The start time of the analysis window. The
%         default is the maximum of all of the start times in X. 
%      OPTS.end_time: The end time of the analysis window. The
%         default is the minimum of all of the end times in X.
%      OPTS.shift_cost: The cost of shifting a spike per unit time
%         relative to inserting or deleting a spike. This option may
%         be a vector of such values. The default is
%         1/(end_time-start_time).
%      OPTS.label_cost: This applies only to data sets with
%         simultaneously recorded spike trains. It is the cost of
%         altering a spike's label, and may range from 0 to 2. This
%         option may be a vector of such values whose length is equal
%         to OPTS.shift_cost. The default is 0.
%      OPTS.metric_family: Selects the metric to be used.
%         OPTS.metric_family=0: Uses D^spike metric.
%         OPTS.metric_family=1: Uses D^interval metric. This is
%            only applicable to single-site data.
%         The default value is 0.
%      OPTS.parallel: Selects which algorithm version to
%         use.
%         OPTS.parallel=0: Computes distances for a single shift_cost,
%             label_cost pairs at a time.
%         OPTS.parallel=1: Uses an algorithm that computes the
%             distances for all shift_cost,label_cost pairs
%             concurrently. When many parameters sets are being
%             analyzed, this method can provide considerable
%             computational savings. 
%         The default value is 0 if OPTS.shift_cost has one element
%             and 1 if OPTS.shift_cost has multiple elements.
%      OPTS.clustering_exponent: A constant that controls the
%         clustering. Negative values emphasize smaller distances
%         and positive values emphasize larger distances. The
%         default is -2.
%
%   Y = METRIC(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = METRIC(X) or [Y,OPTS_USED] = METRIC(X,OPTS)
%   additionally return the options used. 
%
%   See also METRICDIST, METRICCLUST, MATRIX2HIST2D, INFO2D, METRIC_SHUF,
%   METRIC_JACK.

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
      error('STAToolkit:metric:invalidArg',['opts.possible_words=''' opts.possible_words ''' should not be used with the metric space method.']);
    end
  elseif(isfield(opts,'bub_possible_words_strategy') && (opts.bub_possible_words_strategy~=0))
    error('STAToolkit:metric:invalidArg','Only opts.bub_possible_words_strategy=0 should be used with the metric space method.');
  end
end
if(isfield(opts,'entropy_estimation_method') && ~isempty(strmatch('tpmc',opts.entropy_estimation_method,'exact')))
  if(isfield(opts,'possible_words'))
    if(strcmpi(opts.possible_words,'total') || strcmpi(opts.possible_words,'possible') || strcmpi(opts.possible_words,'min_tot_pos') || strcmpi(opts.possible_words,'min_lim_tot_pos'))
      error('STAToolkit:metric:invalidArg',['opts.possible_words=''' opts.possible_words ''' should not be used with the metric space method.']);
    end
  elseif(isfield(opts,'tpmc_possible_words_strategy') && (opts.tpmc_possible_words_strategy~=0))
    error('STAToolkit:metric:invalidArg','Only opts.tpmc_possible_words_strategy=0 should be used with the metric space method.');
  end
end
if(isfield(opts,'entropy_estimation_method') && ~isempty(strmatch('ww',opts.entropy_estimation_method,'exact')))
  if(isfield(opts,'possible_words'))
    if(strcmpi(opts.possible_words,'total') || strcmpi(opts.possible_words,'possible') || strcmpi(opts.possible_words,'min_tot_pos') || strcmpi(opts.possible_words,'min_lim_tot_pos'))
      error('STAToolkit:metric:invalidArg',['opts.possible_words=''' opts.possible_words ''' should not be used with the metric space method.']);
    end
  elseif(isfield(opts,'ww_possible_words_strategy') && (opts.ww_possible_words_strategy~=0))
    error('STAToolkit:metric:invalidArg','Only opts.ww_possible_words_strategy=0 should be used with the metric space method.');
  end
end

[categories,times,labels,opts]=metricopen(X,opts);
[d,opts] = metricdist(X.N,times,labels,opts);

for idx=1:length(opts.shift_cost)
  out(idx).d = d(:,:,idx);
  [out(idx).cm,opts] = metricclust(out(idx).d,categories,X.M,opts);
  [out(idx).table,opts] = matrix2hist2d(out(idx).cm,opts);
  [out(idx).table,opts] = info2d(out(idx).table,opts);
  out(idx).M = X.M;
  out(idx).categories = categories;
end
opts_used = opts;
