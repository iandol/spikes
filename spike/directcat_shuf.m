function [out,shuf,opts_used]=directcat_shuf(X,opts,S)
%DIRECTCAT_SHUF Direct method analysis to determine category-specific information with shuffled inputs.
%   [Y,SHUF] = DIRECTCAT_SHUF(X,OPTS,S) performs a direct method
%   analysis on input data structure X. In addition to the typical
%   analysis, this function also analyzes S versions of X with the
%   categories randomly shuffled. Y is an output structure with the
%   results of the typical analysis and SHUF is an Sx1 array of output
%   structures with the results for each category permutation. For
%   information on the output structure, see DIRECTCAT.
%
%   For information on options and parameters see DIRECT.
%
%   [Y,SHUF] = DIRECTCAT_SHUF(X,[],S) uses the default options and parameters.
%
%   [Y,SHUF,OPTS_USED] = DIRECTCAT_SHUF(X,[],S) or [Y,SHUF,OPTS_USED] =
%   DIRECTCAT_SHUF(X,OPTS,S) additionally return the options used. 
%
%   See also DIRECTCAT, DIRECTCAT_JACK.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
[out,opts] = directcat(X,opts);

P_total = size(out.binned,1);

for s=1:S
  shuf(s).binned = out.binned;
  shuf(s).binned = shuffle(out.binned);
  [shuf(s).cond,opts] = directcountcond(shuf(s).binned,opts);
  [shuf(s).cond,opts] = infocond(shuf(s).cond,opts);
  shuf(s).M = X.M;
end
opts_used = opts;

function out=shuffle(in)

M = size(in,1);
temp = [];

% Get them all in a matrix
for m=1:M
  P(m) = size(in{m},1);
  temp = [temp;in{m}];
end

% Permute them
P_total = sum(P);
P_cum = cumsum(P);
P_cum =[0 P_cum];
temp2 = temp(randperm(P_total),:);

% Put them back
for m=1:M
  out{m,1} = temp2(P_cum(m)+1:P_cum(m+1),:);
end
