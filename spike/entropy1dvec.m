%ENTROPY1DVEC Entropy from a vector of 1-D histograms.
%   Y = ENTROPY1DVEC(X,OPTS) takes a HIST1DVEc structure X and copies it to
%   Y, adding and estimate of the entropy. Y.ENTROPY is an ESTIMATE
%   structure. 
%
%   The options and parameters for this function are:
%      OPTS.ENTROPY_ESTIMATION_METHOD
%      OPTS.VARIANCE_ESTIMATION_METHOD: A cell array of variance
%      estimation methods.
%   Please see the Spike Train Analysis Toolkit documentation for
%   more information.
%         
%   Y = ENTROPY1DVEC(X) does not do any bias correction or variance
%      estimation. 
%
%   [Y,OPTS_USED] = ENTROPY1DVEC(X,OPTS) copies OPTS into OPTS_USED.
%
%   See also ENTROPY1D, INFOCOND, INFO2D.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
