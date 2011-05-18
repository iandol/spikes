%
% Produces a scatterplot of the variance versus the mean
% One point per neuron/condition
% Slopes (Fano Factors) are plotted on top of the scattterplot.
% Distributions of mean counts are also plotted.
% By default, done for both the complete and restricted distributions.
%
% usage: outParams = plotScatter(Result, t, params)
%   
% 'Result' is the output of 'VarVsMean'.
%
% 't' is the time for which data should be plotted (based on 'Result.times'
%
% 'params' is an optional argument. If used, it is a structure with one or
%  more of the following fields:
%       'showSelect' 1 = show downselected dist/points/line in black. Default = 1
%       'showFanoAll' 1 = show slope for fano computed from all data (in grey). Default = 1
%       'axLim'     Axis limits for whole matlab fig. If set to 'auto', varies w/ axLen. Can also be a vector
%                   of axis limits, e.g. [-10 25 -10 25]. 
%       'mSize'     size of the marker points. Default = 2.5 
%       'propData'  proportion of datapoints to be plotted. Default = 1
%       'initRand'  this matters only if propData < 1.
%       'axLen'     length of the axes. Default = 10
%       'greyShade' shade of grey used for complete (non down-selected) data. Default = 0.7
%       'clockOn'   if == 1, clock shown at top indicates time relative to zero. Default = 0.
%       'plotInExistingFig'  if == 1, plot is produced in the current figure (rather than creating a new one).
%
% There are also two more optonal fields ('VaxisP' & 'HaxisP') that are themselves parameter
% structures, and are passed to 'AxisMMC', to allow the user to control how the axes
% look. Usually it is best to leave these blank, or to just set the 'tickLocations' field
% As an example, if 'axLen' = 15, you might set 'VaxisP.tickLocations' and 'HaxisP.tickLocations'
% to be [0 5 10 15].
%
% 'outParams' just returns the parameters that were used (usually some mix of
% default and supplied).
% 
function outParams = plotScatter(Result, t, varargin)


% PARSE INPUTS AND SET DEFAULTS ETC

% find the index for the asked-for time.
time = find(Result.times==t);  
if isempty(time)
    fprintf('ERROR: the requested time, %d, does not exist\n', t); % warn if it doesnt exist
    [foo, tmp] = min(abs(Result.times - t));  fprintf('The nearest time is %d\n', Result.times( tmp ));
    return;
end

% default values (these can be overridden by the user if they pass a parameters structure as the last input
showSelect = 1; showFanoAll = 1; axLim = 'auto';  mSize = 2.5;  propData = 1; initRand = 1;
axLen = 10; greyShade = 0.7; clockOn = 0; plotInExistingFig = 0; VaxisP = []; HaxisP = [];
Pfields = {'showSelect', 'showFanoAll', 'axLim', 'mSize', 'initRand', 'propData', 'axLen', 'greyShade', 'clockOn', 'plotInExistingFig', 'VaxisP', 'HaxisP'};
for i = 1:length(Pfields) % if a params structure was provided as an input, change the requested fields
    if ~isempty(varargin) && ~isempty(varargin{1}) && isfield(varargin{1}, Pfields{i})
        eval(sprintf('%s = varargin{1}.(Pfields{%d});', Pfields{i}, i)); 
    end
end;
% warn if there is an unrecognized field in the input parameter structure
if ~isempty(varargin) && ~isempty(varargin{1})  
    fnames = fieldnames(varargin{1});
    for i = 1:length(fnames)
        recognized = max(strcmp(fnames{i},Pfields));
        if recognized == 0, fprintf('fieldname %s not recognized\n',fnames{i}); end
    end
end
if initRand, rand('state',0); end  % initialize random number generator (done by default, can be overridden)
                                    % may matter if user chooses to shown only a proportion of the datapoints 
 
% if asked to autoscale matlab figure axes based on our axis length                                    
if strcmp(axLim, 'auto'), axLim = axLen * [-1 2 -0.7 2.3]; end                                 

% get Data for the right time
scatterSelect = Result.scatterData(time); % data points that survived the distribution matching
scatterAll = Result.scatterDataAll(time); % all data points
slope = Result.FanoFactor(time);
slopeCI = Result.Fano_95CIs(time,:);
slopeAll = Result.FanoFactorAll(time);
slopeCIAll = Result.FanoAll_95CIs(time,:);
distData = Result.distData(time);

lineLen = 0.8*axLen;
% DONE PARSING INPUTS

% make blank, white figure (or plot in existing figure if asked)
if plotInExistingFig==0
    blankFigure(axLim); 
else
    clf; hold on; 
    set(gca,'visible', 'off');
    %set(hf, 'color', [1 1 1]);
    axis(axLim); axis square;
end

% unity line
plot([0 axLen], [0 axLen], 'k', 'linewidth', 0.5);

% PLOT POINTS (user may choose to plot just some proportion, in the interests of visual clarity, esp useful for movies)
whichPoints = randperm(length(scatterAll.mn)); % first for whole distribution
whichPoints = whichPoints(1:round(propData*length(scatterAll.mn)));
plot( scatterAll.mn(whichPoints), scatterAll.var(whichPoints), 'k.', 'markersize', mSize, 'color', greyShade*[1 1 1] );
if showSelect % now for select distribution
    whichPoints = randperm(length(scatterSelect.mn)); % now for dowselected (mean-matched) distribution
    whichPoints = whichPoints(1:round(propData*length(scatterSelect.mn)));
    plot( scatterSelect.mn(whichPoints), scatterSelect.var(whichPoints), 'k.', 'markersize', mSize );
end

% PLOT SLOPES
if showFanoAll  % slope when using all data
    h1 = plot( [0 lineLen], [0 lineLen*slopeAll], 'k', 'linewidth', 1.5);
    h2 = plot( [0 lineLen-sqrt(2)/2*(slopeAll - slopeCIAll(1))], [0 lineLen*slopeCIAll(1)], 'k', 'linewidth', 0.5);
    h3 = plot( [0 lineLen-sqrt(2)/2*(slopeAll - slopeCIAll(2))], [0 lineLen*slopeCIAll(2)], 'k', 'linewidth', 0.5);
    set([h1 h2 h3], 'color', greyShade*[1 1 1]);
end
if showSelect % now for select distribution
    lineLen = 1.1*max(Result.scatterData(1).mn);
    plot( [0 lineLen], [0 lineLen*slope], 'k', 'linewidth', 1.7);
    plot( [0 lineLen-sqrt(2)/2*(slope - slopeCI(1))], [0 lineLen*slopeCI(1)], 'k', 'linewidth', 0.75);
    plot( [0 lineLen-sqrt(2)/2*(slope - slopeCI(2))], [0 lineLen*slopeCI(2)], 'k', 'linewidth', 0.75);
end

% general axis parameters
start = 0;
fin = round(axLen);
axP.tickLocations = 0:axLen;
axP.tickLength = (axLim(4)-axLim(3))/90;
axP.axisLabelOffset = axP.tickLength * 1.5;
axP.tickLabels = {'0',num2str(fin)};

% vertical axis
Vax = axP;
Vax.axisOrientation = 'v';
Vax.axisLabel = 'variance';
Vax.axisOffset = -0.4;
if isstruct(VaxisP)  % override in the user provided a params structure
    FN = fieldnames(VaxisP);
    for i = 1:length(FN), Vax.(FN{i}) = VaxisP.(FN{i}); end
end
VaxisP = AxisMMC(start, fin, Vax);

% horizontal axis
Hax = axP;
Hax.axisOrientation = 'h';
Hax.axisLabel = 'mean';
Hax.axisOffset = -axLen/3;
if isstruct(HaxisP)  % override in the user provided a params structure
    FN = fieldnames(HaxisP);
    for i = 1:length(FN), Hax.(FN{i}) = HaxisP.(FN{i}); end
end
HaxisP = AxisMMC(start, fin, Hax);


% distribution for all in grey
counts = distData.counts;
lastBin = find(counts>0, 1, 'last')+1;
if lastBin == length(counts), lastBin = length(counts)-1; end
counts = counts(1:lastBin);
counts = log(counts+1);
bins = (distData.binEdges(1:lastBin) + distData.binEdges(2:lastBin+1)) / 2;
offset = 0.9*Hax.axisOffset;
scale = -0.7*Hax.axisOffset / max(counts);
% now plot
bins = [bins(1) bins' bins(end) bins(1)];
counts = [0 counts' 0 0];
h = fill(bins, offset + scale*counts, greyShade*[1 1 1]);  %grey
set(h, 'edgeColor', greyShade*[1 1 1]);

% downselected distribution in black
if showSelect
    counts = distData.countsSelect;
    lastBin = find(counts>0, 1, 'last')+1;
    counts = counts(1:lastBin);
    counts = log(counts+1);
    bins = (distData.binEdges(1:lastBin) + distData.binEdges(2:lastBin+1)) / 2;
    % now plot
    bins = [bins(1) bins' bins(end) bins(1)];
    counts = [0 counts' 0 0];
    fill(bins, offset + scale*counts, 0*[1 1 1])  % black
end

% Plot the clock
if clockOn == 1
    clockLoc = [0.5 1.4]*axLen;
    radius = 0.2*axLen;
    clockShade = 0.7;
    faceColor = clockShade*[1 1 1];
    edgeColor = clockShade*[1 1 1];
    if t>=0, handColor = [1 0 0]; else handColor = [0 0 0]; end
    timeRange = 1.2*range(Result.times);
    clockThingy(clockLoc, radius, faceColor, edgeColor, handColor, timeRange, t);
end

% create output:
for i = 1:length(Pfields) % if a params structure was provided as an input, change the requested fields
    outParams.(Pfields{i}) = eval(Pfields{i});
end;
