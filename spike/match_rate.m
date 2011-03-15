function [X_out, R_out] = match_rate(X_in, R_in, R)
% MATCH_RATE    Redraw samples to match spike rate
%
% usage:  [X_out] = match_rate(X_in, R_samples, R);
%
% arguments:   X_in -- Nx1 samples from distribution of
%                      estimated entropy rates
%              R_in -- Nx1 samples of spike rates associated with
%                      entropy rate estimates.
%                 R -- center (mean) spike rate
%
% outputs:    X_out -- samples of X_in adjusted to spike rate
%
% This function presumes a linear Ansatz between entropy rate and
% spike rate by finding a linear fit between X_in and R.
% It will adjust samples by removing this linear trend, i.e. 
% interpolating to given rate R. 
% 
% Original coding: Matt Kennel 2004
% Edited: Shlens 2006-02-14
%

% difference between sampled spike rate and mean spike rate
delta = abs(R_in - R);

% find N closest samples near whose spike rate is near R
[junk, sorted_indices] = sort(delta);

% select subset of spike rates and entropy rate estimates
X_subset = X_in(sorted_indices);
R_subset = R_in(sorted_indices); 

% fit a line between spike rate and entropy rate estimates
coef = polyfit(R_subset, X_subset, 1);

% make linear adjustment
X_R = polyval(coef, R);
X_out = X_subset - polyval(coef,R_subset) + X_R;

% save output of spike rates
R_out = R_subset;
