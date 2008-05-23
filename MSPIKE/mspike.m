
% MSPIKE - MALTAB Neuronal Spike Pattern Analysis
% By Hazem Saliba Baqaen (Hazem@brown.edu). Designed on MATLAB 6.5.
% Brown University Departments of Psychology and Neuroscience, September 2004. 
% Supervisors: Professors Andrea and James Simmons. 
% (Credit due to Nicola Neretti for important suggestions)
%
% Inputs: One or more .csv data files exported by TDT's System3
% OpenEx, with ' Tref ' selected. See start data row and column specifier block
% below, or sample .csv file, for proper formatting. Also, see the code block
% below with the header " Other needed parameters..." for more inputs and
% defaults. The user must enter a list of the input files into
% InputFileList.txt and save it, and a list of the corresponding stimulus
% frequencies entered into FrequencyList.txt and save it if s/he wishes any
% periodicity analysis done (by setting period_select = 1). 
%
% Outputs: Image files (see Program functionality selector code block
% below)
%
% To change the way the output file names are adapted from the input file
% names, and the output path, you must edit the ' saveas ' statement in each of
% the corresponding functions. 
% This program is easily extensible with minor modification. See the
% comments for more details.
%
% Warning: Keep MATLAB in the foreground while running mspike and do not
% use the computer until mspike is done. Any open windows will be captured
% in the image files.

clear all;                                          

