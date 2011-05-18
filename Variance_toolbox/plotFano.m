
%
% Plots the Fano factor as a function of time
% Also plots the mean rate
% Will add a trace for the 'raw' Fano factor (no mean-matching selection of datapoints) if asked.
%
% usage: outParams = plotFano(Result,params)
% 
% 'Result' is the output of 'VarVsMean' and contains the Fano 
% 'params' is an optional structure with one or more of the following fields
%       sep             size of white space between mean and fano plots
%       relGain         relative amounts of space taken by fano plot, relative to mean plot
%       plotRawF        set to 1 to plot the raw (all data, non-mean-matched) fano factor
%       FFcolor         color of fano factor trace
%       FFallColor      color of 'raw' fano factor that uses all the data
%       MNcolor         color of the mean firing rate trace (after mean-matching)
%       MNallColor      color of the mean trace (all data)
%       FFscale         the following, if not empty, will override the automatic scalings and offsets
%       MNscale
%       FFoffset
%       MNoffset
%       leftEdgeOfTimeCal   in ms, location of left edge of horizontal (time) calibration. (zero is default)
%       lengthOfTimeCal     in ms, length of calibration
%       spanOfTime          in ms, the total span of the horizontal axis (default is the range of times in Result)
%       FFcal           can override the start/finish values of the calibration (e.g. set to [0 1])
%       MNcal           same for mean
%       useSEs          substitutes flanking SE's for flanking 95 CIs (default = 0)
% 
% Note that you can specify all, some, or none of these, in any order
%
% 'outParams' returns the parameters used (possibly a mix of supplied and default).
% This is convenient if you don't like what you see and wish to know what a good
% rough starting value is for a given field.


function outParams = plotFano(Result,varargin)

sep = 0.15;
relGain = 2;
plotRawF = 0;
FFcolor = [0 0 0];
FFallColor = 0.7*[1 1 1];
MNcolor = [0 0 0];
MNallColor = 0.7*[1 1 1];
FFscale = []; % if left empty, these are set automatically based on the data
MNscale = [];
FFoffset = [];
MNoffset = [];
leftEdgeOfTimeCal = 0;
lengthOfTimeCal = 200;
spanOfTime = 0;
FFcal = [];
MNcal = [];
useSEs = 0;

Pfields = {'sep', 'relGain', 'plotRawF', 'FFcolor', 'FFallColor', 'MNcolor', 'MNallColor', 'FFscale', 'MNscale', ...
    'FFoffset', 'MNoffset', 'lengthOfTimeCal', 'spanOfTime', 'FFcal', 'MNcal', 'useSEs'};
for i = 1:length(Pfields) % if a params structure was provided as an input, change the requested fields  
    if ~isempty(varargin)&&isfield(varargin{1}, Pfields{i}), eval(sprintf('%s = varargin{1}.(Pfields{%d});', Pfields{i}, i)); end
end
if ~isempty(varargin)  % if there is a params input
    fnames = fieldnames(varargin{1}); % cycle through field names and make sure all are recognized
    for i = 1:length(fnames)
        recognized = max(strcmp(fnames{i},Pfields));
        if recognized == 0, fprintf('fieldname %s not recognized\n',fnames{i}); end
    end
end

if ~isfield(Result, 'FanoFactor')  % possible that there is no mean matched FF (e.g. if matchReps was 0)
    disp('Result contains no mean matched FF');
    disp('Plotting the raw FF instead');
    Result.FanoFactor = Result.FanoFactorAll;
    Result.Fano_95CIs = Result.FanoAll_95CIs;
    Result.meanRateSelect = Result.meanRateAll;
    plotRawF = 0;  % no need, as Result.FanoFactor now IS the raw FF
end
    
sideMargin = 0.05 * range(Result.times);
bottomMargin = 0.15;
topMargin = 0.1;
if spanOfTime <= range(Result.times)
    leftTime = Result.times(1);
    rightTime = Result.times(end);
else
    extraTime = spanOfTime - range(Result.times);
    leftTime = Result.times(1) - extraTime/2;
    rightTime = Result.times(end) + extraTime/2;
end
    
    
% horizontal span determined by 'times'
% vertical span always 0 to 1 (data then scale appropriately)
blankFigure([leftTime-sideMargin rightTime+sideMargin 0-bottomMargin 1+topMargin]);

% FIGURE OUT SCALINGS
% figure out max and in values for fano part of plot
pad = 0.025; % will pad max and min a bit to hand the case where they are very similar
maxFF = max(Result.Fano_95CIs(:,2));
if plotRawF, maxFF = max([maxFF, max(Result.FanoAll_95CIs(:,2))]); end
maxFF = maxFF + pad;
minFF = min(Result.Fano_95CIs(:,1));
if plotRawF, minFF = min([minFF, min(Result.FanoAll_95CIs(:,1))]); end
minFF = minFF - pad;
% figure out max and in values for mean rate part of plot
maxMN = max( [max(Result.meanRateAll), max(Result.meanRateSelect)] );
minMN = min( [min(Result.meanRateAll), min(Result.meanRateSelect)] );

if useSEs  % we will replace the 95% CIs with SEs
    Result.Fano_95CIs = repmat(Result.FanoFactor,1,2) + 1/1.96*( Result.Fano_95CIs - repmat(Result.FanoFactor,1,2) );
    Result.FanoAll_95CIs = repmat(Result.FanoFactorAll,1,2) + 1/1.96*( Result.FanoAll_95CIs - repmat(Result.FanoFactorAll,1,2) );
end
    

