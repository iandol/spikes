classdef runExperiment < dynamicprops
	%SHOWSTIMULUS Displays a single stimulus, allowing settings to be passed
	%to control display. 
	%   stimulus must be a stimulus class, i.e. gratingStimulus and friends,
	%   so for example: 
	%     >> gs=gratingStimulus(struct('mask',1,'sf',0.01));
	%     >> ss=runExperiment(struct('stimulus',gs,'windowed',1))
	%     >> ss.run
	
	properties
		pixelsPerCm = 44 %MBP 1440x900 is 33.2x20.6cm so approx 44px/cm, Flexscan is 32px/cm @1280 26px/cm @ 1024
		distance = 57.3 % rad2ang(2*(atan((0.5*1cm)/57.3cm))) equals 1deg
		stimulus %stimulus class passed from gratingStulus and friends
		task %the structure of the task, and any callbacks embedded
		screen = [] %which screen to display on, [] means use max screen
		windowed = 0 % if 1 useful for debugging, but remember timing will be poor
		debug = 1 % change the parameters for poorer temporal fidelity during debugging
		doubleBuffer = 1 %normally should be left at 1
		antiAlias = 4 %multisampling sent to the graphics card, try values []=disabled, 4, 8 and 16
		backgroundColor % background of display during stimulus presentation
		screenXOffset = 0 %shunt screen center by X degrees
		screenYOffset = 0 %shunt screen center by Y degrees
		blend = 0 %use OpenGL blending mode
		srcMode = 'GL_SRC_ALPHA' %GL_ONE %src mode
		dstMode = 'GL_ONE_MINUS_SRC_ALPHA' %GL_ONE % dst mode
		fixationPoint = 1 %show a fixation spot?
		photoDiode = 1 %show a white square to trigger a photodiode attached to screen
		serialPortName = 'dummy' %name of serial port to send TTL out on, if set to 'dummy' then ignore
		verbose = 0 %show time log after stumlus presentation
		hideFlash = 1 %hide the black flash as PTB tests it refresh timing.
	end
	
	properties (SetAccess = private, GetAccess = public)
		pixelsPerDegree %calculated from distance and pixelsPerCm
		maxScreen %set automatically on construction
		info
		computer %computer info
		ptb %PTB info
		screenVals %gamma tables and the like
		timeLog %log times during display
		sVals %calculated stimulus values
		taskLog %detailed info as the experiment runs
	end
	properties (SetAccess = private, GetAccess = private)
		black=0 %black index
		white=1 %white index
		allowedPropertiesBase='^(pixelsPerCm|distance|screen|windowed|stimulus|task|serialPortName|backgroundColor|screenXOffset|screenYOffset|blend|fixationPoint|srcMode|dstMode|antiAlias|debug|photoDiode|verbose|hideFlash)$'
		serialP %serial port object opened
		xCenter
		yCenter
		win
		winRect
		photoDiodeRect
	end
	
	methods
		%-------------------CONSTRUCTOR----------------------%
		function obj = runExperiment(args)
			obj.timeLog.construct=GetSecs;
			if nargin>0 && isstruct(args) %user passed some settings, we will parse through them and set them up
				if nargin>0 && isstruct(args)
					fnames = fieldnames(args); %find our argument names
					for i=1:length(fnames);
						if regexp(fnames{i},obj.allowedPropertiesBase) %only set if allowed property
							obj.salutation(fnames{i},'Configuring property in runExperiment constructor');
							obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
						end
					end
				end
			end
			obj.prepareScreen;
		end
		

		%-------------------------Main Grating----------------------------%
		function run(obj)
			
			%initialise timeLog for this run
			obj.timeLog.startrun=GetSecs;
			obj.timeLog.vbl=zeros(10000,1);
			obj.timeLog.show=zeros(10000,1);
			obj.timeLog.flip=zeros(10000,1);
			obj.timeLog.miss=zeros(10000,1);
			
			%HideCursor; %hide mouse
			
			if obj.hideFlash==1
				obj.screenVals.oldGamma = Screen('LoadNormalizedGammaTable', obj.screen, repmat(obj.screenVals.gammaTable(128,:), 256, 1));
			end
			
			obj.serialP=sendSerial(struct('name',obj.serialPortName,'openNow',1,'verbosity',0));
			obj.serialP.setDTR(0);
			
			try
				if obj.debug==1 || obj.windowed==1
					Screen('Preference', 'SkipSyncTests', 2);
					Screen('Preference', 'VisualDebugLevel', 0);
					Screen('Preference', 'Verbosity', 2); 
					Screen('Preference', 'SuppressAllWarnings', 0);
				else
					Screen('Preference', 'SkipSyncTests', 0);
					Screen('Preference', 'VisualDebugLevel', 3);
					Screen('Preference', 'Verbosity', 3); %errors and warnings
					Screen('Preference', 'SuppressAllWarnings', 0);
				end
				
				PsychImaging('PrepareConfiguration');
				PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
				PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
				
				obj.timeLog.preOpenWindow=GetSecs;
				if obj.windowed==1
					[obj.win, obj.winRect] = PsychImaging('OpenWindow', obj.screen, 0.5,[1 1 801 601], [], obj.doubleBuffer+1,[],obj.antiAlias);
				else
					[obj.win, obj.winRect] = PsychImaging('OpenWindow', obj.screen, 0.5,[], [], obj.doubleBuffer+1,[],obj.antiAlias);
				end
				
				Priority(MaxPriority(obj.win)); %bump our priority to maximum allowed
				
				obj.timeLog.postOpenWindow=GetSecs;
				obj.timeLog.deltaOpenWindow=(obj.timeLog.postOpenWindow-obj.timeLog.preOpenWindow)*1000;
				
				if obj.hideFlash==1
					Screen('LoadNormalizedGammaTable', obj.screen, obj.screenVals.gammaTable);
				end
				
				AssertGLSL;
				
				% Enable alpha blending.
				if obj.blend==1
					Screen('BlendFunction', obj.win, obj.srcMode, obj.dstMode);
				end
				
				%get the center of our screen, along with user defined offsets
				[obj.xCenter, obj.yCenter] = RectCenter(obj.winRect);
				obj.xCenter=obj.xCenter+(obj.screenXOffset*obj.pixelsPerDegree);
				obj.yCenter=obj.yCenter+(obj.screenYOffset*obj.pixelsPerDegree);
				
				%find our fps if not defined before  
				obj.screenVals.ifi=Screen('GetFlipInterval', obj.win);
				if obj.screenVals.fps==0
					obj.screenVals.fps=1/obj.screenVals.ifi;
				end
				obj.screenVals.halfisi=obj.screenVals.ifi/2;
				
				obj.black = BlackIndex(obj.win);
				obj.white = WhiteIndex(obj.win);
				
				obj.initialiseTask; %set up our task structure for this run
				
				obj.sVals=[];
				for i=1:length(obj.stimulus) %calculate values for each stimulus
					switch obj.stimulus(i).family
						case 'grating'
							obj.setupGrating(i);
						case 'dots'
							obj.setupDots(i);
						case 'annulus'
							obj.setupAnnulus(i);
					end
				end
				
				obj.initialiseVars; %set the variables for the very first run;
				
				obj.photoDiodeRect(:,1)=[0 0 25 25]';
				%obj.photoDiodeRect(:,2)=[obj.winRect(3)-100 obj.winRect(4)-100 obj.winRect(3) obj.winRect(4)]';
				
				KbReleaseWait; %make sure keyboard keys are all released
				
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Our main display loop
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				
				tick=1;
				obj.timeLog.beforeDisplay=GetSecs;
				[obj.timeLog.vbl(1),vbl.timeLog.show(1),obj.timeLog.flip(1),obj.timeLog.miss(1)] = Screen('Flip', obj.win);
				
				while obj.task.thisTrial <= obj.task.nTrials
					
					if obj.task.isBlank==1
						%obj.drawBackground;
					else
						if ~isempty(obj.backgroundColor)
							obj.drawBackground;
						end
						for j=1:length(obj.sVals)
							switch obj.stimulus(j).family
								case 'grating'
									obj.drawGrating(j);
								case 'dots'
									obj.drawDots(j);
								case 'annulus'
									obj.drawAnnulus(j);
							end
						end
						if obj.photoDiode==1
							obj.drawPhotoDiodeSquare;
						end
						if obj.fixationPoint==1
							obj.drawFixationPoint;
						end
					end
					
					t=sprintf('T: %i | R: %i | isBlank: %i | Time: %3.3f',obj.task.thisTrial,...
						obj.task.thisRun,obj.task.isBlank,(obj.timeLog.vbl(tick)-obj.task.startTime)); 
					Screen('DrawText',obj.win,t,50,0);
					
					Screen('DrawingFinished', obj.win); % Tell PTB that no further drawing commands will follow before Screen('Flip')
					
					[~, ~, buttons]=GetMouse(obj.screen);
					if any(buttons) % break out of loop
						break;
					end;
					
					obj.updateTask(tick);
					
					% Show it at next retrace:
					[obj.timeLog.vbl(tick+1),obj.timeLog.show(tick+1),obj.timeLog.flip(tick+1),obj.timeLog.miss(tick+1)] = Screen('Flip', obj.win, (obj.timeLog.vbl(tick)+obj.screenVals.halfisi));
					if tick==1
						obj.timeLog.startflip=obj.timeLog.vbl(tick) + obj.screenVals.halfisi;
						obj.timeLog.start=obj.timeLog.show(tick+1);
						%WaitSecs('UntilTime',obj.timeLog.show(thisRun+1));
						obj.serialP.setDTR(1);
					end
					
					tick=tick+1;
				end
				
				%---------------------------------------------Finished
				
				Screen('Flip', obj.win);
				obj.timeLog.afterDisplay=GetSecs;
				obj.serialP.setDTR(0);
				
				obj.timeLog.deltaDispay=obj.timeLog.afterDisplay-obj.timeLog.beforeDisplay;
				obj.timeLog.deltaUntilDisplay=obj.timeLog.beforeDisplay-obj.timeLog.start;
				obj.timeLog.deltaToFirstVBL=obj.timeLog.vbl(1)-obj.timeLog.beforeDisplay;
				obj.timeLog.deltaStart=obj.timeLog.startflip-obj.timeLog.start;
				
				obj.info = Screen('GetWindowInfo', obj.win);
				
				Screen('Close');
				Screen('CloseAll');
				obj.win=[];
				Priority(0);
				ShowCursor;
				obj.serialP.close;
				
			catch ME
				
				if obj.hideFlash==1
					Screen('LoadNormalizedGammaTable', obj.screen, obj.screenVals.gammaTable);
				end
				Screen('Close');
				Screen('CloseAll');
				obj.win=[];
				Priority(0);
				ShowCursor;
				obj.serialP.close;
				rethrow(ME)
				
			end
			
			if obj.verbose==1
				obj.printLog;
			end
		end
		
		%------------------Make sure pixelsPerDegree is also changed-----
		function set.distance(obj,value)
			if ~(value > 0)
				value = 57.3;
			end
			obj.distance = value;
			obj.pixelsPerDegree=round(obj.pixelsPerCm*(57.3/obj.distance)); %set the pixels per degree
			obj.salutation(['set sf: ' num2str(value)],'Custom set method')
		end 
		%------------------Make sure pixelsPerDegree is also changed-----
		function set.pixelsPerCm(obj,value)
			if ~(value > 0)
				value = 44;
			end
			obj.pixelsPerCm = value;
			obj.pixelsPerDegree=round(obj.pixelsPerCm*(57.3/obj.distance)); %set the pixels per degree
			obj.salutation(['set sf: ' num2str(value)],'Custom set method')
		end 
	end
	
	%-------------------------END PUBLIC METHODS--------------------------------%
	
	methods ( Access = private ) %----------PRIVATE METHODS---------------------%
		
		%---------------Update the stimulus values for the current trial---------%
		function initialiseTask(obj)
			if isempty(obj.task.findprop('thisRun'))
				obj.task.addprop('thisRun'); %add new dynamic property
			end
			obj.task.thisRun=1;
			
			if isempty(obj.task.findprop('thisTrial'))
				obj.task.addprop('thisTrial'); %add new dynamic property
			end
			obj.task.thisTrial=1;
			
			if isempty(obj.task.findprop('isBlank'))
				obj.task.addprop('isBlank'); %add new dynamic property
			end
			obj.task.isBlank=0;
			
			if isempty(obj.task.findprop('startTime'))
				obj.task.addprop('startTime'); %add new dynamic property
			end
			obj.task.startTime=0;
			
			if isempty(obj.task.findprop('switchTime'))
				obj.task.addprop('switchTime'); %add new dynamic property
			end
			obj.task.startTime=0;
			
			if isempty(obj.task.findprop('stimIsDrifting'))
				obj.task.addprop('stimIsDrifting'); %add new dynamic property
			end
			obj.task.stimIsDrifting=[];
			
			if isempty(obj.task.findprop('stimIsMoving'))
				obj.task.addprop('stimIsMoving'); %add new dynamic property
			end
			obj.task.stimIsMoving=[];
			
			%work out which stimuli have animaton parameters to update

		end
		
		%-------------set up variables for the first ever run -------------------%
		function initialiseVars(obj)
						
			for i=1:obj.task.nVars
				ix = obj.task.nVar(i).stimulus; %which stimulus
				value=obj.task.outVars{obj.task.thisTrial,i}(obj.task.thisRun);
				name=obj.task.nVar(i).name; %which parameter
				obj.sVals(ix).(name)=value;
				if strcmpi(name,'xPosition') || strcmpi(name,'yPosition')
					obj.sVals(ix).dstRect=Screen('Rect',obj.sVals(ix).gratingTexture);
					obj.sVals(ix).dstRect=ScaleRect(obj.sVals(ix).dstRect,obj.sVals(ix).scaledown,obj.sVals(ix).scaledown);
					obj.sVals(ix).dstRect=CenterRectOnPoint(obj.sVals(ix).dstRect,obj.xCenter,obj.yCenter);
					obj.sVals(ix).dstRect=OffsetRect(obj.sVals(ix).dstRect,obj.sVals(ix).xPosition*obj.pixelsPerDegree,obj.sVals(ix).yPosition*obj.pixelsPerDegree);
				end
			end
			
		end
		
		%---------------Update the stimulus values for the current trial---------%
		function updateTask(obj,tick)
			xt = GetSecs;
			if tick==1 %first ever loop
				obj.task.isBlank=0;
				obj.task.startTime=xt;
				obj.task.switchTime=obj.task.trialTime;
			end
			
			if  xt <= (obj.task.startTime+obj.task.switchTime) %do what we were doing.
				
				if obj.task.isBlank == 0 %not in an interstim time
					
					for i=1:length(obj.task.stimIsDrifting)
						ix=obj.task.stimIsDrifting(i);
						obj.sVals(ix).phase=obj.sVals(ix).phase+obj.sVals(ix).phaseincrement;
					end
					
					for i=1:length(obj.task.stimIsMoving)
						
					end
				else %blank stimulus, don't need to do anything
					
				end
				
			else %need to switch to next trial or blank
				
				if obj.task.isBlank == 0
					
					if ~mod(obj.task.thisRun,obj.task.minTrials)
						obj.task.switchTime=obj.task.switchTime+obj.task.itTime;
					else
						obj.task.switchTime=obj.task.switchTime+obj.task.isTime;
					end
					
					obj.task.isBlank = 1;
					
				else
					
					obj.task.switchTime=obj.task.switchTime+obj.task.trialTime;
					obj.task.isBlank = 0;
					obj.task.thisRun = obj.task.thisRun+1;
					
					if ~mod(obj.task.thisRun,obj.task.minTrials+1)
						obj.task.thisTrial=obj.task.thisTrial+1;
						obj.task.thisRun=obj.task.thisRun-obj.task.minTrials; %reset run
					end
					
					%now update our stimuli
					if obj.task.thisTrial <= obj.task.nTrials
						for i=1:obj.task.nVars
							ix = obj.task.nVar(i).stimulus;
							value=obj.task.outVars{obj.task.thisTrial,i}(obj.task.thisRun);
							name=obj.task.nVar(i).name;
							obj.sVals(ix).(name)=value;
							if strcmpi(name,'xPosition') || strcmpi(name,'yPosition')
								obj.sVals(ix).dstRect=Screen('Rect',obj.sVals(ix).gratingTexture);
								obj.sVals(ix).dstRect=ScaleRect(obj.sVals(ix).dstRect,obj.sVals(ix).scaledown,obj.sVals(ix).scaledown);
								obj.sVals(ix).dstRect=CenterRectOnPoint(obj.sVals(ix).dstRect,obj.xCenter,obj.yCenter);
								obj.sVals(ix).dstRect=OffsetRect(obj.sVals(ix).dstRect,obj.sVals(ix).xPosition*obj.pixelsPerDegree,obj.sVals(ix).yPosition*obj.pixelsPerDegree);
							end
						end
					end
				end
			end
		end
		
		%---------------Calculates the screen values----------------%
		function prepareScreen(obj)
			
			obj.pixelsPerDegree=round(obj.pixelsPerCm*(57.3/obj.distance)); %set the pixels per degree
			obj.maxScreen=max(Screen('Screens'));
			
			if isempty(obj.screen) || obj.screen > obj.maxScreen
				obj.screen = obj.maxScreen;
			end
			
			%get the gammatable and dac information
			[obj.screenVals.gammaTable,obj.screenVals.dacBits,obj.screenVals.lutSize]=Screen('ReadNormalizedGammaTable', obj.screen);
			
			%get screen dimensions
			rect=Screen('Rect',obj.screen);
			obj.screenVals.width=rect(3);
			obj.screenVals.height=rect(4);
			
			obj.screenVals.fps=Screen('FrameRate',obj.screen);
			
			%initialise 10,000 timeLog values
			obj.timeLog.vbl=zeros(10000,1);
			obj.timeLog.show=zeros(10000,1);
			obj.timeLog.flip=zeros(10000,1);
			obj.timeLog.miss=zeros(10000,1);
			
			%make sure we load up and test the serial port
			obj.serialP=sendSerial(struct('name',obj.serialPortName,'openNow',1));
			obj.serialP.toggleDTRLine;
			obj.serialP.close;
			
			try
				AssertOpenGL;
			catch ME
				error('OpenGL is required for Opticka!');
			end
			
			obj.computer=Screen('computer');
			obj.ptb=Screen('version');
			
			obj.timeLog.prepTime=GetSecs-obj.timeLog.construct;
			a=GetSecs;
			b=GetSecs;
			c=GetSecs;
			d=GetSecs;
			e=GetSecs;
			f=GetSecs;
			g=GetSecs;
			obj.timeLog.deltaGetSecs=mean(diff([a b c d e f g]))*1000; %what overhead does GetSecs have?
			WaitSecs(0.01); %preload function
			
			Screen('Preference', 'TextRenderer', 0); %fast text renderer
			
		end
		
		%--------------------Configure grating specific variables-----------%
		function setupGrating(obj,i)
			if obj.stimulus(i).rotationMethod==1
				obj.sVals(i).rotateMode = kPsychUseTextureMatrixForRotation;
			else
				obj.sVals(i).rotateMode = [];
			end
			
			obj.sVals(i).gabor=obj.stimulus(i).gabor;
			if obj.sVals(i).gabor==0
				obj.sVals(i).scaledown=0.25;
				obj.sVals(i).scaleup=4;
			else
				obj.sVals(i).scaledown=1; %scaling gabors does weird things!!!
				obj.sVals(i).scaleup=1;
			end
			obj.sVals(i).gratingSize = round(obj.pixelsPerDegree*obj.stimulus(i).size);
			obj.sVals(i).sf = (obj.stimulus(i).sf/obj.pixelsPerDegree)*obj.sVals(i).scaledown;
			obj.sVals(i).tf = obj.stimulus(i).tf;
			obj.sVals(i).contrast = obj.stimulus(i).contrast/2;
			obj.sVals(i).angle = obj.stimulus(i).angle;
			obj.sVals(i).phase = obj.stimulus(i).phase;
			obj.sVals(i).phaseincrement = (obj.sVals(i).tf * 360) * obj.screenVals.ifi;
			obj.sVals(i).color = obj.stimulus(i).color;
			obj.sVals(i).xPosition = obj.stimulus(i).xPosition*obj.pixelsPerDegree;
			obj.sVals(i).yPosition = obj.stimulus(i).yPosition*obj.pixelsPerDegree;
			
			
			if obj.stimulus(i).driftDirection < 1
				obj.sVals(i).phaseincrement = -obj.sVals(i).phaseincrement;
			end
			
			if obj.sVals(i).tf>0 %we need to say this needs animating
				obj.sVals(i).doDrift=1;
				obj.task.stimIsDrifting=[obj.task.stimIsDrifting i];
			else
				obj.sVals(i).doDrift=0;
			end
			

			obj.sVals(i).res = [obj.sVals(i).gratingSize obj.sVals(i).gratingSize]*obj.sVals(i).scaleup;
			
			if obj.stimulus(i).mask>0
				obj.sVals(i).mask = (floor((obj.pixelsPerDegree*obj.stimulus(i).size)/2)*obj.sVals(i).scaleup);
			else
				obj.sVals(i).mask = [];
			end
			
			if obj.stimulus(i).gabor==0
				obj.sVals(i).gratingTexture = CreateProceduralSineGrating(obj.win, obj.sVals(i).res(1), obj.sVals(i).res(2),obj.sVals(i).color, obj.sVals(i).mask);
			else
				obj.sVals(i).gratingTexture = CreateProceduralGabor(obj.win, obj.sVals(i).res(1), obj.sVals(i).res(2), 1, obj.sVals(i).color);
			end
			
			obj.sVals(i).dstRect=Screen('Rect',obj.sVals(i).gratingTexture);
			obj.sVals(i).dstRect=ScaleRect(obj.sVals(i).dstRect,obj.sVals(i).scaledown,obj.sVals(i).scaledown);
			obj.sVals(i).dstRect=CenterRectOnPoint(obj.sVals(i).dstRect,obj.xCenter,obj.yCenter);
			obj.sVals(i).dstRect=OffsetRect(obj.sVals(i).dstRect,obj.sVals(i).xPosition,obj.sVals(i).yPosition);
		end
		
		%-------------------Draw the grating-------------------%
		function drawGrating(obj,j)
			if obj.sVals(j).gabor==0
				Screen('DrawTexture', obj.win, obj.sVals(j).gratingTexture, [],obj.sVals(j).dstRect,...
					obj.sVals(j).angle, [], [], [], [],obj.sVals(j).rotateMode, [obj.sVals(j).phase,...
					obj.sVals(j).sf,obj.sVals(j).contrast, 0]);
			else
				Screen('DrawTexture', obj.win, obj.sVals(j).gratingTexture, [],...
					obj.sVals(j).dstRect, [], [], [], [], [], kPsychDontDoRotation,...
					[obj.sVals(j).phase, obj.sVals(j).sf, 10, 10, 0.5, 0, 0, 0]);
			end
		end
		
		%--------------------Draw Fixation spot-------------%
		function drawFixationPoint(obj)
			Screen('gluDisk',obj.win,[1 1 0],obj.xCenter,obj.yCenter,5);
		end
		
		%--------------------Draw photodiode block-------------%
		function drawPhotoDiodeSquare(obj)
			Screen('FillRect',obj.win,[1 1 1 0],obj.photoDiodeRect);
		end
		
		%--------------------Draw photodiode block-------------%
		function drawBackground(obj)
			Screen('FillRect',obj.win,obj.backgroundColor,[]);
		end
		
		%--------------------Print time log-------------------%
		function printLog(obj)
			obj.timeLog.vbl=obj.timeLog.vbl(obj.timeLog.vbl>0)*1000;
			obj.timeLog.show=obj.timeLog.show(obj.timeLog.show>0)*1000;
			obj.timeLog.flip=obj.timeLog.flip(obj.timeLog.flip>0)*1000;
			index=min([length(obj.timeLog.vbl) length(obj.timeLog.flip) length(obj.timeLog.show)]);
			obj.timeLog.vbl=obj.timeLog.vbl(1:index);
			obj.timeLog.show=obj.timeLog.show(1:index);
			obj.timeLog.flip=obj.timeLog.flip(1:index);
			obj.timeLog.miss=obj.timeLog.miss(1:index);
			
			figure
			plot(1:index-2,diff(obj.timeLog.vbl(2:end)),'ro:')
			hold on
			plot(1:index-2,diff(obj.timeLog.show(2:end)),'b--')
			plot(1:index-2,diff(obj.timeLog.flip(2:end)),'g-.')
			legend('VBL','Show','Flip')
			t=sprintf('VBL mean=%2.2f', mean(diff(obj.timeLog.vbl)));
			t=[t sprintf(' | Show mean=%2.2f', mean(diff(obj.timeLog.show(2:end))))];
			t=[t sprintf(' | Flip mean=%2.2f', mean(diff(obj.timeLog.flip(2:end))))];
			title(t)
			hold off
			
			figure
			hold on
			plot(obj.timeLog.show(2:index)-obj.timeLog.vbl(2:index),'r')
			plot(obj.timeLog.show(1:index)-obj.timeLog.flip(1:index),'g')
			plot(obj.timeLog.vbl(1:index)-obj.timeLog.flip(1:index),'b')
			title('VBL - Flip time in ms')
			legend('Show-VBL','Show-Flip','VBL-Flip')
			
			figure
			plot(obj.timeLog.miss,'r.-')
			title('Missed frames')
		end
		
		%-------------------blah blah blah-----------------------------------
		function salutation(obj,in,message)
			if obj.verbose==1
				if ~exist('in','var')
					in = 'random user';
				end
				if exist('message','var')
					fprintf([message ' | ' in '\n']);
				else
					fprintf(['\nHello from ' obj.screen ' stimulus, ' in '\n\n']);
				end
			end
		end
	end
end