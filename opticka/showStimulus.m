classdef showStimulus < handle
	%BASESTIMULUS Summary of this class goes here
	%   Detailed explanation goes here
	properties
		pixelsPerCm=44 %MBP 1440x900 is 33.2x20.6cm so approx 44pixels per cm
		distance=57.3 % rad2ang(2*(atan((0.5*1cm)/57.3cm))) equals 1deg
		pixelsPerDegree
		stimulus
		screen=0
		maxScreen
		windowed=1
		debug=1
		doubleBuffer=1
		antiAlias=[]
		gabor=1
	end
	properties (SetAccess = private, GetAccess = private)
		black=0
		white=1
		allowedPropertiesBase='^(pixelsPerCm|distance|screen|windowed|stimulus|gabor|antiAlias|debug|windowed)$'
	end
	methods
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CONSTRUCTOR
		function obj = showStimulus(args)
			obj.pixelsPerDegree=obj.pixelsPerCm*(57.3/obj.distance); %set the pixels per degree
			obj.maxScreen=max(Screen('Screens'));
			if nargin>0 && isstruct(args) %user passed some settings, we will parse through them and set them up
				if nargin>0 && isstruct(args)
					fnames = fieldnames(args); %find our argument names
					for i=1:length(fnames);
						if regexp(fnames{i},obj.allowedPropertiesBase) %only set if allowed property
							obj.salutation(fnames{i},'Configuring setting in showStimulus constructor');
							obj.(fnames{i})=args.(fnames{i}); %we set up the properies from the arguments as a structure
						end
					end
				end
			elseif nargin>0 && iscell(args)
				
			end
		end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function showGrating(obj)
			AssertOpenGL;
			AssertOSX;
			
			try
				if obj.debug==1
					Screen('Preference', 'SkipSyncTests', 2);
					Screen('Preference', 'VisualDebugLevel', 3);
					Screen('Preference', 'Verbosity', 5); 
					Screen('Preference', 'SuppressAllWarnings', 1);
				else
					Screen('Preference', 'SkipSyncTests', 0);
					Screen('Preference', 'VisualDebugLevel', 4);
					Screen('Preference', 'Verbosity', 3); %errors and warnings
					Screen('Preference', 'SuppressAllWarnings', 0);
				end
				
				PsychImaging('PrepareConfiguration');
				PsychImaging('AddTask', 'General', 'FloatingPoint16BitIfPossible');
				PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
				
				if obj.windowed==1
					[window, windowrect] = PsychImaging('OpenWindow', obj.screen, 0.5,[1 1 801 601], [], obj.doubleBuffer+1,[],obj.antiAlias);
				else
					[window, windowrect] = PsychImaging('OpenWindow', obj.screen, 0.5,[], [], obj.doubleBuffer+1,[],obj.antiAlias);
				end
				
% 				if obj.windowed==1
% 					[window windowrect] = Screen('OpenWindow', obj.screen, 128, [1 1 801 601], [], obj.doubleBuffer+1,[],obj.antiAlias);
% 				else
% 					[window windowrect] = Screen('OpenWindow', obj.screen, 128, [], [], obj.doubleBuffer+1,[],obj.antiAlias);
% 				end
				
				AssertGLSL;
				
				% Enable alpha blending with proper blend-function.
				%Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				[center(1), center(2)] = RectCenter(windowrect);
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
				
				if obj.gabor==0
					gratingTexture = CreateProceduralSineGrating(window, res(1), res(2),obj.stimulus.color, obj.stimulus.mask);
				else
					gratingTexture = CreateProceduralGabor(window, res(1), res(2), 1, obj.stimulus.color);
				end
				
				rect=Screen('Rect',gratingTexture)
				
				dstRect=ScaleRect(rect,(obj.stimulus.size/1),(obj.stimulus.size/1))
				dstRect=CenterRectOnPoint(dstRect,center(1),center(2))
				dstRect=OffsetRect(dstRect,1*obj.pixelsPerDegree,1*obj.pixelsPerDegree)
				dstRect=[]
				KbReleaseWait;
				vbl = Screen('Flip', window);
				
				while 1
					if obj.gabor==0
						Screen('DrawTexture', window, gratingTexture, [], dstRect, angle, [], [], [], [], rotateMode, [phase, spatialFrequency, amplitude, 0]);
					else
						Screen('DrawTexture', window, gratingTexture, [], dstRect, [], [], [], [], [], kPsychDontDoRotation, [phase, spatialFrequency, 10, 10, 0.5, 0, 0, 0]);
					end
					Screen('DrawingFinished', window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
					
					[~, ~, buttons]=GetMouse(obj.screen);
					if KbCheck || any(buttons) % break out of loop
						break;
					end;
					%phase = phase + phaseincrement;
					%angle=angle+0.1;
					% Show it at next retrace:
					vbl = Screen('Flip', window, vbl + 0.5 * ifi);
				end
				
				Priority(0);
				ShowCursor;
				Screen('CloseAll');
			catch ME	
				Screen('CloseAll');
				Priority(0);
				ShowCursor;
				rethrow(ME)
			end
			
		end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
	end
end