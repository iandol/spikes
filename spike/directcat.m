function [out,opts_used]=directcat(X,opts)
%DIRECTCAT Direct method analysis to determine category-specific information.
%   Y = DIRECTCAT(X,OPTS) uses the direct method to find the amount
%   of information conveyed by the spike trains in X about their
%   category membership. The results are stored in the structure Y.
%
%   The members of Y are:
%      Y.binned: Binned versions of the spike trains. See DIRECTBIN
%         for details.
%      Y.cond: A HISTCOND structure with word counts for total and
%         class-conditional histograms. See DIRECTCOUNTCOND and
%         INFOCOND for details. 
%
%   The options and parameters for this function are:
%      OPTS.start_time: The start time of the analysis window. The
%         default is the maximum of all of the start times in X. 
%      OPTS.end_time: The end time of the analysis window. The
%         default is the minimum of all of the end times in X.
%      OPTS.counting_bin_size: The size of the counting bins in
%         seconds. The default is OPTS.end_time-OPTS.start_time.
%      OPTS.sum_spike_trains: For data sets with simultaneously
%         recorded spike trains, this determines whether the
%         simultaneous spikes are summed across time bins.
%         OPTS.sum_spike_trains=0 means there is no summing.
%         OPTS.sum_spike_trains=1 means there is summing.
%         The default value is 0.
%      OPTS.permute_spike_trains: For data sets with simultaneously
%         recorded spike trains, this determines whether sets of
%         simultaneous spike trains that are permuted should be
%         considered identical.
%         OPTS.permute_spike_trains=0 means they are considered
%            distinct.
%         OPTS.permute_spike_trains=1 means they are considered
%            indentical.
%         The default value is 0.
%
%   Y = DIRECTCAT(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = DIRECTCAT(X) or [Y,OPTS_USED] = DIRECT(X,OPTS)
%   additionally return the options used. 
%
%   See also DIRECTFORMAL, DIRECTBIN, DIRECTCONDCAT,
%   DIRECTCOUNTCOND, INFOCOND, DIRECTCAT_SHUF, DIRECTCAT_JACK.

%
%  Copyright 2006, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
if(nargin<2)
  opts=[];
end
  
[out.binned,opts] = directbin(X,opts);
[out.cond,opts] = directcountcond(out.binned,opts);
[out.cond,opts] = infocond(out.cond,opts);
out.M = X.M;
opts_used = opts;
