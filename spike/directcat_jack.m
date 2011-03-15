function [out,jk,opts_used]=directcat_jack(X,opts)
%DIRECTCAT_JACK Direct method analysis to determine category-specific information with leave-one-out jackknife.
%   [Y,JK] = DIRECTCAT_JACK(X,OPTS) performs a direct method
%   analysis on input data structure X. In addition to the typical
%   analysis, this function also does a leave-one-out jackknife. Y
%   is an output structure with the results of the typical analysis
%   and JK is an array of output structures with the results for each
%   jackknife trial. There are as many elements in JK as there are
%   spike trains in X. For information on the output structure, see
%   DIRECTCAT. 
%
%   For information on options and parameters see DIRECT.
%
%   [Y,JK] = DIRECTCAT_JACK(X) uses the default options and parameters.
%
%   [Y,JK,OPTS_USED] = DIRECTCAT_JACK(X) or [Y,JK,OPTS_USED] =
%   DIRECT_JACK(X,OPTS) additionally return the options used. 
%
%   See also DIRECTCAT, DIRECTCAT_SHUF.

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

[out,opts] = directcat(X,opts);

p_total=0;
for m=1:X.M
  for p=1:X.categories(m).P
    p_total = p_total+1;
    jk(p_total).binned = out.binned;
    jk(p_total).binned{m} = out.binned{m}([1:p-1 p+1:end],:);
    [jk(p_total).cond,opts] = directcountcond(jk(p_total).binned,opts);
    [jk(p_total).cond,opts] = infocond(jk(p_total).cond,opts);
    jk(p_total).M = X.M;
  end
end
opts_used = opts;
