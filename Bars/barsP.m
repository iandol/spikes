function summary = barsP(data,dataRange,trials, bp)
% Usage: fit = barsP(data,dataRange,trials, bp)
%   data: a vector of count data.  Data must be equally spaced along x
%   dataRange: the x values for the first and last point of the data
%   trials: number of repeats that gave rise to these count data
%   bp (optional): the bars parameter structure.  See defaultParams.m
%
% Examples:
% > load example.data
% > fit1 = barsP(example(:,2),[example(1,1) example(end,1)],60);
% 
% > bp = defaultParams;
% > bp.prior_id = 'POISSON';
% > bp.dparams = 4;
% > fit2 = barsP(example(:,2),[example(1,1) example(end,1)],60,bp);
% For more information about the parameters, see
% http://www.stat.cmu.edu/~kass/papers/jss.pdf

% This is a MATLAB port (9/2010) of the code from the following paper:
%   An Implementation of Bayesian Adaptive Regression Splines (BARS) 
%   in C with S and R Wrappers, Garrick Wallstrom, Jeffrey Liebner, and Rob
%   Kass
% http://www.stat.cmu.edu/~kass/papers/jss.pdf
% by Ryan Kelly (rckelly@cmu.edu).
% 
% To use Logspline, you must compile nlsd_mex.c first.
% > mex nlsd_mex.c

tic

data = data(:);

% if no parameter struct is passed in, just use the defaults
if nargin <= 3
    bp = defaultParams();
end

% make sure counts are positive
if sum(data < 0)
    disp('Counts cannot be less than 0');
    return
end

% make sure that the range is set up properly
if dataRange(2) <= dataRange(1)
    disp('dataRange should be [xmin xmax]');    
    return
end

% put the data in the correct form in the 'bd' structure
bd = makeBinnedData(data,dataRange,trials,bp.nf);

% set up the model struct
m = defaultModel(bd.n,bd.nf);

% compute the first knot locations
m.knots_interior = firstKnots(bd,bp);

% initial values of mu are the data, with 0's replaced by .1
mu_start = bd.y;
mu_start(mu_start < .1) = .1;

% compute the fitted values for the specified knots
m = setBasisAndFitModel(m,bd,mu_start);

% if that first fit is unsucessful, try to improve on it by deleting knots
if m.fit_info == 0
    k = length(m.knots_interior);
    knot_set = m.knots_interior;
    
    if strcmp(bp.prior_id,'UNIFORM') || strcmp(bp.prior_id,'USER')
        kmin = bp.iparams(1);
    else
        kmin = 1;
    end
    
    % as long as we still don't have a good fit, try to keep removing knots
    while m.fit_info == 0 && k > kmin
        maxcn = -1;
        cnk = -1;
        remk = -1;
        
        for i = 1:k
            m.knots_interior = knot_set;
            m.knots_interior(i) = [];
            
            [m condnum] = setBasisAndFitModel(m,bd,mu_start);
            
            if (condnum > maxcn)
                cnk = i;
                maxcn = condnum;
            end
            
            if m.fit_info ~= 0
                if remk == -1
                    remk = i;
                    like = m.loglikelihood;
                else
                    if m.loglikelihood > like
                        remk = i;
                        like = m.loglikelihood;
                    end
                end
                    
            end
        end
        
        if remk == -1
            if cnk == -1
                remk = 1;
            else
                remk = cnk;
            end
        end
        
        m.knots_interior = knot_set;
        m.knots_interior(remk) = [];
        m = setBasisAndFitModel(m,bd,mu_start);
        
        k = k - 1;
    end
    
    % last chance - use a minimum number of equally spaced knots
    if m.fit_info == 0
        m.knots_interior = (1:kmin)/(kmin+1);

        m = setBasisAndFitModel(m,bd,mu_start);
        if m.fit_info == 0
            disp('Irreparable initial knots. This may have occurred if the prior on the number of knots has too small of a support.');
            return;
        end
    end
end

