function autoco = autocorrelation(s_train,bin_length,lags)

% constructs the autocorrelation histogram (actually autocovariogram) of a spike train

% BN168  Spring 2006

s_times = find(s_train);            % spike times in bin units
n = length(s_times);                % number of spikes in record
n_bins = length(s_train);           % number of bins in record (epoch)
T = n_bins*bin_length;              % length of record (epoch) in sec

m = 0;
for lag = lags
    m = m + 1;
    lst = s_times + lag;                    % lagged spike times
    lst = lst( lst>=1 & lst<=n_bins );      % discard times outside record
    N_m = sum(s_train(lst));                % number of spike pairs that fall into bin m of histogram 
    autoco(m) = N_m - n^2*bin_length/T;
    if lag == 0
        autoco(m) = 0;                      % set 0-lag bin to 0
    end
end


autoco = autoco/T;                  % divide by length of record

