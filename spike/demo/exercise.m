% Lets generate a 2-D matrix
in_a = [0 4 5;0 6 0;0 1 2];
out_minus1;
out_0;
out_1;

% matrix2hist2d with unocc bins

% matrix2hist2d with occ bins

% matrix2hist2d 3rd option

% Let's generate a multineuron spike train (1 category, 2
% neurons, 3 spike trains per neuron)
% I will have to do the input data structure. Boo!

X.M = 2;
X.N = 3;
X.sites(1).label
X.sites(1).recording_tag
X.sites(1).time_scale
X.sites(1).time_resolution
X.sites(2).label
X.sites(2).recording_tag
X.sites(2).time_scale
X.sites(2).time_resolution
X.categories(1).label = {'example'};
X.categories(1).P = 3;
X.categories(1).trials(1,1).start_time = 0;
X.categories(1).trials(1,1).end_time = 1;
X.categories(1).trials(1,1).Q;
X.categories(1).trials(1,1).list;
X.categories(1).trials(2,1).start_time = 0;
X.categories(1).trials(2,1).end_time = 1;
X.categories(1).trials(2,1).Q;
X.categories(1).trials(2,1).list;
X.categories(1).trials(3,1).start_time = 0;
X.categories(1).trials(3,1).end_time = 1;
X.categories(1).trials(3,1).Q;
X.categories(1).trials(3,1).list;
X.categories(1).trials(1,2).start_time = 0;
X.categories(1).trials(1,2).end_time = 1;
X.categories(1).trials(1,2).Q;
X.categories(1).trials(1,2).list;
X.categories(1).trials(2,2).start_time = 0;
X.categories(1).trials(2,2).end_time = 1;
X.categories(1).trials(2,2).Q;
X.categories(1).trials(2,2).list;
X.categories(1).trials(3,2).start_time = 0;
X.categories(1).trials(3,2).end_time = 1;
X.categories(1).trials(3,2).Q;
X.categories(1).trials(3,2).list;
opts.counting_bin_size;

% directbin regular

% directbin with summed spike trains

% directbin with permuted spike trains

%%%%%%%%%%%%%%%%%%%%%

%%% Here we just need a pair of spike trains (for the next four)

a = [0.0185 0.2311 0.4447 0.4565 0.4860 0.6068 0.7621 0.8214 0.8913 0.9501];
b = [0.1763 0.4057 0.4103 0.6154 0.7382 0.7919 0.8936 0.9169 0.9218 0.9355];
c = ones(1,10);
times = {a;b};
labels = {c;c};

% metricbin d_spike
opts.parallel = 0;
opts.metric_family = 0;
opts.q = [0 1];
y=metricdist(1,times,labels,opts);

% metricbin d_isi
opts.metric_family = 1;
y=metricdist(1,times,labels,opts);

% metricbin all-parameter
opts.parallel = 1;
y=metricdist(1,times,labels,opts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% binlesswarp linear
opts.warping_strategy = 0;
y = binlesswarp(x,opts)

% binlesswarp uniform
opts.warping_strategy = 1;
y = binlesswarp(x,opts)

opts.stratification_strategy = 1;
opts.stratification_strategy = 1;
opts.stratification_strategy = 1;
opts.singleton_strategy = 0;
opts.singleton_strategy = 1;
% binlessinfo strat 1

% binlessinfo strat 2

% binlessinfo strat 3

% binlessinfo sing 1

% binlessinfo sing 2

%%% Let's make a hist structure


% tpmc 0 

% tpmc 1

% tpmc 2

% bub 0

% bub 1

% bub 2

% bub compat 0

% bub compat 1

% ww 0

% ww 1

% ww 2