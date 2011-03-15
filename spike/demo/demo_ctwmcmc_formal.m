%DEMO_CTWMCMC_FORMAL Demos CTWMCMC method by comparing it to DIRECTFORMAL.
%   DEMO_CTWMCMC_FORMAL Runs a script to demonstrate how one might analyze
%   data with the Context-Tree Weighted Markov chain Monte Carlo (CTWMCMC)
%   method. In order to make sense of the results, an abbreviated
%   DIRECTFORMAL analysis on the same data (but see caveats below) is
%   directly compared in the generated figure. This same data is more
%   extensively analyzed with DIRECTFORMAL in DEMO_DIRECTFORMAL.

%
%  Copyright 2010, Weill Medical College of Cornell University
%  All rights reserved.
%
%  This software is distributed WITHOUT ANY WARRANTY
%  under license "license.txt" included with distribution and
%  at http://neurodatabase.org/src/license.
%

if isoctave
    warning(['Due to differences in the figure handling and plotting functions ' ...
        'between Matlab and Octave, this demo will not run in Octave. You may use ' ...
        'this file as a template for your own analyses.']);
	return;
end

path(path,'..');

if(~exist('add_nsb','var'))
    disp('Would you like to include the NSB entropy estimator (analysis');
	add_nsb = input('with NSB will take about 8 times longer) [y/(n)]? ','s');
    if ~isempty(add_nsb) && strcmpi(add_nsb(1),'y')
        add_nsb = true;
    else
        add_nsb = false;
    end
end

%options and parameters for the CTWMCMC method
opts.beta = 0.5; %1/A where A is the number of letters in the binned data
opts.gamma = 0.5;
opts.nmc = 199;
opts.max_tree_depth = 10^3; %allows for opts.max_tree_depth*opts.counting_bin_size temporal correlations
opts.h_zero = 1;
opts.tree_format = 'none'; %don't output memory intensive tree
opts.memory_expansion = 1.61;
opts.mcmc_iterations = 100;
opts.mcmc_max_iterations = 10000;
opts.mcmc_min_acceptances = 20;
opts.match_rates = 1;
opts.confidence_interval = 95;

%options and parameters used by CTWMCMC and DIRECTFORMAL methods
opts.counting_bin_size = 6e-4;
opts.words_per_train = 1; %no other value is sensible
opts.legacy_binning = 0;
opts.letter_cap = 1; %context-tree weighting not well tested with non-binary sequences
opts.entropy_estimation_method = {'ww'};
opts.possible_words = 'unique';
opts.ww_beta = opts.beta;

%Note that the same data will be analyzed with both CTWMCMC and
%DIRECTFORMAL methods, however, the amount of data is reduced for the
%CTWMCMC analysis, as it is much more memory intensive.
x_uni = staread(strrep('../data/inforate_uni.stam','/',filesep));
x_rep = staread(strrep('../data/inforate_rep.stam','/',filesep));
x_stream = x_uni;
x_replica = x_rep;

%data reduction
data_reduction = 1/8;
x_stream.categories(1).trials(1).end_time = data_reduction*(x_stream.categories(1).trials(1).end_time-...
    x_stream.categories(1).trials(1).start_time) + x_stream.categories(1).trials(1).start_time;
found = find(x_stream.categories(1).trials(1).list<x_stream.categories(1).trials(1).end_time);
x_stream.categories(1).trials(1).Q = int32(length(found));
x_stream.categories(1).trials(1).list = x_stream.categories(1).trials(1).list(found);
for i=1:x_replica.categories.P
    x_replica.categories.trials(i).end_time = data_reduction*(x_replica.categories.trials(i).end_time-...
        x_replica.categories.trials(i).start_time) + x_replica.categories.trials(i).start_time;
    found = find(x_replica.categories.trials(i).list<x_replica.categories.trials(i).end_time);
    x_replica.categories.trials(i).Q = int32(length(found));
    x_replica.categories.trials(i).list = x_replica.categories.trials(i).list(found);
end

