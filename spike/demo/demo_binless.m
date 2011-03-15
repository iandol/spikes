%DEMO_BINLESS Demo of the binless method.

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

if(~exist('dataset','var'))
  dataset = input('Enter dataset label (\"drift\", \"synth\", \"taste\", or \"continuous\"): ','s');
end

opts.possible_words = 'unique';
opts.start_warp = -1;
opts.end_warp = 1;
opts.min_embed_dim = 1;
opts.singleton_strategy=0;
opts.stratification_strategy=2;
opts.entropy_estimation_method = {'plugin','tpmc','jack'};
opts.unoccupied_bins_strategy = 0;
opts.warping_strategy=1;
D_max_vec = 1:5;

if (strcmp(dataset,'drift'))
  opts.start_time = 0;
  opts.end_time = 0.475;
  
  X=staread(strrep('../data/drift.stam','/',filesep));

elseif (strcmp(dataset,'synth'))
  opts.start_time = 0;
  opts.end_time = 0.25;
  
  X=staread(strrep('../data/synth.stam','/',filesep));

elseif (strcmp(dataset,'taste'))
  opts.start_time = 10;
  opts.end_time = 12;

  X=staread(strrep('../data/taste.stam','/',filesep));
  
elseif (strcmp(dataset,'continuous'))
  opts.start_time = 0;
  opts.end_time = 1;
  opts.cont_min_embed_dim = 0;
  opts.warping_strategy=0;
  
  X=staread(strrep('../data/continuous.stam','/',filesep));

else
  clear dataset;
  error('Invalid label');
  
end

clear out out_unshuf shuf out_unjk jk;
clear info info_tpmc info_jack info_unshuf info_unjk;
clear temp_info_shuf temp_info_jk;

figure;
set(gcf,'name',['Binless ' dataset ' demo']); 

subplot(221);
if strcmp(dataset,'continuous')
    staplot(X,[opts.start_time opts.end_time]);
    title('Data plot');
else
    staraster(X,[opts.start_time opts.end_time]);
    title('Raster plot');
end

%%% Simple analysis

for D_max_idx=1:length(D_max_vec)
 opts.max_embed_dim = D_max_vec(D_max_idx);
 opts.cont_max_embed_dim = D_max_vec(D_max_idx);
 [out(D_max_idx),opts_used] = binless(X,opts);
 info_total_plugin(D_max_idx) = out(D_max_idx).I_total(1).value;
 info_total_tpmc(D_max_idx) = out(D_max_idx).I_total(2).value;
 info_total_jack(D_max_idx) = out(D_max_idx).I_total(3).value;
 if strcmp(dataset,'continuous')
  info_count_plugin(D_max_idx) = NaN;
  info_count_tpmc(D_max_idx) = NaN;
  info_count_jack(D_max_idx) = NaN;
 else
  info_count_plugin(D_max_idx) = out(D_max_idx).I_count(1).value;
  info_count_tpmc(D_max_idx) = out(D_max_idx).I_count(2).value;
  info_count_jack(D_max_idx) = out(D_max_idx).I_count(3).value;
 end
 info_part_plugin(D_max_idx) = out(D_max_idx).I_part(1).value;
 info_part_tpmc(D_max_idx) = out(D_max_idx).I_part(2).value;
 info_part_jack(D_max_idx) = out(D_max_idx).I_part(3).value;
 info_cont(D_max_idx) = out(D_max_idx).I_cont;
end
info_timing_plugin = info_part_plugin+info_cont;
info_timing_tpmc = info_part_tpmc+info_cont;
info_timing_jack = info_part_jack+info_cont;

[D_max_max,D_max_idx]=max(D_max_vec);
if(D_max_max>1)
  subplot(222);
  title('Embedded spike trains');
  hold on;
  colororder = get(gca,'colororder');
  num_colors = size(colororder,1);
  for m=1:X.M
    cur_color = colororder(mod(m-1,num_colors)+1,:);
    in_idx = find(out(D_max_idx).categories==m-1);
    h=plot3(out(D_max_idx).embedded(in_idx,2), ...
            out(D_max_idx).embedded(in_idx,3), ...
            out(D_max_idx).embedded(in_idx,4),'.');
    set(h,'color',cur_color);
    xlabel('Dimension 1');
    ylabel('Dimension 2');
    zlabel('Dimension 3');
    view(3);  
  end
  hold off;
end

subplot(223);
plot(D_max_vec,info_total_plugin,'k');
hold on;
plot(D_max_vec,info_timing_plugin,'b');
plot(D_max_vec,info_count_plugin,'r');
plot(D_max_vec,info_total_tpmc,'k--');
plot(D_max_vec,info_timing_tpmc,'b--');
plot(D_max_vec,info_count_tpmc,'r--');
plot(D_max_vec,info_total_jack,'k-.');
plot(D_max_vec,info_timing_jack,'b-.');
plot(D_max_vec,info_count_jack,'r-.');
hold off;
set(gca,'xtick',D_max_vec);
set(gca,'xlim',[min(D_max_vec) max(D_max_vec)]);
set(gca,'ylim',[-2.5 2.5]);
xlabel('Maximal embedding dimension');
ylabel('Information (bits)');
if strcmp(dataset,'continuous')
  legend('Total','Timing','location','best');
else
  legend('Total','Timing','Count','location','best');
end

%%% Shuffling

opts.entropy_estimation_method = {'plugin'};
rand('state',0);
S=10;
for D_max_idx=1:length(D_max_vec)
  opts.max_embed_dim = D_max_vec(D_max_idx);
  opts.cont_max_embed_dim = D_max_vec(D_max_idx);
  [out_unshuf(D_max_idx),shuf(:,D_max_idx),opts_used] = binless_shuf(X,opts,S);
  info_unshuf(D_max_idx) = out_unshuf(D_max_idx).I_total.value;
  for s=1:S
    temp_info_shuf(s,D_max_idx) = shuf(s,D_max_idx).I_total.value;
  end
end
info_shuf = mean(temp_info_shuf,1);
info_shuf_std = std(temp_info_shuf,[],1);

%%% Leave-one-out jackknife

for D_max_idx=1:length(D_max_vec)
  opts.max_embed_dim = D_max_vec(D_max_idx);
  opts.cont_max_embed_dim = D_max_vec(D_max_idx);
  [out_unjk(D_max_idx),jk(:,D_max_idx),opts_used] = binless_jack(X,opts);
  info_unjk(D_max_idx)= out_unjk(D_max_idx).I_total.value;
  P_total = length(jk);
  for p=1:P_total
    temp_info_jk(p,D_max_idx) = jk(p,D_max_idx).I_total.value;
  end
end
info_jk_sem = sqrt((P_total-1)*var(temp_info_jk,1,1));

%%% Plot results

subplot(224);
errorbar(D_max_vec,info_unjk,2*info_jk_sem);
hold on;
errorbar(D_max_vec,info_shuf,2*info_shuf_std,'r');
hold off;
set(gca,'xtick',D_max_vec);
set(gca,'xlim',[min(D_max_vec) max(D_max_vec)]);
set(gca,'ylim',[-2.5 2.5]);
xlabel('Maximal embedding dimension');
ylabel('Information (bits)');
legend('Original data (\pm 2 SE via Jackknife)','Shuffled data (\pm 2 SD)',...
       'location','best');

scalefig(gcf,1.5);
