%METRICOPEN Prepare input data structure for metric space analysis.
%   [CATEGORIES,TIMES,LABELS] = METRICOPEN(X,OPTS) opens input data
%   structure X and generates several useful matrices.
%
%   TIMES is an Px1 cell array of spike times where P is the number of
%   trials in the data set. Each member of the cell array consists of
%   spike times interleaved from simultaneous trials.
%
%   LABELS is a Px1 cell array with labels of the spikes in TIMES.
%
%   CATEGORIES is a vector that gives the category indices of spike
%   trains in TIMES.
%
%   The options and parameters for this function are:
%      OPTS.start_time: The start time of the analysis window. The
%         default is the maximum of all of the start times in X. 
%      OPTS.end_time: The end time of the analysis window. The
%         default is the minimum of all of the end times in X.
%
%   [CATEGORIES,TIMES,LABELS] = METRICOPEN(X) uses the default options
%   and parameters.
%
%   [CATEGORIES,TIMES,LABELS,OPTS_USED] = METRICOPEN(X) or
%   [CATEGORIES,TIMES,LABELS,OPTS_USED] = METRICOPEN(X,OPTS)
%   additionally return the options used.
% 
%   See also METRICDIST, METRICCLUST.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