for i=2:x_stream.M
    %data reduction
    x_stream.categories(i).trials(1).end_time = data_reduction*(x_stream.categories(i).trials(1).end_time-...
        x_stream.categories(i).trials(1).start_time) + x_stream.categories(i).trials(1).start_time;
    found = find(x_stream.categories(i).trials(1).list<x_stream.categories(i).trials(1).end_time);
    x_stream.categories(i).trials(1).Q = int32(length(found));
    x_stream.categories(i).trials(1).list = x_stream.categories(i).trials(1).list(found);

    %We are also modifying the data slightly below, by merging the unique
    %spike trains in x_uni into one long spike train in x_stream. This is
    %ONLY acceptable because the data in inforate_uni is from simulated
    %Poisson spike trains, which carry no temporal correlations. DO NOT DO
    %THIS with real data, which may have important temporal correlations
    %which would be lost. Instead, use data from one long continuous
    %recording, such as data obtained from an m-sequence experiment.

    %data concatentation
    x_stream.categories(1).trials(1).Q = x_stream.categories(1).trials(1).Q + x_stream.categories(i).trials(1).Q;
    x_stream.categories(1).trials(1).list = [x_stream.categories(1).trials(1).list ...
        x_stream.categories(1).trials(1).end_time + x_stream.categories(i).trials(1).list];
    x_stream.categories(1).trials(1).end_time = x_stream.categories(1).trials(1).end_time + ...
        x_stream.categories(i).trials(1).end_time - x_stream.categories(i).trials(1).start_time;
end
x_stream.M = int32(1);
x_stream.categories = x_stream.categories(1);

fprintf(1,'Doing CTWMCMC analysis ... ');
tic;
[y opts_used] = ctwmcmc(x_stream,x_replica,opts);
disp(['done (' num2str(toc) ' seconds).']);

for i=1:length(y.estimates.noise)
    H_noise_ctwmcmc(i) = y.estimates.noise(i).h_analytical.value;
end
H_noise_ctwmcmc = mean(H_noise_ctwmcmc);

opts.possible_words = 'recommended';
opts.start_time = 0;

L = [2 8 24 64]; %see DEMO_DIRECTFORMAL for additional values

H_total_plugin = zeros(1,length(L));
H_noise_plugin = zeros(1,length(L));
info_plugin = zeros(1,length(L));

H_total_tpmc = zeros(1,length(L));
H_noise_tpmc = zeros(1,length(L));
info_tpmc = zeros(1,length(L));

if add_nsb
    H_total_nsb = zeros(1,length(L));
    H_noise_nsb = zeros(1,length(L));
    info_nsb = zeros(1,length(L));
end

fprintf(1,'Doing DIRECTFORMAL analysis ... ');
tic;
for i=1:length(L)
    fprintf(1,'L=%d ',L(i));

    %directformal with entropy methods plugin and tpmc
    opts.entropy_estimation_method = {'plugin','tpmc'};
    opts.end_time = 8;

    temp = floor((opts.end_time-opts.start_time)/(L(i)*opts.counting_bin_size));
    opts.end_time = L(i)*opts.counting_bin_size*temp;
    opts.words_per_train = (opts.end_time-opts.start_time)/(L(i)*opts.counting_bin_size);

    out = directformal(x_uni,x_rep,opts); %not saving complete output on each loop to save memory

    H_total_plugin(i) = out.cond.total.entropy(1).value;
    H_noise_plugin(i) = out.cond.class.entropy(1).value;
    info_plugin(i) = out.cond.information(1).value;

    H_total_tpmc(i) = out.cond.total.entropy(2).value;
    H_noise_tpmc(i) = out.cond.class.entropy(2).value;
    info_tpmc(i) = out.cond.information(2).value;

    if add_nsb
        %directformal with entropy method nsb (on reduced data)
        opts.entropy_estimation_method = {'nsb'};
        opts.nsb_precision = 1e-6;
        opts.end_time = data_reduction*8;

        temp = floor((opts.end_time-opts.start_time)/(L(i)*opts.counting_bin_size));
        opts.end_time = L(i)*opts.counting_bin_size*temp;
        opts.words_per_train = (opts.end_time-opts.start_time)/(L(i)*opts.counting_bin_size);

        out = directformal(x_uni,x_rep,opts); %not saving complete output on each loop to save memory

        H_total_nsb(i) = out.cond.total.entropy(1).value;
        H_noise_nsb(i) = out.cond.class.entropy(1).value;
        info_nsb(i) = out.cond.information(1).value;
    end
end
disp(['done (' num2str(toc) ' seconds).']);

H_total_rate_plugin = H_total_plugin./(L*opts.counting_bin_size);
H_noise_rate_plugin = H_noise_plugin./(L*opts.counting_bin_size);
info_rate_plugin = info_plugin./(L*opts.counting_bin_size);

