%BINLESSOPEN Extract useful information for binless method.
%   [DATA,COUNTS,CATEGORIES] = BINLESSOPEN(X,OPTS) opens the input
%   data structure X and extracts information required for analysis
%   with the binless method. DATA is a cell array of spike trains
%   (episodic) or samples (continuous). COUNTS is a vector of the
%   number of spikes or samples in each element of DATA. CATEGORIES is
%   a vector of the categories of the items in DATA.
%
%   The options and parameters for this function are:
%      OPTS.start_time: The start time of the analysis window. The
%         default is the maximum of all of the start times in X. 
%      OPTS.end_time: The end time of the analysis window. The
%         default is the minimum of all of the end times in X.
%
%   [DATA,COUNTS,CATEGORIES] = BINLESSOPEN(X) uses the default options
%   and parameters.
%
%   [DATA,COUNTS,OPTS_USED] = BINLESSOPEN(X) or
%   [DATA,COUNTS,CATEGORIES,OPTS_USED] = BINLESSOPEN(X,OPTS)
%   additionally returns the options used.
% 
%   Note that the option OPTS.recording_tag, which is used by
%   BINLESSEMBED, is explicitly set by this function according to the
%   recording_tag of the input data ('episodic' or 'continuous').
%   Likewise, when X contains continuous data, OPTS.warping_strategy,
%   which is used by BINLESSWARP, is explicitly set to 0 (linear
%   scaling), as no other choice currently makes sense. Therefore, it
%   is recommended that the output options OPTS_USED be passed
%   serially from BINLESSOPEN to subsequent binless method functions,
%   as is done in BINLESS.
%
%   See also BINLESS, BINLESSWARP, BINLESSEMBED, BINLESSINFO.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
