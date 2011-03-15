function X = correlated_bootstrap(X_t, N, spike_rate)
% CORRELATED_BOOTSTRAP    Calculate correlated bootstrap samples of P(X(t))
%
% usage 1:     [X] = correlated_bootstrap(X_t);
%              [X] = correlated_bootstrap(X_t, N);
% usage 2:     [X] = correlated_bootstrap(X_t, N, spike_rate);
%
% Inputs:     X_t  -  [N_mc x T] matrix of N_mc samples from a
%                     distribution P(X(t) where X_t(:,i) are N_mc
%                     samples from time i.
%
%               N  -  number of desired samples [default = 199]
%
%       spike_rate -  [1xT] vector spike rates. [optional] 
%        
% Outputs:      X  -  [1xN] samples from distribution P(X). Calculate
%                     confidence intervals using PRCTILE.
%
% Compute N samples from distribution P(X) when all is known is
% N_mc samples from P(X(t)) for each moment in time t=[1,T] and
% samples from P(X(t=a)) is correlated with P(X(t=a+b)).
%
% Usage 1: Standard correlated bootstrap procedure.
%
% Usage 2: Correlated bootstrap but adjust P(X(t)) according to the
%          linear relationship with the spike rate. Specifiying the
%          spike rate centers the resampled estimates about the
%          mean spike rate.
%
% See also: PRCTILE, BOOTSTRAP_PR
%
% Original coding - Kennel
% Edited - shlens 2005-09-23
% Edited - shlens 2006-02-14
%


% always start with same random seed
%rand('state',10);
%rand('seed',10);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. PROCESS ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% defaults
default_N = 199;

% check if spike rate is matched
if nargin < 3
  is_match = 0;
  spike_rate = [];
else
  % spike rate is matched
  is_match = 1;
end

% check if number of samples is requested
if nargin < 2
  N = default_N;
end

% find size of X_t
[N_mc,T] = size(X_t);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. DETERMINE CORRELATION LENGTH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate autocovariance of mean of distribution
X_mean = mean(X_t,1);
autocov = xcov(X_mean,'coeff');
% -- average symmetric lobes and recenter
autocov = (autocov(T:2*T-1) + autocov(T:-1:1))/2;

% find first zero crossing in AC
less_than_zero = find(autocov<0);

if isempty(less_than_zero)
  correlation_length = 1;
else
  correlation_length = less_than_zero(1);
end

% correlation heuristic to set effective L
L = 2 * correlation_length;


% always start with same random seed
rand('state',10);
rand('seed',10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. SETUP BOOTSTRAP CALCULATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% number of samples
N_raw = ceil(N);

% statistics on statistic of interest
[N_mc, T] = size(X_t);       % size of X(t)
X_t_mean   = mean(X_t);      % mean value of X(t)
X_mean = mean(X_t_mean);     % statistic T on observed data

% generated samples
spike_rate_samples = zeros(1,N_raw); % spike rate at individual samples
X_samples_raw      = zeros(1,N_raw); % individual samples of P(X)

% update the user
% fprintf(1,['Calculating bootstrap samples (L = ' ...
%        num2str(L) ', N = ' num2str(N) ') ... ']); %commented out by MAR for inclusion in STAToolkit


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. CALCULATE CORRLATED BOOTSTRAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate samples
for i=1:N_raw

  % generate correlated bootstrap indices
  index_boot = bootstrap_pr(T, T, L);
  
  % generate 1 bootstrap statistic sample
  X_boot = mean(resample_statistic(X_t, index_boot));

  % calculate adjusted bootstrap estimate 
  X_raw(i) = 2 * X_mean - X_boot;
  
  % save the spike rate associated with the time indexes
  if is_match
    spike_rate_samples(i) = mean(spike_rate(index_boot));
  end;
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. MATCH SAMPLE TO SPIKE RATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% match the samples to spike rate
if is_match
  % draw samples matched to spike rate
  X = match_rate(X_raw, ...
		 spike_rate_samples, ...
		 mean(spike_rate));
else
  X = X_raw;
end


% disp('done.'); %commented out by MAR for inclusion in STAToolkit
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function X_samples = resample_statistic(X_t,time_index)
% RESAMPLE_STATISTIC
%
% usage:   [X_samples] = resample_statistic(X_t, time_index);
%
% inputs:        X_t  - NxT matrix of N samples at T time steps
%         time_index  - 1xT vector of time samples to resample
%
% Resample P(X(t)) samples at times given by time_index and
% samples given by uniformly randomly sampling the N samples.
%

% size of P(X(t)) samples
[N_samples, T] = size(X_t);

% generates [Tx1] column vector with random integers from (1, N_samples) 
sample_index= random('discrete uniform', N_samples, T, 1);

% generate 1-d indexes for 2-d matrix
index = sub2ind(size(X_t), sample_index, time_index);

% index via 1-d knowing it is columnwise first.
X_samples = X_t(index);   

