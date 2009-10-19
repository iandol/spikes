function staverify(mode)

path(path,'..');

if nargin<1
  mode = 1;
end 
 
if(mode) %read mode
  eval(strrep('load ../data/verify_expected','/',filesep));
else %write mode
  dummy = 0;
  eval(strrep('save ../data/verify_expected dummy','/',filesep));
end

tol = 1e-5;

%%% Test matrix2hist2d unoccupied bins strategy option

in = [9 0 3 0;
      2 0 2 7;
      0 0 0 0;
      4 0 7 4];

opts.entropy_estimation_method = {'tpmc'};
opts.possible_words = 'unique';

% matrix2hist2d ignore unoccupied bins
opts.unoccupied_bins_strategy = -1;
h_ignore = matrix2hist2d(in,opts);
out_ignore = info2d(h_ignore,opts);
info_ignore.actual = out_ignore.information.value;
verify_element('info_ignore',info_ignore,tol,mode);

% matrix2hist2d include unoccupied bins if rows and columns are occupied
opts.unoccupied_bins_strategy = 0;
h_include1 = matrix2hist2d(in,opts);
out_include1 = info2d(h_include1,opts);
info_include1.actual = out_include1.information.value;
verify_element('info_include1',info_include1,tol,mode);

% matrix2hist2d include all unoccupied bins
opts.unoccupied_bins_strategy = 1;
h_include2 = matrix2hist2d(in,opts);
out_include2 = info2d(h_include2,opts);
info_include2.actual = out_include2.information.value;
verify_element('info_include2',info_include2,tol,mode);

%%% Direct method

X=staread(strrep('../data/phase.stam','/',filesep));
opts.start_time = 0;
opts.end_time = 0.947;
opts.counting_bin_size = 1;
opts.words_per_train = 1;
opts.legacy_binning = 0;
opts.letter_cap = Inf;

% directbin with summed spike trains
opts.sum_spike_trains = 1;
opts.permute_spike_trains = 0;
out_summed.actual = directbin(X,opts);
verify_element_intstruct('out_summed',out_summed,tol,mode);

% directbin with permuted spike trains
opts.permute_spike_trains = 1;
opts.sum_spike_trains = 0;
out_permuted.actual = directbin(X,opts);
verify_element_intstruct('out_permuted',out_permuted,tol,mode);

% directbin with letter cap
opts.letter_cap = 9;
opts.sum_spike_trains = 0;
opts.permute_spike_trains = 0;
out_capped.actual = directbin(X,opts);
verify_element_intstruct('out_capped',out_capped,tol,mode);

X=staread(strrep('../data/drift.stam','/',filesep));
opts.start_time = 0;
opts.end_time = 0.475;

%%% Metric space method

[categories,times,labels]=metricopen(X,opts);

opts.shift_cost = 8;
opts.parallel = 0;
opts.metric_family = 0;

% metricdist d_spike
d_spike_temp = metricdist(1,times(239:240),labels(239:240),opts);
d_spike.actual = d_spike_temp(1,2);
verify_element('d_spike',d_spike,tol,mode);

% metricdist d_isi
opts.metric_family = 1;
d_interval_temp = metricdist(1,times(239:240),labels(239:240),opts);
d_interval.actual = d_interval_temp(1,2);
verify_element('d_interval',d_interval,tol,mode);

% metricdist all-parameter
opts.metric_family = 0;
opts.parallel = 1;
d_parallel_temp = metricdist(1,times(239:240),labels(239:240),opts);
d_parallel.actual = d_parallel_temp(1,2);
verify_element('d_parallel',d_parallel,tol,mode);

%%% Binless method

[times,counts,categories] = binlessopen(X,opts);
opts.start_warp = -1;
opts.end_warp = 1;

% binlesswarp linear
opts.warping_strategy = 0;
warped_linear_actual = binlesswarp(times(240),opts);
warped_linear.actual = warped_linear_actual{1};
verify_element('warped_linear',warped_linear,tol,mode);

% binlesswarp uniform
opts.warping_strategy = 1;
warped_uniform_actual = binlesswarp(times(240),opts);
warped_uniform.actual = warped_uniform_actual{1};
verify_element('warped_uniform',warped_uniform,tol,mode);

opts.max_embed_dim = 3;
opts.min_embed_dim = 1;
opts.unoccupied_bins_strategy = 0;
opts.singleton_strategy = 0;
opts.entropy_estimation_method = {'plugin'};

% binlessinfo single stratum
opts.stratification_strategy = 0;
out_strat_single = binless(X,opts);
info_strat_single.actual = out_strat_single.I_total.value;
verify_element('info_strat_single',info_strat_single,tol,mode);

% binlessinfo one stratum per spike count
opts.stratification_strategy = 1;
out_strat_percount = binless(X,opts);
info_strat_percount.actual = out_strat_percount.I_total.value;
verify_element('info_strat_percount',info_strat_percount,tol,mode);

% binlessinfo one stratum per spike count; all spike trains with more than embed_dim_max-embed_dim_min spikes go into a single stratum
opts.stratification_strategy = 2;
out_strat_percount2 = binless(X,opts);
info_strat_percount2.actual = out_strat_percount2.I_total.value;
verify_element('info_strat_percount2',info_strat_percount2,tol,mode);

