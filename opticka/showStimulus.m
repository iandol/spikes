classdef showStimulus < dynamicprops
	%SHOWSTIMULUS Displays a single stimulus, allowing settings to be passed
	%to control display. 
	%   stimulus must be a stimulus class, i.e. gratingStimulus and friends,
	%   so for example: 
	%     >> gs=gratingStimulus(struct('mask',1,'sf',0.01));
	%     >> ss=showStimulus(struct('stimulus',gs,'windowed',1))
	%     >> ss.run
	
	properties
		pixelsPerCm = 26 %MBP 1440x900 is 33.2x20.6cm so approx 44px/cm, Flexscan is 32px/cm @1280 26px/cm @ 1024
		distance = 57.3 % rad2ang(2*(atan((0.5*1cm)/57.3cm))) equals 1deg
		stimulus %stimulus class passed from gratingStulus and friends
		screen = [] %which screen to display on, [] means use max screen
		windowed = 0 % useful for debugging
		debug = 1 % change the parameters for poor temporal fidelity during debugging
		doubleBuffer = 1 %normally should be left at 1
		antiAlias = [] %multisampling sent to the graphics card, try values []=disabled, 4, 8 and 16
		backgroundColor % background of display during stimulus presentation
		screenXOffset = 0 %shunt screen center by X degrees
		screenYOffset = 0 %shunt screen center by Y degrees
		blend = 0 %use OpenGL blending mode
		srcMode = 'GL_SRC_ALPHA' %GL_ONE %src mode
		dstMode = 'GL_ONE_MINUS_SRC_ALPHA' %GL_ONE % dst mode
		fixationPoint = 1 %show a fixation spot?
		photoDiode = 1 %show a white square to trigger a photodiode attached to screen
		serialPortName = 'dummy' %name of serial port to send TTL out on, if set to 'dummy' then ignore
		showLog = 1 %show time log after stumlus presentation
		blankFlash = 1 %hide the black flash as PTB tests it refresh timing.
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
	end
	properties (SetAccess = private, GetAccess = private)
		black=0 %black index
		white=1 %white index
		allowedPropertiesBase='^(pixelsPerCm|distance|screen|windowed|stimulus|serialPortName|backgroundColor|screenXOffset|screenYOffset|blend|fixationPoint|srcMode|dstMode|antiAlias|debug|windowed|photoDiode)$'
		serialP %serial port object opened
		xCenter
		yCenter
	end
	
	methods
		%-------------------CONSTRUCTOR----------------------%
		function obj = showStimulus(args)
			obj.timeLog.construct=GetSecs;
			if nargin>0 && isstruct(args) %user passed some settings, we will parse through them and set them up
				if nargin>0 && isstruct(args)
					fnames = fieldnames(args); %find our argument names
					for i=1:length(fnames);
						if regexp(fnames{i},obj.allowedPropertiesBase) %only set if allowed property
							obj.salutation(fnames{i},'Configuring property in showStimulus constructor');
							obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
						end
					end
				end
			end
			obj.prepareScreen;
		end
		
		%---------------CALLS THE RIGHT DISPLAY METHOD----------------%
		function run(obj) %just a temporary alias
			
			switch obj.stimulus(1).family
				case 'grating'
					obj.showGrating
			end
			
		end
		

		%-------------------------Main Grating----------------------------%
		function showGrating(obj)
			
			%initialise timeLog for this run
			obj.timeLog.start=GetSecs;
			obj.timeLog.vbl=zeros(10000,1);
			obj.timeLog.show=zeros(10000,1);
			obj.timeLog.flip=zeros(10000,1);
			obj.timeLog.miss=zeros(10000,1);
			
			%HideCursor; %hide mouse
			
			if obj.blankFlash==1
				obj.screenVals.oldGamma = Screen('LoadNormalizedGammaTable', obj.screen, repmat(obj.screenVals.gammaTable(128,:), 256, 1));
			end
			
			obj.serialP=sendSerial(struct('name',obj.serialPortName,'openNow',1,'verbosity',0));
			obj.serialP.setDTR(0);
			
			try
				if obj.debug==1
					Screen('Preference', 'SkipSyncTests', 0);
					Screen('Preference', 'VisualDebugLevel', 0);
					Screen('Preference', 'Verbosity', 3); 
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
					[window, windowrect] = PsychImaging('OpenWindow', obj.screen, 0.5,[1 1 801 601], [], obj.doubleBuffer+1,[],obj.antiAlias);
				else
					[window, windowrect] = PsychImaging('OpenWindow', obj.screen, 0.5,[], [], obj.doubleBuffer+1,[],obj.antiAlias);
				end
				
				Priority(MaxPriority(window)); %bump our priority to maximum allowed
				
				obj.timeLog.postOpenWindow=GetSecs;
				obj.timeLog.deltaOpenWindow=obj.timeLog.postOpenWindow-obj.timeLog.preOpenWindow;
				
				if obj.blankFlash==1
					Screen('LoadNormalizedGammaTable', obj.screen, obj.screenVals.gammaTable);
				end
				
				AssertGLSL;
				
				% Enable alpha blending with proper blend-function.
				if obj.blend==1
					Screen('BlendFunction', window, obj.srcMode, obj.dstMode);
				end
				
				%get the center of our screen, along with user defined offsets
				[obj.xCenter, obj.yCenter] = RectCenter(windowrect);
				obj.xCenter=obj.xCenter+(obj.screenXOffset*obj.pixelsPerDegree);
				obj.yCenter=obj.yCenter+(obj.screenYOffset*obj.pixelsPerDegree);
				
				%find our fps if not defined before  
				obj.screenVals.ifi=Screen('GetFlipInterval', window);
				if obj.screenVals.fps==0
					obj.screenVals.fps=1/obj.screenVals.ifi;
				end;
				
				obj.black = BlackIndex(window);
				obj.white = WhiteIndex(window);
				
				
				for i=1:length(obj.stimulus) %calculate values for each stimulus
					
					if obj.stimulus(i).rotationMethod==1
						obj.sVals(i).rotateMode = kPsychUseTextureMatrixForRotation;
					else
						obj.sVals(i).rotateMode = [];
					end
				
					obj.sVals(i).gratingSize = obj.pixelsPerDegree*obj.stimulus(i).size;
					obj.sVals(i).sf = obj.stimulus(i).sf/obj.pixelsPerDegree;
					obj.sVals(i).tf = obj.stimulus(i).tf;
					obj.sVals(i).amplitude = obj.stimulus(i).contrast/2;
					obj.sVals(i).angle = obj.stimulus(i).angle;
					obj.sVals(i).phase = obj.stimulus(i).phase;
					obj.sVals(i).phaseincrement = (obj.sVals(i).tf * 360) * obj.screenVals.ifi;
					obj.sVals(i).color = obj.stimulus(i).color;
					obj.sVals(i).xPosition = obj.stimulus(i).xPosition*obj.pixelsPerDegree;
					obj.sVals(i).yPosition = obj.stimulus(i).xPosition*obj.pixelsPerDegree;
					obj.sVals(i).gabor=obj.stimulus(i).gabor;
					
					if obj.stimulus(i).driftDirection < 1
						obj.sVals(i).phaseincrement = -obj.sVals(i).phaseincrement;
					end
					
					obj.sVals(i).res = [obj.sVals(i).gratingSize obj.sVals(i).gratingSize];
					
					if obj.stimulus(i).mask>0
						obj.sVals(i).mask = floor((obj.pixelsPerDegree*obj.stimulus(i).size)/2);
					else
						obj.sVals(i).mask = [];
					end

					if obj.stimulus(i).gabor==0
						obj.sVals(i).gratingTexture = CreateProceduralSineGrating(window, obj.sVals(i).res(1), obj.sVals(i).res(2),obj.sVals(i).color, obj.sVals(i).mask);
					else
						obj.sVals(i).gratingTexture = CreateProceduralGabor(window, obj.sVals(i).res(1), obj.sVals(i).res(2), 1, obj.sVals(i).color);
					end

					obj.sVals(i).dstRect=Screen('Rect',obj.sVals(i).gratingTexture);
					%dstRect=ScaleRect(rect,(obj.stimulus.size/1),(obj.stimulus.size/1))
					obj.sVals(i).dstRect=CenterRectOnPoint(obj.sVals(i).dstRect,obj.xCenter,obj.yCenter);
					obj.sVals(i).dstRect=OffsetRect(obj.sVals(i).dstRect,obj.sVals(i).xPosition,obj.sVals(i).yPosition);
					
				end
				
				fixRect=CenterRectOnPoint([0 0 5 5],obj.xCenter,obj.yCenter);
				photoDiodeRect(:,1)=[0 0 100 100]';
				photoDiodeRect(:,2)=[windowrect(3)-100 windowrect(4)-100 windowrect(3) windowrect(4)]';
				
				KbReleaseWait; %make sure keyboard keys are all released
				
				i=1;
				
				obj.timeLog.beforeDisplay=GetSecs;
				[obj.timeLog.vbl(1),vbl.timeLog.show(1),obj.timeLog.flip(1),obj.timeLog.miss(1)] = Screen('Flip', window);
				
				while 1
					if ~isempty(obj.backgroundColor)
						Screen('FillRect',window,obj.backgroundColor,[]);
					end
					
					for j=1:length(obj.sVals)
						if obj.sVals(j).gabor==0
							Screen('DrawTexture', window, obj.sVals(j).gratingTexture, [], obj.sVals(j).dstRect, obj.sVals(j).angle, [], [], [], [], obj.sVals(j).rotateMode, [obj.sVals(j).phase, obj.sVals(j).sf, obj.sVals(j).amplitude, 0]);
						else
							Screen('DrawTexture', window, obj.sVals(j).gratingTexture, [], obj.sVals(j).dstRect, [], [], [], [], [], kPsychDontDoRotation, [obj.sVals(j).phase, obj.sVals(j).sf, 10, 10, 0.5, 0, 0, 0]);
						end
					end
					
					if obj.fixationPoint==1
						Screen('gluDisk',window,[1 1 1],obj.xCenter,obj.yCenter,5);
					end
					if obj.photoDiode==1
						Screen('FillRect',window,[1 1 1 0],photoDiodeRect);
					end
					Screen('DrawingFinished', window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
					
					[~, ~, buttons]=GetMouse(obj.screen);
					if KbCheck || any(buttons) % break out of loop
						break;
					end;
					
					for j=1:length(obj.sVals)
						if obj.sVals(j).tf>0
							obj.sVals(j).phase = obj.sVals(j).phase + obj.sVals(j).phaseincrement;
						end
					end
					
					% Show it at next retrace:
					[obj.timeLog.vbl(i+1),obj.timeLog.show(i+1),obj.timeLog.flip(i+1),obj.timeLog.miss(i+1)] = Screen('Flip', window, obj.timeLog.vbl(i) + (0.5 * obj.screenVals.ifi));
					if i==1
						WaitSecs('UntilTime',obj.timeLog.show(i+1));
						obj.serialP.setDTR(1);
					end
					i=i+1;
				end
				obj.timeLog.afterDisplay=GetSecs;
				
				Screen('FillRect',window,[1 0 0],[]);
				Screen('Flip', window);
				obj.serialP.setDTR(0);
				
				obj.timeLog.deltaDispay=obj.timeLog.afterDisplay-obj.timeLog.beforeDisplay;
				obj.timeLog.deltaUntilDisplay=obj.timeLog.beforeDisplay-obj.timeLog.start;
				obj.timeLog.deltafirstVBL=obj.timeLog.vbl(1)-obj.timeLog.beforeDisplay;
				
				
				obj.info = Screen('GetWindowInfo', window);
				
				Screen('Close');
				Screen('CloseAll');
				Priority(0);
				ShowCursor;
				obj.serialP.close;
				
			catch ME
				if obj.blankFlash==1
					Screen('LoadNormalizedGammaTable', obj.screen, obj.screenVals.gammaTable);
				end
				Screen('Close');
				Screen('CloseAll');
				Priority(0);
				ShowCursor;
				obj.serialP.close;
				rethrow(ME)
			end
			
			if obj.showLog==1
				obj.printLog;
			end
		end
		
		%-------------------blah blah blah-----------------------------------
		function salutation(obj,in,message)
			if ~exist('in','var')
				in = 'random user';
			end
			if exist('message','var')
				fprintf([message ' | ' in '\n']);
			else
				fprintf(['\nHello from ' obj.screen ' stimulus, ' in '\n\n']);
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
	end %---END PUBLIC METHODS---%
	
	methods ( Access = private ) %----------PRIVATE METHODS---------%
		
		%---------------Calculates the screen values----------------%
		function prepareScreen(obj)
			
			obj.pixelsPerDegree=obj.pixelsPerCm*(57.3/obj.distance); %set the pixels per degree
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
			WaitSecs(0.1); %preload function
			
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
	end
end