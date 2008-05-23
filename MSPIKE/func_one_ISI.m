
function func_one_ISI(dataFile, PathName, sweepPeriod, stimOn, stimFreq, stimPeriod, bins, binWidth, Dt, Data_Rows, Data_Columns, Time, currentSweep, samplingPeriod)
% First-Order Inter-spike Interval Histogram. 
% This subroutine is part of mspike (MALTAB Neuronal Spike Pattern Analysis)
% Written by Hazem Baqaen, Brown University Departments of Psychology and
% Neuroscience, September 2004. Supervisors: Professors Andrea and James
% Simmons. E-mail: hazem@brown.edu. Designed on MATLAB 6.5.


% Next block: Discard spikes that are either outside the stimulus interval, or
% singleton spikes in a sweep for which an inter-spike interval is not defined.
% Discarding is done for the purposes of computing the ISIs, so the outputs
% and variables of this program should never be used to reconstruct the original 
% data set.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rowdiscard = 0;
for snippet = 1:Data_Rows,
    if (Time(snippet) > stimOn) | (Time(snippet) < 0)  % Discard data ourside of stimulus duration interval
        Time(snippet) = NaN;                           %% (_Note_: since DataArray is not used, the same was not done for it)
        currentSweep(snippet) = NaN;             
        rowdiscard = rowdiscard +1;                    % Discarded data row counter
    end
end
Time = Time(finite(Time));
currentSweep = currentSweep(finite(currentSweep));     % See comments above (keep only good spikes)
Data_Rows = Data_Rows - rowdiscard;                    % Update number of data rows (spikes) remaining
rowdiscard = 0;                                        % Re-initialize discarded row counter
%%
for snippet = 1:Data_Rows,                             % Case of intermediate sweep with single snippet that must be discarded 
    if ((snippet > 1) & (snippet < Data_Rows)) & ((currentSweep(snippet+1) - currentSweep(snippet-1)) >= 2) 
        Time(snippet) = NaN;
        currentSweep(snippet) = NaN;
        rowdiscard = rowdiscard +1;
    end
end
Time = Time(finite(Time));
currentSweep = currentSweep(finite(currentSweep)); 
Data_Rows = Data_Rows - rowdiscard;
rowdiscard = 0;
%%
for snippet = 1:Data_Rows,                             % Case of first sweep containing only one snippet and must be discarded 
    if (snippet == 2) & ((currentSweep(snippet) - currentSweep(snippet-1)) >= 1),        
        Time(1) = NaN;
        currentSweep(1) = NaN;
        rowdiscard = rowdiscard +1;
    end
end
Time = Time(finite(Time));
currentSweep = currentSweep(finite(currentSweep)); 
Data_Rows = Data_Rows - rowdiscard;
rowdiscard = 0;
%%
for snippet = 1:Data_Rows,
    if snippet == Data_Rows,                            % Case of last sweep containing only one snippet and must be discarded
        if ((currentSweep(snippet) - currentSweep(Data_Rows-1)) >= 1),           
            Time(snippet) = NaN;
            currentSweep(snippet) = NaN;
            rowdiscard = rowdiscard +1;
        end
    end
end
Time = Time(finite(Time));
currentSweep = currentSweep(finite(currentSweep)); 
Data_Rows = Data_Rows - rowdiscard;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for snippet = 2:Data_Rows,                       
    if currentSweep(snippet) - currentSweep(snippet-1) > 1   % Make sweep numbers monotonically increasing before proceeding
        currentSweep(snippet:Data_Rows) = currentSweep(snippet:Data_Rows) - (currentSweep(snippet)-currentSweep(snippet-1));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Generate ISI matrix
% See next code block for more explanation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sweep = 0;                                      % Initialize sweep counter
snippet1 = 1;                                   % Starting data snippet (spike) of each sweep 

for snippet = 1:Data_Rows+1,                    % snippet is equivalent to spike data row index (each spike's data points are stored in a row)
    if snippet <= Data_Rows
    %[spikeMax(snippet), occurenceIndex(snippet)] = max(DataArray(snippet,:));   % Extract peaks and their indices for later
    timeOccurence(snippet) = Time(snippet) + samplingPeriod*Data_Columns/4;    % + samplingPeriod*occurenceIndex(snippet);  
    end

    if (snippet > Data_Rows) | (currentSweep(snippet) > sweep)    % Do for each sweep 
        for n_minus_one = 0:(snippet-snippet1)-1,                 % Increment spike to which all succeeding difference intervals are calculated in each sweep
            for spikecounter = (snippet1+n_minus_one+1):(snippet-1),    % Calculate Inter-Spike Intervals for all spikes, "orders", and sweeps (3-D array: ISI)
                n = 1+n_minus_one;
                intervalindex = spikecounter-snippet1;
                SWEEP = 1+sweep;
                ISI(n,intervalindex,SWEEP) = timeOccurence(spikecounter)-timeOccurence(snippet1+n_minus_one);
            end    
        end
        snippet1 = snippet;                     % Update sweep interval
        sweep = sweep + 1;    
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear currentSweep;
clear Time;                                     % Clear currentSweep and Time to save memory


% This following code block loops over sweeps, calculating 1st-order ISI's 
% for each sweep. Diagonal elements of each sweep's ISI 2-D sub-matrix ( ISI(:,:,sweep) )
% represent the sought intervals for the sweep in the first order. 
% The second order intervals would be the first upper off-diagonal, and 
% so on. 
% By concatenating the 1st-order ISI values (diagonals) for each sweep, we get the
% complete set for all sweeps, which are subsequently plotted. However, the
% zero elements are removed first so as not to skew the bar graph toward
% zero, since the zero elements on the diagonals are not real interval
% values but were generated to keep the 3-D ISI supermatrix cuboid-shaped.
% Removing those zero intervals is justified by the fact that the recording
% equipment are unable to assign two time stamps for two spikes that occur
% at the same time. This of course holds true for single-channel recording.

% The way to visualize the ISI matrix is as a 3-D cuboid which is a stack
% of 2-D sub-matrices each corresponding to a sweep. The dimensions (rows
% and columns) of these sub-matrices do not correspond directly to any
% quantities of interest.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
one_ISI = diag(ISI(:,:,1));                     % Look at first sweep initially, get 1st-order ISIs
for sweepindex = 2:sweep,                       % First Order ISI arrays for all sweeps
    one_ISI = cat(1,one_ISI,diag(ISI(:,:,sweepindex))); % Concatenate diagonals of all sweep matrices
end
one_ISI = nonzeros(one_ISI);                    % Eliminate zero intervals

figure                                          % Plot First-Order ISI Histogram

bar(bins,histc(one_ISI',bins),'histc')   
axis([0 max(one_ISI) 0 10])                     % Set axes for plotting
axis 'auto y'
title('First-Order Inter-Spike Interval Histogram');
xlabel('Interval Length (s)');
ylabel(['Interval Count Per  ' num2str(binWidth) 's']);
text(max(xlim)/2, -0.09*max(ylim), ['File Name = ' dataFile], 'HorizontalAlignment','center')    % Place annotation

set(gcf,'position',[4 34 1150 760]);        % Size and position of figure. These specifiers are screen-size dependent.

fname = strrep(dataFile,'.csv','');         % Intermediate file name, Remove .csv name extension
%saveas(gcf,strcat('MSPIKEoutputs/',strrep(fname,'spike','Interspike_one')),'bmp')    % Save figure as image file, specify output directory, and modify name.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

