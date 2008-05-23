%BINLESSWARP Warp spike times.
%   Y = BINLESSWARP(X,OPTS) warps the spike trains in cell array X
%   to give spike trains in cell array Y. 
%
%   The options and parameters for this function are:
%      OPTS.start_warp: The lower limit of the warping. The default
%         is -1.  
%      OPTS.end_warp: The upper limit of the warping. The
%         default is 1. 
%      OPTS.warping_strategy: The strategy for warping. 
%         OPTS.warping_strategy=0 means the spike times in X are
%            linearly scaled to fall between OPTS.start_warp and
%            opts.end_warp.  
%         OPTS.warping_strategy=1 means the spike times are
%            uniformly spaced between OPTS.start_warp and
%            opts.end_warp.  
%         The default value is 1.
%
%   Y = BINLESSWARP(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = BINLESSWARP(X) or [Y,OPTS_USED] =
%   BINLESSWARP(X,OPTS) additionally return the options used.
% 
%   See also BINLESSINFO, BINLESSEMBED, BINLESSINFO.
