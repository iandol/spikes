%DIRECTBIN Bin spike trains for direct method analysis.
%   Y = DIRECTBIN(X,OPTS) returns a cell array Y with binned versions
%   of the spike trains in the input data structure X. Y has M rows
%   and N columns, where M is the number of categories and N is the
%   number of words per spike train. The rows of the members of Y
%   correspond to individual spike trains and the columns correspond
%   to time bins. The third dimension corresponds to individual
%   simultaneously recorded neurons.
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
%   Y = DIRECTBIN(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = DIRECTBIN(X) or [Y,OPTS_USED] =
%   DIRECTBIN(X,OPTS) additionally return the options used.
% 
%   See also DIRECTCONDCAT, DIRECTCONDTIME, DIRECTCONDFORMAL,
%   DIRECTCOUNTCLASS, DIRECTCOUNTTOTAL, DIRECTCOUNTCOND.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