% using the user parameters, build the knot prior
[birth_probs death_probs] = getRJProbs(bp);

% total iterations is the sample iterations + the burn in iterations
tot_iter = bp.samp_iter + bp.burn_iter;

moves = zeros(3,1);

% models is the output - the collection of fitted models after burn-in
models = cell(bp.samp_iter,1);

i = 1;

% MCMC - fit models, allowing knots to be added, deleted, and moved
while i <= tot_iter
   u = rand(1);
   
   k = length(m.knots_interior);
   
   if u < birth_probs(k)
       % birth step
       bdr = 1;
       mNew = getBirthModel(m,bp,bd,mu_start);
   elseif 1-u < death_probs(k)
       % death step
       bdr = 2;
       mNew = getDeathModel(m,bp,bd,mu_start);
   else
       % relocation step
       bdr = 3;
       mNew = getRelocateModel(m,bp,bd,mu_start);
   end
   
   moves(bdr) = moves(bdr) + 1;
   if rand(1) < mNew.accept_prob
       m = mNew;
   end
   if i > bp.burn_iter
       if m.fit_fine == 0
           m.basis_fine = getModelBasis(m, bd, 1);
           m.fit_fine = 1;
       end
       [m laterej] = RandMu(m,bd,bp);           
       if laterej
            i = i - 1;
       else
            models{i-bp.burn_iter} = getStats(m,bd);
       end
   end
   i = i + 1;
end

% prepare the output
models = cell2mat(models);

% compute summary statistics
summary = struct();
modelCell = struct2cell(models);
[~, maxIndex] = max(cell2mat(modelCell(3,:)));
summary.mode = models(maxIndex).sampMu;
summary.mode_fine = models(maxIndex).sampMuFine;
summary.mean = mean(cell2mat(modelCell(6,:)),2);
summary.mean_fine = mean(cell2mat(modelCell(7,:)),2);

firstIndex = round((1-bp.conf_level) * length(models)); 
lastIndex = round((bp.conf_level) * length(models));
locations = sort(cell2mat(modelCell(1,:)));
heights = sort(cell2mat(modelCell(2,:)));
knots = sort(cellfun(@length,modelCell(5,:)));

sortedMu = sort(cell2mat(modelCell(6,:)),2);
summary.confBands = [sortedMu(:,firstIndex) sortedMu(:,lastIndex)];
sortedMuFine = sort(cell2mat(modelCell(7,:)),2);
summary.confBands_fine = [sortedMuFine(:,firstIndex) sortedMuFine(:,lastIndex)];

summary.params = zeros(3,4);
summary.params(1,1) = locations(firstIndex);
summary.params(2,1) = heights(firstIndex);
summary.params(3,1) = knots(firstIndex);
summary.params(1,2) = locations(lastIndex);
summary.params(2,2) = heights(lastIndex);
summary.params(3,2) = knots(lastIndex);
summary.params(1,3) = mean(locations);
summary.params(2,3) = mean(heights);
summary.params(3,3) = mean(knots);

summary.params(1,4) = models(maxIndex).peakLocation;
summary.params(2,4) = models(maxIndex).peakHeight;
summary.params(3,4) = length(models(maxIndex).knots);

summary.models = models;

% how long did that take?
toc

end

%%%%%%%%%%%%%%%%%%%%
% HELPER FUNCTIONS
%%%%%%%%%%%%%%%%%%%%

function output = getStats(m,bd)    
    % compute some final statistics for this model m
    output = struct();

    [maxY maxInd] = max(m.random_mu_fine);
    k = length(m.knots_interior);
    output.peakLocation = bd.fg(maxInd)*(bd.x_rawmax - bd.x_rawmin) + bd.x_rawmin;
    output.peakHeight = maxY * bd.scale_factor;

    w = k + 1.5;
    v = sum(bd.y .* log(m.random_mu) - m.random_mu);
    output.BIC = v - w*log(m.n);
    output.logLikelihood = v;

    output.knots = m.knots_interior;
    output.sampMu = m.random_mu;
    output.sampMuFine = m.random_mu_fine;
