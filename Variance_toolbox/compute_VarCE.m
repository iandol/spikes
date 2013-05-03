%
% usage: Result = VarVsMean(data, times, params)
% This code was adapted by Anne Churchland from code written by Mark Churchland> his original code was designed to compute the
% mean-matched fano factors. The key differences are 
% 1) We compute all quantities from residuals 
% 2) We emphasize the VarCE which is the difference between the total variance and a constant (phi) times the point process variance. 
% 3) we use bootstrapping to estimate the errors
%
% OVERVIEW
%   This function computes both the mean-matched fano-factor and the VarCE 
%
%   This is done at multiple timepoints, which the user inputs
%
% INPUTS
%   There are 2 required inputs: 'data', and 'times', and one optional input 'params'
%
%   'DATA'
%           A structure, each element of which contains a field 'spikes' which is a matrix with 1 row
%       per trial and 1 column per millisecond.  Each entry should be a '1' (there was a spike in
%       that ms on that trial) or a '0' (there wasn't).  All data should be time-aligned to some event.
%           For example, suppose you collect 100 trials, each with 200 ms of pre-target
%       data and 800 ms of post-target data. Your 'spikes' matrix would then be 100 by 1000
%       (with one of these for each element of 'data').
%       E.G.
%           trial 1     0 0 0 1 0 0 0 1 0 0 1 ... 0 1 0 0 0 1
%           trial 2     0 0 1 0 0 1 0 0 0 1 0 ... 0 0 1 0 1 0
%           trial 3     0 0 0 0 1 1 0 1 0 0 0 ... 0 1 0 0 0 0
%             ...
%           trial n     1 0 1 1 0 0 0 1 0 0 0 ... 0 0 0 1 1 0
%
%           Running this analysis only makes sense if you collected data for many neurons &/or many conditions.
%       Each element of 'data' should contain all the trials for one neuron/condition combination.  Thus, if you
%       collected data from 100 neurons using 10 conditions, 'data' would be length 1000.
%       **  The field containing the spike matrix MUST be named 'spikes'. **
%
%   'TIMES'
%           A vector of times for which the analysis should be performed.  In the above example, the data
%       spans 1000 ms, so 'times' might be 100:50:800.  This would compute the Fano factor every 50 ms starting
%       100 ms into the data and ending 200 ms before the data end.
%           You almost certainly DONT want to feed in every time (e.g. 1:1000 would be a bad choice).  This is
%       because 1) things will be slow, and 2) it becomes harder to match the distribution of mean counts as the
%       number of times increases.  As a result, more data will have to be excluded to manage the match.  Just
%       ask for the times that are critical for your analysis, with a reasonable spacing (probably 20-50 ms
%       between times is reasonable).
%           Also, keep in mind that the count window is centered on ttimeshe times you ask for.  For example, the
%       default 'boxWidth' is 80 ms, which means the first entry in 'times' must be >40 ms.
%
%   'PARAMS'
%           This input structure is optional.  If you don't supply it, default values will be used.  You can
%       input params with some fields but not others (the unsupplied fields revert to the defaults).  The
%       fields are:
%           'boxWidth' is the width of the sliding window in which the count is made (default is 80 ms)
%           'matchReps' should be zero if you do not wish the firing rate distributions to
%               be equalized across the times. When non-zero, that is the number of times
%               the downselection is done (different random seed each time). (default is 10).
%           'binSpacing' determines the scale on which we try and match the firing rates.  It
%               is the bin width used to compute the distribution of spike counts. (default is 0.25 spikes).
%           'alignTime' allows you to specify the time that the neural responses are aligned to (e.g. target
%               onset). The 'times' field in the output will be with respect to that time.  This means that
%               you don't have to keep track of the alignment time for the purposes of subsequent plots / analyses.
%               (default is 0).
%           'initRand' If set to 1, 'rand' will be initialized. If set to 0, 'rand' is not initialized.  This
%               matters because 'rand' is used when downselecting data (deciding which points to ignore).
%               If you want the result to be identical every time 'VarVsMean' is called, don't set to 0.
%               So long as 'matchReps' isn't too small though, results will be very similar regardless
%               of whether rand is initialized. (default is 1).
%           'weightedRegression'  If set to 1, the regression takes into account the different sampling
%               error for the different points (lower trial counts and higher means result in a
%               larger sampling error in our measurement of the variance). Default is 1. 0 means not weighted.
%           'includeVarMinusMean'  If set to 1, 'Result' will contain fields that report the variance
%               minus the mean. (default is 0).
%           'use_this_dist' this is a core distribution that is used
%           'remain_thresh' proportion of conditions that must be remaining
%               for a pt to be included; default is 0.5. Note that this is
%               separate from the number of trials within a condition that are
%               needed to include that condition- you would specify that in
%               other code that creates, "data". 
%               instead of computing targetCount from the data.
%           'conditional_FF' these are the values of phi that you compute
%               for each neuron. I did this by computing the fano factor for
%               each conditions and taking its minimum. There should be one
%               value for each condition. You could always start with a
%               guess, an idea for a guess is suggested as the default: use
%               0.45 for all. 
%NOTE: whether you override the defaults or not, the function informs you of the values used on the command line.
%
% OUTPUT: 'Result' has the following fields:
%        FanoFactor: The Fano Factor for each time (after downselection to match distributions across times)
%        Fano_95CIs: The 95% Confidence intervals on the Fano Factor
%       scatterData: contains the data for the variance versus mean scatterplot
%     FanoFactorAll: Same as 'FanoFactor' but for all datapoints (no downselection or matching)
%     FanoAll_95CIs: 95% CIs on the above
%    scatterDataAll: Scatterplot data for the above
%    meanRateSelect: The mean rate (across all conditions/neurons) after downselection (should be fairly constant)
%       meanRateAll: The mean rate with no downselection (i.e. the population average) (this and above in spikes/s)
%          distData: The distributions of firing rate counts (raw and downselected)
%             times: The times that the analysis was performed, including offset if 'alignTime' was nonzero
%                           Those below are produced only if 'includeVarMinusMean' == 1
%      varMinusMean: The variance minus the mean (avgd across all points, after mean-matching)
%         VMM_95CIs: Corresponding 95% CIs
%            VMMall: The 'raw' variance minus the mean (no mean-matching)
%      VMMall_95CIs: Corresponding 95% CIs
%          omitRaw: don't include the raw data in the output (AKC, for my fig 2)


