
function M2 = DoubleFrames(M)

index = 1;
for f = 1:length(M)
    for k = 1:2
        M2(index) = M(f);
        index = index+1;
    end
end