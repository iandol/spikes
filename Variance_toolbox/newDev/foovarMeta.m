
rates = [0 5 10 20 50 100];
trials = 10;
reps = 5000;


index = 1;
for rate = rates
    errorWrate(index) = foovar(rate,trials,reps);
    index = index+1;
    fprintf('done with rate of %d\n', rate)
end

figure
plot(rates*100/1000,errorWrate);
hold on;
plot(rates*100/1000,errorWrate, 'o');
axis([-1 12 -1 25]);
axis square
title('variance of sampling distribution versus mean spike count')

figure
plot((rates*100/1000).^2,errorWrate);
hold on;
plot((rates*100/1000).^2,errorWrate, 'o');
axis([-10 120 -1 25]);
axis square
title('variance of sampling distribution versus square of mean spike count')


% now for relationship to trial count
rate = 50;
trialCounts = [5 10 15 25 50 100];
index = 1;
for trials = trialCounts
    errorWtrials(index) = foovar(rate,trials,reps);
    index = index+1;
    fprintf('done with trial count of %d\n', trials)
end

figure
plot(rates,errorWtrials, 'r');
hold on;
plot(rates,errorWtrials, 'ro');
axis([-5 120 -5 20]);
axis square
title('variance of sampling distribution versus trial count')

figure
plot(rates,1./errorWtrials, 'r');
hold on;
plot(rates,1./errorWtrials, 'ro');
axis([-5 120 -1 4]);
axis square
title('1 / variance of sampling distribution versus trial count')



