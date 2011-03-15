function [out,shuf,opts_used]=binless_shuf(X,opts,S)
%BINLESS_SHUF Binless method analysis with shuffled inputs.
%   [Y,SHUF] = BINLESS_SHUF(X,OPTS,S) performs a binless method
%   analysis on input data structure X. In addition to the typical
%   analysis, this function also analyzes S versions of X with the
%   categories randomly shuffled. Y is an output structure with the
%   results of the typical analysis and SHUF is an Sx1 array of output
%   structures with the results for each category permutation. For
%   information on the output structure, see BINLESS.
%
%   For information on options and parameters see BINLESS.
%
%   [Y,SHUF] = BINLESS_SHUF(X,[],S) uses the default options and parameters.
%
%   [Y,SHUF,OPTS_USED] = BINLESS_SHUF(X,[],S) or [Y,SHUF,OPTS_USED] =
%   BINLESS_SHUF(X,OPTS,S) additionally return the options used. 
%
%   See also BINLESS, BINLESS_JACK.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
[out,opts]=binless(X,opts);

P_total = length(out.categories);

for s=1:S
  shuf(s).times = out.times;
  shuf(s).warped = out.warped;
  shuf(s).categories = out.categories(randperm(P_total));
  shuf(s).embedded = out.embedded;
  [shuf(s).I_part,shuf(s).I_cont,shuf(s).I_count,shuf(s).I_total,opts] = ...
      binlessinfo(shuf(s).embedded,out.counts,shuf(s).categories,X.M,opts);
end
opts_used = opts;
