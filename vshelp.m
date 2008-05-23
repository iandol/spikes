function vshelp(action)

% Provides a help window for various VS modules

switch action
   
case 'SpikeLoad'
   x={'There are several Options Available:';'';'Binwidth can be selected in values of 0.1ms up to Max Time.';'Reload allows you to change parameters and recalculate the same data.';'Spawn Copies the Current figure to a new window for Output to an external program.';'Load and Save MAT allows one to save the Spike data in Matlab format'};
   helpdlg(x,'Spike Loading Parameters:');

case 'SpikeMeasure'
   x={'This menu allows you to select a variable or variables from which you can visualise the PSTH of to Cursor for measurement. You can use a variety of spike counts, such as mean, peak etc. Time Values can also be entered into the edit boxes manually...'};  
   helpdlg(x,'Spike Measuring Parameters:');
   
case 'SpikePlot'
   x={'This allows you to have extensive control of the way the data is visualised, largely for 2-3 variable data.';'';'You can enter manual axis values, rotate the 3d plot, edit the colour map, and change the plot labels.';'Replot simply updates the figure if you change the options.';'';'You can also smooth the data using a variety of methods and resolutions.'};
   helpdlg(x,'Spike Loading Parameters:');
   
case 'SpikeAnalysis'
   x={'There are a range of Specialised Analyses here. If you use a different analysis, and then want to see the raw data again, please make sure you select "No Analysis" or you may not be plotting the raw data but e.g. just the bursts.';'';'Significance allows you to change errorbars and the level above which significant responses are measured inthe area analysis.';'';'You can also set the axis for the PSTH plot, when set to 0 you can see what the maximum is for all the variables.'};
   helpdlg(x,'Spike Loading Parameters:');
   
case 'SpikeBurst'
   x={'The burst routine requires 4 parameters:';' 1=Silence before burst (ms)';' 2=First ISI for burst (ms)';' 3=Subsequent ISI to stay in burst (ms)';' 4=Minimum Number of spikes in burst';'';'Spikes contained in Bursts are plotted along with PSTH plot in red';'You can also do surface plots constructed from the bursts,';'Select "Plot Burst" in the further analysis menu.';'You can use either the peak or count for bursts.'};
   helpdlg(x,'Burst Parameters:');
   
case 'SPlot'
   x={'This module runs from Spikes, and allows you to see individual PSTH plots choosing the time base, to Spawn as a figure or to do further analysis on.';'Just Select the Variables of Interest and click Plot!';'You can smooth the plots by using either a standard smoothing function or a more computationally intensive Loess function. For the Loess function, vary the number until the desired amount of smoothing is achieved. When this number is too small, there will be an error and you will need to increase this number.';' Select Reload to reload data from Spikes';' Further Analysis will allow you to measure spike statistics and perform various analasyse'};
   helpdlg(x,'Single PSTH Plot:');
   
case 'OPro'
   x={'Opro is capable of performing many different statistical analyses between two receptive fields. You first need to have two .mat files for each cell saved after loading each into ''Spikes'', measuring them and then selecting save.';'These .mat files contain the measured matrix (so you can do a straight Pearson/Spearman/ANOVA on the matrix measured in ''Spikes''), but if you want to do an analysis involving a more complex comparison, or just want to rebin the spikes, then you need to first measure the raw spike trains. You can select the binwidth by entering a binwidth, or if you put 0, it will leave just the raw spikes for statistical comparison. You can do this for all spikes, or just the burst spike train. You can also select either binned ISI or raw ISI rather than spike times themselves if you prefer. By selecting a cell and a variable position, you can choose which position to visualise when measuring the PSTH. Then choose any statistical test and ''OrbanizeIt!''';'';'Another option is to remove spontaneous, by selecting which position you want to measure and pressing "Find Spontaneous". It will find the mean firing +2SD and then remove positions that do not reach this criterion. Another way to check spontaneous is to be found in the stats test menu'};
   helpdlg(x,'OPRO Help:');
   
case 'SpikeSlice'
   x={'You can select subsets of variables with which to select your data (x and y variables supported). You can also save predefined ranges of variables using "Save"; these are then available when loading other data runs.'};
   helpdlg(x,'OPRO Help:');

   
end

   