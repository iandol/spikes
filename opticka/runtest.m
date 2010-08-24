%make sure we start in a clean environment, not essential
Screen('CloseAll')
clear all

%These set up the stimuli, values in degrees
gs(1)=gratingStimulus(struct('sf',1,'contrast',0.75,'size',1,'tf',0,'gabor',0,'mask',1,'verbose',0));
gs(2)=gratingStimulus(struct('sf',1,'contrast',0.5,'size',4,'xPosition',5,'yPosition',2,'gabor',0,'mask',1));
gs(3)=gratingStimulus(struct('sf',3,'contrast',0.75,'size',3,'xPosition',-2,'yPosition',-4,'gabor',0,'mask',1));
gs(4)=gratingStimulus(struct('sf',1,'contrast',0.75,'tf',0,'size',1,'xPosition',-5,'yPosition',7,'gabor',0,'mask',0));
gs(5)=gratingStimulus(struct('sf',2,'contrast',0.5,'color',[0.75 0.2 0.2 0],'tf',0.1,'size',2,'xPosition',-4,'yPosition',1,'gabor',0,'mask',0));
gs(6)=gratingStimulus(struct('sf',2,'contrast',0.75,'color',[0.5 0.1 0.1 0],'tf',0.1,'size',3,'xPosition',5,'yPosition',4,'gabor',0,'mask',0));

%stimulus sequence allows us to vary parameters and run blocks of trials
s=stimulusSequence;
s.inVars(1).name='contrast';
s.inVars(1).stimulus=2;
s.inVars(1).values=[0 0.3 0.6];
s.inVars(2).name='angle';
s.inVars(2).stimulus=3;
s.inVars(2).values=[0 45 90];

%we call the routing to randomise trial in a block structure
s.randomiseStimuli;

%% ss is the object which interfaces with the screen and runs our
%% experiment
ss=runExperiment(struct('distance',53.7,'pixelsPerCm',44,...
	'stimulus',gs,'task',s,'windowed',0,'debug',1,'hideFlash',0,'showLog',0));
ss.run