H_total_rate_tpmc = H_total_tpmc./(L*opts.counting_bin_size);
H_noise_rate_tpmc = H_noise_tpmc./(L*opts.counting_bin_size);
info_rate_tpmc = info_tpmc./(L*opts.counting_bin_size);

if add_nsb
    H_total_rate_nsb = H_total_nsb./(L*opts.counting_bin_size);
    H_noise_rate_nsb = H_noise_nsb./(L*opts.counting_bin_size);
    info_rate_nsb = info_nsb./(L*opts.counting_bin_size);
end

clear i found temp;

%get true entropy/information rate
lambda = 40;
sigma = opts.counting_bin_size;
H_diff_total = log(exp(1)/lambda);
H_diff_noise = (1/2)*log(2*pi*exp(1)*(sigma^2));
info_true = lambda*((H_diff_total-H_diff_noise)/log(2));

%create figure
figure('Name','CTWMCMC Information Demo','NumberTitle','Off');
if add_nsb
    label_legend = {'Direct (Plug-in)','Direct (TPMC)','Direct (NSB)','CTWMCMC','Confidence Interval'};
    annotation('textbox',[0.3 0.01 0.4 0.05],'String',['Please note that ' label_legend{3} ' and ' label_legend{4} ' analyses were performed with ' num2str(data_reduction*100) '% of the data as compared to Direct (Plug-in) and Direct (TPMC)']);
else
    label_legend = {'Direct (Plug-in)','Direct (TPMC)','CTWMCMC','Confidence Interval'};
    annotation('textbox',[0.33 0.01 0.34 0.05],'String',['Please note that ' label_legend{3} ' analysis was performed with ' num2str(data_reduction*100) '% of the data as compared to Direct (Plug-in) and Direct (TPMC)']);
end
scalefig(gcf,2);

subplot(2,2,1);
plot(1./L,H_total_rate_plugin,'marker','.');
hold on;
plot(1./L,H_total_rate_tpmc,'r','marker','.');
if add_nsb
    plot(1./L,H_total_rate_nsb,'c','marker','.');
end
plot([0 1/L(1)],repmat(y.estimates.signal.h_analytical.value/opts.counting_bin_size,[1 2]),'g');
fill([0 0 1/L(1) 1/L(1)],[y.estimates.signal.ci/opts.counting_bin_size ...
    fliplr(y.estimates.signal.ci/opts.counting_bin_size)],'g','EdgeColor','none','FaceAlpha',0.1);
legend(label_legend,'location','best');
xlabel('Inverse word length for direct method 1/L (1/bins)');
ylabel('Entropy (bits/sec)');
title('Total entropy rate');

subplot(2,2,2);
plot(1./L,H_noise_rate_plugin,'marker','.');
hold on;
plot(1./L,H_noise_rate_tpmc,'r','marker','.');
if add_nsb
    plot(1./L,H_noise_rate_nsb,'c','marker','.');
end
plot([0 1/L(1)],repmat(H_noise_ctwmcmc/opts.counting_bin_size,[1 2]),'g');
fill([0 0 1/L(1) 1/L(1)],[y.estimates.noise(1).ci/opts.counting_bin_size ...
    fliplr(y.estimates.noise(1).ci/opts.counting_bin_size)],'g','EdgeColor','none','FaceAlpha',0.1);
legend(label_legend,'location','best');
xlabel('Inverse word length for direct method 1/L (1/bins)');
ylabel('Entropy (bits/sec)');
title('Noise entropy rate');

subplot(2,2,4);
plot(1./L,info_rate_plugin,'marker','.');
hold on;
plot(1./L,info_rate_tpmc,'r','marker','.');
if add_nsb
    plot(1./L,info_rate_nsb,'c','marker','.');
end
plot([0 1/L(1)],repmat(y.estimates.information.value/opts.counting_bin_size,[1 2]),'g');
fill([0 0 1/L(1) 1/L(1)],[y.estimates.information.ci/opts.counting_bin_size ...
    fliplr(y.estimates.information.ci/opts.counting_bin_size)],'g','EdgeColor','none','FaceAlpha',0.1);
plot([0 1/L(1)],[info_true info_true],'k--');
legend([label_legend {'Analytic'}],'location','best');
xlabel('Inverse word length for direct method 1/L (1/bins)');
ylabel('Information rate (bits/sec)');
title('Information rate');
