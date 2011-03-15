function [out,opts_used]=directformal(X_uni,X_rep,opts)
%DIRECTFORMAL Direct method analysis to determine formal information.
%   Y = DIRECTFORMAL(X_UNI,X_REP,OPTS) uses the direct method to
%   find the formal information. X_UNI is an input data structure
%   with spike trains obtained from distinct stimuli and is used to
%   estimate the "total" entropy. Each spike train is considered to
%   be in its own stimulus category. X_REP is an input data
%   structure with spike trains obtained from repitition of the
%   same stimulus. The results are stored in the structure Y.
%
%   The members of Y are:
%      Y.uni_binned: Binned versions of the spike trains in
%         X_UNI. See DIRECTBIN for details. 
%      Y.rep_binned: Binned versions of the spike trains in
%         X_REP. See DIRECTBIN for details.
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
%      OPTS.words_per_train: The number of words that the spike trains
%         will be divided into.
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
%      OPTS.legacy_binning: Allows binning to be done in a manner
%         compatible with version 1.1 and earlier of the toolkit.
%         These older versions created an extra (empty) bin when
%         (OPTS.end_time-OPTS.start_time) is an integer multiple of
%         (OPTS.words_per_train*OPTS.counting_bin_size).
%         OPTS.legacy_binning=0 means use the current binning method.
%         OPTS.legacy_binning=1 means use the legacy binning method.
%         The default value is 0.
%      OPTS.letter_cap: Places a cap on the maximum number of spikes
%         to be counted in a bin. The default value is Inf.
%
%   Y = DIRECTFORMAL(X_UNI,X_REP) uses the default options and parameters.
%
%   [Y,OPTS_USED] = DIRECTFORMAL(X_UNI,X_REP) or [Y,OPTS_USED] =
%   DIRECTFORMAL(X_UNI,X_REP,OPTS) additionally return the options
%   used.
%
%   See also DIRECTCAT, DIRECTBIN, DIRECTCONDTIME,
%   DIRECTCONDFORMAL, DIRECTCOUNTCLASS, DIRECTCOUNTTOTAL.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
if(nargin<3)
  opts=[];
end
  
[out.uni_binned,opts] = directbin(X_uni,opts);
out.uni_binned = directcondformal(out.uni_binned);
[out.cond.total,opts] = directcounttotal(out.uni_binned,opts);
  
[out.rep_binned,opts] = directbin(X_rep,opts);
out.rep_binned = directcondtime(out.rep_binned);
[out.cond.class,opts] = directcountclass(out.rep_binned,opts);

[out.cond,opts] = infocond(out.cond,opts);

opts_used = opts;
