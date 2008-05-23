
function func_any_ISI(dataFile, PathName, sweepPeriod, stimOn, stimFreq, stimPeriod, bins, binWidth, Dt, Data_Rows, Data_Columns, Time, currentSweep, samplingPeriod, range)
% Inter-spike Interval Histogram for any order or combination of orders. 
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
% See one_ISI code block for more explanation
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


% In the following code block, any range of orders can be plotted. As shown
% before, an order corresponds to the diagonal values or upper off-diagonals of
% the ISI matrix. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear sweepindex;                           % Clear previous value of this local variable
n_ISI = [];                                 % n_ISI is just the diagonal of the ISI submatrix for the particular order being computed
nrange_ISI = [];                            
os = [];
[nMax,nv,nrSweeps] = size(ISI);             % Get dimensions of previously generated ISI data array
for order = range,                          % Loop over orders in range
    if order > nv
        disp([' The maximum possible order for this data is ' num2str(nv)])
        order = nv;
        break
    end
    for sweepindex = 1:nrSweeps,            % Loop over all sweeps
        n_ISI = diag(ISI(1:(nv-order+1),order:nv,sweepindex)); % Distance from the diagonal is related to order thus: 1st order = diagonal, 2nd order = 1st upper off-diagonal, etc.
        nrange_ISI = [nrange_ISI; n_ISI];   % Concatenate results
    end
    os = [os order];
end
nrange_ISIp = nonzeros(nrange_ISI);         % Discard zeros and prepare for plotting

figure                                      % Plot order range ISI Histogram

bar(bins,histc(nrange_ISIp',bins),'histc')  
axis([0 max(nrange_ISIp) 0 10])
axis 'auto y'
title(['[' num2str(os) '] Order Inter-Spike Interval Histogram']);
xlabel('Interval Length (s)');
ylabel(['Interval Count Per  ' num2str(binWidth) 's']);
text(max(xlim)/2, -0.09*max(ylim), ['File Name = ' dataFile], 'HorizontalAlignment','center')    % Place annotation

set(gcf,'position',[4 34 1150 760]);        % Size and position of figure. These specifiers are screen-size dependent.

fname = strrep(dataFile,'.csv','');         % Intermediate file name. Remove .csv name extension
saveas(gcf,strcat('MSPIKEoutputs/',strrep(fname,'spike','Interspike_any')),'bmp')    % Save figure as image file, specify output directory, and modify name. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

