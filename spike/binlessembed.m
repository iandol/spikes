%BINLESSEMBED Embed the spike trains.
%   Y = BINLESSEMBED(X,OPTS) embeds the spike trains in cell array
%   X with Legendre polynomials. Y is a matrix with
%   OPTS.max_embed_dim columns. Future versions may feature other
%   embedding functions.
%
%   The options and parameters for this function are:
%      OPTS.min_embed_dim: The minimal embedding dimension. The
%         default is 1.  
%      OPTS.max_embed_dim: The maximal embedding dimension. The
%         default is 2.  
%
%   Y = BINLESSEMBED(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = BINLESSEMBED(X) or [Y,OPTS_USED] =
%   BINLESSEMBED(X,OPTS) additionally return the options used.
% 
%   See also BINLESSINFO, BINLESSWARP, BINLESSINFO.
