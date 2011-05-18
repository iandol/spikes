% useage: P = simpleSigTest(Result,T1,T2)
% or:     P = simpleSigTest(Result,T1,T2,'raw') to do it on the raw.

function P = simpleSigTest(Result,T1,T2,varargin)

if ~isempty(varargin) && strcmp(varargin{1},'raw')
    % for purposes of this function, substitute raw FF
    Result.FanoFactor = Result.FanoFactorAll;
    Result.Fano_95CIs = Result.FanoAll_95CIs;
end

index1 = find(Result.times == T1);
index2 = find(Result.times == T2);

FF1 = Result.FanoFactor(index1);  % this better be the LARGER
FF2 = Result.FanoFactor(index2);  % this better be the SMALLER

CI1 = Result.Fano_95CIs(index1,2) - FF1;
CI2 = Result.Fano_95CIs(index2,2) - FF2;

SD1 = CI1 / norminv(0.975,0,1);  % convert the 95% CI to the SD of the sampling dist
SD2 = CI2 / norminv(0.975,0,1);  % we have enough data that the sampling dist is pres. gaussian.

P1 = 1 - normcdf(FF1-FF2, 0, SD1);
P2 = 1 - normcdf(FF1-FF2, 0, SD2);

P = max(P1,P2);

fprintf('FF diff is %1.3f\n', FF1 - FF2);
fprintf('p value is %g\n', P);
