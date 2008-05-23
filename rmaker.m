function rmaker(cell1,index)

% Raster Plotter for the Spike Times

if size(index,2)~=2
    errordlg('Sorry, incorrect selection of variable')
end

strain=cell1.raw{index}
ntrials=strain{1}.ntrials
maxtime.cell1.trialtime
