

function out = foovar(rate, trials, reps)

window = 100;
varC = zeros(reps,1);

for r = 1:reps
    x = rand(trials,window) < rate/1000;
    counts = sum(x,2);
    varC(r) = var(counts);
end

out = var(varC);  % sampling error
    
    