end

function [m laterej] = RandMu(m,bd,bp)
    % compute a sample mu, and also return whether or not there should be a
    % late rejection
    [beta laterej] = RandBeta(m,bd,bp);
    m.random_mu = exp(m.basis(:,3:end) * beta);
    m.random_mu_fine = exp(m.basis_fine(:,3:end) * beta);    
end

function [beta laterej] = RandBeta(m,bd,bp)
    % compute a perturbed beta vector
    MHiters = bp.beta_iter;
    threshold = bp.threshold;
    
    p = length(m.knots_interior)+2;
    
    lastbeta = m.J(:,end);
    m.random_mu = exp(m.basis(:,3:end) * lastbeta);
        
    lastfi = sum(bd.y .* log(m.random_mu) - m.random_mu);
    lastgi = sum((m.J(2:end,2:end-1)*lastbeta(2:end)).^2)/(-2*m.n);
    lasthi = 0;
    countMH = 0;
    
    MHi = 1;
    while MHi <= MHiters        
        curbeta = randn(p,1);
        curhi = sum(curbeta.^2);
       
        curbeta = m.J(:,1:end-1)\curbeta;
        
        curhi = curhi * -.5;
        curbeta = curbeta + m.J(:,end);
        
        m.random_mu = exp(m.basis(:,3:end) * curbeta);
        curfi = sum(bd.y .* log(m.random_mu) - m.random_mu);
        curgi = sum((m.J(2:end,2:end-1)*curbeta(2:end)).^2)/(-2*m.n);
        r = (curfi - lastfi) + (curgi - lastgi) - (curhi - lasthi);
        
        if r > 0
            r = 0;
        end
        u = rand(1);
        if u < eps
            u = r-1;
        else
            u = log(u);
        end
        if MHi == 1 && r > threshold
            MHi = MHiters+1;
            u = r - 1;
        end
        if u < r
            lastbeta = curbeta;
            lastfi = curfi;
            lastgi = curgi;
            lasthi = curhi;
            countMH = countMH + 1;
        end
        
        MHi = MHi + 1;
    end
    
    beta = lastbeta;
    laterej = countMH == 0;
end

function m = getRelocateModel(m,bp,bd,mu_start)
       % compute a new model, relocating a single knot
       oldLike = m.loglikelihood;
       
       [birth_cand dkPos] = getBirthKnotInfo(m.knots_interior,bp.tau);
       death_cand = m.knots_interior(dkPos);
       
       m.knots_interior(dkPos) = [];
       m.knots_interior = sort([m.knots_interior; birth_cand]);
       
       dens1 = dbeta(birth_cand,bp.tau*death_cand,bp.tau*(1-death_cand));
       dens2 = dbeta(death_cand,bp.tau*birth_cand,bp.tau*(1-birth_cand));       
       
       m = setBasisAndFitModel(m,bd,mu_start);
   
       if m.fit_info > 0
           m.accept_prob = exp(m.loglikelihood - oldLike + log(dens2) - log(dens1));
       else
           m.accept_prob = 0;
       end
end

function m = getDeathModel(m,bp,bd,mu_start)
       % compute a new model, deleting a knot
       oldLike = m.loglikelihood;
       k = length(m.knots_interior);
       
       dkPos = randi(k);
       cand = m.knots_interior(dkPos);       
       m.knots_interior(dkPos) = [];
       dens = getTransitionDensity(cand,bp.tau,m.knots_interior);

       m = setBasisAndFitModel(m,bd,mu_start);
   
       if m.fit_info > 0
           m.accept_prob = exp(m.loglikelihood - oldLike - log(k-1) + log(dens) + .5 * log(m.n));
       else
           m.accept_prob = 0;
       end
end

