function [out,jk,opts_used]=metric_jack(X,opts)
%METRIC_JACK Metric space analysis with leave-one-out jackknife.
%   [Y,JK] = METRIC_JACK(X,OPTS) performs a metric space method
%   analysis on input data structure X. In addition to the typical
%   analysis, this function also does a leave-one-out jackknife. Y
%   is an output structure with the results of the typical analysis
%   and JK is an array of output structures with the results for
%   each jackknife trial. There are as many elements in JK as there
%   are spike trains in X. For information on the output structure,
%   see METRIC. 
%
%   For information on options and parameters see METRIC.
%
%   [Y,JK] = METRIC_JACK(X) uses the default options and parameters.
%
%   [Y,JK,OPTS_USED] = METRIC_JACK(X) or [Y,JK,OPTS_USED] =
%   METRIC_JACK(X,OPTS) additionally return the options used. 
%
%   See also METRIC, METRIC_SHUF.

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

[out,opts]=metric(X,opts);

for idx=1:length(opts.shift_cost)
  P_total=length(out(idx).categories);
  for p=1:P_total
    d = out(idx).d([1:p-1 p+1:end],[1:p-1 p+1:end]);
    jk(p,idx).categories = out(idx).categories([1:p-1 p+1:end]);
    jk(p,idx).cm = metricclust(d,jk(p,idx).categories,X.M,opts);
    jk(p,idx).table = matrix2hist2d(jk(p,idx).cm,opts);
    jk(p,idx).table = info2d(jk(p,idx).table,opts);
    jk(p,idx).M = X.M;
  end
end 
opts_used = opts;
