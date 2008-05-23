function [ ] = cockpit(varargin);
%
% COCKPIT Flight simulator
%    COCKPIT('FileName') starts the flight simulator. The various flight 
%    properties are saved to the MAT file.  All variables (other than LANDSCAPE)
%    have default values and need only be included in the file if desired.
%    The values for each property must be saved in the MAT file with the
%    name of the property.  These names are given below.
%    COCKPIT(LANDSCAPE,'PropertyName1',value1,'PropertyName2',value2,...) allows
%    user control of flight properties using values extant in the workspace.
%    The only mandatory argument is LANDSCAPE.  The remaining properties all 
%    have default values.
%
%    The properties which can be set are:
%       landscape: The surface plot which creates the ground below the 
%                  airplane.  There is no default.
%       x,y: Optional arguments to the mesh command.  If x and y are specified,
%            the command to create the ground will be MESH(x,y,landscape), or
%            SURFL or SURF, depending on the value of GROUNDSTYLE.  Default is
%            x = 1:N and y = 1:M, where [M,N] = size(LANDSCAPE).
%       velocity: The velocity of the plane. Default is 1.
%       lift: The force of lift as a fraction of velocity.  Default is 0.3.
%       gravity: The force of gravity as a fraction of velocity.  
%                Default is 0.3.
%       map: The colormap used to create the ground. Default is bone.
%       bg: The sky color [ R G B ]. Default is sky blue.
%       shade: Shading style for the ground.  This must be set to one of the
%                following three options: 'flat', 'facted', or 'interp'. Default
%                is 'flat'.
%       groundstyle: The command to create the ground.  This must be set to
%                one of the following: 'mesh', 'surf', or 'surfl'. Default
%                is 'mesh'
%       horizon: This will activate the virtual plane view if it is set to
%                a non-zero value.  Default is 0.
%       start: This is the initial plane location.  Default is calculated
%              based on LANDSCAPE.
%       target: This is the initial plane target.  Default is calculated
%               based on LANDSCAPE.
%
%    Flying:
%       The mouse pointer is automatically centered in the middle of the 
%       viewing window.  This represents the control stick in the vertical
%       position.  Moving the mouse up and down is analagous to moving the
%       stick forward and backward respecitively, and changes the pitch of the
%       plane.  Moving the mouse right and left is analagous to moving the
%       stick right and left, and causes the plane to bank accordingly.
%
%       At any time during flight, the following keys may be pressed:
%          a: Turn head 18 degrees to the left
%          s: Turn head 36 degrees to the left
%          d: Look straight ahead (Any key other than a,s,f,g,r,x will do this.)
%          f: Turn head 18 degrees to the right
%          g: Turn head 36 degrees to the right
%          r: Look in reverse
%          x: Exits the game
%    
%    This program requires a fast computer to be entertaining in the least;
%    however, it can provide interesting visualization of three dimensional
%    data sets for any speed of computer.  This is NOT intended to be an
%    accurate portrayal of Newtonian physics.
%
%    The display screen automatically scale to any display size; however, the
%    instrument panel may not be completely visible at resolutions less than
%    1280x1024.
% 
%    Example:
%       cockpit(peaks);
%       cockpit(peaks,'groundstyle','surfl','shade','interp','horizon',1);
%
%       The best landscape (for powerful computers) is the map of Cape Cod,
%       included in the Matlab demos.
%
%    Tested on Matlab 5.2 on Linux
%
%    By Daniel Call  March, 1999
%    call@mit.edu


% Initialize the defaults.  
velocity = 1;
map = bone(64);
shade = 'flat';
groundstyle = 'mesh';
bg = [ .5274 .8047 .9180 ];
horizon = 0;
gravity = .3;
lift = .3;
% Parse the input.
if(nargin == 1)  % This may be a file name or a landscape
   if(ischar(varargin{1})) % This is a file.
      load(varargin{1});
   else % This is a landscape
      landscape = varargin{1};
      x = 1:size(landscape,1);
      y = 1:size(landscape,2);
   end
else % Parse the input variables.
   landscape = varargin{1};
   x = 1:size(landscape,1);
   y = 1:size(landscape,2);
   for i = 2:2:nargin
      eval(strcat(varargin{i},' = varargin{i+1}',';'));
   end
end
%% Determine our working area
ssize = get(0,'ScreenSize');
viewd = min(round(ssize(4)/2),640);
horzd = round(.594*viewd);
%% Build the scenery
aircraft = figure('Units','pixels','Position',[ horzd+20 54 viewd viewd ],...
       'NumberTitle','off','MenuBar','none','Name','Cockpit');
