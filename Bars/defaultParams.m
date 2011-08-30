function bp = defaultParams()
    bp = struct();
    bp.burn_iter = 0;
    bp.samp_iter = 2000;
    bp.k = 3;
    bp.nf = 500;
    bp.use_logspline = 1;
    bp.beta_iter = 3;
    bp.probbd = .4;
    bp.tau = 50;
    bp.conf_level = .95;
    bp.threshold = -10;

    bp.prior_id = 'UNIFORM';
    bp.dparams = 6;
    bp.iparams = [1 80];    
end