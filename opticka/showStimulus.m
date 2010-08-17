classdef showStimulus < handle
	%SHOWSTIMULUS Displays a single stimulus, allowing settings to be passed
	%to control display. 
	%   stimulus must be a stimulus class, i.e. gratingStimulus and friends,
	%   so for example: 
	%     >> gs=gratingStimulus(struct('mask',1,'sf',0.01));
	%     >> ss=showStimulus(struct('stimulus',gs,'windowed',1))
	%     >> ss.run
	
	properties
		pixelsPerCm = 32 %MBP 1440x900 is 33.2x20.6cm so approx 44px/cm, Flexscan is 32px/cm
		distance = 57.3 % rad2ang(2*(atan((0.5*1cm)/57.3cm))) equals 1deg
		pixelsPerDegree %calculated from distance and pixelsPerCm
		stimulus %stimulus class passed from gratingStulus and friends
		screen = 1 %which screen to display on
		maxScreen %set automatically on construction
		windowed = 1 % useful for debugging
		debug = 1 % change the parameters for poor temporal fidelity during debugging
		doubleBuffer = 1 %normally should be left at 1
		antiAlias = [] %multisampling sent to the graphics card, try values []=disabled, 4, 8 and 16
		serialPortName = 'dummy' %name of serial port to send TTL out on, if set to 'dummy' then ignore
		serialP %serial port object opened
		backgroundColor % background of display during stimulus presentation
		screenXOffset = 0 %shunt screen center by X degrees
		screenYOffset = 0 %shunt screen center by Y degrees
		blend = 0 %use OpenGL blending mode
		srcMode = 'GL_SRC_ALPHA' %GL_ONE %src mode
		dstMode = 'GL_ONE_MINUS_SRC_ALPHA' %GL_ONE % dst mode
		fixationPoint = 1 %show a fixation spot?
		photoDiode = 1 %show a white square to trigger a photodiode attached to screen
	end
	
	properties (SetAccess = private, GetAccess = private)
		black=0 %black index
		white=1 %white index
		allowedPropertiesBase='^(pixelsPerCm|distance|screen|windowed|stimulus|serialPortName|backgroundColor|screenXOffset|screenYOffset|blend|fixationPoint|srcMode|dstMode|antiAlias|debug|windowed|photoDiode)$'
		timeLog %log times during display
	end
	
	methods
		%-------------------CONSTRUCTOR----------------------%
		function obj = showStimulus(args)
			
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
			
			obj.pixelsPerDegree=obj.pixelsPerCm*(57.3/obj.distance); %set the pixels per degree
			obj.maxScreen=max(Screen('Screens'));
			
			if obj.screen > obj.maxScreen
				obj.screen = obj.maxScreen;
			end
		end
		
		%---------------CALLS THE RIGHT DISPLAY METHOD----------------%
		function run(obj) %just a temporary alias
			switch obj.stimulus.family
				case 'grating'
					obj.showGrating
			end
		end
		
		%-------------------------Main Grating----------------------------%
		function showGrating(obj)
			
			obj.timeLog=zeros(5,1);
			obj.timeLog(1)=GetSecs;
			AssertOpenGL;
			
			obj.serialP=sendSerial(struct('name',obj.serialPortName,'openNow',1));
			obj.serialP.toggleDTRLine;
			
			try
				if obj.debug==1
					Screen('Preference', 'SkipSyncTests', 0);
					Screen('Preference', 'VisualDebugLevel', 0);
					Screen('Preference', 'Verbosity', 4); 
					Screen('Preference', 'SuppressAllWarnings', 0);
				else
					Screen('Preference', 'SkipSyncTests', 0);
					Screen('Preference', 'VisualDebugLevel', 4);
					Screen('Preference', 'Verbosity', 3); %errors and warnings
					Screen('Preference', 'SuppressAllWarnings', 0);
				end
				
				PsychImaging('PrepareConfiguration');
				PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
				PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
				
				if obj.windowed==1
					[window, windowrect] = PsychImaging('OpenWindow', obj.screen, 0.5,[1 1 801 601], [], obj.doubleBuffer+1,[],obj.antiAlias);
				else
					[window, windowrect] = PsychImaging('OpenWindow', obj.screen, 0.5,[], [], obj.doubleBuffer+1,[],obj.antiAlias);
				end
				obj.timeLog(2)=WaitSecs(1);
