
% produces a movie of the Fano-factor unfolding over time.
%
% usage (simplest case): MV = ScatterMovie(Result)
% usage (full featured): [MV, outParams] = ScatterMovie(Result, times, plotParams, propData, pixelsToGet, reps);
%
% INPUT:
%   'Result' is the output of VarVsMean
%
% OPTIONAL INPUTS (don't have to specify all, but must be in order):
%   'times' the times to plot (e.g. -100:25:100, presuming these match up with values in Result.times)
%           The default is just Result.times.
%           
%   'plotParams' is a structure of parameters to be passed to 'plotScatter'. Will override defaults.
%                Its format can be found by typing 'help plotScatter' or by looking at 'outParams'.
%
%   'propData' is the proportion of dots to be plotted per frame (0.5 by default).
%
%   'pixelsToGet' is the rectangle of pixels that are put into the output movie MV.
%                 Default is [50 -28 240 345]; [xstart, ystart, xwidth, ywidth]
% 
%   'reps' is the number of frame repitions for each time.  The default is 3, which slows the
%          movie down enough to be understandable.  The slopes are interpolated smoothly.  
%
% OUTPUTS:
%   'MV' is the movie. This can be used by 'movie2avi' or 'mpgwrite' (see below)
%   'outParams' reports the plotting params used, in case you wish to change any
%               This is the output of the last call to 'plotScatter'. See that function for advice.
%
% EXAMPLES:
%   MV = ScatterMovie(Result);  all times are used, scaling is done for you.
%
%   MV = ScatterMovie(Result, someTimes);  a subset of times are used.
%  
%   moveScatP.axLen = 4;  % length of the axis (in spikes/s)
%   moveScatP.axLim = [-4 8 -3 9];  %set boundaries of matlab-fig axis (in spikes/s) to scale figure
%   MV = ScatterMovie(Result, Result.times, moveScatP);  % all times, with asked for plotting parameters
%
%   Once you have produced 'MV', you can create a stand-alone movie using:
%   movie2avi(MV, yourName, 'FPS', 15, 'compression', 'none');
%
%   If you prefer a (much smaller but uglier) mpg:
%   path(path, 'blahblahblah\Variance_toolbox\mpgwrite')  % set path so it can find it
%   mpgwrite(DoubleFrames(MV), 'default', yourName)
%
%
function [MV, outParams] = ScatterMovie(Result, varargin)

% ********  PARSE INPUTS  *******

% OPTIONAL INPUT 1: times to plot
if ~isempty(varargin), timesToUse = varargin{1}; else timesToUse = Result.times; end
if timesToUse(end) == Result.times(end), timesToUse = timesToUse(1:end-1); end  % never go to very end


% OPTIONAL INPUT 2: parameters to be passed to 'plotScatter'
plotParams.initRand = 0;
plotParams.clockOn = 1;
% Figure out scalings etc.
mxFR = 0;
for actualTime = timesToUse'
    mxFR = max([mxFR, max(Result.scatterDataAll(Result.times == actualTime).mn)]);
end
plotParams.axLen = ceil(mxFR);
plotParams.axLim = plotParams.axLen * [-1 2 -0.7 2.3];
% Done with default computations.
% Add fields / Override fields if the user supplied parameters
if length(varargin) >= 2 
    inputParams = varargin{2};
    fnames = fieldnames(inputParams);
    for i = 1:length(fnames)
        plotParams.(fnames{i}) = inputParams.(fnames{i});
    end
end


% OPTIONAL INPUT 3: proportion of dots that are plotted on any given frame
if length(varargin) >= 3, propData = varargin{3}; else propData = 0.5; end


% OPTIONAL INPUT 4: chunk of pixels to be turned into the movie
if length(varargin) >= 4
    pixelsToGet = varargin{4};
else
    pixelsToGet = [50 -25 260 345]; % [xstart, ystart, xwidth, ywidth]
end


% OPTIONAL INPUT 5: number of reps to interpolate between times (will usually run too fast if set to 1)
if length(varargin) >= 5
    reps = varargin{5};
else
    reps = 3; % slows things down (will do 3 repititions of each frame)
end
% ******* DONE PARSING INPUTS **************
    


fr = 0;  % counts which frame of the movie we are on
tempResult = Result;  % we make some minor modifications to this before passing to 'plotScatter'
for actualTime = timesToUse'

    ti = find(Result.times == actualTime);
    
    for r = 1:reps
        fr = fr+1; %incement frame
        weight2 = (r-1)/reps;
        weight1 = 1-weight2;
        
        % the following is a bit of a hack to get the slope to change smoothly even when reps > 1
        % it just interpolates the values for the extra frames.
        tempResult.FanoFactor(ti) = weight1*Result.FanoFactor(ti) + weight2*Result.FanoFactor(ti+1);
        tempResult.Fano_95CIs(ti,1) = weight1*Result.Fano_95CIs(ti,1) + weight2*Result.Fano_95CIs(ti+1,1);
        tempResult.Fano_95CIs(ti,2) = weight1*Result.Fano_95CIs(ti,2) + weight2*Result.Fano_95CIs(ti+1,2);   
        
        tempResult.FanoFactorAll(ti) = weight1*Result.FanoFactorAll(ti) + weight2*Result.FanoFactorAll(ti+1);
        tempResult.FanoAll_95CIs(ti,1) = weight1*Result.FanoAll_95CIs(ti,1) + weight2*Result.FanoAll_95CIs(ti+1,1);
        tempResult.FanoAll_95CIs(ti,2) = weight1*Result.FanoAll_95CIs(ti,2) + weight2*Result.FanoAll_95CIs(ti+1,2); 

        if ( actualTime == timesToUse(1) && r == 1) || ( actualTime == timesToUse(end) && r == reps )
            plotParams.propData = 1;
        else
            plotParams.propData = propData;
        end

        % PLOT THE DATA
        outParams = plotScatter(tempResult, actualTime, plotParams);
        % GRAB THE FRAME
        MV(fr) = getframe(gca, pixelsToGet);
        
        plotParams.plotInExistingFig = 1; % set now, so first frame creates figure (0 is default).
    end
end

