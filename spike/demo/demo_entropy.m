%DEMO_ENTROPY Demo of several entropy methods.

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

%Note: this usage has been deprecated but will be maintained as long as possible
%to provide backwards compatibility. Use stream=RandStream.getDefaultStream; and
%stream.reset; as a replacement but note that the stream does not reset to the
%same state as dictated by the deprecated usage.
rand('state',1);

N_vec = round(logspace(1,3,5)); % Vector of total words observed
L = 100; % Number of trials for each value of N
C = 10;  % Number of bins
p = 0.5; % Binomial parameter

opts1.entropy_estimation_method = {'plugin','tpmc','jack','chaoshen','ww','ma'};
opts1.variance_estimation_method = {'jack','boot'};
opts1.possible_words = 'unique';
opts1.ww_beta=1;
opts1.boot_random_seed=1;
opts1.boot_num_samples=100;

opts2.entropy_estimation_method = {'bub'};
opts2.bub_K = 11;
opts2.bub_lambda_0=0;
opts2.bub_compat=0;
opts2.possible_words = 'min_lim_tot_pos';

entropy_methods = [opts1.entropy_estimation_method opts2.entropy_estimation_method];

entropy = zeros(length(entropy_methods),L);
variance_jack = zeros(length(entropy_methods),L);
variance_boot = zeros(length(entropy_methods),L);
cl_jack = zeros(length(entropy_methods),L);
cl_boot = zeros(length(entropy_methods),L);
mean_entropy = zeros(length(entropy_methods),length(N_vec));
rms_stderr_jack = zeros(length(entropy_methods),length(N_vec));
rms_stderr_boot = zeros(length(entropy_methods),length(N_vec));
mean_cl_jack = zeros(length(entropy_methods),length(N_vec));
mean_cl_boot = zeros(length(entropy_methods),length(N_vec));

binom_dist=zeros(C,1);
for y=0:C-1
  binom_dist(y+1) = nchoosek(C-1,y)*(p^y)*((1-p)^(C-1-y));
end
true_entropy = -sum(binom_dist.*log2(binom_dist));

for N_idx = 1:length(N_vec)
  N = N_vec(N_idx);
  disp(['Total words observed equals ' int2str(N)]);
  u1 = rand(N,L,C-1)<p;
  u = sum(u1,3);

  for L_idx = 1:L
    h = directcounttotal({int32(u(:,L_idx))});
    [out1,opts_out] = entropy1d(h,opts1);
    [out2,opts_out] = entropy1d(h,opts2);

    for i=1:length(opts1.entropy_estimation_method)
      entropy(i,L_idx) = out1.entropy(i).value;

      variance_jack(i,L_idx) = out1.entropy(i).ve(1).value;
      ul_jack = out1.entropy(i).value + ...
                1.96*sqrt(out1.entropy(i).ve(1).value);
      ll_jack = out1.entropy(i).value - ...
                1.96*sqrt(out1.entropy(i).ve(1).value);
      cl_jack(i,L_idx) = (true_entropy > ll_jack) & (true_entropy < ul_jack); 
      
      variance_boot(i,L_idx) = out1.entropy(i).ve(2).value;
      ul_boot = out1.entropy(i).value + ...
                1.96*sqrt(out1.entropy(i).ve(2).value);
      ll_boot = out1.entropy(i).value - ...
                1.96*sqrt(out1.entropy(i).ve(2).value);
      cl_boot(i,L_idx) = (true_entropy > ll_boot) & (true_entropy < ul_boot); 
    end

    for i=1:length(opts2.entropy_estimation_method)
      entropy(length(opts1.entropy_estimation_method)+i,L_idx) = out2.entropy(i).value;
    end
    
    mean_entropy(:,N_idx) = mean(entropy,2);
    rms_stderr_jack(:,N_idx) = sqrt(mean(variance_jack,2));
    rms_stderr_boot(:,N_idx) = sqrt(mean(variance_boot,2));
    mean_cl_jack(:,N_idx) = mean(cl_jack,2);
    mean_cl_boot(:,N_idx) = mean(cl_boot,2);
  end
end

colors = jet(length(entropy_methods));
figure('Name','Entropy method demo','DefaultAxesColorOrder',colors); 

subplot(231);
semilogx(N_vec,mean_entropy');
hold on;
semilogx(N_vec,true_entropy*ones(size(N_vec)),'k--');
hold off;
legend(entropy_methods,4);
xlabel('Total words observed');
ylabel('Entropy (bits)');
title('Entropy estimates');

% Bias
subplot(234);
loglog(N_vec,abs(true_entropy-mean_entropy'));
xlabel('Total words observed');
ylabel('Absolute value of bias (bits)');
title('Bias');

% Standard error via jackknife
subplot(232);
loglog(N_vec,rms_stderr_jack');
xlabel('Total words observed');
ylabel('Standard error (bits)');
title('Standard error via jackknife');

% CL via jackknife
subplot(235);
semilogx(N_vec,mean_cl_jack');
hold on;
semilogx(N_vec,0.95*ones(size(N_vec)),'k--');
hold off;
set(gca,'ylim',[0.5 1]);
xlabel('Total words observed');
ylabel('Fraction of estimates w/in 95% CL');
title('CL validation via jackknife');

% Standard error via bootstrap
subplot(233);
loglog(N_vec,rms_stderr_boot');
xlabel('Total words observed');
ylabel('Standard error (bits)');
title('Standard error via bootstrap');

% CL via bootstrap
subplot(236);
semilogx(N_vec,mean_cl_boot');
hold on;
semilogx(N_vec,0.95*ones(size(N_vec)),'k--');
hold off;
set(gca,'ylim',[0.5 1]);
xlabel('Total words observed');
ylabel('Fraction of estimates w/in 95% CL');
title('CL validation via bootstrap');

scalefig(gcf,2);