% binlessinfo ignore singletons
opts.singleton_strategy = 0;
out_single_ignore = binless(X,opts);
info_single_ignore.actual = out_single_ignore.I_total.value;
verify_element('info_single_ignore',info_single_ignore,tol,mode);

% binlessinfo include singletons
opts.singleton_strategy = 1;
out_single_include = binless(X,opts);
info_single_include.actual = out_single_include.I_total.value;
verify_element('info_single_include',info_single_include,tol,mode);

%%% Entropy methods

u = [3 7 1 6 4 4 5 4 5 4 7 5 5 3 8 4 2 5 6 1]';
h = directcounttotal({int32(u)});

opts.entropy_estimation_method = {'plugin','tpmc','jack','ma','bub','chaoshen','ww'};
opts.variance_estimation_method = {'jack','boot'};
opts.possible_words = 'unique';
opts.ww_beta=1;
opts.boot_random_seed=1;
opts.boot_num_samples=100;
opts.bub_K = 11;
opts.bub_lambda_0=0;
opts.bub_compat=0;

[out0,opts_out] = entropy1d(h,opts);
for i=1:length(opts.entropy_estimation_method)
  entropy0_actual(i) = out0.entropy(i).value;
  variance_jack0_actual(i) = out0.entropy(i).ve(1).value;
  variance_boot0_actual(i) = out0.entropy(i).ve(2).value;
end
entropy0.actual = entropy0_actual;
variance_jack0.actual = variance_jack0_actual;
variance_boot0.actual = variance_boot0_actual;
verify_element('entropy0',entropy0,tol,mode);
verify_element('variance_jack0',variance_jack0,tol,mode);
%verify_element('variance_boot0',variance_boot0,tol,mode);

opts.entropy_estimation_method = {'tpmc','bub','ww'};
opts.possible_words = 'total';

[out1,opts_out] = entropy1d(h,opts);
for i=1:length(opts.entropy_estimation_method)
  entropy1_actual(i) = out1.entropy(i).value;
  variance_jack1_actual(i) = out1.entropy(i).ve(1).value;
  variance_boot1_actual(i) = out1.entropy(i).ve(2).value;
end
entropy1.actual = entropy1_actual;
variance_jack1.actual = variance_jack1_actual;
variance_boot1.actual = variance_boot1_actual;
verify_element('entropy1',entropy1,tol,mode);
verify_element('variance_jack1',variance_jack1,tol,mode);
%verify_element('variance_boot1',variance_boot1,tol,mode);

opts.possible_words = 'possible';

[out2,opts_out] = entropy1d(h,opts);
for i=1:length(opts.entropy_estimation_method)
  entropy2_actual(i) = out2.entropy(i).value;
  variance_jack2_actual(i) = out2.entropy(i).ve(1).value;
  variance_boot2_actual(i) = out2.entropy(i).ve(2).value;
end
entropy2.actual = entropy2_actual;
variance_jack2.actual = variance_jack2_actual;
variance_boot2.actual = variance_boot2_actual;
verify_element('entropy2',entropy2,tol,mode);
verify_element('variance_jack2',variance_jack2,tol,mode);
%verify_element('variance_boot2',variance_boot2,tol,mode);

opts.entropy_estimation_method = {'bub'};
opts.bub_compat=0;
[out3,opts_out] = entropy1d(h,opts);
entropy3.actual = out3.entropy.value;
variance_jack3.actual = out3.entropy.ve(1).value;
variance_boot3.actual = out3.entropy.ve(2).value;
verify_element('entropy3',entropy3,tol,mode);
verify_element('variance_jack3',variance_jack3,tol,mode);
%verify_element('variance_boot3',variance_boot3,tol,mode);

opts.entropy_estimation_method = {'nsb'};
opts.variance_estimation_method = {'nsb_var'};
opts.possible_words = 100;
opts.nsb_precision = 1e-6;
[out4,opts_out] = entropy1d(h,opts);
entropy4.actual = out4.entropy.value;
variance_nsb.actual = out4.entropy.ve(1).value;
verify_element('entropy4',entropy4,tol,mode);
verify_element('variance_nsb',variance_nsb,tol,mode);

function verify_element(name,in,tol,mode)

if(mode)
  compare(name,in,tol);
else
  in.expected = in.actual;
  eval(sprintf('%s.expected = in.expected;',name));
  eval(strrep(sprintf('save ../data/verify_expected %s -append',name),'/',filesep));
end
  
function compare(name,in,tol)

str = sprintf('%s test',name);
gap = char(46*ones(1,40-length(str)));

if(any(any(abs(in.expected - in.actual)>tol)))
  disp([str gap '[FAILED]']);
else
  disp([str gap '[PASSED]']);
end

function verify_element_intstruct(name,in,tol,mode)

if(mode)
  compare_intstruct(name,in,tol);
else
  in.expected = in.actual;
  eval(sprintf('%s.expected = in.expected;',name));
  eval(strrep(sprintf('save ../data/verify_expected %s -append',name),'/',filesep));
end
  
function compare_intstruct(name,in,tol)

str = sprintf('%s test',name);
gap = char(46*ones(1,40-length(str)));

if(isequal(in.expected,in.actual)==0)
  disp([str gap '[FAILED]']);
else
  disp([str gap '[PASSED]']);
end