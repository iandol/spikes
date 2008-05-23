function savetext(file,matr)
%Saves a matrix as a text file, with more portable formatting
% savetext(file,matrix)
% file=file to save to
% matrix=matrix to be saved

fid=fopen(file, 'w');

t=1;

for i=1:size(matr,1)
    for j=1:size(matr,2)
        if j<size(matr,2)
            fprintf(fid, '%6.3f\t', matr(i,j));
        elseif j==size(matr,2)
            fprintf(fid, '%6.3f\n', matr(i,j));
        end
    end
end

fclose(fid);

    