
function  func_rpsth(dataFile, PathName, sweepPeriod, stimOn, stimFreq, stimPeriod, bins, binWidth, Dt, Data_Rows, Data_Columns, Time, currentSweep, samplingPeriod, StartTime1, EndTime1, StartTime2, EndTime2)  
% Raster Plot, Peri-Stimulus-Time Histogram, Average Onset Latency, and Spike Counts
% This subroutine is part of mspike (MALTAB Neuronal Spike Pattern Analysis)
% Written by Hazem Baqaen, Brown University Departments of Psychology and
% Neuroscience, September 2004. Supervisors: Professors Andrea and James
% Simmons. E-mail: hazem@brown.edu. Designed on MATLAB 6.5.


sweep = 0;                                      % Initialize sweep counter
snippet1 = 1;                                   % Starting data snippet (spike) of each sweep 
runningSum_firstSpikeLatencies = 0;

for snippet = 1:Data_Rows+1,                    % snippet is equivalent to spike data row index (each spike's data points are stored in a row)
    if snippet <= Data_Rows
    %[spikeMax(snippet), occurenceIndex(snippet)] = max(DataArray(snippet,:));   % Extract peaks and their indices for later
    timeOccurence(snippet) = Time(snippet) + samplingPeriod*Data_Columns/4;    % + samplingPeriod*occurenceIndex(snippet);  
    end

    if (snippet > Data_Rows) | (currentSweep(snippet) > sweep)     % Do for each sweep
        subplot(2,1,1)
        plot(timeOccurence(snippet1:snippet-1),1+sweep,'b.')
        axis ij;
        hold on     
        firstSpikeLatency(snippet1) = timeOccurence(snippet1) - Dt;
        runningSum_firstSpikeLatencies = runningSum_firstSpikeLatencies + firstSpikeLatency(snippet1);
        snippet1 = snippet;                     % Update sweep interval and
        sweep = sweep + 1;                      % expand sweeps into their own axis for clarity
    end
end
title('Raster Plot 1');
xlabel('Time (s)');
ylabel('Nr. of Sweeps');
axis([0 sweepPeriod 0 10])
axis 'auto y'
plot([stimOn stimOn],[0 max(ylim)],'r')             % Add colored vertical line to define stimulus interval
hold off

Average_firstSpikeLatency = runningSum_firstSpikeLatencies/sweep;

SpikesInInterval_1 = timeOccurence(timeOccurence>=StartTime1 & timeOccurence<=EndTime1);    % Spike counts in intervals
SpikesInInterval_2 = timeOccurence(timeOccurence>=StartTime2 & timeOccurence<=EndTime2);

%all_event_times = sort(timeOccurence);

subplot(2,1,2)
bar(bins,histc(timeOccurence,bins),'histc')     % Plot Histogram
axis([0 sweepPeriod 0 10])
axis 'auto y'
title('Peri-Stimulus Time Histogram');
xlabel('Time (s)');
ylabel(['Event Count Per  ' num2str(binWidth) 's']);
text(max(xlim)/2, -0.23*max(ylim), ['File Name= ' dataFile  ', Latency = ' num2str(Average_firstSpikeLatency) 's' ', Total Spikes in Stim. Interval = ' num2str(length(SpikesInInterval_1)) ' (Normalised= ' num2str(round(length(SpikesInInterval_1)/sweep)) '), Spikes After Stim. = ' num2str(length(SpikesInInterval_2)) ' (Normalised= ' num2str(round(length(SpikesInInterval_2)/sweep)) '), Sweeps = ' num2str(sweep)], 'HorizontalAlignment','center')   % place annotation on figure
hold on
plot([stimOn stimOn],[0 max(ylim)],'r:')             % Add colored dotted vertical line to define stimulus interval
hold off

set(gcf,'position',[4 34 1150 760]);        % Size and position of figure. These specifiers are screen-size dependent.

fname = strrep(dataFile,'.csv','');         % Intermediate file name, Remove .csv name extension
%saveas(gcf,strcat('MSPIKEoutputs/',strrep(fname,'spike','rpsth')),'bmp')    % Save figure as image file, specify output directory, and modify name.


