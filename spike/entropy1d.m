%ENTROPY1D Entropy from a 1-D histogram.
%   Y = ENTROPY1D(X,OPTS) takes a HIST1D structure X and copies it to
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
%   Y = ENTROPY1D(X) does not do any bias correction or variance
%      estimation. 
%
%   [Y,OPTS_USED] = ENTROPY1D(X,OPTS) copies OPTS into OPTS_USED.
%
%   See also ENTROPY1DVEC, INFOCOND, INFO2D.
