function [out,shuf,opts_used]=metric_shuf(X,opts,S)
%METRIC_SHUF Metric space analysis with shuffled inputs.
%   [Y,SHUF] = METRIC_SHUF(X,OPTS,S) performs a metric space method
%   analysis on input data structure X. In addition to the typical
%   analysis, this function also analyzes S versions of X with the
%   categories randomly shuffled. Y is an output structure with the
%   results of the typical analysis and SHUF is an Sx1 array of output
%   structures with the results for each category permutation. For
%   information on the output structure, see METRIC.
%
%   For information on options and parameters see METRIC.
%
%   [Y,SHUF] = METRIC_SHUF(X,[],S) uses the default options and parameters.
%
%   [Y,SHUF,OPTS_USED] = METRIC_SHUF(X,[],S) or [Y,SHUF,OPTS_USED] =
%   METRIC_SHUF(X,OPTS,S) additionally return the options used. 
%
%   See also METRIC, METRIC_JACK.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
[out,opts]=metric(X,opts);

for idx=1:length(opts.shift_cost)
  for s=1:S
    shuf(idx,s).categories = out(idx).categories(randperm(length(out(idx).categories)));
    [shuf(idx,s).cm,opts] = metricclust(out(idx).d,shuf(idx,s).categories,X.M,opts);
    [shuf(idx,s).table,opts] = matrix2hist2d(shuf(idx,s).cm,opts);
    [shuf(idx,s).table,opts] = info2d(shuf(idx,s).table,opts);
    shuf(idx,s).M = X.M;
  end
end
opts_used = opts;