set(aircraft,'Color',bg);
eval(strcat(groundstyle,'(x,y,landscape);'));;
colormap(map);
shading(shade);
v = gca;
maxax = max(axis);
minax = min(axis);
axis([minax maxax minax maxax minax maxax]);
axis off;
%% Initialize flying controls
offset = get(aircraft,'Position');
center = offset(3:4)./2;
stick = [ 0 0 ];
[ alt loc head ] = readout(horzd,viewd);
if(horizon)
   pl = figure('Units','pixels','Position',[ 1 1 horzd horzd ],...
               'NumberTitle','off','MenuBar','none','Name','Plane');
end
%% Set plane position and target
if(~exist('target'))
   target = [ mean([maxax minax]) mean([maxax minax]) mean([maxax minax]) ];
end
if(~exist('start'))
   start = [ minax minax mean([maxax minax]) ];
end
camerat = target;
cameral = start;
camerau = get(v,'CameraUpVector');
camerad = unit(camerat - cameral);
camerau = unit(-cross(camerad,cross(camerad,camerau)));
set(v,'Projection','perspective');
set(v,'CameraTarget',camerat);
set(v,'CameraPosition',cameral);
set(v,'CameraViewAngle', 45);
set(0,'PointerLocation',center + offset(1:2));
%% Fly around
side = 0; push = 0; 
%
% This is the flying loop.  The program can be exited by pressing 'x' on the
% keyboard.
while(1)
   %% Lift, thrust and gravity determine the plane location.
   cameral = cameral + camerad.*velocity + camerau.*velocity.*lift ...
                                         - [ 0 0 gravity*velocity]; 
   %% Move the CameraTarget forward to prevent 180 degree spins.
   camerat = cameral + camerad.*2.*velocity; 
   %% Update the plane position
   set(v,'CameraPosition',cameral);
   set(v,'CameraUpVector',camerau);
   %
   % Set the view using head orientation.
   %
   switch(get(aircraft,'CurrentCharacter'))
      case 'a', set(v,'CameraTarget',cameral + ...
                       rotat(camerad,camerau,sign(camerau(1))*pi/5));
      case 's', set(v,'CameraTarget',cameral + ...
                       rotat(camerad,camerau,sign(camerau(1))*pi/10));
      case 'd', totangle = 0; set(v,'CameraTarget',camerat);
      case 'f', set(v,'CameraTarget',cameral + ...
                       rotat(camerad,camerau,sign(camerau(1))*-pi/10));
      case 'g', set(v,'CameraTarget',cameral + ...
                       rotat(camerad,camerau,sign(camerau(1))*-pi/5));
      case 'r', set(v,'CameraTarget',cameral + ...
                       rotat(camerad,camerau,pi));
      case 'x', break;
      otherwise, set(v,'CameraTarget',camerat);
   end
   set(loc,'String',strrep(strcat('X:',num2str(round(cameral(1))),'_', ...
                                  'Y:',num2str(round(cameral(2)))),'_',' '));
   set(alt,'String',num2str(round(cameral(3))));
   set(head,'String', ...
                 num2str(round(360*cart2pol(camerad(1),camerad(2))/(2*pi))));
   % Update the view.  This is where the vast majority of the delay occurs.
   drawnow;
   %%%%% Plane drawing
   if(horizon)
      figure(pl);
      plot3([ -1 1 ],[ 0 0 ],[ 0 0 ]);
      hold on;
      view_vec = unit(get(v,'CameraTarget') - cameral);
      pitch_vec = cross(camerau,camerad);
      plot3([0 pitch_vec(1)*1.2 ],[0 pitch_vec(2)*1.2 ],[0 pitch_vec(3)*1.2 ]);
      plot3([ 0 view_vec(1)*2 ], [ 0 view_vec(2)*2 ], [ 0 view_vec(3)*2 ]);
      plot3([ 0 0 ],[ -1 1 ],[ 0 0 ]);
      plot3([ 0 0 ],[ 0 0 ],[ -1 1 ]);
      wing = cross(camerad,camerau);
      wing1 = -wing;
      fill3([ 0 camerad(1) camerau(1) ], [ 0 camerad(2) camerau(2)], ...
            [ 0 camerad(3) camerau(3) ],'b');
      fill3([ 0 camerad(1) wing(1) ], [ 0 camerad(2) wing(2) ], ...
            [ 0 camerad(3) wing(3) ], 'r');
      fill3([ 0 camerad(1) wing1(1) ], [ 0 camerad(2) wing1(2) ], ...
            [ 0 camerad(3) wing1(3) ], 'r');
      hold off;
      drawnow;
      figure(get(v,'Parent'));
   end
   %
   stick = get(0,'PointerLocation');
   stick = stick - offset(1:2);
   if(abs(stick(2) - center(2)) > 5)
      push = (stick(2) - center(2))/center(2);
   else
      push = 0;
   end
   if(abs(stick(1) - center(1)) > 5)
      side = (stick(1) - center(1))/center(1);
   else
      side = 0;
   end
   %
   %%%%%%%% Bank
   % Rotate up to 5 degrees per click
   angle = sign(camerad(1))*(side*5)/360*2*pi;
   camerau = rotat(camerau,camerad,angle);
   %
   %%%%%%%% Pitch
   % Rotate up to 5 degrees per click (in radians)
   pitch_vec = cross(camerau,camerad);
   if(pitch_vec(1) == 0)
      angle = (push*5)/360*2*pi;
   else
      angle = sign(pitch_vec(1))*(push*5)/360*2*pi;
   end
   camerau = rotat(camerau,pitch_vec,angle);
   camerad = rotat(camerad,pitch_vec,angle);
