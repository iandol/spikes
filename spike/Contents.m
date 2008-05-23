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
