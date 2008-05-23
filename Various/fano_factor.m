function fano = fano_factor(spike_train,bin_length,counting_interval)

% Computes the Fano factor of spike counts, over a given counting-interval length

N = length(spike_train);

n_b = round(counting_interval/bin_length);          % number of bins in counting interval
n_i = floor(N/n_b);                                 % number of counting intervals
r_s_t = reshape(spike_train(1:n_b*n_i),n_b,n_i);    % reshaped spike train
counts = sum(r_s_t,1);                              % spike counts
fano = var(counts)/mean(counts);                    % Fano factor
