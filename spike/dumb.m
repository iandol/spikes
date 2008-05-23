opts.entropy_estimation_method = {'bub'};
opts.unoccupied_bins_strategy = 0;
opts.bub_lambda_0=0;
opts.bub_K=11;
opts.bub_compat=0;
opts.bub_possible_words_strategy=0;

for i=1:1000
  a = [1 2 4;1 4 3;2 4 2];
  b = matrix2hist2d(a,opts);
  c = info2d(b,opts);
end
