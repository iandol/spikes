%DEMO_DIRECTFORMAL Demo of the direct method for formal information.

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

opts.counting_bin_size = 6e-4;
opts.legacy_binning = 0;
opts.letter_cap = Inf;
opts.entropy_estimation_method = {'plugin','tpmc','jack','ma'};
opts.possible_words = 'recommended';
opts.start_time = 0;
opts.end_time = 8;
orig_end_time = opts.end_time;

X_uni=staread(strrep('../data/inforate_uni.stam','/',filesep));
X_rep=staread(strrep('../data/inforate_rep.stam','/',filesep));

L_vec = [2 4 6 8 12 16 24 32 48 64];
num_L = length(L_vec);
L_min = 24;
bub_idx = find(L_vec>=L_min);

H_total_plugin = zeros(1,num_L);
H_noise_plugin = zeros(1,num_L);

H_total_tpmc = zeros(1,num_L);
H_noise_tpmc = zeros(1,num_L);

H_total_jack = zeros(1,num_L);
H_noise_jack = zeros(1,num_L);

H_total_ma = zeros(1,num_L);
H_noise_ma = zeros(1,num_L);

H_total_bub = zeros(1,num_L);
H_noise_bub = zeros(1,num_L);

for L_idx = 1:num_L
  L = L_vec(L_idx);
  disp(sprintf('L=%d',L));

  if(L>=L_min)
    opts.entropy_estimation_method = {'plugin','tpmc','jack','ma','bub'};
    opts.bub_lambda_0 = 0;
    opts.bub_K = 11;
    opts.bub_compat = 0;
  end
    
  temp = floor((orig_end_time-opts.start_time)/(L*opts.counting_bin_size));
  opts.end_time = L*opts.counting_bin_size*temp;
  opts.words_per_train = (opts.end_time-opts.start_time)/(L*opts.counting_bin_size);

  out = directformal(X_uni,X_rep,opts);

  H_total_plugin(L_idx) = out.cond.total.entropy(1).value;
  H_noise_plugin(L_idx) = out.cond.class.entropy(1).value;
  info_plugin(L_idx) = out.cond.information(1).value;
  
  H_total_tpmc(L_idx) = out.cond.total.entropy(2).value;
  H_noise_tpmc(L_idx) = out.cond.class.entropy(2).value;
  info_tpmc(L_idx) = out.cond.information(2).value;

  H_total_jack(L_idx) = out.cond.total.entropy(3).value;
  H_noise_jack(L_idx) = out.cond.class.entropy(3).value;
  info_jack(L_idx) = out.cond.information(3).value;

  H_total_ma(L_idx) = out.cond.total.entropy(4).value;
  H_noise_ma(L_idx) = out.cond.class.entropy(4).value;
  info_ma(L_idx) = out.cond.information(4).value;

  if(L>=L_min)
    H_total_bub(L_idx) = out.cond.total.entropy(5).value;
    H_noise_bub(L_idx) = out.cond.class.entropy(5).value;
    info_bub(L_idx) = out.cond.information(5).value;
  end

end

Delta = opts.counting_bin_size;

H_total_rate_plugin = H_total_plugin./(L_vec*Delta);
H_noise_rate_plugin = H_noise_plugin./(L_vec*Delta);
info_rate_plugin = info_plugin./(L_vec*Delta);

H_total_rate_tpmc = H_total_tpmc./(L_vec*Delta);
H_noise_rate_tpmc = H_noise_tpmc./(L_vec*Delta);
info_rate_tpmc = info_tpmc./(L_vec*Delta);

H_total_rate_jack = H_total_jack./(L_vec*Delta);
H_noise_rate_jack = H_noise_jack./(L_vec*Delta);
info_rate_jack = info_jack./(L_vec*Delta);

H_total_rate_ma = H_total_ma./(L_vec*Delta);
H_noise_rate_ma = H_noise_ma./(L_vec*Delta);
info_rate_ma = info_ma./(L_vec*Delta);

H_total_rate_bub = H_total_bub./(L_vec*Delta);
H_noise_rate_bub = H_noise_bub./(L_vec*Delta);
info_rate_bub = info_bub./(L_vec*Delta);

figure;
set(gcf,'name','Formal information demo'); 

subplot(221);
plot(1./L_vec,H_total_rate_plugin,'marker','.');
hold on;
plot(1./L_vec,H_total_rate_tpmc,'r','marker','.');
plot(1./L_vec,H_total_rate_jack,'g','marker','.');
plot(1./L_vec(bub_idx),H_total_rate_bub(bub_idx),'c','marker','.');
hold off;
legend('Plug-in','TPMC','Jackknife','BUB', ...
       'location','best');
xlabel('Inverse word length 1/L (1/bins)');
ylabel('Entropy (bits/sec)');
title('Total entropy rate');

subplot(222);
plot(1./L_vec,H_noise_rate_plugin,'marker','.');
hold on;
plot(1./L_vec,H_noise_rate_tpmc,'r','marker','.');
plot(1./L_vec,H_noise_rate_jack,'g','marker','.');
plot(1./L_vec(bub_idx),H_noise_rate_bub(bub_idx),'c','marker','.');
hold off;
legend('Plug-in','TPMC','Jackknife','BUB', ...
       'location','best');
xlabel('Inverse word length 1/L (1/bins)');
ylabel('Entropy (bits/sec)');
title('Noise entropy rate');

subplot(223);
plot(1./L_vec,H_total_rate_plugin,'marker','.');
hold on;
plot(1./L_vec,H_total_rate_ma,'r','marker','.');
plot(1./L_vec,H_noise_rate_plugin,'--','marker','.');
plot(1./L_vec,H_noise_rate_ma,'r--','marker','.');
hold off;
legend('Total (plug-in)','Total (Ma bound)',...
       'Noise (plug-in)','Noise (Ma bound)',...
       'location','best');
xlabel('Inverse word length 1/L (1/bins)');
ylabel('Entropy (bits/sec)');
title('Comparison to Ma bound');
axis([0 0.5 0 350]);

lambda = 40;
sigma = 6e-4;
H_diff_total = log(exp(1)/lambda);
H_diff_noise = (1/2)*log(2*pi*exp(1)*(sigma^2));
info_true = lambda*((H_diff_total-H_diff_noise)/log(2));

subplot(224);
plot(1./L_vec,info_rate_plugin,'marker','.');
hold on;
plot(1./L_vec,info_rate_tpmc,'r','marker','.');
plot(1./L_vec,info_rate_jack,'g','marker','.');
plot(1./L_vec(bub_idx),info_rate_bub(bub_idx),'c','marker','.');
plot([0 1./L_vec(1)],[info_true info_true],'k--');
hold off;
axis([0 0.5 0 200]);
legend('Plug-In','TPMC','Jackknife','BUB','Analytic',...
       'location','best');
xlabel('Inverse word length 1/L (1/bins)');
ylabel('Information rate (bits/sec)');
title('Information rate');

scalefig(gcf,2);

