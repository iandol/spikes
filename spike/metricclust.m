%METRICCLUST Cluster spike trains based on distance matrix.
%   CM = METRICCLUST(D,CATEGORIES,M,OPTS) uses a simple clustering
%   method to classify spike trains based on the distance matrix
%   D. CATEGORIES is a vector that gives the category indices of the
%   spike trains. M is the number of categories. CM is a square matrix
%   where the columns correspond to the actual classes and the rows
%   correspond to the assigned classes.
%
%   The options and parameters for this function are:
%      OPTS.clustering_exponent: A constant that controls the
%         clustering. Negative values emphasize smaller distances
%         and positive values emphasize larger distances. The
%         default is -2.
%
%   CM = METRICCLUST(D,CATEGORIES,M) uses the default options and parameters.
%
%   [CM,OPTS_USED] = METRICCLUST(D,CATEGORIES,M,OPTS) or
%   [CM,OPTS_USED] = METRICCLUST(D,CATEGORIES,M,OPTS) additionally
%   return the options used.
% 
%   See also METRICOPEN, METRICDIST.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