end
delete(get(v,'Parent'));
delete(get(alt,'Parent'));
if(horizon)
   delete(pl);
end


function [ new_u ] = rotat(u,d,angle)
%
% [ new_u ] = rotat(u,d,angle)
%
% Rotate u about d.  Both vectors are assumed to share a common point at the
% origin.  u and d are in 3-space.
%
d = unit(d);
u = [ u 1 ];
if(d(3) == 0)
   R1 = eye(4);
elseif(d(2) == 0)
   R1 = [ 1 0 0 0 ; 0 0 -1 0; 0 1 0 0 ; 0 0 0 1 ];
else
   thet = atan(d(3)/d(2));
   R1 = [ 1 0 0 0
          0 cos(-thet) sin(-thet) 0
          0 -sin(-thet) cos(-thet) 0
          0 0 0 1 ];
end
d2 = [ d 1 ]*R1;
if(d2(2) == 0)
   R2 = eye(4);
elseif(d2(1) == 0)
   R2 = [ 0 -1 0 0 ; 1 0 0 0; 0 0 1 0 ; 0 0 0 1 ];
else
   phi = atan(d2(2)/d2(1));
   R2 = [ cos(-phi) sin(-phi) 0 0
          -sin(-phi) cos(-phi) 0 0
          0 0 1 0 
          0 0 0 1 ];
end
R3 = [ 1 0 0 0
       0 cos(angle) sin(angle) 0
       0 -sin(angle) cos(angle) 0
       0 0 0 1 ];
new_u = u*R1*R2*R3*inv(R2)*inv(R1);
new_u = new_u(1:3);



function [ uvec ] = unit(vector)
%
% UNIT
%
% Returns the unit vector representing vector and the scalar to multipy
% uvec by in order to recreate vector.
%
% [ uvec ] = unit(vector)
%
uvec = (vector)./( sqrt(sum(vector.^2)) );
I = find(max(vector) == vector);


function [ alt, loc, head ] = readout(horzd,viewd)
%
% READOUT creates an altimiter, compass, and GPS system.
%
readout = figure('Color',[0.8 0.8 0.8], ...
        'Position',[horzd+20 0 viewd 28], ...
        'Tag','Fig2', ...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'Resize','off');
h1 = uicontrol('Parent',readout, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ListboxTop',0, ...
        'Position',[ 27 9 57 13 ], ...
        'String','Altitude:', ...
        'Style','text', ...
        'Tag','StaticText1', ...
        'TooltipString','Altitude:');
h1 = uicontrol('Parent',readout, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ListboxTop',0, ...
        'Position',[191 9 58 14], ...
        'String','Location:', ...
        'Style','text', ...
        'Tag','StaticText2');
h1 = uicontrol('Parent',readout, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ListboxTop',0, ...
        'Position',[352 9 52 14], ...
        'String','Heading:', ...
        'Style','text', ...
        'Tag','StaticText2');
alt = uicontrol('Parent',readout, ...
        'Units','points', ...
        'BackgroundColor',[1 1 1], ...
        'ListboxTop',0, ...
        'Position',[95 6 77 18], ...
        'Style','edit', ...
        'Tag','EditText1');
loc = uicontrol('Parent',readout, ...
        'Units','points', ...
        'BackgroundColor',[1 1 1], ...
        'ListboxTop',0, ...
        'Position',[257 6 77 18], ...
        'Style','edit', ...
        'Tag','EditText1');
head = uicontrol('Parent',readout, ...
        'Units','points', ...
        'BackgroundColor',[1 1 1], ...
        'ListboxTop',0, ...
        'Position',[413 6 77 18], ...
        'Style','edit', ...
        'Tag','EditText1'); 