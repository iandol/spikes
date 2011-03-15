%BINLESSEMBED Embed the data with the Legendre polynomials.
%   Y = BINLESSEMBED(X,OPTS) embeds the data in cell array X with
%   Legendre polynomials. Y is a matrix with OPTS.max_embed_dim+1 or
%   OPTS.cont_max_embed_dim+1 columns, which contains the embedding
%   coordinates for all polynomials, from the zeroth order, up to the
%   specified maximum. Future versions may feature other embedding
%   functions.
%
%   The options and parameters for this function are:
%      OPTS.recording_tag: The type of recording, namely, 'episodic'
%         (e.g. spike trains) or 'continuous' (e.g., LFP). If
%         unspecified, 'episodic' is assumed for backwards
%         compatibility.
%      OPTS.max_embed_dim: The maximal embedding dimension for
%         episodic data. The default is 2. (Related option
%         OPTS.min_embed_dim is used by BINLESSINFO.)
%      OPTS.cont_max_embed_dim: The maximal embedding dimension for
%         continuous data. The default is 2. (Related option
%         OPTS.cont_min_embed_dim is used by BINLESSINFO.)
%      OPTS.start_warp: The lower limit of the warping. This option is
%         only needed when using continuous data. The default is -1.
%      OPTS.end_warp: The upper limit of the warping. This option is
%         only needed when using continuous data. The default is 1.
%
%   Y = BINLESSEMBED(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = BINLESSEMBED(X) or [Y,OPTS_USED] =
%   BINLESSEMBED(X,OPTS) additionally return the options used.
% 
%   See also BINLESSINFO, BINLESSWARP, BINLESSINFO.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
