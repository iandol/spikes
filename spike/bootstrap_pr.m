function T = bootstrap_pr(A,N,L)
% BOOTSTRAP_PR    Politis-Romano method for correlated bootstrap
%
% usage:   [T] = bootstrap_pr(A, N, L); 
%
% arguments:   A - range of integers 1:A to perform bootstrap on
%              N - length of integers to select bootstraps from
%              L - average length of bootstrap blocks. Each 
%                  bootstrap block has length k, such that:
%                   1. P(k) = q*(1-q)^(k-1)
%                   2. (P(k) * k> = L
%                   3. q = 1/L  
%
% outputs:     T - Nx1 vector of bootstrap indices
%
% This function performs the 'stationary bootstrap' of integers
% 1:N according together the method detailed in:
%
%     Politis & Romano (1994) Journal Amer. Stat. Assoc.
%
% This algorithm is used for drawing bootstrap samples from a 
% correlated time series indexed by the integers outputted from
% this function.
%
% Algorithm: We start with a random starting location, and with 
% probability q the next value is drawn again, and with probability
% (1-p) it is consecutive from the previous value.
%
% Original coding: Matt Kennel 2004
% Edited: Shlens 2006-02-14
%

% check if zero
if ~(L > 0)
  error('correlation length must be positive');
end

% generate random start locations
start_locations = random('unid',A,1,N)';


% special case
if (L==1)
  T = start_locations;
  return
end

% probability of jumping to new block
q = 1.0/L;

% generate geometrically-distributed block durations
block_durations = geornd(q,1,N);

% bootstrap indices
T = zeros(N,1);
count = 0;

% generate list of N bootstrap indices
while (count < N),
  
  % increment count
  count = count + 1;
  
  % select random start location
  T(count) = start_locations(count);
  
  % select random block duration
  block_size = block_durations(count);

  % append on blocks
  if (block_size > 0),
    T(count+1 : count+block_size) = T(count) + [1:block_size];
    count = count + block_size;
  end

end

% truncate at desired length
T = T(1:N,1);

% convert to a circular bootstrap
T = mod(T-1,A)+1;