function m = getBirthModel(m,bp,bd,mu_start)
       % compute a new model, adding a single knot
       oldLike = m.loglikelihood;
       k = length(m.knots_interior);
       
       cand = getBirthKnotInfo(m.knots_interior,bp.tau);
       dens = getTransitionDensity(cand,bp.tau,m.knots_interior);
       m.knots_interior= sort([m.knots_interior; cand]);
       m = setBasisAndFitModel(m,bd,mu_start);
   
       if m.fit_info > 0
           m.accept_prob = exp(m.loglikelihood - oldLike + log(k) - log(dens) - .5 * log(m.n));
       else
           m.accept_prob = 0;
       end
end
       
function d = getTransitionDensity(cand,tau,knots)
    d = 0;
    for i = 1:length(knots)
        d = d + dbeta(cand,tau*knots(i),tau*(1-knots(i)));
    end
end

function d = dbeta(x,a,b)
    if x <= 0 || x >= 1
        d = 0;
    else
        d = exp((a-1)*log(x) + (b-1)*log(1-x) - betaln(a,b));
    end
end

function iout = check_cand(cand,knots)
    iout = 0;
    iout = iout + (cand < eps);
    iout = iout + (cand > 1-eps);
    for i=1:length(knots)
        iout = iout + (abs(cand-knots(i)) < eps);
    end    
end

function [cand k_rand] = getBirthKnotInfo(knots,tau)
    % figure out where a new knot would be added
    k = length(knots);
    k_rand = randi(k,1);
    alpha = tau * knots(k_rand);
    beta = tau - alpha;
    cand = betarnd(alpha,beta);
    while check_cand(cand,knots)
        cand = betarnd(alpha,beta);
    end
end

function [m rcond] = setBasisAndFitModel(m,bd,mu_start)  
    % main model building function, constructs a basis and fits the model
    m.knots_all = boundaries(4,m.knots_interior);
    m.basis = getModelBasis(m, bd, 0);
    [m rcond] = FitPoissonModel(m,bd,mu_start);
    m.fit_fine = 0;
end

function [m rcond] = FitPoissonModel(m,bd,mu_start)
    % given a set of knots and a precomputed basis, fit a poisson model
    p = length(m.knots_interior)+2;
    n = bd.n;
    
    loglik1 = 0;
    
    x = m.basis(:,3:end);
    y = bd.y;
        
    iter = 0;
    
    MAXIT_GLM = 20;
    
    mu = mu_start;
    
    g = zeros(n,p+1);
    g(:,1:end-1) = x;
    
    converged = 1;

    for i=MAXIT_GLM:-1:1    
        g(:,end) = log(mu)+ (y - mu)./mu;
        
        h = diag(mu) * x;
        
        J = h'*g;
                
        [J_chol p] = chol(J(:,1:end-1));                
        if p > 0
            converged = 0;
            rcond = -1;
           break; 
        end
        iter = iter + 1;

        % rcond = 1/condest(J(:,1:end-1));
        rcond = 1/cond(J(:,1:end-1));        
        
        if rcond < 500 * sqrt(eps)
            converged = 0;
            break;
        end

        B = J(:,1:end-1)\J(:,end);
        eta = x*B;

        J = [J_chol B];
        
        mu = exp(eta);
        m.fitted_values = mu;
        
        loglik0 = loglik1;
        loglik1 = sum(y .* eta - mu);
        delta = abs(loglik1 - loglik0);
        if delta < .01
            break;
        end
    end
    m.loglikelihood = loglik1;
    m.sigma = 1;
    m.fit_info = iter * converged;
    m.J = J;
end

function xy = outer_plus(dx,Y,dy)
    xy = zeros(1,dx*dy);
    for i = 0:dx-1
        for j = 0:dy-1
            xy(i*dy + j + 1) = i + Y(j+1);
        end
    end
end

function newBasis = basis_cw_trans(basis,index,order,n,newBasisSize)
    newBasis = zeros(newBasisSize,1);
    for i = 0:n-1
        for j = 0:order-1
            newBasis(i+n*index(j*n+i+1)+1) = basis(i*order+j+1);
        end
    end    
end

