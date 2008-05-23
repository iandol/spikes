
function func_period(dataFile, PathName, sweepPeriod, stimOn, stimFreq, stimPeriod, bins, binWidth, Dt, Data_Rows, Data_Columns, Time, currentSweep, samplingPeriod)
% Period Histogram, Synchronicity or 'Vector Strength', and Rayleigh Statistic
% This subroutine is part of mspike (MALTAB Neuronal Spike Pattern Analysis)
% Written by Hazem Baqaen, Brown University Departments of Psychology and
% Neuroscience, September 2004. Supervisors: Professors Andrea and James
% Simmons. E-mail: hazem@brown.edu. Designed on MATLAB 6.5.


for snippet = 1:Data_Rows,                      % snippet is equivalent to spike data row index (each spike's data points are stored in a row)
    if ((Time(snippet) + samplingPeriod*Data_Columns/4) <= stimOn) & ((Time(snippet) + samplingPeriod*Data_Columns/4) > 0)   % Determine spikes which occur during stimulus presentation
        timeOccurence(snippet) = Time(snippet) + samplingPeriod*Data_Columns/4;    
    else
        timeOccurence(snippet) = 0;
    end
end
timeOccurence = nonzeros(timeOccurence);        % Reduce dimension of timeOccurence vector to match number of spikes occuring during stimulus presentation
                                                %% (Discard zero elements, i.e., elements which do not satisfy above condition [no spikes occur exactly at zero]).
spikesInStim = length(timeOccurence);           % Number of spikes occuring during stimulation
npmax =  floor(stimOn/stimPeriod);              % Maximum number of periods (stimulus sinusoid wave cycles) in stimulus     
for periodIndex = 0:npmax,                      % The purpose of this nested loop is to generate an array where spikes from all periods are collapsed into
    onsetTime = (periodIndex*stimPeriod) + Dt;  %% a single stimulus period while keeping their positions relative to the start of their respective periods
    for i = 1:spikesInStim,
        if (timeOccurence(i) >= onsetTime) & (timeOccurence(i) < onsetTime+stimPeriod)
            timeOccurenceC(periodIndex+1,i) = timeOccurence(i) - onsetTime;
        else
            timeOccurenceC(periodIndex+1,i) = NaN;
        end
    end
end

[r,c] = size(timeOccurenceC);
timeOccurenceC = reshape(timeOccurenceC,r*c,1);             % Reshape into a vector for histogram plotting
timeOccurenceC = timeOccurenceC(finite(timeOccurenceC));    % Reduce size by removing NaNs
bar(bins,histc(timeOccurenceC,bins),'histc')                % Plot Histogram
axis([0 stimPeriod 0 10])
axis 'auto y'
title('Period Histogram');
xlabel('Time (s)');
ylabel(['Event Count Per  ' num2str(binWidth) 's']);

% Vector Strength is a measure of the degree of phase-locking or
% synchronization. (Computed over entire stimulus interval, including rise
% and fall time, and not accounting for latency. This should be changed
% later)
VS = (sqrt((sum(sin(2*pi*stimFreq*timeOccurenceC)))^2 + (sum(cos(2*pi*stimFreq*timeOccurenceC)))^2))/spikesInStim;

Z = spikesInStim*(VS^2);                                     % Rayleigh Statistic
    
text(max(xlim)/2, -0.09*max(ylim), ['File Name = ' dataFile  ',  Vector Strength = ' num2str(VS)  ',  Rayleigh Statistic = ' num2str(Z)  ',  Period = ' num2str(stimPeriod) ' s'],'HorizontalAlignment','center')   % Allows user to place annotation on figure       

set(gcf,'position',[4 34 1150 760]);        % Size and position of figure. These specifiers are screen-size dependent.

fname = strrep(dataFile,'.csv','');         % Intermediate file name, Remove .csv name extension
%saveas(gcf,strcat('MSPIKEoutputs/',strrep(fname,'spike','period')),'bmp')    % Save figure as image file, specify output directory, and modify name.     
