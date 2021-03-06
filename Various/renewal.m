% RENEWAL  simulates a renewal process 

% BN168  Spring 2006

% renewal spiking process with truncated-normal or uniform ISI distribution.

clear

%%%%% PARAMETERS %%%%%
epoch = 2;                  % length of epoch in sec
ntrials = 20;               % number of trials
bin_length = .001;           % bin length (discretization of time axis) in sec
mu = .01;                    % mean ISI (in sec) for normal distribution
sigma = .1;                 % std of ISI (in sec) for normal distribution
ISI_min = .001;              % min ISI (in sec) for uniform distribution
ISI_max = .1;              % max ISI (in sec) for uniform distribution
l_plot = 2;                 % length of plot of spike train (in sec)
normal_flag = 2;            % 1 for normal distribution, other for uniform

%%%%%%%%%%%%%%%%%%%%%%%

time_axis = 0:bin_length:epoch;  % time axis
N = length(time_axis);           % total number of bins in epoch
M = epoch/mu;       % mean number of spikes in epoch

sta = time_axis(time_axis<=l_plot);      % short time axis
n = length(sta);                         % number of bins in short epoch


% each spike train (trial) is generated by drawing a series of independent ISI's:

if normal_flag == 1     % normal
    isi = normrnd(mu,sigma,ntrials,2*M);
            % to be on the safe side, generate twice as many as needed on average
            % will discard the unused ones
    isi = max(bin_length,isi);   % truncate the ISI's             
else                    % uniform
    isi = ISI_min + (ISI_max-ISI_min)*rand(ntrials,2*M);
            % to be on the safe side, generate twice as many as needed on average
            % will discard the unused ones
end



Spike_Times = cumsum(isi,2);             % cumulative row sums
spike_train = zeros(ntrials,N);          % these will be the binned spike trains

for trial = 1:ntrials
    ST = Spike_Times(trial,:);
    st = ST(ST<epoch);                   % discard spike times outside epoch
    spike_train(trial,round(st/bin_length)) = 1;
end

number_spikes = sum(spike_train,2);

figure(1)

for trial = 1:3
    subplot(5,1,trial)
    h = stem(sta,spike_train(trial,1:n));
    set(h(1),'Marker','none')           % removes the circles from the stem plot
    set(h(1),'LineWidth',1)
    set(gca,'YLim',[0 1.5])
    [c_v,ISI] = coef_var(spike_train(trial,:),bin_length);       % coefficient of variation of ISI
    text(.1,1.2,['# spikes over ' num2str(epoch) ' sec : ' num2str(number_spikes(trial)) '             CV : ' num2str(c_v)])
end

psth = sum(spike_train);
subplot(5,1,4)
h = stem(sta,psth(1:n));
set(h(1),'Marker','none')           
set(h(1),'LineWidth',1)
text(.1,.7*max(psth(1:n)),['grand total number of spikes : ' num2str(sum(psth))])


                                                    
subplot(5,1,5)
max_interval = max(ISI);
histogram = hist(ISI,0:bin_length:max_interval);    % ISI histogram
bar(0:bin_length:max_interval,histogram,1)
set(gca,'XLim',[0 max_interval])
set(gca,'YLim',[0 max(histogram)])
text(.1*max_interval,.7*max(histogram),'ISI  HISTOGRAM for trial 5')
xlabel('interval (sec)')


fano = var(number_spikes)/mean(number_spikes);     % variance of count over mean of count
                                                  % ( = 1 for a Poisson process)
                                                  
% text(.7*max_interval,.7*max(histogram),['Fano Factor ' num2str(fano)])
disp(['Fano Factor = ' num2str(fano)])

figure(2)

n_lags = 500;                       % number of lags on either side of 0
lags = -n_lags:n_lags;
autocovariogram = autocorrelation(spike_train(trial,:),bin_length,lags);

autocovariogram(1+n_lags) = 0;      % remove the 0-lag term

plot(lags,autocovariogram)