function [basis offsets] = splineBasisValues(knots, order, xvals)
    % compute basis values
    orderm1 = order - 1;
    rdel = zeros(orderm1,1);
    ldel = zeros(orderm1,1);
    
    basis = zeros(order * length(xvals),1);
        
    n = length(xvals);
    
    basisIndex = 1;
    
    j = 1 + order;
    
    offsets = zeros(n,1);
    for i = 1:n
        while j <= length(knots) - order && knots(j) <= xvals(i)
            j = j + 1;
        end
        
        x = xvals(i);
        % basis_funcs
        for k = 1:orderm1
            rdel(k) = knots(j+k-1) - x;
            ldel(k) = x - knots(j-k);
        end
        basis(basisIndex) = 1;
        for k = 1:orderm1
            saved = 0;
            for r = 0:k-1
                term = basis(basisIndex+r)/(rdel(r+1)+ldel(k-r));
                basis(basisIndex+r) = saved + rdel(r+1) * term;
                saved = ldel(k-r) * term;
            end
            basis(basisIndex + k) = saved;
        end        
            
        basisIndex = basisIndex + order;
        
        offsets(i) = j - order - 1;
    end    
end

function [basis offsets] = splineBasisDerivs(knots, order, xvals, deriv)
    % compute the basis derivatives
    orderm1 = order - 1;
    rdel = zeros(orderm1,1);
    ldel = zeros(orderm1,1);
    
    basis = zeros(order * length(xvals),1);
        
    n = length(xvals);
    
    basisIndex = 1;
    
    j = 1 + order;
    
    offsets = zeros(n,1);
    for i = 1:n
        while j <= length(knots) - order && knots(j) <= xvals(i)
            j = j + 1;
        end
        
        for k = 1:order
            a = zeros(order,1);
            a(k) = 1;

            outer = orderm1;
            
            x = xvals(i);
            
            for m = 1:deriv
                apt = 1;
                lpt = -outer+j; 
                for inner = outer:-1:1                
                    a(apt) = outer * (a(apt+1) - a(apt))/(knots(lpt + outer)-knots(lpt));
      
                    apt = apt + 1;
                    lpt = lpt + 1;
                end
                outer = outer - 1;
            end  
                
            for m = 1:outer
                rdel(m) = knots(j+m-1) - x;
                ldel(m) = x - knots(j-m);
            end
        
            while (outer > 0)
                outer = outer - 1;
                apt = 1;
                lpt = outer+1; %ldel
                rpt = 1; % rdel
                for inner = (outer + 1):-1:1
                    a(apt) = (a(apt+1) * ldel(lpt) + a(apt) * rdel(rpt))/(ldel(lpt) + rdel(rpt));
                
                    lpt = lpt - 1;
                    rpt = rpt + 1;
                    apt = apt + 1;
                end
            end
            
            basis(basisIndex) = a(1);
            basisIndex = basisIndex + 1;
        end
        
        offsets(i) = j - order - 1;
    end    
end

function basis = getModelBasis(m, bd, fit_version)
    % return a new model basis for the knots in m
    if fit_version == 1
        xg = bd.fg;
    else
        xg = bd.xg;
    end

    [tmpBasis offsets] = splineBasisValues(m.knots_all, 4, xg);
    index_m = outer_plus(4,offsets,length(xg));
    basis = basis_cw_trans(tmpBasis,index_m,4,length(xg),(length(m.knots_interior)+4)*length(xg));

    [tmpBasis offsets] = splineBasisDerivs(m.knots_all, 4, [0 1], 2);
    index_m = outer_plus(4,offsets,length(offsets));
    con_basis = basis_cw_trans(tmpBasis,index_m,4,2,(length(m.knots_interior)+4)*2);

    t = reshape(con_basis(3:end),2,length(m.knots_interior)+3)';    
    
    [q,~] = qr(t);
    
    if length(basis) < length(xg) * (length(m.knots_interior)+4)
        basis(length(xg)*(length(m.knots_interior)+4)) = 0;
    end

    basis = reshape(basis,length(xg),length(m.knots_interior)+4);
    basis(:,2:end) = basis(:,2:end) * q;
    basis(:,3) = 1;
