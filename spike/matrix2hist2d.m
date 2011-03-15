%MATRIX2HIST2D Converts a 2-D matrix of counts to a 2-D histogram.
%   Y = MATRIX2HIST2D(X,OPTS) converts a matrix of counts X to a
%   HIST2D structure. Y.ROW and Y.COL are HIST1D structures that
%   correspond to the marginal counts and Y.JOINT is a HIST1D
%   structure that corresponds to the joint counts.
%
%   The options and parameters for this function are:
%      OPTS.UNOCCUPIED_BINS_STRATEGY: The strategy for treating
%         unoccupied bins in the count matrix.
%         OPTS.UNOCCUPIED_BINS_STRATEGY=-1 ignores unoccupied bins. 
%         OPTS.UNOCCUPIED_BINS_STRATEGY=0 uses an unoccupied bin
%            only if its row and column are occupied.
%         OPTS.UNOCCUPIED_BINS_STRATEGY=1 uses all bins.
%         The default value is -1.
%
%   Y = MATRIX2HIST2D(X) uses the default options and parameters.
%
%   [Y,OPTS_USED] = MATRIX2HIST2D(X) or [Y,OPTS_USED] =
%   MATRIX2HIST2D(X,OPTS) additionally return the options used. 
% 
%   See also INFO2D.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