% space to be occupied
topFFportion = (1 - sep)*(relGain/(1+relGain)); % top of the FF portion of the fig
bottomMNportion = topFFportion + sep;           % bottom of the MN portion of the fig

% scalings
if isempty(FFscale) % FF scaleing
    rngFF = max( [0.3, (maxFF - minFF) ]); % scale can only get so small, even if FF changes little
    FFscale = topFFportion / rngFF; %scale to fill available space
end
if isempty(MNscale) % now same for mean
    rngMN = max( [5, (maxMN - minMN) ]); % scale can only get so small, even if MN changes little
    MNscale = (1 - bottomMNportion) / rngMN; %scale to fill available space
end
% offsets
if isempty(FFoffset), FFoffset = topFFportion/2 - FFscale*(minFF+maxFF)/2; end
if isempty(MNoffset), MNoffset = bottomMNportion - MNscale*minMN; end
% DONE FIGURING OUT SCALINGS


% PLOT TRACES
if plotRawF % plot raw Fano Factor if asked
    plot(Result.times,FFoffset + FFscale*Result.FanoFactorAll,'color', FFallColor, 'linewidth', 2);
    plot(Result.times,FFoffset + FFscale*Result.FanoAll_95CIs,'color', FFallColor, 'linewidth', 1); 
end
% plot Fano Factor (the mean-matched version)
plot(Result.times,FFoffset + FFscale*Result.FanoFactor,'color', FFcolor, 'linewidth', 2);
plot(Result.times,FFoffset + FFscale*Result.Fano_95CIs,'color', FFcolor, 'linewidth', 1); 
% plot the mean rate
plot(Result.times,MNoffset + MNscale*Result.meanRateAll,'color', MNallColor, 'linewidth', 2);
plot(Result.times,MNoffset + MNscale*Result.meanRateSelect,'color', MNcolor, 'linewidth', 2); 
% DONE PLOTTING TRACES   


% CALIBRATIONS

% horizontal bar
coff = -0.5 * bottomMargin;
if leftEdgeOfTimeCal > max(Result.times) || leftEdgeOfTimeCal < min(Result.times), disp('time calibration out of range'); end
h = plot( leftEdgeOfTimeCal+[0 lengthOfTimeCal], coff+[0 0], 'k' );
set(h,'linewidth',4);  
label = sprintf('%d ms',lengthOfTimeCal);
h = text(leftEdgeOfTimeCal+lengthOfTimeCal/2, 1.2*coff, label); set(h,'verticala','top','horizontala', 'center');   

% vertical calibration for FF
% figure out where cal should start and finish
if isempty(FFcal)
    start = round(10*minFF)/10;
    fin = round(10*maxFF)/10;
    if fin-start < 0.1, start = floor(10*minFF)/10; fin = ceil(10*maxFF)/10; end  % make sure it has some length
    if fin-start < 0.1, start = start-0.1; fin = fin + 0.1; end  % same
        
    startScaled = FFoffset + FFscale*start; %scale here to check if it starts too low
    if startScaled < -bottomMargin
        start = ceil(10*minFF)/10;
    end

    finScaled = FFoffset + FFscale*fin; %scale here to check if it goes too high
    if finScaled > bottomMNportion - 3*sep/4  % can intrude no more than 1/4 of the way into the separation
        fin = floor(10*maxFF)/10;
    end 
    FFcal = [start, fin];
else 
    start = FFcal(1);
    fin = FFcal(2);
end
startScaled = FFoffset + FFscale*start; % may not have been done, or may need to be overridden
finScaled = FFoffset + FFscale*fin;    

axP.tickLocations = FFoffset + FFscale*(start:0.1:fin);
axP.tickLabels = {num2str(start), num2str(fin)};
axP.tickLabelLocations = [startScaled, finScaled];
axP.axisLabel = 'Fano factor';
axP.axisOrientation = 'v';
axP.axisOffset = Result.times(1)-range(Result.times) / 30;
AxisMMC(startScaled, finScaled, axP);

% vertical calibration for mean
% figure out where cal should start and finish
if isempty(MNcal)
    start = round(minMN);
    fin = round(maxMN);
    if fin-start < 1, start = floor(minMN); fin = ceil(maxMN); end  % make sure it has some length
    if fin-start < 1, start = start-1; fin = fin + 1; end  % same
        
    startScaled = MNoffset + MNscale*start; %scale here to check if it starts too low
    if startScaled < bottomMNportion -sep/4  % can intrude no more than 1/4 into the separation
        start = start+1;
    end

    finScaled = MNoffset + MNscale*fin; %scale here to check if it goes too high
    if finScaled > 1
        fin = fin-1;
        start = start-1;
    end   
    MNcal = [start, fin];
else 
    start = MNcal(1);
    fin = MNcal(2);
end

startScaled = MNoffset + MNscale*start;  % may not have been done, or may need to be overridden
finScaled = MNoffset + MNscale*fin;

axP.tickLocations = [startScaled, finScaled];
axP.tickLabels = {num2str(start), num2str(fin)};
axP.tickLabelLocations = [startScaled, finScaled];
axP.axisLabel = 'rate (sp/s)';
axP.axisOrientation = 'v';
axP.axisOffset = Result.times(1)-range(Result.times) / 30;
AxisMMC(startScaled, finScaled, axP);

% DONE WITH CALIBRATIONS

% MAKE outParams STRUCTURE (tells user what default choices were made)
for i = 1:length(Pfields)
    outParams.(Pfields{i}) = eval(Pfields{i});
end
    
    
    
    