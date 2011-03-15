function [out,jk,opts_used]=binless_jack(X,opts)
%BINLESS_JACK Binless method analysis with leave-one-out jackknife.
%   [Y,JK] = BINLESS_JACK(X,OPTS) performs a binless method analysis
%   on input data structure X. In addition to the typical analysis,
%   this function also does a leave-one-out jackknife. Y is an output
%   structure with the results of the typical analysis and JK is an
%   array of output structures with the results for each jackknife
%   trial. There are as many elements in JK as there are spike trains
%   in X. For information on the output structure, see BINLESS.
%
%   For information on options and parameters see BINLESS.
%
%   [Y,JK] = BINLESS_JACK(X) uses the default options and parameters.
%
%   [Y,JK,OPTS_USED] = BINLESS_JACK(X) or [Y,JK,OPTS_USED] =
%   BINLESS_JACK(X,OPTS) additionally return the options used. 
%
%   See also BINLESS, BINLESS_SHUF.

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

[out,opts]=binless(X,opts);

P_total=length(out.categories);

for p=1:P_total
  jk(p).times = out.times;
  jk(p).warped = out.warped;
  jk(p).categories = out.categories([1:p-1 p+1:end]);
  jk(p).counts = out.counts([1:p-1 p+1:end]);
  jk(p).embedded = out.embedded([1:p-1 p+1:end],:);
  [jk(p).I_part,jk(p).I_cont,jk(p).I_count,jk(p).I_total,opts] = ...
      binlessinfo(jk(p).embedded,jk(p).counts,jk(p).categories,X.M,opts);
end
opts_used = opts;
