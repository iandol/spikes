% Spike Train Analysis Toolkit table of contents.
%
% General functions and utilities.
%   make                      - Compile functions in the Spike Train Analysis Toolkit.
%   entropy1d                 - Entropy from a 1-D histogram.
%   entropy1dvec              - Entropy from a vector of 1-D histograms.
%   info2d                    - Information and entropies from a 2-D histogram.
%   infocond                  - Information and entropies from conditional and total histograms.
%   matrix2hist2d             - Converts a 2-D matrix of counts to a 2-D histogram.
%   staread                   - Read STAD and STAM files into an input data structure.  
%   stawrite                  - Write STAD and STAM files from an input data structure. 
%   staraster                 - Raster plot of an input data structure.
%   multisitearray            - Convert a multi-site input data structure
%   multisitesubset           - Extract a subset of sites from a multi-site
%   staversion                - Return the version and revision number of the Spike Train Analysis Toolkit.
%
% Demonstrations and verification.
%   demo/demo_all             - Run all directcat, binless, and metric information demos on the 'synth' and 'taste' datasets.
%   demo/demo_binless         - Run binless information demo on the 'synth', 'taste', or 'drift' datasets.
%   demo/demo_ctwmcmc         - Run CTWMCMC formal information demo on the 'inforate' datasets.
%   demo/demo_directcat       - Run directcat information demo on the 'synth', 'taste', or 'drift' datasets.
%   demo/demo_directformal    - Run directformal information demo on the 'inforate' datasets.
%   demo/demo_entropy         - Compare entropy estimates on sythentic data (not NSB).
%   demo/demo_metric          - Run metric information demo on the 'synth', 'taste', or 'drift' datasets.
%   demo/demo_metric_multi    - Run metric information demo on a multineuron dataset.
%   demo/demo_nsb             - Compare entropy estimates with NSB on reduced synthetic data.
%   demo/scalefig             - Scale a given figure window by a given factor.
%   demo/staverify            - Verify successful installation of the toolkit.
%
% Direct method.
%   directcat                 - Direct method analysis to determine category-specific information.
%   directcat_jack            - Direct method analysis to determine category-specific information with leave-one-out jackknife.
%   directcat_shuf            - Direct method analysis to determine category-specific information with shuffled inputs.
%   directformal              - Direct method analysis to determine formal information.
%   directbin                 - Bin spike trains for direct method analysis.
%   directcondcat             - Condition data on category.
%   directcondformal          - Condition data on both category and time slice.
%   directcondtime            - Condition data on time slice.
%   directcountclass          - Count spike train words in each class.
%   directcountcond           - Count spike train words in each class and disregarding class.
%   directcounttotal          - Count spike train words disregarding class.
% 
% Metric space method.
%   metric                    - Metric space analysis
%   metric_jack               - Metric space analysis with leave-one-out jackknife.
%   metric_shuf               - Metric space analysis with shuffled inputs.
%   metricopen                - Prepare input data structure for metric space analysis.
%   metricdist                - Compute distances between sets of spike train pairs.
%   metricclust               - Cluster spike trains based on distance matrix.
%
% Binless method.
%   binless                   - Binless method analysis.
%   binless_jack              - Binless method analysis with leave-one-out jackknife.
%   binless_shuf              - Binless method analysis with shuffled inputs.
%   binlessopen               - Extract useful information for binless method.
%   binlesswarp               - Warp spike times.
%   binlessembed              - Embed the spike trains.
%   binlessinfo               - Compute information components using binless method. 
%
% CTWMCMC method.
%   ctwmcmc                   - CTWMCMC method analysis.
%   ctwmcmctree               - Build CTW tree graph(s).
%   ctwmcmcsample             - Do MCMC sampling of entropy on CTW tree graph(s).
%   ctwmcmcbridge             - Build and sample CTW tree graph(s) without outputing tree(s) (to conserve memory).
%   ctwmcmcinfo               - Compute information from CTW entropy estimates.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%
