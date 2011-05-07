%DEMO_METRIC_MULTI Demo of multineuron capabilities of metric space method.

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

% Smaller dataset - use this to get results quickly
%X=staread(strrep('/Users/ian/Code/spikes/spike/data/phase_small.stam','/',filesep));

% Larger dataset
X=staread(strrep('/Users/ian/Code/spikes/spike/data/phase.stam','/',filesep));

AB_array = multisitearray(X);
A = AB_array(1);
B = AB_array(2);

q_vec = [0 2.^(0:9)];
k_vec = [0:0.1:0.2 0.4:0.2:1 1.25:0.25:2];

num_q = length(q_vec);
num_k = length(k_vec);

opts.start_time = 0;
opts.end_time = 0.473;
opts.parallel = 1;
opts.metric_family = 0;
opts.unoccupied_bins_strategy = 0;
opts.clustering_exponent = -2;
opts.entropy_estimation_method = {'plugin'};

[q_mat,k_mat]=meshgrid(q_vec,k_vec);
q_vec2 = q_mat(:);
k_vec2 = k_mat(:);
num_qk = length(q_vec2);
opts.shift_cost = q_vec2;
opts.label_cost = k_vec2;

out = metric(X,opts);

for idx=1:length(opts.shift_cost)
  info_ab_vec(idx) = out(idx).table.information.value;
end
 
info_ab = (reshape(info_ab_vec,[num_k num_q]))';
 
%%% Do single neuron
opts.shift_cost = q_vec;
[out_a,opts_used] = metric(A,opts);
[out_b,opts_used] = metric(B,opts);

for q_idx=1:num_q
  info_a(q_idx) = out_a(q_idx).table.information.value;
  info_b(q_idx) = out_b(q_idx).table.information.value;
end

my_vec = 1:num_q;

figure;

subplot(221);
staraster(X,[opts.start_time opts.end_time],1);

subplot(222);
staraster(X,[opts.start_time opts.end_time],2);

subplot(223);
[k_mat,my_mat]=meshgrid(k_vec,my_vec);
h = surf(k_mat,my_mat,info_ab);
set(h,'facecolor','interp');
hold on;
h1=plot3(zeros(size(my_vec)),my_vec,info_a,'k');
set(h1,'marker','s','markerfacecolor',[0 0 0]);
h2=plot3(zeros(size(my_vec)),my_vec,info_b,'k');
set(h2,'marker','o','markerfacecolor',[1 1 1]);
h3=plot3(zeros(size(my_vec)),my_vec,info_a+info_b,'k');
set(h3,'marker','+');
hold off;
set(gca,'ytick',[1 4 7 10]);
set(gca,'yticklabel',[0 1 10 100]);
set(gca,'ydir','rev');
axis([0 2 1 my_vec(end) 0 3]);
dar = get(gca,'dataaspectratio');
dar(3) = (2/3)*dar(3);
set(gca,'dataaspectratio',dar);
view([245 5])
box on;

ylabel('Temporal precision q (1/sec)');
xlabel('k');
zlabel('Information (bits)');

% Redundancy index
subplot(224);
H_joint = max(info_ab,[],1);
H_1 = max(info_a);
H_2 = max(info_b);
RI = (1-(H_joint/(H_1+H_2)))/(1-(max(H_1,H_2))/(H_1+H_2));
plot(k_vec,RI);
hold on;
plot(k_vec,RI,'.');
hold off;
xlabel('k');
ylabel('Redundancy index');
set(gca,'ylim',[-0.5 1.5]);

scalefig(gcf,1.5);