% 				if obj.windowed==1
% 					[window windowrect] = Screen('OpenWindow', obj.screen, 128, [1 1 801 601], [], obj.doubleBuffer+1,[],obj.antiAlias);
% 				else
% 					[window windowrect] = Screen('OpenWindow', obj.screen, 128, [], [], obj.doubleBuffer+1,[],obj.antiAlias);
% 				end
				
				AssertGLSL;
				
				% Enable alpha blending with proper blend-function.
				if obj.blend==1
					Screen('BlendFunction', window, obj.srcMode, obj.dstMode);
				end
				[center(1), center(2)] = RectCenter(windowrect);
				center(1)=center(1)+obj.screenXOffset;
				center(2)=center(2)+obj.screenYOffset;
				fps=Screen('FrameRate',window);      % frames per second
				ifi=Screen('GetFlipInterval', window);
				if fps==0
					fps=1/ifi;
				end;
				obj.black = BlackIndex(window);
				obj.white = WhiteIndex(window);
				
				Priority(MaxPriority(window));
				
				if obj.stimulus.rotationMethod==1
					rotateMode = kPsychUseTextureMatrixForRotation;
				else
					rotateMode = [];
				end
				
				gratingSize=obj.pixelsPerDegree*obj.stimulus.size;
				spatialFrequency=obj.stimulus.sf;
				cyclesPerSecond=obj.stimulus.tf;
				amplitude=obj.stimulus.contrast/2;
				angle=obj.stimulus.angle;
				phase=obj.stimulus.phase;
				phaseincrement = (cyclesPerSecond * 360) * ifi;
				res = [gratingSize gratingSize];
				if obj.stimulus.mask>0
					obj.stimulus.mask = floor((obj.pixelsPerDegree*obj.stimulus.size)/2);
				else
					obj.stimulus.mask = [];
				end
				
				if obj.stimulus.gabor==0
					gratingTexture = CreateProceduralSineGrating(window, res(1), res(2),obj.stimulus.color, obj.stimulus.mask);
				else
					gratingTexture = CreateProceduralGabor(window, res(1), res(2), 1, obj.stimulus.color);
				end
				
				dstRect=Screen('Rect',gratingTexture);
				%dstRect=ScaleRect(rect,(obj.stimulus.size/1),(obj.stimulus.size/1))
				dstRect=CenterRectOnPoint(dstRect,center(1),center(2));
				dstRect=OffsetRect(dstRect,obj.stimulus.xPosition*obj.pixelsPerDegree,obj.stimulus.yPosition*obj.pixelsPerDegree);
				fixRect=CenterRectOnPoint([0 0 10 10],center(1),center(2));
				photoDiodeRect=[windowrect(3)-200 windowrect(4)-200 windowrect(3) windowrect(4)];
				
				KbReleaseWait;
				i=0;
				vbl = Screen('Flip', window);
				obj.timeLog(3)=vbl;
				while 1
					if ~isempty(obj.backgroundColor)
						Screen('FillRect',window,obj.backgroundColor,[]);
					end
					if obj.stimulus.gabor==0
						Screen('DrawTexture', window, gratingTexture, [], dstRect, angle, [], [], [], [], rotateMode, [phase, spatialFrequency, amplitude, 0]);
					else
						Screen('DrawTexture', window, gratingTexture, [], dstRect, [], [], [], [], [], kPsychDontDoRotation, [phase, spatialFrequency, 10, 10, 0.5, 0, 0, 0]);
					end
					if obj.fixationPoint==1
						Screen('FillOval',window,[1 1 1],fixRect);
					end
					if obj.photoDiode==1
						Screen('FillRect',window,[1 1 1 0],photoDiodeRect);
					end
					Screen('DrawingFinished', window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
					
					[~, ~, buttons]=GetMouse(obj.screen);
					if KbCheck || any(buttons) % break out of loop
						break;
					end;
					
					if obj.stimulus.tf>0
						phase = phase + phaseincrement;
					end
					
					% Show it at next retrace:
					vbl = Screen('Flip', window, vbl + 0.5 * ifi);
					if i==0
						obj.timeLog(4)=GetSecs;
						obj.serialP.toggleDTRLine;
						obj.timeLog(5)=vbl-obj.timeLog(4);
					end
					i=i+1;
				end
				vbl = Screen('Flip', window);
				vbl = Screen('Flip', window);
				obj.serialP.setDTR(0);
				Priority(0);
				ShowCursor;
				Screen('Close');
				Screen('CloseAll');
				obj.serialP.close;
				plot(diff(obj.timeLog))
			catch ME
				Screen('Close');
				Screen('CloseAll');
				Priority(0);
				ShowCursor;
				obj.serialP.close;
				rethrow(ME)
			end
			
		end
		
		%---------------------------------------------------------
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
			obj.pixelsPerDegree=obj.pixelsPerCm*(57.3/obj.distance); %set the pixels per degree
			obj.salutation(['set sf: ' num2str(value)],'Custom set method')
		end 
	end %---END PUBLIC METHODS---%
	
	methods ( Access = private ) %----------PRIVATE METHODS---------%
		
	end
end