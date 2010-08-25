%make sure we start in a clean environment, not essential
Screen('CloseAll')
clear all

%These set up the stimuli, values in degrees
gs(1)=gratingStimulus(struct('sf',1,'contrast',0.75,'size',1,'tf',0,'gabor',0,...
	'mask',1,'verbose',0));

gs(2)=gratingStimulus(struct('sf',1,'contrast',0.5,'size',3,'angle',45,'xPosition',5,...
	'yPosition',5,'gabor',0,'mask',1));

gs(3)=gratingStimulus(struct('sf',3,'contrast',0.75,'size',3,'xPosition',-2,...
	'yPosition',-4,'gabor',0,'mask',1));

gs(4)=gratingStimulus(struct('sf',1,'contrast',0.75,'tf',0,'size',1,'xPosition',-5,...
	'yPosition',7,'gabor',0,'mask',0));

gs(5)=gratingStimulus(struct('sf',1,'contrast',1,'color',[0.6 0.2 0.2 1],'tf',0.1,...
	'size',2,'xPosition',-2,'yPosition',7,'gabor',0,'mask',0));

gs(6)=gratingStimulus(struct('sf',1,'contrast',0.5,'color',[0.7 0.4 0.4 0],'tf',1,...
	'driftDirection',-1,'size',2,'xPosition',5,'yPosition',5,'gabor',0,'mask',1));

%stimulus sequence allows us to vary parameters and run blocks of trials
s = stimulusSequence;
s.nTrials = 5;
s.nSegments = 1;
s.isTime = 0.5;
s.nVar(1).name = 'contrast';
s.nVar(1).stimulus = 2;
s.nVar(1).values = [0 0.3 0.6];
s.nVar(2).name = 'angle';
s.nVar(2).stimulus = 5;
s.nVar(2).values = [0 45 90];

%we call the routing to randomise trial in a block structure
s.randomiseStimuli;

%% ss is the object which interfaces with the screen and runs our
%% experiment
ss=runExperiment(struct('distance',57.3,'pixelsPerCm',44,...
	'stimulus',gs,'task',s,'windowed',1,'debug',1,'hideFlash',0,'verbose',0));
ss.run