function Result = VarVsMean(data, times, varargin)


% SET DEFAULTS AND OVERIDE IF A "PARAMS" STRUCTURE WAS PASSED
boxWidth = 60;  % width of the sliding window in which the counts are made
matchReps = 0; % number of random choices regarding which points to throw away when matching distributions
binSpacing = 1.5; % bin width when computing distributions of mean counts
alignTime = 0; % time of event that data are aligned to (in the output structure, times will be expressed relative to this)
initRand = 1;
weightedRegression = 0;
includeVarMinusMean = 1;
provide_marg = [];
omitRaw = 0;
conditional_FF = 0.55;
remain_thresh = 0.25;%0.35;%
shuffle_windows = 0;
allconds_resid = single(nan(sum([data.numtrials]),length(times)));
allconds_mean = single(nan(sum([data.numtrials]),length(times)));
conditional_FF = 0.45 * ones(size(data')); %Tahe 0.45 for all values. This is in case you haven't estimated phi yet. 


startcond = 1;
nboot = 200;  %number of bootstrap iterations; this is on the low side to save time. 


if nboot < 100
    sprintf('Caution: using only %d bootstrap trials to save time. Dont take error bars seriously',nboot)
end

for maket = 1:length(times)

    scatterDataAll(maket).boot = single(nan(sum([data.numtrials]),nboot));
    scatterDataAll(maket).new_means = single(nan(size(data,2),nboot));

end;

Pfields = {'boxWidth', 'matchReps', 'binSpacing', 'alignTime', 'initRand', 'weightedRegression', 'includeVarMinusMean','provide_marg','omitRaw','conditional_FF','remain_thresh','shuffle_windows'};

for i = 1:length(Pfields) % if a params structure was provided as an input, change the requested fields
    if ~isempty(varargin)&&isfield(varargin{1}, Pfields{i}), eval(sprintf('%s = varargin{1}.(Pfields{%d});', Pfields{i}, i)); end
    %akc: I commented this out because I kept getting an error and the
    %numbers were useless anyway.
    % fprintf('%s = %g; ', Pfields{i}, eval(Pfields{i}) );
    if i==4, fprintf('\n'); end
end; fprintf('\n');
if initRand, rand('state',0); end  % initialize random number generator (done by default, can be overridden)
% warn if there is an unrecognized field in the input parameter structure
if ~isempty(varargin)
    fnames = fieldnames(varargin{1});
    for i = 1:length(fnames)
        recognized = max(strcmp(fnames{i},Pfields));
        if recognized == 0, fprintf('fieldname %s not recognized\n',fnames{i}); end
    end
end
weightingEpsilon = 1 * boxWidth/1000; % past approx < 1 spike/s, weights don't increase much anymore



%matchReps = 10;

if ~islogical(data(1).spikes), disp('the spikes field should be of type logical'); end

%conditional_FF = 1;
% DO CONVOLUTION WITH SLIDING WINDOW.
% COMPUTE THE MEAN AND VARIANCE OF THE COUNT FOR EACH TIME & EACH NEURON/CONDITION
for t = 1:length(times)
    scatterDataAll(t).time = times(t)-alignTime;
    scatterDataAll(t).var = zeros(length(data),1);  %initialize
    scatterDataAll(t).mn = zeros(length(data),1);   %initialize
    scatterDataAll(t).cov = zeros(length(data),1);   %initialize
end


mycov = [];


maxRate = 0;  % used to keep track of max rate across all times / conds
trialCount = zeros(length(data),1);  % initialize for speed (used for weighted regression)


rand('twister',sum(100*clock))

startboot = 1;


for cond = 1:length(data)

   
    if isempty(data(cond).spikes), disp('ERROR: the field spikes is an empty matrix.'); end

    if size(data(cond).spikes, 1) < 2, disp('ERROR: in at least one case the field spikes has 1 or fewer trials.');

    end;


    Tstart = times - floor(boxWidth/2) + 1;
    Tend = times + ceil(boxWidth/2) + 1;

    if Tend(end)+1 > size(data(cond).spikes,2)

        %keyboard;
        disp('ERROR, BOX ENDS LATER THAN DATA FOR AT LEAST ONE TIME');
        disp('make sure there is >= (boxWidth/2 + 2) ms of data beyond the last requested time.');
        Result = []; return;
    end


    if isfield(data,'pre_dot_time')
        pre_time = data(1).pre_dot_time;
    elseif isfield(data,'pre_targ_time')
        pre_time = data(1).pre_targ_time;
    end;


    %find out which trials haven't dropped out yet;
    if isfield(data,'rts')
        newdata = single(data(cond).spikes);

        for addnan = 1:size(newdata,1)
     
        
            newdata(addnan,floor(data(cond).rts(addnan))+pre_time :size(newdata,2)) = NaN;

        end;
    else
        newdata = data(cond).spikes;
    end;



    %this is the right way to do this because if there are ANY nans in
    %the bin, the whole bin gets scored as a Nan. It would be weird to
    %count the spikes for only part of the bin.


    csum = cumsum(single(newdata(:,Tstart(1):Tend(end)+1)), 2); % casting as single makes it faster
    count = csum(:,Tend - Tstart(1)+1) - csum(:,Tstart - Tstart(1)+1);

    %there is no nancsum so I have to do this the slow way, I
    %think.
    num_total_trials = size(newdata,1);

    for countem = 1:length(times)

        %   count(1:num_total_trials,countem) = nansum(newdata(:,Tstart(countem):Tend(countem)),2);
        num_trials(countem) = size(find(~isnan(newdata(:,Tend(countem)))),1);

    end;

    % get rid of data when fewer than "remain_thresh" of the **trials** are
    % present.
    cut_here = min(find(num_trials < ceil(remain_thresh*num_total_trials)));
    count(:,cut_here:size(count,2)) = NaN;

    %this will tell you the last time window for which you have a
    %non-nan
    col_lastFinite = [];

    for ntrials = 1:size(count,1)

        if isempty(find(isfinite(count(ntrials,:)),1,'last'))
            keyboard
        end;
      
        col_lastFinite(ntrials) = find(isfinite(count(ntrials,:)),1,'last');
    end;


    varTemp = nanvar(count);  % var and mean are taken for all times at once (to save time)
    mnTemp  = nanmean(count);
    residTmp = count - (repmat(mnTemp,size(count,1),1));   %these are the residuals;


    endcond = startcond + size(count,1) -1;
    allconds_resid(startcond:endcond,1:length(times)) = residTmp;

    allconds_mean(startcond:endcond,1:length(times)) = count;


    startcond = endcond + 1;




    for t = 1:length(times)
        scatterDataAll(t).var(cond) = varTemp(t);

        scatterDataAll(t).mn(cond) = mnTemp(t);
        scatterDataAll(t).individ(cond).trials = count(:,t);
        scatterDataAll(t).individ(cond).col_lastFinite = col_lastFinite;

        scatterDataAll(t).numtrials(cond) = size(residTmp,1) - size(find(isnan(residTmp(:,t))),1);%min(find(isnan(mnTemp))) - 1;%size(count,1);
        scatterDataAll(t).individ(cond).fxTrialsRemainingAll = num_trials(1:length(num_trials))/num_trials(1);
        scatterDataAll(t).residuals = residTmp(:,t); %all the residuals at time t.

   
        %This next line will just generate random indices which you will
        %later use to resample "count"
        take_these = unidrnd(size(count,1),size(count,1),nboot);
        take_these = uint16(take_these);
        endboot = startboot + size(count,1)-1;
        new_means = nanmean(reshape(count(take_these,t),size(count,1),nboot));
        new_counts = (reshape(count(take_these,t),size(count,1),nboot));
        
        %Now subtract off each resampled mean from each new list of
        %resampled counts. This will create a whole set of resampled
        %residuals. 
        resample_resid = new_counts -repmat(new_means,size(count,1),1);
        scatterDataAll(t).new_means(cond,:) = new_means;
        scatterDataAll(t).boot(startboot:endboot,:) = resample_resid;
        
        

        
        %to check:
        %[a b] = hist(mean(new_counts));plot(b,a)
        %vline(mean(count(:,t)))
        %If the line isn't in the middle of your distribution, something is
        %wrong. The true mean should be in the middle of the resampled
        %means. 
        %You can perform this same exercise with the residuals, but
        %remember that they are really small, and the means for the actual
        %data are based on a smallish number of samples. So we don't expect
        %the means to line up perfectly. 

        
    end


    startboot = endboot + 1;
    trialCount(cond) = size(data(cond).spikes,1); % (used for weighted regression)   
    maxRate = max(maxRate, max( mnTemp ) ); %I think this should actually be called maxCount
    

end; %if new_way


% COMPUTE FIRING RATE DISTRIBUTIONS AT EACH TIME TO BE TESTED
% This is necessary even if we aren't downselecting, to provide the user with bin and dist info
meanRates = zeros(length(times),2);  % initialize to save time
bins = 0:binSpacing:maxRate+binSpacing;  % bins that define the precision of the match

for t = 1:length(times)

    fraction_remain = size(find(~isnan(scatterDataAll(t).mn)),1)/size((scatterDataAll(t).mn),1);
    if fraction_remain > remain_thresh %you muyst have 1/3 of conditions to proceed.


        meanRates(t,1) = 1000 / boxWidth * nanmean(scatterDataAll(t).mn); % convert to spikes/s (ONLY for the rate)
        stdOfDeltaRate(t,1) = 1000 / boxWidth * nanstd(scatterDataAll(t).mn - scatterDataAll(1).mn); % standard deviation of means
        % keyboard;
        stdErrOfRate(t,1) = (1000 / boxWidth) * (nanstd(scatterDataAll(t).mn)/sqrt(size(scatterDataAll(t).mn,1))    );



        [distData(t).counts, distData(t).whichBin] = histc(scatterDataAll(t).mn,bins);
        if distData(t).counts(end) > 0
            disp('ERROR: last bin contained more than one datapoint');

        end; % the last element is the number outside the bin range (should always be zero)
        distData(t).binEdges = bins';  % just the bins themselves (so the user can use them for plotting etc)
    else


    end
    targetCount = min( [distData.counts], [], 2);  % takes min count, across the measurement times, for each bin.



end;




% COMPUTE SLOPE VERSUS TIME FOR ENTIRE DATA SET (no distribution matching yet)

for t = 1:length(times)
   

    %get rid of all 0 entries

    zipmn= find(scatterDataAll(t).mn ~= 0);
    zipvar = find(scatterDataAll(t).var ~= 0);
    take_these = intersect(zipmn,zipvar); %so these points have no 0 var & no 0 mn

    nozipmn = scatterDataAll(t).mn(take_these);
    nozipvar = scatterDataAll(t).var(take_these) ;

    %[B, stdB] = lscov(log(nozipmn), log(nozipvar), regWeights(take_these));

    % t
    notanan = (find(~isnan(scatterDataAll(t).mn)));
    nonanmean = scatterDataAll(t).mn(notanan);
    nonanvar = scatterDataAll(t).var(notanan);

    if weightedRegression % the variance of the estimate of the variance (whew!) scales as the square of the mean, and inversely with trial count
        regWeights = trialCount(notanan) ./ (nonanmean + weightingEpsilon) .^ 2;
    else
        regWeights = ones(size(nonanmean));
    end



    % [B, stdB] = lscov((scatterDataAll(t).mn), (scatterDataAll(t).var), regWeights);

    if ~isempty(notanan)
        [B, stdB] = lscov((nonanmean), (nonanvar), regWeights);

        Bint = [B-2*stdB, B+2*stdB]; %actually, fix this: shouldn't be exactly 2, use tinv or something.

    else %means we have all nans.
        B = NaN;
        bint = [NaN NaN];

    end;
    slopesAll(t,1) = B;

    slopesAll_95CIs(t,1:2) = Bint;




    if includeVarMinusMean  % if asked by user (default is not)
        fraction_remain = size(find(~isnan(scatterDataAll(t).mn)),1)/size((scatterDataAll(t).mn),1);
        if fraction_remain > remain_thresh %you muyst have 1/3 of conditions to proceed.

            if size(conditional_FF,1) > size(scatterDataAll(t).mn,1)
                sprintf('this seems like a bad idea')
                conditional_FF = conditional_FF(1:size(scatterDataAll(t).mn,1));
            end;

            meanTemp = nanmean(scatterDataAll(t).var - (diag(conditional_FF)*scatterDataAll(t).mn));
            semTemp = nanstd(scatterDataAll(t).var - (diag(conditional_FF)*scatterDataAll(t).mn)) / sqrt(length(scatterDataAll(t).var));
            VMMall(t,1) = meanTemp;
            VMMall_95CIs(t,1:2) = meanTemp + [-2, 2]*semTemp;
            scatterDataAll(t).VarCE = (scatterDataAll(t).var - (diag(conditional_FF)*scatterDataAll(t).mn)); ;

        else
            VMMall(t,1) = NaN;
            VMMall_95CIs(t,1:2) = [NaN NaN];

        end;
    end

end






if ~isempty(provide_marg)
    sprintf('WARNING:  this is using a provided LCD?')
    keyboard;
    targetCount = provide_marg;

end;


%NOW DO THE DISTRIBUTION MATCHING, if you have elected to do so. 
if matchReps > 0
    scatterDataSelect = scatterDataAll;  % this will be downselected
    sumSlopes = zeros(length(times),1);  % used to compute mean slope across downselection draws
    sumCIs = zeros(length(times),2);     % ditto for the CI on that slope

    if includeVarMinusMean
        sumDiffs = zeros(length(times),1); % initialize for speed (parallel with sumSlopes above)
        sumDiffCIs = zeros(length(times),2);
    end

    for rep = 1:matchReps   % distribution matching gets done 'matchReps' times
        for t = 1:length(times)
            toKeep = [];

            for b = 1:length(bins)-1  % go through (spike count) bins and figure out which datapoints to keep
                thisBin = find( distData(t).whichBin == b );  % indices for means in this bin  %%AC: so find which cells hace a firing rate that matches the current bin
                if length(thisBin) < targetCount(b), disp('ERROR: target count not right'); end
                thisBin = thisBin(randperm(length(thisBin)));  % shuffle before cutting off the end.
                if targetCount(b)~=0
                    toKeep = [toKeep; thisBin(1:targetCount(b))];  % keep at most all
                end
                distData(t).countsSelect(b,1) = length(thisBin(1:targetCount(b)));
            end

            distData(t).countsSelect(length(bins),1) = 0;  % All dists should end with a zero
            %    figure(23);hold on;
            %   plot(bins,distData(t).counts,'k');
            %   plot(bins,distData(t).countsSelect,'r');



            mnsThisRep = scatterDataAll(t).mn(toKeep);
            varsThisRep = scatterDataAll(t).var(toKeep);
            %remember to onyl keep the phis for the conditions we are
            %using!:
            FF_this_rep = conditional_FF(toKeep);

            %What I wrote below makes no sense- you can't do this. The
            %problem is that different cells are contributing at each time
            %point. So how can you take the covariance for some condition
            %and say, t1 and t5, when only t5 is contributing. 
            %This emphasizes an advantage of VarCE over mean-matched FF: it
            %extends naturally to the CorCE. 
            
            % mycov(makecond).cov = zeros(length(times));
            %mycov(cond).cov = cov(count);%./max(max(cov(count)));

            if weightedRegression  % default is weighted
                regWeights = trialCount(toKeep) ./ (mnsThisRep + weightingEpsilon).^2;
            else
                regWeights = ones(size(mnsThisRep));
            end


            [B, stdB] = lscov(mnsThisRep,varsThisRep, regWeights);
            Bint = [B-2*stdB, B+2*stdB];

            sumSlopes(t,1) = sumSlopes(t,1) + B;
            sumCIs(t,:) = sumCIs(t,:) + Bint;

            if rep == 1 % the returned scatterpoints are from the first rep
                scatterDataSelect(t).mn = mnsThisRep;
                scatterDataSelect(t).var = varsThisRep;
            end


            meanRates(t,2) = meanRates(t,2) + 1000/boxWidth*mean(mnsThisRep)/matchReps; % mean over all reps


            % Variance MINUS Mean

            if includeVarMinusMean  % if asked by user (default is not)

                meanTemp = mean(varsThisRep - FF_this_rep.*mnsThisRep);
                semTemp = std(varsThisRep - mnsThisRep) / sqrt(length(varsThisRep));
                sumDiffs(t,1) = sumDiffs(t,1) + meanTemp;
                sumDiffCIs(t,:) = sumDiffCIs(t,:) + meanTemp + semTemp*[-2, 2];

            end
        end
    end



    slopes = sumSlopes / matchReps;  % computes the mean from the sum ('matchReps' repeats were used)
    slopes_95CIs = sumCIs / matchReps;

    if includeVarMinusMean  % if the user also wants the variance minus the mean
        diffs = sumDiffs / matchReps;
        diffs_95CIs = sumDiffCIs / matchReps;
    end

    fprintf('%d percent of datapoints survived matching\n', round(100*sum(distData(1).countsSelect) / sum(distData(1).counts)));
end

% DONE WITH COMPUTATIONS
% MAKE OUTPUT STRUCTURE: 'Result'
if matchReps > 0
    Result.FanoFactor = slopes; % slopes (distribution matched)
    Result.Fano_95CIs = slopes_95CIs; % 95% CI's on those slopes
    %Result.scatterData = scatterDataSelect';  % data for scatterplot (distribution matched)
end

Result.FanoFactorAll = slopesAll;  % slopes (not distribution matched)
Result.FanoAll_95CIs = slopesAll_95CIs; % 95% CI's on those slopes
Result.scatterDataAll = scatterDataAll';  % data for scatterplot (not distribution matched)

allvar = [scatterDataAll.var];
if size(allvar,1) > 1
    Result.justVariance = nanmean(allvar) * 1000/boxWidth;
else
    Result.justVariance = (allvar) * 1000/boxWidth;
end;


if matchReps > 0
    Result.meanRateSelect = meanRates(:,2); % the 'mean mean-rate' across time, after matching (should change little)
end                             % mean rates are in spikes/s (not spike count, like everything else)

Result.stdOfDeltaRate = stdOfDeltaRate(:,1);
distData = rmfield(distData,'whichBin'); %doesn't need to be returned to user
Result.distData = distData';  % distributions of spike counts for the different times




Result.times = times' - alignTime;  % just the times that the user asked for, stored here for convenience


end_real_values = min(find(isnan(allconds_resid(:,1))));
allconds_resid(end_real_values:size(allconds_resid,1),:) = [];


%s2 is a big long vector of all the residuals.
s2 = (nanvar(allconds_resid));
m_i=  [scatterDataAll.mn];
n_i = ([scatterDataAll(1).numtrials]);
N_z = sum(n_i); %totalTrials
myphi = 0.48; %just for now; fix later;


%get bootstrapped s:

mean_new = zeros(1,length(times));
%% compute VarCE from the residuals

if size(conditional_FF,1) == 1
    conditional_FF = (conditional_FF*ones(size(data))');
end;

for t = 1:length(times)


    %note: to check this. Look at the mean value at some particular
    %time, say t=2:  (mean(allconds_resid(:,2)))
    %then look at the distribution of estimates for this mean at the same
    %time. The center of that distribution should be about where the real
    %mean is. The std dev of that distribution is the std error.
    %[a,b] = hist(mean(scatterDataAll(2).boot)); plot(b,a)
    %hold on
    %vline(mean(allconds_resid(:,2)))
    %allconds_resid is the real data; you have one point for EACH TRIAL at
    %each time. For the bootstrapped data, you can't store it all in one
    %matrix because you hjave 50 samples for each trial at each time point.
    %So those data are each in an entry in scatterDataAll. 
    
    %Remember that
    %the residuals are generated by taking the counts a whole bunch of
    %times and subtracting off re-sampled means. Because there are SO MANY
    %tirals, the resampled means just don't differ from the sampled means
    %by that much. 

    boot_s2_thistime = nanvar(scatterDataAll(t).boot);%this gives you the variance for each run through the bootstrap
    %this will be a vector that has 20 estimates of the variance, each
    %taken from one run through the bootstrap. There are as many values in
    %scatterDataAll(t).boot as there are trials.

    N_z_thist = size(find(~isnan(allconds_resid(:,t))),1);
    n_i_thist = scatterDataAll(t).numtrials;%(n_i > t).*n_i;%size(find(n_i >= t));
    % wtd_ppv_orig = nansum( diag((n_i/N_z))    * ((diag(conditional_FF')* m_i(:,t)) ) );

    %argh, have to do this bc you can't multiply the nans by the
    %diagonal matrix or you get all nans.
    cut_this = find(isnan(m_i(:,t)));

    
    
    fraction_remain = size(find(~isnan(m_i(:,t))),1)/size(m_i(:,t),1); %look at what fraction of conditions are still "contributing", that is, the RT is longer than the time point we are currently at
    if fraction_remain > remain_thresh 
      

        mean_new(t) = nanmean(allconds_mean(:,t));
        std_err_mean(t) = nanstd((allconds_mean(:,t)))./ sqrt(size(allconds_mean,1));

        m_i(cut_this,t) = 0; %this is going to get multiplied by a wt of 0 anyway.
        conditional_FF(find(isnan(conditional_FF))) = 0;

        %the ppv is a weighted sum that depends on which fraction of the
        %trials came from a particular cell. recall that
        %sum(n_i_thist/N_z_thist) should = 1
        

        
        wtd_ppv =      nansum( diag((n_i_thist/N_z_thist))    * ((  (conditional_FF')* diag(m_i(:,t))    ) )' );
        wtd_mean =     nansum( diag((n_i_thist/N_z_thist)) * m_i(:,t)); %this is as if conditional_FF = 1; so this will be larger

        %now do the same thing for the bootstrap analysis: here we have a
        %matrix of weighted ppvs because there is a different mean for each of
        %the "nboot" runs through.
      
        wtd_ppv_boot = nansum( diag((n_i_thist/N_z_thist))    * (diag(conditional_FF')* scatterDataAll(t).new_means ) );


        if length(wtd_ppv) > 1
           sprintf('wtd_ppv is the wrong size. should be a number')
           %Sometimes this happens because your conditional_FF in your
           %params structure is not of the dimension: Nx1, where N is the
           %number of trials (eg, 1XN) will cause this problem. 
            keyboard
        end;

        all_ppv(t) = wtd_ppv;

        EV_new(t) = s2(t) - wtd_ppv;
        FF_new(t) = s2(t)/wtd_mean;
        %this is the bootstrap estimate for each of the nboot runs through for
        %the EV.
        boot_EVs = boot_s2_thistime - wtd_ppv_boot; %so this will give you a whole bunch of bootstrapped estimates of EV
        stderr_EV(t)  = nanstd(boot_EVs); %this is the standard error because it is the std deviation of an estimate (or something).

        boot_FFs = boot_s2_thistime/wtd_mean;
        stderr_FF(t)  = nanstd(boot_FFs);




    else

        mean_new(t) = NaN;
        std_err_mean(t) = NaN;
        stderr_EV(t)  =NaN;
        EV_new(t)= NaN;
        all_ppv(t)= NaN;
        stderr_FF(t) = NaN;
        FF_new(t) = NaN;
    end; %if fraction_remain


end;



Result.meanRateAll = mean_new' * (1000/boxWidth); % the 'mean mean-rate' across time, no matching (just the pop mean)

Result.stdErrOfRate = std_err_mean' * (1000/boxWidth);
Result.FF_resid = FF_new;
Result.stdErrOfFF = stderr_FF;


%% compute CorCE from the residuals

if diff(times(1:2)) > 30


    [val ind] = min(abs(times - 390)); %see if there is a point that is JUST at decision onset, 200 ms after motion onset
    %i.e. you have a time = 200 instead of time = [190 250 ...];
    if val == 0
        num_points_to_skip = ind ; %because you DON'T want to tkae the 0!
    else

        num_points_to_skip = ceil(alignTime/diff(times(1:2))); %min(find((times - alignTime) > 0)) ;%
    end;

    cov_times = times(num_points_to_skip+1:length(times));
    
    if size(allconds_resid,2) >= num_points_to_skip+8

        allconds_resid_cut = allconds_resid(:,num_points_to_skip:num_points_to_skip+8);
        EV_new_cut = EV_new(num_points_to_skip:num_points_to_skip+8);
        
        cov_times = times(num_points_to_skip:num_points_to_skip+8);
        
    else
        allconds_resid_cut = allconds_resid;
        EV_new_cut = EV_new;

    end;

    
    ECV_new = nancov(allconds_resid_cut,'pairwise');
    totalCVM = ECV_new;

    for i =1:length(ECV_new)
        ECV_new(i,i) = EV_new_cut(i);
    end
    times_for_cov = size(ECV_new,2);

    corCE = nan((times_for_cov),(times_for_cov));
    
    
  %  keyboard;
    if ~isempty(find(ECV_new<0))
        sprintf('Warning: There are some negative elements to your covariance matrix. \nIf this is real data, this may indicate that you are using a measure of phi that is TOO LARGE')
        %Think about it: if phi is too big, you subtract off TOO much PPV,
        %bringing the adjusted covariance matrix below 0. 
        ECV_new(find(ECV_new<0)) = NaN;
    end;

    for i = 1:times_for_cov
        for j = 1:times_for_cov
            corCE(i,j) = ECV_new(i,j)/sqrt(ECV_new(i,i)*ECV_new(j,j));
            
            totalCR(i,j) = totalCVM(i,j)/sqrt(totalCVM(i,i)*totalCVM(j,j));
        end
    end
    
    if ~isempty(find(corCE>1))
        sprintf('Warning: There are some elements in your CorCE matrix that are >1. \nIf this is real data, this may indicate that you are using a measure of phi that is TOO LARGE')
        %Think about it: if phi is too big, you subtract off TOO much PPV,
        %this means that you have a number in your denominator that is TOO
        %small, and the corCE gets inflated.

    end;
    

    
   % if ~(isempty(find(isnan(corCE)))); %means we have some nans
   %     corCE = corCE(1:min(find(isnan(corCE(1,:))))-1,1:min(find(isnan(corCE(1,:))))-1)
    %    times = times(1:max(find(~isnan(EV_new))));
   % end;

    Result.CorCE = corCE;
    Result.cov_times = cov_times;
    Result.covCE = ECV_new;
    Result.rawCov = totalCVM;
   

end; %if length(times);




if includeVarMinusMean  
    if matchReps >= 1  
        Result.varMinusMean = diffs;
        Result.VMM_95CIs = diffs_95CIs;
    end;

    Result.VarCE = EV_new';


    Result.VarCE_std_errors = [stderr_EV'];

end



Result.bins = bins;
if matchReps == 1
    Result.survival_percentage = round(100*sum(distData(1).countsSelect) / sum(distData(1).counts));
end;

Result.marginal = targetCount;
Result.conditions_FF = conditional_FF;




%mini_dists(distData,[5 8 11],bins,Result);

if omitRaw == 1
    Result.FanoFactorAll = [];
    Result.meanRateAll = [];
    Result.VarCE = [];
end;






% purpose: draws a vertical line on the current axis
function vline(hpos,linetype)

ax = axis;

if (nargin == 1)
  plot([hpos hpos],[ax(3) ax(4)],'k:');
elseif (nargin == 2)
  plot([hpos hpos],[ax(3) ax(4)],linetype,'linewidth',2);
else
  help vline
end









