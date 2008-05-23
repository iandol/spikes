function directspikes(data,sv)

hwait=waitbar(0,'Direct Method data loading');
pos=get(hwait,'Position');
set(hwait,'Position',[0 0 pos(3) pos(4)]);
opts.words_per_train = 1;
opts.tpmc_possible_words_strategy = 0;

Delta_vec = 2.^(-4:1);
opts.start_time = sv.mint/1000;
opts.end_time = sv.maxt/1000;
X=makemetric(data,sv);

Delta_frac = 1./Delta_vec;

clear out out_unshuf shuf out_unjk jk;
clear info_plugin info_tpmc info_jack info_unshuf info_unjk;
clear temp_info_shuf temp_info_jk;

waitbar(0.1,hwait,'Plotting Rasters');
figure;
set(gcf,'name',['Direct Method Analysis']); 

subplot(221);
staraster(X,[opts.start_time opts.end_time]);
title('Raster plot');

%%% Simple analysis

opts.entropy_estimation_method = {'plugin','tpmc','jack'};
for Delta_idx=1:length(Delta_vec)
 opts.counting_bin_size = Delta_vec(Delta_idx);
 [out(Delta_idx),opts_used] = directcat(X,opts);
 info_plugin(Delta_idx) = out(Delta_idx).cond.information(1).value;
 info_tpmc(Delta_idx) = out(Delta_idx).cond.information(2).value;
 info_jack(Delta_idx) = out(Delta_idx).cond.information(3).value;
end

drawnow;
waitbar(0.4,hwait,'Plot entropy');
subplot(223);
plot(1:length(Delta_frac),info_plugin);
hold on;
plot(1:length(Delta_frac),info_tpmc,'--');
plot(1:length(Delta_frac),info_jack,'-.');
hold off;
set(gca,'xtick',1:length(Delta_frac));
set(gca,'xticklabel',Delta_frac);
set(gca,'xdir','rev');
set(gca,'xlim',[1 length(Delta_frac)]);
set(gca,'ylim',[-0.5 2.5]);
xlabel('Inverse bin size (1/sec)');
ylabel('Information (bits)');
legend('No correction','TPMC correction','Jackknife correction','location','best');

%%% Shuffling

opts.entropy_estimation_method = {'plugin'};
rand('state',0);
S=10;
for Delta_idx=1:length(Delta_vec)
  opts.counting_bin_size = Delta_vec(Delta_idx);
  [out_unshuf(Delta_idx),shuf(:,Delta_idx),opts_used] = directcat_shuf(X,opts,S);
  info_unshuf(Delta_idx) = out_unshuf(Delta_idx).cond.information.value;
  for s=1:S
    temp_info_shuf(s,Delta_idx) = shuf(s,Delta_idx).cond.information.value;
  end
end
info_shuf = mean(temp_info_shuf,1);
info_shuf_std = std(temp_info_shuf,[],1);

%%% Leave-one-out jackknife

for Delta_idx=1:length(Delta_vec)
  opts.counting_bin_size = Delta_vec(Delta_idx);
  [out_unjk(Delta_idx),jk(:,Delta_idx),opts_used] = directcat_jack(X,opts);
  info_unjk(Delta_idx)= out_unjk(Delta_idx).cond.information.value;
  P_total = length(jk);
  for p=1:P_total
    temp_info_jk(p,Delta_idx) = jk(p,Delta_idx).cond.information.value;
  end
end
info_jk_sem = sqrt((P_total-1)*var(temp_info_jk,1,1));

drawnow;
waitbar(0.2,hwait,'Shuffling...');

subplot(224);
errorbar(1:length(Delta_frac),info_unjk,2*info_jk_sem);
hold on;
errorbar(1:length(Delta_frac),info_shuf,2*info_shuf_std,'r');
hold off;
set(gca,'xtick',1:length(Delta_frac));
set(gca,'xticklabel',Delta_frac);
set(gca,'xdir','rev');
set(gca,'xlim',[1 length(Delta_frac)]);
set(gca,'ylim',[-0.5 2.5]);
xlabel('Inverse bin size (1/sec)');
ylabel('Information (bits)');
legend('Original data (\pm 2 SE via Jackknife)','Shuffled data (\pm 2 SD)',4);

close(hwait);
