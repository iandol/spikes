%BINLESSOPEN Extract useful information for binless method.
%   [TIMES,COUNTS,CATEGORIES] = BINLESSOPEN(X,OPTS) opens the input data
%   structure X and extracts information required for analysis with
%   the binless method. TIMES is a cell array of spike
%   trains. COUNTS is a vector of the number of spikes in each
%   element of TIMES. CATEGORIES is a vector of the categories of
%   the spike trains in TIMES.
%
%   The options and parameters for this function are:
%      OPTS.start_time: The start time of the analysis window. The
%         default is the maximum of all of the start times in X. 
%      OPTS.end_time: The end time of the analysis window. The
%         default is the minimum of all of the end times in X.
%
%   [TIMES,COUNTS,CATEGORIES] = BINLESSOPEN(X) uses the default
%   options and parameters.
%
%   [TIMES,COUNTS,OPTS_USED] = BINLESSOPEN(X) or
%   [TIMES,COUNTS,CATEGORIES,OPTS_USED] = BINLESSOPEN(X,OPTS) additionally
%   return the options used.
% 
%   See also BINLESSWARP, BINLESSEMBED, BINLESSINFO.