% Program functionality selector (1 = yes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rpsth_select = 1;                                   % Raster Plot, Peri-Stimulus-Time Histogram, Average Onset Latency, Spike Counts
period_select = 1;                                  % Period Histogram, Synchronicity or 'Vector Strength', Rayleigh Statistic
one_ISI_select = 1;                                 % First-Order Inter-Spike Interval Histogram
all_ISI_select = 1;                                 % All-Order Inter-Spike Interval Histograms (Auto Correlation Function)
any_ISI_select = 0;                                 % Any Combination of Orders Inter-Spike Interval Histograms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Start data read row and column specifier (see sample exported .csv file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spikeDataStartRow = 1;                              % Zero-based indexing of data in .csv file
spikeDataStartColumn = 8;
TimeDataStartRow = 1;
TimeDataStartColumn = 3;
SweepDataStartRow = 1;
SweepDataStartColumn = 6;
fsDataStartRow = 1;
fsDataStartColumn = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



InputFileList = textread('InputFileList.txt','%q'); % Read InputFileList.txt
FrequencyList = textread('FrequencyList.txt','%f'); % Read FrequencyList.txt

if (length(InputFileList) ~= length(FrequencyList)) & (period_select == 1)       % Error checking 
    disp(' ERROR READING TEXT FILES: The length of the data-file list and the frequencies list do not match.')
    return
end

for k = 1:length(InputFileList),                    % Data file batch processing
    close all hidden;
    inputfilename = char(cell2mat(InputFileList(k)));  % Convert filename back to character array (string)
	  
	% Other needed parameters (read and/or calculated)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	sweepPeriod = 8;
	stimOn = 4;
	StimDelay = 0.005;                              % Delay of stimulus onset relative to start of sweep
	
	stimFreq = FrequencyList(k);
	stimPeriod = 1/stimFreq;
	
	binWidth = 0.005;
	bins = 0:binWidth:sweepPeriod+binWidth;
	
	Tc = 20;                                        % Air temperature (Centigrade)
	c = 331.5 + 0.6*Tc;                             % Speed of sound in air at temperature Tc
	d = 0.35;                                       % Distance the sound travels in air (m)
	%Dt = d/c;                                       % Sound propagation delay in air (s)
	%Dt = 0.089/1482;                                % Sound propagation delay in the water dish at 20 degrees Centigrade. (s) 
	Dt = 0;                                         % Signal propagation time in the near field in water is negligible. [Shaker experiment]
    
	range = [1:3 5];                                % Range of orders to plot ISI histograms. Use this format: <order_n1>:<order_n2> or 
                                                    %% use [<order_n1> <order_n2> ...] for any combination of orders and/or ranges (AVOID OVERLAP!)     
                                                    
    StartTime1 = 0;                                 % These parameters define two spike counting intervals. The defaults are 0->stimOn, and stimOn->sweepPeriod 
    EndTime1 = stimOn;                              % If you change these, be sure to change the text of the annotation on the graph to reflect this.
    StartTime2 = stimOn;                            % Zero-time here means start of stimulus
    EndTime2 = sweepPeriod;                                             
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	
	% Data read and preprocessing
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%[dataFile,PathName] = uigetfile('*.csv');        % Display user dialogue box to retrieve data file
	dataFile = inputfilename; PathName = pwd;        % Input file and path name (current directory)
	
	DataArray = csvread(dataFile,spikeDataStartRow,spikeDataStartColumn);       % Read spike data
	[Data_Rows,Data_Columns] = size(DataArray);     % Dimensions of spike data array
	Data_Columns = Data_Columns-1;
	DataArray = DataArray(:,[1:Data_Columns]);      % Discard last column of zeros (resultant of exporting an extra comma separator)
	
	Time = csvread(dataFile,TimeDataStartRow,TimeDataStartColumn,[TimeDataStartRow TimeDataStartColumn Data_Rows TimeDataStartColumn]); % Read time data
	Time = Time - StimDelay;
	
	currentSweep = csvread(dataFile,SweepDataStartRow,SweepDataStartColumn,[SweepDataStartRow SweepDataStartColumn Data_Rows SweepDataStartColumn]);   % Read sweep number
	currentSweep = currentSweep - currentSweep(1,1); % Reset to start sweep number from zero if it starts from elsewhere
    
    fs = csvread(dataFile,fsDataStartRow,fsDataStartColumn,[fsDataStartRow fsDataStartColumn Data_Rows fsDataStartColumn]);  % Read sampling rate
    
    % Discard last sweep, and all snippets and data belonging to it, because
    % the last sweep is usually incomplete and therefore unsuitable for
    % inclusion in the analysis. 
    nrSpikesInLastSweep = length(nonzeros(currentSweep == currentSweep(end)));
    DataArray = DataArray(1:end-nrSpikesInLastSweep,:);
    clear DataArray;                                % Clear DataArray to save memory since it is unused beyond this point
    currentSweep = currentSweep(1:end-nrSpikesInLastSweep);
    Time = Time(1:end-nrSpikesInLastSweep);
    fs = fs(1:end-nrSpikesInLastSweep);
    Data_Rows = Data_Rows - nrSpikesInLastSweep;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    
	% Error-checking loops
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(mod(currentSweep,1))                      % Check that all Sweep numbers are integers                   
        disp(' ERROR: Sweep numbers are not integers. Please check the data file.')
        disp(inputfilename)
        return
	end
	
	for snippet = 2:Data_Rows,                       
        if fs(1) ~= fs(snippet)                      % Loop to check sampling rate values taken from data file
            disp(' ERROR: The sampling rate is not constant. Please check the data file.')
            disp(inputfilename)
            return                                   % Terminate program and display error message if fs is not constant
        end
        
        if currentSweep(snippet) - currentSweep(snippet-1) < 0
            disp(' ERROR: Sweep numbers are negative or decreasing. Please check the data file.')
            disp(inputfilename)
            return
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        
	samplingPeriod = 1/fs(1);
	clear fs;                                        % Clear fs to save memory
    

	% Function calls
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if rpsth_select == 1
		func_rpsth(dataFile, PathName, sweepPeriod, stimOn, stimFreq, stimPeriod, bins, binWidth, Dt, Data_Rows, Data_Columns, Time, currentSweep, samplingPeriod, StartTime1, EndTime1, StartTime2, EndTime2);
	end
	
	if period_select == 1	
		figure
		func_period(dataFile, PathName, sweepPeriod, stimOn, stimFreq, stimPeriod, bins, binWidth, Dt, Data_Rows, Data_Columns, Time, currentSweep, samplingPeriod);
	end
	
	if one_ISI_select == 1
		func_one_ISI(dataFile, PathName, sweepPeriod, stimOn, stimFreq, stimPeriod, bins, binWidth, Dt, Data_Rows, Data_Columns, Time, currentSweep, samplingPeriod);
	end
	
	if all_ISI_select == 1
		func_all_ISI(dataFile, PathName, sweepPeriod, stimOn, stimFreq, stimPeriod, bins, binWidth, Dt, Data_Rows, Data_Columns, Time, currentSweep, samplingPeriod);
	end
	
	if any_ISI_select == 1
		func_any_ISI(dataFile, PathName, sweepPeriod, stimOn, stimFreq, stimPeriod, bins, binWidth, Dt, Data_Rows, Data_Columns, Time, currentSweep, samplingPeriod, range);
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end                                                    % End data file batch processing loop