end

function [birth death] = getRJProbs(bp)
    % builds the knot prior
    i = 1:(MAXKNOTS-1);
            
    if strcmp(bp.prior_id,'POISSON')
        pratio = bp.dparams(1) ./ (i+1);
    elseif strcmp(bp.prior_id,'UNIFORM')
        pratio = (i >= bp.iparams(1)) & (i < bp.iparams(2));
    elseif strcmp(bp.prior_id,'USER')
        pratio = i*0;
        pratio(bp.iparams(1):bp.iparams(2)-1) = bp.dparams(i+1)./bp.dparams(i);
    else
        pratio = i*0;
    end
    
    pratio = [0 pratio 0];
    birth = zeros(MAXKNOTS+1,1);
    death = zeros(MAXKNOTS+1,1);
    
    c = bp.probbd;
    
    birth(1) = 0;
    death(1) = 0;
    birth(2) = (pratio(2) >= eps) * c * min(1,pratio(2));
    death(2) = 0;
    if pratio(end-1) < eps
        death(end) = c;
    else
        death(end) = c * min(1,1/pratio(end-1));
    end
        
    for i=3:MAXKNOTS
        birth(i) = (pratio(i) >= eps) * c * min(1,pratio(i));
        if pratio(i-1) < eps
            death(i) = c;           
        else
            death(i) = c * min(1,1/pratio(i-1));
        end
    end
end

function ka = boundaries(order, ki)
    % adds (order) zero knots on either side of the interior knots
    ka = [zeros(order,1); ki; ones(order,1)];
end

function knots = firstKnots(bd, bp)
    % compute the first knot set, either using logspline or with the
    % uniform distribution
    if (bp.use_logspline)
        if exist('nlsd_mex') ~= 3
            disp(' You must compile nlsd_mex.c to use logspline:')
            disp(' > mex nlsd_mex.c');
            disp(' Using equally spaced knots instead.');
            knots = (1:bp.k)'/(bp.k+1);
        else        
            knots = nlsd_mex(bd.xg,bd.y);
        end
        k = length(knots);
        
        if strcmp(bp.prior_id,'UNIFORM') || strcmp(bp.prior_id,'USER')
            if k < bp.iparams(1) || k > bp.iparams(2)
                k = floor(.5*sum(bp.iparams));
                mexPrintf('The number of logspline knots has zero prior probability. Using %i equally spaced knots to begin chain.\n\n',k);

                knots = (1:k)/(k+1);
            end            
        else
            knots = knots(1:min(k,MAXKNOTS));
        end
    else
        knots = (1:bp.k)'/(bp.k+1);
    end    
end

function bd = makeBinnedData(data,dataRange,trials,nf)
    % build the binned data structure from the input data
    bd = struct();
    bd.n = length(data);
    bd.x_raw = (0:bd.n-1) * (dataRange(2)-dataRange(1))/(bd.n-1) + dataRange(1);
    bd.y = data;

    bd.bin_width = diff(dataRange)/(bd.n-1);
    bd.x_rawmin = min(bd.x_raw) - .5*bd.bin_width;
    bd.x_rawmax = max(bd.x_raw) + .5*bd.bin_width;
    bd.xg = (bd.x_raw - bd.x_rawmin)/(bd.x_rawmax - bd.x_rawmin);
    
    bd.scale_factor = 1/(trials * bd.bin_width);
    bd.trials = trials;
    
    bd.fg = (0:nf-1) * (max(bd.xg) - min(bd.xg)) / (nf-1) + min(bd.xg);
    
    bd.nf = nf;
end

function bm = defaultModel(nd,nf)
    % build an empty model structure
    bm = struct();
    bm.n = nd;
    bm.nf = nf;
    bm.fit_info = 0;
    bm.fit_fine = 0;
    bm.accept_prob = 0;
end

function m = MAXKNOTS()
    % just a #define substitute
    m = 80;
end