%INFOCOND Information and entropies from conditional and total
%histograms.  
%   Y = INFOCOND(X,OPTS) takes a HISTCOND structure X and copies it to
%   Y, adding estimates of entropies and mutual
%   information. Y.INFORMATION is an ESTIMATE structure corresponding
%   to the mutual information. ESTIMATE structures corresponding to
%   entropies are added to Y.CLASS and Y.TOTAL.
%
%   The options and parameters for this function are:
%      OPTS.ENTROPY_ESTIMATION_METHOD
%      OPTS.VARIANCE_ESTIMATION_METHOD: A cell array of variance
%      estimation methods.
%   Please see the Spike Train Analysis Toolkit documentation for
%   more information.
%         
%   Y = INFOCOND(X) does not perform any bias correction or variance
%      estimation. 
%
%   [Y,OPTS_USED] = INFOCOND(X,OPTS) copies OPTS into OPTS_USED.
% 
%   See also MATRIX2HIST2D, INFO2D, ENTROPY1D.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
